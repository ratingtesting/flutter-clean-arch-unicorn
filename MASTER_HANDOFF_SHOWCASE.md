# MASTER_HANDOFF_SHOWCASE.md — v1.7.6 Showcase & Contributors

> Дата: 2026-08-24 · Пуш НЕ выполнялся — ждёт команды владельца «Делай пуш».
> Post-push шаги (license API, releases, branch protection) — pending push.

## БЛОК A: Витрина

### 1. MERMAID — ✅ fix + РЕНДЕР ДОКАЗАН
Fix был в v1.7.5-addendum (коммит 6027342): все labels в кавычках, subgraph →
явные узлы FEAT --- AUTH/DASH/SPLASH, ложная AUTH --> DASH убрана.
**Верификация рендера (новая сессия, agent-browser + локальный mermaid.min.js):
`RENDER_OK svgs=1`, title=RENDER_OK; скриншот-пруфф vision-проверен — все узлы
читаемы (Presentation/Widgets, Riverpod Providers, Repository Impl, Data
Sources, Drift Local DB, Dio Remote API, Services Contracts, Noop impls,
features/ + authentication/dashboard/splash), classDef применён.**
Файл пруффа: %LOCALAPPDATA%/Temp/mermaid_render_proof.png (27.7 KB).
mermaid-fence grep по всем *.md = ровно 1 блок (README).

### 2. SCREENSHOTS — ⛔ BLOCKED (честно)
4 пути испробованы: Windows-native run (блок «Developer Mode» = HKLM-ключ,
нет прав админа; HKCU Flutter не принимает) · web release на копии проекта
(условный drift/web импорт в КОПИИ, репо не тронут; сборка зелёная RC=0, но
dart2js-рантайм «Uncaught» — белый экран) · web debug `flutter run -d web-server`
(движок стартует, UI не рендерит, JS-ошибок 0) · все скрины белые,
vision-проверены. Причина: web-таргет шаблона блокируется dart:ffi (нативный
sqlite3 у Drift) — это архитектура шаблона, править код запрещено NON-GOALS.
README секция переписана честно: почему нет картинок + инструкция как добавить.
Фейковые изображения НЕ создавались.

### 3. LICENSE — ✅ канон MIT-0 (pending-push проверка API)
Перезаписан дословно каноном MIT No Attribution (без SPDX-строки и преамбул,
которые давали license: NOASSERTION). Локальная сверка — дословный канон.
**Pending push:** `gh api repos/... --jq .license.spdx_id` должен вернуть MIT-0.

### 4. TOPICS — ✅ ровно 20, применено и проверено API
flutter, flutter-template, flutter-starter, boilerplate, starter-kit,
clean-architecture, riverpod, drift, dio, freezed, go-router, dart, ai-agents,
ai-coding, agents-md, llms-txt, ci-cd, startup, vibe-coding, production-ready.
PUT /topics выполнен, обратное чтение names.length = 20.

## БЛОК B: Обратная связь

### 5. FEEDBACK LOOP — ✅ Discussion #1
Комментарий добавлен: «Used this template? Tell us…» + отсылка к cold-start
claim README как примеру замера.
URL: https://github.com/ratingtesting/flutter-clean-arch-unicorn/discussions/1#discussioncomment-18127598
GraphQL pinDiscussion отсутствует в схеме API (проверено) — по условию задачи
достаточно комментария.

### 6. RELEASES — ⏳ PENDING PUSH
Текущий факт: последний GitHub Release = v1.7.1. Скрипт готов (в
MASTER_HANDOFF_MERMAID_RELEASES.md): после зелёного CI нового head создать
v1.7.2/v1.7.3/v1.7.4/v1.7.5 из секций CHANGELOG, v1.7.5 = Latest.

## БЛОК C: Ворота для контрибьюторов

### 7. BRANCH PROTECTION — ⏳ PENDING PUSH
Включается только после пуша. План: required status check «Flutter CI»,
запрет force-push/удаления, linear history; admin override сохранён.
Фактический ответ API зафиксирую после включения.

### 8. CONTRIBUTOR ONBOARDING — ✅ (кроме скриншотов)
- CODE_OF_CONDUCT.md создан: Contributor Covenant v2.1 (адаптированная версия,
  атрибуция на месте).
- Issue-маяки открыты:
  - #2 [good first issue] Translate README intro to Russian (+documentation)
  - #3 [good first issue] Unit tests for PaginatedResponse parsing
  - #4 [good first issue] Extend DRIFT_TABLE_GUIDE with second worked example (+documentation)
  - #5 [help wanted] Widget test for auth guard redirect (/dashboard -> /login) (+enhancement)
  Каждый: чеклист шагов, ссылка AGENTS.md, критерии analyze=0 / tests green / boundaries pass.
- README: секция 🤝 Contributing добавлена («New here? Pick a good first issue →»
  на фильтр issues + ссылка Discussion #1).
- .github/GOOD_FIRST_ISSUE.md сверен с процессом (ссылки живые, лейблы есть);
  добавлена строка Questions? → Discussion #1.

### 9. ROADMAP AS ISSUES — ✅
- #6 [help wanted] Package extraction ← trigger §13 (второй продукт ИЛИ второй разработчик)
- #7 [enhancement] Integration/E2E foundation ← trigger §13 (первый реальный проект ИЛИ >10 фич)
Текст = маяк направления со scope-при-триггере, без реализации.
