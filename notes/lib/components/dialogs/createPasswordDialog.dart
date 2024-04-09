import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/myTextField.dart';

/// A custom dialog widget that contains a text field for input.
///
/// This dialog is designed to capture user input, providing options
/// for confirmation and cancellation. It uses [AlertDialog] as its
/// base structure and includes custom styling and localization support.
class CreatePasswordDialog extends StatelessWidget {
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

  /// Controller for managing the text field's content.
  final TextEditingController controller1;

  final TextEditingController controller2;

  /// A utility object for styling the widget.
  final utils = ComponentUtils();

  /// Constructs a [TextFieldDialog].
  ///
  /// Requires [onConfirm] and [onCancel] callbacks to define the dialog's
  /// behavior on respective actions. Also requires [titleText],
  /// [confirmButtonText] for labeling, and a [TextEditingController]
  /// [controller] to manage the input field's state.
  CreatePasswordDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.titleText,
    required this.confirmButtonText,
    required this.controller1,
    required this.controller2,
  });

  // Builds the UI of the textfield dialog.
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
      content: SizedBox(
        width: 200,
        height: 150,
        child: Column(
          children: [
            MyTextField(
              isPasswordField: true,
              hint: AppLocalizations.of(context)!.password,
              controller: controller1,
              pefIcon: const Icon(Icons.key),
            ),
            const SizedBox(
              height: 15,
            ),
            MyTextField(
              isPasswordField: true,
              hint: AppLocalizations.of(context)!.passwordConfirm,
              controller: controller2,
              pefIcon: const Icon(Icons.key),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('cancelButton'),
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
