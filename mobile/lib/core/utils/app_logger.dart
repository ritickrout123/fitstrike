import 'dart:developer' as developer;

class AppLogger {
  static void info(String message) {
    developer.log(message, name: 'FitStrike');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'FitStrike',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
