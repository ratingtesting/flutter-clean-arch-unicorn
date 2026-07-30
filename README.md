# 🦄 Flutter Clean Arch Unicorn

> **Clean Architecture · Riverpod 3 · 100% tests · v1.3.0**

**The foundation for a startup that will become a unicorn.**

This is not a "hello world" or a "quick prototype". It's a production-ready template engineered so that **you won't have to rewrite your code two years from now**.

---

## Why this template?

### 🟢 Easy
**A new developer is up and running in 3 minutes.**

- `make.bat setup` — install dependencies
- `make.bat run-dev` — launch dev environment
- Feature-first structure: `features/{name}/{data,domain,presentation}` — intuitive navigation
- 100 tests verify nothing is broken

### 🔒 Secure
**Secrets never leak into git. Tokens are encrypted.**

- `scripts/check_secrets.sh` — blocks commits with API keys
- `SecureStorage` — tokens stored in iOS Keychain / Android EncryptedSharedPreferences
- `--dart-define` — BASE_URL and keys are build arguments, not hardcoded
- `Either<L,R>` — errors are handled, not thrown as exceptions

### 🛡️ Reliable
**100% test coverage. CI/CD. Monitoring ready.**

- **100/100 unit tests** — zero failures
- **GitHub Actions** — format → analyze → test → build in 2 minutes per PR
- `ExceptionHandler` — centralized network error handling (Socket, Dio, timeouts)
- `ErrorReporter` and `Analytics` interfaces — ready for Crashlytics / Sentry

### 💰 Cheap
**One codebase — two platforms. Free CI.**

- **Flutter** — write once, run on iOS and Android. Saves 2x engineering cost
- **GitHub Actions** — free for public repositories
- **Retry interceptor** — fewer redundant requests on network failures (saves bandwidth)
- **Minimal dependencies** — only what you actually need. No bloat

### 📈 Scalable
**Clean Architecture. Branch-ready for 1M+ users.**

- **Clean Architecture (0 violations)** — `domain` layer never imports `data`/`presentation`. Swap DB, API, or UI — business logic stays intact
- **Riverpod 3 (compile-time DI)** — if a provider import is wrong, the code won't compile. Errors caught before deployment
- **3 built-in environments** — dev/staging/prod via `--dart-define`
- **Roadmap to Unicorn** — step-by-step plan: from 0 to 1,000,000 users without rewriting

---

[![MIT-0](https://img.shields.io/badge/License-MIT--0-blue.svg)](LICENSE)

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
| Observability | firebase_crashlytics, firebase_analytics, firebase_remote_config |
| Local DB | sqflite | 2.3.0 |
| Logging | logger | 2.5.0 |

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
│   ├── security/         # SecureStorage, CertificatePinning
│   ├── network/          # Interceptors (retry, auth, logging)
│   └── database/         # Local SQLite cache
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
| `lib/main.dart` | Development (default) |
| `lib/main/main_dev.dart` | Dev build |
| `lib/main/main_staging.dart` | Staging |
| `lib/main/main_prod.dart` | Production |

## Testing

```bash
flutter test              # all tests
flutter test --coverage   # with coverage
```

Pattern: `ProviderContainer` + `mocktail`, each provider tested in isolation.

## CI/CD

GitHub Actions on every PR:
1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze lib/` (0 errors)
4. `flutter test`

## Requirements

- **Flutter SDK** 3.44.8+
- **Android SDK** (platforms/android-34, set `ANDROID_HOME` or `local.properties`)
- **JDK** 17+ (for Android builds)

## Versioning

Semantic tags (`v1.0.0`, `v1.1.0`). Every change is a commit + tag.

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