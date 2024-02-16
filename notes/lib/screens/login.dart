import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  static const loginString = "Login";
  static const pleaseLogin = "Please Login";

  void login() {
    print('Touched login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(loginString),
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
                    login();
                  },
                  child: const Text(loginString),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an acount?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: this.onTap,
                      child: const Text(
                        "Create new here!",
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
