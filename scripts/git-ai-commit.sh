#!/usr/bin/env bash
set -euo pipefail

# ----------------- config -----------------
# Default model (0x in your list)
DEFAULT_MODEL="gpt-5-mini"

# Allow override per-run:
#   COPILOT_MODEL=claude-haiku-4.5 git aic
MODEL="${COPILOT_MODEL:-$DEFAULT_MODEL}"

# Optional: enforce 0x-only models to avoid premium burn.
# Set to 1 if you want a hard gate.
ENFORCE_ZERO_X="${ENFORCE_ZERO_X:-0}"
ZERO_X_ALLOWLIST_REGEX='^(gpt-5-mini|gpt-4\.1)$'

# ----------------- preflight -----------------
if ! command -v copilot >/dev/null 2>&1; then
  echo "copilot CLI not found. Install/login first." >&2
  exit 127
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git not found." >&2
  exit 127
fi

if git diff --cached --quiet; then
  echo "No staged changes. Stage files first (git add ...)." >&2
  exit 1
fi

if [[ "$ENFORCE_ZERO_X" == "1" ]] && [[ ! "$MODEL" =~ $ZERO_X_ALLOWLIST_REGEX ]]; then
  echo "Refusing to run with model '$MODEL' (not in 0x allowlist)." >&2
  echo "Set COPILOT_MODEL=gpt-5-mini (or gpt-4.1), or set ENFORCE_ZERO_X=0 to override." >&2
  exit 2
fi

# ----------------- prompt -----------------
PROMPT=$'You are generating a git commit message.\n'
PROMPT+=$'Constraints:\n'
PROMPT+=$'- Use Conventional Commits: type(scope): summary\n'
PROMPT+=$'- Summary must be <= 72 chars, imperative mood.\n'
PROMPT+=$'- If useful, add a blank line and a short body describing WHAT changed (not why).\n'
PROMPT+=$'- Output ONLY the commit message text. No tool traces, no steps, no commands, no bullets, no quotes, no code fences.\n\n'
PROMPT+=$'Task:\n'
PROMPT+=$'1) Run: git diff --staged\n'
PROMPT+=$'2) Produce the best commit message for these staged changes.\n'

echo "Generating commit message via Copilot CLI…"
echo "Model (forced): $MODEL"

TMP_OUT="$(mktemp)"
TMP_ERR="$(mktemp)"
TMP_MSG="$(mktemp)"
cleanup() { rm -f "$TMP_OUT" "$TMP_ERR" "$TMP_MSG" 2>/dev/null || true; }
trap cleanup EXIT

# Foreground execution to preserve TTY if Copilot needs it,
# but use --silent to keep output parseable.
if ! copilot \
  --model "$MODEL" \
  -p "$PROMPT" \
  --allow-tool 'shell(git)' \
  --silent \
  >"$TMP_OUT" 2>"$TMP_ERR"; then
  echo "Copilot CLI failed. stderr:" >&2
  cat "$TMP_ERR" >&2
  exit 1
fi

RAW="$(cat "$TMP_OUT")"
if [[ -z "${RAW//[[:space:]]/}" ]]; then
  echo "Copilot returned an empty message. stderr:" >&2
  cat "$TMP_ERR" >&2
  exit 1
fi

# ----------------- sanitize -----------------
# Even with --silent, some builds may still emit trace-y lines.
sanitize_commit_message() {
  local input="$1"

  # Drop common trace patterns if they slip in.
  local filtered
  filtered="$(printf "%s\n" "$input" \
    | sed -E '/^[[:space:]]*●[[:space:]]+/d' \
    | sed -E '/^[[:space:]]*\$[[:space:]]+git[[:space:]]+/d' \
    | sed -E '/^[[:space:]]*└[[:space:]]+/d')"

  # Trim leading/trailing blank lines
  filtered="$(printf "%s\n" "$filtered" | awk '
    BEGIN{p=0}
    {
      if(p==0 && $0 ~ /^[[:space:]]*$/) next
      p=1
      lines[++n]=$0
    }
    END{
      # trim trailing blanks
      while(n>0 && lines[n] ~ /^[[:space:]]*$/) n--
      for(i=1;i<=n;i++) print lines[i]
    }
  ')"

  # If we can find a conventional-commit header, keep from that line onward.
  local start
  start="$(printf "%s\n" "$filtered" | awk '
    {n++; if($0 ~ /^[a-z]+(\([^)]+\))?!?:[[:space:]]+/){ print n; exit }}
  ')"

  if [[ -n "${start:-}" ]]; then
    printf "%s\n" "$filtered" | tail -n +"$start"
  else
    printf "%s\n" "$filtered"
  fi
}

MSG="$(sanitize_commit_message "$RAW")"

if [[ -z "${MSG//[[:space:]]/}" ]]; then
  echo "Copilot output could not be sanitized into a commit message." >&2
  echo "Raw output:" >&2
  cat "$TMP_OUT" >&2
  exit 1
fi

# ----------------- confirm + commit -----------------
echo "----- Suggested commit message -----"
echo "$MSG"
echo "-----------------------------------"
printf "Commit with this message? [Y/n] "
read -r yn
# Default to yes when input is empty
yn="${yn:-y}"
case "$yn" in
  [Yy]*)
    printf "%s\n" "$MSG" >"$TMP_MSG"
    git commit -F "$TMP_MSG"
    ;;
  *)
    echo "Cancelled."
    exit 0
    ;;
esac
