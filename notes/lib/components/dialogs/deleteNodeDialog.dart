import 'package:flutter/material.dart';

class DeleteNodeDialog extends StatelessWidget {
  final String nodeName;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const DeleteNodeDialog(
      {super.key,
      required this.nodeName,
      required this.onDelete,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete $nodeName"),
      content: Text("Are you sure to delete $nodeName node?"),
      actions: [
        MaterialButton(onPressed: onDelete, child: const Text("DELETE")),
        MaterialButton(
          onPressed: onCancel,
          child: const Text("CANCEL"),
        )
      ],
    );
  }
}
