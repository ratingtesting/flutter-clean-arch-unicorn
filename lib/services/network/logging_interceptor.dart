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

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start'] = DateTime.now().millisecondsSinceEpoch;
    logger.info(
      '→ ${options.method} ${options.uri}'
      '${options.data != null ? ' | body: ${_truncate(options.data.toString(), 200)}' : ''}',
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
