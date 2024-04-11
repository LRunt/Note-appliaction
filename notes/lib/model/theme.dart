import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/data/userDatabase.dart';

/// Manages the theme settings for the application.
///
/// This class provides a centralized way of managing the theme across the application.
/// It interacts with a [UserDatabase] to persist theme preferences to local storage,
/// ensuring that user preferences are maintained across sessions.
///
/// The class provides methods to change the theme which also notify all listeners
/// about theme changes, thus supporting a reactive update model across the app.
class ThemeProvider with ChangeNotifier {
  /// The current theme mode (light, dark, or system).
  ThemeMode _themeMode;

  /// The current color scheme for dark mode.
  late ColorScheme _darkScheme = DARK_COLOR_SCHEME;

  /// The current color scheme for light mode.
  late ColorScheme _lightScheme = LIGHT_COLOR_SCHEME;

  /// The database used to save and load theme settings.
  final UserDatabase userDb;

  /// Constructs a [ThemeProvider] with an initial theme mode and a user database for persistence.
  ///
  /// The [themeMode] parameter sets the initial theme mode for the application.
  /// The [userDb] parameter is the [UserDatabase] instance used for persisting theme preferences.
  ThemeProvider({required ThemeMode themeMode, required this.userDb}) : _themeMode = themeMode;

  /// Returns the current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Sets the theme mode and saves it to persistent storage.
  ///
  /// [value] is the new theme mode to be set. It updates the application's current theme mode,
  /// saves it to local storage, and notifies all listeners to refresh their UI if necessary.
  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    userDb.saveTheme(value);
    notifyListeners();
  }

  /// Returns the color scheme for dark mode.
  ColorScheme get darkScheme => _darkScheme;

  /// Sets the color scheme for dark mode and notifies listeners.
  ///
  /// [value] is the new color scheme to be applied when the dark theme is active.
  void setDarkScheme(ColorScheme value) {
    _darkScheme = value;
    notifyListeners();
  }

  /// Returns the color scheme for light mode.
  ColorScheme get lightScheme => _lightScheme;

  /// Sets the color scheme for light mode and notifies listeners.
  ///
  /// [value] is the new color scheme to be applied when the light theme is active.
  void setLightScheme(ColorScheme value) {
    _lightScheme = value;
    notifyListeners();
  }
}
