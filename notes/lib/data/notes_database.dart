import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes/model/myTreeNode.dart';

//reference to our box
final _myBox = Hive.box("Notes_Database");

class NotesDatabase {
  List<MyNode> nodes = [];

  // create initial default data
  void createDefaultData() {}

  // load data if already exists
  void loadData() {}

  // update database
  void updateDatabase() {}
}
