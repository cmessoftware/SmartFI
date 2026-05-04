## Why

Hoy el sistema permite registrar pagos del resumen actual, pero no proyecta automáticamente su efecto contable en el período siguiente. Eso obliga a depender del CSV bancario para reflejar movimientos negativos tipo "SU PAGO EN PESOS" y dificulta estimar el próximo resumen antes de que llegue el extracto.

## What Changes

- Al registrar un pago del resumen actual, el sistema generará automáticamente un movimiento proyectado negativo en el período siguiente con semántica bancaria tipo `SU PAGO EN PESOS`.
- La estimación del próximo resumen usará saldo anterior, pagos proyectados y gastos/cargos del período actual.
- La importación CSV del banco dejará de ser la fuente de los pagos ya registrados y se usará solo para ajustes adicionales no modelados previamente, como intereses, impuestos, retenciones y punitorios.
- El sistema deberá evitar duplicar pagos si luego se importa un CSV que también contiene líneas negativas equivalentes.

## Capabilities

### New Capabilities
- `next-statement-payment-projection`: Proyectar pagos registrados como movimientos negativos en el período siguiente.
- `next-statement-estimation`: Calcular el próximo resumen usando saldo anterior, pagos proyectados y cargos actuales.
- `statement-adjustment-import`: Importar solo ajustes bancarios adicionales sin duplicar pagos ya modelados.

### Modified Capabilities

## Impact

- **Backend** (`backend/services/credit_card_service.py`): generación y consulta de movimientos proyectados del período siguiente.
- **Backend** (`backend/main.py`): endpoints de resumen e importación CSV.
- **Frontend** (`frontend/src/`): visualización de la estimación del próximo resumen y distinción entre pagos proyectados y ajustes importados.
- **Data**: posible reutilización de tablas de pagos/transacciones existentes o incorporación de una marca de origen/tipo de movimiento.