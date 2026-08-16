# UNICORN STARTUP FOUNDATION TEMPLATE — REQUIREMENTS

## Philosophy
> Invest in architecture **NOW** → cost of changes **IN THE FUTURE** is minimal.
> This template is not "starter code." It's a **contract with the future**: any feature can be added without refactoring the foundation.

---

## 1. ARCHITECTURAL HARD CONSTRAINTS

| Requirement | Acceptance Criteria | Why for a Unicorn |
|-------------|-------------------|-------------------|
| **Clean Architecture** (Dependency Rule) | `graphify query "violation"` → 0 | Business logic doesn't know about Flutter, Dio, or SharedPreferences. Changing DB/API/UI is a local change. |
| **Feature-first modularity** | Each feature: `data/domain/presentation` isolated | Teams work in parallel without conflicts. New feature = new folder, touching nothing else. |
| **Riverpod 3 + Notifier** | No `StateNotifier`, only `Notifier`/`AsyncNotifier` | Compile-time safety, no `state =`, clean `state = newState`. Testable without providers. |
| **GoRouter (declarative)** | No `auto_route` | Routes are data, not code. Deeplinks, redirects, guards in one place. |
| **Freezed + json_serializable** | All DTOs/State immutable, `fromJson`/`toJson` generated | No manual parsing. Adding a field = 1 line in model + `build_runner`. |

---

## 2. SECURITY BY DEFAULT

| Requirement | Implementation | Why |
|-------------|---------------|-----|
| **No secrets in code** | `--dart-define` only, CI secrets in GitHub Secrets | Key leaks = startup death. |
| **Encrypted Local Storage** | `flutter_secure_storage` for tokens, biometric auth | Tokens in SharedPreferences = instant compromise. |
| **App Integrity** | Play Integrity / App Attest | Binary tampering / root detection. |
| **Network Security Config** | Android `network_security_config.xml` | Cleartext traffic forbidden at OS level. |
| **Certificate Pinning** | *Optional* — Dio interceptor with SHA-256 fingerprints (not bundled; add when backend requires) | MITM on public Wi-Fi is attack vector #1. |

---

## 3. OBSERVABILITY — "Don't fly blind"

| Layer | Tool | Template Abstraction |
|-------|------|---------------------|
| **Logging** | `logger` package | `AppLogger` interface → `ConsoleLogger` / `SentryLogger` / `DatadogLogger` |
| **Crash Reporting** | Sentry / Firebase Crashlytics | `ErrorReporter` interface, initialized in `main_<env>.dart` |
| **Analytics** | Amplitude / Mixpanel / PostHog | `AnalyticsTracker` interface, `track(event, props)` |
| **Performance** | Firebase Performance / custom | `PerformanceMonitor` — trace network calls, renders |
| **Feature Flags** | Firebase Remote Config / LaunchDarkly | `FeatureFlags` provider, `bool isEnabled('new_checkout')` |

---

## 4. OFFLINE-FIRST & SYNC

| Capability | Implementation |
|------------|---------------|
| **Local cache** | Drift (SQLite) — repository writes locally, then syncs |
| **Optimistic UI** | State updates immediately, background `Either<Failure, Success>` |
| **Conflict Resolution** | `last-write-wins` / server-wins / merge strategies in `SyncEngine` |
| **Background Sync** | `workmanager` / `flutter_background_service` — periodic sync |

---

## 5. CI/CD — "Green master = ready to release"

| Stage | Command | Gate |
|-------|---------|------|
| **Analyze** | `flutter analyze --fatal-infos` | 0 errors, 0 warnings (strict) |
| **Format** | `dart format --set-exit-if-changed .` | No diff |
| **Test** | `flutter test` | All 128 tests pass (coverage gate ≥30% in CI) |
| **Build** | `flutter build apk --release` / `flutter build ios --release` | Artifacts built |
| **Security** | `flutter pub outdated` (weekly) | No critical CVEs |
| **Deploy** | Fastlane → Play Console / TestFlight / Firebase App Distribution | Manual approve for PROD |

---

## 6. DEPLOY & RELEASES

| Artifact | Automation |
|----------|------------|
| **Versioning** | `semver` from git tags (`v1.2.3`), `build_number` = CI run number |
| **Changelog** | `conventional-commits` → `auto-changelog` |
| **Code Signing** | Fastlane `match` (iOS), `keystore` in CI secrets (Android) |
| **Rollout** | Phased (5% → 25% → 100%) with crash metrics |

---

## 7. EXTENSIBILITY WITHOUT REFACTORING (Open/Closed)

| Pattern | Where Applied |
|---------|---------------|
| **Repository Interface** | Domain defines `UserRepository`, Data provides `UserRepositoryImpl(Supabase)` / `UserRepositoryImpl(GraphQL)` |
| **Strategy** | `PaymentStrategy` — Stripe/ApplePay/GooglePay added without changing `CheckoutUseCase` |
| **Plugin Architecture** | `AnalyticsTracker` — new provider = implement interface + register in `main.dart` |
| **Middleware Pipeline** | Dio interceptors: auth → logging → retry → pinning — each independent |

---

## 8. DOCUMENTATION AS CODE

| File | Purpose |
|------|---------|
| `README.md` | Quickstart, structure, commands, CI, troubleshooting |
| `ARCHITECTURE.md` | Dependency Rule, layers, boundaries, how to add a feature |
| `CONTRIBUTING.md` | Git flow, commit convention, PR checklist |
| `SECURITY.md` | Threat model, secrets, incident response |
| `docs/adr/` | Architecture Decision Records (one per decision) |
| `AGENTS.md` | Guide for AI coding agents |
| `llms.txt` | Machine-readable project description for LLMs |

---

## 9. WHAT IS ALREADY IN V1 (DONE ✅)

- [x] Clean Architecture (data/domain/presentation) — domain layer clean (data/presentation NOT imported by domain)
- [x] Riverpod 3.4.1 + Notifier + AsyncNotifier
- [x] GoRouter 16.3.0
- [x] Freezed 3.2.5 + json_serializable
- [x] Either<T, R> for functional error handling
- [x] Dio network layer with `NetworkService` abstraction
- [x] Feature-first structure: `auth`, `dashboard`, `splash`
- [x] Environment entrypoints: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`
- [x] 128 tests passing (unit + provider + 2 widget tests)
- [x] `flutter analyze` = 0 issues (with `--fatal-infos`)
- [x] GitHub Actions workflow (analyze, test, format)
- [x] README.md + ARCHITECTURE.md + CONTRIBUTING.md
- [x] AGENTS.md — AI coding agent guide
- [x] llms.txt — LLM-friendly project description
- [x] check_secrets.sh — pre-commit secret guard
- [x] make.bat + Makefile — quick setup
- [x] SECURITY.md with threat model
- [x] Drift local relational DB (`lib/core/database/`) + in-memory test DB

### Known gaps (honest status)
- [ ] **Clean Architecture 0 violations**: presentation still imports datasources directly in 3 provider files (see `GAP_ANALYSIS.md`, M8)
- [ ] **Certificate Pinning**: NOT bundled (interceptor absent; documented as optional in SECURITY.md)
- [ ] **Widget tests**: 0 — only unit/provider tests
- [ ] **Coverage gate**: configured in CI (≥30% lines; excludes generated files)
- [ ] **MIT-0 LICENSE file**: added in v1.4.0 (see `GAP_ANALYSIS.md`)
- [ ] **Git tags**: none pushed yet at v1.4.0

---

## 10. BACKLOG FOR THE UNICORN

### 🔴 Critical (Not production without these)
- [ ] **Certificate Pinning** (Dio interceptor)
- [ ] **Error Reporter** abstraction + Sentry/Crashlytics implementation
- [ ] **Logger** abstraction + console/production implementations
- [ ] **Network Security Config** (Android XML)

### 🟡 High (Team growth / scale)
- [ ] **Analytics Tracker** abstraction + Amplitude/PostHog
- [ ] **Feature Flags** (Remote Config)
- [ ] **Offline-first** local DB (Drift/ObjectBox) + SyncEngine
- [ ] **Deep Links** handling in GoRouter
- [ ] **Push Notifications** (FCM) abstraction
- [ ] **i18n** (arb files, `intl` generation)
- [ ] **Accessibility** (semantics, contrast, scaling)

### 🟢 Medium (Quality of life)
- [ ] **Fastlane** config (match, gym, pilot, deliver)
- [ ] **Coverage thresholds** in CI (lcov + genhtml)
- [ ] **Dependency Validator** (ban dev_dependencies in prod code)
- [ ] **Performance Monitoring** (Firebase Performance / custom traces)
- [ ] **ADR** template and first records (why Riverpod, why GoRouter, why Freezed)

---

## 11. TEMPLATE SUCCESS METRICS

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Time to First Feature** | < 30 min | Newcomer adds "Hello Feature" (CRUD) |
| **Time to Prod Build** | < 15 min | `flutter build apk --release` on clean CI |
| **New Dev Onboarding** | < 2 hours | Reads README + ARCHITECTURE → pushes a feature |
| **Refactor Cost** | O(1) per feature | Changing API / DB / UI doesn't touch domain |
| **Test Feedback Loop** | < 60 sec | `flutter test` on a laptop |

---

## 12. DECISION FRAMEWORK

When "you want to do it differently" — checklist:

1. **Does it violate the Dependency Rule?** → NO (hard stop)
2. **Does it increase Time-to-First-Feature for the next team?** → NO
3. **Can it be rolled back in 1 commit?** → YES (feature flag / interface swap)
4. **Is there an ADR?** → If the decision is non-obvious, write an ADR

---

*This document is alive. Every architectural decision is recorded in `docs/adr/YYYY-MM-DD-<slug>.md`.*