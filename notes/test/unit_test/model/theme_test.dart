import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/data/userDatabase.dart';
import 'package:notes/model/theme.dart';

class ListenerMock extends Mock {
  void call();
}

class MockUserDatabase extends Mock implements UserDatabase {}

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;
    late MockUserDatabase mockUserDatabase;

    setUp(() {
      mockUserDatabase = MockUserDatabase();
      themeProvider = ThemeProvider(themeMode: ThemeMode.system, userDb: mockUserDatabase);
    });

    test('should update themeMode and notify listeners', () {
      var listener = ListenerMock();
      themeProvider.addListener(listener);

      expect(themeProvider.themeMode, ThemeMode.system);

      // Act
      themeProvider.setThemeMode(ThemeMode.dark);

      // Assert
      expect(themeProvider.themeMode, ThemeMode.dark);
      verify(mockUserDatabase.saveTheme(ThemeMode.dark)).called(1);
      verify(listener()).called(1);
    });

    test('should update darkScheme and notify listeners', () {
      var listener = ListenerMock();
      themeProvider.addListener(listener);

      // Initial value check
      expect(themeProvider.darkScheme, DARK_COLOR_SCHEME);

      // New color scheme
      const ColorScheme newScheme = ColorScheme.dark();

      // Act
      themeProvider.setDarkScheme(newScheme);

      // Assert
      expect(themeProvider.darkScheme, newScheme);
      verify(listener()).called(1);
    });

    test('should update lightScheme and notify listeners', () {
      var listener = ListenerMock();
      themeProvider.addListener(listener);

      // Initial value check
      expect(themeProvider.lightScheme, LIGHT_COLOR_SCHEME);

      // New color scheme
      const ColorScheme newScheme = ColorScheme.light();

      // Act
      themeProvider.setLightScheme(newScheme);

      // Assert
      expect(themeProvider.lightScheme, newScheme);
      verify(listener()).called(1);
    });
  });
}
