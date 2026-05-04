$GITEA_URL   = "http://localhost:3001"
$GITEA_OWNER = "admin"
$GITEA_REPO  = "SmartFI"
$TOKEN       = "9c32f99f970ab6ed7dcc07f15626b3459461688f"
$CHANGES_DIR = "c:\Users\sergiosal\source\repos\Finly\openspec\changes"

$Headers = @{
    "Authorization" = "token $TOKEN"
    "Content-Type"  = "application/json"
    "Accept"        = "application/json"
}

function Invoke-Gitea($Method, $Path, $Body = $null) {
    $uri = "$GITEA_URL/api/v1$Path"
    $params = @{ Uri = $uri; Method = $Method; Headers = $Headers; ErrorAction = "Stop" }
    if ($Body) { $params["Body"] = ($Body | ConvertTo-Json -Depth 10) }
    try { return Invoke-RestMethod @params }
    catch {
        $msg = $_.Exception.Message
        try { $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); $msg = $reader.ReadToEnd() } catch {}
        Write-Warning "  API ERROR [$Method $Path]: $msg"; return $null
    }
}

function Get-OrCreate-Milestone($title, $description) {
    Write-Host "  Milestone: $title"
    $existing = Invoke-Gitea "GET" "/repos/$GITEA_OWNER/$GITEA_REPO/milestones?limit=50"
    $found = $existing | Where-Object { $_.title -eq $title }
    if ($found) { Write-Host "    -> exists (id=$($found.id))"; return $found.id }
    $result = Invoke-Gitea "POST" "/repos/$GITEA_OWNER/$GITEA_REPO/milestones" @{ title = $title; description = $description; state = "open" }
    if ($result) { Write-Host "    -> created (id=$($result.id))"; return $result.id }
    return $null
}

function Get-Or-Create-Issue($title, $body, $milestoneId) {
    $existing = Invoke-Gitea "GET" "/repos/$GITEA_OWNER/$GITEA_REPO/issues?type=issues&state=open&limit=50"
    $found = $existing | Where-Object { $_.title -eq $title }
    if ($found) { Write-Host "    -> issue exists #$($found.number) [$title]"; return $found.number }
    $result = Invoke-Gitea "POST" "/repos/$GITEA_OWNER/$GITEA_REPO/issues" @{ title = $title; body = $body; milestone = $milestoneId }
    if ($result) { Write-Host "    -> created issue #$($result.number) [$title]"; return $result.number }
    return $null
}

function Update-Yaml($path, $msName, $issueId, $branch, $status) {
    $c = Get-Content $path -Raw
    $c = $c -replace '\ngitea_issue:.*', '' -replace '\ngitea_milestone:.*', '' -replace '\nbranch:.*', ''
    if ($c -notmatch 'status:') { $c = $c.TrimEnd() + "`nstatus: $status" }
    else { $c = $c -replace 'status:.*', "status: $status" }
    $c = $c.TrimEnd() + "`ngitea_milestone: $msName`ngitea_issue: $issueId`nbranch: $branch"
    Set-Content $path -Value $c -Encoding UTF8 -NoNewline
    Write-Host "    -> .openspec.yaml updated"
}

# Verify
Write-Host "`n=== Connecting to Gitea ===" -ForegroundColor Cyan
$repo = Invoke-Gitea "GET" "/repos/$GITEA_OWNER/$GITEA_REPO"
if (-not $repo) { Write-Error "Cannot connect"; exit 1 }
Write-Host "  OK: $($repo.full_name)" -ForegroundColor Green

# Labels
Write-Host "`n=== Labels ===" -ForegroundColor Cyan
$labelDefs = @(
    @{ name = "feature"; color = "#0075ca" }
    @{ name = "bug"; color = "#d73a4a" }
    @{ name = "backlog"; color = "#e4e669" }
    @{ name = "in-progress"; color = "#0052cc" }
    @{ name = "cc"; color = "#7057ff" }
    @{ name = "exp"; color = "#008672" }
)
$existingLabels = Invoke-Gitea "GET" "/repos/$GITEA_OWNER/$GITEA_REPO/labels?limit=50"
foreach ($ld in $labelDefs) {
    if (-not ($existingLabels | Where-Object { $_.name -eq $ld.name })) {
        Invoke-Gitea "POST" "/repos/$GITEA_OWNER/$GITEA_REPO/labels" $ld | Out-Null
        Write-Host "  created: $($ld.name)"
    } else { Write-Host "  exists: $($ld.name)" }
}

# Changes data
$changes = @(
    [pscustomobject]@{ name='exp-month-close'; status='in-progress'; branch='feature/exp-month-close'
        title='[EXP] Month close lifecycle'
        why='El modulo de gastos no distingue entre meses activos y cerrados, permitiendo modificaciones accidentales en historicos.'
        tasks=@(
            'Crear migracion Alembic para tabla monthly_periods'
            'Crear migracion Alembic para tabla monthly_period_snapshots'
            'Agregar columna monthly_period_id nullable FK a tabla transactions'
            'Crear modelos SQLAlchemy MonthlyPeriod y MonthlyPeriodSnapshot'
            'Implementar get_month_status(year_month)'
            'Implementar close_month con snapshot'
            'Implementar reopen_month con validacion de motivo minimo 10 chars'
            'Agregar validacion de periodo en create/update/delete transaction'
            'Crear endpoints POST /months/{year_month}/close, /reopen, GET /status'
            'Crear componente MonthStatusBadge (OPEN/CLOSED/REOPENED)'
            'Integrar MonthStatusBadge en selector de mes y header'
            'Crear modal de cierre de mes con confirmacion'
            'Crear modal de reapertura con campo de motivo'
            'Implementar bloqueo CED en formulario de transacciones para meses cerrados'
            'Tests unitarios close_month, reopen_month, validaciones de permisos'
            'Tests integracion endpoints close/reopen/status'
            'Test E2E: cerrar intentar editar reabrir editar exitoso'
        )
    }
    [pscustomobject]@{ name='cc-bugs-critical'; status='proposed'; branch='bugfix/cc-bugs-critical'
        title='[CC] Critical bugs: fecha edicion y moneda header'
        why='Al editar fecha de compra no se mueve de periodo. Al cambiar moneda ARS->USD el header Total Pendiente no se actualiza.'
        tasks=@(
            'Reproducir y aislar bug: edicion de fecha no mueve compra de periodo'
            'Fix backend: recalcular periodo al actualizar fecha de compra'
            'Fix frontend: actualizar header Total Pendiente al cambiar moneda sin reload'
            'Tests unitarios para recalculo de periodo en edicion de fecha'
            'Validacion manual de ambos fixes'
        )
    }
    [pscustomobject]@{ name='cc-period-policy'; status='proposed'; branch='feature/cc-period-policy'
        title='[CC] Period policy: validacion temporal de pagos y cargas'
        why='El modulo CC no valida que pagos y cargas respeten las ventanas temporales de los periodos.'
        tasks=@(
            'Definir reglas de ventana temporal por periodo (apertura, cierre, vencimiento)'
            'Implementar validacion backend: pagos fuera de periodo vigente'
            'Implementar validacion backend: cargas CSV con fecha de cierre incorrecta'
            'Implementar mensajes de error claros en UI para violaciones de politica'
            'Tests unitarios para validaciones de ventana temporal'
            'Tests integracion: intentar cargar fuera de ventana -> error esperado'
        )
    }
    [pscustomobject]@{ name='cc-period-close'; status='proposed'; branch='feature/cc-period-close'
        title='[CC] Period close lifecycle'
        why='Los periodos CC pueden modificarse indefinidamente despues de la closing_date, sin auditoria ni control de estado.'
        tasks=@(
            'Agregar campo status OPEN/CLOSED a tabla credit_card_periods'
            'Crear migracion Alembic para campo status en credit_card_periods'
            'Implementar endpoint POST /cc-periods/{id}/close'
            'Bloquear modificaciones en periodos cerrados excepto admin'
            'Crear UI para cerrar periodo con confirmacion'
            'Auditoria: loguear PERIOD_CLOSED'
            'Tests unitarios para close y bloqueo de modificaciones'
        )
    }
    [pscustomobject]@{ name='cc-period-budget-registration'; status='proposed'; branch='feature/cc-period-budget-registration'
        title='[CC] Auto-register CC period total as budget item'
        why='Al cerrar un periodo CC el monto no se registra como item de presupuesto del mes siguiente.'
        tasks=@(
            'Disenar modelo de budget_item generado por cierre de periodo CC'
            'Implementar auto-creacion de budget_item al cerrar periodo CC'
            'Mostrar budget_item de CC en vista de presupuesto mensual'
            'Fix regresion: botones de visibilidad al registrar gasto de nuevo periodo'
            'Tests unitarios para auto-creacion de budget_item'
            'Tests integracion: cerrar periodo -> verificar budget_item creado'
        )
    }
    [pscustomobject]@{ name='cc-period-open-rollover'; status='proposed'; branch='feature/cc-period-open-rollover'
        title='[CC] Period open rollover: traslado de saldo pendiente'
        why='Al crear nuevo periodo CC no hay mecanismo para trasladar saldo pendiente de periodos anteriores cerrados.'
        tasks=@(
            'Calcular saldo pendiente al cerrar periodo CC'
            'Implementar traslado automatico de saldo al abrir nuevo periodo'
            'Mostrar desglose compras nuevas vs saldo arrastrado en UI'
            'Calcular pago minimo considerando deuda acumulada'
            'Tests unitarios para calculo y traslado de saldo'
        )
    }
    [pscustomobject]@{ name='cc-next-statement-estimation'; status='proposed'; branch='feature/cc-next-statement-estimation'
        title='[CC] Next statement estimation'
        why='El sistema no proyecta el efecto contable de pagos en el periodo siguiente.'
        tasks=@(
            'Disenar modelo de proyeccion del proximo resumen'
            'Implementar calculo de estimacion basado en compras actuales y cuotas pendientes'
            'Crear endpoint GET /cc-periods/{id}/next-estimation'
            'Crear componente UI de estimacion del proximo resumen'
            'Tests unitarios para logica de estimacion'
        )
    }
    [pscustomobject]@{ name='cc-ux-improvements'; status='proposed'; branch='feature/cc-ux-improvements'
        title='[CC] UX improvements: tabla, paginacion, sorting, tooltip'
        why='La tabla de compras CC tiene multiples problemas de usabilidad.'
        tasks=@(
            'Corregir paginacion de tabla de compras: mostrar 5 items'
            'Corregir paginacion de cronograma de cuotas'
            'Agregar ordenamiento por monto en tabla de compras'
            'Agrupar visualmente cuotas y pagos unicos'
            'Agregar tooltip de detalle por compra'
            'Ocultar combo tipo-de-plan cuando no corresponde'
            'Agregar campo de detalle libre en formulario de compras'
        )
    }
    [pscustomobject]@{ name='credit-card-usd-billing-date'; status='proposed'; branch='feature/credit-card-usd-billing-date'
        title='[CC] USD purchases billing period assignment'
        why='Las compras en USD se asignan al periodo actual usando purchase_date en lugar del siguiente periodo facturado.'
        tasks=@(
            'Identificar campo de billing_date en compras USD'
            'Implementar logica de asignacion de periodo usando billing_date para USD'
            'Migrar datos historicos de compras USD al periodo correcto'
            'Validar que importacion CSV USD respeta logica de billing_date'
            'Tests unitarios para asignacion de periodo en compras USD'
        )
    }
    [pscustomobject]@{ name='formalize-credit-card-module'; status='proposed'; branch='feature/formalize-credit-card-module'
        title='[CC] Formalize credit card module spec'
        why='Las reglas del modulo CC estan en un documento narrativo mixto sin estructura OpenSpec.'
        tasks=@(
            'Extraer reglas funcionales del documento narrativo actual'
            'Crear specs estructuradas en openspec/changes/formalize-credit-card-module/specs/'
            'Validar specs contra comportamiento actual del sistema'
            'Identificar gaps entre spec y comportamiento real'
            'Documentar decisiones de diseno en design.md'
        )
    }
    [pscustomobject]@{ name='exp-month-comparative-dashboard'; status='backlog'; branch='feature/exp-month-comparative-dashboard'
        title='[EXP] Monthly comparative dashboard'
        why='No existe vista integrada para comparar gastos entre meses.'
        tasks=@(
            'Disenar estructura de datos para comparacion multi-mes'
            'Crear endpoint GET /api/months/comparison'
            'Crear componente MonthlyComparisonTable'
            'Agregar graficos de tendencia por categoria'
            'Resaltar anomalias estadisticas (desviacion > umbral)'
            'Tests unitarios para logica de comparacion'
        )
    }
    [pscustomobject]@{ name='exp-month-open-rollover'; status='backlog'; branch='feature/exp-month-open-rollover'
        title='[EXP] Month open rollover: traslado de presupuesto y saldo'
        why='Al abrir un nuevo mes los usuarios recrean manualmente el presupuesto y no hay traslado de saldo neto del anterior.'
        tasks=@(
            'Disenar mecanismo de copia de items de presupuesto entre meses'
            'Implementar endpoint POST /api/months/{year_month}/rollover'
            'Calcular y mostrar saldo neto arrastrado del mes anterior'
            'Crear UI de confirmacion de rollover con preview'
            'Tests unitarios para logica de rollover'
        )
    }
)

$results = @{}

foreach ($ch in $changes) {
    Write-Host "`n=== $($ch.name) ===" -ForegroundColor Yellow
    $msId = Get-OrCreate-Milestone $ch.name "OpenSpec change: openspec/changes/$($ch.name)/`nStatus: $($ch.status)`n`n$($ch.why)"
    if (-not $msId) { continue }
    $parentBody = "## Spec`n``openspec/changes/$($ch.name)/proposal.md```n`n## Por que`n$($ch.why)`n`n## Branch`n``$($ch.branch)```n`n## Status`n$($ch.status)`n`n## Sub-issues`n*pendiente*"
    $parentId = Get-Or-Create-Issue $ch.title $parentBody $msId
    if (-not $parentId) { continue }
    $taskIds = @()
    foreach ($task in $ch.tasks) {
        $taskTitle = "[TASK:$($ch.name)] $task"
        $taskBody = "Parent: #$parentId`nMilestone: $($ch.name)`nSpec: openspec/changes/$($ch.name)/`n`n$task"
        $tid = Get-Or-Create-Issue $taskTitle $taskBody $msId
        if ($tid) { $taskIds += $tid }
    }
    if ($taskIds.Count -gt 0) {
        $subList = ($taskIds | ForEach-Object { "- #$_" }) -join "`n"
        $updBody = $parentBody -replace '\*pendiente\*', $subList
        Invoke-Gitea "PATCH" "/repos/$GITEA_OWNER/$GITEA_REPO/issues/$parentId" @{ body = $updBody } | Out-Null
    }
    $yamlPath = "$CHANGES_DIR\$($ch.name)\.openspec.yaml"
    if (Test-Path $yamlPath) { Update-Yaml $yamlPath $ch.name $parentId $ch.branch $ch.status }
    $results[$ch.name] = @{ milestone = $msId; issue = $parentId; tasks = $taskIds.Count }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$results.GetEnumerator() | Sort-Object Key | ForEach-Object {
    Write-Host "  $($_.Key): milestone=$($_.Value.milestone), issue=#$($_.Value.issue), tasks=$($_.Value.tasks)"
}
Write-Host "`nDone! http://localhost:3001/$GITEA_OWNER/$GITEA_REPO/issues" -ForegroundColor Green
