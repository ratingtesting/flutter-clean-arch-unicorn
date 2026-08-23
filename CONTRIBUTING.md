# Contributing to Flutter Clean Arch Unicorn

Thank you for wanting to improve this template! 🦄

## Quick Start

```bash
git clone https://github.com/ratingtesting/flutter-clean-arch-unicorn.git
cd flutter_clean_arch_unicorn
flutter pub get
flutter test           # should be 151 passing
flutter analyze lib/ test/   # 0 issues (--fatal-infos)
```

## Git Flow

- `master` — stable branch, release tags only (`v1.7.0`, `v1.6.0`...)
- Feature branches: `feat/<short-description>` (e.g., `feat/offline-sync`)
- Bugfix branches: `fix/<short-description>` (e.g., `fix/pagination-edge-case`)
- PR into `master` → mandatory CI (analyze, format, test)
- After merge → new git tag: `v<major>.<minor>.<patch>`

## Conventional Commits

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat` — new feature for template users
- `fix` — bug in the template
- `docs` — documentation only
- `refactor` — refactoring without behavior change
- `test` — adding/fixing tests
- `chore` — CI, deps, tooling
- `style` — formatting, line breaks

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

- [ ] `flutter analyze lib/ test/ --fatal-infos` — 0 issues
- [ ] `dart format --set-exit-if-changed .` — no diff
- [ ] `flutter test` — all tests pass (151)
- [ ] Tests added for new logic (domain layer required)
- [ ] Documentation updated (README, ARCHITECTURE.md, CHANGELOG.md if needed)
- [ ] No hardcoded secrets / API keys / domains
- [ ] Clean Architecture Dependency Rule not violated (domain does not depend on data/presentation)

## Adding a New Feature

1. Create folder `lib/features/<feature_name>/` with `data/`, `domain/`, `presentation/` subdirectories
2. Domain: interfaces (Repository, UseCase), models (Freezed), Either for errors
3. Data: RepositoryImpl, DataSource (Remote/Local), DTOs with json_serializable
4. Presentation: Notifier/AsyncNotifier (Riverpod 3), UI widgets, GoRouter route
5. Tests: unit for domain/data, provider tests for presentation
6. Register providers in `lib/features/<feature_name>/presentation/providers/`
7. Add route in `lib/routes/app_router.dart`

## Code Style

- **Dart formatter** — single source of truth (`dart format .`)
- **Lint** — `flutter analyze` with project `analysis_options.yaml`
- **Naming**: `PascalCase` types, `camelCase` variables/functions, `snake_case` files
- **Imports**: `package:` first, then `dart:`, then relative; alphabetical within groups

## Reporting Issues

- **Bug**: reproduction steps, expected/actual behavior, `flutter --version`, OS
- **Feature Request**: use-case, why it belongs in the template (not the user's app)
- **Security**: privately via contacts in `SECURITY.md`

## License

MIT-0 (public domain equivalent). See [LICENSE](LICENSE).