import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget{
  const SignUpPage({super.key});

  static const name = "Sign Up";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Text(name),
    );
  }


}