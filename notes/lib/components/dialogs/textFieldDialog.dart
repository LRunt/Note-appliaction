import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/componentUtils.dart';

class TextFieldDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String titleText;
  final String confirmButtonText;
  final TextEditingController controller;
  final utils = ComponentUtils();

  TextFieldDialog(
      {super.key,
      required this.onConfirm,
      required this.onCancel,
      required this.titleText,
      required this.confirmButtonText,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      backgroundColor: Colors.white,
      title: Text(titleText),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: utils.getButtonStyle(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: utils.getButtonStyle(),
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
