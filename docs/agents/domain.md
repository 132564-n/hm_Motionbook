# Domain docs

This repo uses a **single-context** domain doc layout.

## Layout

- `CONTEXT.md` at the repo root — the single source of truth for the project's domain, terminology, and current architecture.
- `docs/adr/` at the repo root — Architecture Decision Records, one file per decision, numbered (e.g. `0001-record-architecture-decisions.md`).

## Consumer rules

Agents working in this repo should:

1. Read `CONTEXT.md` before making non-trivial changes, to ground themselves in the project's domain and conventions.
2. Check `docs/adr/` for prior decisions that affect the area being changed. Don't contradict an ADR without acknowledging it.
3. When a significant architectural decision is made, record it as a new ADR in `docs/adr/`.
4. Keep `CONTEXT.md` updated when the domain model or core architecture changes.

## What goes in CONTEXT.md

- Project purpose and scope
- Domain terminology (ubiquitous language)
- High-level architecture
- Key constraints and conventions

## What goes in docs/adr/

One file per architecture decision. Each ADR records:

- Title and number
- Status (proposed / accepted / superseded)
- Context
- Decision
- Consequences
