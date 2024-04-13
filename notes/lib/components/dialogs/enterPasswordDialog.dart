import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/widgetConstants.dart';
import 'package:notes/components/myTextField.dart';

/// A [EnterPasswordDialog] widget that presents a dialog with a text field for capturing a password.
///
/// This widget is designed to capture a password input from the user, offering options
/// for confirmation and cancellation. It uses [AlertDialog] as its
/// base structure and includes custom styling and localization support.
///
/// Parameters:
/// - [onConfirm]: A callback function that is executed when the confirm button is pressed.
/// - [onCancel]: A callback function that is executed when the cancel button is pressed.
/// - [titleText]: Text to display as the title of the dialog.
/// - [confirmButtonText]: Text to display on the confirm button.
/// - [controller]: Controller for managing the text field's content.
///
/// Usage example:
/// ```dart
/// EnterPasswordDialog(
///   onConfirm: () {
///     // Handle confirmation action
///   },
///   onCancel: () {
///     // Handle cancellation action
///   },
///   titleText: 'Enter Password',
///   confirmButtonText: 'Confirm',
///   controller: myTextController,
/// )
/// ```
///
/// This dialog leverages [AlertDialog] to present its content, providing a consistent and familiar UI for users.
class EnterPasswordDialog extends StatelessWidget {
  /// A callback function that is called when the user presses the confirm button.
  ///
  /// Use this to define the action that will be executed when the confirm action is triggered.
  final VoidCallback onConfirm;

  /// A callback function that is called when the user presses the cancel button.
  ///
  /// Use this to define the action that should be taken when the user wants to cancel the action.
  final VoidCallback onCancel;

  /// The title text to be displayed in the title of the dialog.
  final String titleText;

  /// The text of the confirmation button.
  final String confirmButtonText;

  /// Controller for managing the text field's content.
  final TextEditingController controller;

  /// Constructor of the [EnterPasswordDialog].
  ///
  /// Requires five positional arguments:
  /// - [onConfirm] a callback function that is executed when the confirm button is pressed.
  /// - [onCancel] a callback function that is executed when the cancel button is pressed.
  /// - [titleText] a text to display as the title of the dialog.
  /// - [confirmButtonText] a text to display on the confirm button.
  /// - [controller] a controller for managing the text field's content.
  const EnterPasswordDialog(
      {super.key,
      required this.onConfirm,
      required this.onCancel,
      required this.titleText,
      required this.confirmButtonText,
      required this.controller});

  // Builds the UI of the textfield dialog.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: dialogBorder,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(titleText),
      content: MyTextField(
        isPasswordField: true,
        hint: AppLocalizations.of(context)!.password,
        controller: controller,
        pefIcon: const Icon(Icons.key),
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
