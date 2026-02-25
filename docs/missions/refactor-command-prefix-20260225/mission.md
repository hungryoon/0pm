# Mission: Add 0-Prefix to Command Names

> **Mission ID:** `refactor-command-prefix-20260225`
> **Status:** completed
> **Created:** 2026-02-25

## Checkpoints

1. As a developer, I can type `/0` and immediately filter to only 0pm commands, distinguishing them from other plugins' `plan`, `sync`, etc.

## Background

0pm's command names (`plan`, `dev`, `ship`, `sync`) are generic and collide with other plugins and built-in commands in the Claude Code command list. When a developer types `/plan`, they see multiple results from different sources (built-in, superpowers, claude-mem, 0pm). Adding a `0` prefix to each command name makes them instantly findable by typing `/0`.

## AS-IS (Current State)

### Commands
- `commands/plan.md` → `/0pm:plan`
- `commands/dev.md` → `/0pm:dev`
- `commands/ship.md` → `/0pm:ship`
- `commands/sync.md` → `/0pm:sync`

### References
10 active files reference these command names:
- `CLAUDE.md` — workflow description
- `README.md`, `README.ko.md` — usage instructions
- `commands/*.md` — cross-references between commands
- `docs/services/0pm/overview.md` — service documentation
- `docs/domains/glossary.md` — term definitions
- `scripts/session-start.sh` — session hook output messages

## TO-BE (Target State)

### Commands
- `commands/0plan.md` → `/0pm:0plan`
- `commands/0dev.md` → `/0pm:0dev`
- `commands/0ship.md` → `/0pm:0ship`
- `commands/0sync.md` → `/0pm:0sync`

### References
All 10 active files updated to use new command names. Historical mission docs left unchanged.

## Impact

- **Scope:** 4 command files (rename + frontmatter), 6 documentation/script files (text references)
- **Risk:** Low — pure rename, no logic changes
- **Complexity:** Low — mechanical find-and-replace across known files
