import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/paginated_response.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/product/product_model.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

/// Drift-backed dashboard repository.
///
/// Reference implementation of the Repository Law + caching extension (§12, §20):
///   Feature → Repository (interface) → Local + Remote datasources → Drift / Dio
///
/// Strategy: try the network first; on success, update the Drift cache and
/// return fresh data. On failure, fall back to the local Drift cache so the UI
/// still renders. This is the offline-first pattern without a heavy framework.
class DashboardDriftRepository extends DashboardRepository {
  DashboardDriftRepository(this.remoteDatasource, this.localDatasource);

  final DashboardDatasource remoteDatasource;
  final DashboardLocalDatasource localDatasource;

  @override
  Future<Either<AppException, PaginatedResponse>> fetchProducts(
      {required int skip}) async {
    final remote = await remoteDatasource.fetchPaginatedProducts(skip: skip);
    return remote.fold(
      (failure) => _fallbackToCache(failure),
      (response) async {
        // Cache the freshly fetched page for offline rendering.
        final products = response.data
            .map((e) => Product.fromJson(e))
            .toList(growable: false);
        await localDatasource.cacheProducts(products);
        return Right(response);
      },
    );
  }

  @override
  Future<Either<AppException, PaginatedResponse>> searchProducts(
      {required int skip, required String query}) async {
    // Search is network-only here; caching search results is a later extension.
    return remoteDatasource.searchPaginatedProducts(skip: skip, query: query);
  }

  Future<Either<AppException, PaginatedResponse>> _fallbackToCache(
    AppException failure,
  ) async {
    final cached = await localDatasource.readCachedProducts();
    return cached.fold(
      (cacheFailure) => Left(failure),
      (products) => Right(PaginatedResponse(
        total: products.length,
        skip: 0,
        data: products,
      )),
    );
  }
}
