# KANBAN — PARALLEL POST-v1.5 HARDENING

Orchestrator: Hermes
Execution: parallel subagent swarm + Integrator
Master Architect: external (final decision maker)

## BOARD STATE (2026-08-14)

### BACKLOG
- TASK-A1: Architect Audit (read-only)
- TASK-A2: VibeCoder/DX Audit (read-only)
- TASK-A3: Scale/Unicorn Audit (read-only)
- TASK-A4: QA/Test Audit (read-only)
- TASK-A5: Security Audit (read-only)
- TASK-A6: Open Source/Adoption Audit (read-only)

### AUDIT (parallel wave, read-only)
- TASK-A1: Architect Auditor — status: IN PROGRESS (delegated)
- TASK-A2: VibeCoder Agent — status: IN PROGRESS (delegated)
- TASK-A3: Scale/Unicorn Agent — status: IN PROGRESS (delegated)
- TASK-A4: QA Agent — status: IN PROGRESS (delegated)
- TASK-A5: Security Agent — status: IN PROGRESS (delegated)
- TASK-A6: OSS Agent — status: IN PROGRESS (delegated)

### READY (after synthesis)
- TASK-B1: pubspec version fix (1.4.0 → 1.6.0) [depends A1] — IN PROGRESS (Track B)
- TASK-B2: issue templates expansion [depends A6] — TODO
- TASK-B3: ARCHITECTURE_BOUNDARIES enforcement CI [depends A1] — IN PROGRESS (Track A: shared leak + test/ analyze)
- TASK-B4: widget test extensions (loading/error states) [depends A4] — done in prior turn (login/router widget tests exist)
- TASK-B5: SyncEngine extension-point doc [depends A3] — deferred (P2, not needed)

### IN PROGRESS
- Track A (Architect/Security): P0-2 (shared leak), P0-3 (CI test/ analyze), P1-2 (log redaction), P0-4 (env honesty) — delegated deleg_8efb80a8 task-0
- Track B (VibeCoder/OSS): P0-1 (pubspec), P1-5 (README version), P1-1 (placeholder tests), P1-3 (LICENSE) — delegated deleg_8efb80a8 task-1

### IN PROGRESS
(empty until audit wave completes)

### CODE REVIEW
(empty)

### TEST
(empty)

### INTEGRATE
- TASK-I1: Integrator final QA (format/analyze/test/coverage/build/CI) [depends all B*]

### DONE
- POST_V1_5_AUDIT.md (pre-existing, will be refreshed by A-wave)
- ARCHITECTURE_BOUNDARIES.md (pre-existing)
- v1.6.0 released (prior turn)

## FILE OWNERSHIP
- ARCHITECT: lib/core/, lib/features/*/data|domain, lib/shared, app_router, pubspec.yaml
- VIBECODER: tool/, README quick-start, docs/AI_DEVELOPMENT_RULES.md
- QA: test/, .github/workflows/
- SECURITY: security-related files only
- OSS: docs/, README sections, .github/ISSUE_TEMPLATE/, .github/PULL_REQUEST_TEMPLATE.md
- INTEGRATOR: cross-cutting verification + release

## PROTECTED (no parallel modification)
- pubspec.yaml (single owner: Architect, serialized)
- app_router.dart (single owner: Architect)
- Repository interfaces (single owner: Architect)
- database architecture (single owner: Architect)
- shared/core (single owner: Architect)
- authentication contracts (single owner: Architect)

## DEPENDENCY RULES
- A-wave: all independent, parallel
- B-wave: B1/B3/B5 depend on A1; B2 on A6; B4 on A4
- I1: depends on ALL B-tasks
- No two agents modify same protected file simultaneously
