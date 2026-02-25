#!/bin/bash
# 0pm Session Start Hook
# Provides rich mission context at session start.
# Output: JSON with additionalContext field.

CONFIG="0pm.config.yaml"
DOCS_DIR="docs"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source state helpers
if [ -f "$SCRIPT_DIR/state.sh" ]; then
  source "$SCRIPT_DIR/state.sh"
fi

# --- No config: prompt init ---
if [ ! -f "$CONFIG" ]; then
  printf '{"additionalContext": "0pm is not initialized yet. Run /0pm:0sync to get started."}\n'
  exit 0
fi

# --- Read display language from config ---
DISPLAY_LANG=$(grep -A1 '^language:' "$CONFIG" 2>/dev/null | grep 'display:' | sed 's/.*display:[[:space:]]*//' | tr -d ' ')
DISPLAY_LANG="${DISPLAY_LANG:-en}"

# --- Localized message helpers ---
msg() {
  local key="$1"
  shift
  case "$DISPLAY_LANG" in
    ko)
      case "$key" in
        header)          echo "[0pm] 진행 중인 미션:" ;;
        no_missions)     echo "[0pm] 진행 중인 미션이 없습니다. /0pm:0plan으로 새 미션을 만드세요." ;;
        tasks_done)      printf "%s: %s/%s 태스크 완료" "$1" "$2" "$3" ;;
        all_complete)    echo " — 전부 완료! /0pm:0ship으로 배포하세요." ;;
        next_task)       printf " — 다음: %s" "$1" ;;
        continue)        echo ". /0pm:0dev로 계속하세요." ;;
      esac
      ;;
    *)
      case "$key" in
        header)          echo "[0pm] Active missions:" ;;
        no_missions)     echo "[0pm] No active missions. Use /0pm:0plan to create one." ;;
        tasks_done)      printf "%s: %s/%s tasks done" "$1" "$2" "$3" ;;
        all_complete)    echo " — all complete! Run /0pm:0ship to deploy." ;;
        next_task)       printf " — next: %s" "$1" ;;
        continue)        echo ". Run /0pm:0dev to continue." ;;
      esac
      ;;
  esac
}

# --- Collect active missions ---
MISSIONS_DIR="$DOCS_DIR/missions"
CONTEXT=""

if [ -d "$MISSIONS_DIR" ]; then
  for mission_dir in "$MISSIONS_DIR"/*/; do
    [ -d "$mission_dir" ] || continue
    mission_name=$(basename "$mission_dir")
    mission_file="$mission_dir/mission.md"
    tasks_file="$mission_dir/tasks.md"

    # Skip completed missions
    if [ -f "$mission_file" ] && grep -q 'Status:.*completed' "$mission_file" 2>/dev/null; then
      continue
    fi

    if [ -f "$tasks_file" ]; then
      total=$(grep -c '^\- \*\*Status:\*\*' "$tasks_file" 2>/dev/null || echo "0")
      done=$(grep -c '\[x\]' "$tasks_file" 2>/dev/null || echo "0")

      if [ "$total" -gt 0 ] && [ "$done" -eq "$total" ]; then
        CONTEXT="${CONTEXT}$(msg tasks_done "$mission_name" "$done" "$total")$(msg all_complete)\n"
      elif [ "$total" -gt 0 ]; then
        # Get task number from preceding header
        next_num=$(grep -n '\[ \]' "$tasks_file" | head -1 | cut -d: -f1)
        next_header=""
        if [ -n "$next_num" ]; then
          next_header=$(head -n "$next_num" "$tasks_file" | grep '### Task' | tail -1 | sed 's/### //')
        fi

        CONTEXT="${CONTEXT}$(msg tasks_done "$mission_name" "$done" "$total")"
        if [ -n "$next_header" ]; then
          CONTEXT="${CONTEXT}$(msg next_task "$next_header")"
        fi
        CONTEXT="${CONTEXT}$(msg continue)\n"
      fi
    fi
  done
fi

# --- Output ---
if [ -n "$CONTEXT" ]; then
  HEADER=$(msg header)
  if command -v python3 &>/dev/null; then
    ESCAPED=$(printf '%s\n%b' "$HEADER" "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
    printf '{"additionalContext": %s}\n' "$ESCAPED"
  else
    printf '{"additionalContext": "%s\\n%s"}\n' "$HEADER" "$CONTEXT"
  fi
else
  printf '{"additionalContext": "%s"}\n' "$(msg no_missions)"
fi
