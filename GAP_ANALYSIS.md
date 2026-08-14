# GAP_ANALYSIS.md — Честный разрыв между требованиями и реальностью

> Этот документ существует, чтобы **не врать**. Каждый пункт `UNICORN_FOUNDATION_REQUIREMENTS.md`
> проверен против реального кода в этой ветке (v1.0.0). Если что-то помечено DONE — это подтверждено
> чтением файлов, а не верой в документацию.

## Статус по разделам требований

| # | Требование | Статус | Доказательство (файл) |
|---|-----------|--------|----------------------|
| 1 | Clean Architecture (Dependency Rule) | PARTIAL | `domain/` не импортирует data/presentation ✅; но `presentation` импортирует datasource напрямую в 3 файлах (см. M8) |
| 1 | Feature-first модульность | DONE | `lib/features/{auth,dashboard,splash}/{data,domain,presentation}` |
| 1 | Riverpod 3 + Notifier | DONE | `AuthNotifier extends Notifier`, `DashboardNotifier extends Notifier`, `AsyncNotifier` в user_cache |
| 1 | GoRouter (declarative) | DONE | `lib/routes/app_router.dart` — список `GoRoute`, без auto_route |
| 1 | Freezed + json_serializable | PARTIAL | `Product`/`AuthState` — freezed; `User`/`DashboardState` — ручной Equatable (работает, но не унифицировано) |
| 2 | No secrets in code | DONE | `--dart-define` в `main_common`; `scripts/check_secrets.sh` |
| 2 | Certificate Pinning | MISSING (optional) | Файла `certificate_pinning_interceptor.dart` нет в коде; документировано как optional в SECURITY.md |
| 2 | Encrypted Local Storage | DONE | `SecureStorage` → `flutter_secure_storage` (Keychain/EncryptedSharedPreferences) |
| 2 | App Integrity | MISSING | Play Integrity / App Attest не подключены (вне шаблона по умолчанию) |
| 2 | Network Security Config | PARTIAL | Cleartext заблокирован в манифесте; XML-конфиг не в шаблоне |
| 3 | Observability (Logger/ErrorReporter/Analytics/FeatureFlags) | DONE (Noop) | Интерфейсы + `Noop*` реализации; Firebase/Sentry НЕ в pubspec |
| 4 | Offline-first (Drift) | DONE (база) | `lib/core/database/` — Drift `AppDatabase`, typed table, in-memory test DB; cache-then-remote в `dashboard_drift_repository` |
| 4 | SyncEngine / Conflict Resolution | MISSING | Нет `SyncEngine`; Drift используется как локальный кеш продуктов |
| 4 | Background Sync | MISSING | `workmanager` не подключён |
| 5 | CI/CD (analyze/test/format) | DONE | `.github/workflows/main.yml` |
| 5 | Coverage gate | MISSING | `flutter test` без `--coverage` в CI; coverage не измеряется |
| 5 | Deploy (Fastlane) | MISSING | Fastlane не в шаблоне |
| 6 | Doc as Code | DONE | README, ARCHITECTURE, CONTRIBUTING, SECURITY, AGENTS, llms.txt, ADR |
| 8 | Repository Interface (OCP) | DONE | `UserRepository` интерфейс в domain, `UserRepositoryImpl` в data |
| 9 | 100/100 tests (unit + widget) | PARTIAL | 119 unit/provider тестов; **0 widget-тестов** |
| 9 | MIT-0 license | DONE (v1.0.0) | `LICENSE` добавлен (ранее отсутствовал — бейдж врал) |
| 9 | Git tags v1.0.0–v1.3.0 | MISSING | Тегов ещё нет; версия в pubspec `1.0.0+1` |

## Критические несоответствия, исправленные в этой работе

1. **README/ARCHITECTURE врали про sqflite** — в pubspec нет sqflite; заменили на Drift (реально есть).
2. **README/ARCHITECTURE врали про firebase_*** — в pubspec нет firebase; заменили на Noop-интерфейсы.
3. **«100% test coverage» / «100/100 tests»** — неверно; факт: 119 тестов, widget-тестов 0, coverage не измеряется.
4. **«Certificate Pinning» в SECURITY** — файла нет; помечено optional.
5. **LICENSE отсутствовал** — бейдж MIT-0 вёл на несуществующий файл; создан `LICENSE`.
6. **Версии разъехались** — pubspec `1.0.0+1`, README `v1.3.0`, SECURITY `v1.2.x`; выровнено на `1.0.0`.

## Что осталось сделать (M8 — архитектурный закон)

- [ ] Убрать `presentation → data` bypass: 3 файла провайдеров (`auth_repository_providers.dart`, `dashboard_providers.dart`, `user_cache_provider.dart`) не должны импортировать datasource напрямую.
- [ ] Добавить GoRouter auth guard (`redirect` на `/login` для `/dashboard`).
- [ ] Починить shared mutable Dio state (`networkServiceProvider` мутирует `dioProvider` singleton).
- [ ] Разорвать cross-module presentation import (`auth_notifier.dart`, `splash_provider.dart` → `user_cache_service/presentation`).
- [ ] Консолидировать сервис-провайдеры в единый `service_providers.dart`.

## Честный вердикт

Шаблон **production-ready для стартапа на уровне архитектуры и тестов**, но:
- Не «0 violations» (есть presentation→data bypass).
- Не «100% coverage» (нет coverage gate, нет widget-тестов).
- Не содержит Firebase/Certificate Pinning «из коробки» (это осознанный выбор — Noop-интерфейсы, чтобы не тащить тяжёлые зависимости).

Это документировано открыто. Никаких «unicorn-claims» без подтверждения в коде.
