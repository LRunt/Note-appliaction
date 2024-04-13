part of services;

/// A utility class providing various helper methods.
class UtilService {
  /// Formats the given [microsecondsSinceEpoch] into a human-readable date string.
  ///
  /// Returns an empty string if [microsecondsSinceEpoch] is `null`.
  /// Otherwise, converts the given milliseconds since epoch to a [DateTime]
  /// and formats it using the pattern 'HH:mm dd.MM.yyyy'.
  ///
  /// Example:
  /// ```dart
  /// final formattedDate = UtilService.getFormattedDate(1713016004370000);
  /// print(formattedDate); // Output: '15:46 13.04.2024'
  /// ```
  static String getFormattedDate(int? microsecondsSinceEpoch) {
    if (microsecondsSinceEpoch == null || microsecondsSinceEpoch < 0) {
      return "";
    }
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
    return DateFormat('HH:mm dd.MM.yyyy').format(date);
  }
}
