import 'package:intl/intl.dart';

class UtilService {
  static String getFormattedDate(int? millisecondsSinceEpoch) {
    if (millisecondsSinceEpoch == null) {
      return "";
    }
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(millisecondsSinceEpoch);
    return DateFormat('HH:mm dd.MM.yyyy').format(date);
  }
}
