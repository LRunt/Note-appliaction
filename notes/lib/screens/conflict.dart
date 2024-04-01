import 'package:flutter/material.dart';
import 'package:notes/components/conflictTree.dart';

class Conflict extends StatelessWidget {
  const Conflict({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Conflicts"),
        ),
        body: const SingleChildScrollView(
          child: ConflictTree(),
        ));
  }
}
