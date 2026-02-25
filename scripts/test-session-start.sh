#!/bin/bash
# Test script for enhanced session-start.sh
# Usage: bash scripts/test-session-start.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR=$(mktemp -d)
PASS=0
FAIL=0

cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

assert_output_contains() {
  local label="$1" expected="$2" actual="$3"
  if echo "$actual" | grep -q "$expected"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: output does not contain '$expected'"
    echo "  actual: $actual"
    FAIL=$((FAIL + 1))
  fi
}

assert_output_not_contains() {
  local label="$1" expected="$2" actual="$3"
  if ! echo "$actual" | grep -q "$expected"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: output should NOT contain '$expected'"
    FAIL=$((FAIL + 1))
  fi
}

assert_valid_json() {
  local label="$1" output="$2"
  if echo "$output" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: output is not valid JSON"
    echo "  output: $output"
    FAIL=$((FAIL + 1))
  fi
}

# --- Setup test environment ---
setup_test_dir() {
  rm -rf "$TEST_DIR"
  TEST_DIR=$(mktemp -d)
  # Copy scripts
  mkdir -p "$TEST_DIR/scripts"
  cp "$PROJECT_DIR/scripts/session-start.sh" "$TEST_DIR/scripts/"
  cp "$PROJECT_DIR/scripts/state.sh" "$TEST_DIR/scripts/"
}

echo "=== Test: No config file ==="
setup_test_dir
OUTPUT=$(cd "$TEST_DIR" && bash scripts/session-start.sh 2>&1)
assert_valid_json "no config json" "$OUTPUT"
assert_output_contains "no config msg" "0pm:sync" "$OUTPUT"

echo "=== Test: Config exists, no missions ==="
setup_test_dir
cat > "$TEST_DIR/0pm.config.yaml" << 'YAML'
version: "0.1.0"
YAML
mkdir -p "$TEST_DIR/docs/missions"
OUTPUT=$(cd "$TEST_DIR" && bash scripts/session-start.sh 2>&1)
assert_valid_json "no missions json" "$OUTPUT"
assert_output_contains "no missions msg" "0pm:plan" "$OUTPUT"

echo "=== Test: Active mission with mixed tasks ==="
setup_test_dir
cat > "$TEST_DIR/0pm.config.yaml" << 'YAML'
version: "0.1.0"
YAML
mkdir -p "$TEST_DIR/docs/missions/feat-test-20260225"
cat > "$TEST_DIR/docs/missions/feat-test-20260225/mission.md" << 'MD'
# Mission: Test
> **Status:** in-progress
MD
cat > "$TEST_DIR/docs/missions/feat-test-20260225/tasks.md" << 'TASKS'
### Task 1: Done task
- **Status:** [x] done

### Task 2: Pending task
- **Status:** [ ] pending
- **Description:** Do the second thing

### Task 3: Also pending
- **Status:** [ ] pending
TASKS

# Set active mission in state
export OPM_STATE_FILE="$TEST_DIR/.0pm-state.json"
source "$PROJECT_DIR/scripts/state.sh"
set_active_mission "feat-test-20260225"

OUTPUT=$(cd "$TEST_DIR" && bash scripts/session-start.sh 2>&1)
assert_valid_json "active mission json" "$OUTPUT"
assert_output_contains "shows mission name" "feat-test-20260225" "$OUTPUT"
assert_output_contains "shows progress" "1/3" "$OUTPUT"
assert_output_contains "suggests dev" "0pm:dev" "$OUTPUT"

echo "=== Test: All tasks completed ==="
setup_test_dir
cat > "$TEST_DIR/0pm.config.yaml" << 'YAML'
version: "0.1.0"
YAML
mkdir -p "$TEST_DIR/docs/missions/feat-done-20260225"
cat > "$TEST_DIR/docs/missions/feat-done-20260225/mission.md" << 'MD'
# Mission: Done
> **Status:** in-progress
MD
cat > "$TEST_DIR/docs/missions/feat-done-20260225/tasks.md" << 'TASKS'
### Task 1: Task
- **Status:** [x] done

### Task 2: Task
- **Status:** [x] done
TASKS

export OPM_STATE_FILE="$TEST_DIR/.0pm-state.json"
source "$PROJECT_DIR/scripts/state.sh"
set_active_mission "feat-done-20260225"

OUTPUT=$(cd "$TEST_DIR" && bash scripts/session-start.sh 2>&1)
assert_valid_json "all done json" "$OUTPUT"
assert_output_contains "shows all done" "2/2" "$OUTPUT"
assert_output_contains "suggests ship" "0pm:ship" "$OUTPUT"

echo "=== Test: Completed mission filtered out ==="
setup_test_dir
cat > "$TEST_DIR/0pm.config.yaml" << 'YAML'
version: "0.1.0"
YAML
mkdir -p "$TEST_DIR/docs/missions/feat-old-20260225"
cat > "$TEST_DIR/docs/missions/feat-old-20260225/mission.md" << 'MD'
# Mission: Old
> **Status:** completed
MD
cat > "$TEST_DIR/docs/missions/feat-old-20260225/tasks.md" << 'TASKS'
### Task 1: Task
- **Status:** [x] done
TASKS

OUTPUT=$(cd "$TEST_DIR" && bash scripts/session-start.sh 2>&1)
assert_valid_json "completed filtered json" "$OUTPUT"
assert_output_not_contains "no completed mission" "feat-old-20260225" "$OUTPUT"

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  echo "All tests passed!"
fi
