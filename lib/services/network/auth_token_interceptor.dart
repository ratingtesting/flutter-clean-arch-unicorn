/// Auth token interceptor for Dio.
///
/// Attaches Bearer token to all requests and handles 401 auto-refresh.
/// Tokens are stored in SecureStorage (encrypted), never in SharedPreferences.
library;

import 'package:dio/dio.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/logger.dart';
import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';

class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor({
    required this.secureStorage,
    required this.logger,
    this.onTokenRefresh,
    this.refreshEndpoint = '/auth/refresh',
  });

  final SecureStorage secureStorage;
  final AppLogger logger;
  final Future<String?> Function(String refreshToken)? onTokenRefresh;
  final String refreshEndpoint;

  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/refresh endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains(refreshEndpoint)) {
      return handler.next(options);
    }

    final token = await secureStorage.read(SecureStorageKeys.authToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await secureStorage.read(
          SecureStorageKeys.refreshToken,
        );

        if (refreshToken == null || refreshToken.isEmpty) {
          logger.warning('No refresh token available, forcing logout');
          return handler.next(err);
        }

        if (onTokenRefresh != null) {
          final newToken = await onTokenRefresh!(refreshToken);

          if (newToken != null && newToken.isNotEmpty) {
            await secureStorage.write(SecureStorageKeys.authToken, newToken);
            logger.info('Token refreshed successfully');

            // Retry original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            try {
              final dio = Dio();
              final response = await dio.fetch(err.requestOptions);
              handler.resolve(response);
              return;
            } on DioException catch (e) {
              handler.next(e);
              return;
            }
          }
        }

        logger.warning('Token refresh failed, clearing credentials');
        await _clearCredentials();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  Future<void> _clearCredentials() async {
    await secureStorage.delete(SecureStorageKeys.authToken);
    await secureStorage.delete(SecureStorageKeys.refreshToken);
    await secureStorage.delete(SecureStorageKeys.userId);
  }
}
