# Adding a Drift Table

Short guide for adding persistent relational storage with Drift.
Example used: the bundled `CachedProducts` table in `lib/core/database/tables/`.

## Steps

1. **Generate code first.** Run `make gen` (or `dart run build_runner build
   --delete-conflicting-outputs`) before anything else — without it, `analyzer`
   reports false errors on missing `*.g.dart` / freezed parts.

2. **Create the table file** `lib/core/database/tables/<name>_table.dart`:

   ```dart
   import 'package:drift/drift.dart';

   class Notes extends Table {
     IntColumn get id => integer().autoIncrement()();
     TextColumn get title => text().withDefault(const Constant(''))();
     TextColumn get body => text().withDefault(const Constant(''))();
     DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
   }
   ```

3. **Register it** in `lib/core/database/database.dart`:
   - add `import 'tables/<name>_table.dart';` and `export 'tables/<name>_table.dart';`
   - add the class to `@DriftDatabase(tables: [CachedProducts, Notes])`
   - keep `part 'database.g.dart';`

4. **Regenerate** with `make gen`. Drift writes `database.g.dart` containing the
   `Notes` and `NotesCompanion` classes (the data holder for inserts).

5. **Use it** from a repository / local datasource. Inject `AppDatabase`, call
   `into(notes).insert(notesCompanion...)`, `select(notes)`, `update(notes)`.

## Real-run FAQ (from a cold-start agent build)

- **Wrap every companion field in `Value(...)` with the exact column type.**
  `notesCompanion.insert(title: Value('Hi'))`. Forgetting `Value()` is a
  compile error the analyzer catches before you run.
- **`insert` / `replace` return `bool`** (success), not the model. To update
  an in-memory model, use the Freezed `copyWith`, e.g. `note.copyWith(title: 'x')`.
- **Freezed models are `abstract class`** with `const factory` constructors —
  you cannot `new` them; build via the factory or `copyWith`.
- **Bumping `schemaVersion` requires a migration.** When you go from `1` to `2`,
  add a `from1To2` step inside `MigrationStrategy` (see the example in
  `database.dart`) or the app crashes on existing installs.

## See also
- `lib/core/database/database.dart` — registration + migration strategy
- `lib/features/dashboard/data/datasource/dashboard_local_datasource.dart` —
  a real repository writing through a Drift table
