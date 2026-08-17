# Release Integrity Audit V2.1

> Universal Flutter Startup Unicorn Template
> Репозиторий: https://github.com/ratingtesting/flutter-clean-arch-unicorn
> Дата: 2026-08-17 · Оркестратор: Hermes Agent
> Метод: 3 параллельных read-only аудитора (A1 public-README, A2 release/version, A3 technical-claims) + независимая сверка оркестратора (локальный + публичный GitHub через `gh`).

---

## Executive Summary

Предыдущая итерация v2 (MASTER_HANDOFF_V2) провозгласила синхронизацию, но **сам README остался на версии `v1.7.0`** в двух местах, тогда как релиз уже `1.7.1` (pubspec `1.7.1+1`, тег `v1.7.1`, GitHub Release). Это и есть «handoff claims v1.7.1, public README presents v1.7.0». Также выявлена **ложная claim про secret-scanning** («blocks commits») и пара P2-гипербол («production-ready template», «Branch-ready for 1M+ users»).

Итерация v2.1 = RELEASE INTEGRITY FIX: устраняем противоречия без добавления архитектуры, без новых БД/state-management, без расширения scope.

**P0 (блокирующие):**
- F1 (P0): `README.md:24` утверждал, что `scripts/check_secrets.sh` «blocks commits» — на деле hook НЕ установлен, в CI/Makefile не вызывается. Вводящая в заблуждение claim. **Исправлено** (см. Fixes).
- F2 (P0): Границы-чекер `tool/check_boundaries.dart` сканирует только `lib/features`, пропуская `lib/services`. Реальный cross-module leak: `lib/services/user_cache_service/presentation/providers/current_user_provider.dart` импортирует `features/authentication/presentation/providers/auth_providers.dart`. **ВНЕ SCOPE v2.1** (архитектурное решение) — задокументировано как P1-наблюдение для Master Architect (см. MASTER_HANDOFF_V2_1 §13).

**P1:**
- F3: README версия `v1.7.0` (строки 3, 173) → `1.7.1`. **Исправлено.**
- F4: coverage-gate комментарий «excluding generated files» но код считает все строки (P1-код). Вне scope doc-fix; задокументировано.

**P2 (документируем, мягко исправлены wording):**
- F5: «production-ready template» → «production-ready foundation».
- F6: «Branch-ready for 1M+ users» → «Architected with a path to scale toward 1M+ users».
- F7: ARCHITECTURE.md бейдж `v1.7.0` → `v1.7.1` (консистентность).

---

## P0

| ID | Находка | Доказательство | Статус |
|----|---------|----------------|--------|
| F1 | README:24 «`scripts/check_secrets.sh` — blocks commits with API keys» — ЛОЖЬ | `.git/hooks/pre-commit` отсутствует; `git config core.hooksPath` пуст; не упоминается в `Makefile`/`make.bat`/`.github/workflows/main.yml`. Скрипт инертен. | ✅ Исправлено (текст смягчён) |
| F2 | CI «no cross-feature imports» ложноположителен: чекер не смотрит `lib/services` | `current_user_provider.dart` импортирует `features/authentication/presentation/providers/auth_providers.dart` (A3-F). Арх-решение. | ⏸ Вне scope, передано Master Architect |

## P1

| ID | Находка | Доказательство | Статус |
|----|---------|----------------|--------|
| F3 | README версия `1.7.0` при релизе `1.7.1` (строки 3, 173) | pubspec `1.7.1+1`, тег `v1.7.1`, commit `a1e9695`; README писал `1.7.0` | ✅ Исправлено |
| F4 | coverage-gate: комментарий «excluding generated» ≠ код (PCT = HIT*100/TOTAL по всем строкам) | `main.yml` PCT-формула; EXCLUDED не используется | ⏸ Документировано (P2 в v2) |

## P2

| ID | Находка | Статус |
|----|---------|--------|
| F5 | «production-ready template» — гипербола | ✅ Смягчено → «production-ready foundation» |
| F6 | «Branch-ready for 1M+ users» — факт vs аспирация | ✅ Смягчено → «Architected with a path to scale toward 1M+ users» |
| F7 | ARCHITECTURE.md бейдж `v1.7.0` | ✅ → `v1.7.1` |
| F8 | CI «~7 minutes» — подтверждено реальными прогонами (~6 min) | Оставлено (точное) |
| F9 | 128 tests — согласовано везде | Оставлено (точное) |

---

## Claims Audit (финальное состояние после правок)

| Claim | Статус | Evidence |
|-------|--------|----------|
| Version 1.7.1 | ✅ supported | pubspec `1.7.1+1`, тег v1.7.1, README:3/173=1.7.1 |
| 128 unit tests | ✅ supported | 128 `test()/testWidgets()` в test/; CI «128 tests passed» |
| CI ~7 min | ✅ supported | gh run list: 5m40s–6m38s (≈6 min) |
| CI pipeline 8 steps | ✅ supported | main.yml: pub get→build_runner→format→analyze→boundary→test+coverage→gate→apk |
| Drift + SQLite + Preferences | ✅ supported | pubspec drift^2.34.3, sqlite3^3.5.1, shared_preferences, flutter_secure_storage |
| No Hive / no sqflite-as-DB | ✅ supported | ни в pubspec, ни в README; EOL sqlite3_flutter_libs удалён в v2 |
| Auth (login/guard/token) | ✅ supported | lib/features/authentication/* + app_router.dart guard |
| Feature Generator | ✅ supported | tool/new_feature.dart + test/tool/new_feature_test.dart |
| Secret scan «blocks commits» | ❌ removed | было ложью; теперь «run manually» |
| «production-ready» | ⚠️ softened | «production-ready foundation» |
| «1M+ users» | ⚠️ aspirational | «path to scale toward 1M+ users» |
| Boundary enforcement (CI) | ⚠️ partial | чекер только lib/features; real leak в lib/services (F2) |

---

## Canonical Release State (A2)

- **Version:** 1.7.1 (pubspec `1.7.1+1`)
- **Commit:** `a1e9695` (chore: v1.7.1 integrity & documentation consistency pass) → после v2.1-правок будет новый коммит
- **Tag:** `v1.7.1` (локально + remote)
- **Release:** GitHub Release v1.7.1 (создан в v2)
- **Branch:** master
- **Public GitHub:** отражает 1.7.1 после пуша v2.1-правок

Единое каноническое состояние: **v1.7.1**.
