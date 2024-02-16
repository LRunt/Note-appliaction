import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static const login = "Sign In";
  static const pleaseLogin = "Please Login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(login),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Icon(Icons.message, size: 80),
                const Text(pleaseLogin),
                const TextField(
                  decoration: InputDecoration(
                    hintText: "Username",
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const TextField(
                  obscureText: true,
                  obscuringCharacter: "*",
                  decoration: InputDecoration(
                    hintText: "Password",
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Touched');
                  },
                  child: const Text(login),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an acount?"),
                    SizedBox(width: 4),
                    Text(
                      "Create new here!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
