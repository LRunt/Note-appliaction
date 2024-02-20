import 'package:flutter/material.dart';

class RenameNodeDialog extends StatelessWidget {
  final String nodeName;
  final controller;
  final VoidCallback onRename;
  final VoidCallback onCancel;

  const RenameNodeDialog(
      {super.key,
      required this.nodeName,
      required this.controller,
      required this.onRename,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rename $nodeName"),
      content: TextField(
        controller: controller,
      ),
      actions: [
        MaterialButton(onPressed: onRename, child: const Text("RENAME")),
        MaterialButton(
          onPressed: onCancel,
          child: const Text("CANCEL"),
        )
      ],
    );
  }
}
