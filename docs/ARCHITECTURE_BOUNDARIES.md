# Architecture Boundaries

Enforceable rules for `shared/` and feature boundaries in this template.
These rules prevent architectural decay as the project grows from
VibeCoder → MVP → Scale → Unicorn.

## Feature boundaries (§11)

Allowed:
- `Feature A` → `core/`
- `Feature A` → `shared/`
- `Feature A` → `services/` (via contracts)

Forbidden:
- `Feature A` → `Feature B` internals (e.g. `features/dashboard/data/...` imported by `features/authentication`)

A CI guard (`tool/check_boundaries.dart`) fails the build on cross-feature
imports. Run it locally:

```bash
dart run tool/check_boundaries.dart
```

## Shared must be strict (§10, §7)

`shared/` is NOT a dumping ground. It may contain **only** genuinely
generic primitives:

Allowed in `shared/`:
- `domain/models/` — cross-cutting models used by 2+ features (e.g. `Either`, `PaginatedResponse`, `User` when shared)
- `data/remote/` — `NetworkService` / `DioNetworkService` abstraction
- `data/local/` — `SharedPreferencesStorageService` abstraction
- `theme/` — colors, text themes
- `widgets/` — `AppError`, `AppLoading` generic UI
- `exceptions/` — `AppException`, `ExceptionHandlerMixin`
- `constants.dart` — global constants (`kTestMode`, `PRODUCTS_PER_PAGE`, storage keys)

Forbidden in `shared/`:
- Feature-specific domain models → belong in `features/<name>/domain/models/`
- Feature-specific business logic
- DI wiring (`*_provider.dart`) in `shared/presentation/` — providers live in their feature's `presentation/providers/`
- Global mutable state (`globals.dart` is banned; use `constants.dart`)

## Repository Law (§12, §6)

Presentation must NEVER import Dio / Drift / Firebase directly.

Correct chain:
```
Presentation (widget)
  ↓
Riverpod Provider
  ↓
Repository interface (domain)
  ↓
Repository implementation
  ↓
Datasource (remote → Dio / local → Drift)
```

Forbidden:
- `Widget` → `Dio` / `Drift` / `Firebase`
- `Provider` → `Dio` / `Drift` / `Firebase`

Verify with `grep` in CI: no `package:dio` / `package:drift` in
`lib/features/*/presentation/` and `lib/features/*/domain/`.

## Services are contracts (§13, §8)

Feature code depends on interfaces, not vendor SDKs:

- `AnalyticsService` → `AnalyticsTracker` + `NoopAnalyticsTracker`
- `CrashReportingService` → `NoopCrashReportingService` / `CrashlyticsReportingService`
- `FeatureFlagService` → `FeatureFlags` + `StaticFeatureFlags`
- `LoggerService` → `AppLogger` + `ConsoleLogger`
- `StorageService` → `SecureStorage`
- `AuthRepository` → `AuthenticationRepositoryImpl` / `AuthRepositoryFake`

Swap implementations by changing one provider in `service_providers.dart`
or `auth_providers.dart`. No feature code changes.
