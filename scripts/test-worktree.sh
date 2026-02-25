#!/bin/bash
# Test script for worktree.sh
# Usage: bash scripts/test-worktree.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR=$(mktemp -d)
PASS=0
FAIL=0

cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: expected '$expected', got '$actual'"
    FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local label="$1" expected="$2" actual="$3"
  if echo "$actual" | grep -q "$expected"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: expected to contain '$expected', got '$actual'"
    FAIL=$((FAIL + 1))
  fi
}

assert_dir_exists() {
  local label="$1" path="$2"
  if [ -d "$path" ]; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: Expected directory $path to exist"
    FAIL=$((FAIL + 1))
  fi
}

assert_dir_not_exists() {
  local label="$1" path="$2"
  if [ ! -d "$path" ]; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: Expected directory $path to NOT exist"
    FAIL=$((FAIL + 1))
  fi
}

# --- Setup: create test config ---
cat > "$TEST_DIR/0pm.config.yaml" << 'EOF'
version: "0.1.0"

language:
  display: ko
  document: en

repos:
  - name: api-server
    path: ./repos/api-server
    type: nestjs
    description: Main API
  - name: web-client
    path: ./repos/web-client
    type: nextjs
    description: Frontend app

docs:
  path: ./docs

worktree:
  base_dir: ./workspaces
  auto_create: true
  auto_cleanup: true
  branch_prefix: "feat-"
EOF

export OPM_CONFIG_FILE="$TEST_DIR/0pm.config.yaml"
source "$SCRIPT_DIR/worktree.sh"

# ============================================================
echo "=== Test: opm_parse_repos — parses two repos ==="
result=$(opm_parse_repos)
line_count=$(echo "$result" | wc -l | tr -d ' ')
assert_eq "repo count" "2" "$line_count"

echo "=== Test: opm_parse_repos — first repo ==="
first=$(echo "$result" | head -1)
assert_eq "first repo" "api-server|./repos/api-server" "$first"

echo "=== Test: opm_parse_repos — second repo ==="
second=$(echo "$result" | tail -1)
assert_eq "second repo" "web-client|./repos/web-client" "$second"

# ============================================================
echo "=== Test: opm_parse_repos — empty repos ==="
cat > "$TEST_DIR/empty.yaml" << 'EOF'
version: "0.1.0"
repos: []
docs:
  path: ./docs
EOF
OPM_CONFIG_FILE="$TEST_DIR/empty.yaml" result=$(opm_parse_repos)
assert_eq "empty repos" "" "$result"

# ============================================================
echo "=== Test: opm_parse_repos — missing config ==="
OPM_CONFIG_FILE="$TEST_DIR/nonexistent.yaml" result=$(opm_parse_repos)
assert_eq "missing config" "" "$result"

# ============================================================
echo "=== Test: opm_get_worktree_config — reads values ==="
opm_get_worktree_config
assert_eq "base_dir" "./workspaces" "$OPM_WT_BASE_DIR"
assert_eq "auto_create" "true" "$OPM_WT_AUTO_CREATE"
assert_eq "auto_cleanup" "true" "$OPM_WT_AUTO_CLEANUP"
assert_eq "branch_prefix" "feat-" "$OPM_WT_BRANCH_PREFIX"

# ============================================================
echo "=== Test: opm_get_worktree_config — custom values ==="
cat > "$TEST_DIR/custom.yaml" << 'EOF'
version: "0.1.0"
repos: []
worktree:
  base_dir: ./custom-ws
  auto_create: false
  auto_cleanup: false
  branch_prefix: "wip-"
EOF
OPM_CONFIG_FILE="$TEST_DIR/custom.yaml" opm_get_worktree_config
assert_eq "custom base_dir" "./custom-ws" "$OPM_WT_BASE_DIR"
assert_eq "custom auto_create" "false" "$OPM_WT_AUTO_CREATE"
assert_eq "custom auto_cleanup" "false" "$OPM_WT_AUTO_CLEANUP"
assert_eq "custom branch_prefix" "wip-" "$OPM_WT_BRANCH_PREFIX"

# ============================================================
echo "=== Test: opm_get_worktree_config — defaults when no worktree section ==="
cat > "$TEST_DIR/noworktree.yaml" << 'EOF'
version: "0.1.0"
repos: []
EOF
OPM_CONFIG_FILE="$TEST_DIR/noworktree.yaml" opm_get_worktree_config
assert_eq "default base_dir" "./workspaces" "$OPM_WT_BASE_DIR"
assert_eq "default auto_create" "true" "$OPM_WT_AUTO_CREATE"

# ============================================================
echo "=== Test: opm_create_worktrees — requires mission_id ==="
result=$(opm_create_worktrees 2>&1) || true
assert_contains "missing mission_id" "mission_id required" "$result"

# ============================================================
echo "=== Test: opm_create_worktrees — auto_create off ==="
cat > "$TEST_DIR/noauto.yaml" << 'EOF'
version: "0.1.0"
repos:
  - name: test
    path: ./repos/test
worktree:
  auto_create: false
EOF
OPM_CONFIG_FILE="$TEST_DIR/noauto.yaml" result=$(opm_create_worktrees "test-mission" 2>&1)
assert_contains "auto_create off" "disabled" "$result"

# ============================================================
echo "=== Test: opm_cleanup_worktrees — auto_cleanup off ==="
cat > "$TEST_DIR/noclean.yaml" << 'EOF'
version: "0.1.0"
repos:
  - name: test
    path: ./repos/test
worktree:
  auto_cleanup: false
EOF
OPM_CONFIG_FILE="$TEST_DIR/noclean.yaml" result=$(opm_cleanup_worktrees "test-mission" 2>&1)
assert_contains "auto_cleanup off" "disabled" "$result"

# ============================================================
echo "=== Test: opm_create_worktrees — creates real worktree ==="
# Setup: create a bare git repo as our "managed repo"
REPO_DIR="$TEST_DIR/repos/demo"
mkdir -p "$REPO_DIR"
git -C "$REPO_DIR" init -b main --quiet
git -C "$REPO_DIR" commit --allow-empty -m "init" --quiet

cat > "$TEST_DIR/wt-test.yaml" << EOF
version: "0.1.0"
repos:
  - name: demo
    path: $REPO_DIR
worktree:
  base_dir: $TEST_DIR/workspaces
  auto_create: true
  auto_cleanup: true
  branch_prefix: "feat-"
EOF

OPM_CONFIG_FILE="$TEST_DIR/wt-test.yaml" opm_create_worktrees "my-mission" > /dev/null 2>&1
assert_dir_exists "worktree created" "$TEST_DIR/workspaces/my-mission/demo"

# ============================================================
echo "=== Test: opm_create_worktrees — idempotent (already exists) ==="
OPM_CONFIG_FILE="$TEST_DIR/wt-test.yaml" result=$(opm_create_worktrees "my-mission" 2>&1)
assert_contains "already exists" "already exists" "$result"

# ============================================================
echo "=== Test: opm_cleanup_worktrees — removes worktree ==="
OPM_CONFIG_FILE="$TEST_DIR/wt-test.yaml" opm_cleanup_worktrees "my-mission" > /dev/null 2>&1
assert_dir_not_exists "worktree removed" "$TEST_DIR/workspaces/my-mission/demo"

# ============================================================
echo "=== Test: opm_cleanup_worktrees — cleans empty mission dir ==="
assert_dir_not_exists "mission dir cleaned" "$TEST_DIR/workspaces/my-mission"

# ============================================================
echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  echo "All tests passed!"
fi
