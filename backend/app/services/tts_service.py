import asyncio
import io
import wave

from app.core.config import get_settings


class TtsUnavailableError(RuntimeError):
    pass


class LocalTtsService:
    """Piper ONNX speech synthesis that returns a standard WAV payload."""

    def __init__(self) -> None:
        self.settings = get_settings()
        self._voices: dict[str, object] = {}
        self._errors: dict[str, str] = {}

    @property
    def configured(self) -> bool:
        return bool(self.settings.tts_voice_root or (self.settings.tts_voice_model_path and self.settings.tts_voice_config_path))

    @property
    def ready(self) -> bool:
        return bool(self._voices)

    @property
    def detail(self) -> str | None:
        if self._errors:
            return "; ".join(self._errors.values())
        return "Set MEDIKIOSK_TTS_VOICE_ROOT or MEDIKIOSK_TTS_VOICE_MODEL_PATH and MEDIKIOSK_TTS_VOICE_CONFIG_PATH" if not self.configured else None

    def _voice_paths(self, language: str) -> tuple[str, object, object]:
        key = "hi" if language.lower().startswith("hi") else "en"
        if self.settings.tts_voice_root:
            root = self.settings.tts_voice_root / key
            return key, root / f"{key}.onnx", root / f"{key}.onnx.json"
        return key, self.settings.tts_voice_model_path, self.settings.tts_voice_config_path

    def _load(self, language: str) -> object:
        key, model_path, config_path = self._voice_paths(language)
        if key in self._voices:
            return self._voices[key]
        if key in self._errors:
            raise TtsUnavailableError(self._errors[key])
        if not model_path or not config_path or not model_path.is_file() or not config_path.is_file():
            self._errors[key] = f"Piper {key} voice model or config file does not exist"
            raise TtsUnavailableError(self._errors[key])
        try:
            from piper import PiperVoice

            self._voices[key] = PiperVoice.load(str(model_path), str(config_path))
            return self._voices[key]
        except Exception as error:
            self._errors[key] = f"TTS {key} voice unavailable: {error}"
            raise TtsUnavailableError(self._errors[key]) from error

    async def synthesize(self, text: str, language: str = "en") -> bytes:
        if not text.strip():
            raise ValueError("Text to synthesize is empty")
        if len(text) > 2000:
            raise ValueError("Text exceeds the 2,000-character synthesis limit")
        voice = self._load(language)

        def run() -> bytes:
            stream = io.BytesIO()
            with wave.open(stream, "wb") as wav_file:
                voice.synthesize_wav(text, wav_file)
            return stream.getvalue()

        return await asyncio.to_thread(run)
