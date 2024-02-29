import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/componentUtils.dart';
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
          emailController.text, passwordController.text);
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      // Go back to the main screen
      Navigator.pop(context);
    } catch (e) {
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      String errorMessage = "";
      if (e == 'user-not-found') {
        errorMessage = "No user found with that email.";
      } else if (e == 'wrong-password') {
        errorMessage = "Wrong password.";
      } else if (e == 'invalid-credential') {
        errorMessage = "Wrong email or password.";
      } else if (e == "network-request-failed") {
        errorMessage = "No internet connection!";
      } else if (e == "invalid-email") {
        errorMessage = "Wrong format of email";
      } else {
        errorMessage = "Error: $e.";
      }
      log(errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            // Bootstrap danger color
          ),
          backgroundColor: const Color.fromRGBO(220, 53, 69, 1.0),
        ),
      );
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
        title: Text(AppLocalizations.of(context)!.login),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Icon(Icons.person, size: 80),
                Text(AppLocalizations.of(context)!.loginText),
                TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.email,
                  ),
                  controller: emailController,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  obscureText: isVisible,
                  obscuringCharacter: "*",
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.password,
                      suffixIcon: IconButton(
                        onPressed: toggleVisibility,
                        icon: isVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      )),
                  controller: passwordController,
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text(AppLocalizations.of(context)!.login),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.doNotHaveAccount),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        AppLocalizations.of(context)!.createAccount,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
