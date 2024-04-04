import 'package:intl/intl.dart';

class UtilService {
  static String getFormattedDate(int millisecondsSinceEpoch) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(millisecondsSinceEpoch);
    return DateFormat('HH:mm dd.MM.yyyy').format(date);
  }
}
