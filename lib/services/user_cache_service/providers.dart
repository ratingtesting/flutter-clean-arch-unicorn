import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/datasource/user_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/repositories/user_repository_impl.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/domain/repositories/user_cache_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/presentation/providers/shared_preferences_storage_service_provider.dart';
import 'package:flutter_clean_arch_unicorn/services/service_providers.dart';

/// Public infrastructure contract for the user-cache service.
///
/// Other features (auth, splash) import the repository provider from HERE —
/// not from `presentation/providers/user_cache_provider.dart` — so they depend
/// on the service's boundary, not its presentation internals.
export 'data/datasource/user_local_datasource.dart';
export 'domain/repositories/user_cache_repository.dart';

final userDatasourceProvider = Provider<UserDataSource>((ref) {
  final prefs = ref.read(storageServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return UserLocalDataSource(prefs, secureStorage);
});

final userLocalRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userDatasourceProvider);
  return UserRepositoryImpl(datasource);
});
