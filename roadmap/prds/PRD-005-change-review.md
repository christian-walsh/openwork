# PRD-005 — Review and Undo Changes (Working Files)

## One-line Summary

OpenWork should make it easy to see what changed, review it, and undo it—without needing git knowledge.

## Status (Today)

Not implemented.

- The UI does not show a “changed files” list or diffs.
- The UI does not offer undo/revert for edits made during a task.

---

## Problem (In Plain English)

A user will trust an agent more if they know:

- what it read
- what it changed
- how to undo mistakes

Without this, users either refuse to let the agent edit files, or they accept changes blindly.

---

## Goals

- Make file changes visible and reviewable.
- Provide “undo” without requiring git experience.
- Keep the UI calm and understandable.

## Non-Goals

- Replacing a full code review tool.
- Implementing a full git UI.

---

## User Experience (What You’ll See)

1. In the task workspace, there is a **Working files** section.
2. It shows two lists:
   - “Looked at” (read)
   - “Changed” (edited/created)
3. You can tap a changed file to see:
   - a simple diff (before/after)
4. You can choose:
   - Accept (do nothing)
   - Undo this file
   - Undo everything from this task

---

## Requirements

### Must Have

- Show “Changed files” per task.
- Open a file details panel that shows a readable diff.
- Undo options:
  - per-file
  - all changes in task

### Should Have

- Show “Looked at” (recently read) files.
- Clearly label when a file is outside “Files you shared” (PRD-002).

### Nice to Have

- “Request review” mode: tasks that must be reviewed before they write changes.

---

## Safety, Permissions, and Trust

- Undo should be reversible where possible (soft undo), or at least clearly warn if it’s destructive.
- If undo requires running commands, OpenWork should ask permission and explain.

---

## Success Metrics

- Higher user confidence letting tasks edit files.
- Fewer cases where users feel “it changed something without me noticing”.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Use OpenCode’s file APIs to power the lists:
  - “Changed” from file status
  - “Looked at” from read events or tool calls
- Diff rendering:
  - prefer an API that returns diffs if available
  - otherwise compute diffs in UI for text files

Undo options (choose based on feasibility):

- If git is present: revert changes via git (optional, advanced)
- If not: maintain backups of edited files and restore
- If OpenCode tracks edits: request OpenCode to revert to pre-run snapshot

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - add Working files panel
  - track “read” vs “changed”
- `apps/openwork/src-tauri/src/lib.rs`
  - optional: implement safe file backup/restore helpers

### Phased Delivery

- Phase 1: “Changed files” list and open file content view
- Phase 2: Diff view for common text formats
- Phase 3: Undo/revert flows

### Open Questions

- What is the best source of truth for “this task changed this file”? (Session-scoped vs repo-scoped)
- Do we require git, or must this work without it?
