## Mejoras y bugs modulo de seguridad

Mejoras

1. ~~habilitar vizualizador de password (ojito)~~ ✅ Completada
2. ~~Clonado de datos de un usuario a otros (solo desde role admin)~~ ✅ Completada
   ~~2.1 Clonado de datos módulos Gastos, Presupuestos y Tarjeta de Crédito y sus relaciones (vinculaciones entre gasto y presupuesto por ej)~~ ✅
   ~~2.2 Crear selección para clonar todo, o solo un rango de meses. En el caso de tarjeta de Crédito el periodo a cloanr sería cuya fecha de cierre anterior coincida con el mes indicado.~~ ✅
   Implementación: Endpoint `POST /api/admin/clone-data` + tab "Clonar Datos" en AdminPanel. Clona transactions, budget_items, credit_cards con sus relaciones (purchases, installment plans, statements). Soporta clonado total o por rango de meses.
   

Bugs

1. ~~Nuevo usuario visualiza datos del usuario admin.~~ ✅ Corregido — Se agregó columna `user_id` a `transactions`, `budget_items` y `month_closings`. Todos los endpoints filtran por usuario autenticado.
   Reproducción:
   a. Usuario ingresa con user: sergio pass: Sergio4401.
   b. Usuario entra Panel Principal y visualiza datos de otro usuario (ver imagen)
      ![alt text](image-26.png)