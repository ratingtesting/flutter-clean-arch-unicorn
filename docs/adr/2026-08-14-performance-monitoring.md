# ADR: Performance Monitoring Extension Point

- Status: Accepted
- Date: 2026-08-14

## Context

The template must allow adding performance monitoring (startup time, FPS, memory,
network traces) at the Unicorn stage without rewriting feature code. We do NOT
want to bundle Firebase Performance or any vendor SDK into the starter.

## Decision

Introduce a `PerformanceMonitor` interface in `lib/services/observability/performance.dart`
with `trace`, `traceAsync`, `recordMetric`, `recordStartupTime`. Ship a
`NoopPerformanceMonitor` (debug-prints in debug mode). Wire via
`performanceMonitorProvider` in `service_providers.dart`.

Feature/app code calls `ref.watch(performanceMonitorProvider)` — never a concrete
vendor class.

## Consequences

- ✅ Vendor-independent: swap `NoopPerformanceMonitor` → `FirebasePerformanceMonitor`
  by changing one provider line.
- ✅ Zero dependency cost in the starter.
- ✅ Matches the §13 / §25 contract pattern (Logger, ErrorReporter, Analytics).
- ⚠️ No real metrics until a concrete implementation is added (intentional).
