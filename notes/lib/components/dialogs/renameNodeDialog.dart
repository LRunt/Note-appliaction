import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class [RenameNodeDialog] creates alert dialog to the rename the node.
class RenameNodeDialog extends StatelessWidget {
  /// Name of the node what will be renamed.
  final String nodeName;

  /// Controller of the TextField in the alert dialog.
  final controller;

  /// Reaction on the Rename button click.
  final VoidCallback onRename;

  /// Reaction on the cancel button click.
  final VoidCallback onCancel;

  /// Constructor of the class [RenameNodeDialog].
  const RenameNodeDialog(
      {super.key,
      required this.nodeName,
      required this.controller,
      required this.onRename,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.renameNode(nodeName)),
      content: TextField(
        controller: controller,
      ),
      actions: [
        MaterialButton(
            onPressed: onRename,
            child: Text(AppLocalizations.of(context)!.rename)),
        MaterialButton(
          onPressed: onCancel,
          child: Text(AppLocalizations.of(context)!.cancel),
        )
      ],
    );
  }
}
