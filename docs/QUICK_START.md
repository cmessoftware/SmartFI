# Finly - Quick Start Guide

## ⚡ Inicio en 3 Pasos

### Paso 1: Instalar Dependencias
```powershell
.\install.ps1
```

### Paso 2: Iniciar Aplicación
```powershell
.\start.ps1
```

### Paso 3: Abrir en el Navegador
```
http://localhost:5173
```

**Credenciales:**
- Usuario: `admin`
- Contraseña: `admin123`

---

## 📝 Inicio Manual

### Backend (Terminal 1)
```bash
cd backend
pip install -r requirements.txt
python main.py
```

### Frontend (Terminal 2)
```bash
cd frontend
npm install
npm run dev
```

---

## 🎯 Guía de Uso Rápida

### 1. Login
- Usa credenciales por defecto
- Roles disponibles: admin, writer, reader

### 2. Agregar Transacción
1. Click en "Cargar Gasto/Ingreso" en el sidebar
2. Completa el formulario
3. Click "Guardar Transacción"

### 3. Importar CSV
1. Click en "Importar CSV"
2. Arrastra tu archivo CSV
3. Mapea las columnas
4. Preview y confirma

### 4. Ver Reportes
1. Click en "Reportes"
2. Visualiza gráficos y estadísticas
3. Revisa tabla de transacciones

### 5. Administrar (Solo Admin)
1. Click en "Administración"
2. Gestiona usuarios y categorías

---

## 🔧 Configuración Opcional

### Google Sheets
1. Sigue `backend/GOOGLE_SHEETS_SETUP.md`
2. Coloca `credentials.json` en `backend/`
3. Actualiza `.env` con GOOGLE_SHEET_ID

### PostgreSQL
```bash
docker-compose up -d
```

---

## 🆘 Problemas Comunes

**Puerto en uso:**
```bash
# Cambiar puerto en vite.config.js (frontend)
# o en main.py (backend)
```

**Dependencias faltantes:**
```bash
npm install  # Frontend
pip install -r requirements.txt  # Backend
```

---

## 🎨 Características Principales

✅ Autenticación con JWT
✅ Gestión de gastos e ingresos
✅ Importación masiva desde CSV
✅ Reportes con gráficos
✅ Panel de administración
✅ Múltiples roles de usuario
✅ Diseño responsivo

---

## 📖 Más Información

- [README.md](../README.md) - Información general
- [INSTALLATION.md](../INSTALLATION.md) - Guía de instalación completa
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Estado del proyecto

---

**¡Listo para gestionar tus finanzas! 💰**
