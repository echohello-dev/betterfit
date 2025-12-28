# Architecture Decision Records (ADRs)

This folder holds Architecture Decision Records (ADRs) for BetterFit.

## When to write an ADR

Create an ADR when a decision:

- changes the public API or module boundaries
- affects data models, persistence, or compatibility/migrations
- changes app/service architecture, dependencies, or infrastructure
- is hard to reverse or has meaningful trade-offs
- introduces new patterns that others should follow

If it’s a small, local refactor with no long-term impact, a normal PR description is usually enough.

## Naming

Use a monotonic numeric prefix:

- `0001-short-decision-title.md`
- `0002-another-decision.md`

Pick the next available number in this directory.

## Status

Common statuses:

- Proposed
- Accepted
- Deprecated
- Superseded by [000X-...](000X-...)

Record `date` and `status` in YAML frontmatter at the top of each ADR (see `0000-template.md`).

Don’t delete old ADRs; supersede them.

## Index

Keep a simple list below. Add new ADRs at the bottom.

- [0001: Supabase for Authentication and Data Persistence](0001-supabase-auth-and-persistence.md) – Multi-platform auth (Apple Sign In) + PostgreSQL persistence, enabling guest mode and future Android/Web expansion.
