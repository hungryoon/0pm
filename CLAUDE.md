# 0pm — Claude Code Plugin

> Zero PM. Engineers own everything from planning to deployment.

## Project Overview

0pm is a Claude Code plugin that enables engineers to lead planning, development, and deployment without a PM, on top of existing codebases.

## Directory Structure

```
{project}-0pm/
├── .claude-plugin/       # Plugin manifest & marketplace
├── commands/             # Slash commands (plugin code)
├── hooks/                # Hook configurations
├── docs/                 # Base — single source of truth
│   ├── domains/          # Domain descriptions
│   ├── services/         # Per-service structure docs
│   └── missions/         # Per-mission plans + tasks
├── repos/                # Code repos (.gitignore)
├── workspaces/           # Per-mission worktrees (.gitignore)
├── templates/            # Document templates
├── scripts/              # Automation scripts
└── 0pm.config.yaml       # Project config
```

## Core Terminology

| Term | Description |
|---|---|
| **Base** | The docs/ directory. Single source of truth for all documentation |
| **Checkpoint** | User stories from management/PM (business goals) |
| **Mission** | Technical planning document converted from checkpoints |
| **Task** | Concrete development items derived from a mission |
| **Mission ID** | Unique mission identifier (used as branch/directory name) |
| **Sync** | Code-document consistency check and synchronization |

## Workflow

```
/0pm:0plan → /0pm:0dev → /0pm:0ship
/0pm:0sync (init + ad-hoc sync)
/0pm:0status (check progress anytime)
```

1. **sync**: Initialize project structure OR synchronize code↔docs (auto-detects mode)
2. **plan**: Input checkpoints → create mission → generate tasks
3. **dev**: Task-based TDD development + code review
4. **ship**: Pre-deploy verification + doc updates
5. **status**: Show active mission progress and next task

## Conventions

- Follow TDD (Red-Green-Refactor)
- Commit small and often
- Keep docs/ always up to date
- Isolate work per mission using worktrees
- Use `language.display` in `0pm.config.yaml` for conversation output, `language.document` for generated documents
