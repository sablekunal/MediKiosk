import re
from dataclasses import dataclass, field
from typing import Any

from app.core.config import get_settings
from app.engine.grammar_registry import GrammarRegistry
from app.engine.llm_client import LocalLlamaClient


_shared_llm = LocalLlamaClient()


@dataclass(slots=True)
class ExtractionResult:
    value: Any | None
    engine: str
    grammar_name: str
    confidence: float | None
    attempts: int
    diagnostics: list[str] = field(default_factory=list)


class ConstrainedExtractor:
    """Grammar-first extractor with deterministic fallback for essential kiosk continuity."""

    def __init__(self, registry: GrammarRegistry | None = None, llm: LocalLlamaClient | None = None):
        self.registry = registry or GrammarRegistry()
        self.llm = llm or _shared_llm
        self.settings = get_settings()

    async def extract(self, grammar_name: str, text: str) -> ExtractionResult:
        grammar = self.registry.get(grammar_name)
        diagnostics: list[str] = []
        for attempt in range(1, self.settings.extraction_retries + 1):
            try:
                response = await self.llm.extract_json(
                    text=text,
                    grammar=grammar,
                    prompt=("Extract only the requested clinical slot. Return JSON strictly permitted "
                            "by the supplied grammar. Do not infer a diagnosis."),
                )
                value = self._normalise_model_value(grammar_name, response)
                return ExtractionResult(value, "llama-cpp", grammar_name, 0.90, attempt, diagnostics)
            except Exception as error:
                diagnostics.append(f"LLM attempt {attempt}: {error}")
        if self.settings.allow_rule_based_fallback:
            value = self._rules(grammar_name, text)
            if value is not None:
                diagnostics.append("Used deterministic fallback; clinician review remains required.")
                return ExtractionResult(value, "rules", grammar_name, 0.55, self.settings.extraction_retries, diagnostics)
        return ExtractionResult(None, "unavailable", grammar_name, None, self.settings.extraction_retries, diagnostics)

    @staticmethod
    def _normalise_model_value(grammar_name: str, response: dict[str, Any]) -> Any:
        if "value" not in response:
            raise ValueError("Grammar-constrained response has no value property")
        value = response["value"]
        if grammar_name == "severity" and (not isinstance(value, int) or not 0 <= value <= 10):
            raise ValueError("Severity must be an integer from 0 to 10")
        return value

    @staticmethod
    def _rules(grammar_name: str, text: str) -> Any | None:
        lowered = text.lower().strip()
        if grammar_name == "yesno":
            if re.search(r"\b(yes|yeah|yep|haan|ha)\b", lowered): return "yes"
            if re.search(r"\b(no|nope|nah|nahi)\b", lowered): return "no"
        if grammar_name == "severity":
            match = re.search(r"\b(10|[0-9])\b", lowered)
            return int(match.group(1)) if match else None
        enum_values = {
            "agni": ("Manda", "Tikshna", "Vishama", "Sama"),
            "koshtha": ("Krura", "Madhyama", "Mridu"),
            "prakriti": ("Vata-Pitta", "Pitta-Kapha", "Kapha-Vata", "Sannipata", "Vata", "Pitta", "Kapha"),
            "vikriti": ("Vata-Pitta", "Pitta-Kapha", "Kapha-Vata", "Sannipata", "Vata", "Pitta", "Kapha"),
            "character": ("sharp", "dull", "throbbing", "burning", "aching", "colicky"),
        }
        if grammar_name in enum_values:
            found = [item for item in enum_values[grammar_name] if item.lower() in lowered]
            return found[0] if found else None
        if grammar_name in {"body_location", "duration", "time_course", "exacerbating_relieving", "ahara_vihara", "nidana", "dashavidha", "multi_select"}:
            clean = text.strip()
            return clean if clean else None
        return None
