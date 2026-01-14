# PRD-012 — Template Gallery (Non-Technical “Jobs to Be Done”)

## One-line Summary

OpenWork should ship with a small set of non-technical templates that guide users to good prompts and safe defaults.

## Status (Today)

Partially implemented:

- Users can create, save, and run templates (stored locally).

Missing:

- A curated starter gallery.
- Guided inputs (so templates feel like “forms”, not developer prompts).

---

## Problem (In Plain English)

Many users don’t know what to ask.

A prompt box is powerful, but it’s also intimidating.

Templates solve this by:

- showing what’s possible
- providing safe defaults
- collecting the right inputs

---

## Goals

- Ship “starter templates” that work for normal knowledge work.
- Make templates feel like “tasks you can run”, not prompt snippets.

## Non-Goals

- A giant marketplace of templates.

---

## User Experience (What You’ll See)

1. On the home screen, you see a **Template Gallery**.
2. Each template is described like a task:
   - “Review a folder of documents and summarize what changed”
   - “Find duplicates / already-published checks”
   - “Create a shareable report from these files”
3. You tap a template and fill in a few simple fields (folder, goal, output format).
4. OpenWork runs it and produces an output artifact.

---

## Requirements

### Must Have

- A curated set of starter templates included in the app.
- Each template declares:
  - required shared folders/files
  - required connectors (if any)
  - output type (report, checklist, etc.)

### Should Have

- Guided input UI for templates:
  - folder picker
  - optional fields
  - a preview of what will happen

### Nice to Have

- Community import/export of templates.

---

## Safety, Permissions, and Trust

- Templates should default to least-privilege:
  - ask for the folder explicitly
  - web connectors off unless explicitly required

---

## Success Metrics

- Higher success rate for first-time users.
- Reduced onboarding drop-off.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Separate “Template content” from “Template UI fields”.
- Store starter templates in the repo as static JSON/TS objects.
- Store user templates in localStorage (already exists), but extend schema to include:
  - variables
  - required permissions/connectors

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - template schema upgrades
  - gallery UI
- `apps/openwork/design-prd.md`
  - keep parity with template concept

### Open Questions

- Where should we store starter templates (code vs JSON)?
- How do we prevent templates from becoming overly technical?
