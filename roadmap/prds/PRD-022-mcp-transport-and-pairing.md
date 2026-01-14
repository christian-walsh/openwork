# PRD-022 — MCP Transport + Pairing (Desktop + Mobile)

## One-line Summary

MCP tool calls must work reliably in both Host and Client modes, with secure pairing and clear ownership of approvals.

## Status (Today)

Not implemented.

---

## Problem (In Plain English)

OpenWork’s long-term promise includes:

- Start tasks on a desktop.
- Monitor and approve tasks from a phone.

If we add MCP tools, we must answer:

- Where do tool calls go?
- Who is allowed to approve them?
- How do we keep it secure?

---

## Goals

- Define a secure transport story for MCP in Host mode.
- Define a pairing/approval story for Client mode.
- Make failures graceful (reconnect, retry, clear UI states).

## Non-Goals

- A public cloud relay in v1.

---

## User Experience (What You’ll See)

### Host Mode (Desktop)

1. OpenWork runs the engine locally.
2. When the agent requests a tool:
   - OpenWork shows an approval sheet.
3. If OpenWork is closed, tool requests fail safely (the agent pauses or errors with a clear reason).

### Client Mode (Phone)

1. You pair your phone with your trusted host.
2. You can see tasks running on the host.
3. If the agent requests a tool approval:
   - your phone shows “Needs approval”
   - you can approve/deny from the phone

---

## Requirements

### Must Have

- Host mode: MCP server available to the local engine.
- Authentication:
  - only the local engine (or explicitly paired clients) can call/approve tools
- Clear error states:
  - “Waiting for approval”
  - “Approval timed out”
  - “Disconnected”

### Should Have

- Client mode approvals:
  - allow approving from remote device
  - show which device approved (audit)

### Nice to Have

- Offline queueing for low-risk actions (e.g., notifications).

---

## Safety, Permissions, and Trust

- Tool approvals must be tied to identity:
  - host user
  - paired device
- Approvals must be visible in run reports.

---

## Success Metrics

- Mobile approvals work reliably.
- Users trust that only their devices can approve actions.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Host mode:
  - run MCP server locally (inside Tauri backend)
  - OpenCode connects via localhost transport

- Client mode:
  - host remains the MCP server
  - mobile acts as a remote “approval client”
  - approvals are forwarded to host securely

Implementation should handle:

- reconnect logic
- timeouts
- “only one approver wins” (avoid double approvals)

### Files Likely Touched

- `apps/openwork/src-tauri/src/lib.rs`
  - pairing token generation (host)
  - secure approval channel
- `apps/openwork/src/App.tsx`
  - client UI for approvals

### Open Questions

- What is the minimal secure transport for pairing (LAN-only vs optional tunnel)?
- How do we handle tool call approvals if both host UI and client UI are connected?
