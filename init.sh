#!/usr/bin/env bash
set -e

ensure_git_alias() {
  local name=$1
  local value=$2

  current=$(git config --global "alias.$name" || true)

  if [ "$current" != "$value" ]; then
    git config --global "alias.$name" "$value"
    echo "configured git alias: $name"
  fi
}

ensure_git_alias cb  "rev-parse --abbrev-ref HEAD"
ensure_git_alias pp '!git push -u origin $(git cb)'
ensure_git_alias al "!git --no-pager config --show-origin --get-regexp '^alias\\.'"
