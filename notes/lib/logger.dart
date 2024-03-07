import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

/// A utility class for application-wide logging.
///
/// This class initializes a logger that captures logs and writes them both to the console
/// and a designated file on the device's file system. It leverages the `logging` package for
/// log management and the `path_provider` package to locate an appropriate directory for the
/// log file. The class provides functionality to log messages at different levels, delete the
/// log file, and format log timestamps.
///
/// Usage:
/// - Call [init] at the start of the application to initialize logging.
/// - Use [log] to log messages throughout the application.
/// - Use [deleteLogFile] to delete the log file, if needed.
///
/// Example:
/// ```
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppLogger.init();
///   AppLogger.log("Application started");
///   runApp(MyApp());
/// }
/// ```
///
/// The log file is stored in the application's document directory and named `app_logs.txt`.
/// Log messages are formatted with a timestamp, log level, and the log message itself.
class AppLogger {
  /// Static logger for application-wide logging.
  static final Logger _logger = Logger("AppLogger");

  /// File for storing log messages, initialized upon first use.
  static File? logFile;

  /// Initializes the logger to output messages to both the console and a file.
  ///
  /// Ensures the existence of `app_logs.txt` in the application's documents directory
  /// and sets up logging to capture all message levels. Should be called at application startup.
  static Future<void> init() async {
    Logger.root.level = Level.ALL; // Log all messages
    Logger.root.onRecord.listen((record) {
      var formattedTime = DateFormat('dd-MM-yyyy HH:mm:ss').format(record.time);
      print('${record.level.name}: $formattedTime: ${record.message}');
      _writeToFile('${record.level.name}: $formattedTime: ${record.message}');
    });
    createLogFileIfNotExist();
  }

  static void createLogFileIfNotExist() async {
    final directory = await getApplicationDocumentsDirectory();
    logFile = File('${directory.path}/app_logs.txt');
    if (!await logFile!.exists()) {
      await logFile!.create();
    }
  }

  /// Logs a message with the specified [message] and [level].
  ///
  /// The [level] defaults to `Level.INFO` if not specified. The message is formatted with
  /// a timestamp and logged to both the console and the log file.
  static void log(String message, {Level level = Level.INFO}) {
    _logger.log(level, message);
  }

  /// Writes the log message to the log file.
  ///
  /// This private method is called within the class to append log messages to the file.
  static Future<void> _writeToFile(String message) async {
    if (logFile != null) {
      await logFile!.writeAsString("$message\n", mode: FileMode.append);
    }
  }

  /// Deletes the current log file from the device's file system.
  ///
  /// This can be used for log rotation or clearing logs. Once deleted, subsequent log messages
  /// will be written to a new file.
  static Future<void> deleteLogFile() async {
    if (logFile != null && await logFile!.exists()) {
      await logFile!.delete();
      logFile = null;
    }
  }
}
