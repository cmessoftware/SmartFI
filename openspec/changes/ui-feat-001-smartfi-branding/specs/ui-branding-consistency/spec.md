## ADDED Requirements

### Requirement: Unificación de marca visible a SmartFI
El frontend SHALL mostrar la marca "SmartFI" en todos los labels visibles al usuario donde hoy figure "Finly".

#### Scenario: Login renderiza marca unificada
- **WHEN** el usuario abre la pantalla de login
- **THEN** se visualiza "SmartFI" como marca principal y no "Finly"

#### Scenario: Navegación y encabezados sin marca legacy
- **WHEN** el usuario recorre vistas principales de la app
- **THEN** los encabezados y textos de navegación no muestran referencias "Finly"

### Requirement: Consistencia semántica de marca en assets
Los atributos semánticos de marca en elementos visuales (por ejemplo `alt`/`title`) SHALL reflejar "SmartFI".

#### Scenario: Logo con alt consistente
- **WHEN** se renderiza el logo en login u otras vistas
- **THEN** su atributo `alt` utiliza la marca vigente "SmartFI"
