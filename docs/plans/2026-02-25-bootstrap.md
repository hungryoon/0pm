# 0PM 부트스트랩 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 0PM의 최소 기능을 수동으로 구축하여, 이후 개발을 0PM 자체로 할 수 있게 한다.

**Architecture:** `.claude/commands/` 슬래시 커맨드 5개가 제품. 각 커맨드는 Claude에게 역할을 지시하는 프롬프트. templates/에 문서 템플릿, scripts/에 훅 스크립트.

**Tech Stack:** Claude Code slash commands (Markdown + YAML frontmatter), Bash scripts, YAML config

---

## Task 1: 디렉토리 구조 + .gitignore

**Files:**
- Create: `.gitignore`
- Create: `docs/domains/.gitkeep`
- Create: `docs/services/.gitkeep`
- Create: `docs/relations/.gitkeep`
- Create: `docs/policies/.gitkeep`
- Create: `docs/missions/.gitkeep`

**Step 1: 디렉토리 생성**

```bash
mkdir -p docs/{domains,services,relations,policies,missions}
mkdir -p repos
mkdir -p workspaces
mkdir -p templates
mkdir -p scripts
mkdir -p .claude/commands
```

**Step 2: .gitkeep 생성**

docs/의 빈 디렉토리들에 `.gitkeep` 추가:

```bash
touch docs/domains/.gitkeep
touch docs/services/.gitkeep
touch docs/relations/.gitkeep
touch docs/policies/.gitkeep
touch docs/missions/.gitkeep
```

**Step 3: .gitignore 작성**

```gitignore
# 코드 레포들 (git clone)
repos/

# 미션별 worktree
workspaces/

# OS
.DS_Store
```

**Step 4: 확인**

Run: `find . -not -path './.git/*' -not -path './.git' | sort`
Expected: 위 디렉토리 구조가 모두 존재

**Step 5: 커밋**

```bash
git add .gitignore docs/ .claude/ templates/ scripts/
git commit -m "chore: create 0PM directory structure"
```

---

## Task 2: 0pm.config.yaml + self-referencing 심볼릭 링크

**Files:**
- Create: `0pm.config.yaml`

**Step 1: config 파일 작성**

```yaml
version: "0.1.0"

repos:
  - name: 0pm
    path: ./repos/0pm
    type: claude-code-plugin
    description: 0PM 플러그인 자체 (self-referencing)

docs:
  path: ./docs

worktree:
  base_dir: ./workspaces
  auto_create: true
  auto_cleanup: true
  branch_prefix: "feat-"
```

**Step 2: repos/0pm 심볼릭 링크 생성**

```bash
mkdir -p repos
ln -s .. repos/0pm
```

**Step 3: 확인**

Run: `ls -la repos/0pm/0pm-spec.md`
Expected: 파일이 보임 (심볼릭 링크를 통해 프로젝트 루트에 접근)

Run: `ls repos/0pm/repos/0pm/ 2>&1 | head -5`
Expected: 재귀적으로 접근 가능하지만, .gitignore로 repos/ 제외되므로 문제없음

**Step 4: 커밋**

```bash
git add 0pm.config.yaml
git commit -m "chore: add 0pm.config.yaml with self-referencing setup"
```

주의: repos/는 .gitignore에 있으므로 심볼릭 링크는 추적되지 않음. `/0pm-init` 실행 시 재생성.

---

## Task 3: 문서 템플릿

**Files:**
- Create: `templates/mission.md`
- Create: `templates/tasks.md`

**Step 1: mission.md 템플릿 작성**

```markdown
# Mission: {mission-title}

> **Mission ID:** `{mission-id}`
> **Status:** draft | in-progress | completed
> **Created:** {date}

## Checkpoints

{유저스토리/비즈니스 목표 목록}

## Background

{왜 이걸 해야 하는가}

## AS-IS (현재 상태)

{현재 시스템의 관련 부분 설명 — docs/에서 자동 추출}

## TO-BE (목표 상태)

{체크포인트 달성 후의 모습}

## Impact

- **영향 범위:** {어떤 서비스/모듈이 변경되는지}
- **리스크:** {기존 시스템과의 충돌 가능성}
- **복잡도:** {Low | Medium | High}
```

**Step 2: tasks.md 템플릿 작성**

```markdown
# Tasks: {mission-title}

> **Mission ID:** `{mission-id}`
> **Mission:** [mission.md](./mission.md)

## Task List

### Task 1: {task-title}

- **Status:** [ ] pending | [x] done
- **Files:** {영향받는 파일/모듈}
- **Description:** {구체적인 개발 내용}
- **Test:** {검증 방법}

### Task 2: {task-title}

- **Status:** [ ] pending | [x] done
- **Files:** {영향받는 파일/모듈}
- **Description:** {구체적인 개발 내용}
- **Test:** {검증 방법}
```

**Step 3: 커밋**

```bash
git add templates/
git commit -m "chore: add mission and tasks document templates"
```

---

## Task 4: CLAUDE.md

**Files:**
- Create: `CLAUDE.md`

**Step 1: CLAUDE.md 작성**

0PM 프로젝트의 컨텍스트를 Claude에 제공하는 파일. 프로젝트 개요, 디렉토리 구조, 용어, 워크플로우를 포함한다.

```markdown
# 0PM (제로PM) — Claude Code Plugin

> PM이 제로명. 엔지니어가 기획부터 배포까지 전부 한다.

## 프로젝트 개요

0PM은 레거시 코드베이스 위에서 PM 없이 엔지니어가 기획→개발→배포를 주도하는 Claude Code 플러그인이다.

## 디렉토리 구조

```
0pm/
├── .claude/commands/     # 슬래시 커맨드 (제품 코드)
├── docs/                 # Base — 단일 진실 원천
│   ├── domains/          # 도메인 설명
│   ├── services/         # 서비스별 구조 문서
│   ├── relations/        # 서비스 간 관계도
│   ├── policies/         # 비즈니스 규칙
│   └── missions/         # 미션별 기획+태스크
├── repos/                # 코드 레포 (.gitignore)
│   └── 0pm -> ..         # self-referencing
├── workspaces/           # 미션별 worktree (.gitignore)
├── templates/            # 문서 템플릿
├── scripts/              # 훅/자동화 스크립트
├── 0pm.config.yaml       # 프로젝트 설정
└── 0pm-spec.md           # 기획서
```

## 핵심 용어

| 용어 | 설명 |
|---|---|
| **Base** | docs/ 디렉토리. 모든 문서의 단일 진실 원천 |
| **Checkpoint** | 경영진/PM의 유저스토리 (비즈니스 목표) |
| **Mission** | 체크포인트를 기술 기획서로 변환한 문서 |
| **Task** | 미션에서 파생된 구체적 개발 항목 |
| **Mission ID** | 미션 고유 식별자 (브랜치명/디렉토리명으로 활용) |
| **Sync** | 코드↔문서 일관성 검사 및 동기화 |

## 워크플로우

```
/0pm-plan → /0pm-dev → /0pm-ship
                        /0pm-sync (수시)
```

1. **plan**: 체크포인트 입력 → 미션 생성 → 태스크 생성
2. **dev**: 태스크 기반 TDD 개발 + 코드리뷰
3. **ship**: 배포 전 검증 + 문서 최신화
4. **sync**: 코드↔문서 동기화 (독립 유틸리티)

## 개발 컨벤션

- TDD (Red-Green-Refactor) 원칙 따름
- 커밋은 작은 단위로 자주
- docs/를 항상 최신 상태로 유지
- 미션 단위로 worktree 격리하여 작업
```

**Step 2: 확인**

Run: `head -5 CLAUDE.md`
Expected: 제목과 설명이 올바르게 표시됨

**Step 3: 커밋**

```bash
git add CLAUDE.md
git commit -m "chore: add CLAUDE.md project context"
```

---

## Task 5: /0pm-init 커맨드

**Files:**
- Create: `.claude/commands/0pm-init.md`

**Step 1: 커맨드 작성**

```markdown
---
name: 0pm-init
description: 프로젝트 코드베이스를 분석하고 0PM 문서 구조를 자동 생성합니다
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# 0PM Init — 프로젝트 분석 & 스캐폴딩

당신은 0PM 초기화 에이전트입니다. 대상 프로젝트의 코드베이스를 분석하고 0PM 구조를 생성합니다.

## 실행 절차

### 1단계: 프로젝트 분석

현재 프로젝트 루트를 스캔하여 다음을 파악합니다:

- **언어/프레임워크**: package.json, requirements.txt, go.mod, Cargo.toml 등으로 감지
- **디렉토리 구조**: src/, lib/, app/, services/ 등 주요 디렉토리 파악
- **서비스/모듈 경계**: 마이크로서비스라면 각 서비스 식별, 모노리스라면 모듈 경계 식별
- **API 엔드포인트**: 라우트 파일, 컨트롤러 등에서 엔드포인트 추출
- **기존 문서**: README, docs/, wiki 등 기존 문서 확인

분석 결과를 사용자에게 요약하여 보여줍니다.

### 2단계: 사용자 확인

분석 결과를 보여주고 다음을 확인합니다:
- 감지된 서비스/모듈 목록이 맞는지
- 추가할 레포가 있는지 (멀티 레포인 경우)
- 프로젝트의 도메인/비즈니스 영역 설명

### 3단계: 구조 생성

확인 후 다음을 생성합니다:

1. **`0pm.config.yaml`** — 감지된 레포/서비스 정보 기반
2. **`docs/` 디렉토리** — domains/, services/, relations/, policies/, missions/
3. **서비스별 문서 초안** — docs/services/{service-name}/ 아래에 구조 문서
4. **도메인 용어 사전 초안** — docs/domains/ 아래에 주요 도메인 용어
5. **`.gitignore` 업데이트** — repos/, workspaces/ 제외 추가
6. **`CLAUDE.md` 생성/업데이트** — 프로젝트 컨텍스트

### 4단계: 결과 보고

생성된 파일 목록과 다음 단계를 안내합니다:
- "이제 `/0pm-plan`으로 첫 미션을 만들어보세요"
```

**Step 2: 확인**

Run: `cat .claude/commands/0pm-init.md | head -5`
Expected: frontmatter가 올바르게 표시됨

**Step 3: 커밋**

```bash
git add .claude/commands/0pm-init.md
git commit -m "feat: add /0pm-init command"
```

---

## Task 6: /0pm-plan 커맨드

**Files:**
- Create: `.claude/commands/0pm-plan.md`

**Step 1: 커맨드 작성**

```markdown
---
name: 0pm-plan
description: 비즈니스 체크포인트로부터 미션과 태스크를 생성합니다
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit
---

# 0PM Plan — 기획 (Checkpoint → Mission → Tasks)

당신은 0PM 기획 에이전트입니다. 비즈니스 목표를 기술 기획서와 개발 명세서로 변환합니다.

## 사전 조건

- `0pm.config.yaml`이 존재해야 합니다 (없으면 `/0pm-init` 안내)
- `docs/` 디렉토리가 존재해야 합니다

## 실행 절차

### 1단계: 컨텍스트 로드

다음을 읽어 현재 시스템 상태를 파악합니다:
- `0pm.config.yaml` — 프로젝트 구성
- `docs/services/` — 기존 서비스 문서
- `docs/domains/` — 도메인 지식
- `docs/missions/` — 진행 중인 미션 확인

### 2단계: 체크포인트 입력

사용자에게 체크포인트(유저스토리)를 요청합니다:
- "이번 미션의 비즈니스 목표(유저스토리)를 알려주세요"
- 3-5개의 구체적인 유저스토리를 받습니다
- 목표가 불명확하면 대화형으로 구체화합니다

### 3단계: Mission ID 생성

체크포인트 내용을 기반으로 Mission ID를 생성합니다:
- 형식: `{type}-{description}-{date}` (예: `feat-주문최적화-2026Q1`)
- 영문+한글 혼용 가능, 브랜치명으로 사용 가능해야 함
- 사용자에게 ID를 제안하고 확인받습니다

### 4단계: 미션 문서 생성

`templates/mission.md` 템플릿을 기반으로 `docs/missions/{mission-id}/mission.md` 생성:
- **Background**: 왜 이걸 해야 하는지
- **AS-IS**: `docs/`에서 현재 상태 자동 추출
- **TO-BE**: 체크포인트 기반 목표 상태
- **Impact**: 영향받는 서비스/모듈, 리스크
- 사용자와 대화하며 고도화합니다

### 5단계: 태스크 생성

미션이 확정되면 `templates/tasks.md` 기반으로 `docs/missions/{mission-id}/tasks.md` 생성:
- 구체적인 개발 항목 리스트
- 각 항목별 영향받는 파일/모듈
- 테스트 요구사항
- 태스크 간 의존성/순서

### 6단계: 결과 보고

생성된 문서를 보여주고 다음 단계를 안내합니다:
- "미션과 태스크가 생성되었습니다"
- "이제 `/0pm-dev`로 개발을 시작하세요"

## 중간 재진입

이미 미션이 존재하지만 태스크가 없는 경우, 태스크 생성 단계부터 시작합니다.
이미 미션과 태스크가 모두 있는 경우, 수정할지 새로 만들지 묻습니다.
```

**Step 2: 커밋**

```bash
git add .claude/commands/0pm-plan.md
git commit -m "feat: add /0pm-plan command"
```

---

## Task 7: /0pm-dev 커맨드

**Files:**
- Create: `.claude/commands/0pm-dev.md`

**Step 1: 커맨드 작성**

```markdown
---
name: 0pm-dev
description: 미션의 태스크를 기반으로 TDD 개발을 진행합니다
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, Task
---

# 0PM Dev — TDD 개발 + 코드리뷰

당신은 0PM 개발 에이전트입니다. 태스크 문서를 기반으로 체계적으로 개발합니다.

## 사전 조건

- `docs/missions/{mission-id}/tasks.md`가 존재해야 합니다 (없으면 `/0pm-plan` 안내)

## 실행 절차

### 1단계: 미션 선택

`docs/missions/` 아래의 미션 목록을 보여줍니다.
- 진행 중인 미션이 하나면 자동 선택
- 여러 개면 사용자에게 선택 요청
- `$ARGUMENTS`가 있으면 해당 Mission ID로 바로 진입

### 2단계: 태스크 로드 & 상태 확인

`tasks.md`를 읽고 현재 진행 상태를 파악합니다:
- 완료된 태스크 수 / 전체 태스크 수
- 다음에 할 태스크 식별
- 사용자에게 현재 진행 상황 보고

### 3단계: Worktree 생성 (필요 시)

`0pm.config.yaml`에서 레포 목록을 읽고:
- 현재 태스크가 영향주는 레포 파악
- `workspaces/{mission-id}/{repo-name}/` 에 worktree가 없으면 생성
- 이미 있으면 해당 worktree로 작업 컨텍스트 전환

```bash
# 예시
git worktree add workspaces/{mission-id}/{repo-name} -b {mission-id}
```

### 4단계: TDD 개발 루프

각 태스크를 순서대로 진행합니다:

1. **Red** — 실패하는 테스트 먼저 작성
2. **Green** — 테스트를 통과하는 최소 구현
3. **Refactor** — 코드 정리 (동작 변경 없이)
4. **Review** — 서브에이전트로 코드리뷰 실행
5. **Mark** — `tasks.md`에서 해당 태스크를 완료로 표시 (`[ ]` → `[x]`)
6. **Commit** — 작은 단위로 커밋

### 5단계: 완료 확인

모든 태스크 완료 시:
- `tasks.md`의 모든 항목이 `[x]`인지 확인
- 누락된 항목 체크
- "모든 태스크가 완료되었습니다. `/0pm-ship`으로 배포 준비를 하세요"

## 개발 원칙

- 테스트 먼저 (TDD)
- 커밋은 작은 단위로 자주
- 태스크 문서에 없는 범위는 건드리지 않음 (scope creep 방지)
- 리팩터링은 동작 변경 없이
```

**Step 2: 커밋**

```bash
git add .claude/commands/0pm-dev.md
git commit -m "feat: add /0pm-dev command"
```

---

## Task 8: /0pm-ship 커맨드

**Files:**
- Create: `.claude/commands/0pm-ship.md`

**Step 1: 커맨드 작성**

```markdown
---
name: 0pm-ship
description: 배포 전 최종 검증과 문서 최신화를 수행합니다
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# 0PM Ship — 배포 검증

당신은 0PM 배포 검증 에이전트입니다. 배포 전 모든 것이 정상인지 확인합니다.

## 사전 조건

- 개발이 완료된 미션이 있어야 합니다 (`tasks.md`의 태스크가 모두 완료)

## 실행 절차

### 1단계: 미션 선택

`$ARGUMENTS`로 Mission ID가 주어지면 해당 미션, 아니면 완료된 미션 목록에서 선택.

### 2단계: 문서 크로스체크

4가지 검증을 수행합니다:

1. **Checkpoint ✓** — mission.md의 체크포인트가 모두 달성되었는지
2. **Mission ✓** — 기획 내용이 실제 구현에 반영되었는지
3. **Task ✓** — tasks.md의 모든 항목이 `[x]`인지
4. **Base ✓** — docs/의 서비스 문서가 변경사항을 반영하는지

### 3단계: 코드 변경점 검토

```bash
git diff main...{mission-branch} --stat
```

- 변경된 파일 목록과 변경 규모 확인
- tasks.md에 없는 예상 외 변경이 있는지 체크
- 테스트 커버리지 확인 (가능한 경우)

### 4단계: 불일치 처리

불일치 발견 시:
- 자동 수정 가능한 항목: 수정 제안
- 수동 확인 필요 항목: 플래그로 표시
- 사용자에게 리포트 출력

### 5단계: 최종 정리

모든 검증 통과 시:
1. docs/ 문서 업데이트 커밋
2. mission.md의 Status를 `completed`로 변경
3. Worktree 정리 제안 (선택)
4. PR 생성 또는 merge 안내

### 6단계: 결과 보고

```
✓ Checkpoint: 3/3 달성
✓ Mission: 기획 반영 완료
✓ Tasks: 5/5 완료
✓ Docs: 최신화 완료
→ 배포 준비 완료
```
```

**Step 2: 커밋**

```bash
git add .claude/commands/0pm-ship.md
git commit -m "feat: add /0pm-ship command"
```

---

## Task 9: /0pm-sync 커맨드

**Files:**
- Create: `.claude/commands/0pm-sync.md`

**Step 1: 커맨드 작성**

```markdown
---
name: 0pm-sync
description: 코드와 문서의 일관성을 검사하고 동기화합니다
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# 0PM Sync — 코드↔문서 동기화

당신은 0PM 동기화 에이전트입니다. 코드와 문서의 일관성을 검사합니다.

## 실행 절차

### 1단계: 설정 로드

`0pm.config.yaml`에서 레포 목록과 docs 경로를 읽습니다.

### 2단계: 코드 스캔

각 레포를 스캔하여 현재 상태를 파악합니다:
- 디렉토리 구조
- API 엔드포인트 / 라우트
- 주요 모듈/클래스
- 설정 파일

### 3단계: 문서 비교

`docs/services/`의 문서와 실제 코드를 비교합니다:

- `[MISSING_DOC]` — 코드에 있는데 문서에 없음
- `[STALE_DOC]` — 문서가 오래됨 (코드가 변경됨)
- `[ORPHAN_DOC]` — 문서에 있는데 코드에서 삭제됨
- `[MISMATCH]` — 문서와 코드가 다름

### 4단계: 리포트 출력

```
=== 0PM Sync Report ===

[MISSING_DOC] services/api-gateway: /api/v2/orders 엔드포인트 문서 없음
[STALE_DOC] services/web-client: 컴포넌트 구조 변경됨 (2일 전)
[ORPHAN_DOC] domains/legacy-payment: 코드에서 삭제된 모듈

Summary: 1 missing, 1 stale, 1 orphan, 0 mismatch
```

### 5단계: 수정 제안

각 불일치 항목에 대해:
- 자동 수정 가능: 문서 업데이트 초안 제시
- 수동 확인 필요: 어떤 부분을 확인해야 하는지 안내
- 사용자 승인 후 수정 적용
```

**Step 2: 커밋**

```bash
git add .claude/commands/0pm-sync.md
git commit -m "feat: add /0pm-sync command"
```

---

## Task 10: 세션 시작 훅

**Files:**
- Create: `scripts/session-start.sh`
- Modify: `.claude/settings.json` (create if not exists)

**Step 1: session-start.sh 작성**

세션 시작 시 0PM 컨텍스트를 로드하는 스크립트.

```bash
#!/bin/bash

# 0PM Session Start Hook
# 세션 시작 시 현재 미션 상태를 요약하여 컨텍스트에 추가

CONFIG="0pm.config.yaml"
DOCS_DIR="docs"
CONTEXT=""

# 0pm.config.yaml 존재 확인
if [ ! -f "$CONFIG" ]; then
  echo '{"additionalContext": "0PM이 아직 초기화되지 않았습니다. /0pm-init으로 시작하세요."}'
  exit 0
fi

# 진행 중인 미션 확인
MISSIONS_DIR="$DOCS_DIR/missions"
if [ -d "$MISSIONS_DIR" ]; then
  ACTIVE_MISSIONS=""
  for mission_dir in "$MISSIONS_DIR"/*/; do
    if [ -d "$mission_dir" ]; then
      mission_name=$(basename "$mission_dir")
      tasks_file="$mission_dir/tasks.md"
      if [ -f "$tasks_file" ]; then
        total=$(grep -c '^\- \*\*Status:\*\*' "$tasks_file" 2>/dev/null || echo "0")
        done=$(grep -c '\[x\]' "$tasks_file" 2>/dev/null || echo "0")
        ACTIVE_MISSIONS="$ACTIVE_MISSIONS\n- $mission_name: $done/$total tasks done"
      fi
    fi
  done

  if [ -n "$ACTIVE_MISSIONS" ]; then
    CONTEXT="[0PM] Active missions:$ACTIVE_MISSIONS"
  fi
fi

if [ -n "$CONTEXT" ]; then
  # JSON escape
  ESCAPED=$(echo "$CONTEXT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
  echo "{\"additionalContext\": $ESCAPED}"
else
  echo '{"additionalContext": "[0PM] No active missions. Use /0pm-plan to create one."}'
fi
```

**Step 2: 실행 권한 부여**

```bash
chmod +x scripts/session-start.sh
```

**Step 3: .claude/settings.json 작성**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Step 4: 확인**

Run: `bash scripts/session-start.sh`
Expected: JSON 출력 (`{"additionalContext": "..."}`)

**Step 5: 커밋**

```bash
git add scripts/session-start.sh .claude/settings.json
git commit -m "feat: add session start hook for context loading"
```

---

## Task 11: 자기 자신 문서화 (Dogfooding 시작)

**Files:**
- Create: `docs/services/0pm/overview.md`

**Step 1: 0PM 자체 서비스 문서 작성**

```markdown
# 0PM Plugin Service

## Overview

0PM은 Claude Code 슬래시 커맨드 기반 플러그인이다.
엔지니어가 PM 없이 기획→개발→배포를 주도할 수 있게 한다.

## Architecture

- **Type:** Claude Code Plugin (slash commands)
- **Language:** Markdown (prompts) + Bash (scripts)
- **Commands:** 5개 (`init`, `plan`, `dev`, `ship`, `sync`)

## Components

| 컴포넌트 | 경로 | 설명 |
|---|---|---|
| Commands | `.claude/commands/0pm-*.md` | 사용자 진입점 (슬래시 커맨드) |
| Templates | `templates/` | 문서 생성 템플릿 |
| Scripts | `scripts/` | 훅/자동화 스크립트 |
| Config | `0pm.config.yaml` | 프로젝트 설정 |

## Commands

| 커맨드 | 설명 |
|---|---|
| `/0pm-init` | 프로젝트 분석 & 스캐폴딩 |
| `/0pm-plan` | 체크포인트 → 미션 → 태스크 |
| `/0pm-dev` | TDD 개발 + 코드리뷰 |
| `/0pm-ship` | 배포 검증 + 문서 최신화 |
| `/0pm-sync` | 코드↔문서 동기화 |
```

**Step 2: 커밋**

```bash
git add docs/services/0pm/
git commit -m "docs: add 0PM self-documentation"
```

---

## Task 12: 최종 검증 & 정리

**Step 1: 전체 구조 확인**

Run: `find . -not -path './.git/*' -not -name '.DS_Store' | sort`

Expected:
```
.
./.claude/commands/0pm-dev.md
./.claude/commands/0pm-init.md
./.claude/commands/0pm-plan.md
./.claude/commands/0pm-ship.md
./.claude/commands/0pm-sync.md
./.claude/settings.json
./0pm-spec.md
./0pm.config.yaml
./CLAUDE.md
./LICENSE
./docs/domains/.gitkeep
./docs/missions/.gitkeep
./docs/plans/2026-02-25-bootstrap.md
./docs/policies/.gitkeep
./docs/relations/.gitkeep
./docs/services/0pm/overview.md
./docs/services/.gitkeep
./.gitignore
./scripts/session-start.sh
./templates/mission.md
./templates/tasks.md
```

**Step 2: 커맨드 목록 확인**

Run: `ls .claude/commands/`
Expected: `0pm-dev.md  0pm-init.md  0pm-plan.md  0pm-ship.md  0pm-sync.md`

**Step 3: 심볼릭 링크 확인**

Run: `ls -la repos/0pm/CLAUDE.md`
Expected: 파일이 보임 (심볼릭 링크를 통해 접근)

**Step 4: 세션 훅 테스트**

Run: `bash scripts/session-start.sh`
Expected: `{"additionalContext": "[0PM] No active missions. Use /0pm-plan to create one."}`

모든 확인 통과 시, 부트스트랩 완료. 이후부터 `/0pm-plan`으로 미션을 만들어 0PM을 0PM으로 개발한다.
