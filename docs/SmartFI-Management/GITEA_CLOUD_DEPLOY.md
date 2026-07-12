# Gitea Cloud Deploy (Render + Postgres Gratis)

Esta guia describe una implementacion de Gitea en Render usando Postgres gratis externo (Neon o Supabase).

## 1. Arquitectura recomendada

1. Gitea en Render (servicio web Docker).
2. Base de datos Postgres gratis en Neon o Supabase.
3. Volumen persistente en Render montado en /data.

## 2. Archivos en este repositorio

1. Blueprint Render para Gitea:
- deployment/gitea/render.gitea.yaml

## 3. Provisionar Postgres gratis

### Opcion A: Neon

1. Crear proyecto en Neon.
2. Crear base de datos para Gitea.
3. Copiar credenciales: host, puerto, db, user, password.
4. Usar SSL mode require.

### Opcion B: Supabase

1. Crear proyecto.
2. Obtener connection string Postgres.
3. Separar host, db, user y password para variables de Render.
4. Usar SSL mode require.

## 4. Desplegar en Render

1. En Render, crear "Blueprint" desde este repo o crear "Web Service" manual.
2. Usar deployment/gitea/render.gitea.yaml.
3. Configurar variables sync:false:
- GITEA__server__DOMAIN
- GITEA__server__ROOT_URL
- GITEA__database__HOST
- GITEA__database__NAME
- GITEA__database__USER
- GITEA__database__PASSWD

Ejemplo:
- GITEA__server__DOMAIN = tu-gitea.onrender.com
- GITEA__server__ROOT_URL = https://tu-gitea.onrender.com/
- GITEA__database__HOST = ep-xxxx.neon.tech:5432

## 5. Primera inicializacion

1. Abrir URL publica de Gitea.
2. Completar asistente inicial.
3. Crear usuario admin.
4. Verificar login.
5. Luego fijar INSTALL_LOCK=true en Render.

## 6. Hardening minimo recomendado

1. Deshabilitar registro publico (ya viene en true).
2. Mantener OpenID sign-in deshabilitado salvo necesidad.
3. Configurar correo SMTP para recupero de cuentas.
4. Configurar backups de /data y DB.

## 7. Backups

1. Base de datos:
- Backup logico diario (pg_dump) o snapshots del proveedor.

2. Datos Gitea:
- Backup del volumen /data (repos, adjuntos, config).

3. Restauracion de prueba:
- Ejecutar al menos una prueba de restore por mes.

## 8. Limitaciones de planes gratis

1. El servicio puede entrar en sleep por inactividad.
2. Puede haber limites de CPU y almacenamiento.
3. SSH nativo de Gitea no siempre es practico en PaaS free.
4. Recomendado usar Git por HTTPS + Personal Access Tokens.

## 9. Checklist rapido de validacion

1. La app responde en /.
2. Login admin funciona.
3. Se puede crear repo y hacer push por HTTPS.
4. Se puede abrir y cerrar issue en Gitea.
5. El volumen /data persiste tras redeploy.
6. Conexion a Postgres estable con SSL.

## 10. Integracion con este repo

Esta guia complementa:
- docs/SmartFI-Management/SmartFI_GITEA_OPENSPEC_INTEGRATION.md

Objetivo:
- OpenSpec para especificacion.
- Gitea para ejecucion y trazabilidad.
