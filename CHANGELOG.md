# Changelog

All notable changes to this template are documented in this file.
The format is based on [Conventional Commits](https://www.conventionalcommits.org/)
and semantic versioning.

## [1.7.3] — 2026-08-23 (Docs Sync Completion)

### Changed
- **Test count reconciled to 151 everywhere** (grep-recounted before editing): AGENTS.md ×2, CLAUDE.md, GEMINI.md, `.github/copilot-instructions.md`, `.github/pull_request_template.md`, README MVP table. Historical figures in `docs/` audits and old CHANGELOG entries left untouched (history stays history).
- **`CrashlyticsReportingService` renamed to `ConsoleCrashReportingService`** — the class always was a console logger, not Firebase (the old doc comment referenced a non-existent `firebase_crash_reporting_service.dart`). Behavior unchanged, dependencies unchanged, no external usages existed.
- Version bump `1.7.2+1` → `1.7.3+1`.

### Verification (2026-08-23, full local CI cycle from scratch)
- `build_runner build` → OK
- `dart format --set-exit-if-changed .` → clean
- `flutter analyze --fatal-infos lib/ test/` → **0 issues**
- `dart run tool/check_boundaries.dart` → **0 violations** (79 files)
- `flutter test --coverage` → **151 passed / 0 failed**, coverage gate ≥30% green
- Repo grep: live claims contain no «128», no `CrashlyticsReportingService`

## [1.7.2] — 2026-08-23 (Honesty & Small Fixes Pass)

### Added
- **Secret scan in CI**: `scripts/check_secrets.sh` now runs as a blocking step in GitHub Actions (was manual-only).
- **Token refresh wiring example**: `docs/examples/token_refresh_wiring.md` — how to connect `AuthTokenInterceptor.onTokenRefresh` to a real backend.
- **`make gen` / `make.bat gen` target** — generates freezed/drift code; documented as REQUIRED before analyze/test (without it newcomers saw ~58 false errors).

### Changed
- **Test count reconciled to 151** across README, ARCHITECTURE, CONTRIBUTING, llms.txt, folder_structure, UNICORN_FOUNDATION_REQUIREMENTS (was 128; agent-instruction files CLAUDE/GEMINI/AGENTS/copilot pending approval).
- **R-INFRA package list** extracted to `_infrastructurePackages` constant with guidance to extend it for new infra packages (graphql/realm/etc.).
- **Feature generator now creates the public barrel** `features/<name>/<name>.dart` (required by boundary rule R-FEATURE-1 for cross-feature access); generator test extended.

### Fixed
- **SECURITY.md STRIDE honesty**: removed claims of "rate limiting via Feature Flags" and "biometric" — neither exists in template code (documented as backend/app responsibilities instead).

### Verification (2026-08-23)
- `dart run tool/check_boundaries.dart` → pass (79 files)
- `flutter analyze --fatal-infos lib/ test/` → 0 issues
- Full suite + coverage gate → green

## [1.7.1] — 2026-08-16 (Integrity & Documentation Consistency Pass)

### Fixed
- **LICENSE**: restored `SPDX-License-Identifier: MIT-0` (accidentally dropped after v1.7.0).
- **Dependencies**: removed `sqlite3_flutter_libs: ^0.6.0+eol` (obsolete no-op once on `sqlite3` 3.x); `sqlite3: ^3.5.1` already bundles native libs. Drift + SQLite unchanged.
- **dio**: pubspec constraint bumped to `^5.11.0` to match the resolved version.
- **Test count**: reconciled to **128** across README, ARCHITECTURE, AGENTS, CLAUDE, GEMINI, llms.txt, CONTRIBUTING, UNICORN_FOUNDATION_REQUIREMENTS, `.cursor/rules`, copilot-instructions, PR template, and CHANGELOG (was 100/119/125/128 in various places).
- **ARCHITECTURE.md**: version badge `v1.4.0` → `v1.7.0`; test count 119 → 128; CI steps now match the real workflow (build_runner, boundary check, coverage gate, apk build).
- **SECURITY.md**: corrected false "no `^` pins" claim and interceptor path (`lib/services/network/`); supported-versions table now `v1.7.x`.
- **README.md**: CI time "~7 minutes" (was "2 minutes"); full CI pipeline documented; semantic-tag example fixed.
- **folder_structure.md**: regenerated from the actual `lib/` + `test/` tree.
- Removed dead 1-byte stub `auth_local_data_source.dart`.

### Verified
- `flutter pub get` clean, `flutter analyze lib/ test/ --fatal-infos` 0 issues, `flutter test` 128 passed / 0 failed.

## [1.7.0] — 2026-08-14 (Parallel Swarm Hardening + Test Reality Pass)

### Added
- Parallel read-only audit wave (6 roles: Architect, VibeCoder/DX, Scale/Unicorn, QA/CI, Security, OSS) via subagent swarm.
- `docs/MASTER_HANDOFF.md` — single handoff file for the external Master Architect.
- `docs/KANBAN.md` — parallel-execution backlog.
- `test/core/database/database_test.dart` — Drift schema/migration guard (write/read round-trip).

### Changed
- LICENSE: added `SPDX-License-Identifier: MIT-0` so GitHub recognizes the license.
- CI: coverage gate now excludes generated files (`*.g.dart`, `*.freezed.dart`).
- README: honest Screenshots placeholder (no fabricated images).
- `UNICORN_FINAL_AUDIT.md` + `MASTER_HANDOFF.md`: scores → 9.0 (P0 honesty/security closed).

### Fixed
- P0: pubspec version 1.4.0 → 1.6.0; `shared/domain/models` no longer exports feature models; CI analyzes `lib/ test/`; env separation via `--dart-define` BASE_URL_DEV/STAGING/PROD.
- P1: placeholder tests (`expect(true)`) replaced with real discriminating tests; 3 weak `toString()` tests rewritten to behavioral; log-redaction masks URI query + raw body.

### Verified
- `flutter analyze lib/ test/` clean, `flutter test --coverage` 128 passed, CI green.

## [Unreleased]

### Changed
- **Honesty pass over docs** — removed claims that do not match the code:
  the repo did not use `sqflite` (only `shared_preferences`), had no
  certificate pinning in code, and did not have widget tests or "100% coverage".
  README/ARCHITECTURE/llms.txt now describe the real stack.
  (Corrected in v1.7.0 follow-up: widget tests DO exist — added in 1.6.0 — and
  the coverage gate is now wired in CI at ≥30%.)
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
