import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

class AppLogger {
  static final Logger _logger = Logger("AppLogger");
  static File? logFile;

  static Future<void> init() async {
    // Set up logger
    Logger.root.level = Level.ALL; // Log all messages
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      _writeToFile('${record.level.name}: ${record.time}: ${record.message}');
    });

    // Initialize file for logging
    final directory = await getApplicationDocumentsDirectory();
    logFile = File('${directory.path}/app_logs.txt');
    if (!await logFile!.exists()) {
      await logFile!.create();
    }
  }

  static void log(String message, {Level level = Level.INFO}) {
    _logger.log(level, message);
  }

  static Future<void> _writeToFile(String message) async {
    if (logFile != null) {
      await logFile!.writeAsString("$message\n", mode: FileMode.append);
    }
  }
}
