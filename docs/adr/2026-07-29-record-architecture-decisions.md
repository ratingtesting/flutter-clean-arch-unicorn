# 0001 - Record Architecture Decisions

## Status
Accepted

## Context
We need a lightweight, durable way to record *why* we made architectural choices in this template. Decisions like "Riverpod over Bloc", "GoRouter over auto_route", "Freezed over manual models" are not obvious and will be questioned by future maintainers.

Without records, we risk:
- Re-litigating the same decisions repeatedly
- Losing context when contributors change
- Inconsistent choices across features
- Inability to evaluate if a decision still holds

## Decision
Adopt **Architecture Decision Records (ADRs)** — one Markdown file per significant decision, stored in `docs/adr/`.

### Format
```
docs/adr/YYYY-MM-DD-<kebab-case-slug>.md
```

### Template
```markdown
# <Title>

## Status
<Proposed | Accepted | Superseded | Deprecated>

## Context
<What problem were we solving? What constraints existed?>

## Decision
<What did we choose? Be specific.>

## Consequences
### Positive
- <Benefits>

### Negative
- <Trade-offs, costs, risks>

### Neutral
- <Observations>

## Alternatives Considered
- <Option A>: <Why rejected>
- <Option B>: <Why rejected>

## Links
- Related ADRs: [ADR-XXXX](...)
- External references: [...]
```

## Consequences
### Positive
- Decisions are discoverable, reviewable, versioned
- New contributors understand *why* without asking
- Easy to supersede when context changes
- Lightweight — just Markdown in repo

### Negative
- Requires discipline to write/maintain
- Can become stale if not updated on supersession

### Neutral
- First ADR documents this decision (meta)

## Alternatives Considered
- **README-only**: Decisions buried in long docs, hard to find
- **Code comments**: Scattered, not searchable as a set
- **Wiki/Confluence**: External dependency, not versioned with code

## Links
- [ADR GitHub organization](https://github.com/adr/adr)
- Michael Nygard's original post: "Documenting Architecture Decisions"