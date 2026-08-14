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
