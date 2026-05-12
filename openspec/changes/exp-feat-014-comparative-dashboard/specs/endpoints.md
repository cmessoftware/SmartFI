# API Endpoints - EXP-FEAT-014

## GET /api/months/range/{start}/{end}/comparison

Retorna análisis comparativo completo de un rango de meses (2-4 meses).

### Request

```
GET /api/months/2026-01/2026-04/comparison
Authorization: Bearer {token}
```

### Parameters

- `start` (path): string "YYYY-MM" - mes inicial (inclusive)
- `end` (path): string "YYYY-MM" - mes final (inclusive)

### Response (200 OK)

```json
{
  "range": {
    "start": "2026-01",
    "end": "2026-04",
    "months_count": 4
  },
  "summary": {
    "total_income": 2010000,
    "total_expenses": 1265000,
    "total_balance": 745000,
    "avg_monthly_balance": 186250
  },
  "months": [
    {
      "year_month": "2026-01",
      "total_income": 500000,
      "total_expenses": 300000,
      "net_balance": 200000,
      "budget_items": {
        "total_count": 15,
        "pending_count": 3,
        "executed_count": 12
      },
      "status": "closed"
    },
    {
      "year_month": "2026-02",
      "total_income": 480000,
      "total_expenses": 380000,
      "net_balance": 100000,
      "budget_items": {
        "total_count": 18,
        "pending_count": 5,
        "executed_count": 13
      },
      "status": "closed"
    },
    ...
  ],
  "categories": [
    {
      "category_name": "Vivienda",
      "months": [
        {
          "year_month": "2026-01",
          "amount": 120000,
          "percentage": 40
        },
        {
          "year_month": "2026-02",
          "amount": 120000,
          "percentage": 31.6
        },
        ...
      ]
    },
    {
      "category_name": "Servicios",
      "months": [
        {
          "year_month": "2026-01",
          "amount": 75000,
          "percentage": 25
        },
        {
          "year_month": "2026-02",
          "amount": 95000,
          "percentage": 25
        },
        ...
      ]
    },
    ...
  ],
  "deviations": {
    "category_deviations": [
      {
        "category": "Transporte",
        "month": "2026-02",
        "previous_month": "2026-01",
        "previous_amount": 60000,
        "current_amount": 115000,
        "deviation_percent": 91.7,
        "absolute_change": 55000,
        "severity": "critical"
      },
      {
        "category": "Servicios",
        "month": "2026-02",
        "previous_month": "2026-01",
        "previous_amount": 75000,
        "current_amount": 95000,
        "deviation_percent": 26.7,
        "absolute_change": 20000,
        "severity": "critical"
      }
    ],
    "total_deviations": [
      {
        "month": "2026-02",
        "previous_month": "2026-01",
        "income_change_percent": -4,
        "expense_change_percent": 26.7,
        "balance_change_percent": -50,
        "severity": "critical"
      }
    ]
  }
}
```

### Error Responses

**400 Bad Request** - Rango inválido
```json
{
  "detail": "Rango de meses inválido: start > end"
}
```

**400 Bad Request** - Formato incorrecto
```json
{
  "detail": "Formato de mes inválido. Use YYYY-MM"
}
```

**403 Forbidden** - No autorizado
```json
{
  "detail": "No autorizado para acceder a estos datos"
}
```

**422 Unprocessable Entity** - Rango muy largo
```json
{
  "detail": "Rango máximo: 12 meses"
}
```

---

## GET /api/months/range/{start}/{end}/deviations

Retorna solo deviaciones críticas (>20%) para alertas rápidas.

### Request

```
GET /api/months/2026-01/2026-04/deviations
Authorization: Bearer {token}
```

### Response (200 OK)

```json
{
  "range": {
    "start": "2026-01",
    "end": "2026-04"
  },
  "alert_count": 5,
  "critical_deviations": [
    {
      "type": "category",
      "category": "Transporte",
      "month": "2026-02",
      "deviation_percent": 91.7,
      "severity": "critical",
      "message": "Transporte en feb 2026 aumentó 91.7% vs ene 2026"
    },
    {
      "type": "category",
      "category": "Servicios",
      "month": "2026-02",
      "deviation_percent": 26.7,
      "severity": "critical",
      "message": "Servicios en feb 2026 aumentó 26.7% vs ene 2026"
    },
    {
      "type": "total_expenses",
      "month": "2026-02",
      "deviation_percent": 26.7,
      "severity": "critical",
      "message": "Gastos totales en feb 2026 aumentaron 26.7% vs ene 2026"
    }
  ]
}
```

---

## Notes

- Rango mínimo: 2 meses
- Rango máximo: 12 meses
- Desviación crítica: > 20%
- Cálculo: `((current - previous) / previous) * 100`
- Si `previous = 0`, mostrar desviación como "N/A" o "∞"
- Solo meses cerrados o abiertos (sin borrador) se incluyen en la comparativa
