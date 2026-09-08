# noai-kit

Kit de herramientas para seguir desarrollando sin depender de un agente de
IA cuando el servicio no está disponible (caída, corte de red, límite de
uso agotado, etc.). Empieza como plugin de [Claude
Code](https://claude.com/claude-code); la idea es que los skills que trae
sean lo bastante genéricos como para adaptarse después a otras
herramientas (Codex, GitHub Copilot, Cursor, ...).

## Qué trae hoy

- **`handoff`** — genera o actualiza un `HANDOFF.md` en la raíz de tu
  proyecto con todo lo que una persona necesita para seguir trabajando a
  mano: estado actual (rama, commits, cambios pendientes), cómo levantar el
  proyecto, arquitectura, decisiones recientes y próximos pasos. Se invoca
  con `/handoff` (opcionalmente `/handoff brief` para una versión resumida).

## Instalación en Claude Code

Como plugin local, mientras no esté publicado en un marketplace:

```
/plugin marketplace add /ruta/a/noai-kit
/plugin install noai-kit
```

O agregando el repo directamente como fuente del plugin una vez publicado
en GitHub.

## Roadmap

- Adaptar `handoff` (o una versión equivalente) para Codex, GitHub Copilot
  y Cursor.
- Sumar más skills orientados a continuidad sin IA (por ejemplo, checklists
  de troubleshooting manual, generación de runbooks).

## Licencia

MIT — ver [LICENSE](./LICENSE).
