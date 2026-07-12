# SmartFI - OpenSpec Project Baseline

## 1. Propósito del proyecto

SmartFI (Finly) es una aplicación web para gestión de finanzas personales con foco en:
- Registro de ingresos y gastos.
- Presupuesto mensual y obligaciones.
- Gestión de deudas no tarjeta (DebtRecord).
- Gestión de tarjetas de crédito (compras, cuotas, períodos, pagos).
- Reportes y cierre/apertura de mes.

Este archivo define el contexto base para trabajar con OpenSpec de forma formal y consistente.

## 2. Stack y arquitectura

### Backend
- Framework: FastAPI.
- ORM: SQLAlchemy.
- Entorno Python sugerido: conda env finly.
- Punto de entrada principal: backend/main.py.
- Lógica de negocio: backend/services.

### Frontend
- Framework: React + Vite.
- Cliente API: frontend/src/services/api.js.
- UI: frontend/src/components.

### Base de datos
- Motor: PostgreSQL.
- Entorno local frecuente: Docker Compose.
- Migraciones: Alembic (obligatorio para cambios de esquema y datos).

## 3. Principios de gobierno técnico

1. Todo cambio de esquema o datos de BD se realiza por Alembic.
2. El modelo SQLAlchemy es la fuente de verdad previa a la migración.
3. Los cambios funcionales relevantes deben nacer como change de OpenSpec.
4. Cada change debe tener proposal.md, design.md y tasks.md.
5. Las tareas deben mapearse a issues de Gitea (formato [#id]).

## 4. Módulos funcionales relevantes

- Seguridad y usuarios:
  - backend/security
- Presupuesto y flujo mensual:
  - backend/main.py
  - backend/services/debt_service.py
  - frontend/src/components/DebtManager.jsx
- Deudas no tarjeta (DebtRecord):
  - backend/services/debt_record_service.py
  - frontend/src/components/NewDebtModal.jsx
  - frontend/src/components/EditDebtModal.jsx
- Tarjetas de crédito:
  - backend/services/credit_card_service.py
  - frontend/src/components/CreditCardManager.jsx

## 5. Convenciones de cambios OpenSpec

Cada change en openspec/changes/<change-name> debe contener:
- proposal.md: por qué y qué cambia.
- design.md: diseño técnico y decisiones.
- tasks.md: plan de implementación ejecutable.
- specs/: capacidades nuevas o modificadas.

Estructura mínima esperada en proposal.md:
- Why
- What Changes
- Capabilities (new/modified)
- Impact

Estructura mínima esperada en design.md:
- módulos afectados
- cambios de modelo de datos
- contrato API
- consideraciones de seguridad

Estructura mínima esperada en tasks.md:
- agrupación por Backend, Frontend y Testing
- cada tarea con referencia a issue de Gitea [#id]

## 6. Flujo formal recomendado

1. Explorar alcance y validar contexto del problema.
2. Crear change OpenSpec (nombre en kebab-case).
3. Redactar proposal.md.
4. Redactar design.md.
5. Redactar tasks.md con trazabilidad a Gitea.
6. Implementar por etapas siguiendo tasks.md, incluyendo pruebas y validaciones técnicas dentro de Apply.
7. Archivar el change cuando esté completamente implementado.

Si tasks.md no existe o está incompleto al iniciar Apply, se debe detener la implementación y completar tasks.md antes de continuar.

## 7. Criterios de aceptación para considerar un change listo

- Proposal, design y tasks completos y coherentes.
- Reglas de base de datos cumplidas (Alembic).
- Cambios de API y frontend documentados.
- Tareas vinculadas a issues de Gitea.
- Todas las tareas con estado explícito al detener una implementación parcial (por ejemplo: [done], [in-progress]).
- Validaciones técnicas ejecutadas.
- Riesgos y decisiones registradas en design.md.

## 8. Fuentes de contexto del repositorio

- README principal del proyecto.
- backend/main.py
- backend/database/database.py
- backend/services/*
- frontend/src/services/api.js
- frontend/src/components/*
- openspec/config.yaml

Este baseline debe actualizarse cuando cambie la arquitectura, el proceso de entrega o las reglas de gobierno técnico.
