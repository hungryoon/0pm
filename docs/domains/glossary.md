# 0pm Domain Glossary

## Core Concepts

| Term | Description |
|---|---|
| **Base** | The `docs/` directory. Single source of truth for all project documentation. |
| **Checkpoint** | User stories or business goals provided by management/PM. Input to the planning phase. |
| **Mission** | Technical planning document converted from checkpoints. Contains background, AS-IS/TO-BE analysis, and impact assessment. |
| **Task** | Concrete development item derived from a mission. Includes affected files, description, and test criteria. |
| **Mission ID** | Unique identifier for a mission. Used as branch name, worktree directory name, and docs path. Format: `{type}-{description}-{date}`. |
| **Sync** | Code↔document consistency check and synchronization. Detects missing, stale, orphan, and mismatched documentation. |

## Workflow Terms

| Term | Description |
|---|---|
| **Init mode** | First-run behavior of `/0pm:0sync`. Analyzes codebase and scaffolds the 0pm structure. |
| **Sync mode** | Subsequent-run behavior of `/0pm:0sync`. Compares code vs docs and reports mismatches. |
| **TDD loop** | Red → Green → Refactor → Review → Mark → Commit cycle used in `/0pm:0dev`. |
| **Worktree** | Git worktree created per mission for isolated development. Stored in `workspaces/{mission-id}/`. |
| **State file** | `.0pm-state.json` — tracks active mission ID across sessions. Local only (gitignored). |
| **Init** | `/0pm:0sync` first-run mode — scaffolds project directory structure (config, templates, docs, .gitignore). |
| **Display language** | `language.display` in config — the language Claude uses for conversation output. |
| **Document language** | `language.document` in config — the language used for generated documents (missions, tasks, docs). |

## Mismatch Types (Sync Report)

| Tag | Meaning |
|---|---|
| `[MISSING_DOC]` | Code exists but documentation is missing |
| `[STALE_DOC]` | Documentation is outdated (code has changed) |
| `[ORPHAN_DOC]` | Documentation exists but code was deleted |
| `[MISMATCH]` | Documentation and code disagree |
