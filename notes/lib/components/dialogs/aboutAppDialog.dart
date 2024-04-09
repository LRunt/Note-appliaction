import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/componentUtils.dart';

/// A [DeleteDialog] widget that displays an alert dialog for confirming deletion.
///
/// It presents a customizable title and content along with Cancel and Delete buttons
/// to either abort or proceed with the deletion process, respectively. The appearance
/// and behavior of the dialog are defined by the passed parameters and utility methods.
///
/// Parameters:
/// - [onDelete]: Callback function to execute when the Delete button is pressed.
/// - [onCancel]: Callback function to execute when the Cancel button is pressed.
/// - [titleText]: The text displayed in the title section of the dialog.
/// - [contentText]: The text displayed in the content section of the dialog.
///
/// Usage example:
/// ```dart
/// DeleteDialog(
///   onDelete: () {
///     // Handle delete action
///   },
///   onCancel: () {
///     // Handle cancel action
///   },
///   titleText: 'Confirm Delete',
///   contentText: 'Are you sure you want to delete this item?',
/// )
/// ```
class AboutAppDialog extends StatelessWidget {
  /// A callback function that is called when the user presses the delete button.
  ///
  /// Use this to define the action that should be taken when the user confirms the deletion.
  final VoidCallback onClose;

  /// A utility object for styling the widget.
  final utils = ComponentUtils();

  /// Constructor of the [DeleteDialog].
  ///
  /// [onDelete] and [onCancel] must not be null. They define the callback functions
  /// for the delete and cancel actions, respectively. [titleText] and [contentText]
  /// provide the text displayed in the dialog.
  AboutAppDialog({super.key, required this.onClose});

  // Builds the UI of the delete confirm dialog.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      backgroundColor: Colors.white,
      title: Text("Informace o aplikaci"),
      content: Text(
          "Aplikace pro tvorbu poznámek\nAutor: Lukáš Runt\nVerze: 1.0.0\nDatum vydání: 15. 04. 2024"),
      actions: [
        FilledButton(
          onPressed: onClose,
          style: utils.getButtonStyle(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
