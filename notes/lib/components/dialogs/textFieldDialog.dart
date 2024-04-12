import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/widgetConstants.dart';
import 'package:notes/components/myTextField.dart';

/// A custom dialog widget that contains a text field for input.
///
/// This dialog is designed to capture user input, providing options
/// for confirmation and cancellation. It uses [AlertDialog] as its
/// base structure and includes custom styling and localization support.
class TextFieldDialog extends StatelessWidget {
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

  /// The text for the confirmation button.
  final String confirmButtonText;

  final String hint;

  /// Controller for managing the text field's content.
  final TextEditingController controller;

  /// Constructs a [TextFieldDialog].
  ///
  /// Requires [onConfirm] and [onCancel] callbacks to define the dialog's
  /// behavior on respective actions. Also requires [titleText],
  /// [confirmButtonText] for labeling, and a [TextEditingController]
  /// [controller] to manage the input field's state.
  const TextFieldDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.titleText,
    required this.confirmButtonText,
    required this.controller,
    required this.hint,
  });

  // Builds the UI of the textfield dialog.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: dialogBorder,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      content: MyTextField(
        isPasswordField: false,
        controller: controller,
        pefIcon: null,
        hint: hint,
      ),
      actions: [
        TextButton(
          key: const Key('cancelButton'),
          onPressed: onCancel,
          style: defaultButtonStyle,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: defaultButtonStyle,
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
