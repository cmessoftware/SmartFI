# Tasks: EXP-FEAT-017 — Mejorar apertura de mes: clonar solo ítems fijos como Pendientes

> **Depende de**: EXP-FEAT-016 (atributo FIJO/VARIABLE en BudgetItem)

## Backend

- [ ] 1.1 Agregar parámetro `only_fixed: bool` a `clone_budget_items()` para filtrar por `expense_type = FIJO` [#103]
- [ ] 1.2 Actualizar `open_month()` para pasar `only_fixed=True` cuando `include_fixed_clone=True` [#104]
- [ ] 1.3 Agregar campo `only_fixed_clone: bool = True` a `OpenMonthRequest` [#105]

## Frontend

- [ ] 2.1 Actualizar preview en `OpenMonthModal` para mostrar conteo de ítems FIJO del mes anterior [#106]
- [ ] 2.2 Actualizar descripción del modal para comunicar que se clonan solo ítems fijos como Pendientes [#107]

## Testing

- [ ] 3.1 Tests unitarios: `clone_budget_items(only_fixed=True)` solo clona ítems FIJO [#108]
- [ ] 3.2 Test E2E: Abrir mes → verificar que solo se clonaron ítems FIJO con status PENDIENTE [#109]
