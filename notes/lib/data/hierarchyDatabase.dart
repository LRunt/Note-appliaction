import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';
import 'dart:developer';

//import 'package:notes/services/firebaseService.dart';

class HierarchyDatabase {
  //final FirebaseService _firebaseService = FirebaseService();

  static List<MyTreeNode> roots = [];
  static List<String> notes = [];

  // create initial default data
  void createDefaultData() {
    roots = [MyTreeNode(id: "|Home", title: "Home", isNote: false)];
    boxHierachy.put(TREE_STORAGE, roots.firstOrNull);
    boxSynchronization.put(NOTES, []);
  }

  // load data if already exists
  void loadData() {
    MyTreeNode? storedData = boxHierachy.get(TREE_STORAGE);
    log("Loaded data: ${storedData}");

    if (storedData != null) {
      roots = [storedData];
    } else {
      roots = [MyTreeNode(id: "|Home", title: "Home", isNote: false)];
    }
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
    List notes = boxSynchronization.get(NOTES);
    notes.add(noteId);
    log("$notes");
    boxSynchronization.put(NOTES, notes);
  }

  void deleteNote(String noteId) {
    List notes = boxSynchronization.get(NOTES);
    notes.remove(noteId);
    log("$notes");
    boxSynchronization.put(NOTES, notes);
  }

  void updateNote(String oldNoteId, String newNoteId) {
    List notes = boxSynchronization.get(NOTES);
    notes.remove(oldNoteId);
    notes.add(newNoteId);
    log("$notes");
    boxSynchronization.put(NOTES, notes);
  }

  List getNotes() {
    return boxSynchronization.get(NOTES);
  }

  void saveNotes(List notes) {
    boxSynchronization.put(NOTES, notes);
  }

  void saveConflictData() {
    if (roots.length == 1) {
      MyTreeNode conflict = MyTreeNode(id: '|conflict', title: 'Conflict', isNote: false);
      roots.add(conflict);
      conflict.addChild(roots.first);
    } else {
      roots[1].children.add(roots.first);
    }
  }
}
