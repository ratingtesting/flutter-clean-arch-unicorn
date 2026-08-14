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

  static const _redactedKeys = {
    'password',
    'token',
    'authorization',
    'secret',
    'apikey',
    'api_key',
    'access_token',
    'refresh_token',
  };

  /// Returns true if the key matches a sensitive field that must never be logged.
  static bool _isSensitive(String key) =>
      _redactedKeys.contains(key.toLowerCase());

  /// Masks the values of sensitive keys in a request body before logging.
  ///
  /// Only objects shaped like maps are inspected; everything else is logged
  /// as-is (already truncated). This prevents credentials leaking to logs.
  String _redactBody(dynamic data) {
    if (data is Map) {
      final redacted = <String, dynamic>{};
      data.forEach((key, value) {
        final k = key is String ? key : key.toString();
        redacted[k] = _isSensitive(k) ? '***' : value;
      });
      return redacted.toString();
    }
    return data?.toString() ?? '';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start'] = DateTime.now().millisecondsSinceEpoch;
    final body =
        options.data != null ? _redactBody(options.data) : null;
    logger.info(
      '→ ${options.method} ${options.uri}'
      '${body != null ? ' | body: ${_truncate(body, 200)}' : ''}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start = response.requestOptions.extra['request_start'] as int?;
    final duration =
        start != null ? DateTime.now().millisecondsSinceEpoch - start : null;

    logger.info(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}'
      '${duration != null ? ' | ${duration}ms' : ''}'
      '${response.data != null ? ' | ${_responseSize(response.data)}' : ''}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final start = err.requestOptions.extra['request_start'] as int?;
    final duration =
        start != null ? DateTime.now().millisecondsSinceEpoch - start : null;

    logger.error(
      '✗ ${err.requestOptions.method} ${err.requestOptions.uri}'
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
