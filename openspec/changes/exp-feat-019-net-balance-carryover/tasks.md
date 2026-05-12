# Tasks: EXP-FEAT-019 — Arrastre de Balance Neto entre meses

## Backend

- [ ] 1.1 Exponer endpoint `GET /api/months/{year_month}/balance` que devuelve el balance neto del mes anterior cerrado (reutilizar `calculate_month_balance()`) [#95]
- [ ] 1.2 Incluir campo `prior_balance` en la respuesta de `GET /api/months/{year_month}/status` cuando el mes anterior está cerrado [#96]

## Frontend

- [ ] 2.1 Mostrar badge "Saldo anterior: $X.XX" en el header del mes (verde si positivo, rojo si negativo) [#97]
- [ ] 2.2 Mostrar dato informativo de balance anterior en `OpenMonthModal` antes de confirmar apertura [#98]
- [ ] 2.3 Agregar botón opcional "Registrar saldo anterior" que crea manualmente una transacción INGRESO/GASTO de tipo "Saldo Anterior" [#99]

## Testing

- [ ] 3.1 Tests unitarios: `GET /api/months/{year_month}/balance` con mes anterior cerrado y sin cerrar [#100]
- [ ] 3.2 Test UI: badge visible en header, color correcto según signo del balance [#101]
