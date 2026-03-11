#!/usr/bin/env bash
set -e

git --no-pager log --name-only --pretty=format: --diff-filter=AMCR |
  awk 'NF && !seen[$0]++ { print; if (++n == 10) exit }'
