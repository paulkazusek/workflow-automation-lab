$ErrorActionPreference = "Stop"

Write-Host "== WhisperX Run (Multi Speaker / Diarization) ==" -ForegroundColor Cyan

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$envPath    = "$root\envs\whisperx_py311"
$modulePath = "$root\stt\whisperx"
$inputDir   = "$modulePath\input"
$outputDir  = "$modulePath\output"
$envFile    = "$modulePath\.env"

# 1. HF_TOKEN aus .env laden
if (!(Test-Path $envFile)) {
    throw ".env fehlt: $envFile"
}
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*([^#=]+)=(.*)") {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        Set-Item -Path "env:$name" -Value $value
    }
}

if (!$env:HF_TOKEN -or $env:HF_TOKEN -eq "hf_dein_token_hier") {
    throw "HF_TOKEN ist nicht gesetzt oder noch der Platzhalter. Token in .env eintragen."
}

# 2. Input file finden
$audioFile = Get-ChildItem -Path "$inputDir\*" -Include *.wav,*.mp3 -File | Select-Object -First 1
if (!$audioFile) {
    throw "Keine Audio-Datei (.wav/.mp3) gefunden in: $inputDir"
}
Write-Host "Input: $($audioFile.Name)" -ForegroundColor Gray

# 3. venv aktivieren
. "$envPath\Scripts\Activate.ps1"

# 4. GPU / CPU erkennen
$device = "cuda" # (default: cpu) {cpu, cuda}
$computeType = "float32" # {default, float16, float32, int8}
$batchSize = "8" # (default: 8) {1, 2, 4, 8, 16}

$model = "large-v3" # {tiny, base, small, medium, large-v1, large-v2, large-v3, large-v3-turbo}
$language = "en"
$outputFormat = "all" # {all,srt,vtt,txt,tsv,json,aud}
$diarizeModel = "pyannote/speaker-diarization-community-1" #  (default: pyannote/speaker-diarization-community-1)

$result = python -c "import torch; exit(0 if torch.cuda.is_available() else 1)"
if ($LASTEXITCODE -eq 0) {
    $batchSize = "16"
    Write-Host "GPU (CUDA) verfügbar" -ForegroundColor Green
} else {
    $device = "cpu"
    $computeType = "int8"    # empfohlen für CPU
    $batchSize = "1"
    Write-Host "CPU-Modus" -ForegroundColor Yellow
}

# 5. Output-Dateiname
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($audioFile.Name)
$outputJson = "$outputDir\$baseName.json"
$outputTxt  = "$outputDir\$baseName.txt"
$consoleLog = Join-Path $outputDir "konsole.txt"

# 6. Transkription + Diarization
Write-Host "Transkribiere mit Diarization..." -ForegroundColor Yellow
whisperx $audioFile.FullName `
    --model $model `
    --language $language `
    --device $device `
    --compute_type $computeType `
    --diarize_model $diarizeModel `
    --diarize `
    --hf_token $env:HF_TOKEN `
    --output_dir $outputDir `
    --output_format $outputFormat `
    --batch_size $batchSize | Tee-Object -FilePath $consoleLog

if ($LASTEXITCODE -ne 0) {
    throw "whisperx fehlgeschlagen (Exit-Code: $LASTEXITCODE)"
}

if (Test-Path $outputJson) {
    Write-Host "Fertig: $outputJson" -ForegroundColor Green
    Write-Host "Konsole: $consoleLog" -ForegroundColor Green
} else {
    throw "Output wurde nicht erzeugt!"
}
