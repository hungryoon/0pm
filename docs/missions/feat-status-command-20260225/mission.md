# Mission: Add Status Command

> **Mission ID:** `feat-status-command-20260225`
> **Status:** completed
> **Created:** 2026-02-25

## Checkpoints

1. As a user, I can run `/0pm:0status` to see the active mission's task progress at a glance
2. As a user, I can see the next pending task and a suggested command to continue work
3. The status command works independently from the session-start hook

## Background

Currently, mission progress information is only surfaced passively through the SessionStart hook. There is no way to explicitly query mission status mid-session. When switching context or returning to work, users need a quick way to check where they left off without restarting the session.

## AS-IS (Current State)

- `scripts/session-start.sh` displays mission progress at session start only
- `scripts/state.sh` provides helpers: `get_active_mission`, `get_current_task`, `set_active_mission`, `clear_state`
- `.0pm-state.json` tracks active mission ID
- No on-demand status command exists; the only way to see progress is to start a new session or manually read `tasks.md`

## TO-BE (Target State)

- New `/0pm:0status` command shows active mission name, task completion rate (e.g., "3/7 done"), next pending task title, and suggested next command
- Reuses existing state helpers and task-parsing logic from `session-start.sh`
- Respects `language.display` setting for localized output
- Works at any point during a session — not tied to session lifecycle

## Impact

- **Scope:** New command file `commands/0status.md`, documentation updates
- **Risk:** Low — additive feature, no changes to existing commands or hooks
- **Complexity:** Low
