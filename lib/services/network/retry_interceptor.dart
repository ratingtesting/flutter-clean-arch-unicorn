/// Dio interceptor with exponential backoff retry.
///
/// Automatically retries transient network failures (timeout, 5xx, 429).
/// Non-retryable errors (4xx except 429) pass through immediately.
library;

import 'package:dio/dio.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/logger.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.logger,
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(milliseconds: 500),
      Duration(seconds: 1),
      Duration(seconds: 2),
    ],
  });

  final AppLogger logger;
  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  static const _retryableStatusCodes = {408, 429, 500, 502, 503, 504};

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra['retry_count'] as int?) ?? 0;

    if (retryCount >= maxRetries || !_isRetryable(err)) {
      logger.warning(
        'Request failed after $retryCount retries: '
        '${err.requestOptions.method} ${err.requestOptions.path} '
        '[${err.response?.statusCode}]',
      );
      return handler.next(err);
    }

    final delay = retryDelays[retryCount.clamp(0, retryDelays.length - 1)];
    logger.info(
      'Retrying request (${retryCount + 1}/$maxRetries) '
      '${err.requestOptions.method} ${err.requestOptions.path} '
      'in ${delay.inMilliseconds}ms',
    );

    await Future.delayed(delay);

    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    final statusCode = err.response?.statusCode;
    return statusCode != null && _retryableStatusCodes.contains(statusCode);
  }
}
