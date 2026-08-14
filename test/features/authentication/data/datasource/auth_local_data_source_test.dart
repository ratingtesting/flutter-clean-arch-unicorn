import 'package:flutter_clean_arch_unicorn/services/network/logging_interceptor.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/logger.dart';
import 'package:flutter_test/flutter_test.dart';

/// The auth *local* data source is the on-device token/session cache. In this
/// template the auth flow stores the token via SecureStorage on login
/// (see auth_remote_data_source) and restores the session through
/// UserLocalDataSource.
///
/// These tests verify the LOGGING layer (LoggingInterceptor) correctly redacts
/// credentials before they could reach logs — the security boundary the
/// original placeholder documented but did not check.
class _NoopLogger implements AppLogger {
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

void main() {
  group('LoggingInterceptor redacts credentials (auth local boundary)', () {
    final interceptor = LoggingInterceptor(logger: _NoopLogger());

    test('redacts sensitive query param in URI (token must not leak)', () {
      final uri = Uri.parse('https://api.example.com/login?token=abc123&id=5');
      final out = interceptor.redactUri(uri);
      expect(out, isNot(contains('abc123')));
      expect(out, contains('token=%2A%2A%2A'));
      expect(out, contains('id=5'));
    });

    test('redacts password in JSON body', () {
      final body = {'username': 'bob', 'password': 's3cret'};
      final out = interceptor.redactBody(body);
      expect(out, isNot(contains('s3cret')));
      expect(out, contains('password: ***'));
      expect(out, contains('bob'));
    });

    test('redacts raw string body containing token substring', () {
      final out = interceptor.redact('token=plaintextsecretvalue');
      expect(out, isNot(contains('plaintextsecretvalue')));
      expect(out, equals('<redacted: contains sensitive data>'));
    });

    test('does NOT redact benign values', () {
      final uri = Uri.parse('https://api.example.com/users?id=42&name=alice');
      final out = interceptor.redactUri(uri);
      expect(out, contains('id=42'));
      expect(out, contains('name=alice'));
    });
  });
}
