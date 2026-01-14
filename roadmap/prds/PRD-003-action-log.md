# PRD-003 — Action Log (Show What It’s Doing, Without Being Scary)

## One-line Summary

OpenWork should present a calm “action log” that explains what the agent is doing (and shows details when you want them).

## Status (Today)

Partially implemented:

- Tool calls appear as message parts and show status + output.
- Step-start/step-finish parts are hidden unless Developer mode.

Missing:

- A dedicated, user-friendly action timeline with grouping (“ran 44 searches”), clearer labels, and copy-friendly details.

---

## Problem (In Plain English)

When people watch an agent work, they mostly worry about two things:

- “Is it doing the right thing?”
- “Is it doing something risky?”

If the UI hides actions, the agent feels untrustworthy.
If it shows raw developer output, the UI becomes intimidating.

We need a middle layer: clear, plain-English actions with optional details.

---

## Goals

- Make “what it’s doing right now” visible.
- Avoid dumping terminal noise on non-technical users.
- Make it easy to expand and inspect actions when needed.

## Non-Goals

- Full raw log viewer by default (keep that in Developer mode).

---

## User Experience (What You’ll See)

1. In the task workspace there is a section called **Activity**.
2. While running, it shows items like:
   - “Looking for files you shared”
   - “Reading 46 drafts”
   - “Checking if drafts were published (44 searches)”
3. Each activity item has a status:
   - running / done / needs approval / error
4. Each item can be expanded to show:
   - exactly what command/tool ran (copy button)
   - what it returned (short summary, raw output optional)

---

## Requirements

### Must Have

- A visible “Activity” timeline for the current task.
- Each entry shows:
  - a human-readable label
  - status
  - time started / duration (simple)
- Expansion view with:
  - safe, redacted details
  - copy action

### Should Have

- Group repeated actions into a single row:
  - example: “44 web searches” with an expand view.
- Highlight risky actions:
  - “Editing many files”
  - “Running an install command”

### Nice to Have

- Inline “why” explanation for grouped actions (“I’m searching the site to confirm duplicates”).

---

## Safety, Permissions, and Trust

- Never show hidden reasoning by default.
- Always redact secrets from tool input/output.
- Make risky actions visually distinct and easy to cancel.

---

## Success Metrics

- Users can answer “what is it doing?” without Developer mode.
- Reduced “panic stop” cancellations.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Build an “Activity model” from OpenCode message parts:
  - tool parts already include status/title/output
  - step-start/step-finish can remain hidden, but tool parts can drive the timeline
- Keep Developer mode as the raw event/JSON viewer.

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - add an Activity section in the task workspace
- `apps/openwork/src/components/PartView.tsx`
  - improve tool rendering for non-technical users (labels, expandable details)

### Phased Delivery

- Phase 1: Promote tool parts into a distinct “Activity” section (no grouping)
- Phase 2: Group repetitive actions
- Phase 3: Add risk highlighting

### Open Questions

- Do we need a separate action log model, or can we render directly from existing tool parts?
