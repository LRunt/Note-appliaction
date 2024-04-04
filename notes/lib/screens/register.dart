import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/myButton.dart';
import 'package:notes/components/myTextField.dart';
import 'package:notes/components/squareTile.dart';
import 'package:notes/services/authService.dart';

/// A StatefulWidget that provides a user interface for registering a new user.
///
/// This page displays a form where users can input their email, password, and confirm their password
/// to create a new account. It uses Firebase Authentication for the registration process.
class RegisterPage extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  /// Callback function to navigate to another page.
  ///
  /// This is used to navigate to the login page if the user already has an account.
  final void Function()? onTap;

  /// Constructor of [RegisterPage] class.
  const RegisterPage({super.key, required this.auth, required this.firestore, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterPage> {
  late final AuthService _authService;

  final ComponentUtils utils = ComponentUtils();

  /// Controller for the email input field.
  final emailController = TextEditingController();

  /// Controller for the password input field.
  final passwordController = TextEditingController();

  /// Controller for the confirm password input field.
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = AuthService(
      auth: widget.auth,
      firestore: widget.firestore,
      localizationProvider: (BuildContext context) => AppLocalizations.of(context)!,
    );
  }

  ///Clean up the controllers when widget is removed from the tree.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Attempts to register a new user using the provided email and password.
  ///
  /// This method first checks if the password and confirm password fields match.
  /// If they do, it proceeds to attempt creating a new user with Firebase Authentication.
  /// If the registration is successful, the user is navigated back to the previous page.
  /// Errors during the registration process are logged for debugging purposes.
  void register() async {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String errorMessage = "";
    utils.getProgressIndicator(context);
    if (password == confirmPassword) {
      try {
        await _authService.register(emailController.text.trim(), password);
        log("New user created!");
        // Pop the CircularProgressIndicator
        Navigator.pop(context);
        // Go back to the main screen
        Navigator.pop(context);
      } catch (errorCode) {
        String errorMessage = _authService.getErrorMessage(errorCode.toString(), context);
        // Pop the CircularProgressIndicator
        Navigator.pop(context);
        log("Error: $errorMessage");
        utils.getSnackBarError(context, errorMessage.toString());
      }
    } else {
      Navigator.pop(context);
      errorMessage = AppLocalizations.of(context)!.differentPasswords;
      utils.getSnackBarError(context, errorMessage.toString());
      log("Error: $errorMessage");
    }
  }

  registerWithGoogle() async {
    utils.getProgressIndicator(context);
    try {
      await _authService.signInWithGoogle();
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      // Go back to the main screen
      Navigator.pop(context);
    } catch (errorCode) {
      String errorMessage = _authService.getErrorMessage(errorCode.toString(), context);
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      log(errorMessage.toString());
      utils.getSnackBarError(context, errorMessage.toString());
    }
  }

  /// Builds the registration page UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registration),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Icon(Icons.person, size: 80),
                Text(
                  AppLocalizations.of(context)!.registrationText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
                MyTextField(
                    isPasswordField: true,
                    hint: AppLocalizations.of(context)!.passwordConfirm,
                    controller: confirmPasswordController,
                    pefIcon: const Icon(Icons.key)),
                const SizedBox(
                  height: 30,
                ),
                MyButton(
                    onTap: () {
                      register();
                    },
                    text: AppLocalizations.of(context)!.registration),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.haveAccount,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        AppLocalizations.of(context)!.loginHere,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DEFAULT_GAP_SIZE),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          AppLocalizations.of(context)!.googleSignDivider,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DEFAULT_GAP_SIZE),
                Center(
                  child: SquareTile(
                    onTap: () => registerWithGoogle(),
                    imagePath: GOOGLE_AUTH_IMG,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
