# AGENTS.md

## Project purpose

This repository manages a small set of custom Git aliases.

The aliases are installed into the user's global Git config by running `init.sh`.
Most aliases delegate their real behavior to standalone shell scripts in this repository.

## Repository layout

- `init.sh`: source of truth for alias registration
- `today.sh`: implementation for `git today`
- `recent.sh`: implementation for `git recent`
- `push-current-branch.sh`: implementation for `git pp`
- `alias-list.sh`: implementation for `git al`
- `git-ai-commit.sh`: implementation for `git cc`
- `README.md`: user-facing setup and usage documentation

## Working rules

### 1. Keep alias logic out of `init.sh`

If an alias does more than a very small built-in Git command, prefer moving the logic into a standalone shell script.

`init.sh` should stay focused on:

- resolving `SCRIPT_DIR`
- writing alias values into global Git config
- pointing aliases at scripts with absolute paths such as `!$SCRIPT_DIR/today.sh`

### 2. Standalone scripts must not depend on other aliases

Scripts should call `git` directly and must not assume aliases like `git cb` already exist.

For example, `push-current-branch.sh` should resolve the branch with `git rev-parse --abbrev-ref HEAD` instead of calling `git cb`.

### 3. Preserve Bash 3 compatibility

This repo is expected to work on macOS default Bash environments.

Do not use Bash 4+ only features such as:

- associative arrays via `declare -A`
- other newer shell features unless you have verified they work with Bash 3

Prefer portable Bash constructs:

- regular arrays
- `while IFS= read -r ...`
- small helper functions
- explicit constants via `readonly`

### 4. Script style

For standalone scripts, prefer:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Also prefer:

- small, named functions
- descriptive constant names
- clear stderr error messages for invalid states
- no unnecessary one-line pipeline code when normal shell logic is clearer

### 5. Update docs when behavior changes

If you add, remove, or change an alias:

- update `README.md`
- keep examples and command names aligned with actual behavior
- document new external dependencies if any

## Verification checklist

When changing alias installation or behavior, verify with the smallest realistic checks:

### Alias installation

Use a temporary `HOME` first so global config tests stay isolated:

```bash
tmpdir=$(mktemp -d)
HOME="$tmpdir" bash ./init.sh
HOME="$tmpdir" git config --global --get-regexp '^alias\.'
```

### Alias behavior

Test the affected alias directly, for example:

```bash
git today
git recent
git al
```

For `git pp`, prefer a temporary repository with a temporary bare remote so the push path is exercised safely.

For `git cc`, remember it depends on:

- `copilot` CLI being installed
- authentication already being set up
- staged changes existing in the current repo

## Change guidance

When adding a new alias:

1. Add or update the implementation script.
2. Point `init.sh` at the script using `!$SCRIPT_DIR/<script>.sh` when appropriate.
3. Make the script executable.
4. Verify installation in a temporary `HOME`.
5. Update `README.md`.

When refactoring existing aliases:

- preserve command names unless the user asked to rename them
- preserve output format unless there is a clear reason to change it
- keep failure modes explicit and readable

## Notes for future work

- `init.sh` writes to global Git config, so test carefully before changing alias values.
- If a script path changes, update both `init.sh` and `README.md`.
- If logic becomes complex, prefer another small script over embedding shell into the Git alias string.
