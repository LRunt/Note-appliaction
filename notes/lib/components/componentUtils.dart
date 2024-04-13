import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes/assets/constants.dart';

/// Utility class [ComponentUtils] for common UI components customization in Flutter applications.
///
/// Provides methods to display progress indicators, snack bars (for error, success, and info messages),
/// and to get default styles for text and buttons.
///
/// ## Usage:
/// ```dart
/// var utils = ComponentUtils();
/// utils.getSnackBarSuccess(context, "Operation Successful");
/// ```
///
/// Author: Lukas Runt
/// Date: 2024-02-29
/// Version: 1.0.0
class ComponentUtils {
  /// Shows a modal progress indicator dialog, useful during long-running tasks.
  ///
  /// - `context`: BuildContext for widget tree location.
  static void getProgressIndicator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  /// Shows a snack bar with an error message styled with a predefined error color.
  ///
  /// - `context`: BuildContext for finding the Scaffold.
  /// - `errorMessage`: The message to display.
  static void getSnackBarError(BuildContext context, String errorMessage) {
    getSnackBar(context, errorMessage, COLOR_ERROR);
  }

  /// Shows a snack bar with a success message styled with a predefined success color.
  ///
  /// - `context`: BuildContext for finding the Scaffold.
  /// - `successMessage`: The message to display.
  static void getSnackBarSuccess(BuildContext context, String successMessage) {
    getSnackBar(context, successMessage, COLOR_SUCCESS);
  }

  /// Shows a snack bar with an info message styled with a predefined info color.
  ///
  /// - `context`: BuildContext for finding the Scaffold.
  /// - `infoMessage`: The message to display.
  static void getSnackBarInfo(BuildContext context, String infoMessage) {
    getSnackBar(context, infoMessage, COLOR_INFO);
  }

  /// Displays a snack bar which displays an error message.
  ///
  /// - `context`: The BuildContext for finding the Scaffold.
  /// - `message`: The error message to display.
  /// - `color`: Background color for the snack bar.
  static void getSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: color,
      ),
    );
  }

  static void showErrorToast(String message) {
    showCenteredToast(message, COLOR_ERROR);
  }

  static void showSuccesToast(String message) {
    showCenteredToast(message, COLOR_SUCCESS);
  }

  static void showDefaultToast(String message) {
    showCenteredToast(message, COLOR_DEFAULT_TOAST);
  }

  static void showWarningToast(String message) {
    showCenteredToast(message, COLOR_WARNING);
  }

  static void showCenteredToast(String message, Color color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: DEFAULT_TEXT_SIZE);
  }

  /// Provides a default text style for consistency across the app.
  ///
  /// Returns a `TextStyle` with a predefined font size.
  TextStyle getBasicTextStyle() {
    return const TextStyle(fontSize: DEFAULT_TEXT_SIZE);
  }

  /// Provides a default button style with rounded corners for a consistent look.
  ///
  /// Returns a `ButtonStyle` with a predefined border radius.
  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
        ),
      ),
    );
  }
}
