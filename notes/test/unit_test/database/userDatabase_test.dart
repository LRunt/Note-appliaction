import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/boxes.dart'; // Adjust the import based on your project structure
import 'package:notes/assets/constants.dart';
import 'package:notes/data/userDatabase.dart';
import 'package:hive/hive.dart';
import 'package:flutter/widgets.dart';

// Use the mock box instead of the real Hive box
class MockBox extends Mock implements Box {}

void main() {
  group('UserDatabase Tests', () {
    late MockBox mockBox;
    late UserDatabase userDatabase;

    setUp(() {
      mockBox = MockBox();
      userDatabase = UserDatabase();
      boxUser = mockBox;
    });

    /*test('saveLocale saves the locale string', () {
      const String langCode = 'en';

      // Act
      userDatabase.saveLocale(langCode);

      // Assert
      verify(mockBox.put(LOCALE, langCode)).called(1);
    });*/

    test('loadLocale returns the correct Locale instance', () {
      // Arrange
      const String langCode = 'en';
      when(mockBox.get(LOCALE)).thenReturn(langCode);

      // Act
      Locale result = userDatabase.loadLocale();

      // Assert
      expect(result, isA<Locale>());
      expect(result.languageCode, equals(langCode));
    });
  });
}
