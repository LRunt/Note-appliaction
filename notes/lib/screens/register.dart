import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  void register() {
    print('Touched register');
    //if()
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
                const Icon(Icons.man, size: 80),
                const Text("Let's create an acount"),
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
                const TextField(
                  obscureText: true,
                  obscuringCharacter: "*",
                  decoration: InputDecoration(
                    hintText: "Confirm password",
                  ),
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
                      onTap: onTap,
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
