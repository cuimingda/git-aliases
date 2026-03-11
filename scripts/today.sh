#!/usr/bin/env bash
set -euo pipefail

readonly TODAY_RANGE_START="midnight"
readonly TODAY_LOG_FORMAT='* %Cred%h%Creset - %s %Cgreen(%ar)%Creset %Cblue<%an>%Creset'

print_today_commits() {
  git --no-pager log \
    --since="$TODAY_RANGE_START" \
    --pretty=format:"$TODAY_LOG_FORMAT"
}

print_today_commits
