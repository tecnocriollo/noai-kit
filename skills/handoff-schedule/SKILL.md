---
name: handoff-schedule
description: This skill should be used when the user asks to "schedule handoff", "run handoff every 30 minutes", "keep HANDOFF.md updated automatically", "set up automatic continuity docs", "programa handoff cada hora", or wants `HANDOFF.md` to refresh on a recurring interval without invoking the `handoff` skill by hand each time.
version: 0.1.0
argument-hint: "<30m|1h|6h|daily|status|stop>"
---

# Handoff Schedule

Set up, check, or remove a recurring local schedule that runs the
[`handoff`](../handoff/SKILL.md) skill automatically, so `HANDOFF.md` stays
fresh even if nobody remembers to run `/handoff` by hand.

## How it works

This skill installs a standard Unix `crontab` entry (Linux, macOS, or WSL
on Windows) that invokes Claude Code headlessly:

```
claude -p "/handoff"
```

for the target project, on the requested interval. Output is appended to
`.noai-kit/handoff-schedule.log` inside the project.

**Important limitation**: a scheduled run has no access to the interactive
session that a manual `/handoff` would have, so it cannot pull in
"decisions made in this conversation." It still refreshes everything
`handoff` derives from git and the code itself (branch, commits, pending
changes, TODOs, structure) — which is exactly the part most likely to go
stale between sessions. Encourage running `/handoff` by hand too, right
before closing a session, to capture the conversational context the
scheduled runs can't see.

## Steps

1. **Parse the argument**:
   - `<N>m` (e.g. `30m`) — every N minutes (1-59).
   - `<N>h` (e.g. `1h`, `6h`) — every N hours (1-23).
   - `daily` — once a day at 09:00 local time.
   - `status` — report whether a schedule is currently installed.
   - `stop` — remove the schedule.
   - No argument — ask the user what interval they want; do not guess.

2. **Locate the target project root** the same way `handoff` does: the
   first directory upward from the current working directory containing
   `.git` (fall back to the current working directory otherwise).

3. **Check prerequisites**: confirm `crontab` and `claude` are available
   (`command -v crontab`, `command -v claude`). If `crontab` is missing
   (common on plain Windows without WSL), explain that this skill needs a
   Unix-style cron and suggest either using WSL, or scheduling `claude -p
   "/handoff"` manually via Windows Task Scheduler / macOS `launchd` /
   systemd timers as an equivalent. Do not attempt to configure those
   directly — only `crontab` is automated here.

4. **Run the bundled script** to do the actual work:
   - Install/update: `scripts/manage-cron.sh install <interval> <project-root>`
   - Status: `scripts/manage-cron.sh status <project-root>`
   - Remove: `scripts/manage-cron.sh uninstall <project-root>`

   Installing again with a different interval replaces the previous
   schedule for that project — it does not stack multiple cron entries.

5. **Report back** the exact cron expression installed, the log file
   location, and remind the user recurring runs will overwrite/update
   `HANDOFF.md` on their own — they should expect to see periodic commits
   or diffs to that file if it's version-controlled.

## Notes

- One project can have at most one active schedule; installing again
  overwrites it (matched by project path, not by interval).
- This skill only manages cron entries created by itself (tagged with a
  `# noai-kit-handoff:<project-root>` marker) — it never touches unrelated
  crontab entries.
- Scheduled runs consume the same Claude Code usage/tokens as a manual
  `/handoff` — pick an interval that makes sense for the project's pace of
  change, not the shortest one available.
