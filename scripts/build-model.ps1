param (
    [Parameter(Mandatory = $true)]
    [string]$ModelName
)

$ErrorActionPreference = "Stop"

$RootPath = Split-Path -Parent $PSScriptRoot
$ModelPath = Join-Path $RootPath "models\$ModelName"
$ConfigPath = Join-Path $ModelPath "config.env"
$DockerfilePath = Join-Path $RootPath "docker\Dockerfile"

if (-not (Test-Path $ModelPath)) {
    throw "Model directory not found: $ModelPath"
}

if (-not (Test-Path $ConfigPath)) {
    throw "Model configuration not found: $ConfigPath"
}

if (-not (Test-Path $DockerfilePath)) {
    throw "Dockerfile not found: $DockerfilePath"
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
Write-Host " Local LLM - Building Model"
Write-Host "========================================"
Write-Host "Model:       $Model"
Write-Host "Image:       $ImageName"
Write-Host "Context:     $RootPath"
Write-Host "========================================"
Write-Host ""

docker build `
    --build-arg "MODEL=$Model" `
    -t "$ImageName" `
    -f "$DockerfilePath" `
    "$RootPath"

if ($LASTEXITCODE -ne 0) {
    throw "Docker build failed."
}

Write-Host ""
Write-Host "========================================"
Write-Host " Build completed successfully!"
Write-Host " Image: $ImageName"
Write-Host "========================================"