param(
    [string]$ContainerName = "smartfi-gitea"
)

$ErrorActionPreference = "Stop"

function Test-CommandAvailable {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-Host "Stopping Gitea..." -ForegroundColor Cyan

if (-not (Test-CommandAvailable -Command "docker")) {
    Write-Host "Docker is not installed or not in PATH." -ForegroundColor Red
    exit 1
}

try {
    docker info | Out-Null
} catch {
    Write-Host "Docker daemon is not running. Start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

$exists = docker ps -a --filter "name=^/$ContainerName$" --format "{{.Names}}"
if ($exists -ne $ContainerName) {
    Write-Host "Container '$ContainerName' does not exist." -ForegroundColor Yellow
    exit 0
}

$isRunning = docker ps --filter "name=^/$ContainerName$" --format "{{.Names}}"
if ($isRunning -eq $ContainerName) {
    docker stop $ContainerName | Out-Null
    Write-Host "Container '$ContainerName' stopped." -ForegroundColor Green
} else {
    Write-Host "Container '$ContainerName' is already stopped." -ForegroundColor Yellow
}
