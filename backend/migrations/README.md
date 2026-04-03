# ⚠️ ATENCIÓN: Migraciones SQL Manuales OBSOLETAS

**Fecha de deprecación:** 26 de marzo de 2026

---

## ❌ NO USAR ESTOS ARCHIVOS

Los archivos SQL en esta carpeta están **OBSOLETOS** y solo se mantienen como referencia histórica.

---

## ✅ Usar Alembic en su lugar

Todas las migraciones de base de datos ahora se gestionan con **Alembic**.

### Comandos para gestionar migraciones:

```bash
cd backend

# Generar nueva migración automáticamente
alembic revision --autogenerate -m "descripcion_del_cambio"

# Aplicar migraciones pendientes
alembic upgrade head

# Ver estado actual
alembic current

# Ver historial
alembic history
```

---

## Archivos Históricos (SOLO REFERENCIA)

- `001_add_debts_module.sql` - Creación inicial de módulo de deudas
- `002_add_budget_item_columns.sql` - Refactor Budget Model (Fase A)
- `002_add_pago_parcial_status.sql` - Agregar status "Pago parcial"
- `002_remove_partida_field.sql` - Eliminar campo "partida"

**Migración equivalente en Alembic:**
- `alembic/versions/2b125aaa8fae_sync_database_status_enum.py`
- `alembic/versions/e10c0b8c5dbe_add_credit_card_management_module.py`

---

## Por qué Alembic?

✅ Control de versiones automático  
✅ Rollback seguro (`alembic downgrade`)  
✅ Tracking de estado en DB (`alembic_version` table)  
✅ Generación automática desde modelos SQLAlchemy  
✅ Manejo correcto de dependencias y orden de ejecución  

---

## Documentación Completa

Ver `backend/ALEMBIC_GUIDE.md` para guía completa de uso.

Ver `DEVELOPMENT_GUIDELINES.md` en la raíz del proyecto para reglas globales.

---

**IMPORTANTE:** Si necesitas aplicar estos cambios SQL a una base de datos nueva, usa Alembic en su lugar:

```bash
cd backend
alembic upgrade head
```

Esto aplicará TODAS las migraciones correctamente en orden.
