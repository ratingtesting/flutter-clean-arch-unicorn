# Integrity Audit V2

> Universal Flutter Startup Unicorn Template
> Репозиторий: https://github.com/ratingtesting/flutter-clean-arch-unicorn
> Дата аудита: 2026-08-16 · Оркестратор: Hermes Agent
> Метод: 6 параллельных read-only аудиторов (A1–A6) + независимая верификация оркестратора на диске (реальные `flutter test` / `flutter analyze`).

---

## Executive Summary

Репозиторий находится в **хорошем функциональном состоянии**: архитектура соответствует заявленной (feature-first Clean Architecture, Repository Law, Riverpod 3, Drift + SQLite, Preferences как отдельное KV-хранилище), сборка и тесты проходят, безопасность на заявленных осях в порядке. **P0 (ломающих сборку/безопасность) дефектов не найдено.**

Главная проблема итерации — **документационный дрейф и несогласованность чисел** после серии версионных подъёмов 1.4→1.7 и роста числа тестов 119→128. Обнаружена одна реальная **P1-регрессия** (коммит после тега v1.7.0 удалил `SPDX-License-Identifier: MIT-0` из LICENSE, который релиз рекламировал как фикс), один мёртвый EOL-пакет (`sqlite3_flutter_libs`) и системное расхождение числа тестов (100/119/125/128 — ни один не совпадает с реальностью **128**, что независимо подтверждено тремя прогонами: A3, A2-статически, и оркестратором).

Итоговый вердикт: **готов к следующей архитектурной итерации после устранения P1 (см. раздел P0/P1).**

---

## Critical Contradictions

| # | Противоречие | Реальность (доказано) | Где в доках |
|---|---|---|---|
| C1 | Число тестов | **128 passed, 0 failures** (оркестратор + A3 + A2) | README/llms/AGENTS «128»; ARCHITECTURE/CONTRIBUTING «119»; CHANGELOG «125»; A5 заявил «130» (ошибочно) |
| C2 | LICENSE SPDX | Строка `SPDX-License-Identifier: MIT-0` **удалена** в `3374060`, хотя v1.7.0 рекламировал её добавление | LICENSE vs CHANGELOG.md:16, b108bd5 |
| C3 | `sqlite3_flutter_libs` | Пакет `0.6.0+eol` **ничего не делает** (pub.dev: EOL после sqlite3 3.x); уже есть `sqlite3: ^3.5.1` | pubspec.yaml:30 |
| C4 | Версия в ARCHITECTURE.md | Реально **1.7.0+1** | ARCHITECTURE.md:3 пишет «v1.4.0» |
| C5 | dio версия | pubspec пин `^5.4.0`, резолв `5.11.0` | README/ARCH/llms пишут `5.11.0`; pubspec `^5.4.0` |
| C6 | CI время | Реальный прогон **~7m3s** | README.md:33 пишет «2 minutes per PR» |

---

## Documentation Drift

- **ARCHITECTURE.md** отстаёт сильнее всего: шапка `v1.4.0` (C4), таблица требований «119 tests» (C1), раздел Tests «119», CI описан как «analyze lib/» (без `test/`, без boundary-check, без apk-build).
- **folder_structure.md** — сильно устарел: ссылается на несуществующие/переименованные пути (`atuhentication_repository_impl.dart` опечатка, `domain/providers/login_provider.dart` → реально `presentation/providers/`, `routes/app_route.dart`+`.gr.dart` → реально `app_router.dart`, `services/other_service` не существует, `shared/domain/models/product|user` перенесены в features в 1.5.0, `globals.dart` удалён в 1.5.0). Диаграммы README/ARCHITECTURE актуальны — сам `folder_structure.md` избыточен.
- **SECURITY.md** содержит 2 ложных факта: (a) «Pin versions in pubspec.yaml (no `^` or `any`)» — на деле все зависимости используют `^`; (b) путь интерцепторов указан как `lib/services/security/interceptors/`, реально `lib/services/network/`. Поддерживаемые версии перечисляют только `v1.0.x` при проекте 1.7.0.
- **CONTRIBUTING.md / UNICORN_FOUNDATION_REQUIREMENTS.md** — «119 tests» / «0 widget tests» (реально 128, из них 2 widget-теста), примеры тегов `v1.4.0`/`v1.1.0` неактуальны.
- `.cursor/rules/project.mdc` и `.github/copilot-instructions.md` — «100 tests» (C1).
- CHANGELOG `[Unreleased]` ложно утверждает, что репо «did not have widget tests» — они добавлены в 1.6.0 и существуют.
- CHANGELOG `[1.7.0]` «125 passed» противоречит 128.

---

## Architecture Drift

**Отсутствует.** Архитектура на диске соответствует заявленной (A1, подтверждено оркестратором):
- feature-first: `lib/features/{authentication,dashboard,splash}` с `data/domain/presentation` ✅
- Repository Law: `dart run tool/check_boundaries.dart` → «Boundary check passed» ✅
- Presentation purity: 0 импортов `dio`/`drift`/`firebase` в presentation ✅
- Drift-only локальная БД: `lib/core/database/database.dart` (`@DriftDatabase`, `schemaVersion:1`, `MigrationStrategy`) ✅
- Preferences отдельно: токен → `SecureStorage` (auth_remote_data_source.dart:32), user → `SharedPreferences` (user_local_data_source.dart) ✅
- Нет Hive/sqflite в коде и pubspec ✅
- Auth: login/register/logout/session/route-guard/token-persistence/mock+prod абстракция — все на месте ✅

**Единственные архитектурные замечания (P2, не дрейф):**
- Пустой стаб `lib/features/authentication/data/datasource/auth_local_data_source.dart` (1 байт, не импортируется) — кандидат на удаление.
- `User` кэш в SharedPreferences, а не в Drift (документированная KV-оговорка, не противоречие).

---

## Test/CI Drift

- **Число тестов** неверно во всех доках (C1). Реально **128 passed / 0 failed** (38 файлов, 124 unit + 4 widget).
- `flutter analyze lib/ test/ --fatal-infos` → **0 issues** (анализ чист, без `ignore_for_file`, скрывающего ошибки).
- CI описан неполно: README пишет «format → analyze → test → build», реальный `.github/workflows/main.yml` = `pub get` → `build_runner` → `dart format` → `flutter analyze --fatal-infos` → `check_boundaries.dart` → `flutter test --coverage` → coverage-gate (≥30%) → `flutter build apk --debug`.
- «CI в 2 минуты» (README:33) — **не подтверждено**, реальный прогон ~7m3s (P1).
- Coverage-гейт настроен, но **грубый**: комментарий утверждает исключение `*.g.dart`/`*.freezed.dart`, а `PCT = HIT*100/TOTAL` считает ВСЕ строки включая сгенерированные. Никакой «100% coverage» в маркетинге нет (удалено в предыдущей honesty-pass).
- Integration-тестов нет (`integration_test/` отсутствует) — не заявлено как обязательное, P2.

---

## Version/Release Drift

- **Версия 1.7.0 согласована**: pubspec `1.7.0+1`, CHANGELOG верх, README, тег `v1.7.0`, GitHub Release — все совпадают.
- **HEAD на 1 коммит впереди тега**: `git describe` = `v1.7.0-1-g3374060`. Коммит `3374060` («Docs/metadata sync ... 128 tests, GitHub description») не покрыт тегом/релизом, нарушая собственное правило репо «Every change is a commit + tag» (README:169).
- **LICENSE-регрессия (P1)**: `git diff b108bd5 HEAD -- LICENSE` показывает, что `3374060` удалил `SPDX-License-Identifier: MIT-0`.
- Локальные теги неполны vs remote (отсутствуют v1.3.0/1.3.1/1.4.0) — не дефект репо, `git fetch --tags`.

---

## Open Source Positioning Problems

- Репозиторий, имя, описание (About), топики (20) — сильные, не спамные, хорошее SEO-покрытие.
- Описание About содержит фактическую ошибку «128 tests» → после сверки остаётся 128 (верно), но A5 ошибочно предложил 130 — **канон 128**.
- «production-ready» (hype, без доказательств деплоя) и «1M+ users» (в roadmap) — низкая P2-гипербола; допустимо как аспирационное, но лучше смягчить.
- README: блок «кому это» и быстрый старт ниже сгиба — минор.
- Mermaid-диаграмма README имплицирует `AUTH --> DASH` (feature→feature), что противоречит «Feature A never imports Feature B internals» — перелабелить в «public API only» или убрать.

---

## Security Problems

**P0/P1 отсутствуют (A6: PASS).** Проверено:
- SecureStorage присутствует и используется для токенов (`flutter_secure_storage`) ✅
- Нет `print`/`debugPrint` в бизнес-логике (весь лог через `AppLogger`/`ConsoleLogger`) ✅
- Токены/пароли/секреты не пишутся в логи ✅
- Нет реальных секретов в git (`git ls-files | grep secret|env` → только `check_secrets.sh`, который чист) ✅
- Нет утечки вендор-SDK в features (Firebase только за контрактами, Noop по умолчанию) ✅
- Редакция логов есть (`lib/services/network/logging_interceptor.dart` маскирует token/secret/password/apikey) ✅

**P2 (полировка, не блокирует):**
- `check_secrets.sh` заявлен как pre-commit hook, но хук не установлен (нет `.git/hooks/pre-commit`); не в CI/Makefile.
- Сканер не ловит `.env` по имени файла.
- `AppLogger.log(message, data:)` не редактирует чувствительные ключи в `data`-мапах (редактирует только `LoggingInterceptor`).

---

## P0

Нет.

## P1 (исправить в этой итерации)

| ID | Находка | Файлы | Действие |
|----|---------|-------|----------|
| P1-1 | LICENSE удалён `SPDX-License-Identifier: MIT-0` | LICENSE | Вернуть строку как первую |
| P1-2 | `sqlite3_flutter_libs: ^0.6.0+eol` мёртвый EOL | pubspec.yaml | Удалить (sqlite3 3.x уже включает нативные либы) |
| P1-3 | Число тестов неверно везде (100/119/125/128) | README, ARCHITECTURE, AGENTS, CLAUDE, GEMINI, llms.txt, CONTRIBUTING, .cursor/rules, copilot-instructions, CHANGELOG, PR-template | Привести к канону **128** (+ GitHub About) |
| P1-4 | ARCHITECTURE.md шапка `v1.4.0` | ARCHITECTURE.md | → `v1.7.0` |
| P1-5 | dio `5.11.0` в docs vs `^5.4.0` в pubspec | README/ARCH/llms + pubspec | Поднять пин до `^5.11.0` (резолв уже 5.11.0) |
| P1-6 | CI «2 minutes» | README.md | → честно «~7 min» |
| P1-7 | `folder_structure.md` сильно устарел | folder_structure.md | Перегенерировать из реального `lib/` или удалить |
| P1-8 | SECURITY.md ложь «no ^» + неверный путь интерцепторов | SECURITY.md | Исправить факты |
| P1-9 | HEAD впереди тега v1.7.0 без покрытия | repo state | После правок: коммит + тег v1.7.1 (или fold в след. релиз) |

## P2 (опционально)

| ID | Находка | Действие |
|----|---------|----------|
| P2-1 | Стаб `auth_local_data_source.dart` (1 байт) | Удалить |
| P2-2 | CHANGELOG `[Unreleased]` ложно про widget-тесты | Исправить |
| P2-3 | CI coverage-гейт не исключает generated | Починить формулу или поднять порог |
| P2-4 | Нет integration_test | Добавить smoke-тест (если заявлено production-ready) |
| P2-5 | SECURITY.md supported-versions только v1.0.x | Добавить v1.7.x |
| P2-6 | README Mermaid `AUTH-->DASH` | Перелабелить/убрать |
| P2-7 | «1M+ users» / «production-ready» hype | Смягчить |
| P2-8 | User-кэш в SharedPreferences, а не Drift | Подтвердить намерение (документировано) |
| P2-9 | Секрет-хук не подключён в CI | Добавить шаг CI |
| P2-10 | AppLogger не редактирует data-мапы | Централизовать редакцию |

---

## Recommended Corrections

1. **Восстановить LICENSE SPDX** (P1-1) — блочит корректное определение лицензии GitHub.
2. **Удалить `sqlite3_flutter_libs`** (P1-2) — самое безопасное изменение БД-зависимости; не меняет архитектуру.
3. **Сделать 128 единственным каноном тестов** (P1-3) во всех файлах + GitHub About.
4. **Синхронизировать версии** (P1-4/5): ARCHITECTURE → v1.7.0; dio пин → `^5.11.0`.
5. **Честно описать CI** (P1-6): ~7 min, полный пайплайн.
6. **Перегенерировать/удалить folder_structure.md** (P1-7).
7. **Исправить SECURITY.md** (P1-8).
8. После правок: `flutter pub get` → `flutter analyze` → `flutter test` → `flutter build apk --debug` → **коммит + тег v1.7.1** (P1-9).

Все изменения — документация + 2 строки pubspec + 1 строка LICENSE + удаление мёртвого файла. **Архитектура не меняется.**
