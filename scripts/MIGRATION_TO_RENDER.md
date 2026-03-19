# 🚀 Database Migration to Render

Script para migrar datos desde la base de datos local PostgreSQL a Render.

## 📋 Prerequisitos

1. **PostgreSQL Client Tools instalado** (incluye `psql` y `pg_dump`)
   - Windows: [PostgreSQL Downloads](https://www.postgresql.org/download/windows/)
   - Solo necesitas las herramientas cliente, no el servidor completo

2. **Docker Desktop corriendo** (para acceder a la base local)

3. **URL de conexión de Render** 
   - Obtén la "Internal Database URL" desde Render Dashboard
   - Formato: `postgresql://user:password@host:port/database`

## 🎯 Uso del Script

### Opción 1: Modo Completo (Recomendado)

```powershell
.\scripts\migrate-to-render.ps1 -RenderDatabaseUrl "postgresql://user:password@host:port/database"
```

El script te pedirá confirmación antes de hacer cambios.

### Opción 2: Dry Run (Prueba sin cambios)

```powershell
.\scripts\migrate-to-render.ps1 -DryRun
```

Te muestra qué haría sin ejecutar cambios reales.

### Opción 3: Sin Backup de Render

```powershell
.\scripts\migrate-to-render.ps1 -RenderDatabaseUrl "postgresql://..." -SkipBackup
```

Salta el backup de seguridad de Render (no recomendado).

### Opción 4: Interactivo (sin URL)

```powershell
.\scripts\migrate-to-render.ps1
```

El script te pedirá la URL de Render interactivamente.

## 🔄 Proceso del Script

El script realiza estos pasos:

1. ✅ **Verifica** que la base local esté corriendo
2. 📦 **Exporta** la base local a un archivo SQL
3. 📊 **Muestra** resumen de datos (transacciones, budget items, etc.)
4. 💾 **Backup** de la base Render (opcional pero recomendado)
5. 📥 **Importa** los datos a Render
6. 🔍 **Verifica** que la migración fue exitosa

## 📁 Backups

Los backups se guardan en:
```
Finly/backups/
├── local_backup_20260319_153045.sql
└── render_backup_before_migration_20260319_153045.sql
```

**⚠️ IMPORTANTE:** Guarda estos backups por si necesitas revertir cambios.

## 🔑 Obtener URL de Render

1. Ve a tu dashboard de Render: https://dashboard.render.com
2. Selecciona tu servicio PostgreSQL
3. En la pestaña "Info", busca **"Internal Database URL"**
4. Copia la URL completa (incluye usuario y contraseña)

![Render Database URL](https://docs.render.com/images/postgresql-connection-string.png)

## ⚠️ Consideraciones Importantes

### Antes de Migrar:

- ✅ Asegúrate de que tu base local esté actualizada
- ✅ Verifica que los cambios recientes estén guardados
- ✅ Ten a mano las credenciales de Render
- ✅ Lee los mensajes de confirmación cuidadosamente

### Durante la Migración:

- ⏱️ La migración puede tomar varios minutos dependiendo del volumen de datos
- 🔒 No cierres la terminal mientras corre el script
- 📶 Mantén conexión a internet estable

### Después de Migrar:

- ✅ Verifica los datos en Render
- ✅ Prueba login y funcionalidades principales
- ✅ Guarda los backups en lugar seguro
- ✅ Actualiza variables de entorno si es necesario

## 🛠️ Troubleshooting

### Error: "psql command not found"

**Solución:** Instala PostgreSQL Client Tools:
- Windows: https://www.postgresql.org/download/windows/
- Después de instalar, agrega `C:\Program Files\PostgreSQL\XX\bin` al PATH

### Error: "Local PostgreSQL container is not running"

**Solución:**
```powershell
docker-compose up -d postgres
```

### Error: "Connection refused" al conectar a Render

**Causas posibles:**
1. URL de Render incorrecta → Verifica en dashboard
2. Firewall bloqueando → Revisa configuración de red
3. Base de datos pausada → Actívala desde Render dashboard

### Error: "FATAL: password authentication failed"

**Solución:** Verifica que la URL incluye el usuario y password correctos de Render.

## 📝 Ejemplo Completo

```powershell
# Paso 1: Asegurar que Docker está corriendo
docker-compose up -d postgres

# Paso 2: Hacer dry run primero (opcional)
.\scripts\migrate-to-render.ps1 -DryRun

# Paso 3: Ejecutar migración real
.\scripts\migrate-to-render.ps1 -RenderDatabaseUrl "postgresql://finly_user:secretpass123@dpg-abc123.oregon-postgres.render.com:5432/finly_db"

# El script preguntará:
# "⚠️  WARNING: This will REPLACE all data in the Render database!"
# "Continue? (yes/no):"
# 
# Responder: yes

# Paso 4: Verificar en Render
# Abre tu app en Render y verifica que los datos estén correctos
```

## 🔄 Migrar Cambios Incrementales

Si solo quieres actualizar algunos registros (no todo):

```powershell
# Opción 1: Exportar solo nuevos datos
docker exec -e PGPASSWORD=admin123 finly-postgres pg_dump -h localhost -p 5432 -U admin -d fin_per_db -t transactions --data-only --column-inserts > new_data.sql

# Opción 2: Ejecutar consultas específicas
psql "postgresql://..." -c "INSERT INTO transactions (...) VALUES (...);"
```

## 🆘 Revertir Migración

Si algo sale mal y necesitas revertir:

```powershell
# Restaurar desde el backup de Render
psql "postgresql://render-url" < backups/render_backup_before_migration_20260319_153045.sql
```

## 📞 Soporte

Si tienes problemas:
1. Revisa los mensajes de error del script
2. Verifica los logs de Render
3. Consulta la documentación de Render: https://docs.render.com/databases
4. Revisa los backups en `Finly/backups/`

---

**✅ Última actualización:** Marzo 2026  
**🔗 Repositorio:** https://github.com/cmessoftware/finly
