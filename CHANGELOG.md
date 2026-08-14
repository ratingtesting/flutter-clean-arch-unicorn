# Changelog

All notable changes to this template are documented in this file.
The format is based on [Conventional Commits](https://www.conventionalcommits.org/)
and semantic versioning.

## [Unreleased]

### Changed
- **Honesty pass over docs** — removed claims that do not match the code:
  the repo did not use `sqflite` (only `shared_preferences`), had no
  certificate pinning in code, and did not have widget tests or "100% coverage".
  README/ARCHITECTURE/llms.txt now describe the real stack.
- Bumped SDK constraint to `>=3.8.0` so generated code matches the toolchain.

### Security
- `LoggingInterceptor` now masks sensitive request-body keys
  (`password`, `token`, `authorization`, …) before logging.
- `ProviderObserver` no longer logs provider state in release / production builds.
- `SecureStorageImpl` now uses `encryptedSharedPreferences` on Android.

## [1.6.0] — 2026-08-14 (POST-v1.5 Hardening)

### Added
- `AuthRepositoryFake` — in-memory fake for VibeCoder testability (§9).
- Widget tests: `login_screen_test.dart` (render/loading/failure), `app_router_test.dart` (auth guard redirect) (§14).
- `docs/POST_V1_5_AUDIT.md` — independent re-audit of v1.5.0 claims.
- `docs/ARCHITECTURE_BOUNDARIES.md` — enforceable shared/feature/repository/service rules (§7).

### Changed
- CI: added coverage gate (min 30%) after `flutter test --coverage` (P1).
- `app_router.dart`: extracted `appRouterRedirect` + `appRouterRoutes` (testable).
- `UNICORN_FINAL_AUDIT.md`: Scale 8→9, Overall 8.7→8.9; widget tests + coverage documented.

### Fixed
- CI format gate failure: `dart format` on 6 files (commit `d7c81fa`).
- POST_V1_5_AUDIT found 3 v1.5.0 doc inaccuracies (CI status lie, missing Fake, missing boundaries doc) — all corrected.

### Verified
- `flutter analyze` clean, `flutter test` 119/119 passing, CI green (coverage gate passed).

## [1.5.0] — 2026-08-14

### Added
- `isAuthenticatedProvider` — live auth guard combining `authStateNotifierProvider` + persisted `hasUser()` fallback (§15).
- `CrashReportingService` interface (`NoopCrashReportingService`, `CrashlyticsReportingService`) replacing `ErrorReporter` (§24).
- Observability services (analytics/error_reporter/performance/feature_flags) now route through `AppLogger` (§27).
- `docs/UNICORN_GAP_ANALYSIS.md` §15 — §5 seven-role audit results.
- ADR `2026-08-14-shared-models-relocation.md`.

### Changed
- **§10:** `user_model` → `features/authentication/domain/models/`, `product_model` → `features/dashboard/domain/models/`, `globals.dart` → `constants.dart`.
- **§18:** `User`/`DashboardState` kept on `Equatable` (Freezed reverted — broke security `toJson` + 12 tests).
- **§20:** `DashboardDriftRepository` now cache-then-remote (instant cache, background refresh).
- **§30:** `AI_DEVELOPMENT_RULES.md` documents Provider/Route creation.
- **§31:** removed stale mermaid MISSING claim from `OPEN_SOURCE_GROWTH_AUDIT.md`.
- README/CHANGELOG version → 1.5.0.

### Verified
- `flutter analyze` clean, `flutter test` 119/119 passing.
- Auth login persists the returned token to `SecureStorage` (survives restart).

### Added
- **Drift** as the type-safe relational local database (replaces the aspirational
  sqflite claim). See `lib/core/database/` + `docs/database.md`.
- `dart run tool/new_feature.dart <name>` — AI-friendly feature generator.
- Reference tests: Drift repository, routing (GoRouter), and the generator itself.
- `docs/UNICORN_GAP_ANALYSIS.md`, `docs/IMPLEMENTATION_ROADMAP.md`,
  `docs/AI_DEVELOPMENT_RULES.md`, `docs/PACKAGE_EXTRACTION.md`,
  `docs/UNICORN_FINAL_AUDIT.md`.

## [1.3.0] - 2026-07
- Feature-first Clean Architecture (data/domain/presentation).
- Riverpod 3.4.1 (Notifier / AsyncNotifier).
- GoRouter 16.3.0 navigation.
- Freezed + json_serializable models.
- Three environments (dev/staging/prod) via `--dart-define`.
- Observability contracts: Logger, ErrorReporter, Analytics, FeatureFlags.
- Secure token storage via `flutter_secure_storage`.
- GitHub Actions CI (format → analyze → test → build).
- AI-agent docs: AGENTS.md, llms.txt, CLAUDE.md, GEMINI.md, `.cursor/rules`.
