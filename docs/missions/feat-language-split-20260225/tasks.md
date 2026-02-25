# Tasks: Split Display & Document Language Settings

> **Mission ID:** `feat-language-split-20260225`
> **Mission:** [mission.md](./mission.md)

## Task List

### Task 1: Update config format and actual config

- **Status:** [x] done
- **Files:** `0pm.config.yaml`
- **Description:** Change `language` from string to object:
  ```yaml
  language:
    display: ko
    document: en
  ```
- **Test:** Verify `0pm.config.yaml` parses correctly with `yq` or manual inspection

### Task 2: Update `/0pm-sync` command

- **Status:** [x] done
- **Files:** `.claude/commands/0pm-sync.md`
- **Description:** Update Language Setting section to:
  - Read `language.display` for conversation output (explanations, reports, prompts)
  - Read `language.document` for generated documents (service docs, glossary, etc.)
  - Update both Init mode and Sync mode instructions
- **Test:** Read the command and verify both language fields are referenced with clear distinction

### Task 3: Update `/0pm-plan` command

- **Status:** [x] done
- **Files:** `.claude/commands/0pm-plan.md`
- **Description:** Update Language Setting section to:
  - Read `language.display` for conversation (checkpoint discussion, confirmations, reports)
  - Read `language.document` for generated documents (mission.md, tasks.md)
- **Test:** Read the command and verify both language fields are referenced with clear distinction

### Task 4: Update `/0pm-dev` command

- **Status:** [x] done
- **Files:** `.claude/commands/0pm-dev.md`
- **Description:** Update Language Setting section to:
  - Read `language.display` for conversation (progress reports, TDD guidance, review feedback)
  - Read `language.document` for task status updates in tasks.md
- **Test:** Read the command and verify both language fields are referenced with clear distinction

### Task 5: Update `/0pm-ship` command

- **Status:** [x] done
- **Files:** `.claude/commands/0pm-ship.md`
- **Description:** Add Language Setting section (currently missing) to:
  - Read `language.display` for conversation (verification reports, cleanup guidance)
  - Read `language.document` for doc updates
- **Test:** Read the command and verify Language Setting section exists with both fields

### Task 6: Update session-start hook

- **Status:** [x] done
- **Files:** `scripts/session-start.sh`
- **Description:** Read `language.display` from `0pm.config.yaml` and localize output messages:
  - Parse YAML to extract `language.display` value
  - Provide Korean/English message variants (at minimum)
  - Fallback to English if language not recognized
- **Test:** Set `language.display: ko` in config, run `bash scripts/session-start.sh`, verify Korean output

### Task 7: Update documentation

- **Status:** [x] done
- **Files:** `docs/services/0pm/overview.md`, `CLAUDE.md`, `docs/domains/glossary.md`
- **Description:** Update all docs to reflect the new dual-language config:
  - `overview.md`: Update Config Schema section (`language` string → object)
  - `CLAUDE.md`: Update convention about documentation language
  - `glossary.md`: Add "Display language" / "Document language" terms if needed
- **Test:** Run `/0pm-sync` to verify no mismatches
