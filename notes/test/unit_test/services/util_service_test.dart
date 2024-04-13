import 'package:flutter_test/flutter_test.dart';
import 'package:notes/services/services.dart';

void main() {
  group('UtilService Tests', () {
    test('getFormattedDate returns formatted date string', () {
      // Arrange
      int millisecondsSinceEpoch = 1713016004370000;
      String expectedDateString = '15:46 13.04.2024';

      // Act
      final formattedDate = UtilService.getFormattedDate(millisecondsSinceEpoch);

      // Assert
      expect(formattedDate, expectedDateString);
    });

    test('getFormattedDate returns empty string for null input', () {
      // Arrange
      int? millisecondsSinceEpoch;
      String expectedDateString = '';

      // Act
      final formattedDate = UtilService.getFormattedDate(millisecondsSinceEpoch);

      // Assert
      expect(formattedDate, expectedDateString);
    });

    test('getFormattedDate returns empty string for negative input', () {
      // Arrange
      int microsecondsSinceEpoch = -1618296000000;
      String expectedDateString = '';

      // Act
      final formattedDate = UtilService.getFormattedDate(microsecondsSinceEpoch);

      // Assert
      expect(formattedDate, expectedDateString);
    });
  });
}
