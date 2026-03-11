#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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
ensure_git_alias today  "!git --no-pager log --since=midnight --pretty=format:'* %Cred%h%Creset - %s %Cgreen(%ar)%Creset %Cblue<%an>%Creset'"
ensure_git_alias recent  "!$SCRIPT_DIR/recent.sh"
ensure_git_alias pp '!git push -u origin $(git cb)'
ensure_git_alias al "!git --no-pager config --show-origin --get-regexp '^alias\\.'"
ensure_git_alias cc "!$SCRIPT_DIR/git-ai-commit.sh"
