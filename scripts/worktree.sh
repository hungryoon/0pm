#!/bin/bash
# 0pm Worktree Helpers
# Manages multi-repo worktrees for mission-based development.
# Usage: source scripts/worktree.sh

opm_parse_repos() {
  local config="${OPM_CONFIG_FILE:-0pm.config.yaml}"
  if [ ! -f "$config" ]; then
    return
  fi
  # Parse repos[] entries: extract name|path pairs
  local in_repos=false
  local name="" path=""
  while IFS= read -r line; do
    # Detect repos: section
    if echo "$line" | grep -q '^repos:'; then
      in_repos=true
      continue
    fi
    # Exit repos section on next top-level key
    if $in_repos && echo "$line" | grep -q '^[a-z]'; then
      break
    fi
    if $in_repos; then
      # New repo entry
      if echo "$line" | grep -q '^ *- name:'; then
        # Flush previous entry
        if [ -n "$name" ] && [ -n "$path" ]; then
          echo "$name|$path"
        fi
        name=$(echo "$line" | sed 's/.*name: *//;s/ *$//')
        path=""
      elif echo "$line" | grep -q '^ *path:'; then
        path=$(echo "$line" | sed 's/.*path: *//;s/ *$//')
      fi
    fi
  done < "$config"
  # Flush last entry
  if [ -n "$name" ] && [ -n "$path" ]; then
    echo "$name|$path"
  fi
}

opm_get_worktree_config() {
  local config="${OPM_CONFIG_FILE:-0pm.config.yaml}"
  # Defaults
  OPM_WT_BASE_DIR="./workspaces"
  OPM_WT_AUTO_CREATE="true"
  OPM_WT_AUTO_CLEANUP="true"
  OPM_WT_BRANCH_PREFIX="feat-"

  if [ ! -f "$config" ]; then
    return
  fi

  local in_worktree=false
  while IFS= read -r line; do
    if echo "$line" | grep -q '^worktree:'; then
      in_worktree=true
      continue
    fi
    if $in_worktree && echo "$line" | grep -q '^[a-z]'; then
      break
    fi
    if $in_worktree; then
      if echo "$line" | grep -q '^ *base_dir:'; then
        OPM_WT_BASE_DIR=$(echo "$line" | sed 's/.*base_dir: *//;s/ *$//;s/^"//;s/"$//')
      elif echo "$line" | grep -q '^ *auto_create:'; then
        OPM_WT_AUTO_CREATE=$(echo "$line" | sed 's/.*auto_create: *//;s/ *$//')
      elif echo "$line" | grep -q '^ *auto_cleanup:'; then
        OPM_WT_AUTO_CLEANUP=$(echo "$line" | sed 's/.*auto_cleanup: *//;s/ *$//')
      elif echo "$line" | grep -q '^ *branch_prefix:'; then
        OPM_WT_BRANCH_PREFIX=$(echo "$line" | sed 's/.*branch_prefix: *//;s/ *$//;s/^"//;s/"$//')
      fi
    fi
  done < "$config"
}

opm_create_worktrees() {
  local mission_id="$1"
  if [ -z "$mission_id" ]; then
    echo "Error: mission_id required" >&2
    return 1
  fi

  opm_get_worktree_config

  if [ "$OPM_WT_AUTO_CREATE" != "true" ]; then
    echo "Worktree auto_create is disabled, skipping."
    return 0
  fi

  local repos
  repos=$(opm_parse_repos)
  if [ -z "$repos" ]; then
    echo "No repos configured." >&2
    return 1
  fi

  local branch="${OPM_WT_BRANCH_PREFIX}${mission_id}"

  while IFS='|' read -r name repo_path; do
    local wt_path="${OPM_WT_BASE_DIR}/${mission_id}/${name}"
    if [ -d "$wt_path" ]; then
      echo "Worktree already exists: $wt_path"
      continue
    fi
    mkdir -p "$(dirname "$wt_path")"
    git -C "$repo_path" worktree add "$(cd "$(dirname "$wt_path")" && pwd)/$(basename "$wt_path")" -b "$branch" 2>/dev/null \
      || git -C "$repo_path" worktree add "$(cd "$(dirname "$wt_path")" && pwd)/$(basename "$wt_path")" "$branch" 2>/dev/null \
      || { echo "Error: Failed to create worktree for $name" >&2; continue; }
    echo "Created worktree: $wt_path (branch: $branch)"
  done <<< "$repos"
}

opm_cleanup_worktrees() {
  local mission_id="$1"
  if [ -z "$mission_id" ]; then
    echo "Error: mission_id required" >&2
    return 1
  fi

  opm_get_worktree_config

  if [ "$OPM_WT_AUTO_CLEANUP" != "true" ]; then
    echo "Worktree auto_cleanup is disabled, skipping."
    return 0
  fi

  local repos
  repos=$(opm_parse_repos)
  if [ -z "$repos" ]; then
    return 0
  fi

  while IFS='|' read -r name repo_path; do
    local wt_path="${OPM_WT_BASE_DIR}/${mission_id}/${name}"
    if [ ! -d "$wt_path" ]; then
      continue
    fi
    local abs_wt_path
    abs_wt_path=$(cd "$wt_path" 2>/dev/null && pwd) || continue
    git -C "$repo_path" worktree remove "$abs_wt_path" --force 2>/dev/null \
      || { echo "Warning: Could not remove worktree $wt_path" >&2; continue; }
    echo "Removed worktree: $wt_path"
  done <<< "$repos"

  # Clean up empty mission directory
  local mission_dir="${OPM_WT_BASE_DIR}/${mission_id}"
  if [ -d "$mission_dir" ] && [ -z "$(ls -A "$mission_dir" 2>/dev/null)" ]; then
    rmdir "$mission_dir" 2>/dev/null
  fi
}
