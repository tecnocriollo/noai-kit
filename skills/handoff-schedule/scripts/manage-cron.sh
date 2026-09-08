#!/usr/bin/env bash
# Manages a local crontab entry that runs the "handoff" skill on a schedule,
# via a headless Claude Code invocation (`claude -p "/handoff"`).
#
# Usage:
#   manage-cron.sh install <interval> <project-root> [claude-bin]
#   manage-cron.sh status  <project-root>
#   manage-cron.sh uninstall <project-root>
#
# <interval>: "<N>m" (every N minutes, 1-59), "<N>h" (every N hours, 1-23),
#             or "daily" (09:00 local time).
#
# Requires a Unix-style crontab (Linux/macOS, or WSL on Windows) and the
# `claude` CLI on PATH (or passed explicitly as [claude-bin]).
set -euo pipefail

ACTION="${1:-}"
MARKER_PREFIX="# noai-kit-handoff:"

usage() {
  cat >&2 <<'EOF'
Usage:
  manage-cron.sh install <interval> <project-root> [claude-bin]
  manage-cron.sh status  <project-root>
  manage-cron.sh uninstall <project-root>
EOF
  exit 1
}

require_crontab() {
  command -v crontab >/dev/null 2>&1 || {
    echo "error: 'crontab' not found. This script needs a Unix-style cron (Linux/macOS, or WSL on Windows)." >&2
    exit 1
  }
}

cron_expr_for_interval() {
  local interval="$1"
  case "$interval" in
    daily)
      echo "0 9 * * *"
      ;;
    *m)
      local n="${interval%m}"
      [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le 59 ] || {
        echo "error: minute interval must be between 1 and 59 (got '$interval')" >&2
        exit 1
      }
      echo "*/${n} * * * *"
      ;;
    *h)
      local n="${interval%h}"
      [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le 23 ] || {
        echo "error: hour interval must be between 1 and 23 (got '$interval')" >&2
        exit 1
      }
      echo "0 */${n} * * *"
      ;;
    *)
      echo "error: unrecognized interval '$interval' (expected <N>m, <N>h, or daily)" >&2
      exit 1
      ;;
  esac
}

case "$ACTION" in
  install)
    INTERVAL="${2:?missing <interval>}"
    PROJECT_ROOT="${3:?missing <project-root>}"
    CLAUDE_BIN="${4:-claude}"
    require_crontab

    PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
    command -v "$CLAUDE_BIN" >/dev/null 2>&1 || {
      echo "warning: '$CLAUDE_BIN' not found on PATH right now. The cron job will still be installed, but will fail to run until it is available." >&2
    }

    CRON_EXPR="$(cron_expr_for_interval "$INTERVAL")"
    MARKER="${MARKER_PREFIX}${PROJECT_ROOT}"
    mkdir -p "$PROJECT_ROOT/.noai-kit"
    LOG_FILE="$PROJECT_ROOT/.noai-kit/handoff-schedule.log"

    CRON_LINE="${CRON_EXPR} cd '${PROJECT_ROOT}' && '${CLAUDE_BIN}' -p '/handoff' >> '${LOG_FILE}' 2>&1 ${MARKER}"

    EXISTING="$(crontab -l 2>/dev/null || true)"
    FILTERED="$(printf '%s\n' "$EXISTING" | grep -vF "$MARKER" || true)"
    NEW_CRONTAB="$(printf '%s\n%s\n' "$FILTERED" "$CRON_LINE" | sed '/^$/d')"

    printf '%s\n' "$NEW_CRONTAB" | crontab -
    echo "Installed: handoff will run '${INTERVAL}' for ${PROJECT_ROOT}"
    echo "Cron expression: ${CRON_EXPR}"
    echo "Logs: ${LOG_FILE}"
    ;;

  status)
    PROJECT_ROOT="${2:?missing <project-root>}"
    require_crontab
    PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
    MARKER="${MARKER_PREFIX}${PROJECT_ROOT}"
    LINE="$(crontab -l 2>/dev/null | grep -F "$MARKER" || true)"
    if [ -z "$LINE" ]; then
      echo "No scheduled handoff for ${PROJECT_ROOT}."
    else
      echo "Scheduled handoff for ${PROJECT_ROOT}:"
      echo "$LINE"
    fi
    ;;

  uninstall)
    PROJECT_ROOT="${2:?missing <project-root>}"
    require_crontab
    PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
    MARKER="${MARKER_PREFIX}${PROJECT_ROOT}"
    EXISTING="$(crontab -l 2>/dev/null || true)"
    if ! printf '%s\n' "$EXISTING" | grep -qF "$MARKER"; then
      echo "No scheduled handoff found for ${PROJECT_ROOT}."
      exit 0
    fi
    FILTERED="$(printf '%s\n' "$EXISTING" | grep -vF "$MARKER" || true)"
    printf '%s\n' "$FILTERED" | sed '/^$/d' | crontab -
    echo "Removed scheduled handoff for ${PROJECT_ROOT}."
    ;;

  *)
    usage
    ;;
esac
