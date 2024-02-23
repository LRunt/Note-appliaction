import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      title: Text(AppLocalizations.of(context)!.deleteNode(nodeName)),
      content: Text(AppLocalizations.of(context)!.deleteContent(nodeName)),
      actions: [
        MaterialButton(
            onPressed: onDelete,
            child: Text(AppLocalizations.of(context)!.delete)),
        MaterialButton(
          onPressed: onCancel,
          child: Text(AppLocalizations.of(context)!.cancel),
        )
      ],
    );
  }
}
