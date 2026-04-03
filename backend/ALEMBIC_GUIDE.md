# Guía de Migraciones con Alembic

## Configuración Completada ✅

Alembic está configurado y listo para usar. Las migraciones se gestionan automáticamente desde los modelos SQLAlchemy en `database/database.py`.

## Comandos Básicos

### 1. Generar una nueva migración automática
```bash
cd backend
alembic revision --autogenerate -m "descripcion_del_cambio"
```

Esto compara los modelos en `database.py` con el estado actual de PostgreSQL y genera automáticamente el código de migración.

### 2. Aplicar migraciones pendientes
```bash
alembic upgrade head
```

### 3. Ver estado actual
```bash
alembic current
```

### 4. Ver historial de migraciones
```bash
alembic history
```

### 5. Revertir última migración
```bash
alembic downgrade -1
```

## Modificar Enums (Caso Especial)

SQLAlchemy/Alembic **no puede modificar enums automáticamente**. Para agregar valores a un enum existente:

### Ejemplo: Agregar valor a DebtStatus

1. **Actualiza el modelo** en `database/database.py`:
```python
class DebtStatus(str, enum.Enum):
    PENDIENTE = "PENDIENTE"
    PAGO_PARCIAL = "Pago parcial"  # ← Nuevo valor
    PAGADA = "PAGADA"
    VENCIDA = "VENCIDA"
```

2. **Crea migración manual**:
```bash
alembic revision -m "add_pago_parcial_to_debtstatus"
```

3. **Edita el archivo generado** en `alembic/versions/`:
```python
def upgrade() -> None:
    # Usar op.execute para ALTER TYPE
    op.execute("ALTER TYPE debtstatus ADD VALUE IF NOT EXISTS 'Pago parcial'")

def downgrade() -> None:
    # PostgreSQL no permite eliminar valores de enum
    # Opción: recrear el enum completo (complejo)
    pass
```

4. **Aplica la migración**:
```bash
alembic upgrade head
```

## Flujo de Trabajo Recomendado

1. Modifica los modelos en `database/database.py`
2. Genera migración: `alembic revision --autogenerate -m "cambio"`
3. **Revisa el archivo generado** en `alembic/versions/` (puede necesitar ajustes)
4. Aplica: `alembic upgrade head`
5. Confirma en PostgreSQL que los cambios se aplicaron correctamente

## Archivos Importantes

- **alembic.ini**: Configuración de Alembic
- **alembic/env.py**: Configuración de conexión y metadatos (usa DATABASE_URL del .env)
- **alembic/versions/**: Archivos de migración generados
- **database/database.py**: Modelos SQLAlchemy (fuente de verdad)

## Estado Actual

- ✅ Migración inicial aplicada (2b125aaa8fae) - Sync database status enum
- ✅ Migración Credit Card Module (e10c0b8c5dbe) - Add credit card management module
- ✅ Enum `debtstatus` con valores: PENDIENTE, PAGADA, VENCIDA, Pago parcial
- ✅ Enum `budgettype` con valores: OBLIGATION, VARIABLE
- ✅ Enum `flowtype` con valores: Gasto, Ingreso
- ✅ Enum `assignmentstatus` con valores: ASIGNADA_MANUAL, ASIGNADA_AUTOMATICA, NO_PLANIFICADA, REASIGNADA_AUTOMATICA
- ✅ Enum `installmentstatus` con valores: PENDING, PAID
- ✅ Enum `statementstatus` con valores: PENDING, PARTIALLY_PAID, PAID, OVERDUE
- ✅ Enum `installmentplantype` con valores: REGULAR, PROMOTIONAL, ZERO_INTEREST
- ✅ Tablas: users, debts, transactions, categories
- ✅ Tablas Credit Card Module: credit_cards, credit_card_purchases, installment_plans, installment_schedule, credit_card_statements, credit_card_payments
- ✅ Foreign key: transactions.debt_id → debts.id
- ✅ Foreign keys Credit Card: installment_plans.debt_id → debts.id, credit_card_purchases.transaction_id → transactions.id

## Notas

- Las migraciones SQL manuales en `migrations/` están **obsoletas**. Usar Alembic de ahora en adelante.
- Alembic mantiene una tabla `alembic_version` en PostgreSQL para tracking.
- Siempre revisar el código autogenerado antes de aplicar migraciones.
