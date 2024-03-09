import 'package:notes/assets/constants.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/data/notesDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'dart:developer';

class NodeService {
  HierarchyDatabase hierarchyDb;
  NotesDatabase notesDatabase;

  // Because of testing
  NodeService({
    HierarchyDatabase? hierarchyDb,
    NotesDatabase? notesDatabase,
  })  : hierarchyDb = hierarchyDb ?? HierarchyDatabase(),
        notesDatabase = notesDatabase ?? NotesDatabase();

  MyTreeNode? getNode(String nodeId) {
    List<String> path = nodeId.split(DELIMITER);
    log("$path");
    int level = 1;
    hierarchyDb.loadData();
    List<MyTreeNode> nodeList = hierarchyDb.roots;
    log("Starting serching, nodeList: $nodeList");
    return searchChildren(level, nodeList, path);
  }

  MyTreeNode? searchChildren(
      int level, List<MyTreeNode> nodeList, List<String> path) {
    log("Search children ${path.elementAt(level)}");
    for (MyTreeNode node in nodeList) {
      if (level == path.length - 1 && node.title == path[level]) {
        return node;
      }
      if (node.title == path[level]) {
        return searchChildren(level + 1, node.children, path);
      }
    }
    return null;
  }

  MyTreeNode? getParent(String nodeId) {
    List<String> path = nodeId.split(DELIMITER);
    int level = 1;
    hierarchyDb.loadData();
    List<MyTreeNode> nodeList = hierarchyDb.roots;
    return searchParent(level, nodeList, path, null);
  }

  MyTreeNode? searchParent(int level, List<MyTreeNode> nodeList,
      List<String> path, MyTreeNode? parent) {
    log("Search children ${path.elementAt(level)}");
    for (MyTreeNode node in nodeList) {
      if (level == path.length - 1 && node.title == path[level]) {
        return parent;
      }
      if (node.title == path[level]) {
        return searchChildren(level + 1, node.children, path);
      }
    }
    return null;
  }

  bool containsDisabledChars(String name) {
    for (String disabledChar in DISABLED_CHARS) {
      if (name.contains(disabledChar)) {
        return true;
      }
    }
    return false;
  }

  bool siblingWithSameName(String nodeId, String newName) {
    MyTreeNode? parent = getParent(nodeId);
    if (parent == null) {
      return true; //TODO throw error
    } else {
      for (MyTreeNode sibling in parent.children) {
        if (sibling.title == newName) {
          return true;
        }
      }
    }
    return false;
  }

  bool renameNode(String nodeId, String newName) {
    if (containsDisabledChars(newName)) {
      return false;
    } else if (siblingWithSameName(nodeId, newName)) {
      return false;
    }
    //Todo
    return true;
  }

  void changeChidrenId(String parentId) {}

  void createNewNode(String parentId, String nodeName, bool nodeType) {}
}
