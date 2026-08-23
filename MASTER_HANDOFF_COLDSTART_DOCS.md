# MASTER_HANDOFF_COLDSTART_DOCS.md — v1.7.5

> Дата: 2026-08-23 · Пуш НЕ выполнялся — ждёт команды владельца «Делай пуш».
> После зелёного CI на новом head: тег `v1.7.5` на release-коммите → push тега.

## Изменения

### 1. DOCS — docs/DRIFT_TABLE_GUIDE.md (новый, ~50 строк)
Точные шаги по реальному устройству шаблона (образец = CachedProducts):
make gen → файл таблицы `tables/<name>_table.dart` → регистрация в database.dart
(`@DriftDatabase(tables: [...])` + `part 'database.g.dart'`) → make gen повторно
→ использование. FAQ из реального холодного прогона: Value()-обёртка, insert
возвращает bool, Freezed copyWith, миграция обязательна при schemaVersion+1.

### 2. LINKS — по строке
- README «Add your second feature in 10 minutes»: ссылка на гайд, если фича с БД.
- AGENTS.md «Add offline storage»: ссылка на docs/DRIFT_TABLE_GUIDE.md.

### 3. CLAIM — холодный прогон в README (после бейджей) + llms.txt
Блок процитирован мастером дословно (правка только пунктуация при необходимости).
В llms.txt — одна строка с тем же фактом.

**Before (README:3):** `… 151 unit tests · v1.7.3`
**After:** `… 151 unit tests · v1.7.5` + claim-блок после бейджей:
> **Cold-start verified** (2026-08-23): an AI agent that had never seen this
> template cloned it cold and shipped a full CRUD feature (own Drift table,
> Freezed model, screen, routing) in ~56 minutes (~18 min reading docs), with
> **0 architecture violations** — every coding mistake was caught by the
> analyzer/enforcer before completion. Single-run measurement, template v1.7.3.

## Гейты (числа)

| Гейт | Результат |
|---|---|
| flutter analyze --fatal-infos lib/ test/ | RC=0, **0 issues** |
| dart run tool/check_boundaries.dart | RC=0, **0 violations** / 79 files |
| flutter test | RC=0, **154 passed** |
| grep «1.7.4» в живых claim-файлах | **CLEAN** (после bump 1.7.5) |
| Diff scope | docs/DRIFT_TABLE_GUIDE.md (новый), README.md, AGENTS.md, llms.txt, pubspec.yaml, CHANGELOG.md — только перечисленные |

## Git / Push Status
Коммиты Conventional: `docs(drift-guide)` · `docs(coldstart-claim)` ·
`chore(release) v1.7.5`. Локально. Пуш — по команде владельца.

STOP — следующую работу не искать.
