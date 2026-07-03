# workflow-automation-lab

A local, reproducible AI workflow system for content generation.

This project is designed to build automated pipelines for:
- Text-to-Speech (TTS)
- Speech-to-Text (STT)
- Audio preprocessing

---

## 🧠 Goal

The goal of this repository is to create a **fully reproducible AI content pipeline** that runs locally on Windows.

Example workflows:
- Audio → transcription → script → voiceover
- Script → TTS → audio output

---

## 📁 Project Structure

```
workflow-automation-lab/
│
├── envs/                     # isolated Python environments per tool
│
├── stt/
│   └── whisperx/             # WhisperX STT module
│       │
│       ├── input/            # audio input files
│       ├── output/           # transcriptions
│       ├── models/           # model cache
│       │
│       ├── setup.ps1         # one-click setup
│       ├── run.ps1           # single-speaker transcription
│       ├── run_diarize.ps1   # multi-speaker transcription
│       └── cleanup.ps1
│
├── tts/
│   └── kokoro/               # Kokoro TTS module
│       │
│       ├── input/            # text input files
│       ├── output/           # generated audio
│       ├── models/           # ONNX models + voices
│       │
│       ├── setup.ps1         # one-click setup
│       ├── run.ps1           # TTS execution
│
└── README.md
```

## 🔊 Kokoro TTS Module

The first implemented workflow is **Kokoro Text-to-Speech**, using ONNX models.

It runs fully locally and supports reproducible audio generation.

### Features
- Fully offline inference
- ONNX-based TTS model
- Reproducible setup via PowerShell
- Isolated Python environment (Python 3.12)

---

## ⚙️ Setup

Run from the project root:

```powershell
.\tts\kokoro\setup.ps1
```

## ▶️ Run TTS

```powershell
.\tts\kokoro\run.ps1
```

Input file:

```
tts/kokoro/input/input.txt
```

Output:

```
tts\kokoro\output\audio.wav
```

Run TTS is equivalent to the command on the CLI

```powershell
kokoro-tts tts\kokoro\input\input.txt tts\kokoro\output\output.wav --speed 0.8 --voice af_sarah --lang en-us --model tts\kokoro\models\kokoro-v1.0.onnx --voices tts\kokoro\models\voices-v1.0.bin
```

## 🎙️ WhisperX STT Module

**Speech-to-Text** with automatic speech recognition and optional **speaker diarization** (multi-speaker).

Uses WhisperX with batched inference (faster-whisper) and forced alignment for precise word-level timestamps.

### Features
- GPU-accelerated (CUDA), CPU fallback
- Optional speaker diarization via pyannote
- Output as JSON + TXT
- Isolated Python environment (Python 3.11)

### Setup

```powershell
.\stt\whisperx\setup.ps1
```

### Prerequisites for Speaker Diarization

1. Create a Hugging Face account
2. Generate a read token at https://huggingface.co/settings/tokens
3. Accept the terms of use for:
   - https://huggingface.co/pyannote/speaker-diarization-community-1
   - https://huggingface.co/pyannote/segmentation-3.0
4. Add your token to `stt/whisperx/.env`:
   ```
   HF_TOKEN=hf_your_token_here
   ```

### Run Single Speaker

```powershell
.\stt\whisperx\run.ps1
```

### Run Multi Speaker (with Diarization)

```powershell
.\stt\whisperx\run_diarize.ps1
```

### Input / Output

```
Input:   stt/whisperx/input/           # Audio (.wav, .mp3)
Output:  stt/whisperx/output/          # Transcript (.json + .txt)
```

### CLI Equivalent (Single Speaker)

```powershell
whisperx stt\whisperx\input\audio.wav --model large-v3 --output_format json --batch_size 16
```

### CLI Equivalent (Diarization)

```powershell
whisperx stt\whisperx\input\audio.wav --model large-v3 --diarize --hf_token $env:HF_TOKEN --output_format json --batch_size 16
```

---

## 🧹 Cleanup

To reset environment or outputs:

```powershell
.\tts\kokoro\cleanup.ps1
.\stt\whisperx\cleanup.ps1
```