from functools import lru_cache

from app.services.asr_service import LocalAsrService
from app.services.ocr_service import LocalOcrService
from app.services.tts_service import LocalTtsService


@lru_cache
def asr_service() -> LocalAsrService:
    return LocalAsrService()


@lru_cache
def tts_service() -> LocalTtsService:
    return LocalTtsService()


@lru_cache
def ocr_service() -> LocalOcrService:
    return LocalOcrService()
