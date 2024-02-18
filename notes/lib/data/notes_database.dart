import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
//reference to our box
//final _myBox = Hive.box<List<MyTreeNode>>("Notes_Database");

class NotesDatabase {
  List<MyTreeNode> roots = [];

  // create initial default data
  void createDefaultData() {
    roots = [MyTreeNode(id: "/home", title: "Home", isNote: false)];
    boxHierachy.put("TREE_VIEW", roots);
  }

  // load data if already exists
  void loadData() {
    List<MyTreeNode>? storedData = boxHierachy.get("TREE_VIEW");

    if (storedData != null && storedData.isNotEmpty) {
      roots = storedData;
    } else {
      roots = [MyTreeNode(id: "/home", title: "Home", isNote: false)];
    }
  }

  // update database
  void updateDatabase() {
    boxHierachy.put("TREE_VIEW", roots);
  }
}
