import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/widgetConstants.dart';

/// A [AboutAppDialog] widget that displays an dialog with information abou application.
///
/// This dialog displays important application details fetched from localized resources
/// and provides a single button to close the dialog. The dialog design includes a rounded
/// border and customized button styling using utility methods.
///
/// Parameters:
/// - [onClose]: A callback function that is executed when the close button is pressed.
///
/// Usage Example:
/// ```dart
/// AboutAppDialog(
///   onClose: () {
///     // Define action when the close button is clicked
///   },
/// )
/// ```
class AboutAppDialog extends StatelessWidget {
  /// A callback function that is called when the user presses the close button.
  ///
  /// This function should handle the closure of the dialog.
  final VoidCallback onClose;

  /// Constructor of the [AboutAppDialog] widget.
  ///
  //// Requires a non-null [onClose] callback to define the action for closing the dialog.
  /// The dialog content and title are defined by the localized resources.
  const AboutAppDialog({super.key, required this.onClose});

  // Builds the UI of the aboutAppDialog dialog.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: dialogBorder,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(
        AppLocalizations.of(context)!.aboutApp,
        key: const Key('title'),
      ),
      content: Text(
        AppLocalizations.of(context)!.informationsAboutApp,
        key: const Key('content'),
      ),
      actions: [
        FilledButton(
          key: const Key('closeButton'),
          onPressed: onClose,
          style: defaultButtonStyle,
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}
