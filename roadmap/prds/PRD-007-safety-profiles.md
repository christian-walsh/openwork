# PRD-007 — Safety Profiles (Simple Presets for Different Comfort Levels)

## One-line Summary

OpenWork should offer simple safety presets so users don’t have to configure a complex matrix of settings.

## Status (Today)

Not implemented.

- There is a Developer mode toggle.
- There are no user-facing “safety profiles” that change default behavior.

---

## Problem (In Plain English)

Different people want different levels of control.

- Some people want “just do it, ask when needed.”
- Some people want “show me everything, ask before changes.”
- In a work setting, people often need “locked down by default.”

If we don’t provide presets, users end up confused or unsafe.

---

## Goals

- Provide a small set of clear presets.
- Keep defaults safe.
- Make behavior predictable.

## Non-Goals

- Exposing every advanced knob in the default UI.

---

## User Experience (What You’ll See)

1. In Settings, the user picks a safety profile:
   - Personal
   - Work
   - Locked-down
   - Developer
2. The app explains what changes in plain language.
3. During tasks, the profile is visible (small badge).

---

## Requirements

### Must Have

- Profiles define at least:
  - default connector state (PRD-006)
  - how write actions are handled (auto vs confirm)
  - how permission prompts are presented
- Profiles are reversible.

### Should Have

- Per-task override: “Use a stricter profile for this task.”
- “Sensitive task” quick toggle (ties to PRD-013).

### Nice to Have

- Organization policy lock (for shared machines).

---

## Safety, Permissions, and Trust

Examples of profile behavior:

- Personal:
  - allow common safe actions with fewer prompts
- Work:
  - web connectors off by default
  - stronger confirmation for changing many files
- Locked-down:
  - require review before writing outputs
  - block outside shared folders (PRD-002)
- Developer:
  - show more details and logs

---

## Success Metrics

- Fewer users get stuck on permissions.
- Fewer unsafe “always allow” patterns.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Introduce a small policy layer in the UI that answers questions like:
  - “Should we require confirmation for this permission request?”
  - “Should web connectors be enabled?”
  - “Should we show raw details?”

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - add profile selection UI
  - store profile in localStorage
  - apply profile rules to permission dialogs and task workspace

### Phased Delivery

- Phase 1: Profile selection + visible badge
- Phase 2: Apply profiles to connector defaults and confirmations
- Phase 3: Per-task overrides

### Open Questions

- Should profiles be per-device, per-user profile, or per-workspace?
