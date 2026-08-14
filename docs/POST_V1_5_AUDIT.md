# POST_v1.5 AUDIT (Parallel Swarm Refresh — v1.6.0)

> Независимая верификация v1.5.0/v1.6.0 claims через 6 параллельных read-only
> аудиторов (Architect, VibeCoder/DX, Scale/Unicorn, QA/CI, Security, OSS).
> Каждый аудитор только читал код (delegate_task, leaf role). Синтез — Hermes.

## Методология
- 6 субагентов, параллельно, read-only (без правок).
- Проверка claims из `UNICORN_FINAL_AUDIT.md` / `UNICORN_GAP_ANALYSIS.md` против `lib/`, `test/`, `.github/`, `pubspec.yaml`.
- Не доверять чекбоксам слепо.

## Синтез находок (P0 / P1 / P2)

### P0 — блокеры (честность / безопасность / закон границ)
| № | Находка | Док- claim | Реальность | Источник |
|---|---------|-----------|-----------|----------|
| P0-1 | `pubspec.yaml version: 1.4.0+1` | v1.6.0 / README v1.6.0 | рассинхрон | VibeCoder |
| P0-2 | `shared/domain/models/models.dart` экспортирует `features/authentication/domain/models/user_model.dart` | "shared только примитивы" (FINAL_AUDIT §29) | утечка границы, CI `check_boundaries.dart` не ловит (сканирует только features) | Architect |
| P0-3 | CI `flutter analyze --fatal-infos lib/` (НЕ `test/`) | docs say `flutter analyze lib/ test/` | test/ не анализируется в CI | QA |
| P0-4 | env separation DEV/STAGING/PROD читают один `BASE_URL` (placeholder) | "environments dev/staging/prod" | фейковое разделение | Security/Scale |

### P1 — улучшения
| № | Находка | Серьёзность | Источник |
|---|---------|-----------|----------|
| P1-1 | 4 placeholder-теста `expect(true,isTrue)` (credential_separation ×3, auth_local_datasource ×1) завышают счётчик | MEDIUM | QA |
| P1-2 | Лог-маскировка неполная: URI query-параметры и non-Map тела не маскируются | MEDIUM | Security |
| P1-3 | LICENSE MIT-0 распознаётся GitHub как "Other" (нет бейджа) | MEDIUM | OSS |
| P1-4 | Нет screenshot/GIF запущенного приложения | HIGH (adoption) | OSS |
| P1-5 | README L169 "Current version: 1.5.0" (факт 1.6.0) | LOW | OSS |
| P1-6 | `FeatureFlags` ≠ `FeatureFlagService` (имя из спец) | LOW | Scale |

### P2 — опционально
| № | Находка | Источник |
|---|---------|----------|
| P2-1 | Нет drift migration-теста | QA |
| P2-2 | coverage gate суммирует generated files (порог легко достижим) | QA |
| P2-3 | `sqlite3_flutter_libs 0.6.0+eol` — EOL dep | Security |
| P2-4 | PACKAGE_EXTRACTION.md честно "НЕ реализовано" — OK для шаблона | Scale |

## Что подтверждено (CORRECT — не трогать)
- Feature-first, Riverpod 3 (нет StateNotifier), GoRouter auth guard, Repository Law (dio/drift вне presentation/domain), services-as-contracts, Drift в core/database, AuthRepositoryFake, widget-тесты (login/router), CI coverage gate, 119 tests green (локально).

## Архитектурные решения (стабильны — НЕ менять)
- Equatable для User/DashboardState (не Freezed) — security toJson + 119 tests.
- cache-then-remote Drift паттерн.
- CrashReportingService контракты (не Firebase напрямую).

## Следующий шаг
Master Architect определяет направление. Оркестратор исправил P0 (version sync, shared leak, CI test/ analyze, env honesty) и P1 (placeholder-тесты, log redaction, LICENSE, screenshot) в рамках этого итерации, где безопасно.
