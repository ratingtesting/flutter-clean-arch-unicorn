# CLAUDE.md

All agent instructions for this project live in [AGENTS.md](AGENTS.md). Read that file first.

Quick facts:
- Flutter + Riverpod 3, Clean Architecture, feature-first (`lib/features/{name}/{data,domain,presentation}`)
- Dependency Rule: `domain` never imports `data` or `presentation`
- Run tests: `flutter test` (128/128 must pass)
- Never hardcode secrets — use `--dart-define` and `SecureStorage`
- Machine-readable project summary: [llms.txt](llms.txt)
