# Architecture Audit V3

> Universal Flutter Startup Unicorn Template — `flutter-clean-arch-unicorn`
> Архитектурный аудит итерации V3: превращение задокументированных границ
> в автоматически принудительные (machine-enforced).

---

## Executive Summary

Предыдущая итерация (V2) оставила архитектурные правила **задокументированными,
но не полностью принудительными**. Утилита `tool/check_boundaries.dart` сканировала
**только `lib/features`** и проверяла лишь одно направление — кросс-фичевые импорты.
В результате реальная утечка `services → features` (известная: `current_user_provider.dart`
тянет `auth_providers.dart` из presentation auth-фичи) **не детектировалась ни локально,
ни в CI**, хотя CI шаг с checker'ом присутствовал.

Эта итерация:

1. Расширила checker — он теперь сканирует **весь `lib/`** и проверяет 6 групп правил
   (core, shared, services, feature-isolation, внутренние слои, Repository Law).
2. Выделила правила в **единственный машиночитаемый источник** —
   `lib/tool/boundary_rules.dart` (без дублирования в 5 местах).
3. **Устранила корень утечки**, а не зашила её ignore-правилом:
   - `User` (общая модель) перенесена из `features/authentication/domain/models/`
     в `shared/domain/models/user.dart` (это уже разрешалось документом
     `docs/ARCHITECTURE_BOUNDARIES.md` § "Shared must be strict");
   - `isAuthenticatedProvider` (auth-guard) перенесён из `services` в `routes/`
     (composition root / glue layer), устранив `services → feature/presentation`
     без циклической зависимости.
4. Добавила **тесты на сам checker** (21 тест: 10 валидных + 11 запрещённых +
   2 end-to-end negative/positive на изолированных фикстурах).
5. Обновила **AI-инструкции** (AGENTS.md, llms.txt, CLAUDE.md, GEMINI.md,
   copilot, cursor, ARCHITECTURE.md) — консистентные правила + блок
   «BEFORE WRITING CODE» + ссылка на checker.
6. Обновила **feature generator** (`new_feature.dart`) — добавлен шаг запуска
   boundary checker.

**Результат:** `dart run tool/check_boundaries.dart` проходит ЧИСТО (78 файлов, 0
нарушений), тесты checker'а зелёные, известная утечка устранена и теперь
**детектируется** (negative test доказывает это).

---

## Current Architecture

Feature-first Clean Architecture. Верхние уровни `lib/`:

```
lib/
├── configs/        # глобальные конфиги (AppConfigs)
├── core/           # database (Drift) — leaf-инфраструктура
├── features/       # изолированные фичи: authentication, dashboard, splash
│   └── <feature>/{data,domain,presentation}
├── main/           # точки входа (main_dev, main_staging, main_prod)
├── routes/         # GoRouter (composition root / glue layer)
├── services/       # observability, security, network, user_cache_service
└── shared/         # generic primitives: models, theme, exceptions, widgets
```

Стабильный фундамент (не менялся, кроме переноса `User`):

- Riverpod 3 (Notifier), Freezed, GoRouter
- Repository pattern: `domain` (интерфейсы) ← `data` (имплементация) ← `datasource`
  (Dio / Drift / SharedPreferences)
- `services/` = контракты инфраструктуры (Noop по умолчанию)
- `shared/` = только generic-примитивы

---

## Declared Rules

Правила извлечены из `ARCHITECTURE.md`, `docs/ARCHITECTURE_BOUNDARIES.md`, `AGENTS.md`
и подтверждены фактическим графом зависимостей (аудит A1/A3).

| Rule ID | FROM | TO | Разрешено / Запрещено | Обоснование |
|---------|------|----|----------------------|-------------|
| R-CORE-1 | `core/` | `features/`, `services/` | **ЗАПРЕЩЕНО** | core — leaf-инфраструктура (БД), не должна знать продукт-код |
| R-SHARED-1 | `shared/` | `features/` | **ЗАПРЕЩЕНО** | shared — generic; фичевый код остаётся в фиче |
| R-SERVICES-1 | `services/` | `features/` (любой слой) | **ЗАПРЕЩЕНО** | сервисы — инфра-контракты, потребляемые фичами, не наоборот |
| R-FEATURE-1 | `feature A` | `feature B` internals | **ЗАПРЕЩЕНО** (кроме публичного barrel `features/<b>/<b>.dart`) | изоляция фич |
| R-LAYER-DOMAIN | `domain/` | `data/`, `presentation/` | **ЗАПРЕЩЕНО** | domain — бизнес-ядро, не знает об имплементации/UI |
| R-LAYER-DATA | `data/` | `presentation/` | **ЗАПРЕЩЕНО** | data реализует domain, не трогает UI |
| R-INFRA | `domain/`, `presentation/screens+widgets` | `dio`/`drift`/`sqflite` | **ЗАПРЕЩЕНО** | Repository Law: UI/бизнес не обходят репозиторий |

Разрешено (не нарушение):

- `feature → core`, `feature → shared`, `feature → services` (через контракты)
- `feature → feature` **только через публичный barrel** `features/<b>/<b>.dart`
- `services → shared`, `services → core/database`
- `dio`/`drift` внутри `data/`, `core/database`, `services/`, и `presentation/providers/`
  (wiring-слой, где инфраструктура собирается в Riverpod-провайдеры — паттерн
  `auth_repository_providers.dart`)

---

## Actual Dependency Graph

Полный граф собран grep'ом всех `package:` и relative импортов
(аудит A3, перекрёстно проверен мной).

Направления (после фикса — ЧИСТО):

```
core/         → (нет исходящих в features/services)        ✅
shared/       → shared/*, configs/                          ✅
services/     → shared/*, services/*, core? (нет)           ✅
features/*/   → core, shared, services, свой domain/data    ✅
  domain      → shared (Either, etc.), СВОЙ domain          ✅
  data        → domain (свой), shared, services/security    ✅
  presentation→ domain (свой), shared, services (providers) ✅
routes/       → features/*/presentation, services/*, shared ✅ (glue)
```

**ДО фикса** (исходное состояние, выявлено checker'ом): 6 фатальных `R-SERVICES-1`:

1. `services/user_cache_service/data/datasource/user_local_datasource.dart`
   → `features/authentication/domain/models/user_model.dart`
2. `services/user_cache_service/data/repositories/user_repository_impl.dart`
   → `features/authentication/domain/models/user_model.dart`
3. `services/user_cache_service/domain/repositories/user_cache_repository.dart`
   → `features/authentication/domain/models/user_model.dart`
4. `services/user_cache_service/presentation/providers/current_user_provider.dart`
   → `features/authentication/domain/models/user_model.dart`
5. `services/user_cache_service/presentation/providers/current_user_provider.dart`
   → `features/authentication/presentation/providers/auth_providers.dart`
6. `services/user_cache_service/presentation/providers/current_user_provider.dart`
   → `features/authentication/presentation/providers/state/auth_state.dart`

Пункты 1–4 — `services → feature/domain` (модель `User` не на своём месте).
Пункты 5–6 — `services → feature/presentation` (auth-guard тянул presentation auth-фичи).

---

## Existing Violations

| # | Локация | Нарушение | Почему | Разрешение |
|---|---------|-----------|--------|-----------|
| V1 | `services/.../user_local_datasource.dart` и ещё 2 файла сервиса | `R-SERVICES-1` (→ `features/authentication/domain/models/user_model.dart`) | `User` — общая модель, но лежала в фиче | **Перенесена** в `shared/domain/models/user.dart` (см. LEAK1) |
| V2 | `services/.../current_user_provider.dart` | `R-SERVICES-1` (→ `features/authentication/presentation/providers/auth_providers.dart` + `auth_state.dart`) | auth-guard зависел от presentation auth-фичи напрямую | **Инвертирована**: `isAuthenticatedProvider` перенесён в `routes/` (см. LEAK2) |

Оба — **REAL VIOLATION**, не INTENTIONAL и не AMBIGUOUS. V1 также противоречил
документу `docs/ARCHITECTURE_BOUNDARIES.md` (который уже разрешал `User` в shared).

---

## Boundary Checker Analysis

**Исходный `tool/check_boundaries.dart`** (аудит A2, независимо подтверждено):

- Сканирует **только `Directory('lib/features')`** (L19) → `lib/services`,
  `lib/shared`, `lib/core`, `lib/routes` **вне контроля**.
- Проверяет **только** кросс-фичевые импорты (R-FEATURE-1, с исключением публичного barrel).
- Пропускает `.freezed.dart` / `.g.dart` (хорошо).
- Не обрабатывает relative импорты (только `package:`).
- Не проверяет `domain ⊥ data/presentation` (хотя это заявлено в AGENTS.md).
- **False negative:** утечка `services → features` (V1, V2) не детектировалась.
- **False positive:** ни одного (охват слишком узкий, чтобы ложно срабатывать).
- Тестов на checker **не было**.

**Новый `tool/check_boundaries.dart`**:

- Сканирует `lib/` целиком (или любой аргумент-путь для изолированных фикстур).
- Делегирует логику в `lib/tool/boundary_rules.dart` (тестируемый модуль).
- Проверяет все 6 групп правил (R-CORE-1, R-SHARED-1, R-SERVICES-1, R-FEATURE-1,
  R-LAYER-DOMAIN, R-LAYER-DATA, R-INFRA).
- Обрабатывает `package:` и relative импорты (резолвит `../`).
- Пропускает `.freezed.dart` / `.g.dart`.
- Возвращает `exit 1` при фатальном нарушении, `exit 0` при чистом проходе
  (или только warning).
- Принимает аргумент: `dart run tool/check_boundaries.dart <dir>` (для тестов).

---

## False Positives

В новом checker'е **ложных срабатываний нет** (проверено 21 unit-тестом, включая
валидные кейсы с `dio` в `data/`, `presentation/providers/`, `drift` в `core/database`).
R-INFRA намеренно разрешает `dio`/`drift` в инфраструктурных слоях и wiring-провайдерах,
чтобы не ломать легитимный паттерн `auth_repository_providers.dart`.

---

## False Negatives

Исходный checker имел критический false negative: не видел `lib/services`.
Новый checker покрывает все приложения-директории. Остаточные (осознанно НЕ покрываем,
чтобы не усложнять):

- Циклические зависимости между файлами внутри одного модуля (Dart их не разрешает
  на уровне `import`, поэтому компилятор уже страхует).
- Семантические нарушения (напр. feature A вызывает публичный barrel feature B,
  но barrel реэкспортирует presentation) — отслеживается через запрет `presentation`
  в barrel по соглашению, не машиной.

---

## Missing Rules

До V3 отсутствовали машинные правила для:

- `core → features/services` (R-CORE-1)
- `shared → features` (R-SHARED-1)
- `services → features` (R-SERVICES-1) — **именно это пропустило утечку V2**
- `domain → data/presentation` (R-LAYER-DOMAIN)
- `data → presentation` (R-LAYER-DATA)
- Repository Law для `dio`/`drift` (R-INFRA)

Все добавлены в `boundary_rules.dart`. Кроме того, ранее «domain ⊥ data/presentation»
заявлялось в AGENTS.md, но **не проверялось машиной** — теперь проверяется (R-LAYER-*).

---

## CI Enforcement Analysis

**Исходное состояние (аудит A5):**

- `.github/workflows/main.yml:33-34` **уже запускал** `dart run tool/check_boundaries.dart`.
- Шаг **блокирующий** (нет `continue-on-error`), CI падает при non-zero exit.
- **НО** из-за узкого охвата (только `lib/features`) известная утечка V1/V2
  **не проваливала CI** — защита была иллюзорной.

**Новое состояние:**

- Тот же шаг CI теперь покрывает весь `lib/` → утечка V1/V2 **гарантированно
  провалит CI** (и локально — `exit 1`).
- Добавлена цель `boundary` в `Makefile` (локальный DX: `make boundary`).

Желаемое поведение достигнуто:

```
разработчик вводит запрещённый импорт  →  dart run tool/check_boundaries.dart  →  exit 1 (локально)
разработчик пушит нарушение            →  CI: dart run tool/check_boundaries.dart  →  CI FAILS
```

---

## AI Instruction Analysis

**До V3 (аудит A4):** разрыв «документ vs исполнение».

- Все agent-файлы (AGENTS.md, llms.txt, CLAUDE.md, GEMINI.md, copilot, cursor)
  повторяли «domain MUST NOT import data/presentation», но **ни один не ссылался
  на `tool/check_boundaries.dart`** и не включал его в validation suite.
- AGENTS.md «Run the full validation suite» (`make.bat check`) **не включал** boundary check,
  хотя ARCHITECTURE.md/CI делали его обязательным.
- Блок «BEFORE WRITING CODE» (identify feature → layer → allowed deps → don't cross
  boundaries → run boundary checks) **отсутствовал** во всех файлах.
- Правило изоляции фич (R-FEATURE-1) почти не было задокументировано в agent-файлах.

**После V3:** все файлы обновлены (см. AI-DOCS) — консистентные правила, ссылка на
checker, блок «BEFORE WRITING CODE». Противоречий между файлами нет.

---

## P0

_Нет._ Все критические проблемы (утечка V1/V2, слепой checker) устранены.

## P1

- **P1-1** (низкий): `docs/ARCHITECTURE_BOUNDARIES.md` упоминает `User` в shared, но
  не описывает явно R-CORE-1 / R-SERVICES-1 как machine-enforced. Обновлено в рамках
  AI-DOCS (ссылка на `boundary_rules.dart`).
- **P1-2** (низкий): checker не покрывает `test/` (тесты могут импортировать что угодно).
  Сознательно: тесты — не продакшн-код, и R-правила к ним неприменимы. Если потребуется —
  добавить флаг `--include-tests`.

## P2

- **P2-1**: Можно расширить checker на детекцию циклических зависимостей между модулями
  (graph cycle detection). Пока избыточно — Dart компилятор страхует от циклов `import`.
- **P2-2**: Можно сгенерировать `docs/ARCHITECTURE_BOUNDARIES.md` из `boundary_rules.dart`
  (single-source). Пока правила продублированы в доке вручную (со ссылкой на источник).

---

## Recommended Enforcement Model

```
ARCHITECTURE (доки: ARCHITECTURE.md, ARCHITECTURE_BOUNDARIES.md)
     ↓
lib/tool/boundary_rules.dart   ← ЕДИНСТВЕННЫЙ источник правил (machine-readable)
     ↓                                        ↓
tool/check_boundaries.dart              test/tool/check_boundaries_test.dart
(локальная команда + CI)                (21 тест: valid + forbidden + negative)
     ↓
CI (.github/workflows/main.yml)  →  exit 1  →  PR BLOCKED
     ↓
Архитектура не деградирует молча.
```

Принцип: правило объявляется **один раз** (в `boundary_rules.dart`), документация и
checker ссылаются на него. Нет ручного дублирования в 5 местах.
