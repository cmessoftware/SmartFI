# Issues a Crear en Gitea para CC-FEAT-024

## Resumen corto del FEAT

Registrar extracciones de tarjeta como gasto del período actual y, además, como deuda del período siguiente en DEBTS, con comisión obligatoria.

## Instrucciones

1. Abrir el repositorio en Gitea y crear Milestone: cc-cash-advance-debt.
2. Crear primero el issue padre de feature.
3. Crear luego las sub-tareas en el orden sugerido.
4. Copiar el número del issue padre y reemplazar PARENT_ID en las descripciones.
5. Actualizar openspec/changes/cc-cash-advance-debt/.openspec.yaml con gitea_issue real.

---

## Issue Padre (Feature)

Título:
[CC-FEAT-024] Extracciones de tarjeta con impacto dual: gasto actual + deuda siguiente

Descripción:
Spec: openspec/changes/cc-cash-advance-debt/proposal.md
Design: openspec/changes/cc-cash-advance-debt/design.md
Tasks: openspec/changes/cc-cash-advance-debt/tasks.md
Milestone: cc-cash-advance-debt
Branch: feature/cc-cash-advance-debt

Contexto:
Se debe modelar la extracción de efectivo con tarjeta como un movimiento especial que impacta en dos lugares:
1) gasto del período actual de tarjeta,
2) deuda en DEBTS del período siguiente,
incluyendo comisión obligatoria.

Criterios de aceptación:
- Extracción válida crea compra + deuda derivada.
- Compra normal no crea deuda derivada.
- Extracción sin comisión se rechaza.
- Reintento no duplica deuda derivada.

Labels sugeridos:
CC-FEAT-024, feature, credit-card, debts, backend, frontend

---

## Sub-issue 1

Título:
[CC-FEAT-024][Backend][Data] Modelo y migración Alembic para extracciones

Descripción:
Parent: #125
Spec: openspec/changes/cc-cash-advance-debt/specs/cash-advance-dual-recording/spec.md

Implementar en modelo de compra de tarjeta:
- movement_type (normal | cash_advance)
- cash_advance_fee
- derived_debt_id

Crear migración Alembic con constraints y defaults seguros.

Criterio de aceptación:
- Migración aplica sin errores.
- Nuevas columnas disponibles.
- Comisión negativa inválida.

Labels sugeridos:
CC-FEAT-024, backend, data, alembic

Dependencias:
Ninguna

---

## Sub-issue 2

Título:
[CC-FEAT-024][Backend] Flujo transaccional extracción + deuda derivada

Descripción:
Parent: #125
Spec: openspec/changes/cc-cash-advance-debt/design.md

Implementar servicio para:
- crear extracción en período actual,
- calcular período siguiente,
- crear deuda derivada por extracción + comisión,
- garantizar atomicidad e idempotencia.

Criterio de aceptación:
- Si falla deuda, no persiste extracción.
- Reintento del mismo origen no duplica deuda.

Labels sugeridos:
CC-FEAT-024, backend, credit-card, debts

Dependencias:
Sub-issue 1

---

## Sub-issue 3

Título:
[CC-FEAT-024][Backend][API] Endpoints compra con tipo extracción y comisión

Descripción:
Parent: #125
Spec: openspec/changes/cc-cash-advance-debt/tasks.md

Extender endpoints POST/PUT de compras para:
- aceptar movement_type y cash_advance_fee,
- validar comisión obligatoria en extracción,
- devolver referencia a deuda derivada.

Criterio de aceptación:
- API rechaza extracción sin comisión.
- API responde metadatos de deuda en extracciones válidas.

Labels sugeridos:
CC-FEAT-024, backend, api

Dependencias:
Sub-issue 2

---

## Sub-issue 4

Título:
[CC-FEAT-024][Backend][CSV] Importación de extracciones con comisión obligatoria

Descripción:
Parent: #125
Spec: openspec/changes/cc-cash-advance-debt/tasks.md

Ajustar importador CSV para:
- clasificar filas como extracción,
- exigir comisión,
- aplicar mismo flujo de deuda derivada,
- reportar errores por fila cuando falte comisión.

Criterio de aceptación:
- CSV con extracción sin comisión retorna error claro.
- CSV válido crea extracción y deuda derivada.

Labels sugeridos:
CC-FEAT-024, backend, csv

Dependencias:
Sub-issue 2

---

## Sub-issue 5

Título:
[CC-FEAT-024][Frontend] Nueva Compra: tipo extracción y campo comisión

Descripción:
Parent: #125
Design: openspec/changes/cc-cash-advance-debt/design.md

Actualizar formulario Nueva Compra:
- selector tipo normal/extracción,
- campo comisión visible y requerido solo para extracción,
- mensajes de validación claros.

Criterio de aceptación:
- Usuario no puede guardar extracción sin comisión.
- Compra normal mantiene flujo actual sin fricción.

Labels sugeridos:
CC-FEAT-024, frontend, ux

Dependencias:
Sub-issue 3

---

## Sub-issue 6

Título:
[CC-FEAT-024][Frontend][CSV] Mensajes de error para extracciones inválidas

Descripción:
Parent: #125
Tasks: openspec/changes/cc-cash-advance-debt/tasks.md

En importación CSV frontend:
- mostrar errores por fila,
- destacar motivo comisión faltante/ inválida,
- permitir corrección y reintento.

Criterio de aceptación:
- Reporte de errores legible por fila y causa.

Labels sugeridos:
CC-FEAT-024, frontend, csv, ux

Dependencias:
Sub-issue 4

---

## Sub-issue 7

Título:
[CC-FEAT-024][Testing] Casos de validación e idempotencia

Descripción:
Parent: #125
Spec: openspec/changes/cc-cash-advance-debt/specs/cash-advance-dual-recording/spec.md

Cubrir casos:
- compra normal sin deuda derivada,
- extracción válida con deuda derivada,
- extracción sin comisión rechazada,
- reintento sin duplicación,
- edición de extracción consistente con deuda.

Criterio de aceptación:
- Suite verde para escenarios críticos del FEAT.

Labels sugeridos:
CC-FEAT-024, testing, backend, frontend

Dependencias:
Sub-issues 5 y 6

---

## Orden sugerido de ejecución

1) Sub-issue 1
2) Sub-issue 2
3) Sub-issue 3 y 4
4) Sub-issue 5 y 6
5) Sub-issue 7
