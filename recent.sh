#!/usr/bin/env bash
set -euo pipefail

readonly RECENT_FILE_LIMIT=10

print_recent_files() {
  git --no-pager log \
    --name-only \
    --pretty=format: \
    --diff-filter=AMCR |
    awk -v limit="$RECENT_FILE_LIMIT" '
      NF && !seen[$0]++ {
        print

        if (++count == limit) {
          exit
        }
      }
    '
}

print_recent_files
