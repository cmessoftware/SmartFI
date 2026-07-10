#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [Parameter(Mandatory=$false)]
    [string]$GiteaUrl = "http://localhost:3001",
    [Parameter(Mandatory=$false)]
    [string]$Owner = "admin",
    [Parameter(Mandatory=$false)]
    [string]$Repo = "SmartFI"
)

$headers = @{
    "Authorization" = "token $Token"
    "Content-Type"  = "application/json"
}

function New-GiteaIssue {
    param([string]$Title, [string]$Body)
    $url = "$GiteaUrl/api/v1/repos/$Owner/$Repo/issues"
    $payload = @{ title = $Title; body = $Body } | ConvertTo-Json -Depth 3
    Write-Host "📝 Creando: $Title" -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $url -Method POST -Headers $headers -Body $payload -ErrorAction Stop
        $issue = $response.Content | ConvertFrom-Json
        Write-Host "   ✅ Issue #$($issue.number)" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

New-GiteaIssue -Title "[EXP-FEAT-014] Backend: Funciones de comparativa de meses" -Body "Implementar funciones en month_service.py"
New-GiteaIssue -Title "[EXP-FEAT-014] Backend: Endpoints GET /api/months/range/{start}/{end}" -Body "Implementar endpoints en main.py"
New-GiteaIssue -Title "[EXP-FEAT-014] Frontend: Componentes MonthComparativeDashboard" -Body "Crear componentes React"
New-GiteaIssue -Title "[EXP-FEAT-014] Frontend: Integración en Router y API client" -Body "Agregar ruta y servicios API"
New-GiteaIssue -Title "[EXP-FEAT-014] Frontend: Exportación a CSV y PDF" -Body "Implementar exportación"
New-GiteaIssue -Title "[EXP-FEAT-014] Testing: Unit tests para funciones de comparativa" -Body "Crear unit tests"
New-GiteaIssue -Title "[EXP-FEAT-014] Testing: E2E tests para dashboard comparativo" -Body "Crear tests E2E"
