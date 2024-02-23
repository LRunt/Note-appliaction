import 'package:flutter/material.dart';

/// Class [DeleteNodeDialog] is used to confirm the deletion of the node with [nodeName].
class DeleteNodeDialog extends StatelessWidget {
  /// Name of the node what will be deleted.
  final String nodeName;

  /// Reaction on the Delete button click.
  final VoidCallback onDelete;

  /// Reaction on the Cancel button click.
  final VoidCallback onCancel;

  /// Constructor of the [DeleteNodeDialog].
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
