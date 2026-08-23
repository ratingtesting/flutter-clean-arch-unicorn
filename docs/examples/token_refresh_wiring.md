# Token Refresh — Wiring Example

> `AuthTokenInterceptor` умеет автоматически обновлять токен при 401 «из коробки»,
> но ему нужен ОДИН колбэк: где брать новый токен. Этот файл показывает, как
> подключить его к реальному бэкенду за ~10 строк.

## Как это работает

1. Любой запрос получает 401 от API.
2. Interceptor читает `refresh_token` из SecureStorage.
3. Вызывает ВАШ колбэк `onTokenRefresh(refreshToken)`.
4. Если вернулся новый access-токен — сохраняет его и **повторяет исходный запрос**.
5. Если нет — стирает все учётные данные (принудительный logout).

Без подключённого колбэка interceptor просто пропустит 401 дальше
(безопасное поведение по умолчанию).

## Шаг 1. Функция обновления токена

```dart
// lib/features/authentication/data/datasource/token_refresh.dart
import 'package:dio/dio.dart';
import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';

/// Calls POST /auth/refresh and returns a new access token, or null on failure.
Future<String?> refreshTokenCall(String refreshToken) async {
  try {
    // Отдельный Dio БЕЗ AuthTokenInterceptor — иначе refresh сам получит 401 и зациклится.
    final dio = Dio(BaseOptions(baseUrl: EnvInfo.connectionString));
    final res = await dio.post('/auth/refresh', data: {'refresh': refreshToken});
    return res.data['access'] as String?;
  } on DioException {
    return null; // interceptor сотрёт креды → logout
  }
}
```

## Шаг 2. Подключение при сборке Dio

Там, где вы создаёте `AuthTokenInterceptor`, передайте колбэк:

```dart
final authInterceptor = AuthTokenInterceptor(
  secureStorage: ref.watch(secureStorageProvider),
  logger: ref.watch(loggerProvider),
  onTokenRefresh: refreshTokenCall, // ← единственная новая строка
);
```

## Что НЕ надо делать

- Не вызывайте `/auth/refresh` через тот же Dio с этим интерцептором — получите цикл.
- Не храните refresh-токен в SharedPreferences — только SecureStorage.
- Не возвращайте непустую строку при неудаче — null означает logout.

## Проверка

После подключения: протухший access-токен + валидный refresh → запрос
повторяется автоматически, пользователь ничего не заметит.
Невалидный refresh → данные стираются → GoRouter guard отправляет на /login.

---

*Пример сознательно живёт в docs/, а не в lib/: starter не навязывает форму
refresh-эндпоинта. Когда у вас появится реальный бэкенд — скопируйте шаги 1–2.*
