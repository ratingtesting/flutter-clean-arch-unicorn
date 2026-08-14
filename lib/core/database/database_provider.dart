import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'database_connection.dart';

/// Provides the app-wide [AppDatabase].
///
/// Default throws: the concrete database is opened asynchronously in each
/// `main_*.dart` entrypoint and wired via
/// `appDatabaseProvider.overrideWithValue(await openAppDatabase())`.
/// In tests, override it with [openTestDatabase].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with a real or test database.',
  );
});

/// Opens the on-disk database at the app documents directory.
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return connectOnDisk(p.join(dir.path, 'app.db'));
}
