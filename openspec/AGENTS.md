# OpenSpec Agents Guide for SmartFI

## Objetivo

Definir cómo deben operar los agentes de trabajo al usar OpenSpec en este repositorio, para mantener consistencia funcional, trazabilidad y calidad técnica.

## 1. Agentes y responsabilidades

### 1. Explore Agent
Responsabilidad:
- Entender el problema y el alcance real.
- Relevar código existente y comportamiento actual.
- Identificar restricciones técnicas y de negocio.

Entregable mínimo:
- Resumen del problema.
- Módulos impactados.
- Riesgos y supuestos.

### 2. Propose Agent
Responsabilidad:
- Crear el change de OpenSpec.
- Redactar proposal.md, design.md y tasks.md.
- Definir capacidades nuevas o modificadas.

Entregable mínimo:
- proposal.md completo.
- design.md completo.
- tasks.md con trazabilidad a Gitea [#id].

### 3. Apply Agent
Responsabilidad:
- Implementar lo definido en tasks.md.
- Mantener compatibilidad con la arquitectura vigente.
- Validar compilación, pruebas y comportamiento funcional como parte del propio Apply.
- Si tasks.md no existe o está incompleto, detener la implementación y notificar al Propose Agent para completarlo antes de comenzar.

Entregable mínimo:
- Código implementado.
- Evidencia de validación técnica.
- Actualización de tareas completadas.

### 4. Archive Agent
Responsabilidad:
- Cerrar formalmente un change implementado.
- Consolidar resultado final y aprendizajes.
- Mantener histórico de cambios accesible.

Entregable mínimo:
- Change archivado.
- Estado final documentado.

## 2. Reglas obligatorias para todos los agentes

1. Nunca modificar esquema o datos de BD fuera de Alembic.
2. Priorizar trazabilidad: cada tarea con issue de Gitea [#id].
3. No mezclar refactors no relacionados dentro de un change funcional.
4. Mantener separación clara entre:
   - reglas de negocio
   - decisiones de diseño
   - pasos de implementación
5. Si hay dudas críticas de alcance, resolverlas antes de implementar.
6. Si una migración Alembic falla o se detectan heads en conflicto, detener la implementación, documentar el conflicto en tasks.md y resolverlo antes de continuar.
7. No continuar con el arranque de la aplicación hasta que `alembic heads` reporte un único head.

## 3. Convenciones por artefacto OpenSpec

### proposal.md
Debe responder:
- Por qué se hace el cambio.
- Qué cambia.
- Qué capacidades se crean o modifican.
- Qué impacto tiene.

### design.md
Debe cubrir:
- módulos afectados
- modelo de datos
- contratos API
- seguridad
- decisiones y trade-offs

### tasks.md
Debe incluir:
- tareas accionables
- agrupación Backend, Frontend y Testing
- referencia Gitea [#id] por tarea
- en avances parciales, marcar cada tarea terminada con [done] y cada tarea en curso con [in-progress]
- no dejar tareas sin estado explícito al detener implementación a mitad de ejecución

## 4. Definición de Done por tipo de trabajo

### Done de Propuesta
- proposal.md, design.md y tasks.md listos y consistentes.
- validación de factibilidad técnica realizada.

### Done de Implementación
- código completo según tasks.md
- tests unitarios e integrales que cubren módulos modificados ejecutados con cero fallas, más los tests nuevos exigidos por tasks.md
- sin errores de sintaxis/arranque
- sin conflictos de merge en archivos del change

### Done de Archivado
- change finalizado y archivado
- estado final y decisiones críticas preservadas

## 5. Protocolo operativo recomendado

1. Explore: confirmar alcance y límites.
2. Propose: generar artefactos (usar base en `openspec/templates/change-template/`).
3. Apply: implementar por bloques pequeños y validables, incluyendo pruebas y revisión funcional.
4. Archive: cerrar ciclo del change.

## 5.1 Plantillas disponibles

- `openspec/templates/change-template/proposal.md`
- `openspec/templates/change-template/design.md`
- `openspec/templates/change-template/tasks.md`
- `openspec/templates/README.md`

Usar estas plantillas como punto de partida para mantener consistencia entre changes.

## 6. Checklist rápido antes de finalizar un cambio

- ¿Se respetó Alembic para cambios de BD?
- ¿Las tareas tienen referencia [#id] de Gitea?
- ¿Se actualizaron proposal/design/tasks según implementación real?
- ¿El backend arranca sin errores?
- ¿El frontend compila y funciona para el flujo afectado?
- ¿No quedaron marcadores de conflicto de merge?

## 7. Contexto SmartFI relevante para agentes

- Backend principal: backend/main.py
- Deudas no tarjeta: backend/services/debt_record_service.py
- Tarjetas: backend/services/credit_card_service.py
- Front API: frontend/src/services/api.js
- OpenSpec config: openspec/config.yaml

Este documento es la guía operativa de agentes para usar OpenSpec formalmente en SmartFI.
