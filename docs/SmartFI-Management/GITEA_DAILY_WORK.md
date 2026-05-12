## Proceso para uso de Gitea y Github

### Recomendaciones

1. Usá Gitea como remoto principal de trabajo diario (issues, PR, review, merge).
2. Después de mergear en Gitea, sincronizás GitHub como espejo.

## Flujo sugerido

1. Crear rama desde main actualizado de Gitea.
2. Hacer commits y push de la rama a Gitea.
3. Abrir PR en Gitea y mergear ahí.
4. Actualizar tu main local desde Gitea.
5. Publicar ese main en GitHub con push a origin.

Comandos típicos:

- git checkout main
- git fetch gitea
- git pull gitea main
- git checkout -b feature/nueva-tarea
- git push gitea feature/nueva-tarea
 -(merge en Gitea)
- git checkout main
- git pull gitea main
- git push origin main

Regla simple para evitar confusiones:

- Feature branches: push solo a Gitea.
- Main: se actualiza desde Gitea y luego se espeja a GitHub.