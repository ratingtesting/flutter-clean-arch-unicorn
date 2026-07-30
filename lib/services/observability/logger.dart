/// Structured logging abstraction.
///
/// Separates logging from implementation.
/// Console (dev), remote (prod: Sentry/Datadog), both — all through one interface.
library;

import 'package:logger/logger.dart' as logger_pkg;

enum LogLevel { debug, info, warning, error, fatal }

abstract class AppLogger {
  void debug(String message, [Object? error, StackTrace? stackTrace]);
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, [Object? error, StackTrace? stackTrace]);
  void fatal(String message, [Object? error, StackTrace? stackTrace]);

  /// Logs with metadata (user ID, session, feature flag states, etc.).
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  });
}

/// Console logger for development.
class ConsoleLogger extends AppLogger {
  final logger_pkg.Logger _logger;

  ConsoleLogger({logger_pkg.LogFilter? filter, logger_pkg.LogPrinter? printer})
      : _logger = logger_pkg.Logger(
          filter: filter ?? logger_pkg.DevelopmentFilter(),
          printer: printer ?? logger_pkg.PrettyPrinter(colors: true),
        );

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final m = data != null ? '$message | ${data.toString()}' : message;
    final err = error;
    final trace = stackTrace;
    switch (level) {
      case LogLevel.debug:
        debug(m, err, trace);
      case LogLevel.info:
        info(m, err, trace);
      case LogLevel.warning:
        warning(m, err, trace);
      case LogLevel.error:
        logError(m, err, trace);
      case LogLevel.fatal:
        fatal(m, err, trace);
    }
  }

  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      this.error(message, error, stackTrace);
}

/// No-op logger for testing (zero side effects).
class NoopLogger extends AppLogger {
  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}
  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {}
  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {}
  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {}
  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {}
  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {}
}
