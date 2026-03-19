# Scripts de Backup y Restauración - Finly

Scripts PowerShell para realizar backup y restauración de la base de datos PostgreSQL de Finly.

## Prerrequisitos

- PostgreSQL Client Tools instalados (incluye `pg_dump` y `psql`)
- Acceso a la base de datos PostgreSQL con credenciales válidas

## 📦 Backup de Base de Datos

### Uso Básico

```powershell
# Backup completo (schema + datos)
.\scripts\backup-database.ps1

# Backup solo del schema (sin datos)
.\scripts\backup-database.ps1 -IncludeData:$false

# Backup con compresión
.\scripts\backup-database.ps1 -CompressOutput
```

### Parámetros Disponibles

| Parámetro | Descripción | Valor por Defecto |
|-----------|-------------|-------------------|
| `-OutputPath` | Directorio donde guardar el backup | `.\backups` |
| `-DbName` | Nombre de la base de datos | `finly_db` |
| `-DbHost` | Host de PostgreSQL | `localhost` |
| `-DbPort` | Puerto de PostgreSQL | `5432` |
| `-DbUser` | Usuario de PostgreSQL | `postgres` |
| `-IncludeData` | Incluir datos (no solo schema) | `$true` |
| `-CompressOutput` | Comprimir el archivo de salida | `$false` |

### Ejemplos

```powershell
# Backup a un directorio específico
.\scripts\backup-database.ps1 -OutputPath "C:\Backups\Finly"

# Backup de base de datos remota
.\scripts\backup-database.ps1 -DbHost "192.168.1.100" -DbUser "admin"

# Backup solo del schema comprimido
.\scripts\backup-database.ps1 -IncludeData:$false -CompressOutput
```

### Salida

El script genera un archivo con el siguiente formato:
```
finly_backup_YYYYMMDD_HHmmss.sql
```

Ejemplo: `finly_backup_20260318_143052.sql`

Si se usa `-CompressOutput`, se genera un archivo `.zip`:
```
finly_backup_20260318_143052.sql.zip
```

---

## 🔄 Restauración de Base de Datos

### Uso Básico

```powershell
# Restaurar desde un archivo de backup
.\scripts\restore-database.ps1 -BackupFile ".\backups\finly_backup_20260318_143052.sql"

# Restaurar eliminando la base de datos existente primero
.\scripts\restore-database.ps1 -BackupFile ".\backups\finly_backup_20260318_143052.sql" -DropExisting
```

### Parámetros Disponibles

| Parámetro | Descripción | Valor por Defecto |
|-----------|-------------|-------------------|
| `-BackupFile` | **Requerido**. Ruta al archivo de backup | - |
| `-DbName` | Nombre de la base de datos destino | `finly_db` |
| `-DbHost` | Host de PostgreSQL | `localhost` |
| `-DbPort` | Puerto de PostgreSQL | `5432` |
| `-DbUser` | Usuario de PostgreSQL | `postgres` |
| `-DropExisting` | Eliminar base de datos existente antes de restaurar | `$false` |

### Ejemplos

```powershell
# Restaurar en base de datos local
.\scripts\restore-database.ps1 -BackupFile ".\backups\finly_backup_20260318_143052.sql"

# Restaurar en servidor remoto con nombre diferente
.\scripts\restore-database.ps1 `
    -BackupFile ".\backups\finly_backup_20260318_143052.sql" `
    -DbHost "192.168.1.200" `
    -DbName "finly_produccion" `
    -DbUser "admin"

# Restaurar desde archivo comprimido
.\scripts\restore-database.ps1 -BackupFile ".\backups\finly_backup_20260318_143052.sql.zip"

# Restaurar reemplazando base de datos existente (⚠️ PELIGROSO)
.\scripts\restore-database.ps1 `
    -BackupFile ".\backups\finly_backup_20260318_143052.sql" `
    -DropExisting
```

### ⚠️ Advertencias

- **`-DropExisting`**: Esta opción **eliminará completamente** la base de datos existente. Use con precaución.
- Siempre verifique el archivo de backup antes de restaurar
- Haga un backup de la base de datos actual antes de restaurar un backup antiguo

---

## 🔐 Seguridad

Los scripts solicitan la contraseña de PostgreSQL de forma interactiva (no se almacena en archivos).

### Variables de Entorno Alternativas

Puede configurar la contraseña usando `.pgpass` (recomendado para automatización):

**Windows**: `%APPDATA%\postgresql\pgpass.conf`
```
localhost:5432:finly_db:postgres:tu_contraseña
```

**Linux/Mac**: `~/.pgpass`
```
localhost:5432:finly_db:postgres:tu_contraseña
```

Establecer permisos apropiados:
```bash
chmod 600 ~/.pgpass
```

---

## 📋 Casos de Uso Comunes

### 1. Backup Regular Automatizado

#### Opción A: Configuración Automática (Recomendado)

Ejecutar el script de configuración como **Administrador**:

```powershell
# Backup diario a las 2:00 AM con compresión
.\scripts\setup-scheduled-backup.ps1

# Personalizar frecuencia y hora
.\scripts\setup-scheduled-backup.ps1 -Frequency Weekly -BackupTime "03:00"

# Configuración completa
.\scripts\setup-scheduled-backup.ps1 `
    -Frequency Daily `
    -BackupTime "02:00" `
    -CompressBackups `
    -RetentionDays 30 `
    -BackupPath "C:\Backups\Finly"
```

El script automáticamente:
- ✅ Crea tarea en Windows Task Scheduler
- ✅ Configura credenciales en `.pgpass`
- ✅ Crea tarea de limpieza de backups antiguos
- ✅ Ejecuta sin intervención manual

#### Opción B: Configuración Manual (Task Scheduler)

1. Abrir **Programador de Tareas** (Task Scheduler)
2. Crear Nueva Tarea:
   - **General**: Nombre "Finly Database Backup"
   - **Desencadenadores**: Diario a las 2:00 AM
   - **Acciones**: 
     - Programa: `powershell.exe`
     - Argumentos: `-NoProfile -ExecutionPolicy Bypass -File "C:\ruta\completa\scripts\backup-database.ps1" -CompressOutput`
   - **Condiciones**: Desmarcar "Iniciar solo si el equipo está conectado"
   - **Configuración**: Tiempo límite de ejecución 2 horas
3. Guardar tarea

### 2. Migración a Nuevo Servidor

```powershell
# En servidor origen
.\scripts\backup-database.ps1 -OutputPath "\\compartido\backups"

# En servidor destino
.\scripts\restore-database.ps1 `
    -BackupFile "\\compartido\backups\finly_backup_20260318_143052.sql" `
    -DbHost "nuevo-servidor" `
    -DropExisting
```

### 3. Backup Antes de Actualización

```powershell
# Antes de ejecutar migraciones o actualizaciones
.\scripts\backup-database.ps1 -OutputPath ".\backups\pre-update"
```

### 4. Restaurar Ambiente de Desarrollo

```powershell
# Clonar producción a desarrollo
.\scripts\backup-database.ps1 -DbHost "prod-server" -DbName "finly_prod"
.\scripts\restore-database.ps1 `
    -BackupFile ".\backups\finly_backup_20260318_143052.sql" `
    -DbName "finly_dev" `
    -DropExisting
```

---

## ⚙️ Administración de Tareas Programadas

### Ver Estado de Tareas

```powershell
# Listar todas las tareas de Finly
Get-ScheduledTask | Where-Object { $_.TaskName -like "*Finly*" }

# Ver detalles de la tarea de backup
Get-ScheduledTask -TaskName "Finly Database Backup"

# Ver información de última ejecución
Get-ScheduledTaskInfo -TaskName "Finly Database Backup"
```

### Ejecutar Manualmente

```powershell
# Ejecutar backup inmediatamente (sin esperar horario)
Start-ScheduledTask -TaskName "Finly Database Backup"

# Ver resultado
Get-ScheduledTaskInfo -TaskName "Finly Database Backup" | Select-Object LastRunTime, LastTaskResult
```

### Modificar Tareas

```powershell
# Deshabilitar tarea temporalmente
Disable-ScheduledTask -TaskName "Finly Database Backup"

# Habilitar nuevamente
Enable-ScheduledTask -TaskName "Finly Database Backup"

# Cambiar horario (requiere recrear trigger)
$newTrigger = New-ScheduledTaskTrigger -Daily -At "04:00"
Set-ScheduledTask -TaskName "Finly Database Backup" -Trigger $newTrigger
```

### Eliminar Tareas

```powershell
# Eliminar tarea de backup
Unregister-ScheduledTask -TaskName "Finly Database Backup" -Confirm:$false

# Eliminar tarea de limpieza
Unregister-ScheduledTask -TaskName "Finly Backup Cleanup" -Confirm:$false
```

### Ver Logs de Ejecución

```powershell
# Ver eventos de Task Scheduler
Get-WinEvent -LogName "Microsoft-Windows-TaskScheduler/Operational" -MaxEvents 50 | 
    Where-Object { $_.Message -like "*Finly*" } |
    Format-Table TimeCreated, Message -AutoSize
```

---

## 🐛 Solución de Problemas

### Error: "pg_dump no está instalado"

**Solución**: Instalar PostgreSQL Client Tools o agregar al PATH:
```powershell
$env:Path += ";C:\Program Files\PostgreSQL\16\bin"
```

### Error: "Connection refused"

**Verificar**:
1. PostgreSQL está ejecutándose
2. Host y puerto son correctos
3. Firewall permite conexiones

### Error: "Permission denied"

**Solución**: Verificar que el usuario tiene permisos adecuados:
```sql
GRANT ALL PRIVILEGES ON DATABASE finly_db TO postgres;
```

---

## 📁 Estructura de Archivos

```
Finly/
├── scripts/
│   ├── backup-database.ps1      # Script de backup
│   ├── restore-database.ps1     # Script de restauración
│   └── DATABASE_BACKUP_README.md # Esta documentación
└── backups/                      # Directorio de backups (creado automáticamente)
    ├── finly_backup_20260318_143052.sql
    └── finly_backup_20260318_150230.sql.zip
```

---

## 📞 Soporte

Para problemas o preguntas, consulte la documentación de PostgreSQL:
- [pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)
- [psql](https://www.postgresql.org/docs/current/app-psql.html)
