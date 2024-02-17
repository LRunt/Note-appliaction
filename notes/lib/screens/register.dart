import 'package:flutter/material.dart';
import 'dart:developer';

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
        title: const Text("Registration"),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Icon(Icons.person, size: 80),
                const Text("Let's create an acount"),
                const TextField(
                  decoration: InputDecoration(
                    hintText: "Username",
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  obscureText: true,
                  obscuringCharacter: "*",
                  decoration: const InputDecoration(
                    hintText: "Password",
                  ),
                  controller: passwordController,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  obscureText: true,
                  obscuringCharacter: "*",
                  decoration: const InputDecoration(
                    hintText: "Confirm password",
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
                  child: const Text("Register"),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Have an acount?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login here!",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
