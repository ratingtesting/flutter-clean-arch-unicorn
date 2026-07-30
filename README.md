# 🦄 Фундамент Стартапа Единорога

> **Flutter Clean Architecture + Riverpod 3 | v1.2.0**

Шаблон Flutter-проекта, спроектированный для длительной и дешёвой поддержки.
Чистая архитектура, Riverpod 3, GoRouter, тесты — чтобы **изменения обходились дёшево** на всём жизненном цикле продукта.

[![AGPL-3.0](https://img.shields.io/badge/License-AGPL%203.0-blue.svg)](LICENSE)

---

## Стек

| Компонент | Пакет | Версия |
|-----------|-------|--------|
| Framework | Flutter | 3.44.8 |
| State Management | flutter_riverpod | 3.4.1 |
| Navigation | go_router | 16.3.0 |
| Code Generation | freezed | 3.2.5 |
| HTTP Client | dio | 5.11.0 |
| Security | flutter_secure_storage | 10.0.0 |
| Observability | firebase_crashlytics, firebase_analytics, firebase_remote_config |
| Local DB | sqflite | 2.3.0 |
| Logging | logger | 2.5.0 |

## Структура

```
lib/
├── configs/              # Глобальные конфиги (AppConfigs)
├── features/             # Изолированные фичи
│   ├── authentication/   # data/domain/presentation
│   ├── dashboard/        # data/domain/presentation
│   └── splash/           # Загрузочный экран
├── main/                 # Entry points (dev/staging/prod)
├── routes/               # GoRouter (app_router.dart)
├── services/
│   ├── observability/    # Logger, ErrorReporter, Analytics
│   ├── security/         # SecureStorage, CertificatePinning
│   ├── network/          # Interceptors (retry, auth, logging)
│   └── database/         # Local SQLite cache
└── shared/               # Модели, тема, exceptions, widgets
```

Каждая фича — автономный модуль: `data/` (реализации), `domain/` (бизнес-логика), `presentation/` (UI + провайдеры).

## Быстрый старт

```bash
# Установить зависимости
flutter pub get

# Запустить в режиме разработки
flutter run

# Запустить production
flutter run -t lib/main/main_prod.dart

# Свой API endpoint
flutter run --dart-define=BASE_URL=https://my-api.com
```

## Окружения

| Entry point | Назначение |
|-------------|-----------|
| `lib/main.dart` | Development (по умолчанию) |
| `lib/main/main_dev.dart` | Dev-сборка |
| `lib/main/main_staging.dart` | Staging |
| `lib/main/main_prod.dart` | Production |

## Тестирование

```bash
flutter test              # все тесты
flutter test --coverage   # с покрытием
```

Паттерн: ProviderContainer + mocktail, каждый провайдер тестируется изолированно.

## CI/CD

GitHub Actions на каждый PR:
1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze lib/` (0 errors)
4. `flutter test`

## Требования к среде

- **Flutter SDK** 3.44.8+ (`/c/dev/tools/flutter/bin`)
- **Android SDK** (platforms/android-34, set `ANDROID_HOME` или `local.properties`)
- **JDK** 17+ (для Android-сборки)

## Версионирование

Git с семантическими тегами (`v1.0.0`, `v1.1.0`). Каждое изменение — коммит + тег.

---

## 🚀 Roadmap to Unicorn

This template is your **Day 0 foundation**. Here's how to scale it as you grow:

| Stage | Users | What to add | Why |
|-------|-------|-------------|-----|
| **Day 0** | 0-100 | ✅ Template as-is | Validate idea, no cost |
| **Month 1** | 100-1K | Firebase Analytics + Crashlytics | Know what breaks |
| **Month 3** | 1K-10K | Offline-first (Drift/Hive) | Work without internet |
| **Month 6** | 10K-100K | Push Notifications (FCM) | Re-engage users |
| **Year 1** | 100K+ | Feature Flags (Firebase Remote Config) | Ship without deploying |
| **Year 2** | 1M+ | BFF (Backend for Frontend) | Reduce API calls |

**Key principle:** Replace `Noop` implementations in `lib/services/` with real ones when needed. The interfaces are already there.

---

## 🛠️ Quick Commands (Windows)

Use `make.bat` for common tasks:

```bash
make.bat setup      # Install dependencies
make.bat check      # Analyze + Test + Format
make.bat test       # Run all tests
make.bat run-dev    # Start dev environment
make.bat build-apk  # Build Android APK
```

---

Подробнее: [ARCHITECTURE.md](./ARCHITECTURE.md) | [UNICORN_FOUNDATION_REQUIREMENTS.md](./UNICORN_FOUNDATION_REQUIREMENTS.md)