from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="MEDIKIOSK_", env_file=".env", extra="ignore")

    api_v1_prefix: str = "/api/v1"
    database_url: str = "sqlite+aiosqlite:///./medikiosk.db"
    llm_model_path: Path | None = None
    llm_n_ctx: int = 2048
    llm_n_gpu_layers: int = 0
    extraction_retries: int = 2
    allow_rule_based_fallback: bool = True
    asr_model: str = "Systran/faster-whisper-small"
    asr_device: str = "cpu"
    asr_compute_type: str = "int8"
    asr_download_root: Path = Path("./models/asr")
    tts_voice_model_path: Path | None = None
    tts_voice_config_path: Path | None = None
    tts_voice_root: Path | None = None
    ocr_language: str = "en"
    ocr_model_root: Path = Path("./models/ocr")
    max_media_bytes: int = 25 * 1024 * 1024


@lru_cache
def get_settings() -> Settings:
    return Settings()
