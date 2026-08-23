# MASTER_HANDOFF_FINAL_POLISH.md — v1.7.4 Final Polish

> Дата: 2026-08-23 · Пуш НЕ выполнялся — ждёт команды владельца «Делай пуш».
> После зелёного CI на новом head: тег `v1.7.4` + push тега (как в Phase H).

## Изменения по пунктам

### 1. G1 — «Fix:» подсказки ✅
- `BoundaryViolation` получил поле `fixHint`; все **7 правил** снабжены короткими
  подсказками (куда перенести код / через что заменить).
- `tool/check_boundaries.dart` печатает `Fix: <hint>` под каждым нарушением
  (и fatal, и warning). Формат: Rule → Why → Fix.
- Тесты обновлены/добавлены: новая группа fix-hint тестов (все 7 правил: hint
  непустой, <220 символов; R-FEATURE-1 упоминает barrel; R-INFRA — provider),
  E2E негативный тест дополнительно ассертит `Fix:` в stderr чекера.

### 2. G2 — Documented vs Enforced ✅
ARCHITECTURE.md → новая таблица по всем 7 правилам + secret scan:
Rule | Documented | Automated | CI Blocking | Fix hint — все строки ✅✅✅✅.

### 3. G3 — правила vs test/ ✅ (факт → документированный exemption)
Фактическая проверка: `dart run tool/check_boundaries.dart test` → **RC=1**
(ложные срабатывания: тесты легально импортируют data-реализации доменных
контрактов). Применение правил к test/ сломало бы существующие тесты →
по критерию задачи зафиксирован **явный exemption** в ARCHITECTURE.md:
«test/ вне скана; тесты МОГУТ импортировать чужие фичи для интеграционных
сценариев, продакшн-код нет». Negative-fixture тест не добавлялся —
применять не к чему (правила на test/ сознательно не распространяются).

### 4. QUICKSTART ✅
README: секция **«Add your second feature in 10 minutes»** после Quick Start:
команда генератора, что сгенерируется (включая public barrel), 3 ручных шага
(wiring провайдера → роут → навигация), напоминание про `make gen`.

### 5. DEFERRED TRIGGERS ✅
UNICORN_FOUNDATION_REQUIREMENTS.md §13 — таблица: Package extraction ← второй
продукт ИЛИ второй разработчик; Integration/E2E ← первый реальный проект ИЛИ >10 фич.

## Гейты (числа)

| Гейт | Результат |
|---|---|
| flutter analyze --fatal-infos lib/ test/ | RC=0, **0 issues** |
| dart run tool/check_boundaries.dart | RC=0, **0 violations** / 79 files |
| flutter test | RC=0, **154 passed** (151 + 3 новых fix-hint теста) |
| Демо Fix | см. ниже |
| Diff scope | только перечисленные файлы (9-й в range = PHASE_H handoff, ждал пуша ещё с прошлой фазы) |

## Демо вывода чекера (временная фикстура, удалена после)

```
- [R-FEATURE-1] feature "demo" must not import internals of feature "authentication"
  (features/authentication/data/repositories/auth_repository_impl.dart).
  Depend on the public barrel or a contract instead.
    Fix: Import the public barrel features/authentication/authentication.dart,
    or move the shared type/contract to shared/ (or a service contract).
DEMO_RC=1
```

## Git / Push Status

Коммиты (Conventional): `6be2dcf` feat(tool) · `c5fefaf` docs(matrix+exemption) ·
`28f1389` docs(quickstart) · `95b8c7e` chore(release) v1.7.4.
Локально также висит незапушенный `9bc1935` (Phase H handoff) — уйдёт следующим пушем.
**Пуш — по команде владельца.** При пуше: master → зелёный CI → тег `v1.7.4`
на release-коммите → push тега (порядок как в Phase H).

STOP — следующую работу не искать.
