# Proposal: Exponer alta e importacion de presupuesto en Reportes

## Why

La pantalla de Reportes permite trabajar con transacciones y ejecutar acciones mensuales, pero no ofrece un flujo equivalente para crear o importar items de presupuesto desde el mismo contexto. Eso genera dos problemas:

1. El usuario debe cambiar de modulo para crear items de presupuesto antes de probar acciones mensuales.
2. El atributo `expense_type` (`FIJO` / `VARIABLE`) no queda visible ni operativo desde Reportes, lo que bloquea la validacion funcional de EXP-FEAT-017 y EXP-FEAT-018.

## What Changes

- Agregar en Reportes acceso explicito a alta manual de item de presupuesto.
- Agregar en Reportes acceso explicito a importacion CSV de presupuesto.
- Reutilizar los componentes existentes del modulo Presupuesto para no duplicar reglas.
- Asegurar que el flujo exponga y preserve `expense_type` durante alta e importacion.

## Capabilities

### Nueva: `reports-budget-entry`
- Crear items de presupuesto desde Reportes.
- Seleccionar `FIJO` o `VARIABLE` en el flujo de alta.
- Refrescar filtros y fuentes de presupuesto disponibles tras crear/importar.

### Nueva: `reports-budget-import`
- Importar items de presupuesto desde Reportes con soporte de columna `tipo_gasto`.
- Reutilizar validaciones y preview de `BudgetCSVImport`.

## Impact

- **Frontend**: `TransactionReport.jsx`, `NewDebtModal.jsx`, `BudgetCSVImport.jsx`.
- **Backend**: sin nuevos endpoints; reutiliza API existente de budget items.
- **Testing**: validar alta manual e importacion desde Reportes, incluyendo `expense_type`.
- **Dependencias**: habilita la prueba funcional de EXP-FEAT-017 y EXP-FEAT-018.
