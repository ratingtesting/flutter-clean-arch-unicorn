import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/paginated_response.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/domain/models/product_model.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

/// Drift-backed dashboard repository.
///
/// Reference implementation of the Repository Law + caching extension (§12, §20):
///   Feature → Repository (interface) → Local + Remote datasources → Drift / Dio
///
/// Strategy: serve from the Drift cache instantly (cache-then-remote), then
/// refresh from the network in the background so the UI renders without waiting
/// on the network. Falls back to remote-only when the cache is empty.
class DashboardDriftRepository extends DashboardRepository {
  DashboardDriftRepository(this.remoteDatasource, this.localDatasource);

  final DashboardDatasource remoteDatasource;
  final DashboardLocalDatasource localDatasource;

  @override
  Future<Either<AppException, PaginatedResponse>> fetchProducts({
    required int skip,
  }) async {
    final cached = await localDatasource.readCachedProducts();
    return cached.fold(
      (cacheFailure) async {
        // Cache empty/unavailable → go straight to network.
        return _fetchFromRemote(skip);
      },
      (products) async {
        if (products.isNotEmpty) {
          // Instant serve from cache, then refresh in background.
          _refreshInBackground(skip);
          return Right(
            PaginatedResponse(
              total: products.length,
              skip: skip,
              data: products,
            ),
          );
        }
        return _fetchFromRemote(skip);
      },
    );
  }

  Future<Either<AppException, PaginatedResponse>> _fetchFromRemote(
    int skip,
  ) async {
    final remote = await remoteDatasource.fetchPaginatedProducts(skip: skip);
    return remote.fold((failure) => _fallbackToCache(failure), (
      response,
    ) async {
      final products = response.data
          .map((e) => Product.fromJson(e))
          .toList(growable: false);
      await localDatasource.cacheProducts(products);
      return Right(response);
    });
  }

  void _refreshInBackground(int skip) {
    remoteDatasource.fetchPaginatedProducts(skip: skip).then((remote) {
      remote.fold((_) {}, (response) async {
        final products = response.data
            .map((e) => Product.fromJson(e))
            .toList(growable: false);
        await localDatasource.cacheProducts(products);
      });
    });
  }

  @override
  Future<Either<AppException, PaginatedResponse>> searchProducts({
    required int skip,
    required String query,
  }) async {
    // Search is network-only here; caching search results is a later extension.
    return remoteDatasource.searchPaginatedProducts(skip: skip, query: query);
  }

  Future<Either<AppException, PaginatedResponse>> _fallbackToCache(
    AppException failure,
  ) async {
    final cached = await localDatasource.readCachedProducts();
    return cached.fold(
      (cacheFailure) => Left(failure),
      (products) => Right(
        PaginatedResponse(total: products.length, skip: 0, data: products),
      ),
    );
  }
}
