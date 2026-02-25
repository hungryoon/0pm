#!/bin/bash
# Test script for plugin manifest and structure validation
# Usage: bash scripts/test-plugin.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR/../.claude-plugin"
ROOT_DIR="$SCRIPT_DIR/.."
PASS=0
FAIL=0

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
  local label="$1" path="$2"
  if [ -f "$path" ]; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [$label]: Expected file $path to exist"
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

echo "=== Test: plugin.json exists ==="
assert_file_exists "plugin.json exists" "$PLUGIN_DIR/plugin.json"

echo "=== Test: plugin.json is valid JSON ==="
if python3 -c "import json; json.load(open('$PLUGIN_DIR/plugin.json'))" 2>/dev/null; then
  PASS=$((PASS + 1))
else
  echo "FAIL [plugin.json valid JSON]: plugin.json is not valid JSON"
  FAIL=$((FAIL + 1))
fi

echo "=== Test: plugin.json has required fields ==="
for field in name version description commands; do
  val=$(python3 -c "import json; d=json.load(open('$PLUGIN_DIR/plugin.json')); print(d.get('$field',''))")
  if [ -n "$val" ]; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [required field '$field']: missing or empty in plugin.json"
    FAIL=$((FAIL + 1))
  fi
done

echo "=== Test: manifest does NOT declare hooks field ==="
has_hooks=$(python3 -c "import json; d=json.load(open('$PLUGIN_DIR/plugin.json')); print('yes' if 'hooks' in d else 'no')")
assert_eq "manifest has no hooks field" "no" "$has_hooks"

echo "=== Test: hooks/hooks.json exists (auto-loaded by Claude Code) ==="
assert_file_exists "hooks.json exists" "$ROOT_DIR/hooks/hooks.json"

echo "=== Test: hooks/hooks.json is valid JSON ==="
if python3 -c "import json; json.load(open('$ROOT_DIR/hooks/hooks.json'))" 2>/dev/null; then
  PASS=$((PASS + 1))
else
  echo "FAIL [hooks.json valid JSON]: hooks/hooks.json is not valid JSON"
  FAIL=$((FAIL + 1))
fi

echo "=== Test: commands directory exists ==="
COMMANDS_PATH=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/plugin.json')).get('commands',''))")
# Commands path is relative to plugin root (repo root), not .claude-plugin/
COMMANDS_DIR="$ROOT_DIR/$COMMANDS_PATH"
assert_dir_exists "commands dir exists" "$COMMANDS_DIR"

echo "=== Test: commands directory has .md files ==="
CMD_COUNT=$(find "$COMMANDS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$CMD_COUNT" -gt 0 ]; then
  PASS=$((PASS + 1))
else
  echo "FAIL [commands has .md files]: no .md files in $COMMANDS_DIR"
  FAIL=$((FAIL + 1))
fi

echo "=== Test: no duplicate hook file references ==="
# If manifest has a hooks field, check it doesn't point to the auto-loaded path
if [ "$has_hooks" = "yes" ]; then
  hooks_path=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/plugin.json')).get('hooks',''))")
  # Resolve to absolute and compare with standard path
  resolved_manifest=$(cd "$PLUGIN_DIR" && realpath "$hooks_path" 2>/dev/null || echo "$hooks_path")
  resolved_standard=$(realpath "$ROOT_DIR/hooks/hooks.json" 2>/dev/null || echo "$ROOT_DIR/hooks/hooks.json")
  if [ "$resolved_manifest" = "$resolved_standard" ]; then
    echo "FAIL [no duplicate hooks]: manifest.hooks points to auto-loaded hooks/hooks.json — this causes duplicate load errors"
    FAIL=$((FAIL + 1))
  else
    PASS=$((PASS + 1))
  fi
else
  # No hooks field = no duplicate possible
  PASS=$((PASS + 1))
fi

echo "=== Test: marketplace.json is valid JSON (if exists) ==="
if [ -f "$PLUGIN_DIR/marketplace.json" ]; then
  if python3 -c "import json; json.load(open('$PLUGIN_DIR/marketplace.json'))" 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [marketplace.json valid JSON]: marketplace.json is not valid JSON"
    FAIL=$((FAIL + 1))
  fi
else
  PASS=$((PASS + 1))  # optional file, skip
fi

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  echo "All tests passed!"
fi
