import 'package:flutter_test/flutter_test.dart';
import 'package:notes/model/language.dart';

void main() {
  group('Language Tests', () {
    test('Creating language test', () {
      // Arrange
      Language language = Language("🇺🇿", "Uzbek", "uz");

      // Assert
      expect(language.flag, "🇺🇿");
      expect(language.name, "Uzbek");
      expect(language.langCode, "uz");
    });

    test('LanguageList - getting languages', () {
      // Arrange
      var languages = Language.languageList();

      // Assert
      expect(languages, isA<List<Language>>());
      expect(languages.isNotEmpty, true);
      expect(languages.first.name, "English");
    });

    test('getByLangCode - simple test', () {
      // Arrange
      var english = Language.getByLangCode("en");
      var czech = Language.getByLangCode("cs");

      // Assert
      expect(english?.name, "English");
      expect(czech?.name, "Čeština");
    });

    test('getByLangCode - null test', () {
      // Arrange
      var klingon = Language.getByLangCode("kl");

      // Assert
      expect(klingon, isNull);
    });

    test('operator == - comparing languages', () {
      // Arrange
      final language1 = Language("🇮🇹", "Italy", "it");
      final language2 = Language("🇮🇹", "Italy", "it");
      final language3 = Language("🇪🇸", "Spanish", "es");

      // Assert
      expect(language1 == language2, isTrue);
      expect(language1 == language3, isFalse);
    });

    test('hashCode - different hash codes', () {
      // Arrange
      final language = Language("🇺🇸", "English", "en");
      final otherLanguage = Language("🇺🇸", "English", "en");

      // Assert
      expect(language.hashCode, equals(otherLanguage.hashCode));
    });

    test('toString test', () {
      // Arrange
      final language = Language("🇺🇸", "English", "en");

      // Assert
      expect(language.toString(), equals("🇺🇸  English"));
    });
  });
}
