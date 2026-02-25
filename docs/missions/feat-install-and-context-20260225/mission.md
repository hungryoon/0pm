# Mission: Plugin Install & Cross-Command Context

> **Mission ID:** `feat-install-and-context-20260225`
> **Status:** completed
> **Created:** 2026-02-25

## Checkpoints

1. As a developer, I can install 0pm into my existing project with a single command
2. As a developer, the install process sets up commands, templates, scripts, and hooks without manual file copying
3. As a developer, when I start a new session, the hook tells me exactly which mission/task I left off at (not just counts)
4. As a developer, `/0pm-dev` automatically picks up the active mission without me re-specifying it
5. As a developer, I can check mission status at any point mid-session, not only at session start

## Background

0pm has completed its bootstrap phase — 4 commands (`sync`, `plan`, `dev`, `ship`), templates, hooks, and self-documentation are all in place. However, two critical gaps remain:

- **No install path**: 0pm is designed as a reusable plugin for any project, but there's no way to actually install it into a target project. A developer would need to manually copy files across multiple directories.
- **Weak context continuity**: Each command runs in isolation. When a session ends and restarts, the developer loses context about which mission/task was active. The session hook only shows summary counts, not actionable state.

## AS-IS (Current State)

### Installation
- No install mechanism exists
- To use 0pm in another project, a developer would need to manually copy:
  - `.claude/commands/0pm-*.md` (4 files)
  - `templates/` (2 files)
  - `scripts/session-start.sh` (1 file)
  - Merge into `.claude/settings.json` (hooks)
- No version tracking or update path

### Context Continuity
- `session-start.sh` outputs mission name + `done/total tasks done` count
- No indication of which specific task is next
- No mission status filtering (completed missions still show)
- `/0pm-dev` requires manual mission selection every time
- No mid-session status check capability
- No persistent state file tracking active mission/task

## TO-BE (Target State)

### Installation
- A single `scripts/install.sh` that copies 0pm into any target project
- Handles: commands, templates, scripts, hooks (merge into existing settings.json)
- Idempotent — safe to re-run for updates
- Version tracking via `0pm.config.yaml` version field

### Context Continuity
- `session-start.sh` outputs:
  - Active mission name + ID
  - Current task (first incomplete task) with description
  - Progress bar or clear fraction (e.g., "Task 3/7: Implement API endpoint")
  - Filters out completed missions
- Persistent state file (`.0pm-state.json`) tracks:
  - Current active mission ID
  - Last worked-on task number
- `/0pm-dev` reads state file to auto-select mission
- All commands update state file on meaningful transitions

## Impact

- **Scope:** `scripts/`, `.claude/commands/`, `session-start.sh`, new files (`install.sh`, `.0pm-state.json`)
- **Risk:** Low — additive changes, no breaking modifications to existing commands
- **Complexity:** Medium — install script needs careful file handling; state file needs all commands to participate
