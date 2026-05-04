## Context

El módulo de tarjetas de crédito usa `billing_date` para determinar a qué periodo pertenece cada compra. Este campo se calcula al crear/editar: para ARS es igual a `purchase_date`, para USD es `purchase_date + 1 mes`. El problema es que al editar la fecha de una compra, el endpoint `update_purchase()` actualiza el campo pero **no verifica si el nuevo `billing_date` cae en un periodo diferente**, por lo que la compra queda imputada en el periodo equivocado hasta que se recarga manualmente.

El segundo bug es de UI: cuando se edita la moneda (ARS↔USD), el componente de la lista de compras llama a la API pero no refresca el resumen del header, dejando el valor de "Total Pendiente" desactualizado.

## Goals / Non-Goals

**Goals:**
- Al guardar un cambio de fecha, detectar si el nuevo `billing_date` corresponde a un periodo diferente y mover la compra, previa confirmación del usuario.
- Al guardar un cambio de moneda, refrescar el resumen del header de la tarjeta.

**Non-Goals:**
- No cambiar el schema de la base de datos (ya existe `billing_date`).
- No mover automáticamente la compra sin confirmación del usuario.
- No afectar compras en cuotas (solo compras standalone en esta iteración).

## Decisions

### D1: Indicador de cambio de periodo en la respuesta del PUT

El endpoint `PUT /purchases/{id}` retornará un campo adicional `period_changed: bool` y `new_period: str | null` en la respuesta. Esto evita un segundo round-trip del frontend para saber si hubo cambio de periodo.

**Alternativa descartada:** Que el frontend calcule el periodo nuevo por su cuenta. Requeriría duplicar lógica de negocio en el cliente.

### D2: Confirmación en el frontend antes de guardar

El frontend mostrará un modal de confirmación si la API retorna `period_changed: true`. Si el usuario cancela, se revertirá al estado previo (no se persiste el cambio de fecha).

**Alternativa descartada:** Confirmar antes de llamar la API. El backend es la fuente de verdad para determinar periodos; hacerlo antes implicaría lógica duplicada.

### D3: Refresco del resumen al cambiar moneda

El componente de edición de compra, tras un `PUT` exitoso que cambia la moneda, llamará al endpoint `GET /api/credit-cards/{card_id}/summary` para forzar el refresco del header.

**Alternativa descartada:** Invalidar el cache global de React Query. Hay riesgo de refrescar datos innecesarios.

## Risks / Trade-offs

- [Risk: Race condition si el usuario edita rápidamente varias veces] → Mitigación: deshabilitar el botón Guardar mientras la request está en vuelo.
- [Risk: El periodo calculado en backend puede diferir del que ve el usuario en la UI] → Mitigación: el modal de confirmación muestra el nombre del nuevo periodo para que el usuario lo valide.

## Migration Plan

- No hay cambios de schema.
- El campo `period_changed` es un campo nuevo en la respuesta JSON; el frontend existente que ignora campos adicionales no se verá afectado.
- Deploy: rebuild backend + frontend, sin downtime.
