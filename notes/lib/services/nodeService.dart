import 'package:logging/logging.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/data/notesDatabase.dart';
import 'package:notes/logger.dart';
import 'package:notes/model/myTreeNode.dart';
import 'dart:developer';

class NodeService {
  HierarchyDatabase hierarchyDb;
  NotesDatabase notesDatabase;
  ComponentUtils utils = ComponentUtils();

  // Because of testing
  NodeService({
    HierarchyDatabase? hierarchyDb,
    NotesDatabase? notesDatabase,
  })  : hierarchyDb = hierarchyDb ?? HierarchyDatabase(),
        notesDatabase = notesDatabase ?? NotesDatabase();

  // Delete
  void deleteNode(MyTreeNode node, MyTreeNode parent) {
    AppLogger.log('Deleting node ${node.id}');
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

  // Rename
  bool renameNode(MyTreeNode node, String newName) {
    AppLogger.log('Renaming node ${node.id}');
    if (newName.isEmpty) {
      AppLogger.log("The name is empty", level: Level.WARNING);
      utils.showErrorToast("Name is not filled");
      return false;
    } else if (containsDisabledChars(newName)) {
      AppLogger.log("Disabled chars", level: Level.WARNING);
      utils.showErrorToast("Name contains not allowed chars");
      return false;
    } else if (siblingWithSameName(node.id, newName, false)) {
      AppLogger.log("Sibling with same name", level: Level.WARNING);
      utils.showErrorToast("There exists a node with same name");
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

  // Create
  bool createNewNode(MyTreeNode node, String nodeName, bool nodeType) {
    AppLogger.log('Creating new node');
    if (nodeName.isEmpty) {
      AppLogger.log("The name is empty", level: Level.WARNING);
      utils.showErrorToast("Name is not filled");
      return false;
    } else if (containsDisabledChars(nodeName)) {
      AppLogger.log("Disabled chars", level: Level.WARNING);
      utils.showErrorToast("Name contains not allowed chars");
      return false;
    } else if (siblingWithSameName(node.id, nodeName, true)) {
      AppLogger.log("Sibling with same name", level: Level.WARNING);
      utils.showErrorToast("There exists a node with same name");
      log("Sibling with same name");
      return false;
    } else {
      String nodeId = node.id + DELIMITER + nodeName;
      MyTreeNode newNode = MyTreeNode(id: nodeId, title: nodeName, isNote: nodeType);
      node.addChild(newNode);
      hierarchyDb.updateDatabase();
      if (nodeType) {
        notesDatabase.createNote(nodeId);
      }
      return true;
    }
  }

  // Move
  bool moveNode(MyTreeNode node, String newParent) {
    AppLogger.log('Moving node ${node.id}, new parent: $newParent');
    MyTreeNode? parent = getNode(newParent);
    if (parent == null) {
      return false;
      // return error
    } else {
      MyTreeNode? oldParent = getParent(node.id);
      oldParent!.children.remove(node);
      parent.addChild(node);
      String oldNoteId = node.id;
      node.id = newParent + DELIMITER + node.title;
      if (node.isNote) {
        notesDatabase.changeNoteId(oldNoteId, node.id);
      }
      for (MyTreeNode child in node.children) {
        changeId(child, node.id);
      }
      hierarchyDb.updateDatabase();
      return true;
    }
  }

  //Serching for node or parent
  MyTreeNode? getNode(String nodeId) {
    List<String> path = nodeId.split(DELIMITER);
    log("$path");
    int level = 1;
    hierarchyDb.loadData();
    List<MyTreeNode> nodeList = HierarchyDatabase.roots;
    log("Starting serching, nodeList: $nodeList");
    return searchChildren(level, nodeList, path);
  }

  MyTreeNode? searchChildren(int level, List<MyTreeNode> nodeList, List<String> path) {
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

  MyTreeNode? searchParent(
      int level, List<MyTreeNode> nodeList, List<String> path, MyTreeNode? parent) {
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

  bool siblingWithSameName(String nodeId, String newName, bool newNode) {
    MyTreeNode? parent;
    if (newNode) {
      parent = getNode(nodeId);
    } else {
      parent = getParent(nodeId);
    }
    log("Parent: $parent");
    if (parent == null) {
      return false;
    } else {
      for (MyTreeNode sibling in parent.children) {
        if (sibling.title == newName) {
          return true;
        }
      }
    }
    return false;
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

  List<String> getFoldersToMove(MyTreeNode node) {
    List<String> folders = getAllFolders();
    if (!node.isNote) {
      folders.remove(node.id);
    }
    folders.remove(getParentPath(node.id));
    return folders;
  }

  /// Controls if the node is root or not
  bool isRoot(String nodeId) {
    for (MyTreeNode root in HierarchyDatabase.roots) {
      if (root.id == nodeId) {
        return true;
      }
    }
    return false;
  }
}
