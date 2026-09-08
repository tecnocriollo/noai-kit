# noai-kit

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

## Installing in Claude Code

As a local plugin, while it isn't published to a marketplace yet:

```
/plugin marketplace add /path/to/noai-kit
/plugin install noai-kit
```

Or add the repo directly as the plugin source once it's published on
GitHub.

## Roadmap

- Adapt `handoff` (or an equivalent) for Codex, GitHub Copilot, and
  Cursor.
- Add more skills focused on continuing without AI (e.g. manual
  troubleshooting checklists, runbook generation).

## License

MIT — see [LICENSE](./LICENSE).
