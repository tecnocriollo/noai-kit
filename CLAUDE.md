# noai-kit

A Claude Code plugin with tools for continuing development without an AI
agent when the service is unavailable.

## Structure

- `.claude-plugin/plugin.json` — plugin manifest.
- `.claude-plugin/marketplace.json` — self-hosted marketplace listing (this
  repo lists itself as its only plugin, source `.`).
- `skills/handoff/` — skill that generates a `handoff/` documentation
  folder (or a single `HANDOFF.md` in `brief` mode) for the target
  project.
- `skills/handoff-schedule/` — skill that installs/removes a local cron
  entry to run `handoff` automatically on an interval.
- `skills/handoff-auto/` — skill that toggles a per-project flag file to
  enable/disable the event-based auto-handoff hook.
- `hooks/hooks.json`, `hooks/auto-handoff-check.sh` — plugin-level `Stop`
  hook that triggers `handoff` after a medium/large uncommitted change,
  opt-in per project via `.noai-kit/auto-handoff.json`.

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
- **2026-09-08**: `handoff`'s `full` mode now writes a `handoff/` folder
  (README quickstart + architecture/dependencies/known-issues/backlog/
  where-to-start/state, each its own file) instead of one `HANDOFF.md`,
  after testing the old single-file output against `tecnocriollo-showcase`
  and finding it too thin to be genuinely useful. `brief` mode is
  unchanged. Also added: migration from a legacy `HANDOFF.md` to a stub
  pointer, an offer to generate the same folder inside git submodules
  (detected via `.gitmodules`/`git submodule status` in
  `gather-context.sh`), and skipping all interactive offers when running
  headlessly (so `handoff-schedule`'s `claude -p "/handoff"` runs don't
  block on unanswerable questions).
- **2026-09-08**: `handoff/README.md` now includes a Quickstart section
  (install + run, condensed from `dependencies.md`) right in the entry
  point, found missing after re-testing against `tecnocriollo-showcase` —
  landing on the quickstart file and having to click into another file
  just to start the project defeated the point of a quickstart.
- **2026-09-08**: added `handoff-auto`, a third (event-based) way to
  trigger `handoff`, alongside manual and `handoff-schedule` (time-based).
  A bundled plugin `Stop` hook (`hooks/hooks.json` +
  `hooks/auto-handoff-check.sh`) blocks the session from stopping after a
  medium/large uncommitted change (≥3 files or ≥80 lines, measured via
  `git diff HEAD` plus untracked files since new files don't show up in
  `git diff HEAD` at all) and asks Claude to run `/handoff` first. Opt-in
  per project via `.noai-kit/auto-handoff.json`, so installing the plugin
  has no effect until a project turns it on — and toggling it requires a
  session restart, since Claude Code only loads hooks at session start.
  Caught and fixed during testing: the hook's own state/flag files under
  `.noai-kit/` were being counted as part of the "uncommitted change"
  they measure, which retriggered on every single `Stop` attempt forever
  — now explicitly excluded.
