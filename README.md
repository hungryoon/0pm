# 0pm

[English](README.md) | [한국어](README.ko.md)

Claude Code plugin. 4 slash commands that turn any codebase into something you can vibe code on.

## Install

```bash
# 1. Create a docs repo (adding -0pm is a convention, not required)
mkdir my-project-0pm && cd my-project-0pm
git init

# 2. Clone your code repos
git clone https://github.com/org/api-server repos/api-server
git clone https://github.com/org/web-client repos/web-client

# 3. Install the plugin
/plugin marketplace add hungryoon/0pm
/plugin install 0pm@hungryoon-0pm

# 4. First sync scaffolds everything
/0pm:sync
```

`/0pm:sync` detects a fresh project and creates `0pm.config.yaml`, `docs/` structure, templates, and `.gitignore` automatically. Your code repos live under `repos/` (gitignored).

## Usage

Open Claude Code and start with sync:

```
/0pm:sync
```

First run scans each repo under `repos/`, analyzes the codebase, and scaffolds a `docs/` structure — services, domains, glossary. Subsequent runs compare code against docs and flag what's out of date.

Once docs exist, plan a mission:

```
/0pm:plan
```

Tell it what you want to build. It creates a mission document (background, AS-IS/TO-BE, impact) and a task list with affected files and test criteria.

Then develop:

```
/0pm:dev
```

Works through tasks one by one using TDD. Knows which task you're on, even across sessions.

When all tasks are done:

```
/0pm:ship
```

Cross-checks checkpoints, tasks, and docs before you merge.

## What it actually does

`/0pm:sync` is the important one. It scans your codebase and produces structured docs that Claude can reference in every future session. Without it, Claude guesses. With it, Claude knows what exists and what matters.

The rest (`plan`, `dev`, `ship`) use those docs to do N→N+1 development — building on what's there instead of starting blind every time.

A session hook shows your current mission and next task on startup:

```
[0pm] Active missions:
feat-auth-refactor-20260301: 3/7 tasks done — next: Task 4: Add JWT middleware
Run /0pm:dev to continue.
```

## Config

`0pm.config.yaml` in your project root:

```yaml
version: "0.1.0"

language:
  display: ko     # Claude talks to you in this language
  document: en    # generated docs are written in this language

repos:
  - name: my-api
    path: ./repos/my-api
    type: nestjs
    description: Backend API

docs:
  path: ./docs

worktree:
  base_dir: ./workspaces
  auto_create: true
  auto_cleanup: true
  branch_prefix: "feat-"
```

## Inspired by

- [Superpowers](https://github.com/obra/superpowers) — agentic skills framework for structured AI development
- [bkit](https://github.com/popup-studio-ai/bkit-claude-code) — PDCA methodology + context engineering for Claude Code
- [Spec Kit](https://github.com/github/spec-kit) — spec-driven development toolkit by GitHub

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Bash
- Git

## License

MIT
