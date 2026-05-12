## ADDED Requirements

### Requirement: Versionado visible en interfaz
La UI SHALL mostrar un identificador de versión con formato `X.Y.Z+abcde`, donde `X.Y.Z` corresponde a SemVer y `abcde` al short commit id de 5 caracteres.

#### Scenario: Render de versión en login o footer
- **WHEN** el usuario abre la aplicación
- **THEN** se muestra una etiqueta de versión con formato `X.Y.Z+abcde`

### Requirement: Coherencia de versión entre entornos
El valor de versión mostrado SHALL ser consistente con la build activa tanto en dev como en qa/docker.

#### Scenario: Entorno dev
- **WHEN** la app corre en `http://localhost:5173`
- **THEN** la versión visible respeta el formato y corresponde a la build de desarrollo

#### Scenario: Entorno qa/docker
- **WHEN** la app corre en `http://localhost:3000`
- **THEN** la versión visible respeta el formato y corresponde a la imagen desplegada
