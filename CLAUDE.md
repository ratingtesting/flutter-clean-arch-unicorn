# CLAUDE.md

All agent instructions for this project live in [AGENTS.md](AGENTS.md). Read that file first.

Quick facts:
- Flutter + Riverpod 3, Clean Architecture, feature-first (`lib/features/{name}/{data,domain,presentation}`)
- Dependency Rule: `domain` never imports `data` or `presentation`
- Architecture boundaries enforced by `tool/check_boundaries.dart` — run `dart run tool/check_boundaries.dart` after changes; `services/` must not depend on `features/`, `feature A` must not import `feature B` internals (see `lib/tool/boundary_rules.dart`)
- Run tests: `flutter test` (128/128 must pass)
- Never hardcode secrets — use `--dart-define` and `SecureStorage`
- Machine-readable project summary: [llms.txt](llms.txt)
