# WhisperX

https://github.com/m-bain/whisperx

https://huggingface.co/pyannote/speaker-diarization-community-1

https://huggingface.co/pyannote/segmentation-3.0

```
whisperx stt\whisperx\input\audio.mp3 --model large-v3 --language en --compute_type float32 --output_dir stt\whisperx\output
```

```
whisperx stt\whisperx\input\audio.mp3 --model large-v3 --language en --diarize --compute_type float32 --output_dir stt\whisperx\output --output_format all  --hf_token TOKEN
```
