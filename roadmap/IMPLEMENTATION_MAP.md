# Implementation Map (How We’d Build Each PRD)

This document is a practical bridge between:

- the user-friendly PRDs in `prds/`
- the existing OpenWork codebase

It answers: “If we decided to build this tomorrow, where would we start?”

---

## Existing Code Anchors (Today)

OpenWork is currently centered in one UI file and a small Tauri backend:

- UI:
  - `apps/openwork/src/App.tsx` (most screens and state)
  - `apps/openwork/src/components/PartView.tsx` (renders tool/text parts)
  - `apps/openwork/src/lib/opencode.ts` (OpenCode client + health helpers)
  - `apps/openwork/src/lib/tauri.ts` (Tauri command wrappers)

- Tauri:
  - `apps/openwork/src-tauri/src/lib.rs` (engine spawn + opkg install + config read/write)

---

## PRD Build Map

### PRD-001 — Task Workspace

- UI work:
  - rename UI language (“sessions/runs” → “tasks”) in `apps/openwork/src/App.tsx`
  - adjust workspace layout and mobile presentation (keep current state model)
- OpenCode APIs:
  - already used: `session.list`, `session.create`, `session.messages`, `session.prompt`, `session.todo`
- Tauri work:
  - none required
- Risks:
  - large refactor; mitigate by only changing labels/layout first

### PRD-002 — Files You Shared

- UI work:
  - render shared folders in task workspace
  - use shared folder list as a guardrail in permission approvals
- OpenCode APIs:
  - already used: `permission.list`, `permission.reply`
- Tauri work:
  - use existing directory picker (`apps/openwork/src/lib/tauri.ts`) in Host mode
- Implementation detail:
  - define a best-effort “is request inside shared folders?” matcher (paths + glob patterns)

### PRD-003 — Action Log

- UI work:
  - build an “Activity” feed derived from tool parts (and optionally events)
  - add grouping (same tool + similar title + repeated)
- OpenCode APIs:
  - no new endpoints required if tool parts carry enough info
- Tauri work:
  - none required

### PRD-004 — Outputs (Artifacts)

- UI work:
  - add Outputs panel
  - add preview rendering (text/markdown/images first)
- OpenCode APIs:
  - likely needed: a “what changed” source (design PRD suggests file status)
  - candidate: `file.status()` (verify exact SDK shape when implementing)
- Tauri work:
  - add commands for:
    - open file
    - reveal in folder
    - save as/export

### PRD-005 — Review and Undo Changes

- UI work:
  - changed files list + diff view + undo buttons
- OpenCode APIs:
  - likely needed:
    - file status
    - file read
    - diff support (if available)
- Tauri work:
  - optional fallback undo helpers:
    - backup/restore files
- Notes:
  - decide whether git is required (prefer “works without git”)

### PRD-006 — Connectors

- UI work:
  - add Connectors panel
  - show availability (based on plugins/skills)
  - show enabled/disabled per task
- OpenCode APIs:
  - depends on how connectors are implemented:
    - via plugins
    - via built-in tools
- Tauri work:
  - none required for “visibility only” stage

### PRD-007 — Safety Profiles

- UI work:
  - settings UI for profile selection
  - a small policy engine that influences:
    - connector defaults
    - confirmation gates
    - level of detail shown
- OpenCode APIs:
  - none required
- Tauri work:
  - none required

### PRD-008 — Provenance + Guardrails

- UI work:
  - provenance labels on steps
  - confirmations for risky actions especially after web-derived content
- OpenCode APIs:
  - depends on whether OpenCode marks web steps distinctly
- Tauri work:
  - none required

### PRD-009 — Run Budgets

- UI work:
  - counters + budgets + pause/continue
- OpenCode APIs:
  - none required for basic counters
- Tauri work:
  - none required
- Notes:
  - implement “soft pause” by blocking additional prompts until user approves

### PRD-010 — Run Reports

- UI work:
  - export button + format selection + redaction controls
- OpenCode APIs:
  - gather:
    - messages
    - todos
    - permissions
    - outputs
- Tauri work:
  - save/export using native dialogs

### PRD-011 — Layout + Focus

- UI work:
  - panel toggles
  - mobile drawers
  - focus mode
- Tauri work:
  - none required

### PRD-012 — Template Gallery

- UI work:
  - starter templates included in app
  - guided field UI
- OpenCode APIs:
  - reuse `session.create` + `session.prompt`
- Tauri work:
  - folder picker for guided flows

### PRD-013 — Retention + Privacy

- UI work:
  - privacy settings
  - per-task delete flows
- OpenCode APIs:
  - likely needed:
    - delete session endpoint (verify when implementing)
- Tauri work:
  - optional: safe delete of known outputs

### PRD-014 — Protected Mode

- UI work:
  - settings toggle + status
- Tauri work:
  - new engine start mode (sandboxed)
- Notes:
  - build as experimental first, platform-specific

---

## MCP Implementation Map

### PRD-020 — MCP Server Inside OpenWork

- Tauri work:
  - run MCP server lifecycle inside `apps/openwork/src-tauri/src/lib.rs`
  - expose status to UI
- UI work:
  - show “App tools available” state
- Integration work:
  - connect OpenCode to OpenWork MCP server (likely via config + plugin/tooling)

### PRD-021 — MCP Tools + Approvals

- Tauri work:
  - tool registry with schemas and risk levels
  - send tool call requests to UI
  - receive approvals/results
- UI work:
  - approval sheet that matches the existing permission prompt style
  - activity entries for tool calls

### PRD-022 — MCP Transport + Pairing

- Tauri work:
  - secure token-based pairing (host)
  - approval forwarding for client devices
- UI work:
  - remote approvals on mobile
  - device attribution (“approved from phone”)

### PRD-023 — MCP Security Policy

- Tauri work:
  - policy evaluator (risk levels, scopes, rate limits)
  - revocation store (per-task and per-device)
- UI work:
  - “App Tools” settings
  - consistent approval sheets with scope display

### PRD-024 — MCP Operations

- Tauri work:
  - MCP lifecycle manager (status, restart, last error)
  - diagnostics capture and redacted export
- UI work:
  - status indicator and recovery actions
  - diagnostics panel in Developer mode

---

## Verification Checklist (For PRD Delivery)

When we implement any PRD, we should verify:

- The UI is understandable without developer knowledge.
- The feature is safe by default.
- There is a clear “stop” path.
- The outcome is visible (outputs, report, or explicit result screen).
