import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';
import 'dart:developer';

//import 'package:notes/services/firebaseService.dart';

class HierarchyDatabase {
  //final FirebaseService _firebaseService = FirebaseService();

  static List<MyTreeNode> roots = [];
  static List<String> rootList = [];
  static List<String> noteList = [];
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
      print("Adding node: $root, node: $node");
      roots.add(node);
    }
  }

  void saveRoot(MyTreeNode root) {
    log("Creating root");
    roots.add(root);
    rootList.add(root.id);
    log("Root list $rootList");
    boxSynchronization.put(ROOT_LIST, rootList);
    boxHierachy.put(root.id, root);
  }

  void deleteRoot(String rootId) {
    log("Deleting root");
    rootList.remove(rootId);
    boxHierachy.delete(rootId);
    loadData();
  }

  // update database
  void updateDatabase() {
    log("Updating database: ${roots.firstOrNull}");
    boxHierachy.put(TREE_STORAGE, roots.firstOrNull);
    // Adding timestamp of last change
    boxSynchronization.put(TREE_CHANGE, DateTime.now().microsecondsSinceEpoch);
  }

  void saveHierarchy(MyTreeNode hierarchy) {
    roots[0] = hierarchy;
    updateDatabase();
  }

  void addNote(String noteId) {
    List notes = boxSynchronization.get(NOTE_LIST);
    notes.add(noteId);
    log("$notes");
    boxSynchronization.put(NOTE_LIST, notes);
  }

  void deleteNote(String noteId) {
    List notes = boxSynchronization.get(NOTE_LIST);
    notes.remove(noteId);
    log("$notes");
    boxSynchronization.put(NOTE_LIST, notes);
  }

  void updateNote(String oldNoteId, String newNoteId) {
    List notes = boxSynchronization.get(NOTE_LIST);
    notes.remove(oldNoteId);
    notes.add(newNoteId);
    log("$notes");
    boxSynchronization.put(NOTE_LIST, notes);
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
