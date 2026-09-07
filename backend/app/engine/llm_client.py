import asyncio
import json
from pathlib import Path
from typing import Any

from app.core.config import get_settings
from app.engine.grammar_registry import Grammar


class LocalLlamaClient:
    """Async facade over llama-cpp-python, imported only on configured deployments."""

    def __init__(self) -> None:
        self.settings = get_settings()
        self._model: Any | None = None
        self._load_error: str | None = None

    @property
    def available(self) -> bool:
        return self._model is not None

    @property
    def load_error(self) -> str | None:
        return self._load_error

    def _ensure_loaded(self) -> None:
        if self._model or self._load_error:
            return
        model_path: Path | None = self.settings.llm_model_path
        if not model_path:
            self._load_error = "MEDIKIOSK_LLM_MODEL_PATH is not configured"
            return
        if not model_path.is_file():
            self._load_error = f"Configured model does not exist: {model_path}"
            return
        try:
            from llama_cpp import Llama

            self._model = Llama(
                model_path=str(model_path), n_ctx=self.settings.llm_n_ctx,
                n_gpu_layers=self.settings.llm_n_gpu_layers, verbose=False,
            )
        except Exception as error:  # deployment-specific binary/model failures
            self._load_error = f"Unable to load local LLM: {error}"

    async def extract_json(self, *, text: str, grammar: Grammar, prompt: str) -> dict[str, Any]:
        self._ensure_loaded()
        if not self._model:
            raise RuntimeError(self._load_error or "Local LLM unavailable")

        def complete() -> dict[str, Any]:
            from llama_cpp import LlamaGrammar

            response = self._model.create_chat_completion(
                messages=[
                    {"role": "system", "content": prompt},
                    {"role": "user", "content": text},
                ],
                temperature=0,
                grammar=LlamaGrammar.from_string(grammar.source),
            )
            content = response["choices"][0]["message"]["content"]
            return json.loads(content)

        return await asyncio.to_thread(complete)
