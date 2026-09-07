# MediKiosk Variant C backend

FastAPI backend for a deterministic clinical-intake workflow. It stores a canonical encounter,
uses grammar-selected extraction (with a safe rules fallback when no local GGUF model is
configured), and exports an R4 `Bundle` without placing ABDM private key or decryption logic on
the compute box.

## Run

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install --default-timeout 120 --retries 5 -e ".[dev]"
uvicorn main:app --reload
```

Visit `/docs` for the API. For actual local LLM inference, set `MEDIKIOSK_LLM_MODEL_PATH` to a
local GGUF model and install `pip install -e ".[llm]"`. Inference remains optional at runtime so
kiosk intake is available during model outages.

## Local media services

Install all local media runtimes with `pip install -e ".[llm,services]"`. Configure the paths in
`.env` (copy from `.env.example`). The API exposes `POST /api/v1/media/transcribe`,
`POST /api/v1/media/synthesize`, and `POST /api/v1/media/ocr`. All adapters are local-only: audio,
speech, and images are processed on the compute box and are not sent to a hosted inference API.

`faster-whisper` downloads its ASR model on the first transcription. Piper requires a downloaded
`.onnx` voice and matching `.onnx.json` configuration. PaddleOCR acquires its OCR model on first
use. The `/api/v1/health` response reports which runtimes are configured and loaded.

To pre-download the complete English/Hindi demo asset set (Qwen LLM, faster-whisper ASR, English
and Hindi Piper voices, and PaddleOCR), run:

```powershell
python scripts/download_models.py --output D:\sih\models
```

Then set `MEDIKIOSK_LLM_MODEL_PATH` to the first Qwen GGUF shard and the two Piper model/config
environment variables to either the English or Hindi voice, or simply set
`MEDIKIOSK_TTS_VOICE_ROOT=D:\sih\models\tts` to enable both. Pass `"language": "hi"` or `"en"`
to the synthesis endpoint. Keep both Qwen shards in the same directory: llama.cpp resolves the
second shard automatically.

## Safety boundary

This project is intake documentation and structured data capture, not diagnosis or autonomous
triage. The backend intentionally never generates, accepts, stores, or decrypts ABDM Fidelius
private key material; an approved clinician-facing device owns those operations.
