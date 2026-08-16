import 'package:drift/drift.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database_connection.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the Drift local database opens with the expected schema and
/// survives a basic write/read cycle. This is the migration/schema guard
/// the original audit flagged as missing (drift tested only indirectly via
/// dashboard datasource).
void main() {
  group('AppDatabase schema (drift migration guard)', () {
    late AppDatabase db;

    setUp(() {
      db = openTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('opens at schema version 1', () {
      expect(db.schemaVersion, 1);
    });

    test('creates CachedProducts table and round-trips a row', () async {
      await db
          .into(db.cachedProducts)
          .insert(
            CachedProductsCompanion.insert(
              id: const Value(42),
              title: const Value('Unicorn'),
              price: const Value(999),
              category: const Value('misc'),
            ),
          );

      final rows = await db.select(db.cachedProducts).get();
      expect(rows, hasLength(1));
      expect(rows.first.title, 'Unicorn');
      expect(rows.first.price, 999);
    });

    test('empty table returns no rows before any insert', () async {
      final rows = await db.select(db.cachedProducts).get();
      expect(rows, isEmpty);
    });
  });
}
