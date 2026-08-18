param (
    [Parameter(Mandatory = $true)]
    [string]$ModelName,

    [switch]$Gpu
)

$ErrorActionPreference = "Stop"

$RootPath = Split-Path -Parent $PSScriptRoot
$ModelPath = Join-Path $RootPath "models\$ModelName"
$ConfigPath = Join-Path $ModelPath "config.env"

if (-not (Test-Path $ModelPath)) {
    throw "Model directory not found: $ModelPath"
}

if (-not (Test-Path $ConfigPath)) {
    throw "Model configuration not found: $ConfigPath"
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

if (-not $config.ContainsKey("IMAGE_NAME")) {
    throw "IMAGE_NAME is not defined in $ConfigPath"
}

if (-not $config.ContainsKey("PORT")) {
    throw "PORT is not defined in $ConfigPath"
}

$ImageName = $config["IMAGE_NAME"]
$Port = $config["PORT"]

Write-Host ""
Write-Host "========================================"
Write-Host " Local LLM - Starting Model"
Write-Host "========================================"
Write-Host "Model:       $ModelName"
Write-Host "Image:       $ImageName"
Write-Host "Port:        $Port"
Write-Host "GPU:         $Gpu"
Write-Host "========================================"
Write-Host ""

$DockerArgs = @(
    "run",
    "--rm",
    "-p",
    "${Port}:${Port}"
)

if ($Gpu) {
    $DockerArgs += "--gpus"
    $DockerArgs += "all"
}

$DockerArgs += $ImageName

& docker @DockerArgs

if ($LASTEXITCODE -ne 0) {
    throw "Docker run failed."
}