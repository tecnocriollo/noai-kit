---
name: handoff-auto
description: This skill should be used when the user asks to "enable auto handoff", "turn on automatic handoff", "run handoff automatically after big changes", "activa el auto handoff", "que se actualice solo cuando haga cambios grandes", or wants continuity docs refreshed automatically whenever the session makes a medium-to-large change, instead of on a fixed time interval.
version: 0.1.0
argument-hint: "<on|off|status>"
---

# Handoff Auto

Turn on/off/check a per-project, event-driven trigger that asks Claude to
run [`handoff`](../handoff/SKILL.md) right before the session stops,
whenever this session made a medium-to-large uncommitted change that the
continuity docs don't reflect yet. This is a third way to keep docs
fresh, alongside manual `/handoff` and time-based
[`handoff-schedule`](../handoff-schedule/SKILL.md) — event-based instead
of interval-based, so it only fires when there's actually something
worth documenting.

## How it works

A `Stop` hook bundled with this plugin (`hooks/auto-handoff-check.sh`)
runs every time a Claude Code session is about to stop. It's opt-in per
project: it checks for `.noai-kit/auto-handoff.json`
(`{"enabled": true}`) in the project root and does nothing at all if
that file isn't there — so installing this plugin has zero effect on
projects that haven't turned this on.

When enabled, on each `Stop` attempt the hook measures the uncommitted
diff (`git diff HEAD --shortstat`). If it's at or above **3 files or 80
changed lines** (whichever comes first — a fixed "medium/large" heuristic
for this version, not currently configurable), it blocks the stop and
tells Claude to run `/handoff` first. It tracks a hash of the diff it
already asked about, so it won't nag again for the same uncommitted
change on every subsequent stop attempt — only once per new diff.

**Important limitation — session restart required.** Claude Code loads
hooks at session start. Turning this on or off only takes effect the
*next* time the person starts a Claude Code session in that project —
never within the current one. Always say this explicitly when
toggling it, so the person doesn't wonder why nothing happened.

## Language

Talk to the person (confirmations, the report-back) in the primary
language they've been using in the conversation, same as `handoff` and
`handoff-schedule`.

## Steps

1. **Parse the argument**: `on`, `off`, or `status`. No argument — ask
   which one they want; do not guess.

2. **Locate the target project root** the same way `handoff` does: the
   first directory upward from the current working directory containing
   `.git` (fall back to the current working directory otherwise).

3. **Act on the argument**:
   - `on`: write `<project-root>/.noai-kit/auto-handoff.json` with
     `{"enabled": true}` (create the `.noai-kit/` directory if needed).
   - `off`: if `<project-root>/.noai-kit/auto-handoff.json` exists,
     rewrite it to `{"enabled": false}` (or delete it — either is fine,
     the hook treats "missing" and "enabled: false" the same way). Also
     fine to leave `.noai-kit/auto-handoff-state` alone; it's harmless
     once disabled.
   - `status`: report whether `.noai-kit/auto-handoff.json` exists and
     has `"enabled": true`.

4. **Report back**, and for `on`/`off` always include the session-restart
   caveat from "How it works" above — this is the single most important
   thing to communicate, since silently "not working yet" is confusing
   otherwise.

## Notes

- This only measures uncommitted changes (`git diff HEAD`). Committing
  resets what counts as "pending," which is the intended behavior — a
  commit is a natural checkpoint.
- If the project isn't a git repository, the hook silently does nothing
  even if enabled — there's no way to size a change without git.
- Scheduled runs from `handoff-schedule` are unaffected by this — they're
  independent triggers and can both be active on the same project at
  once without conflicting.
