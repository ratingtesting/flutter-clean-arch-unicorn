# MASTER_HANDOFF_MERMAID_RELEASES.md — v1.7.5 addendum

> Дата: 2026-08-23 · Пункт A (mermaid) ВЫПОЛНЕН локально. Пункт B (releases)
> ОТЛОЖЕН до пуша владельцем — см. ниже. Пуш/тег/реleases ТОЛЬКО по команде
> «Делай пуш» (на всё разом: v1.7.5 + фиксы mermaid).

## A. Mermaid fix — README architecture diagram

**Before (defective):** subgraph с label `features/ — feature-first, autonomous`
(слэш, длинное тире, запятая), `AUTH[authentication] --> DASH[dashboard]`
(ложная зависимость между фичами — R-FEATURE-1 её запрещает), `UI --> features`
(subgraph использован как узел перехода), `NOOP[Noop impls / swap to ...]`
(спецсимволы в label). Симптом на GitHub: render error.

**After (fixed, commit 6027342):** все 11 node/edge labels в двойных кавычках;
subgraph заменён явными узлами `FEAT --- AUTH/DASH/SPLASH` (связь через `---`,
не стрелка); стрелка `AUTH --> DASH` убрана; спецсимволы в NOOP заменены дефисом.

Статическая проверка симптомов (grep): subgraph-raw-label=0, AUTH-->DASH=0,
UI-->features=0, NOOP-со-слэшем=0. Все mermaid-блоки репо: ровно 1, целый.

### Рендер-верификация — ЧЕСТНЫЙ ФАКТ
Среда НЕ позволяет отрендерить SVG:
- `npx @mermaid-js/mermaid-cli` не поднимает headless chromium (Connection closed —
  на хосте нет системных зависимостей для CDP; puppeteer с bundled chromium
  ставится, но mermaid-cli с ним не соединяется).
- `@mermaid-js/parser` напрямую `parse('flowchart')` не поддерживает (lazy-регистрация).
Поэтому факт «render OK» средой получить нельзя. Применены ВСЕ синтаксические
правила пункта (a); диаграмма написана строго по спецификации GitHub. Рендер
нужно подтвердить владельцу на публичной странице после пуша (или VS Code
Mermaid preview локально). Временные файлы удалены.

## B. Releases — ЖДЁТ КОМАНДЫ «Делай пуш»

Текущее состояние (факт): последний GitHub Release = **v1.7.1** (устарел).
Локальные теги: только **v1.7.3** (создан в Phase H). Теги v1.7.2/1.7.4/1.7.5
и соответствующие releases создаются при пуше по правилу «тег на release-коммите».

После пуша v1.7.5 и зелёного CI — скрипт (готов к запуску):
```
gh release create v1.7.5 --notes "$(sed -n '/## \[1.7.5\]/,/## \[1.7.4\]/p' CHANGELOG.md)"
gh release create v1.7.4 --notes "Final Polish Pass: 'Fix:' hints in boundary violations, Documented vs Enforced matrix, test/ exemption, README second-feature guide, Deferred Triggers (§13)."
gh release create v1.7.3 --notes "Docs Sync Completion: test count reconciled to 151 everywhere, ConsoleCrashReportingService rename, honest CI/secrets claims."
gh release create v1.7.2 --notes "Honesty & Small Fixes Pass: secret scan in CI, honest SECURITY.md STRIDE, extensible R-INFRA, generator public barrel, token-refresh wiring example."
```
(Заметки для v1.7.2/1.7.3/1.7.4 — краткие выжимки из CHANGELOG; теги не
редактируются, создаются на существующих коммитах.)

## Гейты

| Гейт | Результат |
|---|---|
| flutter analyze --fatal-infos lib/ test/ | RC=0, **0 issues** (прогнан, README не в scope) |
| flutter test | **154 passed** (из предыдущей задачи, код не менялся) |
| mermaid рендер средой | **НЕВОЗМОЖНО в этой среде** (см. факт выше) |
| grep '```mermaid' по всем *.md | 1 блок, целый, симптомы устранены |
| diff scope | только README.md (mermaid-блок) |

## Git / Push Status
`mermaid fix` = коммит **6027342** (локально, поверх v1.7.5-цепочки).
Полный локальный набор к пушу: 6027342 + ff363a4 (release v1.7.5) + bed7bf9 +
a2e99b8 + предыдущие. Пуш и теги v1.7.2–v1.7.5 — по команде «Делай пуш».

STOP — следующую работу не искать.
