# Shared helpers for PostgreSQL / Neon scripts

function Get-ProjectRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Import-ProjectDotEnv {
    param(
        [string]$EnvFile = (Join-Path (Get-ProjectRoot) ".env")
    )

    if (-not (Test-Path $EnvFile)) {
        return $false
    }

    Get-Content $EnvFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\s*#' -or [string]::IsNullOrWhiteSpace($line)) { return }

        if ($line -match '^\s*([^=]+)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()

            if ($value -match '^"(.*)"$') {
                $value = $matches[1]
            } elseif ($value -match "^'(.*)'$") {
                $value = $matches[1]
            }

            Set-Item -Path "Env:$key" -Value $value
        }
    }

    return $true
}

function Resolve-PostgresTool {
    param([string]$ToolName)

    $cmd = Get-Command $ToolName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $roots = @(
        (Join-Path ${env:ProgramFiles} "PostgreSQL"),
        (Join-Path ${env:ProgramFiles(x86)} "PostgreSQL")
    )

    foreach ($root in $roots) {
        if (-not (Test-Path $root)) { continue }

        $match = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            ForEach-Object { Join-Path $_.FullName "bin\$ToolName.exe" } |
            Where-Object { Test-Path $_ } |
            Select-Object -First 1

        if ($match) { return $match }
    }

    return $null
}

function Get-NeonDatabaseUrl {
    param([string]$OverrideUrl)

    if ($OverrideUrl) { return $OverrideUrl.Trim() }

    Import-ProjectDotEnv | Out-Null

    if ($env:NEON_DATABASE_URL) {
        return $env:NEON_DATABASE_URL.Trim().Trim('"').Trim("'")
    }

    if ($env:DATABASE_URL -match 'neon\.tech') {
        return $env:DATABASE_URL.Trim().Trim('"').Trim("'")
    }

    return $null
}

function Format-RedactedDbUrl {
    param([string]$DatabaseUrl)

    if (-not $DatabaseUrl) { return "(not set)" }
    return ($DatabaseUrl -replace '://([^:@/]+):([^@/]+)@', '://$1:***@')
}

function Set-PgPasswordFromUrl {
    param([string]$DatabaseUrl)

    if ($DatabaseUrl -match 'postgres(?:ql)?://[^:/@]+:([^@]+)@') {
        $env:PGPASSWORD = [System.Uri]::UnescapeDataString($matches[1])
        return
    }

    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}

function Test-PostgresUrl {
    param([string]$DatabaseUrl)

    return ($DatabaseUrl -match '^postgres(ql)?://')
}

function Get-BackupDirectory {
    return (Join-Path (Get-ProjectRoot) "backups")
}

function Resolve-LocalBackupFile {
    param(
        [string]$BackupFile,
        [string]$BackupDir = (Get-BackupDirectory)
    )

    if ($BackupFile) {
        $resolved = Resolve-Path $BackupFile -ErrorAction SilentlyContinue
        if (-not $resolved) {
            throw "Backup file not found: $BackupFile"
        }
        return $resolved.Path
    }

    $candidates = @(
        (Join-Path $BackupDir "local_backup.sql")
    )

    $latest = Get-ChildItem -Path $BackupDir -Filter "local_backup_*.sql" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($latest) {
        $candidates = @($latest.FullName) + $candidates
    }

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    throw "No local backup found in $BackupDir (expected local_backup.sql or local_backup_*.sql)"
}

function Invoke-NeonQuery {
    param(
        [string]$PsqlPath,
        [string]$DatabaseUrl,
        [string]$Query
    )

    Set-PgPasswordFromUrl -DatabaseUrl $DatabaseUrl
    $result = & $PsqlPath $DatabaseUrl -t -A -c $Query 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw ($result | Out-String).Trim()
    }

    return ($result | Out-String).Trim()
}

function Reset-NeonPublicSchema {
    param(
        [string]$PsqlPath,
        [string]$DatabaseUrl
    )

    $sql = @"
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO neondb_owner;
"@

    Set-PgPasswordFromUrl -DatabaseUrl $DatabaseUrl
    & $PsqlPath $DatabaseUrl -v ON_ERROR_STOP=1 -c $sql 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to reset public schema before import."
    }
}

function Invoke-PsqlFile {
    param(
        [string]$PsqlPath,
        [string]$DatabaseUrl,
        [string]$SqlFile
    )

    # psql -f avoids PowerShell pipe issues that break COPY ... FROM stdin blocks.
    Set-PgPasswordFromUrl -DatabaseUrl $DatabaseUrl
    $output = & $PsqlPath $DatabaseUrl -v ON_ERROR_STOP=1 -f $SqlFile 2>&1
    $text = ($output | Out-String).Trim()

    if ($LASTEXITCODE -ne 0) {
        throw $text
    }

    return $text
}
