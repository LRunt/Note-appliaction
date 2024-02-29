import 'package:flutter/material.dart';

import 'package:notes/assets/constants.dart';

class MyTextField extends StatefulWidget {
  final bool isPasswordField;
  bool isVisible;
  final String hint;
  final TextEditingController controller;
  final Icon pefIcon;

  MyTextField(
      {Key? key,
      required this.isPasswordField,
      required this.isVisible,
      required this.hint,
      required this.controller,
      required this.pefIcon})
      : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  void changeVisibility() {
    setState(() {
      widget.isVisible = !widget.isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPasswordField,
      obscuringCharacter: OBSCURE_CHAR,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: widget.isPasswordField
            ? IconButton(
                onPressed: changeVisibility,
                icon: widget.isVisible
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
              )
            : null,
        prefixIcon: widget.pefIcon,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
    );
  }
}
