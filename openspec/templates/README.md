# OpenSpec Templates (SmartFI)

Este directorio contiene plantillas base para crear nuevos changes de OpenSpec con las convenciones del proyecto.

## Uso rápido

1. Crear un nuevo change en `openspec/changes/<change-name>/`.
2. Copiar los archivos desde `openspec/templates/change-template/`:
   - `proposal.md`
   - `design.md`
   - `tasks.md`
3. Completar los placeholders.
4. Asegurar trazabilidad en `tasks.md` con formato Gitea: `[#id]`.

## Reglas importantes

- Todo cambio de base de datos debe usar Alembic.
- Si una migración falla o aparecen heads en conflicto, detener implementación, documentar el conflicto en tasks.md y resolver antes de continuar.
- `design.md` debe incluir módulos afectados, modelo de datos, contrato API y seguridad.
- `proposal.md` debe incluir Why, What Changes, Capabilities e Impact.
- `tasks.md` debe agrupar por Backend, Frontend y Testing.
- `tasks.md` debe usar estado explícito por tarea cuando hay avance parcial (por ejemplo: [done], [in-progress]).

## Sugerencia de naming

- `feature/<change-name>` para cambios funcionales
- `bugfix/<gitea-issue-id>` para correcciones
- `hotfix/<gitea-issue-id>` para urgencias
