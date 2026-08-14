# OPEN_SOURCE_GROWTH_AUDIT.md

> Отдельный аудит для открытого GitHub-репозитория (§31 мастер-промпта).
> Цель: максимизировать органический discovery / stars / forks / reuse.
> Не используем накрутку, fake stars, misleading claims (§3).

## Текущее состояние (проверено 2026-08-14)

| Элемент | Статус | Комментарий |
|---------|--------|--------------|
| Repository name | PRESENT | `flutter-clean-arch-unicorn` — чёткое, с ключевыми словами |
| Description | PRESENT | "🦄 Production-ready Flutter template: Clean Architecture, Riverpod 3, Drift, 119 tests, CI/CD, security-by-default. AI-agent ready (AGENTS.md, llms.txt). Use as GitHub template." — без ложных claims |
| Topics | PRESENT | flutter, riverpod, drift, clean-architecture, feature-first, go-router, freezed, dio, scalable, vibe-coding, ai-coding, startup, production-ready, agents-md, llms-txt, mvp, dart, ci-cd, ai-agents (19 шт, без спама) |
| README Quick Start | PRESENT | clone → pub get → run |
| Feature list | PRESENT | README + ARCHITECTURE |
| Architecture diagram | PRESENT | mermaid diagram в README (§32, строка ~201) |
| Examples | PARTIAL | example feature (dashboard) в коде; нет отдельного examples/ |
| Roadmap | PRESENT | README "Roadmap to Unicorn" + docs/IMPLEMENTATION_ROADMAP.md |
| Changelog | PRESENT | CHANGELOG.md |
| Contributing | PRESENT | CONTRIBUTING.md |
| Issue templates | PARTIAL | базовые есть, не все типы |
| PR template | PRESENT | `.github/pull_request_template.md` |
| Security policy | PRESENT | SECURITY.md |
| License | PRESENT | MIT-0 LICENSE |
| Release strategy | PRESENT | semantic versioning, v1.4.0 (после v1.3.1) |
| Badges | PARTIAL | CI badge можно добавить (P1) |

## GitHub SEO (§33)

Естественные термины присутствуют в name/description/topics/README:
Flutter, Dart, starter, template, clean architecture, feature-first, Riverpod,
GoRouter, Freezed, Dio, Drift, startup, scalable, production-ready, AI coding,
Vibe Coding. Спам отсутствует.

## Top-5 органического роста (приоритеты P1)

1. **CI badge** в README — социальное доказательство качества.
2. **Screenshots/GIF** стартового экрана — визуальная привлекательность (если полезно).
3. **Issue templates** (bug/feature/docs) — снижает трение для контрибьюторов.
4. **Discussions / Community** — включить GitHub Discussions для Q&A.
5. **Examples/** отдельная папка с минимальным примером фичи — снижает порог входа.

## Что НЕ делаем (§3)

- ❌ Fake stars / накрутка
- ❌ Misleading claims ("100% tests", "enterprise-ready" без оснований)
- ❌ Spam keywords

## Итог

Репозиторий **discoverable и честный**. Главный недостающий элемент для
конверсии посетителя в star/fork — **architecture diagram** (mermaid) в README.
