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
    boxHierachy.put(NOTES, notes);
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
    List notes = boxHierachy.get(NOTES);
    notes.add(noteId);
    boxHierachy.put(NOTES, notes);
  }

  void deleteNote(String noteId) {
    List notes = boxHierachy.get(NOTES);
    notes.remove(noteId);
    boxHierachy.put(NOTES, notes);
  }

  void updateNote(String oldNoteId, String newNoteId) {
    List notes = boxHierachy.get(NOTES);
    notes.remove(oldNoteId);
    notes.add(newNoteId);
    boxHierachy.put(NOTES, notes);
  }
}
