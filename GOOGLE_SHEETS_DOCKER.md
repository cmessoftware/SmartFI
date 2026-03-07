# 📊 Configurar Google Sheets en Docker

Tu aplicación ya tiene Google Sheets configurado localmente. Aquí está cómo hacerlo funcionar en Docker.

## ✅ Verificar que tienes los archivos

1. **credentials.json** en `backend/credentials.json`
2. **GOOGLE_SHEET_ID** en tu archivo `.env`

## 🐳 Configuración Docker

### Paso 1: Crear archivo .env en la raíz

Docker Compose lee variables desde `.env` en la raíz del proyecto (NO el de backend).

```powershell
# Copia y edita
Copy-Item .env.docker .env

# O crea manualmente
New-Item -ItemType File -Path .env -Force
```

Contenido del `.env`:
```env
# JWT
SECRET_KEY=finly-dev-secret-key-change-this-in-production-min-32-chars

# Google Sheets
GOOGLE_SHEET_ID=1jiS2l-1L7p4CBHVxZAFJ-g1jzHgGNMcGN3SFKfNrslM
GOOGLE_CREDENTIALS_FILE=credentials.json
```

### Paso 2: Verificar credentials.json

```powershell
# Verificar que existe
Test-Path backend/credentials.json
# Debe devolver: True
```

Si no existe, cópialo desde donde lo tengas:
```powershell
Copy-Item ruta/a/tu/credentials.json backend/credentials.json
```

### Paso 3: Reiniciar Docker

```powershell
# Detener
docker-compose down

# Levantar con nuevo .env
docker-compose up -d
```

## 🔍 Verificar que funciona

### Ver logs del backend
```powershell
docker-compose logs -f backend
```

Deberías ver:
```
✅ Google Sheets connected successfully
```

### Probar la API
```powershell
# Health check
Invoke-WebRequest http://localhost:3000/api/health | ConvertFrom-Json
```

Debería mostrar:
```json
{
  "status": "ok",
  "google_sheets_connected": true,
  "sheet_id": "1jiS2l-1L7p4CBHVxZAFJ-g1jzHgGNMcGN3SFKfNrslM"
}
```

## 🔧 Troubleshooting

### No encuentra credentials.json

**Síntoma:**
```
⚠️ Google Sheets not available
```

**Solución:**
```powershell
# Verificar que Docker puede ver el archivo
docker exec -it finly-backend ls -la /app/credentials.json

# Si no existe, verificar permisos y ruta
ls backend/credentials.json
```

### Error de permisos en credentials.json

**Síntoma:**
```
Permission denied: 'credentials.json'
```

**Solución:**
El volumen en docker-compose.yml debe ser `:ro` (read-only):
```yaml
volumes:
  - ./backend/credentials.json:/app/credentials.json:ro
```

### GOOGLE_SHEET_ID no se carga

**Síntoma:**
```
sheet_id: null
```

**Solución:**
1. Verificar que `.env` está en la raíz (NO en backend)
2. Reiniciar Docker:
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

### Google API no autorizada

**Síntoma:**
```
Error: Invalid credentials
```

**Solución:**
1. Verificar que `credentials.json` es válido
2. Verificar permisos en Google Cloud Console
3. Compartir el Sheet con el email del service account

## 📁 Estructura de Archivos

```
Finly/
├── .env                          ← Nuevo! Variables para Docker
├── .env.docker                   ← Template
├── docker-compose.yml
├── backend/
│   ├── .env                      ← Variables para desarrollo local
│   ├── credentials.json          ← Tus credenciales de Google
│   ├── main.py
│   └── ...
└── frontend/
    └── ...
```

## 🔐 Seguridad

### ⚠️ IMPORTANTE: No subir credentials.json a GitHub

Ya está en `.gitignore`, pero verifica:

```powershell
# Ver qué archivos se subirían
git status

# credentials.json NO debe aparecer
# Si aparece:
git rm --cached backend/credentials.json
echo "backend/credentials.json" >> .gitignore
```

## 🌐 Para Deployment en la Nube

Cuando despliegues a Render/Railway:

### Opción 1: Variable de entorno (Recomendado)

Convierte `credentials.json` a JSON en una línea:

```powershell
# Leer y comprimir
$creds = Get-Content backend/credentials.json | ConvertFrom-Json | ConvertTo-Json -Compress
Write-Output $creds
```

En Render:
- Environment → Add Variable
- Name: `GOOGLE_CREDENTIALS_JSON`
- Value: (pega el JSON comprimido)

Actualiza `backend/main.py` para leer de env var.

### Opción 2: Secret File (Render)

Render permite subir archivos secretos:
1. Dashboard → Service → Environment
2. Secret Files → Add Secret File
3. Filename: `credentials.json`
4. Content: (pega contenido del archivo)

## ✅ Checklist

- [ ] Archivo `.env` en raíz con `GOOGLE_SHEET_ID`
- [ ] Archivo `backend/credentials.json` existe
- [ ] Docker Compose reiniciado
- [ ] Logs muestran "Google Sheets connected"
- [ ] Health check muestra `google_sheets_connected: true`
- [ ] Puedes ver transacciones existentes en el Sheet
- [ ] `credentials.json` en `.gitignore`

## 🎯 Comandos Rápidos

```powershell
# Setup completo
Copy-Item .env.docker .env
# Editar .env con tu GOOGLE_SHEET_ID
docker-compose down
docker-compose up -d
docker-compose logs -f backend

# Verificar
Invoke-WebRequest http://localhost:8000/api/health | ConvertFrom-Json

# Ver archivo dentro del contenedor
docker exec -it finly-backend cat /app/credentials.json
```

## 💡 Alternativa: Usar solo PostgreSQL

Si prefieres no usar Google Sheets en Docker:

```powershell
# Comentar en .env
# GOOGLE_SHEET_ID=...
```

La app funcionará solo con PostgreSQL (recomendado para production).

---

¿Sigues teniendo problemas? Revisa los logs:
```powershell
docker-compose logs backend
```
