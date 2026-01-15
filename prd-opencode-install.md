# PRD — OpenCode CLI Install + Engine Bootstrap (OpenWork)

## Summary

OpenWork currently requires the `opencode` CLI to already be installed and available on the user’s PATH. This is a major onboarding cliff for non-technical users.

This PRD proposes a **first-run “Engine Setup” step** in Host-mode onboarding that:

1. Detects whether `opencode` is available (and compatible)
2. If missing, offers a **guided one-click install** (macOS/Linux) or clear manual instructions (Windows)
3. Verifies install success and then starts `opencode serve` reliably, even when PATH changes don’t propagate into GUI apps

The goal is to make “fresh install → first successful task run” achievable without opening a terminal.

## Problem

Today, Host mode fails with a generic spawn error when OpenWork can’t find `opencode`.

- Users don’t know what `PATH` means.
- Users don’t know where to install OpenCode.
- Even if we run an installer that modifies shell rc files, **GUI apps won’t automatically inherit that updated PATH** (macOS in particular).

This conflicts with OpenWork’s success metric: **< 5 minutes to first successful task on fresh install**.

## Goals

- Detect missing OpenCode engine **before** the user hits “Start”.
- Provide a safe, guided install flow with explicit consent.
- Show clear progress + logs (download, unpack, verification).
- Make the engine start reliably after install (avoid “it’s installed but OpenWork can’t find it”).
- Keep parity with OpenCode primitives: still run `opencode serve`.

## Non-goals

- Bundling `opencode` into OpenWork releases (possible future work).
- Implementing an auto-updater for `opencode` (future).
- Supporting fully offline installs (we can provide guidance, but not guarantee).

## Current Architecture (Constraints)

- Engine lifecycle lives in the Tauri backend (`src-tauri/src/lib.rs`), started via `Command::new("opencode")` and `opencode serve …`.
- Current engine start discards `stdout`/`stderr` (`Stdio::null()`), so users get poor diagnostics when spawning fails.
- UI connects using `@opencode-ai/sdk/v2/client` and assumes a working `baseUrl`.
- The Tauri app is a GUI process; shell rc changes won’t necessarily affect it (especially macOS).

## Key Insight: GUI PATH Is Not Trustworthy

Even if an installer appends `~/.opencode/bin` to `.zshrc`, OpenWork (a GUI app) may still not see it until the user reboots or re-logs in. Therefore OpenWork must:

- Discover `opencode` via deterministic path probing.
- Prefer starting the engine via an absolute path (resolved by discovery).
- Avoid depending on “restart your terminal” advice for core onboarding.

## Proposed UX

### Where this lives

Host onboarding adds a step after folder selection:

- **Engine Setup**
  - Status: Checking… / Missing / Installing… / Installed
  - Primary action: Install OpenCode (if missing)
  - Secondary: View manual install instructions
  - Tertiary: “I already installed it” → re-check

### Flow A — `opencode` already available

1. Engine Setup runs a check.
2. If `opencode` is found and compatible:
   - Show “OpenCode found: vX.Y.Z”
   - Continue onboarding.

### Flow B — `opencode` missing

1. Engine Setup detects `opencode` cannot be executed.
2. Show:
   - Explanation: “OpenWork needs OpenCode installed to run tasks locally.”
   - What it will do: “Download and install the OpenCode CLI to your user directory.”
   - A clear consent affordance.

**Buttons**
- Primary: **Install OpenCode**
- Secondary: Manual install
- Secondary: Retry check

### Flow C — Guided install succeeds

1. OpenWork runs the installer.
2. UI streams installer output in a collapsible log drawer.
3. After completion:
   - OpenWork re-checks the engine.
   - If found, enables **Start Engine**.

### Flow D — Guided install fails

1. UI shows “Install failed” with:
   - short reason (first stderr line)
   - “Copy logs”
   - “Manual install” instructions
   - “Retry”

### Flow E — Installed but not on PATH

This is common if installation adds `~/.opencode/bin` to shell rc files.

OpenWork should:

- Search known install locations (see “Engine discovery”) and use an **absolute path** to run `opencode`.
- If found outside PATH, show:
  - “OpenCode installed at `~/.opencode/bin/opencode`”
  - Optional action: “Add to PATH” (manual instructions; don’t silently edit dotfiles).

## Proposed Technical Approach (No Implementation Yet)

### 1) Engine discovery (“doctor”)

Add a Tauri command to check engine availability and return structured info:

- `inPath`: boolean
- `resolvedPath`: string | null
- `version`: string | null
- `supportsServe`: boolean
- `notes`: string[]

**Discovery order**

1. Try `opencode --version` (PATH)
2. Try known paths:
   - `~/.opencode/bin/opencode` (matches upstream install script)
   - `/opt/homebrew/bin/opencode` (Homebrew Apple Silicon)
   - `/usr/local/bin/opencode` (Homebrew Intel)
   - Linux common paths (`/usr/bin/opencode`, `/usr/local/bin/opencode`)
   - Windows common paths (TBD)

3. If `opencode` is found, validate `serve` support:
   - `opencode serve --help` (exit code 0)

### 2) Guided install

**Recommended approach (macOS/Linux):** run the upstream install script with explicit consent.

Candidate URLs:

- `https://opencode.ai/install` (if this is the canonical stable redirect)
- `https://raw.githubusercontent.com/opencode-ai/opencode/refs/heads/main/install` (as documented upstream)

Execution strategy (conceptual):

- Run via `bash -lc "curl -fsSL <url> | bash"`
- Capture stdout/stderr and stream to the UI
- Allow choosing a pinned version (advanced): `VERSION=x.y.z`

**Important:** the install script currently writes to `~/.opencode/bin` and may edit shell rc files to add PATH. OpenWork must not rely on that PATH change.

#### Installer implementation options

- **Option A (v0 / fastest): run the upstream script**
  - Pros: minimal code, matches upstream.
  - Cons: remote script execution; PATH edits don’t help the GUI; harder to reason about.
  - Mitigations required: show the exact command, allow “View script”, stream logs, require explicit consent.

- **Option B (recommended medium-term): native installer in Rust**
  - Download the correct release tarball from GitHub Releases (same URL pattern the script uses).
  - Extract the `opencode` binary and place it in `~/.opencode/bin/opencode` (or an OpenWork-managed directory).
  - Never edit shell rc files; always start via absolute path.
  - Pros: safer, deterministic, works in GUI context, easier to debug.
  - Cons: more code, need per-OS archive handling.

OpenWork can start with Option A behind a clear consent UI, then migrate to Option B once we’re confident in the release asset layout.

#### Cancellation + retry

- The install step should be cancellable.
- Retries should re-run discovery first to avoid redundant downloads.

**Windows:** do not attempt `curl | bash`.

Options:

- Manual instructions only (v0)
- Or a native PowerShell installer (future) that downloads a release asset and stores it under `%LOCALAPPDATA%\\OpenCode\\bin` and uses that absolute path

### 3) Engine start should accept a resolved path

Instead of always `Command::new("opencode")`, engine start should prefer a resolved path from discovery.

This avoids the “installed but not on PATH” trap and improves reliability on macOS.

### 4) Permissions + Safety

Running an installer is sensitive.

Requirements:

- No silent remote code execution.
- Show the exact command that will run.
- Provide a “View script” action (fetch and display) before install.
- Clear opt-out path (manual install instructions).

### 5) Telemetry / Diagnostics (Optional)

Local-only diagnostics artifact:

- engine discovery result
- installer logs
- final engine start result

Exportable by the user to include in bug reports.

### 6) Tauri command surface (draft)

To keep the UI thin and deterministic, add a minimal command surface:

- `engine_doctor() -> EngineDoctorResult`
  - Runs discovery and compatibility checks.
- `engine_install(options) -> ExecResult`
  - Performs guided install (Option A or B).
  - Streams progress via a Tauri event (e.g. `engine_install_log`) so the UI can show live logs.
- `engine_start(projectDir, opencodePath?) -> EngineInfo`
  - Starts the engine using `opencodePath` when provided (absolute path).

Where `EngineDoctorResult` includes:

- `found`: boolean
- `inPath`: boolean
- `resolvedPath`: string | null
- `version`: string | null
- `recommendedStartPath`: string | null
- `errors`: string[]
- `warnings`: string[]

## Manual install instructions (UI copy)

OpenWork should show OS-specific instructions with copy buttons.

Example:

- macOS (Homebrew): `brew install opencode-ai/tap/opencode`
- macOS/Linux (script): `curl -fsSL https://opencode.ai/install | bash`
- Linux (script fallback): `curl -fsSL https://raw.githubusercontent.com/opencode-ai/opencode/refs/heads/main/install | bash`

## Acceptance Criteria

- Fresh machine with OpenWork installed but no `opencode`:
  - User can complete guided install (macOS/Linux) without terminal.
  - OpenWork verifies engine availability and can start Host mode.
- If guided install fails:
  - User sees a clear error, can copy logs, and sees manual instructions.
- If `opencode` is installed outside PATH:
  - OpenWork still finds and runs it via absolute path.

## Rollout Plan

- Phase 0: engine discovery + manual instructions (no auto install).
- Phase 1: guided install Option A on macOS/Linux with explicit consent + log streaming.
- Phase 2: migrate to native installer Option B for safety + determinism.
- Phase 3: Windows installer (PowerShell/winget) or a deliberate “manual only” stance.

## Open Questions

- What is the minimum supported OpenCode server version for this OpenWork release?
- Is `https://opencode.ai/install` the canonical stable installer URL we want to bless?
- For Windows, do we want a v0 “manual only” stance, or a PowerShell installer?
- Should OpenWork ever modify shell rc files, or only provide instructions?
