# Custom git aliases

Small shell-based Git aliases for common daily workflows.

## Setup

Run the init script once:

```bash
bash ./init.sh
```

This writes the aliases into your global Git config, so they are available in any Git repository on your machine.

You can rerun `init.sh` at any time. It only updates aliases whose values have changed.

## Included aliases

### `git cb`

Print the current branch name.

```bash
git cb
```

### `git today`

Show commits created since midnight, using a compact readable format.

```bash
git today
```

Example output:

```text
* 91b21a7 - feat(readme): add usage guide (2 minutes ago) <cuimingda>
```

### `git recent`

Show the 10 most recent unique file paths that appeared in added, modified, copied, or renamed commits.

```bash
git recent
```

Example output:

```text
README.md
init.sh
recent.sh
```

### `git pp`

Push the current branch to `origin` and set upstream tracking.

```bash
git pp
```

This alias does not depend on any other alias. It resolves the current branch directly inside the script.

If you run it from a detached `HEAD`, it exits with an error.

### `git al`

List all configured Git aliases together with the config file they come from.

```bash
git al
```

Example output:

```text
file:/Users/you/.gitconfig alias.today !/path/to/scripts/today.sh
file:/Users/you/.gitconfig alias.recent !/path/to/scripts/recent.sh
```

### `git cc`

Generate a Conventional Commit message from staged changes with Copilot CLI, show the proposed message, and ask for confirmation before committing.

```bash
git add .
git cc
```

Requirements:

- `git`
- `copilot` CLI installed and authenticated
- staged changes in the current repository

## Scripts

Each alias is backed by a standalone shell script where appropriate:

- `scripts/today.sh`
- `scripts/recent.sh`
- `scripts/push-current-branch.sh`
- `scripts/alias-list.sh`
- `scripts/git-ai-commit.sh`

This keeps the Git alias definitions short and makes the behavior easier to maintain.
