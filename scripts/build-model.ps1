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
    throw "Diretório do modelo não encontrado: $ModelPath"
}

if (-not (Test-Path $ConfigPath)) {
    throw "Arquivo de configuração do modelo não encontrado: $ConfigPath"
}

if (-not (Test-Path $DockerfilePath)) {
    throw "Dockerfile não encontrado: $DockerfilePath"
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
        throw "Linha de configuração inválida: $line"
    }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim()

    $config[$key] = $value
}

if (-not $config.ContainsKey("MODEL")) {
    throw "MODEL nao definido em $ConfigPath"
}

if (-not $config.ContainsKey("IMAGE_NAME")) {
    throw "IMAGE_NAME nao definida em $ConfigPath"
}

$Model = $config["MODEL"]
$ImageName = $config["IMAGE_NAME"]

Write-Host ""
Write-Host "========================================"
Write-Host " local llm - Construindo modelo"
Write-Host "========================================"
Write-Host "Modelo:       $Model"
Write-Host "Imagem:       $ImageName"
Write-Host "Contexto:     $RootPath"
Write-Host "========================================"
Write-Host ""

docker build `
    --build-arg "MODEL=$Model" `
    -t "$ImageName" `
    -f "$DockerfilePath" `
    "$RootPath"

if ($LASTEXITCODE -ne 0) {
    throw "Falha no build do docker."
}

Write-Host ""
Write-Host "========================================"
Write-Host " Build concluído com sucesso!"
Write-Host " Imagem: $ImageName"
Write-Host "========================================"