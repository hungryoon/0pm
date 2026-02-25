#!/bin/bash
# Test script for state.sh
# Usage: bash scripts/test-state.sh

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

assert_file_exists() {
  if [ -f "$1" ]; then
    PASS=$((PASS + 1))
  else
    echo "FAIL: Expected file $1 to exist"
    FAIL=$((FAIL + 1))
  fi
}

# Override STATE_FILE location for testing
export OPM_STATE_FILE="$TEST_DIR/.0pm-state.json"
source "$SCRIPT_DIR/state.sh"

echo "=== Test: Initial state (no file) ==="
result=$(get_active_mission)
assert_eq "get_active_mission (empty)" "" "$result"

echo "=== Test: Set active mission ==="
set_active_mission "feat-test-mission-20260225"
assert_file_exists "$OPM_STATE_FILE"
result=$(get_active_mission)
assert_eq "get_active_mission" "feat-test-mission-20260225" "$result"

echo "=== Test: Overwrite active mission ==="
set_active_mission "feat-other-mission-20260225"
result=$(get_active_mission)
assert_eq "get_active_mission (overwrite)" "feat-other-mission-20260225" "$result"

echo "=== Test: State file has updated_at ==="
if grep -q "updated_at" "$OPM_STATE_FILE"; then
  PASS=$((PASS + 1))
else
  echo "FAIL: State file should contain updated_at"
  FAIL=$((FAIL + 1))
fi

echo "=== Test: get_current_task ==="
# Create mock tasks.md
MOCK_MISSION_DIR="$TEST_DIR/docs/missions/feat-other-mission-20260225"
mkdir -p "$MOCK_MISSION_DIR"
cat > "$MOCK_MISSION_DIR/tasks.md" << 'TASKS'
# Tasks: Test

### Task 1: First task
- **Status:** [x] done
- **Files:** file1.sh

### Task 2: Second task
- **Status:** [ ] pending
- **Files:** file2.sh

### Task 3: Third task
- **Status:** [ ] pending
- **Files:** file3.sh
TASKS

export OPM_DOCS_DIR="$TEST_DIR/docs"
result=$(get_current_task "feat-other-mission-20260225")
assert_eq "get_current_task" "2" "$result"

echo "=== Test: get_current_task (all done) ==="
cat > "$MOCK_MISSION_DIR/tasks.md" << 'TASKS'
### Task 1: First task
- **Status:** [x] done

### Task 2: Second task
- **Status:** [x] done
TASKS

result=$(get_current_task "feat-other-mission-20260225")
assert_eq "get_current_task (all done)" "0" "$result"

echo "=== Test: Clear state ==="
clear_state
result=$(get_active_mission)
assert_eq "get_active_mission (cleared)" "" "$result"

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  echo "All tests passed!"
fi
