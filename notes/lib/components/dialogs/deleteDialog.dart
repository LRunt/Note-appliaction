import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class [DeleteDialog] is used to confirm the deletion of the node with [nodeName].
class DeleteDialog extends StatelessWidget {
  /// Reaction on the Delete button click.
  final VoidCallback onDelete;

  /// Reaction on the Cancel button click.
  final VoidCallback onCancel;

  final String titleText;

  final String contentText;

  /// Constructor of the [DeleteDialog].
  const DeleteDialog(
      {super.key,
      required this.onDelete,
      required this.onCancel,
      required this.titleText,
      required this.contentText});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleText),
      content: Text(contentText),
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
