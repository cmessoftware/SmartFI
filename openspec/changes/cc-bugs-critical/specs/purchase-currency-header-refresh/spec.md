## ADDED Requirements

### Requirement: Actualización inmediata del header al cambiar moneda
El frontend SHALL refrescar el resumen de la tarjeta (`GET /api/credit-cards/{card_id}/summary`) inmediatamente después de guardar exitosamente una edición que modifica la moneda de una compra, sin requerir recarga de página.

#### Scenario: Header refleja cambio tras editar moneda
- **WHEN** el usuario edita la moneda de una compra y la API retorna 200
- **THEN** el componente header de la tarjeta muestra el Total Pendiente actualizado en la misma sesión, dentro de los 2 segundos posteriores al guardado
