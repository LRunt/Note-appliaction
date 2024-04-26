part of dialogs;

/// A dialog widget designed for password creation, featuring two password fields.
///
/// This custom dialog uses an [AlertDialog] as its base structure and incorporates
/// two [StyledTextField] widgets for password and password confirmation inputs. It provides
/// localized text support and custom styling defined in widget constants. The dialog
/// facilitates user interaction by offering confirm and cancel actions.
///
/// Parameters:
/// - [onConfirm]: A callback that is invoked when the confirm button is pressed.
///   It defines the action taken after user confirmation.
/// - [onCancel]: A callback that is invoked when the cancel button is pressed.
///   It defines the action taken if the user decides to cancel the operation.
/// - [titleText]: Text displayed as the dialog's title.
/// - [confirmButtonText]: Text displayed on the confirmation button.
/// - [controller1]: Controller for the first password input field.
/// - [controller2]: Controller for the password confirmation input field.
///
/// Usage Example:
/// ```dart
/// CreatePasswordDialog(
///   onConfirm: () {
///     // Handle confirmation action
///   },
///   onCancel: () {
///     // Handle cancellation action
///   },
///   titleText: 'Set Your Password',
///   confirmButtonText: 'Confirm',
///   controller1: TextEditingController(),
///   controller2: TextEditingController(),
/// )
/// ```
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

  /// Controller for managing the upper text field's content.
  final TextEditingController controller1;

  /// Controller for managing the lower text field's content.
  final TextEditingController controller2;

  /// Constructor of the [CreatePasswordDialog].
  ///
  /// Requires six positional arguments:
  /// - [onConfirm] A callback that is invoked when the confirm button is pressed.
  ///   It defines the action taken after user confirmation.
  /// - [onCancel] A callback that is invoked when the cancel button is pressed.
  ///   It defines the action taken if the user decides to cancel the operation.
  /// - [titleText] text which will be displayed in the dialog's title.
  /// - [confirmButtonText] text displayed on the confirmation button.
  /// - [controller1] controller for the first password input field.
  /// - [controller2]  controller for the password confirmation input field.
  const CreatePasswordDialog({
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
      shape: dialogBorder,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(titleText),
      content: SizedBox(
        width: 200,
        height: 150,
        child: Column(
          children: [
            StyledTextField(
              isPasswordField: true,
              hint: AppLocalizations.of(context)!.password,
              controller: controller1,
              pefIcon: const Icon(Icons.key),
            ),
            const SizedBox(
              height: SMALL_GAP,
            ),
            StyledTextField(
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
