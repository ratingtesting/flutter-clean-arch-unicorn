# AGENTS.md — A Guide for AI Coding Agents

## What is this project?

A production-ready Flutter template built for startups. It provides Clean Architecture (feature-first), Riverpod 3, 151 unit tests, CI/CD, and security-by-default — so a solo founder can launch without hiring a senior engineer for architecture decisions.

## Project Structure

```
flutter_clean_arch_unicorn/
├── lib/
│   ├── configs/               # Global app configs
│   ├── features/
│   │   ├── authentication/    # Example: auth feature
│   │   │   ├── data/          # API, DB, repository implementations
│   │   │   ├── domain/        # Business logic, interfaces, models
│   │   │   └── presentation/  # UI screens, widgets, Riverpod providers
│   │   ├── dashboard/         # Example: dashboard feature
│   │   └── splash/            # Splash screen
│   ├── main/                  # Entry points (main_dev, main_staging, main_prod)
│   ├── routes/                # GoRouter (app_router.dart)
│   ├── services/
│   │   ├── observability/     # Logger, ErrorReporter, Analytics interfaces
│   │   ├── security/          # SecureStorage, interceptors
│   │   ├── network/          # Dio interceptors (retry, auth, logging)
│   │   └── user_cache_service/ # Local user cache (SharedPreferences + SecureStorage)
│   ├── core/
│   │   └── database/         # Drift local relational DB (typed tables)
│   └── shared/                # Shared models, theme, exceptions, widgets
├── test/                      # 151 unit tests
├── scripts/                   # check_secrets.sh pre-commit hook
├── .github/workflows/         # GitHub Actions (format → analyze → test → build)
├── tool/                      # new_feature.dart generator
└── docs/adr/                  # Architecture Decision Records
```

## Key Files to Modify

| Task | File(s) |
|------|---------|
| Add a new feature | Create `lib/features/<name>/` with `data/`, `domain/`, `presentation/` subdirectories |
| Change API | `lib/features/*/data/repositories/<name>_repository_impl.dart` + `lib/services/network/` |
| Replace data source | Implement domain interfaces in `data/`, swap via Riverpod provider overrides |
| Add a screen | Create in `features/<name>/presentation/screens/`, register route in `lib/routes/app_router.dart` |
| Modify CI | `.github/workflows/main.yml` |
| Add environment | Create `lib/main/main_<env>.dart`, add `--dart-define` config |
| Change error handling | `lib/shared/mixins/exception_handler_mixin.dart` |
| Add offline storage | `lib/core/database/` (Drift) + implement cache in data layer — see [docs/DRIFT_TABLE_GUIDE.md](docs/DRIFT_TABLE_GUIDE.md) |
| Fix tests | `test/features/<name>/` — tests mirror the source structure |

## Conventions

- **Architecture:** Clean Architecture — `domain` layer MUST NOT import `data` or `presentation` packages
- **Architecture boundaries (enforced by `tool/check_boundaries.dart`):** before writing code, identify the module and layer, then respect these machine-checked rules:
  1. `core/` MUST NOT depend on `features/` or `services/`
  2. `shared/` MUST NOT depend on `features/`
  3. `services/` MUST NOT depend on `features/` (any layer — move shared types to `shared/`, invert via a contract)
  4. `feature A` MUST NOT import internals of `feature B` (allowed: public barrel `features/<b>/<b>.dart` or a contract)
  5. `domain/` MUST NOT import `data/` or `presentation/`
  6. `data/` MUST NOT import `presentation/`
  7. `dio`/`drift`/`sqflite` are FORBIDDEN in `domain/` and `presentation/` screens/widgets (Repository Law — never bypass the repository). Allowed in `data/`, `core/database`, `services/`, and `presentation/providers/` (wiring layer).
  Rules are declared once in `lib/tool/boundary_rules.dart`. Run `dart run tool/check_boundaries.dart` after any change.
- **BEFORE WRITING CODE (mandatory):** (1) identify the feature, (2) identify the architectural layer, (3) identify allowed dependencies for that layer, (4) do NOT cross forbidden boundaries, (5) run `dart run tool/check_boundaries.dart` and fix any violation before finishing.
- **State Management:** Riverpod 3 — use `Notifier`/`AsyncNotifier`, NOT `StateNotifier`
- **Error Handling:** Use `Either<Failure, Success>` from `lib/shared/domain/models/either.dart`
- **Models:** Use Freezed for immutable state/DTOs, json_serializable for JSON parsing
- **Navigation:** GoRouter — routes are declarative in `lib/routes/app_router.dart`
- **Security:** Secrets via `--dart-define` only. No hardcoded API keys
- **Testing:** Unit tests with ProviderContainer + mocktail. No WidgetTester for provider tests
- **Formatting:** `dart format .` is the single source of truth
- **Naming:** PascalCase for types, camelCase for variables/functions, snake_case for files
- **Imports:** package: imports first, then dart:, then relative. Alphabetical within groups

## Common Tasks

### Add a new feature
```
1. mkdir -p lib/features/<name>/{data,domain,presentation}
2. Create domain: repository interface, entities (Freezed), use cases
3. Create data: repository implementation, data sources, DTOs
4. Create presentation: Notifier, screens, widgets, route
5. Add tests: unit for domain + data, provider tests for presentation
6. Register providers in feature's providers/ directory
7. Add route in lib/routes/app_router.dart
```

### Test a provider in isolation
```dart
final container = ProviderContainer(overrides: [
  repositoryProvider.overrideWithValue(MockRepository()),
]);
final notifier = container.read(myProvider.notifier);
await notifier.someMethod();
expect(notifier.state, expectedState);
```

### Run the full validation suite
```bash
make.bat check
# or manually:
flutter analyze lib/ test/
dart format --set-exit-if-changed .
flutter test
dart run tool/check_boundaries.dart   # architecture boundary enforcement (CI runs this too)
```

## Notes for AI Agents

- This project uses **Flutter 3.44.8** with Dart 3 pattern matching (`case Type _:` — already types `e`, no cast needed)
- `avoid_dynamic_calls` warnings in `parse_response.dart` and `exception_handler_mixin.dart` are **intentional** (JSON API responses + dynamic exception handling)
- The 3 example features (auth, dashboard, splash) are minimal — replace them with your own
- `Noop*` implementations in `services/observability/` are placeholders. Replace with real implementations (Crashlytics, Sentry, Amplitude) when deploying to production

## Code Graph (token economy — read this before searching code)

This project ships a **graphify code graph** in `graphify-out/graph.json`. Its purpose is **token
savings, not magic**: instead of loading whole files into context, query the graph to locate the
2-3 relevant spots, then read only those. Graph-assisted lookup is cheaper than brute-force file reads.

- **Graph exists?** `graphify-out/graph.json` (relative to project root). If present, use the
  `graphify` skill (`/graphify`) to answer "how does X work / what calls Y / trace Z" questions —
  it reads the graph first, loads files only when needed.
- **Build the graph once per project** (not per session): `graphify extract .` (or `graphify-ds`
  helper). Writes `./graphify-out/`. Model/backend are global in `~/.graphify/providers.json` — no
  per-project init.
- **Rebuild after big refactors:** `graphify update .` (no LLM re-scan needed for code-only changes).
- **Isolation:** graphs are per-project (under each project's own `graphify-out/`). They NEVER mix
  across projects unless `graphify merge-graphs` is run explicitly.
- **Rule of thumb:** prefer graph queries for navigation; load file contents only to verify/edit.
  This keeps token usage low on long tasks.