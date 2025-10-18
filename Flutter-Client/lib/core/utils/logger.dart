import 'package:logger/logger.dart';

/// Centralized logging utility for the application
class AppLogger {
  static late Logger _logger;
  static bool _initialized = false;

  /// Initialize the logger
  static void init({Level level = Level.debug}) {
    if (_initialized) return;

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: level,
    );

    _initialized = true;
  }

  /// Log debug message
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal message
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      init();
    }
  }
}
