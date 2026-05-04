## Context

El módulo ya registra pagos desde el Resumen del Período y calcula parte del próximo pago con base en saldo anterior y cargos del período actual. Sin embargo, los pagos registrados no se materializan como movimientos negativos visibles en el período siguiente con semántica de extracto bancario. La necesidad funcional es que, al registrar un pago hoy, el sistema proyecte inmediatamente el efecto que luego aparecería como `SU PAGO EN PESOS` en el próximo resumen.

El CSV bancario no debe ser la fuente principal de esos pagos proyectados. Debe usarse solo para conceptos adicionales no registrados manualmente por el usuario, como intereses, impuestos, retenciones o punitorios.

## Goals / Non-Goals

**Goals:**
- Proyectar pagos del período actual como movimientos negativos del período siguiente.
- Mostrar una estimación consistente del próximo resumen sin esperar el CSV bancario.
- Evitar duplicaciones cuando luego se importe el extracto real del banco.
- Permitir importar manual o por CSV solo ajustes bancarios adicionales.

**Non-Goals:**
- No reemplazar el flujo existente de registro de pagos.
- No convertir líneas negativas del CSV en compras o gastos nuevos.
- No redefinir en esta iteración toda la conciliación bancaria histórica.

## Decisions

### D1: Los pagos registrados generan un movimiento proyectado derivado

Cada pago registrado en el período actual generará un movimiento derivado para el período siguiente con tipo lógico `projected_payment` y etiqueta visible tipo `SU PAGO EN PESOS`.

### D2: La estimación del próximo resumen se construye antes del CSV

La pantalla del resumen y las APIs de cálculo usarán como fuente principal el saldo anterior neto, los pagos proyectados y los cargos del período actual. El CSV solo agregará ajustes faltantes.

### D3: Dedupe por importe, fecha y tipo al importar extracto

Si el CSV contiene una línea negativa equivalente a un pago ya proyectado, el sistema no creará un segundo movimiento; deberá reconocerla como representada y omitir su duplicación o marcarla como conciliada.

## Risks / Trade-offs

- [Risk: duplicación de movimientos al importar CSV] -> Mitigación: deduplicación por tipo, importe, período y proximidad de fecha.
- [Risk: diferencias menores entre fecha del pago registrado y fecha reflejada por el banco] -> Mitigación: tolerancia configurable de conciliación por rango de días.
- [Risk: complejidad visual al mostrar proyecciones y ajustes reales] -> Mitigación: distinguir claramente origen `proyectado` vs `importado`.

## Migration Plan

- Revisar si alcanza con reutilizar `payment_transactions`/transacciones existentes con un tipo derivado o si se necesita persistencia explícita de proyección.
- Incorporar primero la lógica de proyección y cálculo.
- Luego agregar deduplicación en la importación CSV.
- Finalmente exponer en frontend la estimación y los ajustes adicionales.