#!/usr/bin/env bash
set -euo pipefail

readonly ALIAS_PATTERN='^alias\.'

print_git_aliases() {
  git --no-pager config \
    --show-origin \
    --get-regexp "$ALIAS_PATTERN"
}

print_git_aliases
