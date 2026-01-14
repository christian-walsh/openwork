# PRD-011 — Layout + Focus Modes (Never Cramp the Output)

## One-line Summary

OpenWork should make it easy to focus on what matters right now: progress, activity, or outputs—without cramped layouts.

## Status (Today)

Partially implemented:

- Desktop shows a right sidebar for “Execution Plan”.
- Mobile hides the plan sidebar entirely.

Missing:

- A user-controlled way to open/close panels.
- Focus modes (“show me the output bigger”).

---

## Problem (In Plain English)

When an agent produces something (a report, a page, a document), users want to see it.

If the UI is cramped or confusing:

- users feel like the product is broken
- they lose trust

---

## Goals

- Give users control over the workspace layout.
- Make important content readable on all screens.

## Non-Goals

- Fully customizable window manager.

---

## User Experience (What You’ll See)

1. In a task, you can toggle panels:
   - Progress
   - Activity
   - Outputs
   - Files you shared
2. On mobile, these open as simple bottom sheets/drawers.
3. You can tap **Focus** to maximize Outputs.

---

## Requirements

### Must Have

- Toggle visibility of the right sidebar.
- Mobile-friendly drawers for the same information.
- A “Focus Outputs” mode.

### Should Have

- Remember layout preference per device.
- Respect reduced motion.

### Nice to Have

- Keyboard shortcuts on desktop.

---

## Safety, Permissions, and Trust

- Layout changes should never hide critical safety prompts.
- Permission dialogs must always appear on top.

---

## Success Metrics

- Users can comfortably view outputs and progress on mobile.
- Reduced “I can’t see the output” complaints.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Add a simple layout state machine:
  - sidebar open/closed
  - focus mode on/off
- Reuse the same panels across desktop and mobile with different presentation (sidebar vs drawer).

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - layout state
  - panel rendering
- `apps/openwork/src/styles.css`
  - small additions for responsive layout

### Open Questions

- Should the panel set be fixed, or can it grow as we add Outputs/Connectors?
