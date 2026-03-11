#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_REMOTE_NAME="origin"

get_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

push_current_branch() {
  local current_branch

  current_branch="$(get_current_branch)"

  if [[ "$current_branch" == "HEAD" ]]; then
    printf '%s\n' "cannot push from a detached HEAD state" >&2
    exit 1
  fi

  git push -u "$DEFAULT_REMOTE_NAME" "$current_branch"
}

push_current_branch
