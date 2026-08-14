import 'package:drift/drift.dart';

/// Local cache of catalog products.
///
/// Mirrors the network `Product` model (lib/shared/domain/models/product/).
/// The dashboard feature caches products here so the app works offline and
/// renders instantly on the next launch.
class CachedProducts extends Table {
  /// Server product id.
  IntColumn get id => integer()();

  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get thumbnail => text().withDefault(const Constant(''))();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
  RealColumn get rating => real().withDefault(const Constant(0.0))();
  RealColumn get discountPercentage =>
      real().withDefault(const Constant(0.0))();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get price => integer().withDefault(const Constant(0))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
