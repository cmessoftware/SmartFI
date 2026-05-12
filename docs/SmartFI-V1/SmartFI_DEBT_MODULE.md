## Debt module features ang bugs

## Features (IDs)

| ID | Estado | Resumen | Objetivo |
|---|---|---|---|
| DBT-FEAT-01 | 📋 Backlog | **Crear módulo de deudas** | Copiar UI de Widget de Presupuesto |
| DBT-FEAT-02 | 📋 Backlog | **Registrar gastos de tarjeta de crédito** | 
1. Pagos con Forma de Pago = Crédito: registrarse en periodo actual de la tarjeta (datos del módulo de tarjeta de crédito)
2. Registrar como deuda tipo Tarjeta de Crédito en modulo DEBT |
| DBT-FEAT-03 | 📋 Backlog | **Registrar deudas externas** | Deudas que no se son de tarjeta de crédito (acreedor, monto, cuotas, intereses , fecha inicio) |
| DBT-FEAT-04 | 📋 Backlog | **Registrar deudas especiales** | Deudas que no se son de tarjeta de crédito ni de DBT-FEAT-04 (acreedor, monto, feacha inicio, regla de indexación)  |




## 1. Objetivo

Evolucionar el sistema actual para:

* Separar **presupuesto**, **gasto** y **deuda**.
* Convertir el módulo de tarjeta en un **motor financiero en tiempo real**.
* Incorporar **proyecciones de cierre** y **control de límite de crédito**.
* Exponer métricas operativas en un **dashboard unificado**.

---

## 2. Principios de diseño

1. Un gasto no es deuda.
2. Un gasto con crédito genera deuda.
3. El presupuesto es intención, no ejecución.
4. La tarjeta es un sistema de diferimiento, no un gasto directo.
5. Toda proyección debe ser reproducible y auditable.

Restricción:

* NO incluir deuda dentro de Budget.

---