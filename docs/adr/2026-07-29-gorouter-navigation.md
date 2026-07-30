# 0003 - Navigation: GoRouter (Declarative, Deep Links)

## Status
Accepted

## Context
Navigation options: Navigator 1.0 (imperative), Navigator 2.0 (RouterDelegate), auto_route, go_router, beamer. Requirements:
- Declarative route configuration (routes as data)
- Deep links / app links out of the box
- Redirects, guards (auth, onboarding)
- Type-safe navigation (`context.goNamed('detail', params: {'id': '123'})`)
- Works with Riverpod (no context coupling in providers)
- Web support (URL sync)

## Decision
**GoRouter 16.3.0** with route definitions in `lib/routes/app_router.dart`.

```dart
@TypedGoRoute<HomeRoute>(path: '/home')
@TypedGoRoute<DetailRoute>(path: '/detail/:id')
class AppRouter extends GoRouter { ... }
```

## Consequences
### Positive
- Routes = data → easy to serialize, test, generate
- Deep links: `go_router` handles intent/universal links automatically
- Redirects/guards: `redirect` callback for auth, onboarding
- Type-safe params with `go_router_builder` code gen
- Riverpod-friendly: navigation from notifiers via `ref.read(routerProvider).go(...)`

### Negative
- Code generation step (`build_runner`)
- Learning curve: shells, redirects, navigator keys
- Web history quirks (hash vs path URL strategy)

### Neutral
- `go_router` + `go_router_builder` in deps

## Alternatives Considered
- **auto_route**: Similar, but less deep-link focus, more annotation-heavy
- **beamer**: Powerful but smaller community, less maintained
- **Navigator 2.0 manual**: Full control, but boilerplate explosion

## Links
- [GoRouter docs](https://pub.dev/packages/go_router)
- [Typed routes](https://pub.dev/packages/go_router_builder)