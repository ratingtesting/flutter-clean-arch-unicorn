# UNICORN STARTUP FOUNDATION TEMPLATE — ТРЕБОВАНИЯ

## Философия
> Инвестиции в архитектуру **СЕЙЧАС** → стоимость изменений **В БУДУЩЕМ** минимальна.
> Шаблон — не "стартовый код", а **контракт** с будущим: любая фича добавляется без рефакторинга фундамента.

---

## 1. АРХИТЕКТУРНЫЕ НЕПРЕРЫВНЫЕ (Hard Constraints)

| Требование | Критерий готовности | Почему для единорога |
|------------|---------------------|----------------------|
| **Clean Architecture** (Dependency Rule) | `graphify query "violation"` → 0 | Бизнес-логика не знает о Flutter, Dio, SharedPreferences. Смена БД/API/UI — локальная правка. |
| **Feature-first модульность** | Каждая фича: `data/domain/presentation` изолированно | Команды работают параллельно без конфликтов. Новая фича = новая папка, не трогая чужие. |
| **Riverpod 3 + Notifier** | `StateNotifier` отсутствует, только `Notifier`/`AsyncNotifier` | Компиляторная безопасность, нет `state =`, есть `state = newState`. Тестируемо без провайдеров. |
| **GoRouter (декларативный)** | `auto_route` отсутствует | Маршруты — данные, а не код. Deeplinks, redirects, guards — в одном месте. |
| **Freezed + json_serializable** | Все DTO/State immutable, `fromJson`/`toJson` генерируются | Нет ручного парсинга. Добавление поля = 1 строка в модели + `build_runner`. |

---

## 2. БЕЗОПАСНОСТЬ И ПРИВАТНОСТЬ (Security by Default)

| Требование | Реализация | Зачем |
|------------|------------|-------|
| **Нет секретов в коде** | `.env` только в `.gitignore`, CI секреты в GitHub Secrets | Утечка ключей = смерть стартапа. |
| **Certificate Pinning** | `dio` interceptor с `badCertificateCallback` | MITM на публичных Wi-Fi — вектор атаки №1. |
| **Encrypted Local Storage** | `flutter_secure_storage` для токенов, биометрия | Токены в SharedPreferences — мгновенный компромисс. |
| **App Integrity** | `flutter_app_auth` / Play Integrity / App Attest | Подмена бинарника / рут-детект. |
| **Network Security Config** | `res/xml/network_security_config.xml` (Android) | Cleartext трафик запрещён на уровне ОС. |

---

## 3. НАБЛЮДАЕМОСТЬ (Observability) — "Не лети вслепую"

| Слой | Инструмент | Абстракция в шаблоне |
|------|------------|----------------------|
| **Логирование** | `logger` пакет | `AppLogger` интерфейс → `ConsoleLogger` / `SentryLogger` / `DatadogLogger` |
| **Краш-репортинг** | Sentry / Firebase Crashlytics | `ErrorReporter` интерфейс, инициализация в `main_<env>.dart` |
| **Аналитика** | Amplitude / Mixpanel / PostHog | `AnalyticsTracker` интерфейс, `track(event, props)` |
| **Производительность** | Firebase Performance / custom | `PerformanceMonitor` — trace сетевых вызовов, рендеров |
| **Feature Flags** | Firebase Remote Config / LaunchDarkly | `FeatureFlags` провайдер, `bool isEnabled('new_checkout')` |

---

## 4. ОФФЛАЙН-FIRST И СИНХРОНИЗАЦИЯ

| Возможность | Реализация |
|-------------|------------|
| **Локальный кэш** | `ObjectBox` / `Drift` (SQLite) — репозиторий пишет локально, потом синкает |
| **Optimistic UI** | State сразу обновляется, в фоне `Either<Failure, Success>` |
| **Conflict Resolution** | `last-write-wins` / server-wins / merge стратегии в `SyncEngine` |
| **Background Sync** | `workmanager` / `flutter_background_service` — периодическая синка |

---

## 5. CI/CD — "Зелёный main = готово к релизу"

| Этап | Команда | Гейт |
|------|---------|------|
| **Analyze** | `flutter analyze --fatal-infos` | 0 ошибок, 0 warnings (strict) |
| **Format** | `dart format --set-exit-if-changed .` | Нет diff |
| **Test** | `flutter test --coverage` | 100% unit coverage на domain, >80% overall |
| **Build** | `flutter build apk --release` / `flutter build ios --release` | Артефакты собраны |
| **Security** | `dart run dependency_validator` / `snyk test` | Нет критических CVE |
| **Deploy** | Fastlane → Play Console / TestFlight / Firebase App Distribution | Ручной approve для PROD |

---

## 6. ДЕПЛОЙ И РЕЛИЗЫ

| Артефакт | Автоматизация |
|----------|---------------|
| **Versioning** | `semver` из git tags (`v1.2.3`), `build_number` = CI run number |
| **Changelog** | `conventional-commits` → `auto-changelog` |
| **Code Signing** | Fastlane `match` (iOS), `keystore` в CI secrets (Android) |
| **Rollout** | Поэтапный (5% → 25% → 100%) с метриками крашей |

---

## 7. РАСШИРЯЕМОСТЬ БЕЗ РЕФАКТОРИНГА (Open/Closed)

| Паттерн | Где применяется |
|---------|-----------------|
| **Repository Interface** | Domain определяет `UserRepository`, Data даёт `UserRepositoryImpl(Supabase)` / `UserRepositoryImpl(GraphQL)` |
| **Strategy** | `PaymentStrategy` — Stripe/ApplePay/GooglePay добавляются без правки `CheckoutUseCase` |
| **Plugin Architecture** | `AnalyticsTracker` — новый провайдер = реализация интерфейса + регистрация в `main.dart` |
| **Middleware Pipeline** | Dio interceptors: auth → logging → retry → pinning — каждый независим |

---

## 8. ДОКУМЕНТАЦИЯ КАК КОД

| Файл | Назначение |
|------|------------|
| `README.md` | Quickstart, структура, команды, CI, troubleshooting |
| `ARCHITECTURE.md` | Dependency Rule, слои, границы, как добавлять фичу |
| `CONTRIBUTING.md` | Git flow, commit convention, PR checklist |
| `SECURITY.md` | Threat model, секреты, инцидент-реакция |
| `docs/adr/` | Architecture Decision Records (по одному на решение) |

---

## 9. ЧТО УЖЕ ЕСТЬ В V3 (ГОТОВО ✅)

- [x] Clean Architecture (data/domain/presentation) — 0 нарушений
- [x] Riverpod 3.4.1 + Notifier + AsyncNotifier
- [x] GoRouter 16.3.0
- [x] Freezed 3.2.5 + json_serializable
- [x] Either<T, R> для функциональной обработки ошибок
- [x] Dio network layer с абстракцией `NetworkService`
- [x] SharedPreferences абстракция `StorageService`
- [x] Feature-first структура: `auth`, `dashboard`, `splash`, `user_cache`
- [x] Environment entrypoints: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`
- [x] 73/73 тестов проходят (unit + widget)
- [x] `flutter analyze` = 0 errors
- [x] GitHub Actions workflow (analyze, test, format)
- [x] Git tags v1.0.0–v1.1.0
- [x] README.md + ARCHITECTURE.md (224 строки)

---

## 10. ЧТО НУЖНО ДОБАВИТЬ (BACKLOG ДЛЯ ЕДИНОРОГА)

### 🔴 Critical (Без этого — не продакшн)
- [ ] **Certificate Pinning** (Dio interceptor)
- [ ] **Encrypted Storage** (`flutter_secure_storage` для токенов)
- [ ] **Error Reporter** абстракция + Sentry/Crashlytics реализация
- [ ] **Logger** абстракция + консольная/продакшн реализации
- [ ] **Network Security Config** (Android XML)

### 🟡 High (Рост команды / масштаб)
- [ ] **Analytics Tracker** абстракция + Amplitude/PostHog
- [ ] **Feature Flags** (Remote Config)
- [ ] **Offline-first** локальная БД (Drift/ObjectBox) + SyncEngine
- [ ] **Deep Links** обработка в GoRouter
- [ ] **Push Notifications** (FCM) абстракция
- [ ] **i18n** (arb файлы, `intl` генерация)
- [ ] **Accessibility** (semantics, контраст, масштабирование)

### 🟢 Medium (Качество жизни)
- [ ] **Fastlane** конфиг (match, gym, pilot, deliver)
- [ ] **Coverage thresholds** в CI (lcov + genhtml)
- [ ] **Dependency Validator** (запрет `dev_dependencies` в prod коде)
- [ ] **Performance Monitoring** (Firebase Performance / custom traces)
- [ ] **ADR** шаблон и первый запись (почему Riverpod, почему GoRouter, почему Freezed)

---

## 11. МЕТРИКИ УСПЕХА ШАБЛОНА

| Метрика | Target | Как измерить |
|---------|--------|--------------|
| **Time to First Feature** | < 30 мин | Новичок добавляет "Hello Feature" (CRUD) |
| **Time to Prod Build** | < 15 мин | `flutter build apk --release` на чистом CI |
| **Onboarding New Dev** | < 2 часа | Читает README + ARCHITECTURE → пушит фичу |
| **Refactor Cost** | O(1) на фичу | Смена API / БД / UI не трогает domain |
| **Test Feedback Loop** | < 60 сек | `flutter test` на ноутбуке |

---

## 12. ПРИНЦИПЫ РЕШЕНИЯ КОНФЛИКТОВ (Decision Framework)

Когда "хочется сделать иначе" — чек-лист:

1. **Нарушает ли это Dependency Rule?** → НЕТ (hard stop)
2. **Увеличит ли это Time-to-First-Feature для следующей команды?** → НЕТ
3. **Можно ли откатить это за 1 коммит?** → ДА (feature flag / interface swap)
4. **Есть ли ADR?** → Если решение неочевидное — пишем ADR

---

*Этот документ — живой. Каждое архитектурное решение фиксируется в `docs/adr/YYYY-MM-DD-<slug>.md`.*