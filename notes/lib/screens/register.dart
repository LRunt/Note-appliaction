import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/services/firebaseService.dart';

/// A StatefulWidget that provides a user interface for registering a new user.
///
/// This page displays a form where users can input their email, password, and confirm their password
/// to create a new account. It uses Firebase Authentication for the registration process.
class RegisterPage extends StatefulWidget {
  /// Callback function to navigate to another page.
  ///
  /// This is used to navigate to the login page if the user already has an account.
  final void Function()? onTap;

  /// Constructor of [RegisterPage] class.
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterPage> {
  final FirebaseService _firebaseService = FirebaseService();

  /// Controller for the email input field.
  final emailController = TextEditingController();

  /// Controller for the password input field.
  final passwordController = TextEditingController();

  /// Controller for the confirm password input field.
  final confirmPasswordController = TextEditingController();

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
    if (password == confirmPassword) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.trim(), password: password);
        log("New user created!");
        MyTreeNode tree = boxHierachy.get(TREE_STORAGE);
        _firebaseService.saveTreeStructure(tree);
        _firebaseService.saveAllNotes();
        Navigator.pop(context);
      } on FirebaseException catch (e) {
        if (e.code == 'weak-password') {
          log("The password provided is too weak.");
        } else if (e.code == 'email-already-in-use') {
          log("An account already exists for that email.");
        } else {
          log("Error while trying to register: ${e.code} - ${e.message}");
        }
      } catch (e) {
        log("General error while trying to register: $e");
      }
    } else {
      log("Passwords do not match.");
    }
  }

  /// Builds the registration page UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registration),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Icon(Icons.person, size: 80),
                Text(AppLocalizations.of(context)!.registrationText),
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
                  obscureText: true,
                  obscuringCharacter: "*",
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.password,
                  ),
                  controller: passwordController,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  obscureText: true,
                  obscuringCharacter: "*",
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.passwordConfirm,
                  ),
                  controller: confirmPasswordController,
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    register();
                  },
                  child: Text(AppLocalizations.of(context)!.registration),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.haveAccount),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        AppLocalizations.of(context)!.loginHere,
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
