#!/usr/bin/env bash
# Stop hook for noai-kit's handoff-auto: when enabled for the current
# project, blocks the session from stopping after a medium/large
# uncommitted change, asking Claude to run the handoff skill first.
#
# Opt-in per project via .noai-kit/auto-handoff.json ({"enabled": true},
# written by the handoff-auto skill) — silently does nothing otherwise,
# even though this hook is registered globally with the plugin.
set -euo pipefail

# Drain hook input from stdin (unused — project root comes from
# $CLAUDE_PROJECT_DIR — but the hook runner may expect stdin consumed).
cat >/dev/null 2>&1 || true

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
FLAG_FILE="$PROJECT_DIR/.noai-kit/auto-handoff.json"
STATE_FILE="$PROJECT_DIR/.noai-kit/auto-handoff-state"

THRESHOLD_FILES=3
THRESHOLD_LINES=80

# Not enabled for this project -> silent no-op.
[ -f "$FLAG_FILE" ] || exit 0
grep -qE '"enabled"[[:space:]]*:[[:space:]]*true' "$FLAG_FILE" 2>/dev/null || exit 0

# Not a git repo -> silent no-op (no way to size the change).
git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Tracked changes (modified/staged/deleted) vs HEAD.
shortstat="$(git -C "$PROJECT_DIR" diff HEAD --shortstat 2>/dev/null || true)"
tracked_files="$(echo "$shortstat" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo 0)"
insertions="$(echo "$shortstat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)"
deletions="$(echo "$shortstat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)"

# New, untracked files don't show up in `git diff HEAD` at all — count them
# separately (path + line count) without touching the index (no `git add`).
# Exclude .noai-kit/ itself (state/flag files this hook writes), or every
# run would count its own bookkeeping as part of the change and re-trigger
# forever.
untracked_list="$(git -C "$PROJECT_DIR" status --porcelain --untracked-files=all 2>/dev/null | awk '/^\?\?/ {p=substr($0,4); if (p !~ /^\.noai-kit\//) print p}')"
untracked_files=0
untracked_lines=0
if [ -n "$untracked_list" ]; then
  while IFS= read -r f; do
    [ -f "$PROJECT_DIR/$f" ] || continue
    untracked_files=$((untracked_files + 1))
    untracked_lines=$((untracked_lines + $(wc -l < "$PROJECT_DIR/$f" 2>/dev/null || echo 0)))
  done <<< "$untracked_list"
fi

files=$((tracked_files + untracked_files))
lines=$((insertions + deletions + untracked_lines))

# No pending changes at all -> silent no-op.
[ "$files" -gt 0 ] || exit 0

# Below the medium/large threshold -> silent no-op.
if [ "$files" -lt "$THRESHOLD_FILES" ] && [ "$lines" -lt "$THRESHOLD_LINES" ]; then
  exit 0
fi

# Fingerprint the full pending change (tracked diff + untracked file
# contents) so the same change isn't re-flagged on every Stop attempt.
diff_hash="$(
  {
    git -C "$PROJECT_DIR" diff HEAD
    if [ -n "$untracked_list" ]; then
      while IFS= read -r f; do
        [ -f "$PROJECT_DIR/$f" ] && { printf '%s\n' "$f"; cat "$PROJECT_DIR/$f"; }
      done <<< "$untracked_list"
    fi
  } | git -C "$PROJECT_DIR" hash-object --stdin 2>/dev/null || true
)"
[ -n "$diff_hash" ] || exit 0

last_hash=""
[ -f "$STATE_FILE" ] && last_hash="$(cat "$STATE_FILE")"

# Already asked about this exact change (not committed since) -> don't nag again.
if [ "$diff_hash" = "$last_hash" ]; then
  exit 0
fi

mkdir -p "$PROJECT_DIR/.noai-kit"
printf '%s' "$diff_hash" > "$STATE_FILE"

printf '{"decision": "block", "reason": "noai-kit auto-handoff: this session made a medium/large uncommitted change (~%s files, ~%s lines changed) that the continuity docs do not reflect yet. Run the handoff skill (/handoff) to refresh them, then finish."}\n' "$files" "$lines"

exit 0
