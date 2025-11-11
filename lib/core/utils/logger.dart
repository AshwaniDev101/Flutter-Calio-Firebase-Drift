import 'package:logger/logger.dart';

class Log {
  // Single logger instance
  static final Logger _logger = Logger(
    level: Level.debug,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      lineLength: 50,
      colors: true,
      printEmojis: false,

    ),
  );

  // Info
  static void i(dynamic message) => _logger.i(message);

  // Debug
  static void d(dynamic message) => _logger.d(message);

  // Warning
  static void w(dynamic message) => _logger.w(message);

  // Error
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message,  error: error, stackTrace: stackTrace);
}
