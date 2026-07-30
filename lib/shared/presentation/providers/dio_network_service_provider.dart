import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/shared/data/remote/dio_network_service.dart';
import 'package:flutter_clean_arch_unicorn/services/network/auth_token_interceptor.dart';
import 'package:flutter_clean_arch_unicorn/services/network/logging_interceptor.dart';
import 'package:flutter_clean_arch_unicorn/services/network/retry_interceptor.dart';
import 'package:flutter_clean_arch_unicorn/services/service_providers.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final networkServiceProvider = Provider<DioNetworkService>((ref) {
  final dio = ref.read(dioProvider);
  final logger = ref.read(loggerProvider);
  final secureStorage = ref.read(secureStorageProvider);

  // Add interceptors in correct order:
  // 1. Logging (outermost - logs everything)
  // 2. Auth token (adds Bearer token)
  // 3. Retry (inner - retries failed requests)
  dio.interceptors.addAll([
    LoggingInterceptor(logger: logger),
    AuthTokenInterceptor(secureStorage: secureStorage, logger: logger),
    RetryInterceptor(dio: dio, logger: logger),
  ]);

  return DioNetworkService(dio);
});
