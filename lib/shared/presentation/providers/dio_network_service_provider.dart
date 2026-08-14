import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/shared/data/remote/dio_network_service.dart';
import 'package:flutter_clean_arch_unicorn/services/network/auth_token_interceptor.dart';
import 'package:flutter_clean_arch_unicorn/services/network/logging_interceptor.dart';
import 'package:flutter_clean_arch_unicorn/services/network/retry_interceptor.dart';
import 'package:flutter_clean_arch_unicorn/services/service_providers.dart';

/// Creates a fresh [Dio] instance with the template's interceptors attached.
///
/// Each call builds its own client so interceptors are never mutated onto a
/// shared singleton (the old `dioProvider` was mutated by `networkServiceProvider`,
/// which double-adds interceptors on re-read and leaks state across features).
Dio createDio(Ref ref) {
  final logger = ref.read(loggerProvider);
  final secureStorage = ref.read(secureStorageProvider);

  final dio = Dio();
  // Order matters: logging (outermost) -> auth token -> retry (innermost).
  dio.interceptors.addAll([
    LoggingInterceptor(logger: logger),
    AuthTokenInterceptor(secureStorage: secureStorage, logger: logger),
    RetryInterceptor(dio: dio, logger: logger),
  ]);
  return dio;
}

/// The network service used by all features. Builds its own [Dio] internally.
final networkServiceProvider = Provider<DioNetworkService>((ref) {
  final dio = createDio(ref);
  return DioNetworkService(dio);
});
