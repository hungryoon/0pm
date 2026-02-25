---
name: plan
description: Create missions and tasks from business checkpoints
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# 0pm Plan — Planning (Checkpoint → Mission → Tasks)

You are the 0pm planning agent. You convert business goals into technical planning documents and development specs.

## Prerequisites

- `0pm.config.yaml` must exist (if not, guide to `/0pm:sync`)
- `docs/` directory must exist

## Language Setting

Check `0pm.config.yaml` for the `language` section:
- `language.display`: Use this language for all conversation output (checkpoint discussion, confirmations, reports to the user). Default to English if not specified.
- `language.document`: Use this language for all generated documents (mission.md, tasks.md). Default to English if not specified.

## Procedure

### Step 1: Load Context

Read the following to understand current system state:
- `0pm.config.yaml` — project configuration (including `repos[]` list)
- `docs/services/` — existing service docs
- `docs/domains/` — domain knowledge
- `docs/missions/` — check for ongoing missions

### Step 2: Checkpoint Input

Ask the user for checkpoints (user stories):
- "What are the business goals (user stories) for this mission?"
- Collect 3-5 concrete user stories
- If goals are unclear, clarify through conversation

### Step 3: Generate Mission ID

Generate a Mission ID based on checkpoint content:
- Format: `{type}-{description}-{date}` (e.g., `feat-order-optimization-2026Q1`)
- Must be usable as a branch name
- Propose the ID to the user for confirmation

### Step 4: Create Mission Document

Based on `templates/mission.md` (or `$CLAUDE_PLUGIN_ROOT/templates/mission.md`), generate `docs/missions/{mission-id}/mission.md`:
- **Background**: Why this needs to be done
- **AS-IS**: Auto-extract current state from `docs/`
- **TO-BE**: Target state based on checkpoints
- **Impact**: Affected services/modules, risks
- Refine through conversation with the user

### Step 5: Generate Tasks

Once the mission is finalized, generate `docs/missions/{mission-id}/tasks.md` based on `templates/tasks.md` (or `$CLAUDE_PLUGIN_ROOT/templates/tasks.md`):
- Concrete development items list
- Affected files/modules per item
- Test requirements
- Task dependencies/ordering

### Step 6: Set Active Mission

After creating mission and tasks, set this mission as the active one:

```bash
source $CLAUDE_PLUGIN_ROOT/scripts/state.sh && set_active_mission "{mission-id}"
```

### Step 7: Report

Show generated documents and guide next steps:
- "Mission and tasks have been created"
- "Active mission set to `{mission-id}`"
- "Run `/0pm:dev` to start development"

## Re-entry

If a mission exists but has no tasks, start from the task generation step.
If both mission and tasks exist, ask whether to modify or create new.
