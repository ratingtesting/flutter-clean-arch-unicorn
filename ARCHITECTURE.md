# Шаблон «Фундамент Стартапа Единорога»

> v1.2.0 | Flutter 3.44.8 | Riverpod 3.4.1 | GoRouter | Freezed 3.2.5

## Для кого

Солофаундер без программирования, который строит стартап с нуля.
Шаблон создан так, чтобы **редактировать и содержать проект было дешевле**, чем при использовании других решений. Первоначальные затраты выше (архитектура, тесты, CI), но стоимость изменений в будущем — минимальна.

---

## Требования к шаблону-фундаменту

| # | Требование | Зачем | Реализация |
|---|-----------|-------|-----------|
| 1 | **Низкая стоимость изменений** | Новый фичер / правка не должны стоить дорого | Feature-first Clean Architecture: каждый фичер изолирован |
| 2 | **Безопасность по умолчанию** | Секреты, ключи, конфиги — никогда в коде | `--dart-define`, SecureStorage, Certificate Pinning |
| 3 | **Тестируемость** | Тесты ловят баги до продакшена | 100+ тестов (ProviderContainer + mock) |
| 4 | **CI/CD из коробки** | Автоматические проверки на каждый PR | GitHub Actions: analyze + test + format |
| 5 | **Масштабируемость** | Стартап растёт → добавляются фичи, команды | Feature-first: новый фичер = новая папка |
| 6 | **Наблюдаемость** | Видеть крахи, аналитику, логи в продакшене | Logger, Crashlytics, Analytics, Remote Config |
| 7 | **Оффлайн-first** | Работа без интернета, синк в фоне | sqflite локальная БД, optimistic UI |
| 8 | **Быстрый онбординг** | Новый разработчик понимает за 30 минут | README, ARCHITECTURE.md,.folder_structure |

---

## Архитектура: Feature-First Clean Architecture

```
lib/
├── configs/                  # Глобальные конфиги (AppConfigs)
├── features/                 # Изолированные фичи
│   ├── authentication/       # Пример фичи
│   │   ├── data/             # Реализации (API, DB, репозитории)
│   │   ├── domain/           # Бизнес-логика (интерфейсы репозиториев, use cases)
│   │   └── presentation/     # UI и провайдеры (screens, widgets, providers)
│   ├── dashboard/            # Другая фича — та же структура
│   └── splash/               # Экран загрузки
├── main/                     # Entry points (main_dev, main_staging, main_prod)
├── routes/                   # GoRouter конфигурация
├── services/
│   ├── observability/        # Logger, ErrorReporter, Analytics
│   ├── security/             # SecureStorage, CertificatePinning
│   ├── network/              # Interceptors (retry, auth, logging)
│   └── database/             # Local SQLite cache
└── shared/                   # Общий код (models, theme, exceptions, widgets)
```

### Правило зависимостей (Dependency Rule)

Зависимости направлены **внутрь**:
```
presentation → domain ← data
     ↓            ↑        ↓
  провайдеры   бизнес-   репозитории
  (Riverpod)   логика    (реализации)
```

- **domain** НЕ знает про data и presentation
- **data** реализует интерфейсы из domain
- **presentation** использует провайдеры и бизнес-модели

---

## Сервисы наблюдаемости (Observability)

| Сервис | Интерфейс | Реализация (prod) | Реализация (dev/test) |
|--------|-----------|-------------------|----------------------|
| Логирование | `AppLogger` | `ConsoleLogger` | `NoopLogger` |
| Краш-репортинг | `ErrorReporter` | `CrashlyticsReporter` | `NoopErrorReporter` |
| Аналитика | `AnalyticsTracker` | `FirebaseAnalyticsTracker` | `NoopAnalyticsTracker` |
| Feature Flags | `FeatureFlags` | `RemoteConfigFeatureFlags` | `StaticFeatureFlags` |
| Secure Storage | `SecureStorage` | `SecureStorageImpl` (encrypted) | `SecureStorageFake` |

### Использование

```dart
// В любом провайдере/нотификаторе:
final logger = ref.watch(loggerProvider);
logger.info('User logged in', data: {'userId': user.id});

// Error reporting:
final reporter = ref.watch(errorReporterProvider);
await reporter.recordError(error, stackTrace, reason: 'Login failed');

// Analytics:
final analytics = ref.watch(analyticsProvider);
await analytics.track('purchase_completed', properties: {'amount': 99.99});

// Feature flags:
final flags = ref.watch(featureFlagsProvider);
if (flags.isEnabled('new_checkout_flow')) {
  // показать новый чекаут
}
```

---

## Безопасность (Security)

| Компонент | Защита |
|-----------|--------|
| **Токены** | `flutter_secure_storage` (iOS Keychain / Android EncryptedSharedPreferences) |
| **API ключи** | `--dart-define=API_KEY=...` — никогда в коде |
| **Network** | Certificate Pinning + Network Security Config (Android XML) |
| **Cleartext** | HTTP запрещён (cleartextTrafficPermitted=false) |
| **MITM** | SHA-256 fingerprints проверяются на каждом запросе |

---

## Стек технологий (актуальные версии)

| Компонент | Пакет | Версия | Зачем |
|----------|-------|--------|-------|
| Framework | flutter | 3.44.8 | Мультиплатформа |
| State Management | flutter_riverpod | 3.4.1 | Compile-time safe DI |
| Navigation | go_router | 16.3.0 | Декларативная, deep links |
| Code Generation | freezed | 3.2.5 | Immutable модели |
| HTTP | dio | 5.11.0 | Сетевые запросы |
| Security | flutter_secure_storage | 10.0.0 | Encrypted token storage |
| Observability | firebase_crashlytics | 4.0.0 | Краш-репортинг |
| Analytics | firebase_analytics | 11.0.0 | Событийная аналитика |
| Feature Flags | firebase_remote_config | 5.0.0 | A/B тесты, роллаут |
| Local DB | sqflite | 2.3.0 | Оффлайн кэш |
| Logging | logger | 2.5.0 | Структурированные логи |

---

## Тесты

```bash
flutter test                      # все тесты (100+)
flutter test --coverage           # с покрытием
```

### Паттерн тестирования

```dart
test('should load data', () async {
  final repo = MockRepository();
  final container = ProviderContainer(overrides: [
    repositoryProvider.overrideWithValue(repo),
  ]);
  final notifier = container.read(myProvider.notifier);
  
  when(() => repo.fetchData()).thenAnswer((_) async => Right(testData));
  await notifier.fetch();
  
  expect(notifier.state.data, testData);
});
```

---

## CI/CD (GitHub Actions)

На каждый PR и push в main:
1. `flutter pub get` — зависимости
2. `dart format --set-exit-if-changed .` — форматирование
3. `flutter analyze lib/` — статический анализ (0 errors)
4. `flutter test` — все тесты

При нарушении — PR не мержится. Качество гарантировано.

---

## Философия

> **Тратим больше времени СЕЙЧАС, чтобы тратить меньше В БУДУЩЕМ.**

Чистая архитектура, тесты, CI — это не «избыточность». Это инвестиция.
Стартап, который экономит на архитектуре, платит за это потом — медленными релизами, багами в продакшене, страхом менять код.

Шаблон «Фундамент Единорога» — это основа, где **каждое изменение стоит дешевле**, потому что:
- Структура понятна новому разработчику за 30 минут
- Тесты ловят баги до продакшена
- CI не даёт сломать main
- Добавление фичи = создание папки, не переписывание системы
- Секреты никогда не попадают в git
- Крахи видны мгновенно (Crashlytics)
- A/B тесты запускаются без деплоя (Remote Config)

**Потенциал для масштабирования**: от соло-проекта до команды из 5-10 разработчиков — структура выдерживает без переписывания.

---

## Дополнительные документы

- [UNICORN_FOUNDATION_REQUIREMENTS.md](./UNICORN_FOUNDATION_REQUIREMENTS.md) — полное описание требований