---
name: sync
description: Initialize project or synchronize code and documentation. Auto-detects mode based on current state.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# 0pm Sync — Initialize & Synchronize

You are the 0pm sync agent. You analyze the codebase and keep documentation in sync with code.

**This command operates in two modes:**
- **Init mode**: When `docs/` is empty or `0pm.config.yaml` doesn't exist — analyze the codebase and scaffold the 0pm structure
- **Sync mode**: When docs already exist — compare code vs docs, report mismatches, suggest fixes

## Language Setting

Check `0pm.config.yaml` for the `language` section:
- `language.display`: Use this language for all conversation output (explanations, reports, prompts to the user). Default to English if not specified.
- `language.document`: Use this language for all generated/updated documents (service docs, glossary, CLAUDE.md, etc.). Default to English if not specified.

## Mode Detection

```
if 0pm.config.yaml missing OR docs/services/ empty:
  → Init mode
else:
  → Sync mode
```

---

## Init Mode (First Run)

### Step 0: Scaffold Project

Before analysis, ensure the project structure exists:

```bash
mkdir -p docs/domains docs/services docs/missions repos workspaces templates
```

Copy templates from the plugin if `templates/` is empty:

```bash
cp "$CLAUDE_PLUGIN_ROOT/templates/"*.md templates/ 2>/dev/null || true
```

Create `.gitignore` if missing (add `repos/`, `workspaces/`, `.0pm-state.json`).

### Step 1: Project Analysis

Scan each repo listed in `repos/` directory (or `repos[]` in config) to identify:

- **Languages/Frameworks**: Detect via package.json, requirements.txt, go.mod, Cargo.toml, etc.
- **Directory structure**: Identify key directories (src/, lib/, app/, services/, etc.)
- **Service/module boundaries**: Identify microservices or module boundaries in monoliths
- **API endpoints**: Extract from route files, controllers, etc.
- **Existing docs**: Check for README, docs/, wiki, etc.

Present the analysis summary to the user.

### Step 2: User Confirmation

Show the analysis results and confirm:
- Is the detected service/module list correct?
- Are there additional repos to include? (for multi-repo setups)
- What are the project's domain/business areas?

### Step 3: Generate Structure

After confirmation, generate:

1. **`0pm.config.yaml`** — based on detected repo/service information (create or update). Populate `repos[]` with each repository found under `repos/`.
2. **`docs/` directory** — domains/, services/, missions/
3. **Service docs drafts** — structure docs under docs/services/{service-name}/. For multi-repo setups, scan each repo in `repos[]` to detect services.
4. **Domain glossary draft** — key domain terms under docs/domains/
5. **`.gitignore` update** — add repos/, workspaces/ exclusions
6. **`CLAUDE.md` create/update** — project context

### Step 4: Report

List generated files and guide next steps:
- "Run `/0pm:plan` to create your first mission"

---

## Sync Mode (Subsequent Runs)

### Step 1: Load Config

Read repo list and docs path from `0pm.config.yaml`.

### Step 2: Scan Code

Scan each repo to assess current state:
- Directory structure
- API endpoints / routes
- Key modules/classes
- Configuration files

### Step 3: Compare with Docs

Compare `docs/services/` documentation against actual code:

- `[MISSING_DOC]` — exists in code but not in docs
- `[STALE_DOC]` — docs are outdated (code has changed)
- `[ORPHAN_DOC]` — exists in docs but deleted from code
- `[MISMATCH]` — docs and code disagree

### Step 4: Output Report

```
=== 0pm Sync Report ===

[MISSING_DOC] services/api-gateway: /api/v2/orders endpoint not documented
[STALE_DOC] services/web-client: component structure changed (2 days ago)
[ORPHAN_DOC] domains/legacy-payment: module deleted from code

Summary: 1 missing, 1 stale, 1 orphan, 0 mismatch
```

### Step 5: Suggest Fixes

For each inconsistency:
- Auto-fixable: present document update draft
- Needs manual review: guide what to check
- Apply fixes after user approval
