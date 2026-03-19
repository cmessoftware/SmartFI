# Implementación Fase A - Budget Model Refactor

## Fecha: 2026-03-18

## Objetivo
Implementar la **Fase A (Compatibilidad)** del refactor del modelo de presupuesto para separar conceptualmente:
- **OBLIGATION**: Obligaciones financieras (deudas, compromisos)
- **VARIABLE**: Presupuesto variable (gastos/ingresos planificados)

## Archivos Modificados

### 1. Backend - Migración SQL
**Archivo**: `backend/migrations/002_add_budget_item_columns.sql`
- Agregado tipo enum `budget_type` (OBLIGATION, VARIABLE)
- Agregado tipo enum `flow_type` (Gasto, Ingreso)
- Agregadas columnas en tabla `debts`:
  - `tipo_presupuesto` (VARCHAR): OBLIGATION | VARIABLE
  - `tipo_flujo` (VARCHAR): Gasto | Ingreso
  - `monto_ejecutado` (FLOAT): fuente de verdad de ejecución
- Backfill inicial: sincronización `monto_ejecutado = monto_pagado` para OBLIGATION
- Agregada columna `estado_asignacion` en tabla `transactions` (preparación para autoasignación)
- Índices creados para optimizar queries

### 2. Backend - Modelo de Datos
**Archivo**: `backend/database/database.py`
- Agregados nuevos enums:
  - `BudgetType`: OBLIGATION | VARIABLE
  - `FlowType`: GASTO | INGRESO
  - `AssignmentStatus`: ASIGNADA_MANUAL | ASIGNADA_AUTOMATICA | NO_PLANIFICADA | REASIGNADA_AUTOMATICA
- Actualizado modelo `Debt`:
  - `tipo_presupuesto: BudgetType` (default: OBLIGATION)
  - `tipo_flujo: FlowType` (default: GASTO)
  - `monto_ejecutado: Float` (default: 0.0)
- Actualizado modelo `Transaction`:
  - `estado_asignacion: AssignmentStatus` (default: ASIGNADA_MANUAL)

### 3. Backend - Servicio de Deudas
**Archivo**: `backend/services/debt_service.py`
- Actualizado `add_debt()`:
  - Soporta nuevos campos en creación
  - Inicializa `monto_ejecutado = monto_pagado` para compatibilidad
- Actualizado `get_all_debts()` y `get_debt_by_id()`:
  - Retorna nuevos campos en respuesta
- Actualizado `update_debt()`:
  - Sincroniza `monto_ejecutado` con `monto_pagado` para OBLIGATION (compatibilidad transitoria)
  - Soporta actualización de `tipo_presupuesto` y `tipo_flujo`
- Actualizado `add_payment_to_debt()` y `remove_payment_from_debt()`:
  - Sincroniza `monto_ejecutado` con `monto_pagado` automáticamente

### 4. Backend - Modelos Pydantic
**Archivo**: `backend/main.py`
- Actualizado modelo `Debt`:
  - `tipo_presupuesto: Optional[str]` (default: "OBLIGATION")
  - `tipo_flujo: Optional[str]` (default: "Gasto")
  - `monto_ejecutado: Optional[float]` (default: 0.0)

### 5. Script de Migración
**Archivo**: `run_migration_002.py`
- Script Python para ejecutar migración SQL sin dependencias externas
- Verifica columnas agregadas
- Muestra resumen de cambios

## Compatibilidad

### ✅ Mantenida
- Todos los endpoints existentes `/api/debts/*` funcionan sin cambios
- Campo `monto_pagado` sigue funcionando (sincronizado con `monto_ejecutado`)
- Clientes existentes (frontend) no requieren cambios inmediatos
- Datos existentes migrados correctamente con valores por defecto

### 🔄 Transición
- `monto_ejecutado` es la nueva fuente de verdad (sincronizado con `monto_pagado` en OBLIGATION)
- Nuevos campos opcionales en API pueden enviarse o ser omitidos

## Pruebas Realizadas

### ✅ Backend Inicializado
```
✅ PostgreSQL database connected successfully
✅ Debt service initialized successfully
```

### ✅ API Endpoints Funcionando
- GET `/api/debts` - Retorna 37 debts con nuevos campos
- GET `/api/debts/summary` - Funciona correctamente
- POST `/api/debts` - Creación con nuevos campos exitosa
- GET `/api/debts/{id}` - Retorna debt individual con nuevos campos

### ✅ Valores de Prueba
```json
{
  "id": 126,
  "tipo": "Presupuesto",
  "categoria": "Alimentos",
  "monto_total": 50000,
  "tipo_presupuesto": "VARIABLE",
  "tipo_flujo": "Gasto",
  "monto_ejecutado": 0,
  "detalle": "Presupuesto mensual alimentos - VARIABLE"
}
```

### ✅ Datos Migrados
- 37 debts existentes migrados con `tipo_presupuesto = OBLIGATION`
- `monto_ejecutado` sincronizado con `monto_pagado`

## Próximos Pasos

### Fase B - Transición API (Pendiente)
- Exponer alias `/api/budget-items` manteniendo `/api/debts`
- Soportar ambos nombres de campo en DTOs
- Deprecation warnings para clientes

### Fase C - Consolidación (Pendiente)
- Migrar frontend a `budget-items`
- Deprecar `monto_pagado`
- Considerar renombre físico `debts → budget_items`

### Futuro - Autoasignación
- Implementar matching automático por categoría/monto/fecha
- Crear buckets "no planificado" automáticamente
- Job de reconciliación asíncrona

## Notas Técnicas

### Convenciones
- Español en dominio visible: "Gasto", "Ingreso"
- Enums internos siguen estándar Python
- Mapeo explícito string ↔ enum en servicio

### Sincronización Transitoria
```python
if debt.tipo_presupuesto == BudgetType.OBLIGATION:
    debt.monto_ejecutado = debt.monto_pagado
```

### Performance
- Índices agregados en:
  - `debts.tipo_presupuesto`
  - `debts.tipo_flujo`

## Resultado
✅ **Fase A completada exitosamente**
- Separación conceptual implementada
- Compatibilidad total mantenida
- Backend funcionando correctamente
- Preparado para Fase B
