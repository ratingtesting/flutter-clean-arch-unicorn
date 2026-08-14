/// Structured logging interceptor for Dio.
///
/// Logs every request/response with timing, status, and size.
/// Critical for performance monitoring and debugging in production.
library;

import 'package:dio/dio.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required this.logger});

  final AppLogger logger;

  /// Substrings that mark a key (or value) as sensitive and therefore must
  /// never appear in logs. Matching is case-insensitive and by substring, so
  /// `authToken`, `api_key`, `userSecret`, etc. are all caught.
  static const _sensitiveSubstrings = {'token', 'secret', 'password', 'apikey'};

  /// Returns true if [key] contains a sensitive field that must be masked.
  static bool _isSensitive(String key) =>
      _sensitiveSubstrings.any((s) => key.toLowerCase().contains(s));

  /// Returns true if [text] contains any sensitive substring.
  static bool _containsSensitive(String text) =>
      _sensitiveSubstrings.any((s) => text.toLowerCase().contains(s));

  /// Redacts the values of `"key": value` pairs whose key contains a sensitive
  /// substring, from a raw (JSON or otherwise) string. Non-structured strings
  /// that merely contain a sensitive substring (e.g. form-encoded
  /// `token=abc`) are masked wholesale.
  String _redactString(String text) {
    if (!_containsSensitive(text)) return text;
    final masked = text.replaceAllMapped(
      RegExp(
        r'("(?:[^"\\]|\\.)*")\s*:\s*'
        r'("(?:[^"\\]|\\.)*"|true|false|null|\d+(?:\.\d+)?|\[[^\]]*\]|\{[^\}]*\}|[^\s,}\]]+)',
      ),
      (m) {
        final key = m.group(1)!;
        return _isSensitive(key) ? '${m.group(1)}:"***"' : m.group(0)!;
      },
    );
    // No JSON-style pair was redacted yet the text still holds a sensitive
    // substring: mask the whole thing rather than leak it.
    if (masked == text) return '<redacted: contains sensitive data>';
    return masked;
  }

  /// Masks sensitive data in a request body before logging.
  ///
  /// Maps are inspected key-by-key. Raw strings (including raw JSON bodies)
  /// are scanned for sensitive keys and their values masked.
  String _redactBody(dynamic data) {
    if (data is Map) {
      final redacted = <String, dynamic>{};
      data.forEach((key, value) {
        final k = key is String ? key : key.toString();
        redacted[k] = _isSensitive(k) ? '***' : value;
      });
      return redacted.toString();
    }
    return _redactString(data?.toString() ?? '');
  }

  /// Redacts sensitive query parameters from a URI before logging. Query
  /// parameter values whose key contains a sensitive substring are replaced
  /// with `***` so tokens/secrets never reach the logs.
  String _redactUri(Uri uri) {
    if (uri.queryParameters.isEmpty) return uri.toString();
    final redacted = uri.replace(
      queryParameters: {
        for (final e in uri.queryParameters.entries)
          e.key: _isSensitive(e.key) ? '***' : e.value,
      },
    );
    return redacted.toString();
  }

  /// Public redaction helpers (used by tests and external callers to verify
  /// sensitive data never reaches logs).
  String redact(String input) => _redactString(input);
  String redactBody(dynamic data) => _redactBody(data);
  String redactUri(Uri uri) => _redactUri(uri);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start'] = DateTime.now().millisecondsSinceEpoch;
    final body = options.data != null ? _redactBody(options.data) : null;
    logger.info(
      '→ ${options.method} ${_redactUri(options.uri)}'
      '${body != null ? ' | body: ${_truncate(body, 200)}' : ''}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start = response.requestOptions.extra['request_start'] as int?;
    final duration = start != null
        ? DateTime.now().millisecondsSinceEpoch - start
        : null;

    logger.info(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${_redactUri(response.requestOptions.uri)}'
      '${duration != null ? ' | ${duration}ms' : ''}'
      '${response.data != null ? ' | ${_responseSize(response.data)}' : ''}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final start = err.requestOptions.extra['request_start'] as int?;
    final duration = start != null
        ? DateTime.now().millisecondsSinceEpoch - start
        : null;

    logger.error(
      '✗ ${err.requestOptions.method} ${_redactUri(err.requestOptions.uri)}'
      '${duration != null ? ' | ${duration}ms' : ''}'
      ' | ${err.message}',
    );
    handler.next(err);
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}…';
  }

  String _responseSize(dynamic data) {
    if (data is List) return '${data.length} items';
    if (data is Map) return '${data.length} keys';
    final str = data.toString();
    return str.length > 100
        ? '${(str.length / 1024).toStringAsFixed(1)}KB'
        : '${str.length}B';
  }
}
