# PRD-002 — “Files You Shared” (Visible Access Boundaries)

## One-line Summary

OpenWork should always show which folders/files a task can access, and it should block everything else by default.

## Status (Today)

Partially implemented:

- Host onboarding lets users choose “Authorized Workspaces” (saved locally).
- OpenWork can show OpenCode permission requests and send allow/deny replies.

Missing:

- A persistent “Files you shared” view during a task.
- Enforcement: the UI currently doesn’t use the authorized workspace list as a real boundary.

---

## Problem (In Plain English)

A general agent is only trustworthy if people can clearly answer:

- “What can it see?”
- “What can it change?”

If that boundary is unclear, users either:

- deny permission out of fear (task fails), or
- approve too broadly (unsafe).

---

## Who This Is For

- Primary: anyone who wants to safely use local files.
- Secondary: admins who care about privacy.

---

## Goals

- Make access boundaries visible at all times.
- Default-deny access outside what the user shared.
- Make “expand access” a deliberate user action, not an accidental approval.

## Non-Goals

- Perfect automatic detection of sensitive files.
- Replacing OS-level sandboxing (that’s PRD-014).

---

## User Experience (What You’ll See)

1. In a task, there is a sidebar section called **Files you shared**.
2. It lists folders (and optionally specific files) that the task can access.
3. If the agent requests access outside that list:
   - OpenWork shows a clear warning: “This is outside your shared folders.”
   - The user can:
     - Deny
     - Allow once (for this exact path/pattern)
     - Add a new folder to “Files you shared”
4. The user can review and remove shared folders later.

---

## Requirements

### Must Have

- A **Files you shared** panel visible in the task workspace.
- Show:
  - shared folders
  - shared files (optional)
  - whether the task is in Host mode or Client mode
- When a permission request arrives:
  - clearly show what it’s asking for
  - show whether it is inside or outside shared folders
- Default policy:
  - outside shared folders → block unless user explicitly expands scope

### Should Have

- “Share a folder with this task” button (native picker in Host mode).
- A quick explanation: “OpenWork can only use files you share here.”

### Nice to Have

- Optional “Sensitive mode” toggle:
  - discourage sharing home directory
  - warn about `.env` and credential-like files

---

## Safety, Permissions, and Trust

- OpenWork should never silently expand access.
- Every access expansion should be:
  - explicit
  - reversible
  - recorded in the run report (PRD-010)

---

## Success Metrics

- Fewer permission-deny failures caused by confusion.
- Users can correctly answer “Which files can this task read?”

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Treat the “Authorized Workspaces” list as the UI’s policy boundary.
- In the permission prompt UI:
  - compare requested patterns/paths to authorized roots
  - if outside, show a distinct warning state and require an extra confirmation

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - add “Files you shared” section in the task workspace
  - enforce policy in permission approval flow
- `apps/openwork/src/lib/tauri.ts`
  - ensure folder picker can add to shared list in Host mode

### Phased Delivery

- Phase 1: display the “Files you shared” list in-task (read-only)
- Phase 2: enforce default-deny outside shared folders
- Phase 3: add “share folder with this task” from permission prompt

### Risks and Mitigations

- Risk: OpenCode permission patterns are not always simple paths.
  - Mitigation: implement best-effort matching and show “unknown” as a cautious warning.

### Open Questions

- Should “Allow once” ever be allowed outside shared folders without adding the folder?
