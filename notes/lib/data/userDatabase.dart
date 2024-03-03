import 'package:flutter/widgets.dart';
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

  /// Loads a user prefered language form a local storage.
  ///
  /// Returns a [Locale] what is created from saved language code.
  Locale loadLocale() {
    String langCode = boxUser.get(LOCALE);
    return Locale(langCode);
  }
}
