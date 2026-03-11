#!/usr/bin/env bash
set -e

SCRIPTS_ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$SCRIPTS_ROOT_DIR/scripts"

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
ensure_git_alias today  "!$SCRIPTS_DIR/today.sh"
ensure_git_alias recent  "!$SCRIPTS_DIR/recent.sh"
ensure_git_alias pp "!$SCRIPTS_DIR/push-current-branch.sh"
ensure_git_alias al "!$SCRIPTS_DIR/alias-list.sh"
ensure_git_alias cc "!$SCRIPTS_DIR/git-ai-commit.sh"
