# PRD-006 — Connectors (Explicit Capabilities You Can Turn On/Off)

## One-line Summary

OpenWork should show (and control) what external capabilities a task can use, like web access or browser automation.

## Status (Today)

Not implemented as a unified system.

- OpenWork can manage OpenCode plugins and install skills.
- OpenWork does not present a “connectors” panel that explains enabled capabilities per task.

---

## Problem (In Plain English)

People need to understand when a task can reach outside their computer.

“Web search” is useful, but it changes the trust model:

- The task can be influenced by untrusted internet content.
- The task can leak information if it’s not careful.

A user-friendly UI should make these capabilities explicit.

---

## Goals

- Make capabilities visible (“this task can use the web”, “this task can automate a browser”).
- Make them controllable (on/off per task).
- Keep safe defaults (off unless user enables).

## Non-Goals

- Building a full integration marketplace in v1.

---

## User Experience (What You’ll See)

1. In the task workspace, there is a section called **Connectors**.
2. It shows tiles like:
   - Web (Search)
   - Web (Fetch)
   - Browser automation
   - GitHub
3. Each connector shows:
   - whether it’s available
   - whether it’s enabled for this task
4. When a task uses a connector, the Activity log clearly labels it.

---

## Requirements

### Must Have

- A “Connectors” section visible during a task.
- Connectors have three states:
  - Not available (not installed / not configured)
  - Available but off
  - Enabled
- Enabling a connector requires an explicit user action.

### Should Have

- Connector settings per task:
  - web domain allowlist (“only use these sites”)
  - rate limits (“don’t run 100 searches without asking”)

### Nice to Have

- Connector presets tied to Safety Profiles (PRD-007).

---

## Safety, Permissions, and Trust

- Web connectors should default to **off** in “Work” and “Locked-down” profiles.
- If a connector is enabled:
  - show a visible badge in the task header
  - record usage in the run report (PRD-010)

---

## Success Metrics

- Users understand when tasks use the web.
- Reduced accidental web-enabled runs.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

The connector UI can be shipped in stages:

- Stage 1 (visibility): detect installed plugins/skills and display connector availability.
- Stage 2 (control): store per-task connector settings and inject them into the run as constraints.
- Stage 3 (enforcement): integrate with OpenCode permissions / tool gating for true on/off behavior.

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - add Connectors panel
  - store per-task connector settings
- `apps/openwork/src-tauri/src/lib.rs`
  - optionally: OS-level connector support (e.g., opening browser)

### Open Questions

- How does OpenCode best accept connector constraints: config, system prompt, or permission layer?
- What is the minimal connector set that gives real user value?
