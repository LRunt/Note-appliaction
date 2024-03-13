import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/componentUtils.dart';

// ignore: must_be_immutable
class DropdownMenuDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String titleText;
  final String confirmButtonText;
  final List<DropdownMenuItem<String>> items;
  String? selectedValue;
  final Function(String?) onSelect;
  final utils = ComponentUtils();

  DropdownMenuDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.titleText,
    required this.confirmButtonText,
    required this.items,
    required this.onSelect,
    this.selectedValue,
  });

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
      content: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items,
        onChanged: (value) {
          selectedValue = value;
          onSelect(value);
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
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
