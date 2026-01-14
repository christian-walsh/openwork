# PRD-001 — Task Workspace (Make Runs Feel Like Work)

## One-line Summary

OpenWork should feel like a “task workspace” where each task has a clear home: progress, outputs, and what it can access.

## Status (Today)

Partially implemented:

- Users can create sessions (runs) and view them.
- There is a dedicated session view with messages, an execution plan sidebar (desktop), and permission prompts.

What’s missing is the non-technical framing: “tasks”, “outputs”, “files you shared”, and a consistent workspace layout.

---

## Problem (In Plain English)

Right now, OpenWork works, but it still feels like a developer tool in a few important ways:

- People don’t think in “sessions” or “runs”. They think in tasks like “review these drafts” or “make me a report”.
- The most important trust signals (progress, permissions, outputs) aren’t always visible together.
- The UI changes shape depending on screen size (plan sidebar disappears on small screens), which can feel like the app is “hiding” what the agent is doing.

---

## Who This Is For

- Primary: non-technical knowledge workers who want outcomes, not a terminal.
- Secondary: power users who still want transparency.
- Not for: people who want a full IDE replacement.

---

## Goals

- Make “Task” the primary concept (rename/reshape “session” in the UI).
- Provide a consistent workspace layout:
  - conversation
  - progress
  - permissions
  - outputs
  - what the task can access
- Make it easy to start, resume, and understand tasks.

## Non-Goals

- Turning OpenWork into a project management app.
- Adding new agent capabilities that don’t map to OpenCode.

---

## User Experience (What You’ll See)

1. You open OpenWork and see a **Tasks** list.
2. You click **New Task** and type what you want.
3. The task opens in a workspace where you can always see:
   - what’s happening now
   - what step it’s on
   - what it’s going to do next
   - what outputs it produced
4. If OpenWork needs permission, it asks you clearly, without jargon.
5. When done, the task clearly shows “Here’s what I made” (outputs) and “Here’s what changed”.

---

## Requirements

### Must Have

- **Rename Sessions → Tasks** in the UI (language only).
- **Task list** with:
  - title
  - last updated time
  - status (running / idle / error / needs approval)
- **Task workspace layout** with three conceptual areas:
  - Main: conversation + action timeline
  - Right: Progress / Outputs / Access / Approvals
  - Bottom: prompt input and model selector
- A task can be resumed by tapping it.

### Should Have

- Search tasks by title.
- Pin/star important tasks.
- Clear empty states that explain what a task is.

### Nice to Have

- “New task from template” shortcut.

---

## Safety, Permissions, and Trust

- The workspace should always show whether a task is:
  - local
  - connected to a remote host (client mode)
- The UI should avoid scary words like “sandbox”. It should instead say:
  - “Files you shared”
  - “Web access” (if enabled)
  - “Requires approval”

---

## Success Metrics

- A first-time user can start a task without help.
- Users can answer: “What is it doing right now?” by looking at the workspace.
- Fewer abandoned runs caused by uncertainty.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

OpenWork already has the building blocks (sessions list, session view, todos, permissions). This PRD is mostly about:

- reorganizing the UI into a more consistent workspace
- renaming concepts
- ensuring side panels collapse gracefully on mobile

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - rename labels “Sessions/Runs” → “Tasks”
  - restructure tabs/navigation (without changing backend behavior)
  - improve session view layout for smaller screens

### Phased Delivery

- Phase 1: Language + navigation (“Tasks” everywhere)
- Phase 2: Workspace right sidebar on mobile (collapsible drawers)
- Phase 3: Workspace sections (“Outputs”, “Files you shared”) even if empty

### Risks and Mitigations

- Risk: UI rewrite creates regressions.
  - Mitigation: keep OpenCode interactions the same; change layout and labels first.

### Open Questions

- Should we keep “Runs” as a secondary label anywhere, or fully hide it?
