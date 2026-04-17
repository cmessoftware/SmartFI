# Finly — Budget Model Refactor v2 (adaptado a arquitectura actual)

## Objetivo

Refinar el módulo de presupuesto para separar correctamente:

- Obligaciones financieras (OBLIGATION)
- Presupuesto variable (VARIABLE)

Y hacerlo compatible con la implementación actual:

- Backend FastAPI con tabla actual debts y relación transactions.debt_id
- Frontend React con flujos de creación/edición/importación ya operativos
- Migración por fases sin romper endpoints actuales

Nota: el pseudocódigo, nombres de variables y nombres de estados son sugerencias de diseño. El contrato real se define por modelo/DB/API implementados.

---

## 1) Estado actual de arquitectura (base real)

### Modelo actual

- debts
    - id, fecha, tipo, categoria, monto_total, monto_pagado, detalle, fecha_vencimiento, status
- transactions
    - id, fecha, tipo (Gasto/Ingreso), categoria, monto, detalle, debt_id (nullable)

### API actual relevante

- GET /api/debts
- GET /api/debts/summary
- POST /api/debts
- PUT /api/debts/{id}
- DELETE /api/debts/{id}
- POST /api/transactions
- PUT /api/transactions/{id}
- DELETE /api/transactions/{id}

### Restricción de compatibilidad

En esta fase no se deben romper clientes existentes que consumen /api/debts ni transactions.debt_id.

---

## 2) Modelo objetivo (conceptual)

### Entidad objetivo (nombre de dominio)

BudgetItem

- id
- descripcion
- monto
- tipo_flujo: Ingreso | Gasto
- tipo_presupuesto: OBLIGATION | VARIABLE
- categoria
- fecha_vencimiento (nullable)
- estado
- monto_ejecutado (fuente de verdad de ejecución)
- source_budget_id (nullable)
- created_at
- updated_at

### Transacción (dominio)

- id
- fecha
- tipo: Gasto | Ingreso
- categoria
- monto
- detalle
- budget_item_id (nullable en API; no nulo al persistir si autoasignación está activa)
- estado_asignacion

---

## 3) Convenciones en español + mapeos internos

### Dominio visible (español)

- tipo de transacción: Gasto | Ingreso
- campos de negocio: descripcion, monto, categoria, fecha_vencimiento

### Mapeo interno recomendado

- Gasto -> Expense
- Ingreso -> Income

Este mapeo debe existir en backend para evitar comparar directamente strings de distinto idioma.

---

## 4) Semántica unificada de ejecución

Regla base:

monto_ejecutado += transaccion.monto

Interpretación:

- Si tipo_flujo = Gasto: dinero ejecutado (salida)
- Si tipo_flujo = Ingreso: dinero recibido (entrada)

Compatibilidad faseada:

- Fase transitoria: mantener monto_pagado en debts y sincronizarlo con monto_ejecutado en OBLIGATION
- Fase final: deprecar monto_pagado

---

## 5) Lógica por tipo de presupuesto

### 5.1 OBLIGATION (deuda/compromiso)

saldo_pendiente = monto - monto_ejecutado

Reglas de estado sugeridas (manteniendo nombres actuales):

- PAGADA: monto_ejecutado >= monto
- PAGO_PARCIAL: 0 < monto_ejecutado < monto
- VENCIDA: monto_ejecutado = 0 y fecha_vencimiento < hoy
- PENDIENTE: caso contrario

### 5.2 VARIABLE (presupuesto flexible)

variacion = monto_ejecutado - monto

Estados sugeridos:

- EN_PLAN: monto_ejecutado = 0
- BAJO_PRESUPUESTO: 0 < monto_ejecutado <= monto
- SOBREPRESUPUESTO: monto_ejecutado > monto

Nota: estos estados pueden implementarse como columna separada o como estado lógico derivado, según impacto en frontend.

---

## 6) Autoasignación (adaptada al backend actual)

## Fase 1 — sincrónica (en POST /api/transactions)

Objetivo:

- No obligar selección manual en UI
- Persistir transacción con budget_item_id resuelto automáticamente cuando sea posible

Flujo sugerido:

1. Si llega debt_id/budget_item_id manual -> estado_asignacion = ASIGNADA_MANUAL
2. Si no llega:
     - intentar match por tipo_flujo + categoria + similitud de detalle + proximidad de monto/fecha
     - si hay match -> estado_asignacion = ASIGNADA_AUTOMATICA
     - si no hay match -> asignar bucket no planificado del mes y estado_asignacion = NO_PLANIFICADA

Compatibilidad:

- En fase inicial puede mantenerse columna transactions.debt_id
- bucket no planificado se crea en debts con convención de nombre y tipo VARIABLE

## Fase 2 — asíncrona (job de reconciliación)

Objetivo:

- mejorar calidad de asignación
- mover transacciones desde NO_PLANIFICADA o ASIGNADA_AUTOMATICA a mejor candidato

Resultado sugerido:

- estado_asignacion = REASIGNADA_AUTOMATICA

---

## 7) Integración con ingresos

Misma lógica de asignación:

- Ingreso esperado -> puede asociarse a BudgetItem existente
- Ingreso no planificado -> bucket mensual de ingresos no planificados

---

## 8) Métricas derivadas

### OBLIGATION

- saldo_pendiente = monto - monto_ejecutado
- progreso = monto_ejecutado / monto

### VARIABLE

- variacion = monto_ejecutado - monto
- progreso = monto_ejecutado / monto

---

## 9) Forecast (adaptado)

Formula sugerida:

BalanceForecast =
    IngresosReales
+ IngresosPresupuestadosPendientes
- GastosReales
- ObligacionesPendientes
- VariablesPendientesDeGasto * factor_variable

Modos:

- CONSERVADOR: factor_variable = 1.0
- REALISTA: factor_variable = 0.7

Definición operativa clave:

VariablesPendientesDeGasto debe considerar solo items VARIABLE con tipo_flujo = Gasto.

---

## 10) UI (sin romper flujos actuales)

Reglas:

- selector de presupuesto sigue siendo opcional
- mostrar sugerencias automáticas cuando existan
- permitir corrección manual

Indicador de asignación sugerido:

- ASIGNADA_MANUAL
- ASIGNADA_AUTOMATICA
- NO_PLANIFICADA
- REASIGNADA_AUTOMATICA

---

## 11) Reglas críticas

1. La UI no fuerza asignación manual.
2. El backend define la asignación final al persistir.
3. monto_ejecutado es la fuente de verdad de ejecución.
4. monto_pagado queda en compatibilidad transitoria y luego se depreca.

---

## 12) Plan de migración compatible

### Fase A (compatibilidad)

Sin renombrar tablas aún:

- agregar columnas en debts:
    - tipo_presupuesto
    - tipo_flujo
    - monto_ejecutado
- backfill inicial:
    - monto_ejecutado = monto_pagado para tipo_presupuesto = OBLIGATION
- mantener endpoints /api/debts

### Fase B (transición API)

- exponer alias /api/budget-items manteniendo /api/debts
- soportar ambos nombres de campo en DTOs de entrada/salida

### Fase C (consolidación)

- migrar frontend a budget-items
- deprecar monto_pagado
- considerar renombre físico debts -> budget_items cuando no haya dependencias legadas

---

## 13) Resultado esperado

- Separación clara entre obligación y variable
- Menos transacciones huérfanas
- Forecast más confiable
- Camino realista para optimización (matching avanzado/ML) sin romper producción