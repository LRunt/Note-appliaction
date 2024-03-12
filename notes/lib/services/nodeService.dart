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
    List<MyTreeNode> nodeList = HierarchyDatabase.roots;
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
    log("Getting parent");
    List<String> path = nodeId.split(DELIMITER);
    int level = 1;
    hierarchyDb.loadData();
    List<MyTreeNode> nodeList = HierarchyDatabase.roots;
    return searchParent(level, nodeList, path, null);
  }

  MyTreeNode? searchParent(int level, List<MyTreeNode> nodeList,
      List<String> path, MyTreeNode? parent) {
    log("Search parent ${path.elementAt(level)}");
    for (MyTreeNode node in nodeList) {
      if (level == path.length - 1 && node.title == path[level]) {
        return parent;
      }
      if (node.title == path[level]) {
        return searchParent(level + 1, node.children, path, node);
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
    log("Parent: $parent");
    if (parent == null) {
      return true;
    } else {
      for (MyTreeNode sibling in parent.children) {
        print("Sibling title: ${sibling.title}");
        print("NewName: ${newName}");
        if (sibling.title == newName) {
          return true;
        }
      }
    }
    return false;
  }

  bool renameNode(MyTreeNode node, String newName) {
    if (containsDisabledChars(newName)) {
      return false;
    } else if (siblingWithSameName(node.id, newName)) {
      return false;
    } else {
      node.title = newName;
      String newId = changeNameInId(node.id, newName);
      if (node.isNote) {
        notesDatabase.changeNoteId(node.id, newId);
      }
      node.id = newId;
      for (MyTreeNode child in node.children) {
        changeId(child, newId);
      }
      hierarchyDb.updateDatabase();
      return true;
    }
  }

  void changeId(MyTreeNode node, String path) {
    String newId = changePathInId(node.id, path);
    if (node.isNote) {
      notesDatabase.changeNoteId(node.id, newId);
    }
    node.id = newId;
    for (MyTreeNode child in node.children) {
      changeId(child, node.id);
    }
  }

  String changeNameInId(String actualPath, String newFileName) {
    List<String> path = actualPath.split(DELIMITER);
    String newId = "";
    for (int i = 1; i < path.length - 1; i++) {
      newId += DELIMITER + path[i];
    }
    newId += DELIMITER + newFileName;
    return newId;
  }

  String changePathInId(String path, String newPath) {
    List<String> splittedPath = path.split(DELIMITER);
    String fileName = splittedPath[splittedPath.length - 1];
    return newPath + DELIMITER + fileName;
  }

  String getParentPath(String path) {
    List<String> splittedPath = path.split(DELIMITER);
    String parentPath = "";
    for (int i = 1; i < splittedPath.length - 1; i++) {
      parentPath += DELIMITER + splittedPath[i];
    }
    return parentPath;
  }

  bool createNewNode(MyTreeNode node, String nodeName, bool nodeType) {
    if (containsDisabledChars(nodeName)) {
      return false;
    } else if (siblingWithSameName(node.id, nodeName)) {
      return false;
    } else {
      MyTreeNode newNode = MyTreeNode(
          id: node.id + DELIMITER + nodeName,
          title: nodeName,
          isNote: nodeType);
      node.addChild(newNode);
      hierarchyDb.updateDatabase();
      return true;
    }
  }

  List<String> getAllFolders() {
    List<String> folders = [];
    for (MyTreeNode node in HierarchyDatabase.roots) {
      getFolders(folders, node);
    }
    return folders;
  }

  void getFolders(List<String> folders, MyTreeNode node) {
    if (!node.isNote) {
      folders.add(node.id);
    }
    for (MyTreeNode child in node.children) {
      getFolders(folders, child);
    }
  }

  void deleteNode(MyTreeNode node, MyTreeNode parent) {
    // If node is note, delete note
    if (node.isNote) {
      notesDatabase.deleteNote(node.id);
    }
    // If node have children -> delete its notes
    for (MyTreeNode child in node.children) {
      deleteNode(child, node);
    }
    parent.children.remove(node);
    hierarchyDb.updateDatabase();
  }
}
