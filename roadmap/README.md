# OpenWork Roadmap

This folder contains **user-friendly PRDs** and planning docs for OpenWork.

OpenWork is a Tauri + SolidJS app that makes OpenCode feel like a calm, premium “work assistant” for non-technical people.

If you are looking for the deeper technical architecture and full flow map, start with:

- `apps/openwork/design-prd.md`

## What’s in Here

- `ROADMAP.md` — the high-level plan: what we’re building next and why.
- `PRDS.md` — index of PRDs (by ID).
- `GAPS.md` — what already exists today vs what’s missing (mapped to PRDs).
- `IMPLEMENTATION_MAP.md` — where and how we’d build each PRD.
- `DELIVERY_PLAYBOOK.md` — how we take a PRD from idea → shipped.
- `PRD_TEMPLATE.md` — how to write new PRDs.
- `prds/` — one PRD per feature area.

## How to Read PRDs

Every PRD is written in two layers:

1. **User Experience (plain English)** — what the feature does and how it feels.
2. **Build Notes (for contributors)** — concrete implementation notes (without code).

## Principles

- **Non-technical by default**: the default UI avoids developer jargon.
- **Trust through clarity**: the app shows what it’s doing, and asks before risky actions.
- **Least privilege**: OpenWork should only access folders the user shared.
- **Local-first**: tasks run locally unless the user chooses a remote/paired mode.
