import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class [CreateNodeDialog] creates alert dialog to create new note or directory.
class CreateNodeDialog extends StatelessWidget {
  /// Name of the node to which we are creating new children.
  final String nodeName;

  /// Controller of the alert dialog textfield.
  final controller;

  /// Reaction on the Create button click.
  final VoidCallback onCreate;

  /// Reaction on the Cancel button click.
  final VoidCallback onCancel;

  /// Constructor of the class [CreateNodeDialog].
  const CreateNodeDialog(
      {super.key,
      required this.nodeName,
      required this.controller,
      required this.onCreate,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.newNode),
      content: TextField(
        controller: controller,
      ),
      actions: [
        MaterialButton(
            onPressed: onCreate,
            child: Text(AppLocalizations.of(context)!.create)),
        MaterialButton(
          onPressed: onCancel,
          child: Text(AppLocalizations.of(context)!.cancel),
        )
      ],
    );
  }
}
