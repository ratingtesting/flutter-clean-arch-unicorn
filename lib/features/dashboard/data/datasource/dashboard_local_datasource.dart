import 'package:drift/drift.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/product/product_model.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

/// Local (offline) data source for the dashboard, backed by Drift.
///
/// The dashboard repository layers this under the remote source so the UI
/// renders instantly from cache and stays available without a network.
class DashboardLocalDatasource {
  DashboardLocalDatasource(this.db);
  final AppDatabase db;

  /// Replaces the cached product list (e.g. after a successful remote fetch).
  Future<Either<AppException, List<Product>>> cacheProducts(
    List<Product> products,
  ) async {
    try {
      await db.batch((batch) {
        batch.deleteAll(db.cachedProducts);
        batch.insertAll(
          db.cachedProducts,
          products.map(productToCompanion).toList(),
        );
      });
      return Right(products);
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to cache products: $e',
          statusCode: 500,
          identifier: 'DashboardLocalDatasource.cacheProducts',
        ),
      );
    }
  }

  /// Reads all cached products.
  Future<Either<AppException, List<Product>>> readCachedProducts() async {
    try {
      final rows = await db.select(db.cachedProducts).get();
      return Right(rows.map(productFromDataClass).toList());
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to read cached products: $e',
          statusCode: 500,
          identifier: 'DashboardLocalDatasource.readCachedProducts',
        ),
      );
    }
  }

  /// Clears the product cache.
  Future<Either<AppException, bool>> clearCache() async {
    try {
      await db.delete(db.cachedProducts).go();
      return const Right(true);
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to clear cache: $e',
          statusCode: 500,
          identifier: 'DashboardLocalDatasource.clearCache',
        ),
      );
    }
  }
}

/// Maps a [Product] domain model to a Drift insert companion.
CachedProductsCompanion productToCompanion(Product p) =>
    CachedProductsCompanion.insert(
      id: Value(p.id),
      title: Value(p.title),
      description: Value(p.description),
      thumbnail: Value(p.thumbnail),
      brand: Value(p.brand),
      category: Value(p.category),
      rating: Value(p.rating),
      discountPercentage: Value(p.discountPercentage),
      stock: Value(p.stock),
      price: Value(p.price),
    );

/// Maps a Drift row back to a [Product] domain model.
Product productFromDataClass(CachedProduct row) => Product(
  id: row.id,
  title: row.title,
  description: row.description,
  thumbnail: row.thumbnail,
  brand: row.brand,
  category: row.category,
  rating: row.rating,
  discountPercentage: row.discountPercentage,
  stock: row.stock,
  price: row.price,
);
