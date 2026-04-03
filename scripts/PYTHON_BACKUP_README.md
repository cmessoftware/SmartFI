# Scripts de Backup y Restore - Base de Datos PostgreSQL

## 📦 Backup de la Base de Datos

### Uso

```bash
cd scripts
python backup_database.py
```

### Características

- ✅ Lee automáticamente la configuración desde `.env`
- ✅ Crea la carpeta `backup/` si no existe
- ✅ Genera archivos con formato: `<nombre_base>_YYYYMMDD.backup`
- ✅ Usa formato comprimido de PostgreSQL (custom format)
- ✅ Incluye todos los datos, esquemas y blobs

### Ejemplo de salida

```
🔄 Iniciando backup de la base de datos 'fin_per_db'...
📁 Destino: C:\Users\sergiosal\source\repos\Finly\backup\fin_per_db_20260326.backup
✅ Backup completado exitosamente
📦 Archivo: fin_per_db_20260326.backup
💾 Tamaño: 2.45 MB

✨ Backup guardado en: C:\Users\sergiosal\source\repos\Finly\backup\fin_per_db_20260326.backup
```

---

## 🔄 Restore de la Base de Datos

### Uso

```bash
cd scripts
python restore_database.py <nombre_archivo_backup>
```

### Ejemplos

```bash
# Listar backups disponibles (ejecutar sin parámetros)
python restore_database.py

# Restaurar desde un backup específico
python restore_database.py fin_per_db_20260326.backup
```

### Características

- ✅ Lee automáticamente la configuración desde `.env`
- ✅ Lista backups disponibles si no se especifica archivo
- ✅ Solicita confirmación antes de restaurar
- ✅ Limpia la base de datos antes de restaurar (--clean)
- ✅ Muestra progreso detallado

### Ejemplo de salida

```
❌ Error: Debes proporcionar el nombre del archivo de backup

Uso: python restore_database.py <nombre_archivo_backup>

Archivos de backup disponibles:
  1. fin_per_db_20260326.backup (2.45 MB)
  2. fin_per_db_20260325.backup (2.42 MB)

Ejemplo: python restore_database.py fin_per_db_20260326.backup
```

Al ejecutar con un archivo:

```
⚠️  ADVERTENCIA: Esta operación restaurará la base de datos 'fin_per_db'
📁 Desde el archivo: fin_per_db_20260326.backup
🗄️  Servidor: localhost:5433

¿Estás seguro de continuar? (escribe 'SI' para confirmar): SI

🔄 Iniciando restore de la base de datos...
✅ Restore completado exitosamente
🗄️  Base de datos 'fin_per_db' restaurada desde fin_per_db_20260326.backup
```

---

## ⚙️ Requisitos

### Dependencias Python

Asegúrate de tener instalado `python-dotenv`:

```bash
conda activate finly
pip install python-dotenv
```

O si usas el `requirements.txt` del backend, ya debería estar incluido.

### Herramientas PostgreSQL

Los scripts requieren que `pg_dump` y `pg_restore` estén disponibles en el PATH del sistema.

**En Windows:**
- Si instalaste PostgreSQL, ya deberían estar en: `C:\Program Files\PostgreSQL\<version>\bin`
- Agrega esa ruta al PATH del sistema si es necesario

**Verificar instalación:**

```bash
pg_dump --version
pg_restore --version
```

---

## 📁 Estructura de Archivos

```
Finly/
├── .env                          # Configuración (DATABASE_URL)
├── backup/                       # Carpeta generada automáticamente
│   ├── fin_per_db_20260326.backup
│   ├── fin_per_db_20260325.backup
│   └── ...
└── scripts/
    ├── backup_database.py        # Script de backup
    ├── restore_database.py       # Script de restore
    └── PYTHON_BACKUP_README.md   # Esta documentación
```

---

## 🔒 Seguridad

- ⚠️ La contraseña de la base de datos se pasa mediante la variable de entorno `PGPASSWORD`
- ⚠️ No compartas archivos `.env` ni backups con credenciales sensibles
- ✅ Agrega `backup/` al `.gitignore` para evitar subir backups al repositorio

---

## 🆘 Solución de Problemas

### Error: "pg_dump no se reconoce como comando"

**Solución:** Agrega PostgreSQL al PATH del sistema:

1. Busca la carpeta de instalación de PostgreSQL (ej: `C:\Program Files\PostgreSQL\16\bin`)
2. Agrega esa ruta a las variables de entorno PATH
3. Reinicia la terminal

### Error: "DATABASE_URL no encontrada en .env"

**Solución:** Verifica que el archivo `.env` existe en la raíz del proyecto y contiene:

```env
DATABASE_URL=postgresql://admin:admin123@localhost:5433/fin_per_db
```

### Error de conexión

**Solución:** Asegúrate de que PostgreSQL está corriendo:

```bash
docker ps  # Si usas Docker
# O verifica el servicio de PostgreSQL en Windows
```

---

## 📝 Notas

- Los backups usan el formato **custom** de PostgreSQL (`.backup`), que es comprimido y optimizado
- El formato custom permite restore selectivo y paralelización
- Se recomienda hacer backups antes de migraciones o cambios importantes
- Los nombres de archivo incluyen la fecha para facilitar el versionado
