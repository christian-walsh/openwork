# PRD-008 — Provenance + Prompt-Injection Guardrails (Trustworthy Web Use)

## One-line Summary

When a task uses the web or untrusted text, OpenWork should label where information came from and require extra confirmation for risky actions.

## Status (Today)

Not implemented as a product feature.

- OpenWork hides model reasoning by default.
- OpenWork redacts sensitive keys from tool payloads.

Missing:

- Clear provenance labels (“from the web”, “from your files”).
- Guardrails that reduce the chance that untrusted content can steer actions.

---

## Problem (In Plain English)

If a task reads something from the internet, that content can be wrong—or even malicious.

A normal user cannot be expected to detect “prompt injection” attempts.

So the product must:

- make sources visible
- limit what untrusted content can cause
- ask before risky actions

---

## Goals

- Make provenance visible: where did this come from?
- Treat web content as “untrusted” by default.
- Add guardrails around high-risk actions.

## Non-Goals

- Claiming perfect security.
- Blocking all web usage.

---

## User Experience (What You’ll See)

1. When a task uses the web, you see a **Web** badge in the task header.
2. When the task makes a claim based on web content, it shows:
   - the source site
   - a short excerpt it relied on
3. If web content appears to contain instructions (“run this command”, “ignore your rules”):
   - OpenWork flags it as untrusted
   - OpenWork does not treat it as instructions
4. If the task wants to do something risky next:
   - OpenWork asks for confirmation and explains why

---

## Requirements

### Must Have

- Provenance labels on:
  - web-derived content
  - local file-derived content
  - tool outputs
- A clear “untrusted web content” treatment:
  - collapsed by default
  - visually distinct
- High-risk confirmation gates for:
  - deleting files
  - running install commands
  - writing outside shared folders
  - enabling broad web access

### Should Have

- Domain allowlist UI (ties to PRD-006).
- “Show evidence” pattern:
  - link + excerpt required when web is used for a key decision

### Nice to Have

- Heuristic injection warnings (signals, not guarantees).

---

## Safety, Permissions, and Trust

- OpenWork should never say “trust me”.
- It should say:
  - “This came from the web”
  - “I’m about to do something risky”
  - “Here is what will change”

---

## Success Metrics

- Users feel comfortable enabling web connectors.
- Fewer “surprise” actions after web steps.

---

## Build Notes (For Contributors)

### Suggested Implementation Approach

- Add provenance metadata into the UI model:
  - classify steps/tool calls as “local”, “web”, “system” where possible
- Add a UI policy layer:
  - if last major input is “web/untrusted”, require extra confirmation for risky actions

### Files Likely Touched

- `apps/openwork/src/App.tsx`
  - show web badges
  - implement “risky action” confirmations
- `apps/openwork/src/components/PartView.tsx`
  - render provenance labels

### Open Questions

- What signal(s) in OpenCode events indicate that a step used the web?
- Can we require evidence excerpts without degrading usability?
