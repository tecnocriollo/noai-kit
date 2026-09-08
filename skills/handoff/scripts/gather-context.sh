#!/usr/bin/env bash
# Collects deterministic context from a project for the "handoff" skill.
# Usage: gather-context.sh [project-path]
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

section() {
  printf '\n## %s\n' "$1"
}

section "Directory"
pwd

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  section "Current branch"
  git branch --show-current || echo "(HEAD detached)"

  section "Recent commits"
  git log --oneline -15 2>/dev/null || echo "(no commits)"

  section "Uncommitted changes (git status --short)"
  status_out="$(git status --short)"
  if [ -z "$status_out" ]; then
    echo "(no pending changes)"
  else
    echo "$status_out"
  fi

  section "Diff summary (git diff --stat)"
  diff_out="$(git diff --stat)"
  if [ -z "$diff_out" ]; then
    echo "(no diffs against the working tree)"
  else
    echo "$diff_out"
  fi
else
  section "Git"
  echo "Not a git repository (nor any parent directory). Continuing with filesystem info only."
fi

section "TODO / FIXME / XXX in the code"
grep -rEn --exclude-dir={.git,node_modules,dist,build,vendor,.venv,venv,target} \
  'TODO|FIXME|XXX' . 2>/dev/null | head -50 || echo "(none found)"

section "Folder structure (2 levels)"
find . -maxdepth 2 -mindepth 1 \
  -not -path './.git*' -not -path './node_modules*' \
  | sort

for manifest in package.json pyproject.toml Cargo.toml go.mod Gemfile composer.json; do
  if [ -f "$manifest" ]; then
    section "Manifest: $manifest"
    cat "$manifest"
  fi
done

for doc in README.md README.MD readme.md CLAUDE.md; do
  if [ -f "$doc" ]; then
    section "Existing documentation: $doc"
    cat "$doc"
    break
  fi
done

if [ -f HANDOFF.md ]; then
  section "Existing HANDOFF.md"
  cat HANDOFF.md
fi
