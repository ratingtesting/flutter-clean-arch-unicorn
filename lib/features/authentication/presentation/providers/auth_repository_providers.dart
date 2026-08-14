import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/data/remote/remote.dart';
import 'package:flutter_clean_arch_unicorn/shared/presentation/providers/dio_network_service_provider.dart';
import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';
import 'package:flutter_clean_arch_unicorn/services/service_providers.dart';

/// Wires the authentication repository (domain boundary) to its data-layer
/// implementation. Lives in `presentation/providers/` because Riverpod wiring
/// is infrastructure — never inside `domain/`.
final authDataSourceProvider =
    Provider.family<LoginUserDataSource, NetworkService>(
      (ref, networkService) => LoginUserRemoteDataSource(
        networkService,
        ref.watch(secureStorageProvider),
      ),
    );

final authRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final dataSource = ref.watch(authDataSourceProvider(networkService));
  return AuthenticationRepositoryImpl(dataSource);
});

/// Secure storage for auth tokens (encrypted, not SharedPreferences).
final authSecureStorageProvider = Provider<SecureStorage>((ref) {
  return ref.watch(secureStorageProvider);
});
