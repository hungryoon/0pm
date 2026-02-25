# Tasks: Plugin Install & Cross-Command Context

> **Mission ID:** `feat-install-and-context-20260225`
> **Mission:** [mission.md](./mission.md)

## Task List

### Task 1: Create install script

- **Status:** [x] done
- **Files:** `scripts/install.sh`
- **Description:** Create a bash script that installs 0pm into a target project directory. The script should:
  - Accept target directory as argument (default: current directory)
  - Copy `.claude/commands/0pm-*.md` to target's `.claude/commands/`
  - Copy `templates/` directory
  - Copy `scripts/session-start.sh`
  - Merge SessionStart hook into target's `.claude/settings.json` (create if missing, preserve existing hooks)
  - Write `0pm.config.yaml` with version field (or skip if already exists)
  - Be idempotent — safe to re-run for updates
  - Print summary of installed/updated files
- **Test:** Run `bash scripts/install.sh /tmp/test-project` and verify all files are copied correctly, settings.json is properly merged

### Task 2: Create state file schema and read/write helpers

- **Status:** [x] done
- **Files:** `scripts/state.sh`
- **Description:** Create a bash helper script for `.0pm-state.json` operations:
  - `get_active_mission` — returns current mission ID (or empty)
  - `set_active_mission <mission-id>` — sets active mission
  - `get_current_task <mission-id>` — returns first incomplete task number
  - `clear_state` — clears active mission (for ship/completion)
  - JSON format: `{"active_mission": "feat-xxx", "updated_at": "2026-02-25T12:00:00"}`
  - Use only standard tools (no python dependency)
- **Test:** Source the script and verify each function reads/writes `.0pm-state.json` correctly

### Task 3: Enhance session-start hook with rich context

- **Status:** [x] done
- **Files:** `scripts/session-start.sh`
- **Description:** Upgrade the session start hook to provide actionable context:
  - Read `.0pm-state.json` for active mission
  - Show active mission name + progress (e.g., "3/7 tasks done")
  - Show next task title and description (first `[ ]` task)
  - Filter out completed missions (Status: completed in mission.md)
  - Remove `python3` dependency for JSON escaping (use printf or heredoc)
  - Suggest next action (e.g., "Run `/0pm-dev` to continue" or "Run `/0pm-ship` — all tasks complete")
- **Test:** Create a mock mission with mixed done/pending tasks, verify hook output shows correct next task and progress

### Task 4: Update `/0pm-plan` to set active mission state

- **Status:** [x] done
- **Files:** `.claude/commands/0pm-plan.md`
- **Description:** After mission+tasks are created in Step 6 (Report), the plan command should also:
  - Call state helper to set the new mission as active (`set_active_mission`)
  - Output includes: "Active mission set to `{mission-id}`. Run `/0pm-dev` to start."
  - Add instruction to source `scripts/state.sh` and call `set_active_mission`
- **Test:** Run `/0pm-plan`, verify `.0pm-state.json` contains the new mission ID

### Task 5: Update `/0pm-dev` to auto-select active mission

- **Status:** [x] done
- **Files:** `.claude/commands/0pm-dev.md`
- **Description:** Modify Step 1 (Select Mission) to:
  - First check `.0pm-state.json` for active mission
  - If found and mission dir exists, auto-select it (no user prompt needed)
  - If not found, fall back to current behavior (list missions, ask user)
  - Add Language Setting section (currently missing, unlike plan and sync)
  - On task completion, update state file with progress
- **Test:** Set active mission in state file, run `/0pm-dev`, verify it auto-selects without prompting

### Task 6: Update `/0pm-ship` to clear state on completion

- **Status:** [x] done
- **Files:** `.claude/commands/0pm-ship.md`
- **Description:** After Step 5 (Final Cleanup), the ship command should:
  - Clear active mission from state file (`clear_state`)
  - If other pending missions exist, suggest setting one as active
  - Add `.0pm-state.json` to `.gitignore` (it's local working state, not shared)
- **Test:** Complete a ship flow, verify `.0pm-state.json` is cleared and `.gitignore` is updated

### Task 7: Add `.0pm-state.json` to `.gitignore`

- **Status:** [x] done
- **Files:** `.gitignore`
- **Description:** Add `.0pm-state.json` to `.gitignore` since it's local session state, not meant to be committed. Also add to the install script's `.gitignore` update logic.
- **Test:** Verify `git status` doesn't show `.0pm-state.json` after state operations

### Task 8: Update documentation

- **Status:** [x] done
- **Files:** `docs/services/0pm/overview.md`, `docs/domains/glossary.md`
- **Description:** Update service docs and glossary to reflect new components:
  - Overview: Add install script to Components table, add State File section
  - Glossary: Add "State file" and "Install" terms
  - Overview: Update Hooks section with new session-start behavior
- **Test:** Run `/0pm-sync` to verify no mismatches remain
