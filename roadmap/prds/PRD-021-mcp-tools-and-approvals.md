# PRD-021 — MCP Tools + Approvals + Audit Log (Human-in-the-Loop by Design)

## One-line Summary

Every MCP tool call should be understandable, approval-gated when needed, and recorded so users can trust what happened.

## Status (Today)

Not implemented.

---

## Problem (In Plain English)

If the agent can call tools, the user needs guardrails.

Most users don’t care about the exact protocol. They care about:

- “What is it trying to do?”
- “Is this safe?”
- “Can I stop it?”
- “Can I see what happened later?”

---

## Goals

- Define a safe initial MCP tool catalog.
- Define a consistent approval model.
- Make all tool calls visible and exportable.

## Non-Goals

- Shipping a huge tool catalog in v1.

---

## User Experience (What You’ll See)

1. The agent requests a tool.
2. OpenWork shows an approval sheet with:
   - a plain-English title
   - a short explanation (“why”)
   - what data is involved (“which folder”, “which file”)
   - the choices (Allow once / Allow for this task / Deny)
3. If approved, the agent receives the result and continues.
4. Later, the user can open the run report and see:
   - every tool request
   - approvals
   - results (with safe redaction)

---

## Requirements

### Must Have

- MCP tool calls are rendered in the UI as Activity items.
- MCP tool calls have a consistent approval model:
  - **Allow once**
  - **Allow for this task**
  - **Deny**
- Approval decisions are recorded in the run report (PRD-010).

### Should Have

- Tool categories that map to user expectations:
  - Files
  - Notifications
  - Confirmations
  - Outputs
- Tool scopes:
  - “only inside Files you shared” (PRD-002)

### Nice to Have

- A “Review required before write” profile that automatically gates write tools (ties to PRD-007).

---

## Initial MCP Tool Catalog (Proposed)

This list is intentionally small and user-friendly.

### Category: Confirmations

- `openwork.confirm`
  - Purpose: ask the user to confirm a risky action
  - Always requires approval

### Category: File/Folder Pickers

- `openwork.pick_folder`
  - Purpose: choose a folder to share with the task
  - Always requires approval

- `openwork.pick_file`
  - Purpose: choose a specific file to share
  - Always requires approval

### Category: Outputs

- `openwork.open_output`
  - Purpose: open an output file or reveal it in the file system
  - Requires approval if it opens external apps

### Category: Notifications

- `openwork.notify`
  - Purpose: show a local notification when a run finishes or needs input
  - No approval required (unless user disables notifications)

---

## Safety, Permissions, and Trust

- Any tool that touches the OS should be approval-gated.
- Any tool that could leak data outside the app should be approval-gated.
- Results should be redacted and summarized by default.

---

## Success Metrics

- Users confidently approve tool calls.
- Fewer “always allow everything” decisions.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Maintain a central tool registry in the MCP server implementation:
  - tool schema
  - risk level
  - default approval policy
- Send MCP tool call requests to the UI via a Tauri event channel.
- UI returns approval + optional user input.

### Files Likely Touched

- `apps/openwork/src-tauri/src/lib.rs`
  - MCP tool registry
  - IPC events to UI
- `apps/openwork/src/App.tsx`
  - approval UI
  - activity rendering

### Open Questions

- How do we represent “Allow for this task” when MCP calls may come from different sessions?
- What is the right default: always show tool call output, or show summaries with expandable details?
