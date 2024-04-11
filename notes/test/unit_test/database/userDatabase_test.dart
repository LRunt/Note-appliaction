import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/data/userDatabase.dart';
import 'package:hive/hive.dart';

// Using the mock box instead of the real Hive box
class MockBox extends Mock implements Box {
  @override
  Future<void> put(key, value) => super.noSuchMethod(
        Invocation.method(#put, [key, value]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

void main() {
  group('UserDatabase Tests', () {
    late MockBox mockBox;
    late UserDatabase userDatabase;

    setUp(() {
      mockBox = MockBox();
      userDatabase = UserDatabase();
      boxUser = mockBox;
    });

    test('saveLocale saves the locale string', () {
      const String langCode = 'en';

      // Act
      userDatabase.saveLocale(langCode);

      // Assert
      verify(mockBox.put(LOCALE, langCode)).called(1);
    });

    test('loadLocale returns correct Locale instance', () {
      // Arrange
      const String langCode = 'en';
      when(mockBox.get(LOCALE)).thenReturn(langCode);

      // Act
      Locale result = userDatabase.loadLocale();

      // Assert
      expect(result, isA<Locale>());
      expect(result.languageCode, equals(langCode));
    });

    test('saveTheme stores theme string - light', () {
      // Act
      userDatabase.saveTheme(ThemeMode.light);

      // Assert
      verify(mockBox.put(THEME, LIGHT)).called(1);
    });

    test('saveTheme stores theme string - dark', () {
      // Act
      userDatabase.saveTheme(ThemeMode.dark);

      // Assert
      verify(mockBox.put(THEME, DARK)).called(1);
    });

    test('loadTheme returns correct ThemeMode - light', () {
      // Arrange
      when(mockBox.get(THEME, defaultValue: SYSTEM)).thenReturn(LIGHT);

      // Act
      final result = userDatabase.loadTheme();

      // Assert
      expect(result, ThemeMode.light);
    });

    test('loadTheme returns correct ThemeMode - dark', () {
      // Arrange
      when(mockBox.get(THEME, defaultValue: SYSTEM)).thenReturn(DARK);

      // Act
      final result = userDatabase.loadTheme();

      // Assert
      expect(result, ThemeMode.dark);
    });

    test('loadTheme returns correct ThemeMode - system (default)', () {
      // Arrange
      when(mockBox.get(THEME, defaultValue: SYSTEM)).thenReturn(SYSTEM);

      // Act
      final result = userDatabase.loadTheme();

      // Assert
      expect(result, ThemeMode.system);
    });
  });
}
