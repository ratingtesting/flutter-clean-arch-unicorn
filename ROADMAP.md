# ROADMAP.md — VibeCoder → MVP → Scale → Unicorn

Путь от «я не кодер, но хочу продукт» до «1M+ пользователей без переписывания фундамента».

## Stage 0 — VibeCoder (Day 0, ты сейчас здесь)

**Кто:** основатель без команды, использует AI-агента (Hermes/Claude/Cursor) для генерации кода.
**Что есть:** этот шаблон + AI-агент, читающий `AGENTS.md` / `llms.txt`.

| Задача | Как | Почему |
|--------|-----|--------|
| Генерировать фичи | `dart run tool/new_feature.dart <name>` | Создаёт feature-first модуль + тесты за секунды |
| Проверять сборку | `flutter analyze lib/ test/ --fatal-infos` | Ловит ошибки до коммита |
| Запускать тесты | `flutter test` | 119 тестов подтверждают, что ничего не сломано |
| Менять API/БД/UI | Реализовать доменный интерфейс в `data/` | Бизнес-логика (`domain`) не меняется |

**Риск:** AI-агент может сгенерировать код, нарушающий Dependency Rule. Защита — CI (`flutter analyze`) + `GAP_ANALYSIS.md`.

## Stage 1 — MVP (Month 1–3)

**Цель:** запустить продукт, получить первых 100–1K пользователей.

- [ ] Подключить реальный бэкенд (заменить `NetworkService` на свой API)
- [ ] Реализовать `ErrorReporter` (Sentry/Crashlytics) вместо `NoopErrorReporter`
- [ ] Реализовать `AnalyticsTracker` (PostHog/Amplitude)
- [ ] Включить Certificate Pinning (когда бэкенд готов)
- [ ] Написать первые widget-тесты критических экранов
- [ ] Настроить coverage gate в CI (lcov)

## Stage 2 — Scale (Month 3–12)

**Цель:** 10K–100K пользователей, команда растёт.

- [ ] Feature Flags (Remote Config) — выкатывать фичи без деплоя
- [ ] Offline-first: расширить Drift-кэш (`SyncEngine`, conflict resolution)
- [ ] Push-уведомления (FCM) — абстракция в `services/`
- [ ] i18n (arb + intl)
- [ ] Deep Links в GoRouter
- [ ] Accessibility (semantics, contrast)

## Stage 3 — Unicorn (Year 1–2)

**Цель:** 1M+ пользователей, несколько команд.

- [ ] BFF (Backend for Frontend) — уменьшить число API-вызовов
- [ ] Performance Monitoring (Firebase Performance / кастомные трейсы)
- [ ] Phased rollout (5% → 25% → 100%) с метриками крашей
- [ ] Fastlane (match, gym, pilot, deliver) — автоподписание и деплой
- [ ] АвтоЧейнджлог из conventional-commits

## Принцип

**Каждое изменение стоит дёшево**, потому что:
- Структура понятна новому разработчику за 30 минут
- Тесты ловят баги до продакшена
- CI не даёт сломать `main`
- Добавить фичу = создать папку, не переписывая систему
- Секреты никогда не попадают в git
- Crash-метрики видны сразу (когда подключишь ErrorReporter)
- A/B-тесты без деплоя (когда подключишь Feature Flags)

Рост: от соло-проекта до команды 5–10 разработчиков — структура масштабируется без переписывания.
