# PRD-009 — Run Budgets (Prevent Runaway Tasks)

## One-line Summary

OpenWork should help users prevent runaway tasks by showing simple counters and offering “ask before continuing” limits.

## Status (Today)

Partially implemented:

- The UI shows a busy label and elapsed seconds.

Missing:

- Budget controls (step count, web calls, time limits).
- A simple “this is getting big” transparency layer.

---

## Problem (In Plain English)

Sometimes an agent does something reasonable—many times.

Example: “check 44 drafts” turns into “run 44 web searches”. That can be fine, but users should not be surprised.

People want:

- visibility (“how much is it doing?”)
- control (“ask me before doing 100 more”) 

---

## Goals

- Add lightweight transparency (counters and summaries).
- Add user-friendly budgets that prevent unexpected scale.

## Non-Goals

- Perfect cost estimation.

---

## User Experience (What You’ll See)

1. While a task runs, you see:
   - elapsed time
   - steps completed
   - connector calls (if enabled)
2. You can set limits like:
   - “Ask me after 20 web searches”
   - “Stop after 10 minutes”
3. When a budget is reached:
   - OpenWork pauses and asks what to do next.

---

## Requirements

### Must Have

- Visible counters during a run:
  - elapsed time
  - steps executed
- A post-run summary:
  - “What happened” in numbers

### Should Have

- Simple budgets:
  - max time
  - max connector calls
  - max steps
- User choice at budget boundary:
  - continue
  - stop
  - adjust budget

### Nice to Have

- Cost estimate (only where reliable).

---

## Safety, Permissions, and Trust

Budgets are a trust feature:

- They reduce the risk of unintended behavior.
- They make the agent feel bounded.

---

## Success Metrics

- Fewer aborted runs caused by “it’s doing too much”.
- Higher completion rates for web-enabled tasks.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Count steps from:
  - tool parts
  - todo updates
  - event stream (if needed)
- Budgets can be enforced in the UI by:
  - pausing prompts
  - requiring user confirmation before sending follow-up prompts

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - counters
  - budget settings UI
  - pause/continue UX

### Open Questions

- Can OpenCode pause a session cleanly, or do we implement “soft pause” in the UI?
