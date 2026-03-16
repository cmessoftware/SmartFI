# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Agregado
- **Módulo de Presupuesto (Gestión de Deudas)**
  - Nuevo componente `DebtManager.jsx` para gestión completa de items de presupuesto
  - CRUD completo: crear, editar, visualizar y eliminar items de presupuesto
  - Vista de resumen con tarjetas para estados: Pendiente, Pago Parcial, Vencidas y Pagadas
  - Cálculo automático de progreso de pago (porcentaje y monto)
  - Visualización con badges de colores según estado
  - Campo `monto_pagado` de solo lectura (se calcula automáticamente)
  
- **Sistema de Estados de Presupuesto**
  - Estado `Pago parcial` para items con pagos incompletos
  - Estados: PENDIENTE, PAGO_PARCIAL, PAGADA, VENCIDA
  - Sincronización entre PostgreSQL enum y Python DebtStatus
  - Cálculo automático de estado basado en monto pagado y fecha de vencimiento
  
- **Vinculación Transacciones-Presupuesto**
  - Dropdown en formulario de gastos para vincular a items de presupuesto
  - Actualización automática de `monto_pagado` al crear/eliminar transacciones vinculadas
  - Actualización automática de estado al modificar pagos
  - Columna "Presupuesto" en Reportes con badge visual 📊 Vinculado
  
- **Filtros Avanzados en Reportes**
  - Filtro por presupuesto con opciones:
    - Todas (sin filtro)
    - 📊 Vinculadas (solo transacciones con presupuesto)
    - ⭕ No vinculadas (solo transacciones sin presupuesto)
    - Lista de presupuestos específicos (filtrar por item individual)
  - Grid responsivo de 5 columnas para filtros
  
- **Sistema de Migraciones con Alembic**
  - Alembic 1.13.1 configurado para gestión de migraciones
  - `ALEMBIC_GUIDE.md` con documentación completa
  - Migración inicial para sincronización de schema
  - Soporte para auto-migración desde modelos SQLAlchemy
  
- **API Backend - Endpoints de Presupuesto**
  - `GET /api/debts` - Listar todos los items de presupuesto
  - `GET /api/debts/summary` - Resumen con montos por estado
  - `POST /api/debts` - Crear item de presupuesto
  - `PUT /api/debts/{id}` - Actualizar item
  - `DELETE /api/debts/{id}` - Eliminar (con validación de transacciones)
  
- **Servicio de Deudas (DebtService)**
  - `backend/services/debt_service.py` con lógica de negocio completa
  - Cálculo de resumen con montos pendientes por estado
  - Validación de eliminación (previene si hay transacciones vinculadas)
  - Serialización correcta de enums con `.value`
  
- **Utilidades de Fechas**
  - `frontend/src/utils/dateUtils.js` con funciones:
    - `formatDate()`: Convierte a formato DD/MM/YYYY para display
    - `toISODate()`: Convierte a formato YYYY-MM-DD para inputs HTML
  - Soporte para detección automática de formato con regex

### Modificado
- **TransactionReport.jsx**
  - Refactorizado para incluir filtro por presupuesto
  - Grid de filtros expandido a 5 columnas (md:grid-cols-2 lg:grid-cols-5)
  - Carga dinámica de items de presupuesto para dropdown
  - Lógica de filtrado mejorada con soporte para debt_id específico
  
- **TransactionForm.jsx**
  - Agregado dropdown de presupuesto para gastos
  - Filtrado de items activos (PENDIENTE, VENCIDA, Pago parcial)
  - Envío de `debt_id` al crear transacción
  
- **EditTransactionModal.jsx**
  - Conversión de fechas a formato ISO para compatibilidad con input[type="date"]
  - Uso de `toISODate()` utility function
  
- **DebtManager.jsx**
  - Conversión de fechas en handleEdit usando `toISODate()`
  - Campo monto_pagado con clases: `readOnly disabled bg-gray-50 cursor-not-allowed`
  
- **App.jsx**
  - `deleteTransaction()` ahora recarga todos los datos para actualizar estados de presupuesto
  - Mejora en sincronización de datos tras eliminaciones
  
- **Toast.jsx**
  - Eliminada posición `fixed top-4 right-4` duplicada
  - Posicionamiento manejado por ToastContainer padre
  
- **backend/database/database.py**
  - Enum `DebtStatus` con valores sincronizados con PostgreSQL
  - `SQLEnum` con `values_callable` para serialización correcta
  - Modelo `Debt` completo con todos los campos de presupuesto
  - Campo `debt_id` agregado al modelo Transaction (ForeignKey nullable)
  
- **backend/services/database_service.py**
  - `add_transaction()`: Actualiza monto_pagado y recalcula estado si debt_id presente
  - `delete_transaction()`: Decrementa monto_pagado y recalcula estado
  - `get_all_transactions()`: Incluye debt_id en serialización
  
- **backend/main.py**
  - Endpoints de debts con validación de roles
  - DELETE valida que no haya transacciones vinculadas (HTTP 400)
  - Importación y uso de DebtService
  
- **backend/requirements.txt**
  - Agregado `alembic==1.13.1`

### Corregido
- **Bug de Estado "Pago parcial"**
  - Badge ahora muestra correctamente "Pago parcial" (azul) en lugar de "Pendiente"
  - Sincronización de enum values entre PostgreSQL y Python
  
- **Bug de Array Vacío en Presupuesto**
  - Eliminado conflicto de Docker container interceptando puerto 8000
  - Asegurada carga correcta de items desde backend local
  
- **Serialización de Enums**
  - Agregado `.value` accessor en get_all_debts() para JSON compatibility
  - Configurado `values_callable` en SQLEnum para correcto mapeo
  
- **Posicionamiento de Toasts**
  - Toasts ahora visibles en viewport (removida posición fixed duplicada)
  - Mensajes de error visibles correctamente
  
- **Formato de Fechas en Edición**
  - Inputs de tipo date ahora reciben formato YYYY-MM-DD correcto
  - No más warnings en consola por formato inválido
  
- **Filtro de Transacciones para Vinculación**
  - TransactionForm ahora incluye items con estado "Pago parcial" en dropdown
  - Filtro: `PENDIENTE || VENCIDA || "Pago parcial"`
  
- **Actualización de Estado tras Eliminación**
  - Delete transaction ahora recalcula estado de presupuesto automáticamente
  - Full data reload en frontend asegura sincronización
  
- **Errores en Consola**
  - Eliminada referencia a `env-config.js` (404) en index.html
  - Removidos debug console.logs de api.js
  
- **NaN en Resumen de Presupuesto**
  - `get_debt_summary()` ahora calcula pending_amount, partial_amount, overdue_amount
  - Agregaciones SQL: `SUM(monto_total - monto_pagado)` por estado
  - Valores default: `or 0` para prevenir None
  
- **Importación en TransactionReport**
  - Cambiado `import * as debtsAPI` a `import { debtsAPI }`
  - Corregido error "debtsAPI.getDebts is not a function"

### Técnico
- **Migraciones de Base de Datos**
  - PostgreSQL enum `debtstatus` con valores: PENDIENTE, PAGADA, VENCIDA, 'Pago parcial'
  - Alembic revision inicial: `2b125aaa8fae_sync_database_status_enum.py`
  - Foreign keys y indexes correctamente gestionados
  
- **Docker**
  - Build exitoso con frontend y backend actualizados
  - Healthchecks configurados para todos los servicios
  - Volúmenes persistentes para PostgreSQL
  
- **Testing**
  - Scripts de test en backend/ para validación de estados
  - Verificación de enum synchronization

### Documentación
- **ALEMBIC_GUIDE.md**: Guía completa de uso de Alembic
  - Comandos básicos (revision, upgrade, downgrade)
  - Manejo de enums
  - Mejores prácticas
  - Ejemplos de uso

## [0.1.0] - Versión Inicial
### Agregado
- Sistema base de gestión financiera personal
- Módulo de transacciones (Ingresos/Gastos)
- Dashboard con resumen financiero
- Reportes con gráficos (Pie y Bar charts)
- Autenticación con JWT
- Base de datos PostgreSQL
- Docker Compose para deployment
- Frontend React con TailwindCSS
- Backend FastAPI con SQLAlchemy
- Google Sheets sync (backup opcional)

---

## Formato de Versiones

- **MAJOR**: Cambios incompatibles en la API
- **MINOR**: Funcionalidad nueva compatible con versiones anteriores
- **PATCH**: Correcciones de bugs compatibles con versiones anteriores

## Tipos de Cambios

- `Agregado` para funcionalidades nuevas
- `Modificado` para cambios en funcionalidades existentes
- `Obsoleto` para funcionalidades que serán removidas
- `Eliminado` para funcionalidades removidas
- `Corregido` para corrección de bugs
- `Seguridad` para vulnerabilidades corregidas
