import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';
import 'dart:developer';

//import 'package:notes/services/firebaseService.dart';

class HierarchyDatabase {
  //final FirebaseService _firebaseService = FirebaseService();

  static List<MyTreeNode> roots = [];

  // create initial default data
  void createDefaultData() {
    roots = [MyTreeNode(id: "|Home", title: "Home", isNote: false)];
    boxHierachy.put(TREE_STORAGE, roots.firstOrNull);
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
    boxSynchronization.put(TREE_CHANGE, DateTime.now().toIso8601String());
    //updateFirebaseDatabase();
  }

  // Update firebase database
  /*void updateFirebaseDatabase() {
    if (_firebaseService.isLoggedIn()) {
      _firebaseService.saveTreeStructure(roots.first);
      _firebaseService.saveTreeTime();
    }
  }*/
}
