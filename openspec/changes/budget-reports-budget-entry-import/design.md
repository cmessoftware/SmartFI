# Design: Exponer presupuesto en Reportes

## Modulos afectados

- `frontend/src/components/TransactionReport.jsx`
- `frontend/src/components/NewDebtModal.jsx`
- `frontend/src/components/BudgetCSVImport.jsx`

## Flujo propuesto

1. En la barra de acciones de Reportes, agregar un boton `Nuevo Presupuesto`.
2. Ese boton abre `NewDebtModal` reutilizando la logica actual del modulo Presupuesto.
3. En la misma barra, agregar un boton `Importar Presupuesto CSV`.
4. Ese boton despliega `BudgetCSVImport` inline, similar al import de transacciones.
5. Al completar alta o importacion, refrescar la lista de budget items cargada en Reportes.

## Contrato y datos

- No se agregan endpoints nuevos.
- `debtsAPI.createDebt()` y `/api/budget-items/import-csv` siguen siendo la fuente de verdad.
- `expense_type` debe permanecer visible y editable en el alta manual, y soportado en CSV con `tipo_gasto`.

## Consideraciones de UX

- Mantener separadas las acciones de transacciones y presupuesto para evitar ambiguedad.
- Usar etiquetas explicitas: `Nueva Transaccion`, `Nuevo Presupuesto`, `Importar CSV Transacciones`, `Importar CSV Presupuesto`.
- Prefill del mes seleccionado en Reportes cuando se abre alta manual de presupuesto, para reducir errores de periodo.

## Riesgos

- Si `NewDebtModal` asume categorias primitivas y recibe objetos, puede fallar al renderizar.
- Tener dos importadores inline en Reportes requiere estados separados para evitar superposiciones.

## Mitigaciones

- Normalizar labels/values de categorias antes de renderizar selects.
- Cerrar un importador al abrir el otro.
