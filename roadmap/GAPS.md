# Gaps and Coverage (What Exists vs What We’re Planning)

This document maps each PRD to:

- what OpenWork already has today
- what is missing
- the most concrete implementation approach (without writing code)

This is intentionally written for a mixed audience:

- non-technical stakeholders can skim the “What exists / What’s missing” parts
- contributors can use the “Implementation notes” parts to start building

---

## What OpenWork Already Has (Foundation)

These capabilities exist today and will be reused by almost every PRD:

- Engine lifecycle (Host): starts/stops `opencode serve` (`apps/openwork/src-tauri/src/lib.rs`)
- Connect to server (Host/Client): health check + model list (`apps/openwork/src/App.tsx`)
- Sessions (runs): list/create/select (`apps/openwork/src/App.tsx`)
- Streaming: subscribes to SSE events (`apps/openwork/src/App.tsx`)
- Execution plan: shows todos in sidebar (desktop) (`apps/openwork/src/App.tsx`)
- Permissions: shows modal and replies allow/deny (`apps/openwork/src/App.tsx`)
- Templates: save and run (local) (`apps/openwork/src/App.tsx`)
- Skills manager: list/install/import (`apps/openwork/src/App.tsx`, `apps/openwork/src-tauri/src/lib.rs`)
- Plugin manager: read/write project/global `opencode.json` (`apps/openwork/src/App.tsx`, `apps/openwork/src-tauri/src/lib.rs`)
- Safety basics: hide reasoning by default; redact sensitive keys (`apps/openwork/src/App.tsx`, `apps/openwork/src/components/PartView.tsx`)

---

## PRD-by-PRD Coverage

### PRD-001 — Task Workspace

- What exists:
  - sessions list + session view + plan sidebar + permission prompts (`apps/openwork/src/App.tsx`)
- What’s missing:
  - non-technical “Tasks” framing and a consistent workspace layout on all screen sizes
- Implementation notes:
  - rename “Sessions/Runs” to “Tasks” in UI copy
  - ensure workspace always has visible sections for Progress/Outputs/Access (even if empty)

### PRD-002 — Files You Shared

- What exists:
  - “Authorized Workspaces” list stored locally (`apps/openwork/src/App.tsx`)
- What’s missing:
  - the list is not visible during tasks
  - the list is not enforced as a boundary for permission replies
- Implementation notes:
  - render “Files you shared” in the task workspace
  - when permissions are requested, compare request patterns to authorized roots and require explicit expansion for out-of-scope

### PRD-003 — Action Log

- What exists:
  - tool cards with status/output (`apps/openwork/src/components/PartView.tsx`)
- What’s missing:
  - a dedicated activity timeline with grouping and plain-English labels
- Implementation notes:
  - promote tool parts into a separate “Activity” feed
  - keep raw inputs/outputs behind expandable details

### PRD-004 — Outputs (Artifacts)

- What exists:
  - tool outputs appear inline in chat
- What’s missing:
  - a dedicated Outputs panel listing files created/modified
  - previews and “open/reveal” actions
- Implementation notes:
  - define an “output” model sourced from file status or structured messages
  - add Tauri helpers for open/reveal

### PRD-005 — Review and Undo Changes

- What exists:
  - none (no change review UI)
- What’s missing:
  - changed file list, diffs, undo
- Implementation notes:
  - rely on OpenCode file APIs for status
  - choose an undo strategy (git-backed, backups, or engine support)

### PRD-006 — Connectors

- What exists:
  - plugins manager + suggested plugins (`apps/openwork/src/App.tsx`)
- What’s missing:
  - unified “Connectors” panel
  - per-task enable/disable and allowlists
- Implementation notes:
  - Stage 1: surface availability (installed/configured)
  - Stage 2: store connector settings and inject constraints into tasks

### PRD-007 — Safety Profiles

- What exists:
  - Developer mode toggle (`apps/openwork/src/App.tsx`)
- What’s missing:
  - non-technical presets that change default behavior
- Implementation notes:
  - add a small “policy layer” in the UI
  - apply it to connectors, confirmations, and permission prompts

### PRD-008 — Provenance + Guardrails

- What exists:
  - redaction of sensitive keys (`apps/openwork/src/components/PartView.tsx`)
- What’s missing:
  - provenance labels
  - high-risk action gates, especially for web-derived content
- Implementation notes:
  - add a provenance label model for steps
  - require extra confirmations for risky actions when untrusted sources are involved

### PRD-009 — Run Budgets

- What exists:
  - elapsed time UI state (`apps/openwork/src/App.tsx`)
- What’s missing:
  - step/connectors counters and budget controls
- Implementation notes:
  - count tool calls and connector usage
  - implement “soft pause” and user continuation

### PRD-010 — Run Reports

- What exists:
  - all data is visible in-app, but not exportable
- What’s missing:
  - export to HTML/JSON with redaction
- Implementation notes:
  - gather session messages/todos/permissions/outputs
  - render HTML template and save via Tauri

### PRD-011 — Layout + Focus

- What exists:
  - desktop right sidebar plan (`apps/openwork/src/App.tsx`)
- What’s missing:
  - toggles and mobile drawers
  - output focus mode
- Implementation notes:
  - introduce layout state (sidebar open/closed, focus outputs)

### PRD-012 — Template Gallery

- What exists:
  - user templates stored locally (`apps/openwork/src/App.tsx`)
- What’s missing:
  - curated starter gallery
  - guided fields
- Implementation notes:
  - add “starter templates” as built-in content
  - extend template schema to include variables and required permissions

### PRD-013 — Retention + Privacy

- What exists:
  - localStorage storage for some settings
- What’s missing:
  - delete task/run
  - retention policy
- Implementation notes:
  - add Privacy settings
  - implement session deletion where supported
  - scope output deletion to known task-created artifacts

### PRD-014 — Protected Mode (Sandboxed Engine)

- What exists:
  - engine runs directly on host (`apps/openwork/src-tauri/src/lib.rs`)
- What’s missing:
  - OS-level isolation and mount-only shared folders
- Implementation notes:
  - prototype platform-specific sandboxing
  - keep UX simple: “Protected mode (recommended)”

---

## MCP PRDs

### PRD-020 — MCP Server Built Into OpenWork

- What exists:
  - none
- What’s missing:
  - MCP server lifecycle and tool registration
- Implementation notes:
  - implement MCP server in Tauri backend
  - integrate tool calls into UI Activity

### PRD-021 — MCP Tools + Approvals + Audit

- What exists:
  - permission prompts exist for OpenCode permission events
- What’s missing:
  - MCP-specific approvals and audit integration
- Implementation notes:
  - tool registry with risk levels
  - forward tool call requests to UI

### PRD-022 — MCP Transport + Pairing

- What exists:
  - Host/Client connection modes exist at the OpenCode API level
- What’s missing:
  - secure pairing for MCP approvals across devices
- Implementation notes:
  - host remains source of truth
  - mobile can act as remote approver with secure tokens

### PRD-023 — MCP Security Policy

- What exists:
  - none
- What’s missing:
  - scopes, approvals, rate limits, and revocation rules for MCP tool calls
- Implementation notes:
  - define tool risk levels and default gating
  - integrate with “Files you shared” (PRD-002) and Safety Profiles (PRD-007)

### PRD-024 — MCP Operations

- What exists:
  - none
- What’s missing:
  - status indicators, restart flows, and diagnostics export
- Implementation notes:
  - build an MCP manager in the Tauri backend (status + last error)
  - provide a diagnostics panel behind Developer mode
