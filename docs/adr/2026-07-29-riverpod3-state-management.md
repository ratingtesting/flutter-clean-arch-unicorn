# 0002 - State Management: Riverpod 3 (Notifier/AsyncNotifier)

## Status
Accepted

## Context
Flutter state management options: Provider, Riverpod, Bloc/Cubit, GetX, MobX, Redux. Requirements:
- Compile-time safety (no `Provider.of<X>(context)` runtime crashes)
- Testability without Flutter binding
- Declarative, reactive, minimal boilerplate
- Migration path from Riverpod 2 (existing codebase)
- Active maintenance, strong ecosystem

## Decision
**Riverpod 3.4.1** with `Notifier` / `AsyncNotifier` (not `StateNotifier`).

### Key patterns
```dart
// Domain-driven: Notifier owns state logic
@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  FutureOr<List<Product>> build() => ref.read(dashboardRepository).fetchAll();

  Future<void> refresh() => state = const AsyncLoading().copyWithPrevious(state);
}
```

## Consequences
### Positive
- Compile-time DI: `ref.read()`, `ref.watch()` — no context, no runtime surprises
- `AsyncNotifier` = built-in loading/error/data states, no manual `state = AsyncData(...)`
- `ref.invalidate()` for cache invalidation
- Testing: `ProviderContainer` + overrides — zero Flutter binding
- Migration from Riverpod 2 straightforward (`StateNotifier` → `Notifier`)

### Negative
- Learning curve for `ref` patterns (scoping, `listen`, `invalidate`)
- Code generation (`@riverpod`) adds build_runner step
- Not as widely known as Bloc in some markets

### Neutral
- `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` in deps

## Alternatives Considered
- **Bloc 9.x**: Strong, but `BlocProvider` + context coupling, more boilerplate for simple state
- **Provider**: Simpler, but no compile-time safety, context-dependent
- **GetX**: Anti-patterns (global state, `Get.put`), not testable without binding

## Links
- [Riverpod docs](https://riverpod.dev)
- [Migration guide 2→3](https://riverpod.dev/docs/migration/2_to_3)