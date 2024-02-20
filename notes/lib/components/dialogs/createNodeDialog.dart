import 'package:flutter/material.dart';

class CreateNodeDialog extends StatelessWidget {
  final String nodeName;
  final controller;
  final VoidCallback onCreate;
  final VoidCallback onCancel;

  const CreateNodeDialog(
      {super.key,
      required this.nodeName,
      required this.controller,
      required this.onCreate,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create new note"),
      content: TextField(
        controller: controller,
      ),
      actions: [
        MaterialButton(onPressed: onCreate, child: const Text("CREATE")),
        MaterialButton(
          onPressed: onCancel,
          child: const Text("CANCEL"),
        )
      ],
    );
  }
}
