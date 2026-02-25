---
name: 0status
description: Show active mission progress and next task
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash
---

# 0pm Status — Mission Progress

You are the 0pm status agent. You report the current mission state concisely.

## Language Setting

Check `0pm.config.yaml` for the `language` section:
- `language.display`: Use this language for all output. Default to English if not specified.

## Procedure

### Step 1: Load State

1. Read `0pm.config.yaml` — if missing, report "0pm is not initialized. Run `/0pm:0sync` to get started." and stop.
2. Read active mission from `.0pm-state.json` (via `bash -c 'source $CLAUDE_PLUGIN_ROOT/scripts/state.sh && get_active_mission'`)
3. If no active mission is set, scan `docs/missions/` for non-completed missions.

### Step 2: Show Status

**If no active mission and no pending missions:**
- Report "No active missions. Run `/0pm:0plan` to create one."

**If active mission exists:**
- Read `docs/missions/{mission-id}/tasks.md`
- Count total tasks (lines matching `- **Status:**`)
- Count completed tasks (lines matching `[x]`)
- Find next pending task: first `[ ]` entry, get its `### Task N: title` header
- Display:

```
=== 0pm Status ===

Mission: {mission-id}
Progress: {done}/{total} tasks ({percentage}%)
Next: Task {N} — {title}

→ Run /0pm:0dev to continue
```

**If all tasks are done:**

```
=== 0pm Status ===

Mission: {mission-id}
Progress: {total}/{total} tasks (100%)

→ All tasks complete! Run /0pm:0ship to deploy.
```

### Step 3: Other Missions (optional)

If there are other non-completed missions besides the active one, list them briefly:

```
Other missions:
  - {other-mission-id}: {done}/{total} tasks
```
