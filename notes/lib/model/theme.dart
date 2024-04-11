import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/data/userDatabase.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  late ColorScheme _darkScheme = DARK_COLOR_SCHEME;
  late ColorScheme _lightScheme = LIGHT_COLOR_SCHEME;
  ThemeMode get themeMode => _themeMode;
  UserDatabase userDb = UserDatabase();

  ThemeProvider({required ThemeMode themeMode}) : _themeMode = themeMode;

  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    userDb.saveTheme(value);
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
