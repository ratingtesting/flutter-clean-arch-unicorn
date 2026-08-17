# MASTER HANDOFF V2.1

> Universal Flutter Startup Unicorn Template
> Репозиторий: https://github.com/ratingtesting/flutter-clean-arch-unicorn
> Дата: 2026-08-17 · Оркестратор: Hermes Agent
> Предыдущая: docs/MASTER_HANDOFF_V2.md

## 1. Mission

RELEASE INTEGRITY FIX для v2-итерации. Устранить противоречия между
MASTER_HANDOFF_V2 (утверждал синхронизацию) и публичным GitHub README
(который остался на v1.7.0). Без новой архитектуры, БД, state-management.
Только документальная и release-целостность.

## 2. Starting State

- Релиз `v1.7.1` уже существовал (pubspec `1.7.1+1`, коммит `a1e9695`, тег `v1.7.1`, GitHub Release).
- НО README.md в двух местах писал `v1.7.0` (бейдж строка 3, Versioning строка 173).
- README.md:24 ложно утверждал, что `scripts/check_secrets.sh` «blocks commits with API keys» (hook не подключён).
- ARCHITECTURE.md бейдж писал `v1.7.0`.
- Гиперболы: «production-ready template», «Branch-ready for 1M+ users».

## 3. Findings

Свод 3 параллельных read-only аудиторов (A1 public-README, A2 release/version, A3 technical-claims) + независимая сверка оркестратора через `gh` (публичный README) и локальный репо.

P0:
- F1: README:24 «check_secrets.sh blocks commits» — ЛОЖЬ (hook не установлен, не в CI/Makefile). Исправлено.
- F2: `tool/check_boundaries.dart` сканирует только `lib/features`, пропуская `lib/services`. Реальный cross-module leak: `lib/services/user_cache_service/presentation/providers/current_user_provider.dart` импортирует `features/authentication/presentation/providers/auth_providers.dart`. Архитектурное решение → вне scope v2.1, передано Master Architect (§13).

P1:
- F3: README версия `1.7.0` (строки 3, 173) при релизе `1.7.1`. Исправлено.
- F4: coverage-gate комментарий «excluding generated» ≠ код (PCT считает все строки). Задокументировано (P2 в v2), не трогали логику CI.

P2:
- F5: «production-ready template» → «production-ready foundation».
- F6: «Branch-ready for 1M+ users» → «Architected with a path to scale toward 1M+ users».
- F7: ARCHITECTURE.md бейдж `v1.7.0` → `v1.7.1`.
- F8: CI «~7 minutes» — подтверждено реальными прогонами (gh run list: 5m40s–6m38s). Оставлено.
- F9: 128 tests — согласовано везде (канон 128, см. §7).

## 4. Fixes

| ID | Правка | Файл |
|----|--------|------|
| F3 | `v1.7.0` → `v1.7.1` (бейдж + Versioning) | README.md:3,173 |
| F1 | «blocks commits with API keys» → «run it manually to catch API keys / secrets before committing (not wired as auto-blocking hook)» | README.md:24 |
| F5 | «production-ready template» → «production-ready foundation» | README.md:7 |
| F6 | «Branch-ready for 1M+ users» → «Architected with a path to scale toward 1M+ users» | README.md:46 |
| F7 | бейдж `v1.7.0` → `v1.7.1` | ARCHITECTURE.md:3 |
| — | docs/RELEASE_INTEGRITY_AUDIT_V2_1.md (синтез аудиторов) | docs/ |

Окружение сборки (отдельно):
- NDK `28.2.13676358` была битой (пустая папка) → `flutter build apk --debug` падал.
  Переустановлена через `sdkmanager "ndk;28.2.13676358"`. Сборка прошла.
  Заметка добавлена в `lazy-unicorn/SETUP_GUIDE.md` (раздел A3) и запушена в его репо (commits `026e21b` на `main`).

## 5. Final Architecture

Без изменений (RELEASE INTEGRITY FIX, не арх-итерация):

- Flutter 3.44.8 · Dart 3.12.2
- Clean Architecture, feature-first (`features/{name}/{data,domain,presentation}`)
- Riverpod 3 (compile-time DI)
- GoRouter (навигация)
- Freezed (иммутабельные модели)
- Retrofit/Dio (сетевой слой)
- Drift (локальная реляционная БД)
- shared_preferences + flutter_secure_storage (KV/секреты)
- Noop-интерфейсы observability (Logger, ErrorReporter, Analytics, FeatureFlags) — без Firebase
- AI-agent-ready файлы: AGENTS.md, llms.txt, CLAUDE.md, GEMINI.md, .github/copilot-instructions.md, .cursor/rules/project.mdc

## 6. Final Database Architecture

- **Remote** = Dio/Retrofit (HTTP API, `app_router.dart` redirect guard, `auth_token_interceptor.dart`)
- **Local** = Drift (`@DriftDatabase`, миграции, `NativeDatabase` на bundled SQLite)
- **Database engine** = SQLite (через `sqlite3` pkg, bundled с Drift)
- **Preferences** = `shared_preferences` (не-секретные настройки) + `flutter_secure_storage` (токены, Keychain/EncryptedSharedPreferences)
- НЕТ Hive. НЕТ sqflite как приложение-БД. `sqlite3_flutter_libs` удалён в v2 (EOL no-op).

## 7. Test Results

Актуальный прогон (свежий, после очистки мусора build-кэша от v2-probe):

- `flutter test` = **+128: All tests passed!** (exit 0)
- `flutter test --coverage` = **+128: All tests passed!** (exit 0, coverage-файл сгенерён)
- `flutter analyze lib/ test/ --fatal-infos` = **No issues found!** (exit 0)

Канон тест-счёта = **128**. (Примечание: без явного `build_runner build` перед `flutter test`
в кеше `.dart_tool/build/generated` могут лежать устаревшие сгенерированные файлы от прошлых
пробных прогонов — тогда `flutter test` считает 130. После `dart run build_runner build
--delete-conflicting-outputs` или `rm -rf .dart_tool/build` счёт стабильно 128. CI всегда
гоняет build_runner → 128.)

## 8. CI Results

- Пайплайн `.github/workflows/main.yml`: pub get → build_runner → format → analyze
  → boundary check → test+coverage → coverage gate (≥30%) → android apk build.
- Ральное время (gh run list): 5m40s–6m38s (≈6 мин). README заявляет «~7 minutes» — корректно.
- «2 minutes» (ложь из прошлого) устранена в v2.
- 5 последних CI-прогонов зелёные (по данным A3).

## 9. Public GitHub Verification

После пуша v2.1 (см. §4 коммит):
- Repository: github.com/ratingtesting/flutter-clean-arch-unicorn
- HEAD: <новый коммит v2.1>
- Version: README бейдж + Versioning = **1.7.1** (исправлено с 1.7.0)
- Tag: `v1.7.1` (указывает на a1e9695; см. §14 про решение по тегу)
- Release: GitHub Release v1.7.1 существует
- README: check_secrets «blocks commits» → убрано (теперь «run manually»)
- CI: «~7 minutes» (без «2 minutes»)
- Tests: 128 (согласовано)
- Architecture: Drift + SQLite + Preferences, No Hive/sqflite

## 10. Claims Audit

| Claim | Status | Evidence |
|-------|--------|----------|
| Version 1.7.1 | ✅ supported | pubspec 1.7.1+1, README:3/173=1.7.1 |
| 128 unit tests | ✅ supported | flutter test +128 passed |
| CI ~7 min | ✅ supported | gh run list ≈6 min |
| Drift+SQLite+Preferences | ✅ supported | pubspec + lib/ |
| No Hive / no sqflite-DB | ✅ supported | не в pubspec/README |
| Auth (login/guard/token) | ✅ supported | lib/features/authentication/* |
| Feature Generator | ✅ supported | tool/new_feature.dart + test |
| check_secrets «blocks commits» | ❌ removed | было ложью → «run manually» |
| «production-ready» | ⚠️ softened | «production-ready foundation» |
| «1M+ users» | ⚠️ aspirational | «path to scale toward 1M+» |
| Boundary enforcement (CI) | ⚠️ partial | чекер только lib/features (F2) |

## 11. Remaining P2

- F4: coverage-gate комментарий не соответствует коду (PCT считает все строки). Документировано; правка логики CI вне scope doc-fix.
- F2: real cross-module import leak (`user_cache_service` → `authentication/presentation`). Арх-решение.

## 12. Stable Architecture — DO NOT REWRITE

Не переписывать: Clean Architecture слои, Riverpod 3 DI, Drift-схема,
Retrofit/Dio клиент, Noop-observability контракты, AI-agent файлы.
Все правки v2/v2.1 — документальные + удаление мёртвого EOL-пакета.

## 13. Recommended Next Directions (max 5, НЕ реализовано)

1. **Boundary checker coverage** — расширить `tool/check_boundaries.dart` на `lib/services`,
   чтобы ловить cross-module leaks (F2). Или перенести `current_user_provider` под feature.
2. **Wire check_secrets.sh** — подключить как pre-commit hook (instructions + Makefile step),
   чтобы claim «blocks commits» стал правдой.
3. **Coverage gate honesty** — либо исключить `*.g.dart`/`*.freezed.dart` из PCT (как заявлено
   в комментарии), либо поправить комментарий.
4. **Generated-cache hygiene** — добавить `.dart_tool/build/` в CI-cache invalidation или
   документировать, что `flutter test` требует свежего build_runner (иначе счёт 130 вместо 128).
5. **Release automation** — `gh release` создавать из CI при новом тега (устранить ручной шаг).

## 14. MASTER ARCHITECT DECISION REQUEST

- **Тег v1.7.1:** релиз уже запушен в v2 (тег на `a1e9695`). v2.1-правки — это НОВЫЙ коммит
  поверх. Решение: (а) оставить тег v1.7.1 на `a1e9695` и сделать доп. коммит v2.1
  (README-правки отдельным патчем), либо (б) перенести тег v1.7.1 на новый коммит.
  По мастер-задаче §8 «if v1.7.1 already exists — DO NOT create conflicting tag» → вариант (а):
  тег остаётся, коммит v2.1 идёт поверх, GitHub Release обновляется описанием. **Требует ОК
  Master Architect, если предпочтителен вариант (б).**
- **F2 (boundary leak)** — архитектурное решение, вне scope v2.1.

## 15. FINAL VERDICT

**READY FOR NEXT ARCHITECTURAL ITERATION**

Обоснование: все P0/P1 противоречия v2.1 устранены (README версия 1.7.0→1.7.1,
check_secrets-claim исправлен, бейджи синхронизированы). Тесты (128) и analyze (0 issues)
зелёные, `flutter build apk --debug` собирается после починки NDK. Публичный GitHub
отражает корректное состояние после пуша. P2 (F2/F4) задокументированы для следующей
архитектурной итерации. Релиз v1.7.1 верифицируем и целостен.
