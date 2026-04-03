# Credit Card Management API

## Overview

El módulo de Credit Card Management permite gestionar tarjetas de crédito, compras a plazos, planes de cuotas y pagos.

## Autenticación

Todas las rutas requieren autenticación JWT. Incluir el token en el header:

```
Authorization: Bearer <token>
```

### Roles:
- **admin, writer**: Pueden crear, actualizar y eliminar
- **reader**: Solo puede consultar (GET)

## Endpoints

### 1. Gestión de Tarjetas de Crédito

#### GET /api/credit-cards
Obtiene todas las tarjetas de crédito.

**Query Parameters:**
- `active_only` (boolean, default: true): Filtrar solo tarjetas activas

**Response:**
```json
[
  {
    "id": 1,
    "card_name": "Visa Platinum",
    "bank_name": "Banco XYZ",
    "closing_day": 15,
    "due_day": 25,
    "currency": "USD",
    "credit_limit": 5000.00,
    "is_active": true,
    "notes": "Tarjeta principal",
    "created_at": "2024-03-26T10:00:00"
  }
]
```

#### GET /api/credit-cards/{card_id}
Obtiene una tarjeta específica.

**Response:** Objeto CreditCard (ver arriba)

#### POST /api/credit-cards
Crea una nueva tarjeta de crédito.

**Permissions:** admin, writer

**Request Body:**
```json
{
  "card_name": "Visa Platinum",
  "bank_name": "Banco XYZ",
  "closing_day": 15,
  "due_day": 25,
  "currency": "USD",
  "credit_limit": 5000.00,
  "is_active": true,
  "notes": "Tarjeta principal"
}
```

**Response:**
```json
{
  "message": "Credit card created successfully",
  "id": 1,
  "card": { ... }
}
```

#### PUT /api/credit-cards/{card_id}
Actualiza una tarjeta existente.

**Permissions:** admin, writer

**Request Body:** (todos los campos son opcionales)
```json
{
  "card_name": "Visa Signature",
  "credit_limit": 7500.00,
  "is_active": false
}
```

**Response:**
```json
{
  "message": "Credit card updated successfully",
  "card": { ... }
}
```

#### DELETE /api/credit-cards/{card_id}
Elimina una tarjeta de crédito.

**Permissions:** admin, writer

**Response:**
```json
{
  "message": "Credit card deleted successfully",
  "id": 1
}
```

#### GET /api/credit-cards/{card_id}/summary
Obtiene resumen con estadísticas de la tarjeta.

**Response:**
```json
{
  "card": { ... },
  "total_purchases": 3450.00,
  "total_installments": 12,
  "pending_installments": 8,
  "paid_installments": 4,
  "next_due_amount": 287.50,
  "next_due_date": "2024-04-15",
  "available_credit": 1550.00,
  "current_debt": 3450.00
}
```

### 2. Gestión de Compras

#### POST /api/credit-cards/purchases
Crea una nueva compra con plan de cuotas.

**Permissions:** admin, writer

**Request Body:**
```json
{
  "card_id": 1,
  "transaction_id": 123,
  "description": "Laptop HP",
  "amount": 1200.00,
  "purchase_date": "2024-03-26",
  "installments": 12,
  "interest_rate": 15.0,
  "plan_type": "AUTOMATIC"
}
```

**Campos:**
- `card_id` (int, required): ID de la tarjeta de crédito
- `transaction_id` (int, optional): ID de transacción asociada
- `description` (string, required): Descripción de la compra
- `amount` (float, required): Monto total de la compra
- `purchase_date` (string ISO, required): Fecha de compra
- `installments` (int, default: 1): Número de cuotas
- `interest_rate` (float, default: 0.0): Tasa de interés anual (%)
- `plan_type` (string, default: "MANUAL"): Tipo de plan (MANUAL o AUTOMATIC)

**Response:**
```json
{
  "message": "Purchase created successfully",
  "id": 45,
  "purchase": { ... }
}
```

**Lógica de creación:**
1. Crea el registro de compra (`CreditCardPurchase`)
2. Crea un registro de deuda (`Debt`) con tipo_presupuesto='CREDIT_CARD'
3. Genera el plan de cuotas (`InstallmentPlan`) con cálculo de intereses
4. Crea el cronograma de cuotas (`InstallmentScheduleItem`) con fechas y montos

#### GET /api/credit-cards/{card_id}/purchases
Obtiene todas las compras de una tarjeta.

**Response:**
```json
[
  {
    "id": 45,
    "card_id": 1,
    "transaction_id": 123,
    "description": "Laptop HP",
    "amount": 1200.00,
    "purchase_date": "2024-03-26",
    "installment_plan": {
      "id": 78,
      "total_installments": 12,
      "interest_rate": 15.0,
      "total_amount": 1320.00,
      "paid_installments": 0,
      "pending_installments": 12
    }
  }
]
```

### 3. Gestión de Cuotas

#### GET /api/installment-plans/{plan_id}/schedule
Obtiene el cronograma completo de cuotas.

**Response:**
```json
[
  {
    "id": 890,
    "installment_number": 1,
    "due_date": "2024-04-25",
    "amount": 110.00,
    "principal": 95.00,
    "interest": 15.00,
    "status": "PENDING",
    "payment_date": null
  },
  {
    "id": 891,
    "installment_number": 2,
    "due_date": "2024-05-25",
    "amount": 110.00,
    "principal": 96.19,
    "interest": 13.81,
    "status": "PENDING",
    "payment_date": null
  }
]
```

#### PUT /api/installments/{installment_id}/pay
Marca una cuota como pagada.

**Permissions:** admin, writer

**Request Body:**
```json
{
  "payment_date": "2024-04-25",
  "amount_paid": 110.00,
  "notes": "Pago puntual"
}
```

**Response:**
```json
{
  "message": "Installment marked as paid successfully",
  "installment_id": 890
}
```

**Lógica de pago:**
1. Marca la cuota como PAID
2. Actualiza el monto ejecutado en el Debt asociado
3. Si todas las cuotas están pagadas, marca el Debt como COMPLETED

## Modelos de Datos

### CreditCard
```typescript
{
  id: number;
  card_name: string;
  bank_name: string;
  closing_day: number;  // 1-31
  due_day: number;      // 1-31
  currency: string;     // "USD", "EUR", etc.
  credit_limit?: number;
  is_active: boolean;
  notes?: string;
  created_at: string;
}
```

### CreditCardPurchase
```typescript
{
  id: number;
  card_id: number;
  transaction_id?: number;
  description: string;
  amount: number;
  purchase_date: string;
  installment_plan?: InstallmentPlan;
}
```

### InstallmentPlan
```typescript
{
  id: number;
  purchase_id: number;
  debt_id: number;
  total_installments: number;
  interest_rate: number;
  total_amount: number;
  plan_type: "MANUAL" | "AUTOMATIC";
  paid_installments: number;
  pending_installments: number;
}
```

### InstallmentScheduleItem
```typescript
{
  id: number;
  plan_id: number;
  installment_number: number;
  due_date: string;
  amount: number;
  principal: number;
  interest: number;
  status: "PENDING" | "PAID" | "OVERDUE";
  payment_date?: string;
}
```

## Cálculo de Cuotas

El sistema utiliza amortización francesa (cuotas fijas) para planes con intereses.

**Fórmula:**
```
Cuota = P * [i(1+i)^n] / [(1+i)^n - 1]

Donde:
- P = Monto principal
- i = Tasa de interés mensual (tasa_anual / 12 / 100)
- n = Número de cuotas
```

**Sin intereses:**
```
Cuota = Monto total / Número de cuotas
```

## Integración con Módulo de Debts

Cada compra a cuotas crea automáticamente:
1. **Debt** con tipo_presupuesto='CREDIT_CARD'
2. Vinculación a través de `InstallmentPlan.debt_id`
3. Actualización de `monto_ejecutado` cuando se pagan cuotas
4. Cambio de status a COMPLETED cuando todas las cuotas están pagadas

## Ejemplos de Uso

### Flujo completo: Crear tarjeta y compra

```bash
# 1. Crear tarjeta
POST /api/credit-cards
{
  "card_name": "Visa Gold",
  "bank_name": "Banco Nacional",
  "closing_day": 10,
  "due_day": 20,
  "credit_limit": 3000
}

# 2. Crear compra a 6 cuotas con 12% de interés
POST /api/credit-cards/purchases
{
  "card_id": 1,
  "description": "Televisor Samsung 55\"",
  "amount": 800,
  "purchase_date": "2024-03-26",
  "installments": 6,
  "interest_rate": 12.0
}

# 3. Ver cronograma de cuotas
GET /api/installment-plans/1/schedule

# 4. Pagar primera cuota
PUT /api/installments/1/pay
{
  "payment_date": "2024-04-20",
  "amount_paid": 138.89
}

# 5. Ver resumen de la tarjeta
GET /api/credit-cards/1/summary
```

## Códigos de Error

- **401 Unauthorized**: Token inválido o expirado
- **403 Forbidden**: Permisos insuficientes
- **404 Not Found**: Recurso no encontrado
- **500 Internal Server Error**: Error del servidor
- **503 Service Unavailable**: Servicio de Credit Card no configurado

## Próximos Pasos

- [ ] Implementar estados de cuenta mensuales (`CreditCardStatement`)
- [ ] Agregar tracking de pagos totales (`CreditCardPayment`)
- [ ] Dashboard de análisis de gastos por tarjeta
- [ ] Alertas de vencimiento de cuotas
- [ ] Reportes de intereses pagados
