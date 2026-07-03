$ErrorActionPreference = "Stop"

Write-Host "== WhisperX Run (Single Speaker) ==" -ForegroundColor Cyan

$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$envPath    = "$root\envs\whisperx_py311"
$modulePath = "$root\stt\whisperx"
$inputDir   = "$modulePath\input"
$outputDir  = "$modulePath\output"

# 1. Input file finden
$audioFile = Get-ChildItem -Path "$inputDir\*" -Include *.wav,*.mp3 -File | Select-Object -First 1
if (!$audioFile) {
    throw "Keine Audio-Datei (.wav/.mp3) gefunden in: $inputDir"
}
Write-Host "Input: $($audioFile.Name)" -ForegroundColor Gray

# 2. venv aktivieren
. "$envPath\Scripts\Activate.ps1"

# 3. GPU / CPU erkennen
$device = "cuda"       # {cpu, cuda}
$computeType = "float32"  # {default, float16, float32, int8}
$batchSize = "8"       # {1, 2, 4, 8, 16}

$model = "large-v3"    # {tiny, base, small, medium, large-v1, large-v2, large-v3, large-v3-turbo}
$language = "en"
$outputFormat = "all"  # {all,srt,vtt,txt,tsv,json,aud}

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

# 4. Output-Dateiname
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($audioFile.Name)
$consoleLog = Join-Path $outputDir "konsole.txt"

# 5. Transkription
Write-Host "Transkribiere..." -ForegroundColor Yellow
whisperx $audioFile.FullName `
    --model $model `
    --language $language `
    --device $device `
    --compute_type $computeType `
    --output_dir $outputDir `
    --output_format $outputFormat `
    --batch_size $batchSize | Tee-Object -FilePath $consoleLog

if ($LASTEXITCODE -ne 0) {
    throw "whisperx fehlgeschlagen (Exit-Code: $LASTEXITCODE)"
}

if (Test-Path "$outputDir\$baseName.json") {
    Write-Host "Fertig: $outputDir\$baseName.*" -ForegroundColor Green
    Write-Host "Konsole: $consoleLog" -ForegroundColor Green
} else {
    throw "Output wurde nicht erzeugt!"
}
