# Tasks: Add 0-Prefix to Command Names

> **Mission ID:** `refactor-command-prefix-20260225`
> **Mission:** [mission.md](./mission.md)

## Task List

### Task 1: Rename command files and update frontmatter

- **Status:** [x] done
- **Files:** `commands/plan.md`, `commands/dev.md`, `commands/ship.md`, `commands/sync.md`
- **Description:** Rename each file to `0plan.md`, `0dev.md`, `0ship.md`, `0sync.md`. Update the `name:` field in each file's YAML frontmatter to match (e.g., `name: 0plan`).
- **Test:** `/0pm:0plan`, `/0pm:0dev`, `/0pm:0ship`, `/0pm:0sync` appear in command list; old names do not.

### Task 2: Update cross-references within commands

- **Status:** [x] done
- **Files:** `commands/0plan.md`, `commands/0dev.md`, `commands/0ship.md`, `commands/0sync.md`
- **Description:** Update all `/0pm:plan` → `/0pm:0plan`, `/0pm:dev` → `/0pm:0dev`, `/0pm:ship` → `/0pm:0ship`, `/0pm:sync` → `/0pm:0sync` references inside command files.
- **Test:** `grep -r '/0pm:plan\|/0pm:dev\|/0pm:ship\|/0pm:sync' commands/` returns no results.

### Task 3: Update project documentation

- **Status:** [x] done
- **Files:** `CLAUDE.md`, `README.md`, `README.ko.md`, `docs/services/0pm/overview.md`, `docs/domains/glossary.md`
- **Description:** Replace all old command references with new 0-prefixed names across documentation files.
- **Test:** `grep -r '/0pm:plan\|/0pm:dev\|/0pm:ship\|/0pm:sync' CLAUDE.md README.md README.ko.md docs/services/ docs/domains/` returns no results.

### Task 4: Update session-start script

- **Status:** [x] done
- **Files:** `scripts/session-start.sh`
- **Description:** Replace all command references in both Korean and English output strings.
- **Test:** `grep '/0pm:plan\|/0pm:dev\|/0pm:ship\|/0pm:sync' scripts/session-start.sh` returns no results.
