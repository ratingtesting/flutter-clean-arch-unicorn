import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/presentation/providers/dio_network_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final providerContainer = ProviderContainer();
  late dynamic networkService;
  late dynamic dashboardDataSource;
  late dynamic dashboardRespository;
  setUpAll(
    () {
      networkService = providerContainer.read(networkServiceProvider);
      dashboardDataSource =
          providerContainer.read(dashboardDatasourceProvider(networkService));
      dashboardRespository =
          providerContainer.read(dashboardRepositoryProvider);
    },
  );
  test('dashboardDatasourceProvider is a DashboardDatasource', () {
    expect(
      dashboardDataSource,
      isA<DashboardDatasource>(),
    );
  });
  test('dashboardRepositoryProvider is a DashboardRepository', () {
    expect(
      dashboardRespository,
      isA<DashboardRepository>(),
    );
  });
  test('dashboardRepositoryProvider returns a DashboardRepository', () {
    expect(
      providerContainer.read(dashboardRepositoryProvider),
      isA<DashboardRepository>(),
    );
  });
}
