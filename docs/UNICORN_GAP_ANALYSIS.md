# UNICORN_GAP_ANALYSIS.md

> Честный разрыв между `UNICORN_FOUNDATION_REQUIREMENTS.md` и реальным кодом на `master`.
> Вердикт по каждому требованию: **PRESENT / PARTIAL / MISSING / WRONG**.
> Оценка отдельно по траектории: **VibeCoder / MVP / Scale / Unicorn / Open Source**.

## Легенда

- **PRESENT** — требование полностью выполнено и проверено в коде
- **PARTIAL** — выполнено частично или с оговорками
- **MISSING** — не реализовано
- **WRONG** — в коде/доках есть ложное утверждение (исправлено в этой работе, см. §39)

---

## 1. Clean Architecture (Dependency Rule)

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| VibeCoder | PARTIAL | `domain` не импортирует `data`/`presentation` ✅; но 3 провайдера в `presentation/providers` импортировали datasource напрямую (исправлено в M8 через баррель) |
| MVP | PARTIAL | Repository Law соблюдён; wiring живёт в `presentation/providers` (допустимо, но не идеально) |
| Scale | PARTIAL | Cross-module import разорван (M8), но нет авто-проверки границ CI |
| Unicorn | PARTIAL | Feature boundaries работают; нет линтера на shared/feature границы |
| Open Source | PRESENT | Структура задокументирована в AGENTS.md/ARCHITECTURE.md |

## 2. Riverpod 3 + Notifier (DI)

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| Все | PRESENT | `Notifier`/`AsyncNotifier` везде, `StateNotifier` отсутствует; DI через `ref.watch` |

## 3. GoRouter (declarative)

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| Все | PRESENT | `app_router.dart` declarative; добавлен auth guard (`/dashboard` → `/login`) в M8 |

## 4. Freezed + json_serializable

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| Все | PARTIAL | `Product`, `AuthState` — freezed; `User`, `DashboardState` — ручной Equatable (работает, но не унифицировано) |

## 5. Security by default

| Требование | Статус | Комментарий |
|-----------|--------|--------------|
| No secrets in code | PRESENT | `--dart-define` + `scripts/check_secrets.sh` |
| Encrypted storage | PRESENT | `flutter_secure_storage` (Keychain/EncryptedSharedPreferences) |
| Certificate Pinning | MISSING (optional) | Файла нет; документировано как optional в SECURITY.md (was WRONG — claimed present) |
| App Integrity | MISSING | Play Integrity/App Attest не подключён |
| Network Security Config | PARTIAL | Cleartext заблокирован; XML-конфиг не в шаблоне |

## 6. Observability (Logger/ErrorReporter/Analytics/FeatureFlags)

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| Все | PARTIAL | Интерфейсы + `Noop*` реализации есть (PRESENT как контракты); Firebase/Sentry НЕ в pubspec (было WRONG — claimed firebase) |

## 7. Offline-first (Drift)

| Требование | Статус | Комментарий |
|-----------|--------|--------------|
| Local cache (Drift) | PRESENT | `lib/core/database/` — AppDatabase, typed table, in-memory test DB; cache-then-remote в dashboard репозитории |
| Optimistic UI | PRESENT | `Either<Failure,Success>` в `AuthNotifier` |
| Conflict Resolution / SyncEngine | MISSING | Нет SyncEngine |
| Background Sync | MISSING | `workmanager` не подключён |

## 8. CI/CD

| Требование | Статус | Комментарий |
|-----------|--------|--------------|
| format → analyze → test → build | PRESENT | `.github/workflows/main.yml` (после фикса trigger + build_runner шага — CI green) |
| Coverage gate | MISSING | `flutter test` без `--coverage` gate; coverage не измеряется |
| Deploy (Fastlane) | MISSING | Fastlane не в шаблоне |

## 9. Feature Generator (§8)

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| Все | PRESENT | `tool/new_feature.dart` создаёт feature-first модуль + тесты; generator test есть |

## 10. Package-ready (§21)

| Ось | Статус | Комментариент |
|-----|--------|---------------|
| Unicorn/Scale | PARTIAL | Монорепо; `PACKAGE_EXTRACTION.md` описывает процесс, но модули не вынесены в pub-пакеты |

## 11. Services → Contracts (§13)

| Сервис | Статус | Комментарий |
|--------|--------|--------------|
| LoggerService | PRESENT | `AppLogger` интерфейс + `ConsoleLogger`/`NoopLogger` |
| CrashReportingService | PRESENT | `CrashReportingService` интерфейс + `NoopCrashReportingService`/`CrashlyticsReportingService` (переименован из `ErrorReporter` в v1.5.0, §24) |
| FeatureFlagService | PRESENT | `FeatureFlags` + `StaticFeatureFlags` |
| AnalyticsService | PRESENT (Noop) | `AnalyticsTracker` + `NoopAnalyticsTracker` |
| StorageService | PRESENT | `SecureStorage` интерфейс + impl |
| AuthRepository | PRESENT | интерфейс + impl |

## 12. Performance extension (§25)

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| Unicorn | PRESENT | `PerformanceMonitor` интерфейс + `NoopPerformanceMonitor` (`lib/services/observability/performance.dart`) |

## 13. Open Source / GitHub Adoption (§31)

| Требование | Статус | Комментарий |
|-----------|--------|--------------|
| LICENSE | PRESENT | MIT-0 (было WRONG — бейдж вёл на несуществующий файл) |
| README optimized | PRESENT | без ложных claims (было WRONG — sqflite/firebase/100%) |
| GitHub Topics | PRESENT | + scalable, vibe-coding, ai-coding, drift |
| PR template | PRESENT | `.github/pull_request_template.md` |
| Issue templates | PARTIAL | есть базовые, не все типы |
| Architecture diagram | PRESENT | mermaid diagram в README (§32, ~строка 201) — добавлено в v1.5.0 |
| Changelog | PRESENT | `CHANGELOG.md` |
| Docs (GAP/ROADMAP/AI_RULES/PACKAGE/FINAL_AUDIT) | PRESENT | `docs/` |

## 15. §5 Seven-Role Audit (v1.5.0)

Независимый аудит 7 ролями (architecture/riverpod/database/testing/security/ai-devex/oss-growth) через subagents (agentic-skill-authoring + keelwright Web Guard PASS). Результаты и применённые правки:

| Роль | Находки | Статус после v1.5.0 |
|------|---------|---------------------|
| Architecture | §9/§11/§12/§19 PRESENT; §10 WRONG (domain-модели в shared) | ИСПРАВЛЕНО: `user_model`→`features/authentication/domain`, `product_model`→`features/dashboard/domain`, `globals.dart`→`constants.dart` |
| Riverpod | §14/§7/§17 PRESENT; §15 WRONG (route guard persisted `hasUser()`) | ИСПРАВЛЕНО: `isAuthenticatedProvider` (live `authStateNotifierProvider` + persisted fallback) |
| Database | §16/§26 PRESENT; §20 PARTIAL (remote-first) | ИСПРАВЛЕНО: cache-then-remote в `DashboardDriftRepository` |
| Testing/QA | §28/§29/§37 PRESENT (119 tests) | БЕЗ ИЗМЕНЕНИЙ (green) |
| Security/Prod | §27/§13 PRESENT; §24 PARTIAL (`ErrorReporter`) | ИСПРАВЛЕНО: `CrashReportingService` интерфейс; observability через `AppLogger` (§27) |
| AI-DevEx | §4 PRESENT; §30 PARTIAL (нет Provider/Route creation) | ИСПРАВЛЕНО: `AI_DEVELOPMENT_RULES.md` дополнен |
| OSS-Growth | §31/§32/§33 PRESENT; stale mermaid claim | ИСПРАВЛЕНО: убран stale claim в `OPEN_SOURCE_GROWTH_AUDIT.md` |

**Trade-off §18:** Freezed для `User`/`DashboardState` НЕ применён — Freezed ломал security-контракт (`toJson` должен исключать password/token) и 12 тестов. Оставлен Equatable (работает, 119 tests green).

## 14. Исправленные WRONG (история)

| Было (ложь) | Стало (правда) |
|-------------|----------------|
| sqflite 2.3.0 | Drift 2.34.3 |
| firebase_crashlytics/analytics/remote_config | Noop-интерфейсы (swap when needed) |
| 100% tests / 100/100 | 119 unit tests, coverage не измеряется |
| Certificate Pinning bundled | optional, not bundled |
| Snyk / dependency_validator в CI | `flutter pub outdated` (weekly) |
| Версии v1.3.0 / v1.2.x | v1.4.0 (pubspec + docs + release) |
| structure tree `services/database/` | `lib/core/database/` |

## 15. POST-v1.6 Swarm Audit — P0/P1/P2 (2026-08-14)

Параллельный аудит 6 ролями (Architect, VibeCoder/DX, Scale/Unicorn, QA/CI,
Security, OSS) через delegate_task. Независимая верификация v1.6.0.

### P0 — блокеры (честность / безопасность / границы)
- **P0-1:** `pubspec.yaml` `version: 1.4.0+1` — рассинхрон с v1.6.0/README.
- **P0-2:** `shared/domain/models/models.dart` экспортирует `features/authentication/domain/models/user_model.dart` — утечка границы (CI `check_boundaries.dart` не ловит, сканирует только `features/`).
- **P0-3:** CI анализирует только `lib/` (`flutter analyze --fatal-infos lib/`), не `test/` — docs лгут о `lib/ test/`.
- **P0-4:** env separation DEV/STAGING/PROD читают один `BASE_URL=https://api.example.com` — фейковое разделение.

### P1 — улучшения
- **P1-1:** 4 placeholder-теста `expect(true,isTrue)` завышают счётчик 119.
- **P1-2:** лог-маскировка неполная (URI query / non-Map тела не маскируются).
- **P1-3:** LICENSE MIT-0 → GitHub "Other" (нет бейджа).
- **P1-4:** нет screenshot/GIF запущенного приложения (adoption).
- **P1-5:** README L169 "Current version: 1.5.0" (факт 1.6.0).
- **P1-6:** `FeatureFlags` ≠ `FeatureFlagService` (имя из спец).

### P2 — опционально
- **P2-1:** нет drift migration-теста.
- **P2-2:** coverage gate суммирует generated files.
- **P2-3:** `sqlite3_flutter_libs 0.6.0+eol` — EOL dependency.
- **P2-4:** PACKAGE_EXTRACTION.md "НЕ реализовано" — допустимо для шаблона.

### Что подтверждено (не трогать)
Feature-first, Riverpod 3, GoRouter guard, Repository Law, services-contracts,
Drift, AuthRepositoryFake, widget-тесты, CI coverage gate, 119 tests green.

