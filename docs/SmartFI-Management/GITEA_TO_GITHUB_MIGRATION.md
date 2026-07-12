# Migracion Gitea -> GitHub (sin PRs)

Alcance de esta guia:
1. Historial git (ramas + tags)
2. Issues + comentarios
3. Proyecto Kanban (GitHub Project) por estado

No incluye:
1. Pull Requests

## 1. Requisitos

1. GitHub CLI instalado (`gh`) y autenticado.
2. Token de Gitea con permisos de lectura de repos e issues.
3. Repo GitHub destino ya creado (ejemplo: `SmartFI`).
4. Estar parado en una copia local del repo a migrar.

## 2. Script incluido

- scripts/migrate-gitea-to-github.ps1

## 3. Ejecucion recomendada por fases

### Fase A: Dry run

```powershell
./scripts/migrate-gitea-to-github.ps1 \
  -GiteaBaseUrl "https://tu-gitea" \
  -GiteaOwner "tu-org" \
  -GiteaRepo "SmartFI" \
  -GiteaToken "TOKEN_GITEA" \
  -GithubOwner "TU_USUARIO_O_ORG" \
  -GithubRepo "SmartFI" \
  -MigrateGitHistory \
  -MigrateIssues \
  -MigrateProject \
  -GithubProjectNumber 1 \
  -DryRun
```

### Fase B: Migrar historial git

```powershell
./scripts/migrate-gitea-to-github.ps1 \
  -GiteaBaseUrl "https://tu-gitea" \
  -GiteaOwner "tu-org" \
  -GiteaRepo "SmartFI" \
  -GiteaToken "TOKEN_GITEA" \
  -GithubOwner "TU_USUARIO_O_ORG" \
  -GithubRepo "SmartFI" \
  -MigrateGitHistory
```

### Fase C: Migrar issues (sin project)

```powershell
./scripts/migrate-gitea-to-github.ps1 \
  -GiteaBaseUrl "https://tu-gitea" \
  -GiteaOwner "tu-org" \
  -GiteaRepo "SmartFI" \
  -GiteaToken "TOKEN_GITEA" \
  -GithubOwner "TU_USUARIO_O_ORG" \
  -GithubRepo "SmartFI" \
  -MigrateIssues
```

### Fase D: Migrar issues + project kanban

```powershell
./scripts/migrate-gitea-to-github.ps1 \
  -GiteaBaseUrl "https://tu-gitea" \
  -GiteaOwner "tu-org" \
  -GiteaRepo "SmartFI" \
  -GiteaToken "TOKEN_GITEA" \
  -GithubOwner "TU_USUARIO_O_ORG" \
  -GithubRepo "SmartFI" \
  -MigrateIssues \
  -MigrateProject \
  -GithubProjectNumber 1
```

## 4. Como mapea el estado del Kanban

1. Issue cerrada -> `Done`
2. Issue abierta con label `in progress`, `in-progress`, `doing` o `wip` -> `In Progress`
3. Resto -> `Todo`

## 5. Archivo de salida

El script exporta:
- `migration_issue_map.json`

Contiene el mapeo `issue_gitea -> issue_github`.

## 6. Verificaciones recomendadas

1. Revisar ramas y tags en GitHub.
2. Comparar conteo de issues open/closed entre Gitea y GitHub.
3. Verificar labels y milestones.
4. Verificar que los items aparezcan en el Project y en columna/estado correcto.

## 7. Notas importantes

1. El script no migra PRs.
2. El script crea issues nuevos (IDs distintos a Gitea).
3. Para evitar duplicados, no ejecutar dos veces sobre el mismo repo sin limpieza previa.
4. En repos con muchos issues/comentarios, ejecutar por tandas y validar.
