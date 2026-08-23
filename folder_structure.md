# Folder Structure

Actual layout of `flutter-clean-arch-unicorn` (generated from the repository tree).
Mirrors the diagrams in `README.md` and `ARCHITECTURE.md`.

```
flutter_clean_arch_unicorn/
├── lib/
│   ├── configs/                 # Global app configs (AppConfigs, environment)
│   ├── core/
│   │   └── database/            # Drift local relational DB (typed tables, migrations)
│   │       ├── database.dart
│   │       ├── database.g.dart
│   │       ├── database_connection.dart
│   │       ├── database_provider.dart
│   │       └── tables/
│   ├── features/                # Isolated feature modules (feature-first)
│   │   ├── authentication/      # Example feature
│   │   │   ├── data/
│   │   │   │   ├── datasource/        # auth_remote_data_source.dart
│   │   │   │   └── repositories/      # authentication_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/            # user_model.dart
│   │   │   │   ├── repositories/      # AuthenticationRepository (interface)
│   │   │   │   └── use_cases/         # login_use_case.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── state/         # auth_state.dart, auth_notifier.dart
│   │   │       │   └── auth_providers.dart
│   │   │       ├── screens/           # login_screen.dart
│   │   │       └── widgets/
│   │   ├── dashboard/           # Same structure (data/domain/presentation)
│   │   └── splash/              # Splash screen (presentation only)
│   ├── main/                    # Entry points
│   │   ├── main_dev.dart
│   │   ├── main_staging.dart
│   │   ├── main_prod.dart
│   │   └── main_common.dart
│   ├── routes/                  # GoRouter (app_router.dart)
│   ├── services/
│   │   ├── observability/       # Logger, ErrorReporter, Analytics, FeatureFlags contracts
│   │   ├── security/            # SecureStorage (interface + impl + fake)
│   │   ├── network/             # Dio interceptors (retry, auth, logging)
│   │   └── user_cache_service/  # Local user cache (SharedPreferences + SecureStorage)
│   └── shared/                  # Shared code
│       ├── data/                # local (shared_prefs) + remote (dio) datasources
│       ├── domain/              # models (product/user), providers, either
│       ├── exceptions/          # AppException hierarchy
│       ├── mixins/              # exception_handler_mixin.dart
│       ├── presentation/        # providers, theme, widgets
│       └── theme/               # AppTheme
├── test/                        # 151 tests (mirrors lib/), + fixtures, regression, tool
├── tool/                        # new_feature.dart generator, check_boundaries.dart
├── scripts/                     # check_secrets.sh pre-commit checker
├── docs/                        # ADRs, audits, handoffs
└── .github/
    ├── workflows/main.yml       # CI: pub get → build_runner → format → analyze → boundary → test+coverage → coverage gate → apk build
    ├── copilot-instructions.md
    └── PULL_REQUEST_TEMPLATE.md
```

## Rules (enforced by `tool/check_boundaries.dart` in CI)

- Feature A never imports Feature B internals.
- `presentation` never imports `dio` / `drift` / `firebase` directly.
- `domain` never imports `data` or `presentation`.
- Infrastructure (Dio, Drift, SecureStorage) is injected via Riverpod providers.
- `shared/` holds cross-cutting models and utilities — no feature business logic.

## Key files

| Task | File(s) |
|------|---------|
| Add a feature | `lib/features/<name>/` with `data/`, `domain/`, `presentation/` |
| Change API | `lib/features/*/data/repositories/<name>_repository_impl.dart` + `lib/services/network/` |
| Local persistence | `lib/core/database/` (Drift) + cache in the data layer |
| Auth flow | `lib/features/authentication/` + `lib/routes/app_router.dart` (guard) |
| CI | `.github/workflows/main.yml` |
| Env config | `lib/main/main_<env>.dart` + `--dart-define` |
| Generate code | `dart run build_runner build --delete-conflicting-outputs` |
| Scaffold a feature | `dart run tool/new_feature.dart <name>` |
