# noai-kit

> It's 2 a.m. You are building the product that will change the world.
> One feature stands between you and launch. Just one.
>
> Then Claude goes down. **Service disruption.** You refresh. Still down.
>
> You switch to Codex. *"You've hit your usage limit."* Of course you have.
>
> You open Cursor as a last resort. It spins. It stalls. It dies.
>
> Silence. Just you, a blinking cursor, and thousands of lines of code
> you've never truly had to read on your own — because something else
> always read them for you.
>
> You know how to code. That was never the question. The question is
> whether you can find your way through *this* codebase, *tonight*,
> with no guide and no map, before the deadline swallows you whole.
>
> You take a breath. And then you remember — you saw a repo for
> something like this once...
>
> **noai-kit is here to save you. 🔦**

A toolkit for continuing development without an AI coding agent when the
service is unavailable (outage, network issue, usage limit reached, etc.).
It starts as a plugin for [Claude Code](https://claude.com/claude-code);
the goal is to keep its skills generic enough to later adapt to other
tools (Codex, GitHub Copilot, Cursor, ...).

## What it includes today

- **`handoff`** — generates or updates a `HANDOFF.md` file at the root of
  your project with everything a person needs to keep working by hand:
  current state (branch, commits, pending changes), how to run the
  project, architecture, recent decisions, and next steps. Invoked with
  `/handoff` (or `/handoff brief` for a condensed version).
- **`handoff-schedule`** — keeps `HANDOFF.md` fresh on its own, by
  installing a local cron entry that runs `handoff` automatically every
  30 minutes, hourly, daily, or on a custom cadence. Invoked with
  `/handoff-schedule 30m`, `/handoff-schedule 1h`, `/handoff-schedule
  daily`, `/handoff-schedule status`, or `/handoff-schedule stop`.

## Installing in Claude Code

This repo is its own marketplace, so you can add it straight from GitHub:

```
/plugin marketplace add tecnocriollo/noai-kit
/plugin install noai-kit
```

For local development, point at your working copy instead:

```
/plugin marketplace add /path/to/noai-kit
/plugin install noai-kit
```

## Roadmap

- Adapt `handoff` (or an equivalent) for Codex, GitHub Copilot, and
  Cursor.
- Add more skills focused on continuing without AI (e.g. manual
  troubleshooting checklists, runbook generation).
- Support scheduling backends beyond local cron (e.g. GitHub Actions,
  systemd timers, Windows Task Scheduler) for `handoff-schedule`.

## License

MIT — see [LICENSE](./LICENSE).
