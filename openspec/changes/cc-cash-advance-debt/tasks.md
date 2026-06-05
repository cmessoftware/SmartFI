## 1. Data model y migración

- [ ] 1.1 Actualizar modelo CreditCardPurchase con movement_type, cash_advance_fee y derived_debt_id.
- [ ] 1.2 Crear migración Alembic para nuevas columnas, defaults y restricciones.
- [ ] 1.3 Agregar validaciones de dominio en modelo/servicio para comisión no negativa.

## 2. Backend servicio transaccional

- [ ] 2.1 Implementar flujo create_cash_advance que persiste compra y deuda derivada en una sola operación.
- [ ] 2.2 Calcular período siguiente de la tarjeta y registrar deuda en DEBTS por extracción + comisión.
- [ ] 2.3 Implementar idempotencia para evitar deuda duplicada por reintento/importación repetida.

## 3. API y CSV

- [ ] 3.1 Extender endpoints POST/PUT de compra para aceptar movement_type y cash_advance_fee.
- [ ] 3.2 Devolver en respuesta metadatos de deuda derivada cuando aplique.
- [ ] 3.3 Extender importación CSV para clasificar extracción y validar comisión obligatoria.

## 4. Frontend

- [ ] 4.1 En Nueva Compra, agregar selector de tipo y campo comisión condicionado a extracción.
- [ ] 4.2 Mostrar validación clara si falta comisión en extracción.
- [ ] 4.3 En importación CSV, mostrar errores por fila para extracciones sin comisión.

## 5. Validación

- [ ] 5.1 Verificar: compra normal no crea deuda derivada.
- [ ] 5.2 Verificar: extracción válida crea gasto actual y deuda siguiente.
- [ ] 5.3 Verificar: extracción sin comisión es rechazada.
- [ ] 5.4 Verificar: reintento de misma extracción no duplica deuda.
- [ ] 5.5 Verificar: edición de extracción actualiza deuda derivada de forma consistente.