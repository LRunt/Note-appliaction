import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';

/// Class [UserDatabase] saves user preferences to the local storage.
///
/// Database class working with local storage and provides to save and get user prefered language.
class UserDatabase {
  /// Saves the given language code to the local database.
  ///
  /// [langCode] is a string representing the language code (e.g., 'en', 'es').
  void saveLocale(String langCode) {
    boxUser.put(LOCALE, langCode);
  }

  /// Loads a user prefered language form a local database.
  ///
  /// Returns a [Locale] what is created from saved language code.
  Locale loadLocale() {
    String langCode = boxUser.get(LOCALE);
    return Locale(langCode);
  }

  /// Saves the given theme to the local database.
  ///
  /// [theme] is a string representing a theme.
  void saveTheme(ThemeMode theme) {
    if (theme == ThemeMode.light) {
      boxUser.put(THEME, LIGHT);
    } else {
      boxUser.put(THEME, DARK);
    }
  }

  /// Loads a user prefered theme from local database.
  ///
  /// Returns a [ThemeMode] which user preferes.
  ThemeMode loadTheme() {
    String themeString = boxUser.get(THEME, defaultValue: SYSTEM);
    switch (themeString) {
      case LIGHT:
        return ThemeMode.light;
      case DARK:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
