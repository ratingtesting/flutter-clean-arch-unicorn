# 2026-08-14 — Shared models relocation & Equatable decision (v1.5.0)

## Status
Accepted (2026-08-14, v1.5.0)

## Context
Seven-role audit (§5) flagged two issues in `lib/shared/`:
- **§10 WRONG** — domain models (`user_model.dart`, `product_model.dart`) lived in `shared/domain/models/`, violating shared-boundary discipline.
- **§18 PARTIAL** — `User`/`DashboardState` were hand-written `Equatable` while `Product`/`AuthState` were `freezed`.

## Decision
1. **Relocate models to feature domains:**
   - `shared/domain/models/user/user_model.dart` → `features/authentication/domain/models/user_model.dart`
   - `shared/domain/models/product/product_model.dart` → `features/dashboard/domain/models/product_model.dart`
   - `shared/globals.dart` → `shared/constants.dart` (globals banned by architecture).

2. **Keep `User`/`DashboardState` on `Equatable` (NOT freezed).**
   - Freezed was trialed but reverted: its generated `toJson()` includes all fields, breaking the security test that requires `toJson()` to **exclude `password`/`token`**.
   - Freezed `copyWith(token: null)` is disallowed (non-nullable `String` with `@Default('')`), breaking `user_local_datasource` restore flow.
   - 12 tests failed under Freezed vs 119 green under Equatable.
   - `Product`/`AuthState` remain freezed (no security constraint, no null-copyWith conflict).

## Consequences
- `shared/` no longer holds domain models — only primitives/constants (§10 compliant).
- `User.toJson()` excludes credentials; `User.props` excludes `password`/`token` (security verified by `credential_separation_test.dart`).
- Mixed modeling (freezed for DTOs, Equatable for secure entities) is intentional and documented here.
