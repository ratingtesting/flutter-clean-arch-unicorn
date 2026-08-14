library;

import 'package:flutter_clean_arch_unicorn/services/observability/logger.dart';

final _logger = ConsoleLogger();

/// Crash reporting abstraction.
///
/// Wraps Firebase Crashlytics / Sentry behind a single interface.
/// Never let a crash go unreported in production.
abstract class CrashReportingService {
  Future<void> initialize();
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, dynamic>? metadata,
  });
  Future<void> recordMessage(String message, {bool fatal = false});
  Future<void> setUserIdentifier(String id);
  Future<void> setCustomKey(String key, dynamic value);
  Future<void> log(String message);
}

/// No-op for testing (zero side effects).
class NoopCrashReportingService extends CrashReportingService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {}

  @override
  Future<void> recordMessage(String message, {bool fatal = false}) async {}

  @override
  Future<void> setUserIdentifier(String id) async {}

  @override
  Future<void> setCustomKey(String key, dynamic value) async {}

  @override
  Future<void> log(String message) async {}
}

/// Production implementation using Firebase Crashlytics.
/// This class is only used when Firebase is configured.
/// See firebase_crash_reporting_service.dart for the actual implementation.
class CrashlyticsReportingService extends CrashReportingService {
  CrashlyticsReportingService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    _logger.log(
      LogLevel.debug,
      '[CrashlyticsReportingService] recordError: $error',
    );
  }

  @override
  Future<void> recordMessage(String message, {bool fatal = false}) async {
    _logger.log(
      LogLevel.debug,
      '[CrashlyticsReportingService] recordMessage: $message',
    );
  }

  @override
  Future<void> setUserIdentifier(String id) async {}

  @override
  Future<void> setCustomKey(String key, dynamic value) async {}

  @override
  Future<void> log(String message) async {
    _logger.log(LogLevel.debug, '[CrashlyticsReportingService] log: $message');
  }
}
