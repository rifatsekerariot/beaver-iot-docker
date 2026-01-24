# Zero-touch deploy: Beaver IoT + ChirpStack v4 on a Windows server.
# Usage: irm <url> | iex -ArgumentList "-TenantId", "default"
# Or:    .\deploy-zero-touch.ps1 -TenantId "default" [-Workspace "C:\beaver-chirpstack"] [-InstallDocker]

param(
    [string]$TenantId = "",
    [string]$Workspace = "",
    [switch]$InstallDocker
)

$ErrorActionPreference = "Stop"
$RepoIntegrations = "https://github.com/rifatsekerariot/beaver-iot-integrations.git"
$RepoDocker       = "https://github.com/rifatsekerariot/beaver-iot-docker.git"
$MavenImage      = "maven:3.8-eclipse-temurin-17-alpine"

if (-not $Workspace) {
    $Workspace = Join-Path $env:LOCALAPPDATA "beaver-chirpstack"
}

$env:CHIRPSTACK_DEFAULT_TENANT_ID = $TenantId
Write-Host "[zero-touch] Workspace: $Workspace"
Write-Host "[zero-touch] Tenant ID:  $(if ($TenantId) { $TenantId } else { '<not set>' })"

# Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    if ($InstallDocker) {
        Write-Host "[zero-touch] Installing Docker Desktop via winget..."
        winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements 2>$null
        Write-Host "[zero-touch] Please start Docker Desktop and re-run this script."
        exit 1
    }
    Write-Host "[zero-touch] Docker not found. Install Docker Desktop or use -InstallDocker."
    exit 1
}

# Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[zero-touch] Git not found. Install Git for Windows and re-run."
    exit 1
}

# Workspace
New-Item -ItemType Directory -Force -Path $Workspace | Out-Null
Set-Location $Workspace

# Clone
$intDir = Join-Path $Workspace "beaver-iot-integrations"
$docDir = Join-Path $Workspace "beaver-iot-docker"

if (-not (Test-Path $intDir)) {
    Write-Host "[zero-touch] Cloning beaver-iot-integrations..."
    git clone --depth 1 -b main $RepoIntegrations $intDir
} else {
    Write-Host "[zero-touch] Pulling beaver-iot-integrations..."
    Push-Location $intDir
    git fetch origin main 2>$null; git checkout main 2>$null; git pull --depth 1 2>$null
    Pop-Location
}

if (-not (Test-Path $docDir)) {
    Write-Host "[zero-touch] Cloning beaver-iot-docker..."
    git clone --depth 1 -b main $RepoDocker $docDir
} else {
    Write-Host "[zero-touch] Pulling beaver-iot-docker..."
    Push-Location $docDir
    git fetch origin main 2>$null; git checkout main 2>$null; git pull --depth 1 2>$null
    Pop-Location
}

# Build JAR
Write-Host "[zero-touch] Building chirpstack-integration JAR..."
docker run --rm `
    -v "${intDir}:/workspace" `
    -w /workspace `
    $MavenImage `
    mvn clean package -DskipTests -pl integrations/chirpstack-integration -am -q

$jarDir = Join-Path $intDir "integrations\chirpstack-integration\target"
$jar = Get-ChildItem -Path $jarDir -Filter "chirpstack-integration-*.jar" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch "original" } | Select-Object -First 1
if (-not $jar) {
    Write-Error "[zero-touch] ChirpStack JAR not found."
    exit 1
}
Write-Host "[zero-touch] Built: $($jar.FullName)"

# Copy JAR
$targetDir = Join-Path $docDir "examples\target\chirpstack\integrations"
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item $jar.FullName -Destination $targetDir -Force
Write-Host "[zero-touch] Copied JAR to $targetDir"

# Compose up
$examples = Join-Path $docDir "examples"
Set-Location $examples
Write-Host "[zero-touch] Starting Beaver IoT + ChirpStack stack..."
docker compose -f chirpstack.yaml up -d

Write-Host ""
Write-Host "[zero-touch] Done."
Write-Host "  UI:       http://localhost:9080"
Write-Host "  Webhook:  http://<this-server-ip>:9080/public/integration/chirpstack/webhook"
Write-Host "  Logs:     docker logs -f beaver-iot"
