import 'package:flutter/material.dart';

/// Class [MyButton] creates styled button.
///
/// This widget is designigned as reusable styled button with tap function.
class MyButton extends StatelessWidget {
  /// Callback function that is called when the button is tapped.
  final void Function()? onTap;

  /// Text what will be displayed inside the button.
  final String text;

  /// Constructor of [MyButton] class
  const MyButton({super.key, required this.onTap, required this.text});

  /// Builds the UI of my button.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          )),
    );
  }
}
