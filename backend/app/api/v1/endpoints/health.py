from fastapi import APIRouter

from app.engine.grammar_registry import GrammarRegistry
from app.engine.llm_client import LocalLlamaClient
from app.services.runtime import asr_service, ocr_service, tts_service

router = APIRouter()


@router.get("/health")
async def health() -> dict:
    registry = GrammarRegistry()
    grammars = registry.names()
    llm = LocalLlamaClient()
    llm._ensure_loaded()  # invokes no model inference and reports deployment readiness
    asr = asr_service()
    tts = tts_service()
    ocr = ocr_service()
    return {
        "status": "ok",
        "grammar_count": len(grammars),
        "services": {
            "llm": {"ready": llm.available, "detail": llm.load_error},
            "asr": {"configured": asr.configured, "ready": asr.ready, "detail": asr.detail},
            "tts": {"configured": tts.configured, "ready": tts.ready, "detail": tts.detail},
            "ocr": {"configured": True, "ready": ocr.ready, "detail": ocr.detail},
        },
    }
