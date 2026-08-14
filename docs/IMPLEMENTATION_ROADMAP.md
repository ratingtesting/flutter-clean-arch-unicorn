# IMPLEMENTATION_ROADMAP.md

> План реализации Universal Flutter Startup Unicorn Template.
> Статус на 2026-08-14: P0 выполнен (commits `f9d9596`→`5df2f6d`, CI green, release v1.4.0).

## P0 — Фундамент (DONE ✅)

Цель: шаблон собирается, тестируется, честно задокументирован, готов к форку.

- [x] **M1 Честность+безопасность**: redact логов, gate провайдер-логов в prod, persist токена в SecureStorage, CHANGELOG.md
- [x] **M2 Drift** (`lib/core/database/`): AppDatabase, typed table, connection (on-disk + in-memory), dashboard Drift репозиторий (cache-then-remote)
- [x] **M3 Feature generator**: `tool/new_feature.dart` + generator test
- [x] **M4 Docs-честность**: README/ARCHITECTURE/SECURITY/llms.txt/CONTRIBUTING/AGENTS — убраны ложные claims (sqflite→Drift, firebase→Noop, 100%→119, cert-pinning optional, версии 1.0.0)
- [x] **M5 GitHub adoption**: MIT-0 LICENSE, PR template, topics (scalable/vibe-coding/ai-coding/drift), repo description
- [x] **M6 Tests**: Drift/routing/generator тесты + заполнены stub-тесты; 119 green
- [x] **M8 Архитектурный закон**: cross-module import разорван, GoRouter auth guard, shared mutable Dio fixed, service providers консолидированы
- [x] **CI**: workflow trigger на master, build_runner шаг, Gradle 8.14.2 / AGP 8.11.1 / Kotlin 2.2.20 / heap 4g — CI green
- [x] **Docs**: GAP_ANALYSIS, AI_DEVELOPMENT_RULES, PACKAGE_EXTRACTION, FINAL_AUDIT, этот roadmap

## P1 — Scale / Unicorn improvements (TODO)

Цель: заложить extension points без enterprise-раздувания.

- [ ] **PerformanceService** (`lib/services/observability/performance.dart`): интерфейс `PerformanceMonitor` + `NoopPerformanceMonitor`; точки для startup time / FPS / memory / network traces (§25)
- [ ] **ADR**: Performance monitoring extension (docs/adr/)
- [ ] **Авто-проверка границ** (§10/11): `tool/check_boundaries.dart` — lint на `Feature A → Feature B internals` и `shared/` dumping ground; запуск в CI
- [ ] **Coverage gate**: `flutter test --coverage` + lcov threshold в CI (≥80% domain)
- [ ] **Widget tests**: минимум 1 smoke-тест на login/dashboard экраны (сейчас 0)
- [ ] **Architecture diagram** (mermaid) в README
- [ ] **Freezed унификация**: `User`, `DashboardState` → freezed (сейчас Equatable)
- [ ] **Certificate Pinning** (optional): `CertificatePinningInterceptor` + Network Security Config как documented-опция

## P2 — Future (optional, по запросу)

- [ ] **SyncEngine** + conflict resolution (last-write-wins / server-wins)
- [ ] **Background Sync** (`workmanager`)
- [ ] **Package extraction**: вынести `core/`, `services/`, `shared/` в pub-пакеты (см. PACKAGE_EXTRACTION.md)
- [ ] **Fastlane** (match, gym, pilot, deliver) — автоподписание/деплой
- [ ] **Analytics/Crashlytics/Sentry** reference adapters (вместо Noop)
- [ ] **Deep Links**, **Push (FCM)**, **i18n (arb)**, **Accessibility**
- [ ] **Phased rollout** (5%→25%→100%) с crash-метриками

## Trade-offs (принятые)

| Решение | Почему |
|---------|--------|
| Noop-интерфейсы вместо Firebase | не тащить тяжёлые зависимости в шаблон; swap когда нужно |
| Drift вместо sqflite | type-safe, migrations, reactive queries (§16) |
| Mutable Dio переписан на per-provider instance | убрать shared-state баг |
| CI без coverage-gate (пока) | 119 тестов достаточно для старта; gate добавим в P1 |
| Gradle 8.14.2 (не 8.14.0) | 8.14.0 не существует на сервере дистрибутивов |

## Как реализовывать P1/P2

Без дополнительного разрешения (согласно §36):
1. Создать ADR в `docs/adr/`
2. Реализовать контракт + Noop-имплементацию
3. Покрыть тестами
4. `flutter analyze` + `flutter test` green
5. Отдельный commit, push, проверить CI
6. Обновить GAP_ANALYSIS / FINAL_AUDIT
