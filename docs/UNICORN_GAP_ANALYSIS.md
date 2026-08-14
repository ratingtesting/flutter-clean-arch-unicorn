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
| CrashReportingService | PRESENT (Noop) | `ErrorReporter` + `NoopErrorReporter` |
| FeatureFlagService | PRESENT | `FeatureFlags` + `StaticFeatureFlags` |
| AnalyticsService | PRESENT (Noop) | `AnalyticsTracker` + `NoopAnalyticsTracker` |
| StorageService | PRESENT | `SecureStorage` интерфейс + impl |
| AuthRepository | PRESENT | интерфейс + impl |

## 12. Performance extension (§25)

| Ось | Статус | Комментарий |
|-----|--------|--------------|
| Unicorn | MISSING | Нет `PerformanceMonitor` интерфейса (добавлено в этой работе — см. `lib/services/observability/performance.dart`) |

## 13. Open Source / GitHub Adoption (§31)

| Требование | Статус | Комментарий |
|-----------|--------|--------------|
| LICENSE | PRESENT | MIT-0 (было WRONG — бейдж вёл на несуществующий файл) |
| README optimized | PRESENT | без ложных claims (было WRONG — sqflite/firebase/100%) |
| GitHub Topics | PRESENT | + scalable, vibe-coding, ai-coding, drift |
| PR template | PRESENT | `.github/pull_request_template.md` |
| Issue templates | PARTIAL | есть базовые, не все типы |
| Architecture diagram | MISSING | нет mermaid в README |
| Changelog | PRESENT | `CHANGELOG.md` |
| Docs (GAP/ROADMAP/AI_RULES/PACKAGE/FINAL_AUDIT) | PRESENT | `docs/` |

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
