Mejoras

1. Agregar opción de reseteo de contraseña.

Bugs
1. ✅ ~~Prioridad Alta - Al ingresar una nueva categoria no da error, pero no se refleja en Cargar Gastos.~~ **Resuelto**: Se agregaron endpoints `POST /api/categories` y `DELETE /api/categories/{id}` en el backend, y se actualizó AdminPanel para persistir categorías en la base de datos.
   
2. ✅ ~~Prioridad Alta - NO se muestra nada en usuario origen y usuario destino~~ ![alt text](image-27.png) **Resuelto**: Race condition en el interceptor de axios — múltiples requests 401 simultáneos disparaban refreshes concurrentes que se invalidaban entre sí, dejando `users` vacío. Se implementó una cola de refresh para serializar las llamadas.

