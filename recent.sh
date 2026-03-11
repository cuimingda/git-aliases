#!/usr/bin/env bash
set -euo pipefail

readonly RECENT_FILE_LIMIT=10

collect_recent_file_changes() {
  git --no-pager log \
    --name-only \
    --pretty=format: \
    --diff-filter=AMCR
}

has_seen_file() {
  local target_file=$1
  local seen_file

  shift

  for seen_file in "$@"; do
    if [[ "$seen_file" == "$target_file" ]]; then
      return 0
    fi
  done

  return 1
}

print_recent_files() {
  local recent_file_changes
  local file_path
  local printed_count=0
  local -a seen_files=()

  recent_file_changes="$(collect_recent_file_changes)"

  while IFS= read -r file_path; do
    [[ -n "$file_path" ]] || continue

    if (( ${#seen_files[@]} > 0 )) && has_seen_file "$file_path" "${seen_files[@]}"; then
      continue
    fi

    seen_files+=("$file_path")
    printf '%s\n' "$file_path"

    ((printed_count += 1))

    if (( printed_count == RECENT_FILE_LIMIT )); then
      break
    fi
  done <<< "$recent_file_changes"
}

print_recent_files
