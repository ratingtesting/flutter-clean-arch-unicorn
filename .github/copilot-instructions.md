# GitHub Copilot Instructions

Full agent guide: [AGENTS.md](../AGENTS.md). Machine-readable summary: [llms.txt](../llms.txt).

- Architecture: Clean Architecture, feature-first — `lib/features/{name}/{data,domain,presentation}`
- Dependency Rule: `domain` layer must never import `data` or `presentation`
- State management: Riverpod 3 (compile-time DI). Navigation: GoRouter. Models: Freezed.
- Error handling: return `Either<Failure, T>` from repositories — never throw raw exceptions across layers
- Tests: `flutter test` — all 100 tests must pass before any commit
- Secrets: never hardcode. Use `--dart-define` for build-time config and `SecureStorage` for tokens
- Environments: dev/staging/prod via `lib/main/main_{env}.dart`
