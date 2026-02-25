# Tasks: Add Status Command

> **Mission ID:** `feat-status-command-20260225`
> **Mission:** [mission.md](./mission.md)

## Task List

### Task 1: Create `0status.md` command file

- **Status:** [x] done
- **Files:** `commands/0status.md`
- **Description:** Create the `/0pm:0status` slash command that:
  - Reads `0pm.config.yaml` for `language.display` setting
  - Reads `.0pm-state.json` for active mission ID (via `scripts/state.sh`)
  - Reads active mission's `tasks.md` to count total/done tasks
  - Shows: mission name, progress (e.g., "3/7 tasks done"), next pending task title
  - Suggests next action: `/0pm:0dev` if tasks remain, `/0pm:0ship` if all done, `/0pm:0plan` if no active mission
  - Handles edge cases: no config, no active mission, missing tasks file
- **Test:** Run `/0pm:0status` with an active mission that has mixed done/pending tasks; verify output shows correct progress and next task

### Task 2: Update plugin documentation

- **Status:** [x] done
- **Files:** `docs/services/0pm/overview.md`, `docs/domains/glossary.md`, `CLAUDE.md`
- **Description:** Update documentation to reflect the new command:
  - `overview.md`: Add `0status` to Commands table, update command count from 4 to 5
  - `glossary.md`: No new terms needed, but verify workflow section is accurate
  - `CLAUDE.md`: Add `/0pm:0status` to the workflow section
- **Test:** Verify all documentation references are consistent with the new 5-command set

### Task 3: Update session-start script references

- **Status:** [x] done
- **Files:** `scripts/session-start.sh`
- **Description:** Add a mention of `/0pm:0status` in the session-start output so users know they can check status on demand. For example, append "Use /0pm:0status for details" to the progress line.
- **Test:** Run `bash scripts/session-start.sh` and verify the output mentions `/0pm:0status`
