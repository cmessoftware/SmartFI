param(
    [string]$ContainerName = "smartfi-gitea",
    [string]$VolumeName = "smartfi_gitea_data",
    [switch]$KeepData
)

$ErrorActionPreference = "Stop"

function Test-CommandAvailable {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-Host "Resetting Gitea..." -ForegroundColor Cyan

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

$containerExists = docker ps -a --filter "name=^/$ContainerName$" --format "{{.Names}}"
if ($containerExists -eq $ContainerName) {
    $isRunning = docker ps --filter "name=^/$ContainerName$" --format "{{.Names}}"
    if ($isRunning -eq $ContainerName) {
        docker stop $ContainerName | Out-Null
    }

    docker rm $ContainerName | Out-Null
    Write-Host "Container '$ContainerName' removed." -ForegroundColor Green
} else {
    Write-Host "Container '$ContainerName' does not exist. Skipping container removal." -ForegroundColor Yellow
}

if (-not $KeepData) {
    $volumeExists = docker volume ls --filter "name=^$VolumeName$" --format "{{.Name}}"
    if ($volumeExists -eq $VolumeName) {
        docker volume rm $VolumeName | Out-Null
        Write-Host "Volume '$VolumeName' removed." -ForegroundColor Green
    } else {
        Write-Host "Volume '$VolumeName' does not exist. Skipping volume removal." -ForegroundColor Yellow
    }
} else {
    Write-Host "KeepData enabled. Volume '$VolumeName' was preserved." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Reset completed." -ForegroundColor Cyan
Write-Host "To start again, run: .\scripts\start-gitea.ps1" -ForegroundColor White
