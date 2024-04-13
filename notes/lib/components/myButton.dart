import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';

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
    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.bold,
                fontSize: DEFAULT_TEXT_SIZE),
          ),
        ),
      ),
    );
  }
}
