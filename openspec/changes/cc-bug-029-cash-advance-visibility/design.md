## Context

El modal de compras ya soporta `movement_type` y `cash_advance_fee`, pero la activacion no es suficientemente evidente para usuarios no tecnicos. El cambio debe mejorar discoverability sin alterar contratos backend.

## Decision

1. Reemplazar la seleccion explicita del tipo por un toggle visible (`Es extraccion de efectivo`).
2. Sincronizar toggle con `formData.movement_type` (`normal`/`cash_advance`).
3. Cuando el toggle este activo:
   - Mostrar bloque destacado informativo.
   - Hacer visible el campo de comision y mantenerlo obligatorio.
   - Fijar `installments = 1` y deshabilitar input de cuotas.
4. Cuando el toggle se desactive:
   - Restaurar comportamiento normal de cuotas.

## Consequences

- Menor friccion para encontrar la funcionalidad de extraccion.
- Menor probabilidad de rechazo por validacion backend (cuotas > 1 en extracciones).
- Sin cambios de esquema ni migraciones.
