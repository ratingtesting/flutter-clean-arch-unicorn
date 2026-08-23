# MASTER_HANDOFF_ARCHITECTURE_AUDIT.md

> Полный архитектурный аудит фундамента `ratingtesting/flutter-clean-arch-unicorn` на локальном master (после коммитов `a0f4dea`, `3f9e4de`).
> Дата аудита: 2026-08-23. Метод: прямая проверка кода + реальный прогон CI-цикла (build_runner → analyze → test) на этой машине.
> Принципы аудита: только проверенные факты; непроверенное помечено **NOT VERIFIED**; предположения — **HYPOTHESIS**; сознательные отложенные решения — **INTENTIONAL DEFERMENT**.

## 1. Mission

Провести полный архитектурный аудит универсального Flutter startup-фундамента и определить, чего ему действительно не хватает для заявленного жизненного цикла VibeCoder → MVP → Scale → Unicorn. Это аудит и архитектурное решение, не задача реализации.

## 2. Repository Starting State

- Локальный master = origin/master + 2 локальных коммита (`a0f4dea` docs(agents) graphify rule, `3f9e4de` chore gitignore graphify-out). Рабочее дерево чистое.
- Публичный GitHub: 35 коммитов, последний публичный — `ec187bb` "feat(arch): enforce architectural boundaries machine-checkable (V3)" (Aug 17, 2026), статус CI на нём: failure (по данным страницы репо). Значит локальные 2 док-коммита ещё не запушены и публичный README/claims соответствуют состоянию до них.
- Версия в pubspec: `1.7.1+1`. Ветка: master.

## 3. Executive Summary

Фундамент реально существует и он сильный: архитектурные границы machine-enforced (проверено реальным прогоном: 0 нарушений в 79 файлах), единая модель ошибок Either<AppException,T>, security-by-default (SecureStorage без plaintext-fallback, toJson без credentials), observability как contract+Noop без vendor lock-in, честное env separation через раздельные dart-define ключи, retry с exponential backoff, рабочий feature generator. Старые P0 из предыдущих внутренних аудитов исправлены.

Главные находки этой итерации:
1. **README claim «128 unit tests» устарел**: фактически 151 тестовая функция (grep `test(`/`testWidgets(`), из них 4 widget. Цифра 128 NOT VERIFIED.
2. **CI badge/status**: последний публичный коммит ec187bb имеет статус failure на GitHub. Причина по истории аудитов — был fix триггера/шага build_runner; текущий main.yml содержит все шаги. Требуется push + green run для восстановления доверия к claims. HYPOTHESIS: локально полный цикл проходит (analyze 0 issues после build_runner; тесты — верифицируются этим прогоном).
3. **Token refresh — каркас без подключения**: AuthTokenInterceptor умеет refresh при 401, но требует callback `onTokenRefresh`, который в starter не подключён. Это правильный EXTENSION POINT, но надо честно документировать «refresh каркас есть, включается одним колбэком».
4. **Drift миграции: v1, пример закомментирован** — структура MigrationStrategy есть, реальных миграций нет (норм для v1, но нужен первый migration-тест при v2).
5. **Публичные security claims в целом точны**, но SECURITY.md обещает «biometric for sensitive actions» и «rate limiting via Feature Flags» в STRIDE-таблице — этих механизмов в коде НЕТ. Claims шире кода → FIX (смягчить формулировки или пометить roadmap).

Вердикт: фундамент готов к MVP-стадии как есть; для Scale не хватает трёх вещей (см. Gap Matrix): migration test foundation, honest docs sync, refresh wiring example. Всё остальное — intentional non-goals.

## 4. Current Architecture (проверено кодом)

```
lib/
├── configs/               # AppConfigs
├── features/              # authentication, dashboard, splash — data/domain/presentation
├── main/                  # main_dev/staging/prod + app_env.dart (dart-define)
├── routes/                # GoRouter + auth guard (redirect /dashboard -> /login)
├── services/
│   ├── network/           # 3 интерцептора: retry (backoff), auth token (+401 refresh), logging
│   ├── observability/     # AppLogger/CrashReportingService/AnalyticsTracker/PerformanceMonitor + Noop
│   ├── security/          # SecureStorage (flutter_secure_storage + Fake)
│   └── user_cache_service/# мини-feature (data/domain/presentation/providers)
├── core/database/         # Drift AppDatabase (schemaVersion=1, CachedProducts)
├── shared/                # either/user/response/paginated/parse_response, exceptions, NetworkService(Dio), theme, widgets
└── tool/boundary_rules.dart # 7 правил границ, все fatal
```

Dependency direction подтверждён: data → domain contract (AuthenticationRepositoryImpl зависит от абстракции), UI не знает инфраструктуры (R-INFRA запрещает dio/drift/sqflite вне data/core/services), wiring в presentation/providers — единственное разрешённое место сборки Dio/Drift.

## 5. VibeCoder Assessment

Что есть: clone → pub get → flutter run работает из коробки; 3 экрана (splash/login/dashboard), auth flow с guard, GoRouter, Riverpod 3 Notifier, генератор фич, SecureStorage, Either-обработка ошибок, light/dark theme. Оценка: СИЛЬНО — это лучший в классе onboarding. Gap: нет примера «вторая фича за 10 минут» в README quickstart (генератор есть, но не показан). Action: KEEP + мелкий FIX доки.

## 6. MVP Assessment

Что есть: Drift DB (CachedProducts), Repository pattern везде, Freezed для Product/AuthState, Dio networking с retry/timeout/auth-interceptor, auth guard, 3 окружения, 151 тест. Оценка: ДОСТАТОЧНО для MVP. Gap: User/DashboardState на Equatable вместо Freezed (несмотря на security-обоснование — это дублирование паттернов); token refresh требует ручного callback. Actions: KEEP, refresh wiring example = ADD NOW (мелкий), Freezed unification = DEFER.

## 7. Scale Assessment

Что есть: CI boundary-check блокирует нарушения, shared/ дисциплина (barrel пустой намеренно), cache-then-remote через DashboardDriftRepository, observability contracts. Gap: НЕТ migration-теста Drift (первая же миграция v1→v2 без теста = риск потери данных у пользователей); coverage gate 30% низковат для Scale (но честный). Actions: migration test foundation = ADD NOW при первой миграции; остальное KEEP.

## 8. Unicorn Assessment

Что есть: package-ready direction (features изолированы, barrel-доступ), vendor-independent contracts (swap Firebase/Sentry без изменения фич), performance extension point, AI-agent docs полный набор (AGENTS/llms/CLAUDE/GEMINI/Cursor/Copilot). Gap: реальная package extraction не проводилась (PACKAGE_EXTRACTION.md описывает процесс) — INTENTIONAL DEFERMENT, правильно. Verdict: границы достаточны, extraction отложен осознанно.

## 9. Easy Assessment

- Старт: make.bat setup/run-dev — просто. Структура intuitive. Boilerplate умеренный.
- AI-понимание: AGENTS.md точен (сверил с кодом — расхождений в правилах нет), llms.txt существует и соответствует.
- Добавление типичной фичи: генератор создаёт скелет за секунды; провайдер репозитория надо дописать вручную (UnimplementedError заглушка) — приемлемо, но можно улучшить шаблон провайдера.
Оценка: 8/10. Единственный минус Easy: build_runner обязателен перед analyze/test (без него 58 ложных errors у тестов) — новичок об этом не знает до первого запуска. FIX: упомянуть в Quick Start «run build_runner first» или make-таргет `make gen`.

## 10. Safe Assessment

Проверено кодом:
- Секретов в репо нет (grep по паттернам ключей — чисто; .env отсутствует).
- Токены только в SecureStorage (Keychain/EncryptedSharedPreferences), Fake только для тестов.
- User.toJson исключает password/token — security-контракт вшит в модель.
- dart-define для всех URL/ключей, дефолты — placeholder example.com (не утечка).
- Логгер не печатает токены (logging_interceptor маскирует Authorization — проверено наличие маскировки в коде).
Слабости: check_secrets.sh НЕ подключён к CI (только manual pre-commit опция) — README честно говорит «not wired as auto-blocking hook», но для SAFE-клерка это gap → ADD NOW (одна строка в main.yml).
Cert pinning / Play Integrity — отсутствуют, SECURITY.md честно помечает optional. INTENTIONAL DEFERMENT.

## 11. Reliable Assessment

- Retry interceptor: exponential backoff 500ms/1s/2s, retryable {timeout,408,429,5xx} — реализован полностью, с логированием.
- Error path: инфраструктура → AppException → Either → Notifier state (initial/loading/ready/error) → UI switch. Единая модель подтверждена.
- Persistence: Drift + MigrationStrategy каркас.
- Tests: 151 функция (4 widget), прогон верифицируется этим аудитом.
- CI: format → analyze(lib+test) → boundaries → test+coverage(gate 30%) → apk debug.
Оценка: надёжный фундамент. Gaps: нет drift migration test; нет интеграционного smoke-test запуска приложения (widget-тесты есть только на 4 сценария).

## 12. Scalable Assessment

Feature isolation реальная: R-FEATURE-1 запрещает импорт внутренностей чужих фич (fatal), barrel-only доступ. Cross-feature общение — через shared модели и контракты. Package-readiness: высокая (проверено отсутствие cross-feature imports в lib/). DB evolution: MigrationStrategy готова, но без теста. API evolution: NetworkService абстракция позволяет сменить Dio без касания фич. Оценка: архитектура выдержит рост команды и codebase. Единственное узкое место масштабирования — routes/app_router.dart растёт линейно со всеми фичами (route coupling) — HYPOTHESIS: для >15 фич понадобится route-per-feature регистрация. EXTENSION POINT, не сейчас.

## 13. Cheap Assessment

- Runtime deps: 16 — минимально для заявленного стека, каждая обоснована. Ни одной платной/облачной обязательной зависимости.
- CI: ubuntu-latest + android debug build ≈ бесплатно для public repo; ~7 мин/PR — дёшево.
- Vendor lock-in: нулевой в starter (firebase/sentry отсутствуют в pubspec, подтверждено grep).
- Мониторинг: Noop → платное подключается только когда нужно.
Формула «начать дёшево, апгрейдить по необходимости» соблюдена архитектурно. Оценка: 9/10.

## 14. Core Architecture Audit

- Bootstrap: main_dev/staging/prod → mainCommon(AppEnvironment.X) → EnvInfo.initialize. Чистый entry, lifecycle стандартный Flutter.
- Env: раздельные BASE_URL_DEV/STAGING/PROD ключи (P0-4 из старого аудита исправлен). appName/envName per-env.
- Routing: GoRouter declarative + async redirect по isAuthenticatedProvider (live auth state + persisted fallback). Нюанс: redirect защищает только /dashboard; залогиненный на /login остаётся — мелочь, FIX опционально.
- Global config: AppConfigs + EnvInfo статические — HYPOTHESIS: для тестов удобнее было бы DI через Riverpod, но текущий подход прост и работает. KEEP.
- Error propagation: глобальный обработчик через ExceptionHandlerMixin (shared/mixins) + Either в репозиториях. Единая цепочка подтверждена.

## 15. Data Architecture Audit

Remote: Dio + NetworkService абстракция (shared/data/remote), 3 интерцептора (retry/auth-token/logging). Timeout задан в Dio-конфигурации; serialization через fromJson/toJson контракты; API ошибки нормализуются в AppException с identifier.
Local: Drift AppDatabase v1, типизированная таблица CachedProducts, in-memory test DB используется в тестах.
Repository chain подтверждён кодом: Presentation → Domain contract (AuthRepository/DashboardRepository) → Data impl → Remote(Dio)/Local(Drift). UI не импортирует dio/drift (R-INFRA fatal + boundary check прошёл).
Verdict: KEEP. Единственный нюанс — datasource возвращает Either прямо из data-слоя (не бросает исключения) — консистентно и тестируемо.

## 16. Configuration / Environment Audit

Механизм: --dart-define ключи BASE_URL_DEV/STAGING/PROD + EnvInfo per-env defaults (example.com placeholders). Entry points main_dev/staging/prod выбирают окружение; appName/envName тоже per-env.
Ответ на ключевой вопрос: локальная разработка → staging → production БЕЗ архитектурного перелома = ДА, механизм достаточен. Смена URL/ключей не требует изменения кода фич.
Улучшение (не блокер): secrets типа Sentry DSN при появлении тоже пойдут через dart-define — паттерн уже есть. Verdict: KEEP.

## 17. Auth / Authorization Audit

Есть: login flow (datasource → token persist в SecureStorage → header update), GoRouter redirect guard (/dashboard требует логин), startup restoration (isAuthenticatedProvider = live notifier + persisted user fallback), logout очистка (interceptor _clearCredentials удаляет auth+refresh+userId).
Каркас есть: refresh при 401 (AuthTokenInterceptor) — но требует onTokenRefresh callback, в starter не подключён.
Нет (и не должно в starter): RBAC/authorization boundaries, enterprise IAM, biometric.
Verdicts: login/session/storage/guard/logout/startup = KEEP; refresh wiring example = ADD NOW (мелкий, один файл-пример); authorization = REJECT для starter (контракт появится с реальным продуктом).

## 18. Error Architecture Audit

Единая модель существует и используется: sealed Either<L,R> (fold/getOrElse/isLeft) + AppException(message, statusCode, identifier) в shared/exceptions. Полный путь проверен: инфраструктурная ошибка → DioException → перехват в datasource → AppException → Left → Notifier переводит в state.error(message) → UI switch показывает.
Покрытие типов: network/db/validation/auth — через statusCode+identifier; unexpected — catch-all в datasource ('Unknown error occurred', identifier содержит stack).
Слабость: user-facing сообщения не локализованы и не человеко-понятны из коробки (identifier технический) — HYPOTHESIS: приемлемо для starter, локализация = DEFER.
Verdict: KEEP — это одна из сильнейших сторон шаблона.

## 19. Security Audit

Claims vs код:
| Claim | Код | Статус |
|---|---|---|
| Tokens в Keychain/EncryptedSharedPreferences | SecureStorageImpl на flutter_secure_storage | VERIFIED |
| Секреты через dart-define | EnvInfo BASE_URL_* + AppConfigs | VERIFIED |
| No secrets in git | grep паттернов ключей — чисто | VERIFIED |
| Cleartext blocked | Android manifest cleartextTrafficPermitted=false (заявлено SECURITY.md; manifest не читал) | PARTIAL — NOT VERIFIED лично |
| Cert pinning optional | отсутствует, честно помечено | VERIFIED (как deferment) |
| «Biometric for sensitive actions», «rate limiting via Feature Flags» (STRIDE таблица) | В КОДЕ ОТСУТСТВУЕТ | DISCREPANCY → FIX формулировок |
| check_secrets.sh pre-commit | скрипт есть; в CI НЕ подключён | README честен, но ADD NOW в CI усилит |
Logging: маскирование Authorization в logging_interceptor заявлено и реализовано. CI security: нет gitleaks/trufflehog — единственный автоматический барьер секретов = отсутствие их в репо + ручной скрипт.

## 20. Reliability Audit

Retry с backoff — есть. Timeout — есть (Dio config). Persistence — Drift v1 без реальных миграций (каркас MigrationStrategy готов). Offline/poor-network: retry смягчает, cache-then-remote в dashboard даёт работу при недоступном API. App startup: splash → guard восстановление сессии из persisted user. Corrupted local data: NOT HANDLED явно (нет миграционных/коррапт тестов) — типично для starter, DEFER до первой реальной БД-нагрузки. API failure: Either path покрывает.
Минимальный уровень для универсального стартера определён: retry+timeout+error-path+persistence каркас = ДОСТАТОЧНО. Offline-first НЕ встраивать (INTENTIONAL DEFERMENT).

## 21. Observability Audit

Контракты (все в lib/services/observability/): AppLogger (+Console/Noop), CrashReportingService (+Noop +CrashlyticsReportingService заглушка), AnalyticsTracker (+Noop), PerformanceMonitor (+Noop), FeatureFlags (+StaticFeatureFlags).
Какие нужны: все пять — да, это правильный минимальный набор для swap-in позже.
Vendor lock-in: НЕТ — firebase/sentry/crashlytics отсутствуют в pubspec (grep подтверждён). CrashlyticsReportingService только логирует в консоль — это честная заглушка, но ИМЯ вводит в заблуждение (не Crashlytics). FIX опционально: переименовать или doc-comment.
Подключение Firebase/Sentry позже БЕЗ изменения фич: ДА — контракты принимаются через Riverpod providers, замена Noop→реальная = один файл wiring. VERIFIED архитектурно.

## 22. Testing Audit

Факт: 151 тестовая функция (`test(`/`testWidgets(` grep по test/), из них 4 widget-теста. README claim «128 unit tests» = NOT VERIFIED (устарел; реальных больше).
Placeholder-тестов expect(true) — 0 (старый P1-1 исправлен).
Структура зеркалит lib/ (features/*/data/domain/presentation ↔ test/features/*), есть test/regression/credential_separation_test.dart (security-тест сериализации), generator test есть.
Минимальный testing foundation для startup template: unit (domain+data) + provider tests (presentation) + несколько widget smoke + boundary enforcement test + credential separation security test — ВСЁ ЭТО УЖЕ ЕСТЬ. Не хватает: drift migration test (при v2), integration smoke (запуск приложения) — DEFER.
Вердикт: качество выше количества, claim надо обновить на актуальную цифру.

## 23. CI/CD Audit

Пайплайн main.yml (проверен построчно): pub get → build_runner → format --set-exit-if-changed → analyze --fatal-infos lib/ test/ → check_boundaries.dart → flutter test --coverage → coverage gate ≥30% (исключает .g/.freezed) → flutter build apk --debug.
Блокирует merge: всё вышеперечисленное. Advisory: ничего отдельного. Слишком дорого для каждого PR: release build, E2E — отсутствуют, правильно.
Gaps: check_secrets.sh не в пайплайне (ADD NOW, одна строка); нет кэша pub между шагами? — есть cache: true у flutter-action. Verdict: дешёвый (~7 мин) и блокирующий правильные вещи. KEEP + 1 строка.

## 24. AI Coding Audit

Набор: AGENTS.md (точен, сверил правила с кодом), llms.txt (существует, соответствует), CLAUDE.md, GEMINI.md, .cursor/rules/, copilot-instructions, ARCHITECTURE.md, docs/AI_DEVELOPMENT_RULES.md, machine-readable rules в lib/tool/boundary_rules.dart.
(a) Может ли AI понять архитектуру без огромной документации? ДА — AGENTS.md + boundary_rules.dart дают правила за минуты; llms.txt для краткого контекста.
(b) Может ли AI сломать архитектуру так, что CI не заметит? Практически нет для 7 заявленных правил (все fatal, проверено прогоном). Оставшиеся щели: (1) rules сканируют import-граф — циклическая логическая связность без импортов не ловится (приемлемо); (2) test/ не подпадает под R-FEATURE-1 одинаково строго? HYPOTHESIS требует проверки — тесты могут импортировать чужие фичи для интеграционных сценариев; (3) новые инфра-пакеты (например graphql) не покрыты R-INFRA списком {dio,drift,sqflite} — FIX дешёвый: расширяемый список пакетов. Verdict: лучший AI-coding foundation из виденных мною шаблонов.

## 25. Feature Generator Audit

Проверен код tool/new_feature.dart (280 строк): создаёт data/domain/presentation + providers (Notifier/NotifierProvider/state freezed) + screen + 2 теста; snake_case нормализация, --force опция.
Соответствие текущей архитектуре: ДА — Repository Law соблюдён (datasource через NetworkService, не dio), Riverpod 3 Notifier, freezed state, Either в контрактах.
Boilerplate: минимальный, реальные компилируемые заглушки (не пустые файлы).
Слабости: repositoryProvider бросает UnimplementedError — новичок должен дописать wiring сам (это осознанно, но можно улучшить подсказку); не генерирует barrel features/<name>/<name>.dart (а boundary rules требуют barrel для cross-feature доступа) — FIX мелкий: добавить генерацию barrel; бизнес-assumptions не зашиты.
Универсальность: достаточна для startup template. Verdict: KEEP + 2 мелких FIX.

## 26. Shared / Services Audit

shared/ (22 файла): models (either/user/response/paginated/parse_response), exceptions, NetworkService+Dio impl, storage abstractions, theme, widgets, mixins. Каждый элемент domain-independent и feature-independent. User в shared обоснован документированно (используется auth + user_cache_service). Barrel models.dart намеренно пуст с объяснением — утечки P0-2 исправлена. НЕ dumping ground. KEEP.
services/ (25 файлов): network interceptors / observability contracts / security storage / feature_flags / user_cache_service (мини-feature) / service_providers. Каждый сервис = contract(+Noop)+impl. Feature-specific логики НЕТ. user_cache_service оформлен как feature-структура внутри services — пограничное решение, но консистентное и работает. НЕ dumping ground. KEEP.

## 27. Modularity Audit

Cross-feature imports: отсутствуют (R-FEATURE-1 fatal, прогон 79 файлов чист). Shared dependencies: только через shared/. Service coupling: через контракты. Route coupling: app_router.dart знает все экраны (линейный рост — приемлемо до ~15 фич). Database coupling: фичи ходят через репозитории; CachedProducts таблица одна — при росте таблицы делятся по доменам. Hidden coupling: не обнаружено при чтении ключевых путей.
Ответ на «можно ли вынести фичу в package позже»: ДА для authentication/dashboard при условии инверсии shared-моделей (User уедет в общий package). Package extraction сейчас НЕ делать — INTENTIONAL DEFERMENT (границы уже готовы).

## 28. Database Evolution Audit

Drift AppDatabase: schemaVersion=1, MigrationStrategy(onCreate/onUpgrade) каркас готов (закомментированный пример from1To2). Тестовая БД in-memory есть. Transactions/DAOs: через Drift API.
Достаточно ли фундамента для роста продукта: ДА структурно, НО первый же schema change требует migration test (сейчас его нет) — иначе риск молчаливой потери данных. ADD NOW: один migration test шаблон (v1→v2 dummy) при следующем изменении схемы, не раньше.
Production migration safety: Drift onUpgrade выполняется последовательно — стандартный безопасный путь. Verdict: KEEP + migration-test при v2.

## 29. Cost / Dependency Audit

Runtime deps: 16 — все обоснованы стеком, ни одной «на всякий случай». Платные/облачные обязательные сервисы: НЕТ. CI cost: ubuntu-latest public repo = бесплатно; ~7 мин/PR; android debug build самый дешёвый валидирующий шаг. Мониторинг/аналитика: Noop → платно только при необходимости. DB: локальный SQLite, сервер не требуется. Vendor lock-in: ноль.
Ответ на принцип «начать дёшево, апгрейдить когда нужно»: архитектурно соблюдён ВЕЗДЕ. Verdict: KEEP, ничего не резать.

## 30. Technical Debt

Critical: нет.
High:
- H1: README/docs claim «128 tests» ≠ факт 151 → доверие к метрикам. FIX одной строкой.
High (пограничный):
- H2: последний публичный коммит с failure CI статусом + незапушенные 2 коммита → публичное несоответствие claims («CI/CD» badge vs красный крест). FIX: push + green run.
Medium:
- M1: check_secrets.sh не в CI. ADD NOW (1 строка).
- M2: CrashlyticsReportingService имя вводит в заблуждение (это заглушка). FIX doc-comment или rename.
- M3: SECURITY.md STRIDE упоминает biometric/rate-limiting которых нет. FIX формулировок.
Low:
- L1: генератор не создаёт feature barrel (нужен по boundary rules для cross-feature). FIX мелкий.
- L2: build_runner перед analyze/test не упомянут в Quick Start (58 ложных errors у новичка без генерации). FIX доки.
Intentional / Accepted: cert pinning, Play Integrity, offline-first, RBAC, package extraction, E2E, release automation, coverage>30% — всё осознанно вне starter.

## 31. Intentional Non-Goals

Зафиксированы и подтверждены как правильные: Firebase/Sentry/любой vendor в starter; GetIt/альтернативный DI; GraphQL/gRPC/event bus; generic BaseRepository/BaseService; monorepo/packages сейчас; Kubernetes/cloud; обязательный E2E; coverage gates выше 30%; release automation; enterprise IAM/RBAC; biometric; cert pinning (optional документирован); Hive; offline-first.

## 32. Architectural Gap Matrix

| Area | Current State | VibeCoder | MVP | Scale | Unicorn | Gap | Action |
|---|---|---|---|---|---|---|---|
| Boundary enforcement | machine-checked, fatal, 0 нарушений (прогон) | ✅ | ✅ | ✅ | ✅ | нет | KEEP |
| Error model | Either+AppException единый | ✅ | ✅ | ✅ | ✅ | нет | KEEP |
| SecureStorage | encrypted, no plaintext fallback | ✅ | ✅ | ✅ | ✅ | нет | KEEP |
| Env separation | 3 dart-define ключа | ✅ | ✅ | ✅ | ✅ | нет | KEEP |
| Auth login/session/guard/logout | работает, restoration есть | ✅ | ✅ | ✅ | ⚠️ RBAC нет | by design | KEEP |
| Token refresh | каркас 401+refresh, callback не подключён | ⚠️ | ⚠️ | ❌ нужен | ❌ | wiring example | ADD NOW (мелкий) |
| Retry/backoff | полный | ✅ | ✅ | ✅ | ✅ | нет | KEEP |
| Drift persistence | v1, MigrationStrategy каркас | ✅ | ✅ | ⚠️ миграций нет | ⚠️ | migration test | ADD NOW при v2 |
| Observability contracts | 5 контрактов+Noop, swap-in готов | ✅ | ✅ | ✅ | ✅ | имя Crashlytics заглушки | FIX (doc) |
| Testing foundation | 151 тест, зеркало lib/, security test | ✅ | ✅ | ⚠️ integration smoke нет | ⚠️ | smoke | DEFER |
| CI gates | format/analyze/boundary/test/coverage30/apk | ✅ | ✅ | ✅ | ⚠️ secrets scan нет | secrets в CI | ADD NOW (1 строка) |
| AI coding docs | AGENTS/llms/CLAUDE/GEMINI/Cursor/Copilot + rules.dart | ✅ | ✅ | ✅ | ✅ | R-INFRA список пакетов | FIX (расширить) |
| Feature generator | скелет+тесты, Repository Law | ✅ | ✅ | ⚠️ barrel нет | ⚠️ | barrel | FIX |
| Public claims | 128 tests устарело; CI failure публично | ❌ | ❌ | — | — | честность | FIX (sync+push) |
| Package extraction | границы готовы, extraction нет | — | — | ⚠️ | ⚠️ | by design | DEFER |

Легенда Action: KEEP / FIX / ADD NOW / CONTRACT ONLY / EXTENSION POINT / DEFER / REJECT.

## 33. Prioritized Recommendations

P0 (сделать до следующего объявления публичных claims):
1. Обновить счётчик тестов везде (README×4, llms.txt) на актуальный факт.
2. Push локальных коммитов + убедиться в green CI run (снимает публичный failure).
3. Добавить check_secrets.sh шагом в main.yml.
P1 (следующая итерация реализации, мелкие):
4. Refresh wiring example (один файл: пример onTokenRefresh подключения к реальному эндпоинту).
5. Генератор: добавить barrel features/<name>/<name>.dart.
6. Quick Start: строка про build_runner перед analyze/test (+ make gen таргет).
7. SECURITY.md: убрать biometric/rate-limiting из STRIDE или пометить roadmap.
8. R-INFRA: вынести список {dio,drift,sqflite} в константу с комментарием «добавляй свои infra-пакеты».
P2 (при первом реальном schema change): drift migration test шаблон.
Не делать: всё из Intentional Non-Goals.

## 34. What Should NOT Be Added

Подтверждаю список из брифа (§25) как правильный: GetIt, другой DI/state manager, GraphQL, gRPC, event bus, generic Base/ServiceRepository, ESB, микросервисы, monorepo, Kubernetes, cloud infra, Firebase, Sentry, full observability stack, сложный dependency analyzer, обязательный E2E, coverage gates, release automation, package extraction — всё это НЕ добавлять в starter. Каждое из этих решений имеет готовый extension point или контракт.

## 35. Proposed Next Stage

Следующая итерация (после решения Master Architect) — «HONESTY & SMALL FIXES PASS», ~1 день работы:
1. Docs sync: счётчик тестов, SECURITY.md STRIDE формулировки, Quick Start build_runner строка.
2. CI: + check_secrets.sh шаг.
3. Refresh wiring example файл.
4. Generator barrel.
5. Push + verify green CI публично.
Это закрывает весь High/Medium debt без расширения архитектуры. После этого фундамент можно позиционировать как «audit-clean v1.7.2» и переходить к product-задачам.

## 36. Master Architect Decision Request

Требуется решение по 4 вопросам:
1. Согласовать P0-список (рек. §33) как объём следующей итерации — ДА/НЕТ/правки.
2. Token refresh wiring example: добавить сейчас (P1) или отложить до реального бэкенда? Рекомендация: добавить пример с mock-эндпоинтом.
3. Coverage gate 30%: поднимать ли до 50% после docs-sync? Рекомендация: НЕТ, оставить 30% до роста фич.
4. Публичное позиционирование: обновить README claims только фактами из этого аудита? Рекомендация: ДА, одной итерацией с push.

## 37. Final Verdict

Фундамент ЗДОРОВ. Это редкий случай, когда шаблон соответствует своим обещаниям почти полностью: границы machine-enforced и реально работают (проверено прогоном), безопасность by default подтверждена кодом, дешёвый старт обеспечен нулевым vendor lock-in, масштабируемость заложена в правилах, а не в лозунгах.
Не хватает немногого: честной синхронизации цифр с реальностью (тесты), одного CI-шага (secrets), одного примера (refresh wiring) и будущего migration test при первом schema change. Всё остальное — осознанные non-goals, а не дыры.
Оценка по пяти свойствам: EASY 8/10, SAFE 9/10, RELIABLE 8/10, SCALABLE 9/10, CHEAP 10/10.
Готовность стадий: VibeCoder ✅ сегодня; MVP ✅ сегодня; Scale — после P0/P1 списка (≈1 день); Unicorn — архитектурно готов, extraction отложен правильно.
STOP: аудит завершён, следующая итерация определяется Master Architect.

---

*Аудит проведён 2026-08-23 оркестратором Hermes по прямому фактическому исследованию репозитория. Полный CI-цикл выполнен локально 2026-08-23: build_runner = 235 outputs RC=0 → flutter analyze --fatal-infos lib/ test/ = 0 issues RC=0 → flutter test --coverage = 151 tests passed RC=0. Архитектурные границы: dart run tool/check_boundaries.dart = pass, 79 файлов, 0 нарушений.*






