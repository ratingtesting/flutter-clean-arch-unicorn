# PACKAGE_EXTRACTION.md — Как вытащить этот шаблон в отдельный пакет

> Требование §13: «каждый модуль должен быть доступен как отдельный Dart-пакет (publishable to pub.dev)».
> Текущий статус: **НЕ реализовано**. Шаблон — монорепо, а не набор пакетов. Ниже — план, а не факт.

## Почему это ещё не сделано

- Модули (`services/`, `shared/`, `core/`) — внутренние папки, не `@usableFrom` pub-пакеты.
- `pubspec.yaml` один на весь проект; нет `<module>/pubspec.yaml` с `publish_to: none`.
- Межмодульные импорты идут через `package:flutter_clean_arch_unicorn/...`, а не через отдельные пакеты.

## План извлечения (когда понадобится)

### Шаг 1 — выделить `core` в пакет
```
packages/unicorn_core/
  pubspec.yaml          # name: unicorn_core, publish_to: none
  lib/
    database/           # AppDatabase, tables, connection
    ...
```
Импорт меняется: `package:flutter_clean_arch_unicorn/core/database` → `package:unicorn_core/database`.

### Шаг 2 — выделить `services` (observability, security, network)
Каждый — отдельный пакет с интерфейсами + Noop-реализациями.

### Шаг 3 — выделить `shared` (models, exceptions, Either)
Базовые типы → `unicorn_shared`.

### Шаг 4 — app зависит от пакетов
```yaml
# app/pubspec.yaml
dependencies:
  unicorn_core:
    path: ../packages/unicorn_core
  unicorn_services:
    path: ../packages/unicorn_services
```

## Честный статус

| Модуль | Extractable today? | Что нужно |
|--------|-------------------|-----------|
| `core/database` (Drift) | Частично | Вынести в `packages/unicorn_core`, поправить импорты |
| `services/*` | Нет | Разбить на пакеты, убрать зависимость от app-специфичного |
| `shared/*` | Частично | Вынести `Either`/`Response`/`HttpException` в `unicorn_shared` |
| `features/*` | Нет | Фичи зависят от app-контекста (routing, env) |

## Рекомендация

Для **стартапа-шаблона** monorepo предпочтительнее: проще клонировать, нет overhead на versioning пакетов.
Package-extraction имеет смысл, когда ты начнёшь переиспользовать модули в **других** проектах.
До этого — не трать время (см. ROADMAP.md, Stage 2+).
