# noai-kit

Plugin de Claude Code con herramientas para seguir desarrollando sin
depender de un agente de IA cuando el servicio no está disponible.

## Estructura

- `.claude-plugin/plugin.json` — manifest del plugin.
- `skills/handoff/` — skill que genera `HANDOFF.md` en el proyecto objetivo.

## Historial de cambios

- **2026-09-08**: scaffold inicial del plugin y del skill `handoff`.
  Se definió como plugin de Claude Code (con vista a soportar otros agentes
  como Codex, Copilot y Cursor a futuro) porque el objetivo es que
  cualquier proyecto pueda generar su propia documentación de continuidad
  sin depender de que la IA siga disponible para explicarla.
