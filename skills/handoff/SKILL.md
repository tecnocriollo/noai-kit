---
name: handoff
description: This skill should be used when the user asks to "generate a handoff doc", "prepare continuity documentation", "leave everything documented in case the agent goes down", "prepare the project to continue without AI", or wants a snapshot a human can use to keep developing manually if AI coding agents (Claude Code, Codex, GitHub Copilot, Cursor, etc.) become unavailable.
version: 0.1.0
argument-hint: "[full|brief]"
---

# Handoff

Generate or update a `HANDOFF.md` file at the root of the target project,
with the information a person would need to keep developing manually if
AI coding agent services (Claude Code, Codex, GitHub Copilot, Cursor,
etc.) become unavailable.

## Detail level

Determine the level from the argument received:
- No argument, or `full`: complete document (the "Full" template below).
- `brief`: condensed version (the "Brief" template below).

## Steps

1. **Locate the target project root**: the first directory upward from
   the current working directory that contains `.git`. If there is none,
   use the current working directory and note that explicitly in the
   document.

2. **Collect deterministic context** by running
   `scripts/gather-context.sh <project-root>`. The script prints the
   current branch, recent commits, uncommitted changes, TODOs/FIXMEs,
   folder structure, and relevant content from manifests and existing
   documentation. If the script reports there is no `.git`, continue
   using only what can be inspected from the filesystem.

3. **Add context from the current session**: review the ongoing
   conversation and identify what was being worked on, what decisions
   were made and why, and what next steps were already discussed with
   the person. This part is not covered by the script — it comes
   exclusively from the session context.

4. **Write or update `HANDOFF.md`** at the root of the target project:
   - If the file doesn't exist, create it using the matching template
     (`full` or `brief`).
   - If it already exists, update it: refresh the sections that changed
     (current state, next steps) and keep decisions or historical
     context that's still valid instead of discarding it without cause.

5. **Do not invent information.** If something can't be determined from
   the script or the current session (for example, there's no `README`,
   no tests, or it's unclear how the project is deployed), say so
   explicitly in the relevant section instead of assuming.

6. When done, tell the person the path of the file written and a brief
   summary of which sections were updated.

## Template — `full` mode

```markdown
# Handoff — <project name>
_Generated: <ISO date> · Mode: full_

## What this project is
<what it does, who it's for, how mature it is>

## Current state
- Branch: <current branch>
- Recent commits: <short list>
- Uncommitted changes: <yes/no and detail>

## How to run the project
<install, build, test, run commands — sourced from manifests/README>

## Architecture and key structure
<main folders and their purpose>

## Work in progress and recent decisions
<what was being worked on in the last session, what was decided and why>

## Next steps
<TODOs from the code + what was discussed in session, in priority order>

## How to continue without an AI agent
<concrete steps: where to look first, key commands, checks to run>

## Information not available
<what couldn't be determined and why, if applicable>
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
