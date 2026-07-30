import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/datasource/user_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/repositories/user_repository_impl.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/domain/repositories/user_cache_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/presentation/providers/shared_preferences_storage_service_provider.dart';
import 'package:flutter_clean_arch_unicorn/services/service_providers.dart';

final userDatasourceProvider = Provider<UserDataSource>((ref) {
  final prefs = ref.read(storageServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return UserLocalDataSource(prefs, secureStorage);
});

final userLocalRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(userDatasourceProvider);
  return UserRepositoryImpl(datasource);
});
