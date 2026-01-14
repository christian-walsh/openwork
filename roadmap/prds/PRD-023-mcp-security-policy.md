# PRD-023 — MCP Security Policy (Scopes, Approvals, and “Safe by Default”)

## One-line Summary

OpenWork’s MCP server must enforce a clear security policy so tool calls stay safe, understandable, and user-controlled.

## Status (Today)

Not implemented.

---

## Problem (In Plain English)

MCP makes it easier for an agent to ask the app to do things.

That is powerful — and power needs guardrails.

A non-technical user should never have to “spot suspicious behavior”. Instead, the product should:

- prevent obviously risky actions by default
- ask clearly for approvals
- allow users to revoke access
- keep a trustworthy record

---

## Goals

- Define a simple, enforceable security model for MCP tools.
- Make approvals consistent across the app.
- Make it obvious what the agent can and cannot do.

## Non-Goals

- Claiming absolute security.
- Exposing broad OS access by default.

---

## Threat Model (What We’re Protecting Against)

This PRD assumes the following realistic risks:

- The agent reads untrusted content (especially from the web) that tries to manipulate it.
- The agent may make mistakes and attempt dangerous actions.
- Tool calls could be spammed (accidentally or maliciously).
- A paired device could be lost or compromised.

We cannot fully prevent all mistakes, but we can reduce the blast radius.

---

## User Experience (What You’ll See)

### “App Tools” Settings

1. In Settings, there is a section called **App Tools**.
2. It lists tool categories (not protocol jargon):
   - Confirmations
   - File pickers
   - Outputs
   - Notifications
3. Each category has a simple toggle:
   - Off
   - Ask every time
   - Allow for this task (when safe)

### During a Task

- When the agent requests a tool:
  - OpenWork shows a clear approval sheet
  - it explains what data is involved
  - it shows the “scope” (what this approval applies to)

### Revoking Access

- Users can revoke:
  - a per-task allowance
  - a device pairing
  - an entire tool category

---

## Requirements

### Must Have

- A security policy that answers, for every tool call:
  - is it allowed?
  - is approval required?
  - what scope does approval cover?
  - what is recorded for audit?

- Default posture:
  - **deny-by-default** for OS-sensitive actions

- Approval scopes:
  - Allow once
  - Allow for this task
  - Deny

- Timeouts:
  - approvals expire after a reasonable time (configurable)

### Should Have

- Rate limiting:
  - prevent “approval spam”
  - collapse repeated identical requests

- Device attribution:
  - show which device approved a request (host vs phone)

### Nice to Have

- “Escalation confirmations”:
  - when a task requests a larger scope than before, require an extra confirmation step

---

## Policy Details (Concrete)

### Risk Levels

Each tool is assigned a risk level:

- Low:
  - notification
- Medium:
  - open output (launch external app)
- High:
  - pick folder to share (expands access boundary)
  - any tool that could expose file content

Default behavior:

- Low: allowed (unless notifications disabled)
- Medium: ask
- High: ask + show extra explanation + show scope

### Scope Rules

- “Allow for this task” is only valid if the tool call is tied to a single task/session.
- Any approval that expands file access must be aligned with PRD-002 (“Files you shared”).

### Audit Rules

Every tool call should record:

- tool name
- human-readable title
- timestamp
- risk level
- approval decision (and by which device)
- a redacted summary of inputs/outputs

---

## Safety, Permissions, and Trust

Key user promises:

- OpenWork will not silently share new folders.
- OpenWork will not silently run OS-level actions.
- The user can always deny and continue with a smaller scope.

---

## Success Metrics

- Users understand approvals and choose appropriately.
- Reduced accidental broad access grants.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Define the policy in one place:
  - tool registry + policy evaluator
- Enforce policy in the MCP server before any OS action occurs.
- Forward only “approved” tool calls to execution.
- UI renders approvals using an existing permission prompt style (visual consistency).

### Files Likely Touched

- `apps/openwork/src-tauri/src/lib.rs`
  - MCP policy enforcement
  - pairing management
- `apps/openwork/src/App.tsx`
  - settings UI (“App Tools”)
  - approval sheets

### Phased Delivery

- Phase 1: tool registry with risk levels + “ask/deny”
- Phase 2: scopes (“allow for task”) + auditing
- Phase 3: rate limiting + device attribution

### Open Questions

- Where should policy live long-term: UI, MCP server, or both (defense in depth)?
- What is the safest default for Client mode approvals?
