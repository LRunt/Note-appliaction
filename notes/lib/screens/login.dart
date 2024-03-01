import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/myButton.dart';
import 'package:notes/components/myTextField.dart';
import 'package:notes/services/authentificationService.dart';

/// A StatefulWidget that provides a user interface for logging in.
///
/// This page allows users to enter their email and password to log in to their account.
/// It utilizes Firebase Authentication for secure login functionality and provides
/// feedback in case of errors such as incorrect email or password.
class LoginPage extends StatefulWidget {
  /// A callback function that is triggered when the user taps on the 'Create Account' text.
  ///
  /// This function can be used to navigate the user to the registration page.
  final void Function()? onTap;

  /// Constructor of [LoginPage] class.
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginPage> {
  final AuthentificationService _authentificationService =
      AuthentificationService();
  final ComponentUtils utils = ComponentUtils();

  /// Controller for the email input field.
  final emailController = TextEditingController();

  /// Controller for the password input field.
  final passwordController = TextEditingController();

  bool isVisible = true;

  /// Cleans up the controllers when the widget is removed from the widget tree.
  ///
  /// This method prevents memory leaks by disposing of the TextEditingController
  /// instances when the LoginPage widget is disposed.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Attempts to log in the user using Firebase Authentication.
  ///
  /// This method is called when the user presses the login button. It uses the
  /// email and password from the text controllers to attempt a login via Firebase.
  /// If the login is successful, the user is navigated back to the main screen.
  /// Errors during the login process are logged for debugging purposes.
  void login() async {
    log('Loging user: ${emailController.text}, password: ${passwordController.text}');
    utils.getProgressIndicator(context);
    try {
      await _authentificationService.login(
          emailController.text.trim(), passwordController.text.trim());
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      // Go back to the main screen
      Navigator.pop(context);
    } catch (errorCode) {
      String errorMessage = _authentificationService.getErrorMessage(
          errorCode.toString(), context);
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      log(errorMessage.toString());
      utils.getSnackBarError(context, errorMessage.toString());
    }
  }

  void toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  /// Builds the registration page UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.login,
        ),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Icon(Icons.person, size: 80),
                Text(AppLocalizations.of(context)!.loginText,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(
                  height: 30,
                ),
                MyTextField(
                    isPasswordField: false,
                    hint: AppLocalizations.of(context)!.email,
                    controller: emailController,
                    pefIcon: const Icon(Icons.email)),
                const SizedBox(
                  height: 30,
                ),
                MyTextField(
                    isPasswordField: true,
                    hint: AppLocalizations.of(context)!.password,
                    controller: passwordController,
                    pefIcon: const Icon(Icons.key)),
                const SizedBox(
                  height: 30,
                ),
                MyButton(
                    onTap: () {
                      login();
                    },
                    text: AppLocalizations.of(context)!.login),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.doNotHaveAccount,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        AppLocalizations.of(context)!.createAccount,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
