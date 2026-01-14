# PRD-010 — Run Reports (Exportable, Shareable Audit)

## One-line Summary

OpenWork should let users export a run into a shareable report: what happened, what changed, and what was produced.

## Status (Today)

Not implemented as an export feature.

- The app has the data (messages, todos, permissions), but there is no export UI.

---

## Problem (In Plain English)

People often need to:

- share what the agent did with a teammate
- keep a record for later
- justify decisions (“why did we change this?”)

A run report turns an agent run into something that looks like real work output.

---

## Goals

- Provide a one-click “Export report” button.
- Produce a report that a non-technical person can understand.
- Include enough detail for trust and auditing.

## Non-Goals

- Hosting/syncing reports to a cloud service in v1.

---

## User Experience (What You’ll See)

1. After (or during) a task, you can click **Export report**.
2. You choose a format:
   - HTML (recommended)
   - JSON (for advanced users)
3. The report includes:
   - task title and timestamp
   - summary of what happened
   - steps taken
   - permissions requested and approvals
   - outputs created
   - files changed

---

## Requirements

### Must Have

- Export in HTML.
- Include a clear “executive summary” section.
- Include permission decisions.
- Include outputs list (PRD-004).

### Should Have

- Redaction options:
  - hide full file paths
  - hide web URLs
  - hide tool raw outputs

### Nice to Have

- PDF export.
- “Copy summary” button.

---

## Safety, Permissions, and Trust

- Reports should never accidentally include secrets.
- Redaction should be on by default.

---

## Success Metrics

- Increased user confidence.
- Teams can share agent runs without copying raw chat logs.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Gather data from OpenCode APIs:
  - session messages
  - todos
  - permission list (and replies)
  - outputs/changed files
- Render to HTML using a simple, static template.
- Save via Tauri “Save As…” dialog.

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - export button + format choice
- `apps/openwork/src-tauri/src/lib.rs`
  - file save dialog + write file

### Open Questions

- What is the best approach for safe redaction without losing usefulness?
