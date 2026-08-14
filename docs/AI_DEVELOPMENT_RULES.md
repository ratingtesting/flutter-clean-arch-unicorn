# AI_DEVELOPMENT_RULES.md — Правила для AI-кодера (Hermes / Claude / Cursor / Copilot)

> Этот файл — контракт между тобой (основатель) и AI-агентом. Агент ОБЯЗАН читать его перед
> каждым изменением. Нарушение = блок коммита.

## 1. Архитектурный закон (HARD STOP)

- **Dependency Rule:** `domain` НЕ импортирует `data` или `presentation`. Никогда.
- **Repository Law:** интерфейс в `domain`, реализация в `data`, datasource ниже. Виджеты/провайдеры НЕ трогают Dio/БД напрямую.
- **Feature-first:** каждая фича = `lib/features/<name>/{data,domain,presentation}`.
- **Feature boundaries:** фича А не импортирует внутренности фичи Б (только доменный интерфейс).

## 2. Безопасность (BLOCKING в Autopilot)

- **Никаких секретов в коде.** Только `--dart-define` / GitHub Secrets.
- **Токены** → `SecureStorage` (flutter_secure_storage), не SharedPreferences.
- **Не удаляй и не ослабляй тесты**, чтобы пройти gate (reward-hacking запрещён).
- **Не выдумывай API/флаги/версии** — проверяй в коде/публичных источниках.

## 3. Zone split (АИ строит, человек решает)

АИ владеет: архитектура, код, тесты, рефакторинг, миграции БД, деплой.
Человек владеет: монетизация, вирусные механики, юнит-экономика, KPI, roadmap, цены.

→ По зоне человека: предложи 2–3 варианта с trade-offs, жди «OK». Никогда не внедряй молча.

## 4. Цикл разработки (loop)

1. Прочитай `AGENTS.md` + `GAP_ANALYSIS.md` перед изменением.
2. Маленькие diff (1 файл / 1 функция) > большие рефакторингы.
3. После каждого write: `read_file` всего файла + `flutter analyze` + `git diff`.
4. Тесты: `flutter test` зелёные ДО коммита.
5. Коммит только если analyze = 0 issues И тесты зелёные.

## 5. Генерация фич

```bash
dart run tool/new_feature.dart <feature_name>
```
Создаёт `data/domain/presentation` + тесты. НЕ пиши фичу руками — используй генератор.

## 6. Честность документации

- Не пиши в README то, чего нет в pubspec/коде.
- Если добавил зависимость — обнови Stack table в README/ARCHITECTURE.
- Если сломал тест — почини КОД, не удаляй тест.

## 7. Verified, not claimed

- «Сделано» = файл на диске + `flutter analyze` чисто + `flutter test` зелёный.
- «Работает» = реальный прогон, не самоотчёт агента.

## 8. Процесс (из SOUL.md)

- Каждый milestone = отдельный commit.
- Пуш в `master` — только с разрешения человека (или по готовности группы milestone-ов).
- Tracking-файлы Keelwright (`PROGRESS.md`, `autoresearch-lessons.md`, `phoenix-log.md`) — НЕ пушить.
