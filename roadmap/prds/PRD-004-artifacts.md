# PRD-004 — Outputs (Artifacts) as a First-Class Feature

## One-line Summary

When a task finishes, OpenWork should show clear, usable outputs you can open, share, and trust.

## Status (Today)

Not implemented as a dedicated feature.

- Users can see conversation and tool outputs.
- There is no “Outputs/Artifacts” panel that lists files created/modified.

---

## Problem (In Plain English)

A task isn’t done when the chat stops.

A task is done when the user can say:

- “Here is what it made for me.”
- “I can open it.”
- “I can send it to someone.”

Without first-class outputs, users end up hunting through folders, or copying from chat.

---

## Goals

- Make outputs visible and easy to use.
- Prevent “where did it put the file?” confusion.
- Keep output preview safe and predictable.

## Non-Goals

- Becoming a full document editor.

---

## User Experience (What You’ll See)

1. In the task workspace there is a section called **Outputs**.
2. As the task runs, outputs appear when created.
3. Each output shows:
   - name
   - type (document, spreadsheet, image, HTML page, etc.)
   - when it was created
4. You can:
   - open it
   - copy it
   - save/export it
5. If it’s an HTML output, OpenWork previews it safely and also offers “Open in browser”.

---

## Requirements

### Must Have

- A dedicated **Outputs** section per task.
- Output list items show:
  - filename
  - path (optional, can be hidden behind “Details”)
  - size
  - created/updated time
- Open actions:
  - “Open” (native)
  - “Reveal in folder” (desktop)

### Should Have

- Built-in preview for common formats:
  - Markdown/text
  - images
- Clear “safe preview” rules:
  - no automatic network calls
  - for HTML, default to safest preview mode, with an explicit “Open in browser” action

### Nice to Have

- “Share” integration where platform supports it.
- “Export output bundle” (zip).

---

## Safety, Permissions, and Trust

- Outputs should clearly show provenance:
  - “Created by this task”
  - “Modified by this task”
- HTML preview should be conservative.
- If outputs include sensitive data, pair with retention controls (PRD-013).

---

## Success Metrics

- Users find and open outputs without leaving the app.
- Reduced “where is the file?” support questions.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

OpenWork needs a reliable way to detect “what files this task produced”. Options:

1. Use OpenCode’s file status APIs (preferred if available):
   - show changed/created files as outputs
2. Infer outputs from tool calls (best-effort):
   - detect file-write-like tools and capture paths
3. Allow the agent to explicitly mark outputs:
   - “I created these files” structured message that OpenWork renders as Outputs

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - add Outputs panel in task workspace
  - refresh outputs when session becomes idle
- `apps/openwork/src/components/PartView.tsx`
  - optionally promote “created file” tool outputs into outputs list
- `apps/openwork/src-tauri/src/lib.rs`
  - add OS-native “open file / reveal in folder” commands if needed

### Phased Delivery

- Phase 1: Outputs list populated by changed files (basic open)
- Phase 2: Previews for text/markdown/images
- Phase 3: Safe HTML preview + explicit “Open in browser”

### Open Questions

- Which OpenCode endpoint/event should be the source of truth for file changes per session?
- How do we avoid listing unrelated repo changes not caused by the task?
