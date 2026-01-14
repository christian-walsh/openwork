# Delivery Playbook (How We Ship PRDs)

This document explains how we take a PRD from “idea” to “shipped”, in a way that keeps OpenWork **non-technical friendly**.

OpenWork’s goal is not to be a developer console. It’s to make OpenCode feel like a calm, premium work assistant.

---

## The Golden Rule

If a user can’t tell what’s happening, they won’t trust it.

So for every feature we ship, we must answer:

- What is the agent doing?
- Why is it doing it?
- What can it access?
- What changed?
- Can I stop it?
- Can I undo it?

---

## How PRDs Should Be Written

Each PRD should have:

1. **User story first** (plain English)
2. **Clear screens and flows** (what the user clicks and sees)
3. **Trust & safety rules** (what the app asks/blocks)
4. **Success metrics** (how we know it worked)
5. **Build notes** (implementation plan without code)

Use the template: `PRD_TEMPLATE.md`.

---

## How We Deliver a PRD (Phases)

### Phase 0 — Validate the Need

- Write the simplest version of the user story.
- Identify the “moment of value” (what the user gets at the end).
- List the minimum UI needed for that moment.

### Phase 1 — MVP UI With Honest Limits

- Ship the UI flow even if it has limits (as long as it’s honest and safe).
- Always show:
  - progress
  - stop/cancel
  - what changed (or a clear message that nothing changed)

### Phase 2 — Make It Trustworthy

- Add action logs and confirmations for risky steps.
- Make the boundary visible (“Files you shared”, enabled connectors).
- Add undo/review where applicable.

### Phase 3 — Make It Delightful

- Smooth animations (respect reduced motion)
- Great empty states
- Clear microcopy

---

## Definition of Done (For PRD Work)

A PRD slice is “done” when:

- The user can complete the flow end-to-end.
- The UI shows progress and clear status.
- Permissions are understandable.
- The feature is safe by default.
- The outcome is visible (artifact, summary, or clear result screen).

---

## Where Work Usually Lives (So PRDs Are Implementable)

OpenWork has two layers:

- **UI (SolidJS)** — screens, state, and rendering.
  - Primary directory: `apps/openwork/src/`
- **Backend (Tauri / Rust)** — OS-native actions and spawning the engine.
  - Primary directory: `apps/openwork/src-tauri/`

Typical rule:

- If it’s “show it”, “choose it”, “confirm it”, it’s UI.
- If it’s “touch the OS” (files, dialogs, processes), it’s Tauri.

---

## A Note on “No Code” PRDs

PRDs in this folder intentionally describe:

- what the user experiences
- how we would implement it

…but they do not add production code.

Implementation details should reference the real code structure (files and APIs) so a contributor can start immediately.
