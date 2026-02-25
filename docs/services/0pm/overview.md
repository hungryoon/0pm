# 0pm Plugin Service

## Overview

0pm is a Claude Code plugin distributed via the plugin marketplace.
It enables engineers to lead planning, development, and deployment without a PM.

## Architecture

- **Type:** Claude Code Plugin (slash commands + hooks)
- **Language:** Markdown (prompts) + Bash (scripts)
- **Commands:** 5 (`0sync`, `0plan`, `0dev`, `0ship`, `0status`)

## Components

| Component | Path | Description |
|---|---|---|
| Plugin manifest | `.claude-plugin/plugin.json` | Plugin metadata and registration |
| Marketplace | `.claude-plugin/marketplace.json` | Marketplace listing for distribution |
| Commands | `commands/*.md` | Slash commands (`/0pm:0sync`, `/0pm:0plan`, `/0pm:0dev`, `/0pm:0ship`, `/0pm:0status`) |
| Hooks | `hooks/hooks.json` | SessionStart hook configuration |
| Templates | `templates/` | Document generation templates |
| Scripts | `scripts/` | Automation scripts |
| Session hook | `scripts/session-start.sh` | Mission progress context at session start |
| State helpers | `scripts/state.sh` | Cross-command context persistence |
| Worktree helpers | `scripts/worktree.sh` | Multi-repo worktree create/cleanup |
| Config | `0pm.config.yaml` | Project configuration |
| State file | `.0pm-state.json` | Active mission tracking (local, gitignored) |
| Context | `CLAUDE.md` | Project context for Claude |

## Commands

| Command | Description |
|---|---|
| `/0pm:0sync` | Initialize project structure OR synchronize code↔docs (auto-detects) |
| `/0pm:0plan` | Checkpoints → mission → tasks |
| `/0pm:0dev` | TDD development + code review |
| `/0pm:0ship` | Deploy verification + doc updates |
| `/0pm:0status` | Show active mission progress and next task |

## Config Schema (`0pm.config.yaml`)

```yaml
version: "0.1.0"          # 0pm version
language:
  display: ko              # Language for Claude's conversation output
  document: en             # Language for generated documents

repos:                     # Managed repositories
  - name: string           # Repo identifier
    path: string           # Relative path to repo
    type: string           # Framework type (nestjs, nextjs, fastapi, etc.)
    description: string    # Short description

docs:
  path: ./docs             # Base documentation directory

worktree:
  base_dir: ./workspaces   # Worktree root directory
  auto_create: true        # Auto-create worktrees on /0pm:0dev
  auto_cleanup: true       # Auto-remove worktrees on /0pm:0ship
  branch_prefix: "feat-"   # Branch name prefix for missions
```

## Templates

| Template | Path | Purpose |
|---|---|---|
| Mission | `templates/mission.md` | Mission document structure (checkpoints, AS-IS/TO-BE, impact) |
| Tasks | `templates/tasks.md` | Task list structure (status, files, description, test) |

## Hooks

### SessionStart

Runs `scripts/session-start.sh` at session start to inject mission status into Claude context.

**Behavior:**
- If `0pm.config.yaml` missing → prompts user to run `/0pm:0sync`
- Reads `language.display` from config to localize output messages
- If active missions exist → shows progress, next task title, and suggested next command
- Filters out completed missions (Status: completed)
- If all tasks done → suggests `/0pm:0ship`
- If tasks remain → suggests `/0pm:0dev`
- If no missions → suggests running `/0pm:0plan`

## State File (`.0pm-state.json`)

Tracks the active mission across sessions. Managed by `scripts/state.sh`.

```json
{
  "active_mission": "feat-install-and-context-20260225",
  "updated_at": "2026-02-25T12:00:00"
}
```

- Set by `/0pm:0plan` when creating a new mission
- Read by `/0pm:0dev` for auto-selecting the active mission
- Cleared by `/0pm:0ship` on mission completion
- Gitignored — local working state, not committed

## Installation

```bash
mkdir my-project-0pm && cd my-project-0pm && git init
git clone https://github.com/org/api-server repos/api-server

/plugin marketplace add hungryoon/0pm
/plugin install 0pm@hungryoon-0pm

/0pm:0sync   # first run scaffolds config, docs, templates, .gitignore
```
