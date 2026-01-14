# PRD-014 — Protected Mode (Sandboxed Engine)

## One-line Summary

OpenWork should offer a “Protected mode” where the engine runs in a strong sandbox and can only see the folders you shared.

## Status (Today)

Not implemented.

- Host mode starts `opencode serve` directly on the host OS.

---

## Problem (In Plain English)

UI permissions are helpful, but they’re not the strongest protection.

The safest default is when the engine cannot access anything outside the folders the user explicitly shared.

A protected mode should reduce the “blast radius” of mistakes and malicious instructions.

---

## Goals

- Provide strong isolation by default (or as a recommended option).
- Make it easy for non-technical users to understand: “only the folders you shared are visible.”

## Non-Goals

- Perfect cross-platform parity in the first iteration.
- Solving all prompt-injection risks (this is only one layer).

---

## User Experience (What You’ll See)

1. In onboarding or settings, there is a toggle:
   - Protected mode (recommended)
   - Standard mode (faster)
2. Protected mode explains, in plain language:
   - “Tasks can only see the folders you shared.”
   - “This reduces risk if something goes wrong.”
3. If the task requests access outside shared folders:
   - OpenWork can’t grant it unless the user explicitly shares the folder.

---

## Requirements

### Must Have

- A user-facing “Protected mode” setting.
- In protected mode:
  - only shared folders are visible to the engine
  - the engine cannot read arbitrary host files

### Should Have

- Clear performance expectations (“may be slower”).
- Network policy:
  - default to safe connector allowlists (PRD-006)

### Nice to Have

- Per-task protected mode toggle.

---

## Safety, Permissions, and Trust

Protected mode is meant to be understandable:

- “I shared these folders. The task cannot see anything else.”

---

## Success Metrics

- Users choose protected mode as the default.
- Reduced risk surface in everyday usage.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

This PRD likely requires OS-level sandboxing technology:

- macOS: Apple Virtualization Framework (run a lightweight Linux VM)
- other platforms: use the best available sandbox mechanism

The engine should run inside the sandbox with:

- mounted shared folders only
- stable mount paths to keep audits understandable

### Files Likely Touched

- `apps/openwork/src-tauri/src/lib.rs`
  - start/stop logic for protected engine mode
- `apps/openwork/src/App.tsx`
  - settings UI, status display

### Phased Delivery

- Phase 1: “Protected mode” design + toggle (no-op / behind feature flag)
- Phase 2: macOS protected engine (experimental)
- Phase 3: expand to other platforms

### Open Questions

- What minimal VM image and lifecycle is acceptable for a good UX?
- How do we handle package installs and toolchains inside the sandbox?
