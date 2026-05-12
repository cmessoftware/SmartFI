## Why

Actualmente la UI mezcla referencias de marca "Finly" y "SmartFI" en distintas pantallas. Esta inconsistencia genera confusión de identidad visual y documentación.

## What Changes

- Reemplazar labels visibles de marca "Finly" por "SmartFI" en frontend.
- Unificar textos de login, encabezados, títulos y metadatos visibles al usuario.
- Validar consistencia en alt/title de logo y elementos de navegación.

## Capabilities

### New Capabilities

- `ui-branding-consistency`: Todas las pantallas visibles del frontend muestran marca "SmartFI" de forma consistente.

### Modified Capabilities

- `login-branding`: El login muestra "SmartFI" y no "Finly".
- `app-shell-branding`: Encabezados y textos de navegación reflejan la marca unificada.

## Impact

- **Frontend** (`frontend/src/`): componentes de login, layout, headers y textos de marca.
- **QA visual**: revisión de textos y atributos `alt`/`title` relacionados a marca.
