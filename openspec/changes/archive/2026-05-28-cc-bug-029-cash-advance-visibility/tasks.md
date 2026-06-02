## 1. UX de activacion de extraccion

- [x] 1.1 Agregar toggle visible para activar/desactivar extraccion de efectivo en Nueva Compra.
- [x] 1.2 Sincronizar el toggle con `movement_type` del payload.

## 2. Reglas de formulario

- [x] 2.1 Mostrar comision solo para extraccion y mantener validacion obligatoria.
- [x] 2.2 Forzar 1 cuota para extraccion y deshabilitar edicion de cuotas en ese estado.

## 3. Validacion funcional

- [x] 3.1 Verificar que compra normal sigue funcionando sin cambios.
- [x] 3.2 Verificar que extraccion envia `movement_type=cash_advance` y `cash_advance_fee`.
