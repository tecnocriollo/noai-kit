---
name: handoff
description: This skill should be used when the user asks to "generate a handoff doc", "prepare continuity documentation", "leave everything documented in case the agent goes down", "prepare the project to continue without AI", or wants a snapshot a human can use to keep developing manually if AI coding agents (Claude Code, Codex, GitHub Copilot, Cursor, etc.) become unavailable.
version: 0.2.0
argument-hint: "[full|brief]"
---

# Handoff

Generate or update continuity documentation at the root of the target
project, with the information a person would need to keep developing
manually if AI coding agent services (Claude Code, Codex, GitHub Copilot,
Cursor, etc.) become unavailable.

## Detail level

Determine the level from the argument received:
- No argument, or `full`: a full `handoff/` documentation folder (several
  linked files — see below).
- `brief`: a single condensed `HANDOFF.md` file at the project root (the
  "Brief" template below). No folder, no submodule offer.

## Language

Write all generated docs, and anything said to the person (including the
offers below), in the primary language the person has been using in the
conversation. Do not default to English just because this skill's own
instructions are written in English — that's purely for the plugin's
maintainability. If the conversation has mixed languages or the language
isn't clear, default to English.

## Steps

1. **Locate the target project root**: the first directory upward from
   the current working directory that contains `.git`. If there is none,
   use the current working directory and note that explicitly in the
   docs.

2. **Collect deterministic context** by running
   `scripts/gather-context.sh <project-root>`. The script prints the
   current branch, recent commits, uncommitted changes, TODO/FIXME/BUG/
   HACK markers, git submodules (if any), folder structure, relevant
   manifest content, existing README/CLAUDE.md, and the content of any
   previous `HANDOFF.md` or `handoff/` folder (so updates can reuse what's
   still valid). If the script reports there is no `.git`, continue using
   only what can be inspected from the filesystem.

3. **Add context from the current session**: review the ongoing
   conversation and identify what was being worked on, what decisions
   were made and why, and what next steps were already discussed with the
   person. This part is not covered by the script — it comes exclusively
   from the session context.

4. **Optionally check for tracked issues**: if `gh` is available and the
   project has a GitHub remote, a best-effort `gh issue list --state open
   --limit 20` can enrich `known-issues.md`. This is optional — skip it
   silently if `gh` isn't set up, isn't authenticated, or the project
   isn't on GitHub. Never fail the whole skill run over this.

5. **Write the docs** for the requested detail level:

   - **`brief`**: write or update a single `HANDOFF.md` at the project
     root using the Brief template below. If it already exists, refresh
     it in place.

   - **`full`**: write or update the `handoff/` folder (templates below,
     one file each). If `handoff/` doesn't exist yet:
     - If a legacy single-file `HANDOFF.md` exists at the root, use its
       content as a starting point for the new files (don't discard
       still-valid information), then replace `HANDOFF.md` with a short
       stub: a one-line note that the docs moved to `handoff/README.md`,
       with a link. Do not delete the file — just shrink it to a pointer,
       so anything that referenced it (bookmarks, `handoff-schedule`
       logs) still finds something useful.
     - Otherwise, create `handoff/` fresh.
     If `handoff/` already exists, update each file in place: refresh
     what changed (`state.md` and `backlog.md` change almost every run;
     `architecture.md`, `dependencies.md`, and `where-to-start.md` change
     rarely — don't rewrite them from scratch if nothing relevant
     changed) and keep historical context that's still valid instead of
     discarding it without cause.

6. **Do not invent information.** If something can't be determined from
   the script, the session, or (optionally) `gh issue list` — for example
   there's no `README`, no tests, or it's unclear how the project is
   deployed — say so explicitly in the relevant file instead of assuming.

7. **Skip offers when running non-interactively.** If there's no person
   available to answer a question right now — for example this run was
   triggered headlessly by `handoff-schedule` via `claude -p "/handoff"` —
   skip steps 8 and 9 entirely: just write/update the docs and finish
   without asking anything.

8. **First-time offer.** If no continuity docs existed before this run
   (neither `HANDOFF.md` nor `handoff/`), ask the person whether they want
   the docs to stay fresh automatically from now on, or prefer to keep
   running `/handoff` on demand. Offer it as an explicit choice, don't set
   anything up on your own:
   - **Schedule it**: hand off to the
     [`handoff-schedule`](../handoff-schedule/SKILL.md) skill with the
     interval they pick (e.g. every 30 minutes, hourly, daily).
   - **On demand**: do nothing further — running `/handoff` manually
     whenever they want is a completely valid way to use this skill.
   Skip this offer on every run after the first.

9. **Submodule offer** (`full` mode only). If `scripts/gather-context.sh`
   reported one or more git submodules, ask the person whether they also
   want a `handoff/` folder generated inside each one (they can pick all,
   some, or none). If they opt in for a submodule, repeat steps 1-6
   scoped to that submodule's own directory (it has its own `.git`, so
   treat it as its own project root) — one level deep only, don't
   auto-recurse into sub-submodules. Link each generated submodule
   handoff from the parent's `handoff/README.md` (see template).

10. When done, tell the person what was written (the file path for
    `brief`, or the list of files under `handoff/` for `full`) and a
    brief summary of what changed.

## Templates — `full` mode (`handoff/` folder)

### `handoff/README.md` — quickstart / entry point

```markdown
# Handoff — <project name>
_Generated: <ISO date>_

<one paragraph: what this project is, who it's for, how mature it is>

## Start here

- [architecture.md](./architecture.md) — structure and key design decisions
- [dependencies.md](./dependencies.md) — how to install and run
- [where-to-start.md](./where-to-start.md) — entry points and how to make your first change
- [backlog.md](./backlog.md) — what's next, in priority order
- [known-issues.md](./known-issues.md) — known bugs and limitations
- [state.md](./state.md) — current git state (branch, commits, pending changes)

## At a glance
- Branch: <current branch>
- Last commit: <short sha + subject>
- Uncommitted changes: <yes/no>

## Submodules
<if any were found: one bullet per submodule, path + whether a handoff/
was generated for it (with a relative link) or the person chose not to;
omit this section entirely if there are no submodules>
```

### `handoff/architecture.md`

```markdown
# Architecture — <project name>

## Key folders and modules
<main folders and what lives in each>

## How the pieces fit together
<data flow / request flow / build pipeline, whatever applies>

## Notable design decisions
<why things are structured this way, sourced from docs/commit history/session — not invented>
```

### `handoff/dependencies.md`

```markdown
# Dependencies — <project name>

## Runtime dependencies
<key libraries/services this project depends on to run>

## Development dependencies and setup
<install commands, required tool versions, system-level deps (e.g. a
binary that must be installed separately)>

## How to run it
<install / build / test / run commands, sourced from manifests and README>
```

### `handoff/known-issues.md`

```markdown
# Known issues — <project name>

<bugs/limitations found in code comments (BUG/HACK/XXX), existing docs,
or open GitHub issues if `gh` was available. If none were found, say so
explicitly instead of implying there are none — "no known issues were
found in the code or docs" is different from "there are no bugs".>
```

### `handoff/backlog.md`

```markdown
# Backlog — <project name>

<TODOs/FIXMEs from the code, plus next steps discussed in the current
session, in priority order. State explicitly if nothing was found.>
```

### `handoff/where-to-start.md`

```markdown
# Where to start — <project name>

## Entry points
<the files/modules to look at first depending on what you're changing>

## Suggested first task
<a small, concrete task to get oriented, if one is obvious from the backlog>

## How to validate a change
<tests, build, linting — whatever this project actually has>
```

### `handoff/state.md`

```markdown
# State — <project name>
_Generated: <ISO date>_

- Branch: <current branch>
- Recent commits: <short list>
- Uncommitted changes: <yes/no and detail>
- Diff summary: <from git diff --stat, if relevant>
```

## Template — `brief` mode

```markdown
# Brief handoff — <project name>
_Generated: <ISO date> · Mode: brief_

## Current state
<branch, latest commit, pending changes>

## Next steps
<short list>

## Essential commands
<install / build / test / run>
```
