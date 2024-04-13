import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';

ButtonStyle defaultButtonStyle = ButtonStyle(
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
    ),
  ),
);

RoundedRectangleBorder dialogBorder = const RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(BORDER_RADIUS),
  ),
);

TextStyle defaultTextStyle = const TextStyle(fontSize: DEFAULT_TEXT_SIZE);
