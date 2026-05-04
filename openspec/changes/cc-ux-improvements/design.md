## Context

La tabla de compras en el frontend es el componente central del módulo de tarjetas. Actualmente pagina de a 10 (debería ser 5), no permite ordenar por monto, no distingue visualmente entre cuotas y pagos únicos, y carece de campo de detalle libre. Estos issues afectan la legibilidad y productividad diaria del usuario.

## Goals / Non-Goals

**Goals:**
- Corregir paginación (5 ítems).
- Agregar ordenamiento por monto.
- Diferenciar cuotas y pagos únicos visualmente.
- Tooltip de detalle por compra.
- Ocultar combo tipo de plan cuando no aplica.
- Agregar campo `detail` (texto libre) en formulario y BD.

**Non-Goals:**
- No agregar filtros avanzados ni búsqueda full-text.
- No refactorizar la arquitectura del componente de tabla.

## Decisions

### D1: Paginación fija en 5 ítems (no configurable en esta iteración)

La paginación será 5 ítems fijos. FEAT-009 (paginación configurable) se incluye en el mismo change pero como mejora futura opcional; la implementación inicial usa 5 como default.

### D2: Campo `detail` como columna nullable en BD

Se agrega `detail VARCHAR(500) NULL` a `credit_card_purchases`. Migration Alembic. El campo es opcional; no rompe compras existentes.

### D3: Tooltip via CSS/HTML nativo o librería existente

Se usará el mecanismo de tooltip que ya esté disponible en el proyecto (Tailwind + title attr o componente UI existente). No se instalan nuevas dependencias.

## Risks / Trade-offs

- [Risk: Paginación a 5 puede parecer restrictiva para usuarios con muchas compras] → Mitigación: el ordenamiento por monto ayuda a encontrar compras relevantes más rápido.
- [Risk: Campo `detail` vacío en datos históricos] → Mitigación: el campo es nullable, sin impacto en datos existentes.

## Migration Plan

1. Crear migración Alembic para agregar columna `detail` a `credit_card_purchases`.
2. Actualizar modelo SQLAlchemy `CreditCardPurchase`.
3. Actualizar endpoints y service para exponer/recibir `detail`.
4. Actualizar formulario y tabla en frontend.
