# Roadmap (User-Friendly)

This roadmap turns a “general agent” into a product that normal people trust.

The biggest lessons from agent UIs like Cowork are:

- People need a **task space** (a place to work) more than they need “chat”.
- People trust the agent when it is **transparent** (what it’s doing, why, and what changed).
- Safety must be **built into defaults**, not left up to the user to “watch for suspicious actions”.

---

## Current State (What’s Already Working)

OpenWork already supports:

- Creating runs (OpenCode sessions)
- Streaming updates in realtime
- Showing a live “Execution Plan” (todos)
- Asking for permissions and letting the user approve/deny
- Templates (save and re-run)
- Skills (install/import)
- Plugins manager (project/global `opencode.json`)

See: `GAPS.md` for the detailed mapping.

---

## Next: Make Runs Feel Like “Work”

These are the highest-leverage improvements for non-technical users.

### Phase 1 — Trust + Clarity

- PRD-001: A clearer “Task Workspace” (less developer vibe)
- PRD-002: “Files you shared” boundary that stays visible
- PRD-003: Human-readable action log (what the agent is doing)

### Phase 2 — Outputs You Can Use

- PRD-004: Artifacts (outputs) as a first-class feature
- PRD-005: Working files + review/undo for changes
- PRD-010: Export a run report (share with others)

### Phase 3 — Safe Power

- PRD-006: Connectors (like web search) with clear permissions
- PRD-007: Safety profiles (Personal / Work / Locked-down)
- PRD-008: Prompt-injection guardrails and provenance UI
- PRD-009: Budgets (limit web calls, time, and step count)

### Phase 4 — Deep Isolation + Advanced Architecture

- PRD-014: Sandboxed engine mode (strong isolation)

---

## MCP Roadmap (Inside the App)

MCP is the path to “OpenWork as a trusted capability provider”:

- OpenWork can expose safe tools (like pick a folder, show a confirmation, open an output)
- The agent can request those tools via a standard protocol
- The user stays in control through approvals and scopes

Planned PRDs:

- PRD-020: MCP server built into OpenWork (overview)
- PRD-021: MCP tools + approvals + audit logging
- PRD-022: MCP transport and pairing (desktop + mobile)
- PRD-023: MCP security policy (scopes and guardrails)
- PRD-024: MCP operations (reliability and debugging)

---

## How We Ship

We ship in small slices:

- The user-facing behavior must be usable in isolation.
- Every slice must preserve trust: clear UI states, auditability, and reversible actions.
- If a feature requires broad permissions, it must come with safe defaults and explicit user choice.

See: `DELIVERY_PLAYBOOK.md`.
