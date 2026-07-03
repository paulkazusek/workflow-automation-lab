$ErrorActionPreference = "Stop"

Write-Host "== WhisperX Cleanup ==" -ForegroundColor Cyan

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$envPath = "$root\envs\whisperx_py311"
$modulePath = "$root\stt\whisperx"

# 1. OUTPUT löschen
$confirm = Read-Host "Output löschen? (y/n)"
if ($confirm -eq "y") {
    if (Test-Path "$modulePath\output") {
        Remove-Item "$modulePath\output\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Output gelöscht" -ForegroundColor Yellow
    }
}

# 2. MODELS löschen (optional)
$confirm = Read-Host "Models löschen? (y/n)"
if ($confirm -eq "y") {
    if (Test-Path "$modulePath\models") {
        Remove-Item "$modulePath\models\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Models gelöscht" -ForegroundColor Yellow
    }
}

# 3. VENV löschen (FULL RESET)
$confirm = Read-Host "WhisperX venv löschen? (y = kompletter Reset)?"
if ($confirm -eq "y") {
    if (Test-Path $envPath) {
        Remove-Item $envPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "venv gelöscht" -ForegroundColor Red
    }
} else {
    Write-Host "venv bleibt erhalten" -ForegroundColor Gray
}

# 4. TEMP FILES
Get-ChildItem -Path $modulePath -Include *.pyc,*.tmp -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force

Write-Host "`nCleanup fertig." -ForegroundColor Green
