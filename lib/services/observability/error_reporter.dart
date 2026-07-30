library;

import 'package:flutter/foundation.dart';

/// Crash reporting abstraction.
///
/// Wraps Firebase Crashlytics / Sentry behind a single interface.
/// Never let a crash go unreported in production.

abstract class ErrorReporter {
  Future<void> initialize();
  Future<void> recordError(Object error, StackTrace stackTrace,
      {String? reason, Map<String, dynamic>? metadata});
  Future<void> recordMessage(String message, {bool fatal = false});
  Future<void> setUserIdentifier(String id);
  Future<void> setCustomKey(String key, dynamic value);
  Future<void> log(String message);
}

/// No-op for testing (zero side effects).
class NoopErrorReporter extends ErrorReporter {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> recordError(Object error, StackTrace stackTrace,
      {String? reason, Map<String, dynamic>? metadata}) async {}

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
/// See firebase_error_reporter.dart for the actual implementation.
class CrashlyticsReporter extends ErrorReporter {
  CrashlyticsReporter();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('[CrashlyticsReporter] recordError: $error');
  }

  @override
  Future<void> recordMessage(String message, {bool fatal = false}) async {
    debugPrint('[CrashlyticsReporter] recordMessage: $message');
  }

  @override
  Future<void> setUserIdentifier(String id) async {}

  @override
  Future<void> setCustomKey(String key, dynamic value) async {}

  @override
  Future<void> log(String message) async {
    debugPrint('[CrashlyticsReporter] log: $message');
  }
}
