## Especificación Funcional – Módulo de Seguridad
Objetivo

Implementar un módulo de seguridad para una aplicación Finly


Preliminares

0. Sacar datos de usuarios harcodeados en codigo y en pantalla de login.
1. Diseño modular, implementado como plugin que se puede instalar facilemnte en otro sistema con 
un arquitecturea similar. Agregar tutorial del plugin.
1. Crear en ueva rama finly_security (en base a main)

El módulo debe cubrir:

Autenticación
Autorización
Gestión de usuarios
Gestión de roles
JWT
Protección de rutas y servicios
Recuperación de contraseña
Auditoría básica
Manejo de sesiones
Configuración de permisos por funcionalidad

1. Arquitectura General
Frontend

Tecnología:

React + Vite
React Router
Axios
Context API o Zustand para estado global
Almacenamiento del token JWT en memoria o localStorage/sessionStorage según configuración
Backend

Tecnología:

FastAPI
SQLAlchemy
Alembic
PostgreSQL
PyJWT o python-jose
bcrypt/passlib para hash de contraseñas

2. Conceptos Principales
Usuario

Entidad que representa una persona con acceso al sistema.

Campos mínimos:

id
username
email
password_hash
first_name
last_name
is_active
is_locked
failed_login_attempts
last_login_at
password_changed_at
created_at
updated_at
Rol

Agrupa permisos.

Ejemplos:

ADMIN
WRITER
READER
AUDITOR
SUPPORT

Permiso

Representa una acción habilitada.

Ejemplos:

USER_VIEW
USER_CREATE
USER_EDIT
USER_DELETE
ROLE_VIEW
ROLE_EDIT
REPORT_VIEW
TRANSACTION_CREATE
TRANSACTION_DELETE
Relación Usuario-Rol

Un usuario puede tener uno o varios roles.

Relación Rol-Permiso

Un rol puede tener uno o varios permisos.

3. Modelo de Base de Datos
users
-----
id
username
email
password_hash
first_name
last_name
is_active
is_locked
failed_login_attempts
last_login_at
password_changed_at
created_at
updated_at

roles
-----
id
name
description
created_at
updated_at

permissions
-----------
id
code
description
module
created_at
updated_at

user_roles
----------
user_id
role_id

role_permissions
----------------
role_id
permission_id

refresh_tokens
--------------
id
user_id
token_hash
expires_at
revoked_at
created_at
ip_address
user_agent

audit_logs
----------
id
user_id
action
entity
entity_id
details
ip_address
created_at
4. Flujo de Login
Pantalla de Login

Campos:

Usuario o email
Contraseña
Checkbox "Recordarme"

Validaciones:

Campos obligatorios
Usuario inexistente
Contraseña incorrecta
Usuario inactivo
Usuario bloqueado
Flujo Backend
Usuario envía username/email y password.
Backend busca usuario.
Se valida hash de contraseña.
Se valida estado del usuario.
Se generan:
access_token JWT
refresh_token
Se devuelve al frontend:
token
refresh_token
fecha de expiración
datos básicos del usuario
roles
permisos
Respuesta Login
{
  "access_token": "jwt_token",
  "refresh_token": "refresh_token",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@test.com",
    "roles": ["ADMIN"],
    "permissions": [
      "USER_VIEW",
      "USER_CREATE",
      "USER_EDIT"
    ]
  }
}
5. JWT
Access Token

Contenido sugerido:

{
  "sub": "user_id",
  "username": "admin",
  "roles": ["ADMIN"],
  "permissions": [
    "USER_VIEW",
    "USER_EDIT"
  ],
  "iat": 1710000000,
  "exp": 1710003600
}
Duración
Access Token: 15 a 60 minutos
Refresh Token: 7 a 30 días
Refresh Token

Objetivo:

Renovar access token sin obligar al usuario a volver a loguearse

Flujo:

Frontend detecta expiración del access token.
Llama endpoint /auth/refresh.
Backend valida refresh token.
Devuelve nuevo access token.

6. Logout
Logout Manual

Acción:

El frontend elimina access token
El backend invalida refresh token
Logout por Inactividad
Configurable por tiempo
Ejemplo: 30 minutos sin interacción
Mostrar modal previo:
"Su sesión expirará en 2 minutos"
Logout Global

Permitir al usuario cerrar todas las sesiones activas.

7. Recuperación de Contraseña
Flujo Forgot Password
Usuario ingresa email.
Backend valida existencia.
Se genera token temporal.
Se envía email con link.
Usuario define nueva contraseña.

Campos:

Nueva contraseña
Confirmar contraseña

Reglas:

Mínimo 8 caracteres
Al menos una mayúscula
Al menos un número
Al menos un carácter especial

8. Cambio de Contraseña
Desde Perfil

Campos:

Contraseña actual
Nueva contraseña
Confirmar contraseña

Reglas:

No repetir últimas N contraseñas
No permitir misma contraseña anterior
Invalidar sesiones activas al cambiar contraseña

9. Gestión de Usuarios
Pantalla de Usuarios

Acciones:

Buscar
Filtrar
Crear
Editar
Desactivar
Bloquear
Resetear contraseña
Asignar roles

Campos:

Username
Nombre
Apellido
Email
Estado
Roles
Fecha último login
Estados posibles
Activo
Inactivo
Bloqueado
10. Gestión de Roles
Pantalla de Roles

Acciones:

Crear rol
Editar rol
Eliminar rol
Asignar permisos

Campos:

Nombre
Descripción
Lista de permisos asociados
11. Gestión de Permisos
Estrategia Recomendada

Permisos por módulo y acción.

Formato:

<MODULO>_<ACCION>

Ejemplos:

USER_VIEW
USER_CREATE
USER_EDIT
USER_DELETE

ROLE_VIEW
ROLE_CREATE
ROLE_EDIT
ROLE_DELETE

SECURITY_VIEW
SECURITY_EDIT
12. Protección de Servicios Backend
Middleware JWT

Todos los endpoints protegidos deben validar:

Token presente
Firma válida
Expiración
Usuario activo
Usuario no bloqueado
Decoradores/Reutilización

Ejemplo conceptual:

@require_permission("USER_VIEW")
def get_users():
    pass
Endpoints Públicos
POST /auth/login
POST /auth/refresh
POST /auth/forgot-password
POST /auth/reset-password
Endpoints Protegidos
GET /users
POST /users
PUT /users/{id}
DELETE /users/{id}
GET /roles
POST /roles
13. Protección de Rutas Frontend
Ejemplo
/admin/users -> requiere USER_VIEW
/admin/roles -> requiere ROLE_VIEW
/admin/security -> requiere SECURITY_VIEW
Comportamiento
Si no tiene token:
Redirigir a login
Si no tiene permiso:
Mostrar página 403
Si token expiró:
Intentar refresh automático
Si falla, redirigir a login
14. Auditoría

Registrar eventos sensibles:

Login exitoso
Login fallido
Logout
Cambio de contraseña
Recuperación de contraseña
Alta de usuario
Edición de usuario
Baja de usuario
Cambio de rol
Cambio de permisos

Campos sugeridos:

usuario
acción
fecha
IP
user_agent
detalle
15. Seguridad Adicional
Recomendaciones
Contraseñas hasheadas con bcrypt
Rate limit en login
CAPTCHA opcional tras varios intentos fallidos
Bloqueo temporal luego de N intentos
HTTPS obligatorio
CORS restringido
Secrets fuera del repositorio
JWT_SECRET en variables de entorno
Rotación de claves
Headers de seguridad
Validación estricta de inputs
Sanitización de datos
Logs sin exponer contraseñas ni tokens
16. Endpoints Sugeridos
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout
POST   /auth/forgot-password
POST   /auth/reset-password
POST   /auth/change-password
GET    /auth/me

GET    /users
GET    /users/{id}
POST   /users
PUT    /users/{id}
DELETE /users/{id}

GET    /roles
GET    /roles/{id}
POST   /roles
PUT    /roles/{id}
DELETE /roles/{id}

GET    /permissions
GET    /audit-logs
17. Casos de Error Esperados
401 Unauthorized
- Token inválido
- Token expirado
- Usuario no autenticado

403 Forbidden
- Usuario sin permisos

404 Not Found
- Usuario inexistente
- Rol inexistente

409 Conflict
- Username duplicado
- Email duplicado
- Rol duplicado

422 Validation Error
- Password inválida
- Datos incompletos
18. Consideraciones Técnicas de Implementación
Frontend
Axios interceptor para agregar Authorization Bearer Token
Axios interceptor para refresh automático
Hook useAuth()
Hook usePermissions()
ProtectedRoute component
Persistencia de sesión configurable
Menú dinámico según permisos
Backend
Middleware JWT
Servicio AuthService
Servicio UserService
Servicio RoleService
Servicio PermissionService
Servicio AuditService
Repositorios separados
DTOs de request/response
Validación con Pydantic
Migraciones con Alembic
ademas modulo de admin (solo rol admin) para gestionar usurios y roles.
Especificación Funcional
Módulo de Seguridad + Administración

Aplicación: React + Vite / FastAPI / PostgreSQL / JWT

1. Alcance del Módulo

El sistema de seguridad se compone de dos submódulos:

Autenticación y autorización
Administración de usuarios y roles

El submódulo de administración sólo puede ser utilizado por usuarios con rol:

ADMIN
2. Arquitectura
Frontend

Tecnología

React
Vite
React Router
Axios

Estructura sugerida

src
 ├ auth
 │   ├ AuthProvider.tsx
 │   ├ useAuth.ts
 │   └ authService.ts
 │
 ├ security
 │   ├ usePermissions.ts
 │   └ ProtectedRoute.tsx
 │
 ├ admin
 │   ├ pages
 │   │   ├ UsersPage.tsx
 │   │   ├ UserForm.tsx
 │   │   ├ RolesPage.tsx
 │   │   └ RoleForm.tsx
 │   │
 │   └ services
 │       ├ usersApi.ts
 │       └ rolesApi.ts
Backend

Arquitectura sugerida

app
 ├ api
 │   ├ auth_router.py
 │   ├ users_router.py
 │   └ roles_router.py
 │
 ├ services
 │   ├ auth_service.py
 │   ├ user_service.py
 │   └ role_service.py
 │
 ├ repositories
 │   ├ user_repository.py
 │   └ role_repository.py
 │
 ├ security
 │   ├ jwt_manager.py
 │   ├ auth_dependencies.py
 │   └ permission_checker.py
 │
 ├ models
 │   ├ user.py
 │   ├ role.py
 │   └ permission.py
3. Autenticación
Login

Endpoint

POST /auth/login

Entrada

username
password

Salida

access_token
refresh_token
user
roles
permissions

JWT contiene

user_id
username
roles
permissions
exp
iat
4. Autorización

Cada endpoint protegido valida:

JWT válido
usuario activo
usuario no bloqueado
permiso requerido

Ejemplo backend

@require_permission("USER_VIEW")
5. Submódulo de Administración
Restricción

Todo el módulo requiere:

ROLE = ADMIN

Validación en backend:

@require_role("ADMIN")

Validación en frontend:

ProtectedRoute role="ADMIN"
6. Menú de Administración

Visible sólo para rol ADMIN.

Admin
 ├ Usuarios
 └ Roles
7. Administración de Usuarios
Pantalla
/admin/users

Tabla de usuarios.

Columnas

username
email
nombre
apellido
estado
roles
ultimo_login
acciones

Acciones

crear
editar
activar
desactivar
bloquear
resetear password
asignar roles
8. Crear Usuario

Pantalla

/admin/users/new

Campos

username
email
first_name
last_name
password
confirm_password
roles
activo

Reglas

username único
email único
password segura
al menos un rol
9. Editar Usuario

Pantalla

/admin/users/{id}

Editable

nombre
apellido
email
estado
roles

No editable

username
created_at
10. Bloqueo Automático

Si login falla N veces:

failed_login_attempts >= 5

Usuario pasa a

is_locked = true

Sólo ADMIN puede desbloquear.

11. Reset de Password

Acción disponible para ADMIN.

Flujo

1 Crear password temporal
2 Forzar cambio en próximo login

Campo adicional

force_password_change
12. Administración de Roles

Pantalla

/admin/roles

Tabla

nombre
descripcion
cantidad_usuarios
acciones

Acciones

crear
editar
eliminar
asignar permisos
13. Crear Rol

Campos

name
description
permissions[]

Ejemplo

WRITER
Puede crear contenido
14. Permisos

Formato estándar

MODULO_ACCION

Ejemplos

USER_VIEW
USER_CREATE
USER_EDIT
USER_DELETE

ROLE_VIEW
ROLE_CREATE
ROLE_EDIT
ROLE_DELETE

REPORT_VIEW
REPORT_EXPORT
15. Asignación de Permisos

Pantalla de rol muestra checklist:

Usuarios
 ☑ USER_VIEW
 ☑ USER_CREATE
 ☑ USER_EDIT
 ☐ USER_DELETE

Reportes
 ☑ REPORT_VIEW
 ☐ REPORT_EXPORT
16. Protección de Rutas Frontend

Ejemplo

/admin/users
/admin/roles

Validación

si no hay token → login
si no es ADMIN → 403
17. API Administración
Usuarios
GET /users
GET /users/{id}

POST /users
PUT /users/{id}

PATCH /users/{id}/activate
PATCH /users/{id}/deactivate
PATCH /users/{id}/unlock

POST /users/{id}/reset-password
Roles
GET /roles
GET /roles/{id}

POST /roles
PUT /roles/{id}

DELETE /roles/{id}

PUT /roles/{id}/permissions
18. Modelo Base de Datos
Users
id
username
email
password_hash
first_name
last_name
is_active
is_locked
failed_login_attempts
force_password_change
last_login_at
created_at
updated_at
Roles
id
name
description
created_at
updated_at
Permissions
id
code
description
module
user_roles
user_id
role_id
role_permissions
role_id
permission_id
19. Auditoría

Eventos registrados

LOGIN_SUCCESS
LOGIN_FAIL
LOGOUT
USER_CREATED
USER_UPDATED
USER_DEACTIVATED
USER_LOCKED
PASSWORD_RESET
ROLE_CREATED
ROLE_UPDATED
ROLE_DELETED
PERMISSION_UPDATED

Campos

usuario
accion
entidad
entity_id
fecha
ip
20. Seguridad

Requisitos

bcrypt password hashing
JWT firmado
expiración de token
refresh token
rate limit login
bloqueo por intentos
HTTPS obligatorio
21. Flujo de Sesión
Login
 ↓
JWT emitido
 ↓
Frontend guarda token
 ↓
Interceptor agrega Authorization header
 ↓
Backend valida token
 ↓
Acceso permitido según permisos
22. Flujo de Administración
ADMIN login
 ↓
accede menú admin
 ↓
gestiona usuarios
 ↓
gestiona roles
 ↓
asigna permisos
23. Control en Backend

Dependencias FastAPI

get_current_user
require_role
require_permission

Ejemplo

@router.get("/users")
@require_role("ADMIN")