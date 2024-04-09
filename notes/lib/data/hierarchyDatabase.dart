import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';
import 'dart:developer';

class HierarchyDatabase {
  static List<MyTreeNode> roots = [];
  static List<String> rootList = [];
  static List noteList = [];
  static List<MyTreeNode> conflictData = [];

  // create initial default data
  void createDefaultData() {
    roots = [];
    rootList = [];
    boxSynchronization.put(ROOT_LIST, rootList);
    boxSynchronization.put(NOTE_LIST, []);
  }

  // load data if already exists
  void loadData() {
    log("Loading data...");

    roots = [];
    rootList = boxSynchronization.get(ROOT_LIST);
    log("Root list: $rootList");
    for (String root in rootList) {
      MyTreeNode node = boxHierachy.get(root);
      log("Adding node: $root, node: $node");
      roots.add(node);
    }
  }

  void saveRoot(MyTreeNode root) {
    log("Creating root");
    roots.add(root);
    rootList.add(root.id);
    log("Root list $rootList");
    boxSynchronization.put(ROOT_LIST, rootList);
    boxSynchronization.put(root.id, DateTime.now().microsecondsSinceEpoch);
    boxHierachy.put(root.id, root);
    boxSynchronization.put(LAST_CHANGE, DateTime.now().microsecondsSinceEpoch);
  }

  void downloadRoot(MyTreeNode root) {
    roots.add(root);
    rootList.add(root.id);
    boxSynchronization.put(ROOT_LIST, rootList);
    boxHierachy.put(root.id, root);
  }

  void deleteRoot(MyTreeNode root) {
    log("Deleting root");
    rootList.remove(root.id);
    roots.remove(root);
    boxSynchronization.put(ROOT_LIST, rootList);
    boxSynchronization.delete(root.id);
    boxHierachy.delete(root.id);
    updateDatabase();
  }

  void updateRoot(String oldRootId, String newRootId) {
    log("Update root");
    rootList = boxSynchronization.get(ROOT_LIST);
    rootList.remove(oldRootId);
    rootList.add(newRootId);
    log("$rootList");
    boxSynchronization.delete(oldRootId);
    boxSynchronization.put(newRootId, DateTime.now().microsecondsSinceEpoch);
    boxSynchronization.put(LAST_CHANGE, DateTime.now().microsecondsSinceEpoch);
    boxSynchronization.put(ROOT_LIST, rootList);
  }

  // update database
  void updateDatabase() {
    log("Updating database: ${roots.firstOrNull}");
    boxSynchronization.put(ROOT_LIST, rootList);
    for (MyTreeNode root in roots) {
      boxHierachy.put(root.id, root);
    }
    // Adding timestamp of last change
    boxSynchronization.put(LAST_CHANGE, DateTime.now().microsecondsSinceEpoch);
  }

  void saveHierarchy(MyTreeNode hierarchy) {
    roots[0] = hierarchy;
    updateDatabase();
  }

  void addNote(String noteId) {
    noteList = boxSynchronization.get(NOTE_LIST);
    noteList.add(noteId);
    log("$noteList");
    boxSynchronization.put(NOTE_LIST, noteList);
  }

  void deleteNote(String noteId) {
    noteList = boxSynchronization.get(NOTE_LIST);
    noteList.remove(noteId);
    log("$noteList");
    boxSynchronization.put(NOTE_LIST, noteList);
  }

  void updateNote(String oldNoteId, String newNoteId) {
    noteList = boxSynchronization.get(NOTE_LIST);
    noteList.remove(oldNoteId);
    noteList.add(newNoteId);
    log("$noteList");
    boxSynchronization.put(NOTE_LIST, noteList);
  }

  int getLastChange() {
    return boxSynchronization.get(LAST_CHANGE);
  }

  MyTreeNode getRoot(String rootId) {
    return boxHierachy.get(rootId);
  }

  int getRootLastChangeTime(String rootId) {
    return boxSynchronization.get(rootId);
  }

  List getNotes() {
    return boxSynchronization.get(NOTE_LIST);
  }

  void saveNotes(List notes) {
    boxSynchronization.put(NOTE_LIST, notes);
  }

  void saveConflictData() {
    if (!boxHierachy.containsKey(CONFLICT) || boxHierachy.get(CONFLICT) == null) {
      initConflictData();
    }
    MyTreeNode conflicts = boxHierachy.get(CONFLICT);
    String name = CONFLICT + DateTime.now().toString();
    MyTreeNode newConflict = MyTreeNode(id: name, title: name, isNote: false, isLocked: false);
    newConflict.addChild(roots.first);
    conflicts.addChild(newConflict);
    boxHierachy.put(CONFLICT, conflicts);
  }

  void saveConflictNote(String noteId) {
    if (!boxHierachy.containsKey(CONFLICT) || boxHierachy.get(CONFLICT) == null) {
      initConflictData();
    }
    MyTreeNode conflicts = boxHierachy.get(CONFLICT);
    String name = CONFLICT + DateTime.now().toString() + DELIMITER + noteId;
    MyTreeNode newConflict = MyTreeNode(id: name, title: name, isNote: true, isLocked: false);
    conflicts.addChild(newConflict);
    String noteContent = boxNotes.get(noteId);
    boxNotes.put(name, noteContent);
  }

  void saveConflictRoot(String rootId) {
    if (!boxHierachy.containsKey(CONFLICT) || boxHierachy.get(CONFLICT) == null) {
      initConflictData();
    }
    MyTreeNode conflicts = boxHierachy.get(CONFLICT);
    String name = CONFLICT + DateTime.now().toString() + DELIMITER + rootId;
    MyTreeNode newConflict = MyTreeNode(id: name, title: name, isNote: false, isLocked: false);
    conflicts.addChild(newConflict);
  }

  void loadConflictData() {
    MyTreeNode conflicts = boxHierachy.get(CONFLICT);
    conflictData = [conflicts];
  }

  void initConflictData() {
    MyTreeNode conflictNode =
        MyTreeNode(id: "Conflicts", title: "Conflicts", isNote: false, isLocked: false);
    boxHierachy.put(CONFLICT, conflictNode);
  }
}
