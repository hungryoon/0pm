#!/bin/bash
# 0pm State Helpers
# Manages .0pm-state.json for cross-command context continuity.
# Usage: source scripts/state.sh

get_active_mission() {
  local state_file="${OPM_STATE_FILE:-.0pm-state.json}"
  if [ ! -f "$state_file" ]; then
    echo ""
    return
  fi
  # Extract active_mission value without python/jq dependency
  grep -o '"active_mission"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null \
    | sed 's/.*: *"\([^"]*\)"/\1/' \
    | head -1
}

set_active_mission() {
  local state_file="${OPM_STATE_FILE:-.0pm-state.json}"
  local mission_id="$1"
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%S")
  printf '{\n  "active_mission": "%s",\n  "updated_at": "%s"\n}\n' "$mission_id" "$now" > "$state_file"
}

get_current_task() {
  local docs_dir="${OPM_DOCS_DIR:-docs}"
  local mission_id="$1"
  local tasks_file="$docs_dir/missions/$mission_id/tasks.md"
  if [ ! -f "$tasks_file" ]; then
    echo "0"
    return
  fi
  # Find the line number of the first pending task [ ]
  local pending_line
  pending_line=$(grep -n '\[ \]' "$tasks_file" | head -1 | cut -d: -f1)
  if [ -z "$pending_line" ]; then
    echo "0"
    return
  fi
  # Look backwards from that line to find ### Task N
  local task_num
  task_num=$(head -n "$pending_line" "$tasks_file" | grep -o '### Task [0-9]*' | tail -1 | grep -o '[0-9]*')
  echo "${task_num:-0}"
}

clear_state() {
  local state_file="${OPM_STATE_FILE:-.0pm-state.json}"
  if [ -f "$state_file" ]; then
    rm -f "$state_file"
  fi
}
