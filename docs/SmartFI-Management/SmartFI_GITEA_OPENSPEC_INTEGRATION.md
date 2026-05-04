# Contexto

Este repositorio usa **OpenSpec** como fuente de verdad para especificaciones funcionales y **Gitea** como sistema único de gestión de tareas (issues, milestones, PRs). GitHub actúa exclusivamente como hosting remoto del repositorio (push/pull), **no** se usa para gestión de tareas ni PRs.

Referencias:

- [SmartFI_DOC_NAMMING](SmartFI_DOC_NAMMING.md)

---

# Roles de cada sistema

| Sistema | Rol | No usar para |
|---|---|---|
| **Gitea** | Issues, milestones, PRs, labels, trazabilidad de ejecución | Especificación funcional |
| **OpenSpec** | Propuesta, diseño, specs estructuradas, criterios de aceptación | Tracking de tareas operativas |
| **GitHub** | Hosting remoto del repo (push/pull) | Issues, PRs, gestión de tareas |
| **Git branches** | Aislamiento de cambios por feature/bug | — |

---

# Flujo completo de desarrollo

```
[1] IDEA / BUG
      │
      ▼
[2] Gitea Issue (captura cruda)
      │  título + descripción mínima
      │  label: idea | bug | feature
      ▼
[3] openspec-explore  ← pensar, explorar, clarificar
      │  resultado: contexto, preguntas respondidas, alcance claro
      ▼
[4] openspec-propose  ← generar artefactos
      │  genera: proposal.md, design.md, tasks.md, specs/
      │  actualiza: .openspec.yaml (status: proposed)
      ▼
[5] Gitea Milestone + Sub-issues
      │  1 change OpenSpec = 1 Milestone en Gitea
      │  1 tarea de tasks.md = 1 Issue en Gitea (reemplaza checkboxes)
      │  Issue padre referencia: openspec/changes/<name>/
      ▼
[6] Git branch
      │  feature/<change-name> o bugfix/<gitea-issue-id>
      │  .openspec.yaml: status → in-progress
      ▼
[7] Implementación
      │  commits referencian: closes #<issue-id> o refs #<issue-id>
      │  sub-issues se cierran al completar cada tarea
      ▼
[8] Testing
      │  sub-issues de testing se cierran al pasar tests
      ▼
[9] openspec-archive-change  ← cerrar spec
      │  .openspec.yaml: status → done
      │  milestone Gitea: closed
      ▼
[10] Pull Request en Gitea
      │  referencia: milestone, issue padre, branch
      │  descripción: link a openspec/changes/<name>/proposal.md
      ▼
[11] Review + Merge → main
      │
      ▼
[12] Deploy
```

---

# Estructura OpenSpec por change

```
openspec/changes/<change-name>/
├── .openspec.yaml     ← estado y metadatos (incluye gitea_issue)
├── proposal.md        ← por qué, qué cambia, impacto
├── design.md          ← decisiones técnicas, arquitectura
├── specs/             ← criterios de aceptación estructurados
│   └── <spec>.md
└── tasks.md           ← referencia a issues de Gitea (no checkboxes)
```

## `.openspec.yaml` — campos requeridos

```yaml
schema: spec-driven
created: YYYY-MM-DD
status: proposed | in-progress | done
gitea_milestone: <id-o-nombre-del-milestone>
gitea_issue: <id-del-issue-padre>
branch: feature/<change-name>
```

## `tasks.md` — formato con Gitea (sin checkboxes)

En lugar de checkboxes, cada tarea referencia su issue de Gitea:

```markdown
## Backend

- [#12] Crear migración Alembic para tabla `monthly_periods`
- [#13] Crear modelos SQLAlchemy `MonthlyPeriod`
- [#14] Implementar endpoint `POST /months/{year_month}/close`

## Frontend

- [#15] Crear componente `MonthStatusBadge`
- [#16] Integrar badge en selector de mes

## Testing

- [#17] Tests unitarios `close_month()` y `reopen_month()`
- [#18] Test end-to-end: cerrar → intentar editar → reabrir
```

El estado de cada tarea se gestiona **exclusivamente** en Gitea (open/closed), no con checkboxes en markdown.

---

# Estrategia de ramas

Trunk-Based simplificado (solo developer):

```
main
├── feature/<change-name>     ← 1 feature = 1 branch
├── bugfix/<gitea-issue-id>   ← bugs desde issue
└── hotfix/<gitea-issue-id>   ← fix urgente sobre main
```

## Reglas

- **main**: siempre estable y deployable. No commitear directo.
- **feature/**: vida corta, merge rápido. 1 feature por rama.
- **bugfix/**: correcciones normales, referencia obligatoria al issue.
- **hotfix/**: fix urgente sobre main, PR inmediato.

## Ejemplos de naming

```
feature/exp-month-close
feature/cc-period-policy
bugfix/42
hotfix/55
```

---

# Formato de commits

```
[SPEC:<change-name>] descripción corta

refs #<gitea-issue-id>
```

o al cerrar una tarea:

```
[SPEC:<change-name>] descripción corta

closes #<gitea-issue-id>
```

Ejemplos:

```
[SPEC:exp-month-close] add MonthlyPeriod model and migration

closes #12
```

```
[SPEC:exp-month-close] implement close_month endpoint with snapshot

closes #14
```

```
[BUG:#42] fix snapshot totals filtering by user_id

closes #42
```

---

# Formato de Issues en Gitea

## Issue padre (feature o bug)

```
Título: [EXP-FEAT-012] Per-user period isolation

Descripción:
Spec: openspec/changes/exp-month-close/proposal.md
Milestone: exp-month-close
Branch: feature/exp-month-close

## Contexto
<resumen del proposal.md>

## Sub-issues
- #12 Migración Alembic monthly_periods
- #13 Modelos SQLAlchemy
- #14 Endpoint close_month
...
```

## Sub-issue (tarea)

```
Título: [TASK] Crear migración Alembic para monthly_periods

Descripción:
Parent: #11
Spec: openspec/changes/exp-month-close/specs/
Criterio de aceptación: tabla monthly_periods creada con columnas id, year_month, status, ...
```

---

# Formato de Pull Request en Gitea

```
Título: [EXP-FEAT-012] Per-user period isolation

Milestone: exp-month-close
Branch: feature/exp-month-close → main

## Cambios
- Descripción de qué se implementó

## Spec
openspec/changes/exp-month-close/proposal.md

## Issues cerrados
closes #11, closes #12, closes #13, closes #14

## Testing
- [ ] Tests unitarios pasan
- [ ] Tests de integración pasan
- [ ] Review manual del flujo
```

---

# Estado actual de changes (Mayo 2026)

| Change | Status | Gitea Milestone | Branch |
|---|---|---|---|
| `exp-month-close` | in-progress | pendiente crear | feature/exp-month-close |
| `cc-period-policy` | proposed | pendiente crear | — |
| `cc-bugs-critical` | proposed | pendiente crear | — |
| `formalize-credit-card-module` | proposed | pendiente crear | — |

**Deuda de adopción:** los changes existentes en `openspec/changes/` no tienen `gitea_issue` ni `gitea_milestone` en su `.openspec.yaml`. Deben actualizarse al crear el milestone correspondiente en Gitea.

---

# Checklist de adopción

## Al iniciar un nuevo change

- [ ] Crear Issue padre en Gitea con label `feature` o `bug`
- [ ] Ejecutar `openspec-explore` para clarificar alcance
- [ ] Ejecutar `openspec-propose` para generar artefactos
- [ ] Agregar `gitea_issue` y `gitea_milestone` en `.openspec.yaml`
- [ ] Crear Milestone en Gitea vinculado al change
- [ ] Crear sub-issues en Gitea por cada tarea (reemplaza checkboxes en tasks.md)
- [ ] Reescribir `tasks.md` con referencias `[#id]` a los issues creados
- [ ] Crear branch `feature/<change-name>` desde main
- [ ] Actualizar `status: in-progress` en `.openspec.yaml`

## Al cerrar un change

- [ ] Ejecutar `openspec-archive-change`
- [ ] Cerrar Milestone en Gitea
- [ ] Crear PR en Gitea referenciando milestone e issue padre
- [ ] Merge → main
- [ ] Deploy

---

# Conclusión

- **OpenSpec** = fuente de verdad del diseño (por qué, qué, cómo)
- **Gitea** = fuente de verdad de la ejecución (issues, estado, PRs)
- **GitHub** = hosting remoto únicamente
- **Git branches** = aislamiento de cambios
- **Sin checkboxes en markdown** para tracking — todo en Gitea Issues
