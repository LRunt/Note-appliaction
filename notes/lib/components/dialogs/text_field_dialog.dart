part of dialogs;

/// A [TextFieldDialog] widget that presents a dialog with a text field for capturing input.
///
/// This widget is designed to capture user input, offering options
/// for confirmation and cancellation. It uses [AlertDialog] as its
/// base structure and includes custom styling and localization support.
///
/// Parameters:
/// - [onConfirm]: A callback function that is executed when the confirm button is pressed.
/// - [onCancel]: A callback function that is executed when the cancel button is pressed.
/// - [titleText]: Text to display as the title of the dialog.
/// - [confirmButtonText]: Text to display on the confirm button.
/// - [controller]: Controller for managing the text field's content.
/// - [hint]: The hint text to display in the text field.
///
/// Usage example:
/// ```dart
/// TextFieldDialog(
///   onConfirm: () {
///     // Handle confirmation action
///   },
///   onCancel: () {
///     // Handle cancellation action
///   },
///   titleText: 'Enter Text',
///   confirmButtonText: 'Confirm',
///   controller: myTextController,
///   hint: 'Enter your text here',
/// )
/// ```
///
/// This dialog leverages [AlertDialog] to present its content, providing a consistent and familiar UI for users.
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

  /// The hint text to display in the text field.
  final String hint;

  /// Controller for managing the text field's content.
  final TextEditingController controller;

  /// Constructor of the [TextFieldDialog].
  ///
  /// Requires six positional arguments:
  /// - [onConfirm] a callback function that is executed when the confirm button is pressed.
  /// - [onCancel] a callback function that is executed when the cancel button is pressed.
  /// - [titleText] a text to display as the title of the dialog.
  /// - [confirmButtonText] a text to display on the confirm button.
  /// - [controller] a controller for managing the text field's content.
  /// - [hint] the hint text to display in the text field.
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
      shape: DIALOG_BORDER,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(titleText),
      content: StyledTextField(
        isPasswordField: false,
        controller: controller,
        pefIcon: null,
        hint: hint,
      ),
      actions: [
        TextButton(
          key: const Key('cancelButton'),
          onPressed: onCancel,
          style: DEFAULT_BUTTON_STYLE,
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: DEFAULT_BUTTON_STYLE,
          child: Text(confirmButtonText),
        ),
      ],
    );
  }
}
