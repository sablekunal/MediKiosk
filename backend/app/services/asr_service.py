import asyncio
import io
from dataclasses import dataclass

from app.core.config import get_settings


class AsrUnavailableError(RuntimeError):
    pass


@dataclass(slots=True)
class Transcription:
    text: str
    language: str | None
    language_probability: float | None
    duration_seconds: float | None
    segments: list[dict[str, float | str]]


class LocalAsrService:
    """Lazy local faster-whisper service; no audio leaves the compute box."""

    def __init__(self) -> None:
        self.settings = get_settings()
        self._model = None
        self._error: str | None = None

    @property
    def configured(self) -> bool:
        return bool(self.settings.asr_model)

    @property
    def ready(self) -> bool:
        return self._model is not None

    @property
    def detail(self) -> str | None:
        return self._error

    def _load(self) -> None:
        if self._model or self._error:
            return
        try:
            from faster_whisper import WhisperModel

            self.settings.asr_download_root.mkdir(parents=True, exist_ok=True)
            self._model = WhisperModel(
                self.settings.asr_model,
                device=self.settings.asr_device,
                compute_type=self.settings.asr_compute_type,
                download_root=str(self.settings.asr_download_root),
            )
        except Exception as error:
            self._error = f"ASR model unavailable: {error}"

    async def transcribe(self, audio: bytes, filename: str, language: str | None = None) -> Transcription:
        if not audio:
            raise ValueError("Audio upload is empty")
        self._load()
        if not self._model:
            raise AsrUnavailableError(self._error or "ASR model unavailable")

        def run() -> Transcription:
            # faster-whisper accepts a file-like binary stream and decodes audio through PyAV.
            segments, info = self._model.transcribe(io.BytesIO(audio), language=language, vad_filter=True)
            rendered = list(segments)
            return Transcription(
                text=" ".join(segment.text.strip() for segment in rendered).strip(),
                language=getattr(info, "language", None),
                language_probability=getattr(info, "language_probability", None),
                duration_seconds=getattr(info, "duration", None),
                segments=[{"start": segment.start, "end": segment.end, "text": segment.text.strip()} for segment in rendered],
            )

        return await asyncio.to_thread(run)
