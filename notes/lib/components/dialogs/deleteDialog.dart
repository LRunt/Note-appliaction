import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/widgetConstants.dart';

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
class DeleteDialog extends StatelessWidget {
  /// A callback function that is called when the user presses the delete button.
  ///
  /// Use this to define the action that should be taken when the user confirms the deletion.
  final VoidCallback onDelete;

  /// A callback function that is called when the user presses the cancel button.
  ///
  /// Use this to define the action that should be taken when the user wants to cancel the delete action.
  final VoidCallback onCancel;

  /// The text to be displayed as the title of the dialog.
  final String titleText;

  /// The text to be displayed in the content of the dialog.
  final String contentText;

  /// Constructor of the [DeleteDialog].
  ///
  /// Requires four positional arguments:
  /// - [onDelete] a callback function which confirms delete.
  /// - [onCancel] a callback function which cancel delete.
  /// - [titleText] a text which will be shown in the title.
  /// - [contentText] a text which will be shown in the content.
  const DeleteDialog(
      {super.key,
      required this.onDelete,
      required this.onCancel,
      required this.titleText,
      required this.contentText});

  // Builds the UI of the delete confirm dialog.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: dialogBorder,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(titleText),
      content: Text(contentText),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: defaultButtonStyle,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: onDelete,
          style: defaultButtonStyle,
          child: Text(AppLocalizations.of(context)!.delete),
        ),
      ],
    );
  }
}
