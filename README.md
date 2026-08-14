# 🦄 Flutter Clean Arch Unicorn

> **Clean Architecture · Riverpod 3 · 119 unit tests · v1.4.0**

**The foundation for a startup that will become a unicorn.**

This is not a "hello world" or a "quick prototype". It's a production-ready template engineered so that **you won't have to rewrite your code two years from now**.

---

## Why this template?

### 🟢 Easy
**A new developer is up and running in 3 minutes.**

- `make.bat setup` — install dependencies
- `make.bat run-dev` — launch dev environment
- Feature-first structure: `features/{name}/{data,domain,presentation}` — intuitive navigation
- 119 unit tests verify nothing is broken

### 🔒 Secure
**Secrets never leak into git. Tokens are encrypted.**

- `scripts/check_secrets.sh` — blocks commits with API keys
- `SecureStorage` — tokens stored in iOS Keychain / Android EncryptedSharedPreferences
- `--dart-define` — BASE_URL and keys are build arguments, not hardcoded
- `Either<L,R>` — errors are handled, not thrown as exceptions

### 🛡️ Reliable
**119 unit tests. CI/CD. Monitoring ready.**

- **119 unit tests** — 0 failures
- **GitHub Actions** — format → analyze → test → build in 2 minutes per PR
- `ExceptionHandler` — centralized network error handling (Socket, Dio, timeouts)
- `ErrorReporter` and `Analytics` interfaces — ready for Crashlytics / Sentry (not bundled)

### 💰 Cheap
**One codebase — two platforms. Free CI.**

- **Flutter** — write once, run on iOS and Android. Saves 2x engineering cost
- **GitHub Actions** — free for public repositories
- **Retry interceptor** — fewer redundant requests on network failures (saves bandwidth)
- **Minimal dependencies** — only what you actually need. No bloat

### 📈 Scalable
**Clean Architecture. Branch-ready for 1M+ users.**

- **Clean Architecture** — `domain` layer never imports `data`/`presentation`. Swap DB, API, or UI — business logic stays intact
- **Riverpod 3 (compile-time DI)** — if a provider import is wrong, the code won't compile. Errors caught before deployment
- **3 built-in environments** — dev/staging/prod via `--dart-define`
- **Roadmap to Unicorn** — step-by-step plan: from 0 to 1,000,000 users without rewriting

---

[![MIT-0](https://img.shields.io/badge/License-MIT--0-blue.svg)](LICENSE)

---

## 🤖 AI-Agent Ready

This repo is optimized for AI coding agents (Hermes Agent, Claude Code, Copilot, Cursor, Gemini, Codex, Jules):

| File | Purpose |
|------|---------|
| [`AGENTS.md`](AGENTS.md) | Full agent guide: structure, rules, commands ([agents.md](https://agents.md) standard) |
| [`llms.txt`](llms.txt) | Machine-readable project summary ([llmstxt.org](https://llmstxt.org) standard) |
| [`CLAUDE.md`](CLAUDE.md) / [`GEMINI.md`](GEMINI.md) | Entry points for Claude Code / Gemini CLI |
| [`.github/copilot-instructions.md`](.github/copilot-instructions.md) | GitHub Copilot instructions |
| [`.cursor/rules/`](.cursor/rules/) | Cursor project rules |

Point any agent at this repo — it will understand the architecture, run the tests, and follow the Dependency Rule without extra prompting.

---

## Stack

| Component | Package | Version |
|-----------|---------|---------|
| Framework | Flutter | 3.44.8 |
| State Management | flutter_riverpod | 3.4.1 |
| Navigation | go_router | 16.3.0 |
| Code Generation | freezed | 3.2.5 |
| HTTP Client | dio | 5.11.0 |
| Security | flutter_secure_storage | 10.0.0 |
| Local DB | drift | 2.34.3 |
| Logging | logger | 2.5.0 |
| Observability | Noop interfaces (Logger, ErrorReporter, Analytics, FeatureFlags) | — |

> **Note:** This template ships **Noop implementations** for observability (Crashlytics, Analytics, Remote Config). The interfaces are ready — drop in Firebase (or Sentry) when you need it. No `firebase_*` packages are bundled by default.

## Structure

```
lib/
├── configs/              # Global configs (AppConfigs)
├── features/             # Isolated feature modules
│   ├── authentication/   # data/domain/presentation
│   ├── dashboard/        # data/domain/presentation
│   └── splash/           # Splash screen
├── main/                 # Entry points (dev/staging/prod)
├── routes/               # GoRouter (app_router.dart)
├── services/
│   ├── observability/    # Logger, ErrorReporter, Analytics
│   ├── security/         # SecureStorage, interceptors
│   ├── network/          # Interceptors (retry, auth, logging)
│   └── user_cache_service/ # Local user cache (SharedPreferences + SecureStorage)
├── core/
│   └── database/         # Drift local relational DB (typed tables, migrations)
└── shared/               # Models, theme, exceptions, widgets
```

Each feature is an autonomous module: `data/` (implementations), `domain/` (business logic), `presentation/` (UI + providers).

## Quick Start

```bash
# Windows
make.bat setup       # Install dependencies
make.bat run-dev     # Start dev environment
make.bat check       # Analyze + Test + Format
make.bat build-apk   # Build Android APK

# Unix/Mac
make setup
make run-dev
make check
```

```bash
# Custom API endpoint
flutter run --dart-define=BASE_URL=https://my-api.com
```

## Environments

| Entry point | Purpose |
|-------------|---------|
| `lib/main/main_dev.dart` | Dev build |
| `lib/main/main_staging.dart` | Staging |
| `lib/main/main_prod.dart` | Production |

> Default `flutter run` uses `lib/main.dart` → `mainCommon(AppEnvironment.DEV)`.

## Testing

```bash
flutter test              # all tests (119)
flutter test --coverage   # with coverage
```

Pattern: `ProviderContainer` + `mocktail`, each provider tested in isolation.

## CI/CD

GitHub Actions on every PR:
1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze lib/ test/ --fatal-infos` (0 issues)
4. `flutter test`

## Requirements

- **Flutter SDK** 3.44.8+
- **Android SDK** (platforms/android-34, set `ANDROID_HOME` or `local.properties`)
- **JDK** 17+ (for Android builds)

## Versioning

Semantic tags (`v1.4.0`, `v1.1.0`). Every change is a commit + tag. Current version: **1.0.0**.

---

## 🚀 Roadmap to Unicorn

This template is your **Day 0 foundation**. Scale it as you grow:

| Stage | Users | What to add | Why |
|-------|-------|-------------|-----|
| **Day 0** | 0-100 | ✅ Template as-is | Validate idea, zero cost |
| **Month 1** | 100-1K | Firebase Analytics + Crashlytics | Know what breaks |
| **Month 3** | 1K-10K | Offline-first (Drift/Hive) | Work without internet |
| **Month 6** | 10K-100K | Push Notifications (FCM) | Re-engage users |
| **Year 1** | 100K+ | Feature Flags (Firebase Remote Config) | Ship without deploying |
| **Year 2** | 1M+ | BFF (Backend for Frontend) | Reduce API calls |

**Key principle:** Replace `Noop` implementations in `lib/services/` with real ones when needed. The interfaces are already there.

---

## 📖 Further Reading

- [ARCHITECTURE.md](./ARCHITECTURE.md) — deep dive into the architecture
- [UNICORN_FOUNDATION_REQUIREMENTS.md](./UNICORN_FOUNDATION_REQUIREMENTS.md) — full requirement spec
- [CONTRIBUTING.md](./CONTRIBUTING.md) — how to contribute
- [SECURITY.md](./SECURITY.md) — security policy & threat model
- [docs/adr/](./docs/adr/) — Architecture Decision Records