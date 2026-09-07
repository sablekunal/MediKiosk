import asyncio
import os
from dataclasses import dataclass

from app.core.config import get_settings


class OcrUnavailableError(RuntimeError):
    pass


@dataclass(slots=True)
class OcrResult:
    text: str
    blocks: list[dict]
    mean_confidence: float | None


class LocalOcrService:
    """PaddleOCR adapter. Models are downloaded once by Paddle into the configured local cache."""

    def __init__(self) -> None:
        self.settings = get_settings()
        self._engine = None
        self._error: str | None = None

    @property
    def ready(self) -> bool:
        return self._engine is not None

    @property
    def detail(self) -> str | None:
        return self._error

    def _load(self) -> None:
        if self._engine or self._error:
            return
        try:
            from paddleocr import PaddleOCR

            self.settings.ocr_model_root.mkdir(parents=True, exist_ok=True)
            os.environ.setdefault("PADDLE_PDX_CACHE_HOME", str(self.settings.ocr_model_root))
            self._engine = PaddleOCR(lang=self.settings.ocr_language, use_doc_orientation_classify=False, use_doc_unwarping=False, use_textline_orientation=False)
        except Exception as error:
            self._error = f"OCR engine unavailable: {error}"

    async def recognize(self, image_path: str) -> OcrResult:
        self._load()
        if not self._engine:
            raise OcrUnavailableError(self._error or "OCR engine unavailable")

        def run() -> OcrResult:
            results = self._engine.predict(image_path)
            blocks: list[dict] = []
            scores: list[float] = []
            for result in results:
                payload = result.json if hasattr(result, "json") else result
                data = payload if isinstance(payload, dict) else {}
                texts = data.get("rec_texts", [])
                confidences = data.get("rec_scores", [])
                boxes = data.get("rec_boxes", [])
                for text, confidence, box in zip(texts, confidences, boxes):
                    blocks.append({"text": str(text), "confidence": float(confidence), "box": box})
                    scores.append(float(confidence))
            return OcrResult("\n".join(block["text"] for block in blocks), blocks, sum(scores) / len(scores) if scores else None)

        return await asyncio.to_thread(run)
