## Why

No existe un indicador de versión visible para usuarios y QA que permita identificar rápidamente la build en ejecución. Esto dificulta trazabilidad de despliegues y validación de fixes.

## What Changes

- Mostrar en UI un identificador de versión con formato `X.Y.Z+abcde`.
- Tomar `X.Y.Z` desde versión de aplicación y `abcde` desde short commit id (5 caracteres).
- Mantener el valor disponible tanto en entorno dev como docker/qa.

## Capabilities

### New Capabilities

- `ui-version-badge`: La aplicación muestra versión visible con formato SemVer + short SHA.

### Modified Capabilities

- `release-traceability-ui`: QA y usuarios técnicos pueden identificar build activa desde la interfaz.

## Impact

- **Frontend** (`frontend/src/`): componente o badge de versión en login/footer/header.
- **Build/Env** (`frontend/`, `docker`): inyección de versión y short commit para renderizado.
- **QA**: validación visual del formato `X.Y.Z+abcde`.
