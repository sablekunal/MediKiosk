import os
import tempfile
from pathlib import Path

from fastapi import APIRouter, File, Form, HTTPException, Response, UploadFile
from pydantic import BaseModel, Field

from app.core.config import get_settings
from app.services.asr_service import AsrUnavailableError
from app.services.ocr_service import OcrUnavailableError
from app.services.runtime import asr_service, ocr_service, tts_service
from app.services.tts_service import TtsUnavailableError

router = APIRouter()
settings = get_settings()


class TranscriptResponse(BaseModel):
    text: str
    language: str | None
    language_probability: float | None
    duration_seconds: float | None
    segments: list[dict]


class OcrResponse(BaseModel):
    text: str
    blocks: list[dict]
    mean_confidence: float | None


class SynthesisRequest(BaseModel):
    text: str = Field(min_length=1, max_length=2000)
    language: str = Field(default="en", min_length=2, max_length=10)


async def _limited_upload(upload: UploadFile) -> bytes:
    data = await upload.read(settings.max_media_bytes + 1)
    if len(data) > settings.max_media_bytes:
        raise HTTPException(status_code=413, detail="Media upload exceeds configured size limit")
    if not data:
        raise HTTPException(status_code=422, detail="Media upload is empty")
    return data


@router.post("/transcribe", response_model=TranscriptResponse)
async def transcribe(audio: UploadFile = File(...), language: str | None = Form(default=None)) -> TranscriptResponse:
    if not (audio.content_type or "").startswith("audio/"):
        raise HTTPException(status_code=415, detail="Upload an audio/* media type")
    try:
        result = await asr_service().transcribe(await _limited_upload(audio), audio.filename or "audio", language)
    except AsrUnavailableError as error:
        raise HTTPException(status_code=503, detail=str(error)) from error
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error
    return TranscriptResponse(
        text=result.text,
        language=result.language,
        language_probability=result.language_probability,
        duration_seconds=result.duration_seconds,
        segments=result.segments,
    )


@router.post("/synthesize", response_class=Response)
async def synthesize(request: SynthesisRequest) -> Response:
    try:
        wav = await tts_service().synthesize(request.text, request.language)
    except TtsUnavailableError as error:
        raise HTTPException(status_code=503, detail=str(error)) from error
    except ValueError as error:
        raise HTTPException(status_code=422, detail=str(error)) from error
    return Response(content=wav, media_type="audio/wav", headers={"Content-Disposition": "inline; filename=medikiosk-response.wav"})


@router.post("/ocr", response_model=OcrResponse)
async def ocr(image: UploadFile = File(...)) -> OcrResponse:
    if not (image.content_type or "").startswith("image/"):
        raise HTTPException(status_code=415, detail="Upload an image/* media type")
    payload = await _limited_upload(image)
    suffix = Path(image.filename or "image.png").suffix or ".png"
    temporary_path: str | None = None
    try:
        with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as temporary_file:
            temporary_file.write(payload)
            temporary_path = temporary_file.name
        result = await ocr_service().recognize(temporary_path)
    except OcrUnavailableError as error:
        raise HTTPException(status_code=503, detail=str(error)) from error
    finally:
        if temporary_path:
            Path(temporary_path).unlink(missing_ok=True)
    return OcrResponse(text=result.text, blocks=result.blocks, mean_confidence=result.mean_confidence)
