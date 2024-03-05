import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';

///Class [ComponentUtils] provides utility methods for common UI components in Flutter apps.
///
/// Author: Lukas Runt
/// Date: 2024-02-29
/// Version: 1.0.0
class ComponentUtils {
  /// Shows a modal progress indicator dialog.
  /// Useful for indicating ongoing operations to the user (for example authentification or synchronization).
  ///
  /// `context`: The BuildContext for locating the widget within the tree.
  void getProgressIndicator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  /// Displays a snack bar which displays an error message.
  ///
  /// `context`: The BuildContext for finding the Scaffold.
  /// `errorMessage`: The error message to display.
  void getSnackBarError(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor:
            const Color.fromRGBO(220, 53, 69, 1.0), // Bootstrap danger color
      ),
    );
  }

  /// Returns a default text style
  TextStyle getBasicTextStyle() {
    return const TextStyle(fontSize: DEFAULT_TEXT_SIZE);
  }
}
