import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Form for registrating new user
class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterPage> {
  //Defining controllers for the textfields
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  ///Clean up the controllers when widget is removed from the tree.
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  ///Method for registration of the user
  void register() {
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (password == confirmPassword) {
      log("Passwords match. Registring...");
    } else {
      log("Passwords do not match.");
    }
  }

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
                    hintText: AppLocalizations.of(context)!.username,
                  ),
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
