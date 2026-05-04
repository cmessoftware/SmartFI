## ADDED Requirements

### Requirement: Bloqueo de cargas fuera de ventana cierre-vencimiento
El sistema SHALL bloquear la carga manual y CSV de compras fuera de la ventana válida del periodo activo (desde el `billing_date` del periodo anterior hasta el `due_date` del periodo actual). Usuarios con rol `admin` o `manager` SHALL poder hacer override con confirmación explícita.

#### Scenario: Carga dentro de ventana válida
- **WHEN** un usuario registra una compra con fecha dentro de la ventana del periodo activo
- **THEN** el sistema acepta la carga sin restricciones

#### Scenario: Carga fuera de ventana — usuario sin permisos
- **WHEN** un usuario con rol `user` intenta registrar una compra fuera de la ventana del periodo activo
- **THEN** el sistema rechaza la carga con mensaje indicando la ventana válida

#### Scenario: Carga fuera de ventana — usuario con override
- **WHEN** un usuario con rol `admin` o `manager` intenta registrar fuera de ventana y confirma el override
- **THEN** el sistema acepta la carga
