---
name: handoff
description: This skill should be used when the user asks to "generate a handoff doc", "prepare continuity documentation", "genera documentación de continuidad", "dejá todo documentado por si se cae el agente", "prepará el proyecto para seguir sin IA", or wants a snapshot a human can use to keep developing manually if AI coding agents (Claude Code, Codex, GitHub Copilot, Cursor, etc.) become unavailable.
version: 0.1.0
argument-hint: "[full|brief]"
---

# Handoff

Generar o actualizar un archivo `HANDOFF.md` en la raíz del proyecto
objetivo, con la información que una persona necesitaría para seguir
desarrollando manualmente si los servicios de agentes de código (Claude
Code, Codex, GitHub Copilot, Cursor, etc.) dejan de estar disponibles.

## Nivel de detalle

Determinar el nivel a partir del argumento recibido:
- Sin argumento, o `full`: documento completo (plantilla "Full" abajo).
- `brief`: versión resumida (plantilla "Brief" abajo).

## Pasos

1. **Ubicar la raíz del proyecto objetivo**: el primer directorio hacia
   arriba desde el directorio de trabajo actual que contenga `.git`. Si no
   hay ninguno, usar el directorio de trabajo actual y aclararlo en el
   documento.

2. **Recolectar contexto determinístico** corriendo
   `scripts/gather-context.sh <raíz-del-proyecto>`. El script imprime rama
   actual, últimos commits, cambios sin commitear, TODOs/FIXMEs, estructura
   de carpetas, y contenido relevante de manifests y documentación
   existente. Si el script informa que no hay `.git`, seguir solo con lo
   que se pueda inspeccionar del filesystem.

3. **Sumar contexto de la sesión actual**: repasar la conversación en curso
   e identificar qué se estaba haciendo, qué decisiones se tomaron y por
   qué, y qué próximos pasos ya se discutieron con la persona. Esta parte
   no la cubre el script — sale exclusivamente del contexto de la sesión.

4. **Escribir o actualizar `HANDOFF.md`** en la raíz del proyecto objetivo:
   - Si el archivo no existe, crearlo con la plantilla correspondiente
     (`full` o `brief`).
   - Si ya existe, actualizarlo: refrescar las secciones que cambiaron
     (estado actual, próximos pasos) y conservar decisiones o contexto
     histórico que siga siendo válido en vez de descartarlo sin criterio.

5. **No inventar información.** Si algo no se puede determinar con el
   script o con la sesión actual (por ejemplo, no hay `README`, no hay
   tests, no está claro cómo se despliega), decirlo explícitamente en el
   documento en la sección correspondiente en vez de asumir.

6. Al terminar, indicar a la persona la ruta del archivo escrito y un
   resumen breve de qué secciones se actualizaron.

## Plantilla — modo `full`

```markdown
# Handoff — <nombre del proyecto>
_Generado: <fecha ISO> · Modo: full_

## Qué es este proyecto
<qué hace, para quién, en qué estado de madurez está>

## Estado actual
- Branch: <rama actual>
- Últimos commits: <lista breve>
- Cambios sin commitear: <sí/no y detalle>

## Cómo levantar el proyecto
<comandos de instalación, build, test, run — sacados de manifests/README>

## Arquitectura y estructura clave
<carpetas principales y su propósito>

## Trabajo en curso y decisiones recientes
<qué se estaba haciendo en la última sesión, qué se decidió y por qué>

## Próximos pasos
<TODOs del código + lo discutido en sesión, en orden de prioridad>

## Cómo seguir sin un agente de IA
<pasos concretos: dónde mirar primero, comandos clave, checks a correr>

## Información no disponible
<qué no se pudo determinar y por qué, si aplica>
```

## Plantilla — modo `brief`

```markdown
# Handoff breve — <nombre del proyecto>
_Generado: <fecha ISO> · Modo: brief_

## Estado actual
<rama, último commit, cambios pendientes>

## Próximos pasos
<lista corta>

## Comandos esenciales
<install / build / test / run>
```
