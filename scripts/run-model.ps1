param (
    [Parameter(Mandatory = $true)]
    [string]$ModelName,

    [switch]$Gpu
)

$ErrorActionPreference = "Stop"

$RootPath = Split-Path -Parent $PSScriptRoot
$ModelPath = Join-Path $RootPath "models\$ModelName"
$ConfigPath = Join-Path $ModelPath "config.env"
$ComposePath = Join-Path $RootPath "docker-compose.yml"
$WebModelConfigPath = Join-Path $RootPath "web\model-config.json"

if (-not (Test-Path $ModelPath)) {
    throw "Model directory not found: $ModelPath"
}

if (-not (Test-Path $ConfigPath)) {
    throw "Model configuration not found: $ConfigPath"
}

if (-not (Test-Path $ComposePath)) {
    throw "Docker Compose file not found: $ComposePath"
}

$config = @{}

Get-Content $ConfigPath | ForEach-Object {
    $line = $_.Trim()

    if ([string]::IsNullOrWhiteSpace($line)) {
        return
    }

    if ($line.StartsWith("#")) {
        return
    }

    $parts = $line.Split("=", 2)

    if ($parts.Count -ne 2) {
        throw "Invalid configuration line: $line"
    }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim()

    $config[$key] = $value
}

if (-not $config.ContainsKey("MODEL")) {
    throw "MODEL is not defined in $ConfigPath"
}

if (-not $config.ContainsKey("IMAGE_NAME")) {
    throw "IMAGE_NAME is not defined in $ConfigPath"
}

$Model = $config["MODEL"]
$ImageName = $config["IMAGE_NAME"]

Write-Host ""
Write-Host "========================================"
Write-Host " Local LLM - Starting"
Write-Host "========================================"
Write-Host "Model:       $ModelName"
Write-Host "Ollama:      $Model"
Write-Host "Image:       $ImageName"
Write-Host "GPU:         $Gpu"
Write-Host "Web UI:      http://localhost:3000"
Write-Host "API:         http://localhost:11434"
Write-Host "========================================"
Write-Host ""

$modelConfig = @{
    model = $Model
} | ConvertTo-Json

[System.IO.File]::WriteAllText(
    $WebModelConfigPath,
    $modelConfig,
    [System.Text.UTF8Encoding]::new($false)
)

$env:OLLAMA_IMAGE = $ImageName
$env:OLLAMA_MODEL = $Model

if ($Gpu) {
    $env:GPU_ENABLED = "true"
}
else {
    $env:GPU_ENABLED = "false"
}

Push-Location $RootPath

try {
    docker compose down

    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose shutdown failed."
    }

    docker compose up --build
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "Docker Compose failed."
}