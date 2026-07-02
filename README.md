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
tts/kokoro/output/audio.wav
```

Run TTS is equivalent to the command on the CLI

```powershell
kokoro-tts tts\kokoro\input\input.txt tts\kokoro\output\output.wav --speed 0.8 --voice af_sarah --lang en-us --model tts\kokoro\models\kokoro-v1.0.onnx --voices tts\kokoro\models\voices-v1.0.bin
```

## 🧹 Cleanup

To reset environment or outputs:

```powershell
.\tts\kokoro\cleanup.ps1
```