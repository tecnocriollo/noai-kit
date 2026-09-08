# noai-kit

A Claude Code plugin with tools for continuing development without an AI
agent when the service is unavailable.

## Structure

- `.claude-plugin/plugin.json` — plugin manifest.
- `skills/handoff/` — skill that generates `HANDOFF.md` for the target
  project.

## Changelog

- **2026-09-08**: initial scaffold of the plugin and the `handoff` skill.
  It was set up as a Claude Code plugin (with an eye toward supporting
  other agents like Codex, Copilot, and Cursor later on), since the goal
  is for any project to be able to generate its own continuity
  documentation without depending on AI staying available to explain it.
