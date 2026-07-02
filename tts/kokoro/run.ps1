$ErrorActionPreference = "Stop"

Write-Host "== Kokoro Run ==" -ForegroundColor Cyan

# Root ermitteln (Projektbasis)
$root = (Resolve-Path "$PSScriptRoot\..\..").Path

# Pfade
$envPath    = "$root\envs\kokoro_py312"
$modulePath = "$root\tts\kokoro"

$inputFile  = "$modulePath\input\input.txt"
$outputFile = "$modulePath\output\audio.wav"

$model      = "$modulePath\models\kokoro-v1.0.onnx"
$voices     = "$modulePath\models\voices-v1.0.bin"

# ------------------------
# 1. Checks
# ------------------------

if (!(Test-Path $inputFile)) {
    throw "Input fehlt: $inputFile"
}

if (!(Test-Path $model)) {
    throw "Model fehlt: $model (run setup.ps1)"
}

if (!(Test-Path $voices)) {
    throw "Voices fehlen: $voices (run setup.ps1)"
}

# ------------------------
# 2. Environment aktivieren
# ------------------------

& "$envPath\Scripts\Activate.ps1"

# ------------------------
# 3. Optional: pip sanity check
# ------------------------

python -m pip --version | Out-Null

# ------------------------
# 4. TTS ausführen
# ------------------------

Write-Host "Generiere Audio..." -ForegroundColor Yellow

kokoro-tts `
    $inputFile `
    $outputFile `
    --speed 0.8 `
    --voice af_sarah `
    --lang en-us `
    --model $model `
    --voices $voices

# ------------------------
# 5. Output bestätigen
# ------------------------

if (Test-Path $outputFile) {
    Write-Host "Fertig: $outputFile" -ForegroundColor Green
} else {
    throw "Output wurde nicht erzeugt!"
}