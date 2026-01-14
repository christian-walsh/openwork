# PRD-024 — MCP Operations (Reliability, Status, and Debugging)

## One-line Summary

If OpenWork provides MCP tools, it must also provide reliable operations: status indicators, clear failures, and safe debugging.

## Status (Today)

Not implemented.

---

## Problem (In Plain English)

When something goes wrong with “app tools”, users shouldn’t be stuck.

We need to handle:

- the MCP server not running
- the engine unable to connect
- client device disconnects
- approvals timing out

Without a clear operational story, MCP becomes a source of confusion and support burden.

---

## Goals

- Make MCP feel invisible when it works.
- Make problems diagnosable when it doesn’t.
- Keep debugging safe (no secrets in logs by default).

## Non-Goals

- Building a full observability platform.

---

## User Experience (What You’ll See)

### Normal Users

- In the task header (or settings), a simple indicator:
  - “App tools: Ready”
  - “App tools: Not available”
- When a tool request fails, OpenWork shows:
  - what failed
  - what the user can do (“retry”, “open settings”, “continue without tools”)

### Developer Mode

- A diagnostics panel shows:
  - MCP server status
  - recent tool calls
  - recent errors
  - export diagnostics (redacted)

---

## Requirements

### Must Have

- A clear MCP status indicator.
- Clear error messages when:
  - the engine can’t reach MCP
  - approvals time out
  - a tool call is denied by policy
- A user-safe recovery path:
  - retry
  - restart app tools

### Should Have

- Automatic restart (best-effort) if the MCP server crashes.
- A diagnostics export that is redacted by default.

### Nice to Have

- “Test app tools” button that runs a safe self-check.

---

## Safety, Permissions, and Trust

- Logs must avoid secrets.
- Diagnostics export must default to redaction.

---

## Success Metrics

- Low support burden for MCP features.
- Users can recover from common failures without help.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Maintain an MCP manager inside the Tauri backend:
  - server lifecycle
  - status
  - last error
  - restart method
- Expose MCP status to UI via Tauri commands/events.
- Build a small Developer panel (only when Developer mode is on).

### Files Likely Touched

- `apps/openwork/src-tauri/src/lib.rs`
  - MCP lifecycle manager
  - diagnostics collection
- `apps/openwork/src/App.tsx`
  - status indicator
  - developer diagnostics UI

### Open Questions

- Where should diagnostics be stored (in-memory vs file)?
- How do we avoid collecting sensitive information while still being useful?
