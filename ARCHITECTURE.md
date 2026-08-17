# Flutter Clean Arch Unicorn — Architecture

> v1.7.1 | Flutter 3.44.8 | Riverpod 3.4.1 | GoRouter | Freezed 3.2.5

## Who is this for

Solo founders building a startup from scratch.
This template is designed so that **editing and maintaining the project costs less** than using other solutions. Initial investment is higher (architecture, tests, CI), but the cost of future changes is minimal.

---

## Template Requirements

| # | Requirement | Why | Implementation |
|---|-------------|-----|----------------|
| 1 | **Low change cost** | New features / fixes shouldn't be expensive | Feature-first Clean Architecture: each feature is isolated |
| 2 | **Security by default** | Secrets, keys, configs — never in code | `--dart-define`, SecureStorage, interceptors |
| 3 | **Testability** | Tests catch bugs before production | 128 tests (ProviderContainer + mocktail) |
| 4 | **CI/CD out of the box** | Automatic checks on every PR | GitHub Actions: analyze + test + format |
| 5 | **Scalability** | Startup grows → more features, more teams | Feature-first: new feature = new folder |
| 6 | **Observability** | See crashes, analytics, logs in production | Logger, ErrorReporter, Analytics, FeatureFlags (Noop by default) |
| 7 | **Offline-first ready** | Work without internet, sync in background | Drift local DB (typed tables) |
| 8 | **Fast onboarding** | New developer understands in 30 minutes | README, ARCHITECTURE.md, folder_structure.md |

---

## Architecture: Feature-First Clean Architecture

```
lib/
├── configs/                  # Global app configs (AppConfigs)
├── features/                 # Isolated feature modules
│   ├── authentication/       # Example feature
│   │   ├── data/             # Implementations (API, DB, repositories)
│   │   ├── domain/           # Business logic (repository interfaces, use cases)
│   │   └── presentation/     # UI and providers (screens, widgets, Riverpod)
│   ├── dashboard/            # Another feature — same structure
│   └── splash/               # Splash screen
├── main/                     # Entry points (main_dev, main_staging, main_prod)
├── routes/                   # GoRouter configuration
├── services/
│   ├── observability/        # Logger, ErrorReporter, Analytics
│   ├── security/             # SecureStorage, interceptors
│   ├── network/              # Interceptors (retry, auth, logging)
│   └── user_cache_service/   # Local user cache (SharedPreferences + SecureStorage)
├── core/
│   └── database/             # Drift local relational DB (typed tables, migrations)
└── shared/                   # Shared code (models, theme, exceptions, widgets)
```

### Dependency Rule

Dependencies point **inward**:
```
presentation → domain ← data
     ↓            ↑        ↓
  providers    business   repository
  (Riverpod)   logic      (implementations)
```

- **domain** does NOT know about data or presentation
- **data** implements interfaces from domain
- **presentation** uses providers and business models

---

## Observability Services

| Service | Interface | Implementation (prod) | Implementation (dev/test) |
|---------|-----------|----------------------|---------------------------|
| Logging | `AppLogger` | `ConsoleLogger` | `NoopLogger` |
| Crash Reporting | `ErrorReporter` | **NoopErrorReporter** (swap for Crashlytics/Sentry) | `NoopErrorReporter` |
| Analytics | `AnalyticsTracker` | **NoopAnalyticsTracker** (swap for Firebase) | `NoopAnalyticsTracker` |
| Feature Flags | `FeatureFlags` | `StaticFeatureFlags` (swap for Remote Config) | `StaticFeatureFlags` |
| Secure Storage | `SecureStorage` | `SecureStorageImpl` (encrypted) | `SecureStorageFake` |

### Usage

```dart
// In any provider/notifier:
final logger = ref.watch(loggerProvider);
logger.info('User logged in', data: {'userId': user.id});

// Error reporting:
final reporter = ref.watch(errorReporterProvider);
await reporter.recordError(error, stackTrace, reason: 'Login failed');

// Analytics:
final analytics = ref.watch(analyticsProvider);
await analytics.track('purchase_completed', properties: {'amount': 99.99});

// Feature flags:
final flags = ref.watch(featureFlagsProvider);
if (flags.isEnabled('new_checkout_flow')) {
  // show new checkout
}
```

---

## Security

| Component | Protection |
|-----------|------------|
| **Tokens** | `flutter_secure_storage` (iOS Keychain / Android EncryptedSharedPreferences) |
| **API keys** | `--dart-define=API_KEY=...` — never in code |
| **Network** | Retry + auth + logging interceptors; cleartext disabled |
| **Cleartext** | HTTP forbidden (cleartextTrafficPermitted=false) |
| **MITM** | Certificate Pinning — *optional, not bundled* (add `CertificatePinningInterceptor` + Network Security Config when needed) |

---

## Tech Stack

| Component | Package | Version | Purpose |
|-----------|---------|---------|---------|
| Framework | flutter | 3.44.8 | Cross-platform |
| State Management | flutter_riverpod | 3.4.1 | Compile-time safe DI |
| Navigation | go_router | 16.3.0 | Declarative, deep links |
| Code Generation | freezed | 3.2.5 | Immutable models |
| HTTP | dio | 5.11.0 | Network requests |
| Security | flutter_secure_storage | 10.0.0 | Encrypted token storage |
| Observability | Noop interfaces (Logger, ErrorReporter, Analytics, FeatureFlags) | — | Swap for Firebase/Sentry later |
| Local DB | drift | 2.34.3 | Offline cache (typed tables) |
| Logging | logger | 2.5.0 | Structured logging |

---

## Tests

```bash
flutter test                      # all tests (128)
flutter test --coverage           # with coverage
```

### Testing Pattern

```dart
test('should load data', () async {
  final repo = MockRepository();
  final container = ProviderContainer(overrides: [
    repositoryProvider.overrideWithValue(repo),
  ]);
  final notifier = container.read(myProvider.notifier);

  when(() => repo.fetchData()).thenAnswer((_) async => Right(testData));
  await notifier.fetch();

  expect(notifier.state.data, testData);
});
```

---

## CI/CD (GitHub Actions)

On every PR and push to master:
1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs` — generate freezed/drift code
3. `dart format --set-exit-if-changed .` — formatting
4. `flutter analyze --fatal-infos lib/ test/` — static analysis (0 issues)
5. `dart run tool/check_boundaries.dart` — feature-boundary enforcement
6. `flutter test --coverage` — all tests
7. Coverage gate (min 30%, excluding generated files)
8. `flutter build apk --debug` — Android build sanity

Failure blocks the PR. Quality is guaranteed.

---

## Philosophy

> **Invest more time NOW to spend less IN THE FUTURE.**

Clean Architecture, tests, CI — these are not "overhead." They are an investment.
A startup that skimps on architecture pays later — with slow releases, production bugs, and fear of changing code.

This template is a foundation where **every change costs less** because:
- Structure is clear to a new developer in 30 minutes
- Tests catch bugs before production
- CI prevents breaking main
- Adding a feature = creating a folder, not rewriting the system
- Secrets never enter git
- Crashes are visible instantly (Crashlytics)
- A/B tests launch without deployment (Remote Config)

**Growth potential:** from solo project to a team of 5-10 developers — the structure scales without rewriting.

---

## Related Documents

- [UNICORN_FOUNDATION_REQUIREMENTS.md](./UNICORN_FOUNDATION_REQUIREMENTS.md) — full requirements specification
- [docs/adr/](./docs/adr/) — Architecture Decision Records