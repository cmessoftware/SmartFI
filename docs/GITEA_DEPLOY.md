# Prompt para Copilot — Deploy de Gitea en Render usando Docker + SQLite + Persistent Disk

Quiero configurar un entorno productivo simple para desplegar Gitea en Render usando Docker.

Contexto:
- Proyecto personal colaborativo pequeño (2 usuarios inicialmente).
- No necesito Kubernetes ni alta disponibilidad.
- Quiero minimizar complejidad y costos.
- Se acepta sleeping/restarting de Render Free.
- La persistencia debe mantenerse aunque el contenedor reinicie.
- Usaré SQLite inicialmente.
- Más adelante podría migrar a PostgreSQL.
- Quiero que todo quede preparado correctamente para esa futura migración.

Objetivos:
1. Crear estructura completa del proyecto para Render.
2. Generar Dockerfile minimalista y correcto.
3. Configurar Gitea usando `/data` como volumen persistente.
4. Configurar Render Persistent Disk.
5. Usar SQLite correctamente persistido.
6. Configurar variables de entorno necesarias.
7. Crear `render.yaml`.
8. Documentar despliegue paso a paso.
9. Evitar configuraciones innecesariamente enterprise.
10. Preparar el entorno para HTTPS automático de Render.

Requisitos técnicos:
- Imagen base oficial `gitea/gitea:latest`
- Puerto 3000
- Persistencia en `/data`
- Configuración lista para deploy desde GitHub
- Configuración compatible con Render Web Service
- Uso de HTTP/HTTPS para Git inicialmente (sin SSH por ahora)
- Logs claros y mínimos
- Configuración segura razonable para entorno pequeño

Quiero que generes:

## Archivos
- Dockerfile
- render.yaml
- .gitignore
- README.md
- estructura de carpetas recomendada
- configuración persistente de Gitea

## README.md debe incluir:
- pasos para deploy en Render
- cómo configurar Persistent Disk
- variables de entorno necesarias
- cómo acceder a la primera configuración de Gitea
- cómo realizar backups de SQLite
- cómo restaurar backups
- cómo migrar posteriormente a PostgreSQL

## Consideraciones importantes
- NO usar filesystem efímero para SQLite
- NO usar PostgreSQL todavía
- NO usar docker-compose en producción Render
- Mantener solución simple y mantenible
- Pensado para crecimiento progresivo del proyecto ChessInsightAI

Además:
- explicar cada decisión técnica importante
- comentar los archivos generados
- incluir recomendaciones futuras:
  - PostgreSQL
  - runners
  - backups automáticos
  - MinIO/S3
  - CI/CD

Generar todo listo para copiar y usar.