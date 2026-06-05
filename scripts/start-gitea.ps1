param(
    [string]$ContainerName = "gitea",
    [string]$Image = "gitea/gitea:1.22",
    [int]$HttpPort = 3001,
    [int]$SshPort = 222,
    [string]$VolumeName = "gitea_data"
)

$ErrorActionPreference = "Stop"

function Test-CommandAvailable {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-Host "Starting Gitea..." -ForegroundColor Cyan

if (-not (Test-CommandAvailable -Command "docker")) {
    Write-Host "Docker is not installed or not in PATH." -ForegroundColor Red
    exit 1
}

# Validate Docker daemon is up.
try {
    docker info | Out-Null
} catch {
    Write-Host "Docker daemon is not running. Start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

$existingContainer = docker ps -a --filter "name=^/$ContainerName$" --format "{{.Names}}"
$isRunning = docker ps --filter "name=^/$ContainerName$" --format "{{.Names}}"

if ($isRunning -eq $ContainerName) {
    Write-Host "Gitea is already running in container '$ContainerName'." -ForegroundColor Yellow
} elseif ($existingContainer -eq $ContainerName) {
    Write-Host "Container exists but is stopped. Starting '$ContainerName'..." -ForegroundColor Yellow
    docker start $ContainerName | Out-Null
    Write-Host "Container started." -ForegroundColor Green
} else {
    Write-Host "Creating and starting container '$ContainerName'..." -ForegroundColor Yellow
    docker run -d `
        --name $ContainerName `
        --restart unless-stopped `
        -p "${HttpPort}:3000" `
        -p "${SshPort}:22" `
        -v "${VolumeName}:/data" `
        $Image | Out-Null

    Write-Host "Container created and started." -ForegroundColor Green
}

Write-Host ""
Write-Host "Gitea URL: http://localhost:$HttpPort" -ForegroundColor Cyan
Write-Host "SSH endpoint: ssh://git@localhost:$SshPort" -ForegroundColor Cyan
Write-Host ""
Write-Host "First run setup:" -ForegroundColor White
Write-Host "1. Open the URL above." -ForegroundColor White
Write-Host "2. Complete the installer form (SQLite with /data/gitea/gitea.db works for local use)." -ForegroundColor White
Write-Host "3. Create your admin user." -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor White
Write-Host "- Logs: docker logs -f $ContainerName" -ForegroundColor White
Write-Host "- Stop: docker stop $ContainerName" -ForegroundColor White
Write-Host "- Remove: docker rm -f $ContainerName" -ForegroundColor White
