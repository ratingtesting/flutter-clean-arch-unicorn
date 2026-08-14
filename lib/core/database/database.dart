import 'package:drift/drift.dart';

import 'tables/products_table.dart';

export 'tables/products_table.dart';

part 'database.g.dart';

/// Local relational database powered by Drift (SQLite).
///
/// Drift gives type-safe tables, code-generated queries, migrations and
/// reactive streams. It is the foundation for the VibeCoder → Unicorn path:
/// a feature that needs persistent relational data creates a table here and a
/// repository that writes through it, without reinventing storage.
///
/// Read [docs/database.md] before editing this file.
@DriftDatabase(tables: [CachedProducts])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Called when the schema version changes. Add a `from1To2` step here when
  /// you introduce the next migration (see docs/database.md).
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Example for the next migration:
          // if (from < 2) {
          //   await m.addColumn(cachedProducts, cachedProducts.someNewColumn);
          // }
        },
      );
}
