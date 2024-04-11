import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeMode _themeMode = ThemeMode.system;
  late ColorScheme _darkScheme = DARK_COLOR_SCHEME;
  late ColorScheme _lightScheme = LIGHT_COLOR_SCHEME;
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  ColorScheme get darkScheme => _darkScheme;
  void setDarkScheme(ColorScheme value) {
    _darkScheme = value;
    notifyListeners();
  }

  ColorScheme get lightScheme => _lightScheme;
  void setLightScheme(ColorScheme value) {
    _lightScheme = value;
    notifyListeners();
  }
}
