# 0pm

[English](README.md) | [한국어](README.ko.md)

Claude Code 플러그인. 슬래시 커맨드 4개로 어떤 코드베이스에서든 바이브코딩 할 수 있게 해줍니다.

## 설치

```bash
# 1. docs 레포 생성 (-0pm은 관례일 뿐, 필수 아님)
mkdir my-project-0pm && cd my-project-0pm
git init

# 2. 코드 레포 clone
git clone https://github.com/org/api-server repos/api-server
git clone https://github.com/org/web-client repos/web-client

# 3. 플러그인 설치
/plugin marketplace add hungryoon/0pm
/plugin install 0pm@hungryoon-0pm

# 4. 첫 sync가 전부 알아서 세팅
/0pm:0sync
```

`/0pm:0sync`가 새 프로젝트를 감지하면 `0pm.config.yaml`, `docs/` 구조, 템플릿, `.gitignore`를 자동 생성합니다. 실제 코드 레포는 `repos/` 아래에 위치합니다 (gitignore됨).

## 사용법

Claude Code를 열고 sync부터 시작:

```
/0pm:0sync
```

처음 실행하면 `repos/` 아래 각 레포를 스캔하고 `docs/` 구조를 만듭니다 — 서비스, 도메인, 용어집. 이후 실행하면 코드와 문서를 비교해서 뭐가 오래됐는지 알려줍니다.

문서가 생기면 미션을 계획:

```
/0pm:0plan
```

뭘 만들고 싶은지 말하면 미션 문서(배경, AS-IS/TO-BE, 영향도)와 태스크 목록(파일, 설명, 테스트 기준)을 만듭니다.

개발:

```
/0pm:0dev
```

태스크를 하나씩 TDD로 진행합니다. 세션이 바뀌어도 어디까지 했는지 기억합니다.

태스크가 다 끝나면:

```
/0pm:0ship
```

체크포인트, 태스크, 문서를 교차 검증하고 머지 준비를 합니다.

## 핵심

`/0pm:0sync`가 제일 중요합니다. 코드베이스를 스캔해서 구조화된 문서를 만들고, Claude가 이후 모든 세션에서 참조할 수 있게 합니다. 이게 없으면 Claude는 추측하고, 이게 있으면 뭐가 있고 뭐가 중요한지 압니다.

나머지(`plan`, `dev`, `ship`)는 그 문서를 기반으로 N→N+1 개발을 합니다 — 매번 맨땅에서 시작하는 게 아니라 있는 것 위에 쌓아갑니다.

세션 시작 시 훅이 현재 상태를 보여줍니다:

```
[0pm] 진행 중인 미션:
feat-auth-refactor-20260301: 3/7 태스크 완료 — 다음: Task 4: JWT 미들웨어 추가
/0pm:0dev로 계속하세요.
```

## 설정

프로젝트 루트의 `0pm.config.yaml`:

```yaml
version: "0.1.0"

language:
  display: ko     # Claude가 이 언어로 대화
  document: en    # 생성되는 문서의 언어

repos:
  - name: my-api
    path: ./repos/my-api
    type: nestjs
    description: 백엔드 API

docs:
  path: ./docs

worktree:
  base_dir: ./workspaces
  auto_create: true
  auto_cleanup: true
  branch_prefix: "feat-"
```

## 영감을 받은 프로젝트

- [Superpowers](https://github.com/obra/superpowers) — AI 에이전트를 위한 구조화된 개발 스킬 프레임워크
- [bkit](https://github.com/popup-studio-ai/bkit-claude-code) — PDCA 방법론 + 컨텍스트 엔지니어링 기반 Claude Code 플러그인
- [Spec Kit](https://github.com/github/spec-kit) — GitHub의 스펙 기반 개발 툴킷

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Bash
- Git

## 라이선스

MIT
