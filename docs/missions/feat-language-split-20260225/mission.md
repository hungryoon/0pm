# Mission: Split Display & Document Language Settings

> **Mission ID:** `feat-language-split-20260225`
> **Status:** completed
> **Created:** 2026-02-25

## Checkpoints

1. As a developer, I can configure display language and document language separately in `0pm.config.yaml`
2. As a developer, all commands (sync, plan, dev, ship) speak to me in the display language
3. As a developer, generated documents (mission.md, tasks.md, etc.) are written in the document language
4. As a developer, the session-start hook also outputs in the display language

## Background

0pm currently has a single `language` field (string) in `0pm.config.yaml` that controls both conversational output and document generation. In practice, developers often prefer to interact in their native language (e.g., Korean) while keeping technical documentation in English for broader accessibility. A single setting forces an all-or-nothing choice.

## AS-IS (Current State)

### Config
- `0pm.config.yaml` has `language: en` — a single string value
- Used identically for all output: conversation and documents

### Commands
- All 4 commands (sync, plan, dev, ship) have a "Language Setting" section
- Each reads `0pm.config.yaml` → `language` field
- Instruction: "Write all generated/updated documents in that language"
- No distinction between conversation language and document language

### Session Hook
- `scripts/session-start.sh` outputs in hardcoded English
- No language awareness from config

### Documentation
- `docs/services/0pm/overview.md` Config Schema shows `language: en  # Document language (en, ko, etc.)`
- `CLAUDE.md` says "Write documentation in the language specified by `language` in `0pm.config.yaml`"

## TO-BE (Target State)

### Config
- `0pm.config.yaml` changes from string to object:
  ```yaml
  language:
    display: ko    # Language for Claude's conversation output
    document: en   # Language for generated documents
  ```

### Commands
- All 4 commands read both `language.display` and `language.document`
- Conversation/explanations use `display` language
- Document generation (mission.md, tasks.md, glossary, etc.) uses `document` language
- Language Setting section updated in each command

### Session Hook
- `scripts/session-start.sh` reads `language.display` from config
- Output messages localized to display language

### Documentation
- `docs/services/0pm/overview.md` Config Schema updated
- `CLAUDE.md` updated to reflect dual-language setting
- `docs/domains/glossary.md` updated if needed

## Impact

- **Scope:** `0pm.config.yaml`, `.claude/commands/0pm-*.md` (4 files), `scripts/session-start.sh`, `docs/services/0pm/overview.md`, `CLAUDE.md`
- **Risk:** Low — config format change is breaking but no backward compat needed per user decision
- **Complexity:** Low — mostly updating instructions in command files + config parsing in session hook
