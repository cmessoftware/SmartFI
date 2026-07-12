## 1. Modelado de pagos proyectados

- [ ] 1.1 Identificar dónde persistir o derivar movimientos proyectados del tipo `SU PAGO EN PESOS` para el período siguiente.
- [ ] 1.2 Implementar la generación automática de una proyección negativa al registrar un pago del resumen actual.
- [ ] 1.3 Asegurar que múltiples pagos generen múltiples proyecciones sin mezclarse.

## 2. Cálculo de estimación del próximo resumen

- [ ] 2.1 Actualizar el cálculo del próximo resumen para incluir pagos proyectados.
- [ ] 2.2 Mostrar saldo anterior neto luego de restar pagos proyectados y saldo remanente por pagos parciales.
- [ ] 2.3 Mantener separados pagos proyectados y cargos/adicionales bancarios.
- [ ] 2.4 Recalcular el pendiente proyectado cuando se agregan/editar/eliminan pagos en el período actual.

## 3. Importación de ajustes bancarios

- [ ] 3.1 Permitir que el importador CSV clasifique líneas como ajustes bancarios adicionales.
- [ ] 3.2 Implementar deduplicación de líneas negativas ya representadas por pagos proyectados.
- [ ] 3.3 Informar al usuario cuándo una línea negativa requiere conciliación manual.

## 4. Frontend y validación

- [ ] 4.1 Mostrar en el período siguiente los movimientos negativos proyectados con etiqueta tipo `SU PAGO EN PESOS`.
- [ ] 4.2 Distinguir visualmente movimientos proyectados de ajustes importados del banco.
- [ ] 4.3 Verificar escenario: pago registrado hoy aparece como negativo en el período siguiente.
- [ ] 4.4 Verificar escenario: pago parcial traslada remanente al pendiente estimado del período siguiente.
- [ ] 4.5 Verificar escenario: nuevo pago en período actual reduce nuevamente el pendiente estimado siguiente.
- [ ] 4.6 Verificar escenario: CSV con intereses/impuestos agrega solo esos cargos.
- [ ] 4.7 Verificar escenario: CSV con `SU PAGO EN PESOS` ya proyectado no duplica el movimiento.