## 1. Backend — Crear BudgetItem al cerrar periodo

- [ ] 1.1 Identificar el método de cierre de periodo en `credit_card_service.py` (e.g., `close_period()` o equivalente).
- [ ] 1.2 Dentro de la transacción de cierre, calcular el monto total del periodo.
- [ ] 1.3 Verificar si ya existe un `BudgetItem` vinculado a este cierre (idempotencia).
- [ ] 1.4 Si no existe, crear un `BudgetItem` con: `amount = monto_total`, `month = mes_siguiente`, `year = año_correcto`, `category = "Tarjeta de Crédito"`, `description = "Cierre periodo {nombre} — {tarjeta}"`.
- [ ] 1.5 Ambas operaciones (cierre + BudgetItem) deben estar en el mismo `db.commit()`.

## 2. Frontend — Corrección de visibilidad de botones

- [ ] 2.1 Identificar el componente que maneja el flujo de registro de gasto de nuevo periodo.
- [ ] 2.2 Verificar qué estado controla la visibilidad de los botones de acción.
- [ ] 2.3 Corregir el estado o el re-render para que los botones reflejen el estado correcto tras el guardado.

## 3. Validación

- [ ] 3.1 Verificar: cerrar un periodo crea un `BudgetItem` en el mes siguiente con los datos correctos.
- [ ] 3.2 Verificar: cerrar el mismo periodo dos veces no crea duplicados.
- [ ] 3.3 Verificar: BudgetItem de diciembre → mes enero del año siguiente.
- [ ] 3.4 Verificar: registrar gasto de nuevo periodo → botones visibles correctamente sin reload.
