import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database_provider.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/data/repositories/dashboard_drift_repository.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/data/remote/network_service.dart';
import 'package:flutter_clean_arch_unicorn/shared/presentation/providers/dio_network_service_provider.dart';

final dashboardLocalDatasourceProvider = Provider<DashboardLocalDatasource>((
  ref,
) {
  return DashboardLocalDatasource(ref.watch(appDatabaseProvider));
});

final dashboardRemoteDatasourceProvider =
    Provider.family<DashboardDatasource, NetworkService>(
      (_, networkService) => DashboardRemoteDatasource(networkService),
    );

/// Drift-backed repository (local cache + remote, offline-first).
/// This is the recommended default. Swap for a pure-remote impl if you do not
/// want local caching yet.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final remote = ref.watch(dashboardRemoteDatasourceProvider(networkService));
  final local = ref.watch(dashboardLocalDatasourceProvider);
  return DashboardDriftRepository(remote, local);
});
