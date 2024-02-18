import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';
import 'dart:developer';

class NotesDatabase {
  List<MyTreeNode> roots = [];

  // create initial default data
  void createDefaultData() {
    roots = [MyTreeNode(id: "/home", title: "Home", isNote: false)];
    boxHierachy.put(TREE_STORAGE, roots.firstOrNull);
  }

  // load data if already exists
  void loadData() {
    MyTreeNode? storedData = boxHierachy.get(TREE_STORAGE);
    log("Loaded data: ${storedData}");

    if (storedData != null) {
      roots = [storedData];
    } else {
      roots = [MyTreeNode(id: "/home", title: "Home", isNote: false)];
    }
  }

  // update database
  void updateDatabase() {
    log("Updating database: ${roots.firstOrNull}");
    boxHierachy.put(TREE_STORAGE, roots.firstOrNull);
  }
}
