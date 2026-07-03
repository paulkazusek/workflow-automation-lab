$ErrorActionPreference = "Stop"

Write-Host "== WhisperX Setup ==" -ForegroundColor Cyan

$root = (Resolve-Path "$PSScriptRoot\..\..").Path

# Pfade
$envPath    = "$root\envs\whisperx_py311"
$modulePath = "$root\stt\whisperx"
$reqFile    = "$modulePath\requirements.txt"

# 1. venv mit Python 3.11
if (!(Test-Path $envPath)) {
    py -3.11 -m venv $envPath
}

# 2. aktivieren + pip updaten
& "$envPath\Scripts\Activate.ps1"

# 3. pip updaten
python -m pip install --upgrade pip

# 4. requirements installieren
if (Test-Path $reqFile) {
    Write-Host "Installiere requirements.txt..." -ForegroundColor Cyan
    pip install -r $reqFile
} else {
    throw "requirements.txt fehlt: $reqFile"
}

# 5. Ordner anlegen
$dirs = @("$modulePath\input", "$modulePath\output", "$modulePath\models")
foreach ($d in $dirs) {
    if (!(Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# 6. .env aus .env.example (falls nicht vorhanden)
$envExample = "$modulePath\.env.example"
$envFile    = "$modulePath\.env"
if ((Test-Path $envExample) -and !(Test-Path $envFile)) {
    Copy-Item $envExample $envFile
    Write-Host ".env wurde aus .env.example angelegt – bitte HF_TOKEN eintragen" -ForegroundColor Yellow
}

# 7. CUDA-Check
try {
    $null = nvidia-smi 2>$null
    Write-Host "GPU (CUDA) verfügbar" -ForegroundColor Green
} catch {
    Write-Host "Kein NVIDIA GPU gefunden – CPU-Modus wird verwendet" -ForegroundColor Yellow
}

Write-Host "Setup fertig." -ForegroundColor Green