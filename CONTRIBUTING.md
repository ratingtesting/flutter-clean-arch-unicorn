# Contributing to Unicorn Foundation Template

Спасибо, что хотите улучшить этот шаблон! 🦄

## Быстрый старт

```bash
git clone https://github.com/your-org/flutter_clean_arch_unicorn.git
cd flutter_clean_arch_unicorn
flutter pub get
flutter test           # должно быть 96/100 passing (4 known edge-case failures in dashboard search)
flutter analyze lib/   # 0 errors, 0 warnings
```

## Git Flow

- `main` — стабильная ветка, только теги релизов (`v1.2.0`, `v1.3.0`...)
- Feature branches: `feat/<short-description>` (например, `feat/offline-sync`)
- Bugfix branches: `fix/<short-description>` (например, `fix/pagination-edge-case`)
- PR в `main` → обязательный CI (analyze, format, test)
- После мержа — новый git tag: `v<major>.<minor>.<patch>`

## Conventional Commits

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat` — новая фича для пользователя шаблона
- `fix` — баг в шаблоне
- `docs` — только документация
- `refactor` — рефакторинг без изменения поведения
- `test` — добавление/исправление тестов
- `chore` — CI, deps, tooling
- `style` — форматирование, переносы строк

Scopes (examples): `auth`, `dashboard`, `network`, `security`, `ci`, `docs`, `deps`.

Examples:
```
feat(auth): add biometric login option
fix(network): retry interceptor handles 429 correctly
docs(readme): update quickstart for Windows
refactor(security): extract SecureStorage interface
test(dashboard): add pagination edge-case coverage
chore(ci): pin flutter 3.44.8 in workflow
```

## PR Checklist

- [ ] `flutter analyze lib/` — 0 errors, 0 warnings
- [ ] `dart format --set-exit-if-changed .` — no diff
- [ ] `flutter test` — все тесты проходят (известные 4 фейла в dashboard search — documented, не блокируют)
- [ ] Тесты добавлены для новой логики (domain layer — обязательно)
- [ ] Документация обновлена (README, ARCHITECTURE.md, CHANGELOG.md если нужно)
- [ ] Нет hardcoded secrets / API keys / доменов
- [ ] Clean Architecture Dependency Rule не нарушена (domain не зависит от data/presentation)

## Adding a New Feature

1. Создайте папку `lib/features/<feature_name>/` с подпапками `data/`, `domain/`, `presentation/`
2. Domain: интерфейсы (Repository, UseCase), модели (Freezed), Either для ошибок
3. Data: реализация RepositoryImpl, DataSource (Remote/Local), DTO с json_serializable
4. Presentation: Notifier/AsyncNotifier (Riverpod 3), UI виджеты, GoRouter route
5. Тесты: unit для domain, widget для presentation
6. Зарегистрируйте провайдеры в `lib/features/<feature_name>/presentation/providers/`
7. Добавьте route в `lib/routes/app_router.dart`

## Code Style

- **Dart formatter** — единственный источник истины (`dart format .`)
- **Lint** — `flutter analyze` с `analysis_options.yaml` проекта
- **Naming**: `PascalCase` типы, `camelCase` переменные/функции, `snake_case` файлы
- **Imports**: `package:` сначала, потом `dart:`, потом относительные; сортировка по алфавиту внутри групп

## Reporting Issues

- **Bug**: шаги воспроизведения, ожидаемое/фактическое поведение, `flutter --version`, OS
- **Feature Request**: use-case, почему это в шаблоне, а не в приложении пользователя
- **Security**: приватно в `SECURITY.md` контакты

## License

MIT-0 (public domain equivalent). See [LICENSE](LICENSE).