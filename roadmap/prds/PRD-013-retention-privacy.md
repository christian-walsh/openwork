# PRD-013 — Data Retention + Privacy Controls

## One-line Summary

OpenWork should make it easy to understand what data is stored locally, and to delete it.

## Status (Today)

Not implemented as a user-facing feature.

- Some settings/templates are stored in localStorage.
- OpenCode stores sessions; OpenWork can list them.
- There is no “delete run”, “delete outputs”, or retention policy UI.

---

## Problem (In Plain English)

When tasks run locally, data accumulates:

- chat history
- files read
- outputs created
- logs

Users need:

- clarity: “what is stored and where?”
- control: “delete this”
- safety modes: “treat this task as sensitive”

---

## Goals

- Provide clear, simple retention settings.
- Make deletion safe and obvious.

## Non-Goals

- Cloud sync policies (future).

---

## User Experience (What You’ll See)

1. In Settings, there is a **Privacy** section.
2. You can choose:
   - keep runs forever
   - delete runs after N days
3. For a task, you can choose:
   - “Delete this task and its outputs”
4. When deleting, OpenWork explains what will be removed.

---

## Requirements

### Must Have

- A Privacy settings page:
  - retention policy
  - “clear local settings” (templates, authorized folders)
- Per-task deletion:
  - delete run history
  - delete outputs created by the run (where safe)

### Should Have

- “Sensitive task” flag:
  - stricter connector defaults
  - stronger redaction in reports
  - avoid storing unnecessary details

### Nice to Have

- Scheduled cleanup job.

---

## Safety, Permissions, and Trust

- Deleting should be explicit and reversible where possible.
- If deletion affects files, OpenWork must confirm and show the list.

---

## Success Metrics

- Users can confidently use OpenWork for sensitive work.
- Fewer “where is my data stored?” questions.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- UI-level retention:
  - clear localStorage entries
- Engine/session retention:
  - call OpenCode APIs to delete sessions (if available)
  - if outputs are in the workspace, deletion must be scoped to files known to be created by the run

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - settings UI
  - delete flows
- `apps/openwork/src-tauri/src/lib.rs`
  - optional: safe delete helpers

### Open Questions

- What is the safest definition of “outputs created by this run”? (ties to PRD-004)
