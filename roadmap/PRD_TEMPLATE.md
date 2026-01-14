# PRD Template (OpenWork)

This template is for writing **non-technical friendly** PRDs that still contain enough detail for contributors to implement them.

If you are writing a PRD for a developer audience, prefer linking to `apps/openwork/design-prd.md` instead of duplicating it.

---

## Title

One sentence that makes sense to a non-technical user.

## One-line Summary

A single sentence describing the outcome.

## Problem (In Plain English)

- What is confusing / hard today?
- What do people do instead?
- What feels risky or untrustworthy?

## Who This Is For

- Primary user
- Secondary user
- Not for (explicit)

## Goals

- Goal 1
- Goal 2

## Non-Goals

- Non-goal 1

## User Experience (What You’ll See)

Describe the UI as a story:

1. The user clicks/taps…
2. The app shows…
3. The user approves/changes…
4. The run completes and outputs…

## Requirements

### Must Have

- Requirement

### Should Have

- Requirement

### Nice to Have

- Requirement

## Safety, Permissions, and Trust

Write this as user-facing expectations:

- What the app will *never* do without asking
- What the app will block by default
- What the user can always review / undo

## Data, Storage, and Privacy

- What is stored locally?
- How long is it kept?
- What can be exported?

## Accessibility

- Keyboard access
- Screen reader labels
- Reduced motion

## Success Metrics

- Metric + target

## Edge Cases

- Offline
- Engine not running
- Permission denied
- Conflicting files

## Open Questions

- Unknowns that need confirmation

---

## Build Notes (For Contributors)

This section can be technical.

### Suggested Implementation Approach

- Where in the app this likely lives (UI vs Tauri backend)
- Which OpenCode APIs are involved
- Which new state/events are required

### Files Likely Touched

- `apps/openwork/src/App.tsx` (or other UI modules)
- `apps/openwork/src/lib/opencode.ts`
- `apps/openwork/src/lib/tauri.ts`
- `apps/openwork/src-tauri/src/lib.rs`

### Phased Delivery

- Phase 1 (MVP)
- Phase 2
- Phase 3

### Risks and Mitigations

- Risk
- Mitigation
