## Why

La tabla de compras del módulo de tarjetas de crédito presenta varios problemas de usabilidad: la paginación muestra 10 ítems pero debería mostrar 5, el cronograma de cuotas tampoco pagina correctamente, no es posible ordenar por monto, las cuotas y pagos únicos no están agrupados visualmente, falta un tooltip de detalle por compra, el combo de tipo de plan es visible cuando no corresponde, y falta un campo de detalle libre en las compras.

## What Changes

- Paginación de la tabla de compras: reducir a 5 ítems por página (BUG-011).
- Paginación del cronograma de cuotas: reducir a 5 ítems por página (BUG-012).
- Ordenamiento por monto en la tabla de compras (FEAT-014).
- Agrupación visual de cuotas vs. pagos únicos en la tabla (FEAT-015).
- Tooltip de detalle al hacer hover sobre una compra (FEAT-016).
- Ocultar combo "tipo de plan" cuando no aplica (FEAT-020).
- Agregar campo de texto libre "detalle" a las compras (FEAT-021).
- Paginación configurable: mostrar X ítems por página (FEAT-009).

## Capabilities

### New Capabilities

- `purchase-table-pagination`: Tabla de compras pagina de a 5 ítems; cronograma de cuotas también de a 5.
- `purchase-table-sort-by-amount`: Ordenar la tabla de compras por monto ascendente/descendente.
- `purchase-type-grouping`: Agrupar visualmente cuotas vs. pagos únicos en la tabla.
- `purchase-detail-tooltip`: Tooltip al hacer hover sobre una compra mostrando detalles adicionales.
- `purchase-plan-type-visibility`: Ocultar el combo de tipo de plan cuando no aplica al contexto.
- `purchase-detail-field`: Nuevo campo de texto libre "detalle" en el formulario de compra.

### Modified Capabilities

<!-- No hay specs existentes que modificar -->

## Impact

- **Frontend** (`frontend/src/`): componentes de tabla de compras, formulario de compra, cronograma de cuotas.
- **Backend** (`backend/database/database.py`): agregar columna `detail` (texto libre) a `CreditCardPurchase`.
- **Backend** (`backend/alembic/versions/`): nueva migración Alembic para la columna `detail`.
- **Backend** (`backend/main.py` + `credit_card_service.py`): exponer campo `detail` en endpoints de compra.
