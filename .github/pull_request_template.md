## What does this PR do?

<!-- Опиши изменение простыми словами. Что поменялось для пользователя шаблона? -->

## Type of change

- [ ] `feat` — new feature for template users
- [ ] `fix` — bug in the template
- [ ] `docs` — documentation only
- [ ] `refactor` — refactoring without behavior change
- [ ] `test` — adding/fixing tests
- [ ] `chore` — CI, deps, tooling

## Checklist

- [ ] `flutter analyze lib/ test/ --fatal-infos` — **0 issues**
- [ ] `dart format --set-exit-if-changed .` — no diff
- [ ] `flutter test` — **all 151 tests pass**
- [ ] Tests added for new logic (domain layer required)
- [ ] Documentation updated (README, ARCHITECTURE.md, CHANGELOG.md if needed)
- [ ] No hardcoded secrets / API keys / domains
- [ ] **Clean Architecture Dependency Rule NOT violated** (domain does not depend on data/presentation)
- [ ] New dependency? Updated Stack table in README/ARCHITECTURE + `pubspec.yaml`

## Notes for reviewers

<!-- Любой контекст: почему так, а не иначе? Ссылка на ADR? -->
