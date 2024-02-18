import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:notes/screens/mainScreen.dart';
import 'package:notes/model/myTreeNode.dart';
import 'boxes.dart';

void main() async {
  // initialize hive
  await Hive.initFlutter();

  // registring myTreeNodeAdapter
  Hive.registerAdapter(MyTreeNodeAdapter());

  // open a box
  boxHierachy = await Hive.openBox<MyTreeNode>("Notes_Database");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainScreen());
  }
}
