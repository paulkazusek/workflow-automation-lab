# kokoro-tts

https://github.com/nazdridoy/kokoro-tts

https://huggingface.co/onnx-community/Kokoro-82M-v1.0-ONNX

Run from the project root:

```powershell
kokoro-tts --help-voices --model tts\kokoro\models\kokoro-v1.0.onnx --voices tts\kokoro\models\voices-v1.0.bin
```

```powershell
kokoro-tts --help-languages --model tts\kokoro\models\kokoro-v1.0.onnx --voices tts\kokoro\models\voices-v1.0.bin
```

```powershell
kokoro-tts tts\kokoro\input\input.txt tts\kokoro\output\output.wav --speed 1.0 --voice af_sarah --lang en-us --model tts\kokoro\models\kokoro-v1.0.onnx --voices tts\kokoro\models\voices-v1.0.bin
```
