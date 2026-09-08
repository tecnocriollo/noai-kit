#!/usr/bin/env bash
# Recolecta contexto determinístico de un proyecto para el skill "handoff".
# Uso: gather-context.sh [ruta-del-proyecto]
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

section() {
  printf '\n## %s\n' "$1"
}

section "Directorio"
pwd

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  section "Branch actual"
  git branch --show-current || echo "(HEAD detached)"

  section "Últimos commits"
  git log --oneline -15 2>/dev/null || echo "(sin commits)"

  section "Cambios sin commitear (git status --short)"
  status_out="$(git status --short)"
  if [ -z "$status_out" ]; then
    echo "(sin cambios pendientes)"
  else
    echo "$status_out"
  fi

  section "Resumen de diff (git diff --stat)"
  diff_out="$(git diff --stat)"
  if [ -z "$diff_out" ]; then
    echo "(sin diffs contra el working tree)"
  else
    echo "$diff_out"
  fi
else
  section "Git"
  echo "No es un repositorio git (o ningún padre lo es). Se continúa solo con el filesystem."
fi

section "TODO / FIXME / XXX en el código"
grep -rEn --exclude-dir={.git,node_modules,dist,build,vendor,.venv,venv,target} \
  'TODO|FIXME|XXX' . 2>/dev/null | head -50 || echo "(ninguno encontrado)"

section "Estructura de carpetas (2 niveles)"
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
    section "Documentación existente: $doc"
    cat "$doc"
    break
  fi
done

if [ -f HANDOFF.md ]; then
  section "HANDOFF.md existente"
  cat HANDOFF.md
fi
