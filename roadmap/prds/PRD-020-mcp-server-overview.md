# PRD-020 — MCP Server Built Into OpenWork (Standard “Tool Provider”)

## One-line Summary

OpenWork should include a built-in MCP server so the agent can request safe, user-approved actions through a standard protocol.

## Status (Today)

Not implemented.

- OpenWork is currently a UI client for OpenCode.
- OpenWork does not expose a tool server that OpenCode (or other agents) can call.

---

## Problem (In Plain English)

There are actions that are easiest (or safest) when the **app** handles them:

- opening a file picker
- asking the user a question in a clear UI
- opening an output document
- showing a notification

Right now, these actions are either:

- implemented ad-hoc, or
- pushed into prompts (which is brittle), or
- handled by plugins in inconsistent ways

MCP (Model Context Protocol) is a standard way for an agent to call tools.

If OpenWork becomes an MCP server, it can safely provide “app-native tools” with good UX and approvals.

---

## Goals

- Make OpenWork a trusted “capability provider” for the agent.
- Use a standard protocol (MCP) instead of custom hacks.
- Ensure every sensitive tool call is user-approved and auditable.

## Non-Goals

- Replacing OpenCode’s existing tools.
- Exposing dangerous OS powers by default.

---

## User Experience (What You’ll See)

1. A task wants to do something that requires app interaction (example: choose a folder).
2. OpenWork shows a clear prompt:
   - what the agent is requesting
   - why it needs it
   - what will happen next
3. The user approves or denies.
4. The task continues.

The user never needs to know the acronym “MCP”. It is just the plumbing.

---

## Requirements

### Must Have

- OpenWork can run an MCP server in Host mode.
- The agent can call OpenWork-provided tools.
- Every MCP tool call is:
  - visible to the user (Activity log)
  - logged (for run reports)
  - gated by permissions when needed

### Should Have

- Works in Client mode when connected to a host (transport + authentication).
- “Connector-like” UI for MCP: which tool families are enabled.

### Nice to Have

- Allow third-party “OpenWork MCP tool packs” (future).

---

## Safety, Permissions, and Trust

- MCP tools should be safe by default:
  - read-only unless explicitly approved
  - no secret access
  - no wide filesystem access
- Tool calls must be human-readable:
  - “Open folder picker” not “tools/call”

---

## Success Metrics

- Users can complete more workflows without leaving the app.
- Fewer confusing permission prompts.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Implement an MCP server inside the Tauri backend (Rust) or as a sidecar process.
- Provide a minimal initial tool set:
  - pick file/folder
  - show notification
  - open output
  - request confirmation
- Integrate with UI:
  - tool calls show up in the Activity log
  - approvals appear as first-class dialogs

### Files Likely Touched

- `apps/openwork/src-tauri/src/lib.rs`
  - MCP server lifecycle management
- `apps/openwork/src/App.tsx`
  - render MCP tool call requests and approvals

### Open Questions

- Which MCP transport should we use first (stdio vs local HTTP/SSE), given Tauri constraints?
- How do we authenticate MCP calls in Client mode?
