import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/widgetConstants.dart';

/// A [DropdownMenuDialog] widget that presents a dropdown menu inside an alert dialog.
///
/// This widget is designed to offer a selection from a dropdown menu with the option to confirm or cancel the action.
/// It is customizable through parameters for title, confirm button text, dropdown items, and callbacks for each action.
///
/// Parameters:
/// - [onConfirm]: A callback function that is executed when the confirm button is pressed.
/// - [onCancel]: A callback function that is executed when the cancel button is pressed.
/// - [titleText]: Text to display as the title of the dialog.
/// - [confirmButtonText]: Text to display on the confirm button.
/// - [items]: A list of [DropdownMenuItem<String>] to display in the dropdown.
/// - [selectedValue]: The currently selected value in the dropdown. Can be `null` initially.
/// - [onSelect]: A callback that is executed when a new item is selected from the dropdown.
///
/// Usage example:
/// ```dart
/// DropdownMenuDialog(
///   onConfirm: () {
///     // Handle confirmation action
///   },
///   onCancel: () {
///     // Handle cancellation action
///   },
///   titleText: 'Select Option',
///   confirmButtonText: 'Confirm',
///   items: [
///     DropdownMenuItem<String>(
///       value: 'Option 1',
///       child: Text('Option 1'),
///     ),
///     DropdownMenuItem<String>(
///       value: 'Option 2',
///       child: Text('Option 2'),
///     ),
///   ],
///   onSelect: (value) {
///     // Handle selection change
///   },
/// )
/// ```
///
/// This dialog leverages [AlertDialog] to present its content, providing a consistent and familiar UI for users.
// ignore: must_be_immutable
class DropdownMenuDialog extends StatelessWidget {
  /// A callback function that is called when the user presses the confirm button.
  ///
  /// Use this to define the action that should be taken when the user confirms action.
  final VoidCallback onConfirm;

  /// A callback function that is called when the user presses the cancel button.
  ///
  /// Use this to define the action that should be taken when the user wants to cancel the action.
  final VoidCallback onCancel;

  /// The text to be displayed as the title of the dialog.
  final String titleText;

  /// The text of what will be shown in the confirm button.
  final String confirmButtonText;

  /// A list of [DropdownMenuItem<String>] to display in the dropdown.
  final List<DropdownMenuItem<String>> items;

  /// The currently selected value in the dropdown. Can be `null` initially.
  String? selectedValue;

  ///  A callback that is executed when a new item is selected from the dropdown.
  final Function(String?) onSelect;

  /// Constructor of the [DropdownMenuDialog]
  ///
  /// [onConfirm] and [onCancel] must not be null. They define the callback functions
  /// for the confirm and cancel actions, respectively. [titleText] and [contentText]
  /// provide the text displayed in the dialog.
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

  // Builds the UI of the textfield dialog.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: dialogBorder,
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
          key: const Key('cancelButton'),
          onPressed: onCancel,
          style: defaultButtonStyle,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          key: const Key('confirmButton'),
          onPressed: onConfirm,
          style: defaultButtonStyle,
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
