# 0004 - Immutable Models: Freezed + json_serializable

## Status
Accepted

## Context
Dart model options: manual classes, `json_serializable` alone, Freezed, built_value, dart_mappable. Requirements:
- Immutable by default (no accidental mutation)
- `copyWith` for state updates
- JSON serialization without boilerplate
- Union/sealed classes for state modeling (AsyncValue, Either)
- Pattern matching support (`switch (state) { case Data(:final value): ... }`)
- Code generation (build_runner)

## Decision
**Freezed 3.2.5** + `json_serializable` + `freezed_annotation`.

### Patterns
```dart
@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String title,
    required double price,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

// Sealed state classes
@freezed
sealed class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = _Initial;
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.data(List<Product> products) = _Data;
  const factory DashboardState.error(String message) = _Error;
}
```

## Consequences
### Positive
- True immutability (const constructors, no setters)
- `copyWith` generated, nested copyWith for collections
- `toJson`/`fromJson` with `json_serializable` — zero manual mapping
- Sealed classes + pattern matching = exhaustive switch, compiler catches missing cases
- `map`/`when`/`maybeWhen` helpers for state handling
- Great IDE support (navigation, refactoring)

### Negative
- Build runner required (`dart run build_runner build --delete-conflicting-outputs`)
- Generated files in repo (or `.gitignore` + CI generates)
- Slight learning curve: `part` directives, `@freezed` syntax
- Build time increases with many models

### Neutral
- `freezed` + `freezed_annotation` + `json_serializable` + `json_annotation` + `build_runner`

## Alternatives Considered
- **json_serializable only**: No `copyWith`, no sealed classes, mutable by default
- **built_value**: Immutable, but more verbose, slower build, less ergonomic pattern matching
- **dart_mappable**: Newer, less battle-tested, smaller ecosystem

## Links
- [Freezed docs](https://pub.dev/packages/freezed)
- [Sealed classes in Dart 3](https://dart.dev/language/sealed-classes)