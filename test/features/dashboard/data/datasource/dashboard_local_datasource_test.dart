import 'package:flutter_clean_arch_unicorn/core/database/database.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database_connection.dart';
import 'package:flutter_clean_arch_unicorn/features/dashboard/data/datasource/dashboard_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/product/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardLocalDatasource (Drift)', () {
    late AppDatabase db;
    late DashboardLocalDatasource datasource;

    setUp(() {
      // In-memory database — isolated per test, no disk IO.
      db = openTestDatabase();
      datasource = DashboardLocalDatasource(db);
    });

    tearDown(() => db.close());

    final sample = [
      Product(id: 1, title: 'Widget', price: 9, rating: 4.5),
      Product(id: 2, title: 'Gadget', price: 19, rating: 3.0),
    ];

    test('cacheProducts stores and readCachedProducts returns them', () async {
      final cacheResult = await datasource.cacheProducts(sample);
      expect(cacheResult.isRight(), isTrue);

      final read = await datasource.readCachedProducts();
      read.fold((l) => fail('expected cached products, got $l'), (products) {
        expect(products.length, 2);
        expect(products.first.title, 'Widget');
        expect(products.last.price, 19);
      });
    });

    test('clearCache empties the table', () async {
      await datasource.cacheProducts(sample);
      final cleared = await datasource.clearCache();
      expect(cleared.isRight(), isTrue);

      final read = await datasource.readCachedProducts();
      read.fold(
        (l) => fail('expected empty cache, got $l'),
        (products) => expect(products, isEmpty),
      );
    });

    test('re-cache replaces previous entries (no duplicates)', () async {
      await datasource.cacheProducts(sample);
      await datasource.cacheProducts([Product(id: 3, title: 'Only', price: 1)]);

      final read = await datasource.readCachedProducts();
      read.fold(
        (l) => fail('unexpected error $l'),
        (products) => expect(products.length, 1),
      );
    });
  });
}
