$ErrorActionPreference = "Stop"

Write-Host "== Kokoro Setup ==" -ForegroundColor Cyan

# Root ermitteln (wichtig für Reproduzierbarkeit)
$root = (Resolve-Path "$PSScriptRoot\..\..").Path

# Pfade
$envPath = "$root\envs\kokoro_py312"
$modulePath = "$root\tts\kokoro"
$reqFile = "$modulePath\requirements.txt"

# 1. venv erstellen (falls nicht existiert)
if (!(Test-Path $envPath)) {
    py -3.12 -m venv $envPath
}

# 2. aktivieren
& "$envPath\Scripts\Activate.ps1"

# 3. pip updaten
python -m pip install --upgrade pip

# 4. Kokoro installieren
# 4. requirements installieren (SOURCE OF TRUTH)
if (Test-Path $reqFile) {
    Write-Host "Installiere requirements.txt..." -ForegroundColor Cyan
    pip install -r $reqFile
} else {
    throw "requirements.txt fehlt: $reqFile"
}

# 5. Ordnerstruktur im Modul
$dirs = @(
#    "$modulePath\input",
    "$modulePath\output",
    "$modulePath\models"
)

foreach ($d in $dirs) {
    if (!(Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

# 6. Modelle downloaden
$model = "$modulePath\models\kokoro-v1.0.onnx"
$voices = "$modulePath\models\voices-v1.0.bin"

if (!(Test-Path $model)) {
    Invoke-WebRequest `
        -Uri "https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/kokoro-v1.0.onnx" `
        -OutFile $model
}

if (!(Test-Path $voices)) {
    Invoke-WebRequest `
        -Uri "https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/voices-v1.0.bin" `
        -OutFile $voices
}

Write-Host "Setup fertig." -ForegroundColor Green