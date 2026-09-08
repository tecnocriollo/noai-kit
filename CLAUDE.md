# noai-kit

A Claude Code plugin with tools for continuing development without an AI
agent when the service is unavailable.

## Structure

- `.claude-plugin/plugin.json` — plugin manifest.
- `.claude-plugin/marketplace.json` — self-hosted marketplace listing (this
  repo lists itself as its only plugin, source `.`).
- `skills/handoff/` — skill that generates `HANDOFF.md` for the target
  project.
- `skills/handoff-schedule/` — skill that installs/removes a local cron
  entry to run `handoff` automatically on an interval.

## Changelog

- **2026-09-08**: initial scaffold of the plugin and the `handoff` skill.
  It was set up as a Claude Code plugin (with an eye toward supporting
  other agents like Codex, Copilot, and Cursor later on), since the goal
  is for any project to be able to generate its own continuity
  documentation without depending on AI staying available to explain it.
- **2026-09-08**: added `handoff-schedule`, so `HANDOFF.md` can refresh
  automatically (every 30 min, hourly, daily, ...) instead of relying on
  someone remembering to run `/handoff` before an outage actually hits.
  It drives a local `crontab` entry that calls `claude -p "/handoff"`
  headlessly, since that works today without depending on any
  Claude-specific cloud scheduling infrastructure.
- **2026-09-08**: `handoff` now offers scheduling on its first run for a
  project (schedule via `handoff-schedule`, or stay on-demand) instead of
  requiring people to discover `handoff-schedule` on their own. It only
  asks once — after `HANDOFF.md` exists, the choice is assumed made.
- **2026-09-08**: added `.claude-plugin/marketplace.json` so the repo is
  self-hosted (lists itself as its only plugin) — this lets people install
  it with `/plugin marketplace add tecnocriollo/noai-kit` directly from
  GitHub instead of only via a local path, without needing a separate
  marketplace repo for a single plugin.
