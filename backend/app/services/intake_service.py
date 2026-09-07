from datetime import datetime, timezone

from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.state_machine import IntakeStage, IntakeStateMachine, Slot
from app.engine.extractor import ConstrainedExtractor, ExtractionResult
from app.models.encounter import EncounterRecord
from app.models.session import IntakeSessionRecord
from app.schemas.canonical_encounter import CanonicalEncounter, EncounterStatus, ExtractionTelemetry


class IntakeService:
    def __init__(self, database: AsyncSession, extractor: ConstrainedExtractor | None = None):
        self.database = database
        self.extractor = extractor or ConstrainedExtractor()
        self.machine = IntakeStateMachine()

    async def start(self, initial: dict | None = None) -> CanonicalEncounter:
        encounter = CanonicalEncounter.model_validate(initial or {})
        session_id = str(encounter.id)
        self.database.add(EncounterRecord(session_id=session_id, canonical_json=encounter.model_dump_json()))
        self.database.add(IntakeSessionRecord(id=session_id, stage=self.machine.stage(encounter).value, completion_percent=self.machine.completion_percent(encounter)))
        await self.database.commit()
        return encounter

    async def get(self, session_id: str) -> CanonicalEncounter:
        record = await self.database.get(EncounterRecord, session_id)
        if not record:
            raise HTTPException(status_code=404, detail="Intake session not found")
        return CanonicalEncounter.model_validate_json(record.canonical_json)

    async def turn(self, session_id: str, text: str, selected_value: str | int | None = None) -> tuple[CanonicalEncounter, ExtractionResult | None, Slot | None]:
        encounter = await self.get(session_id)
        slot = self.machine.current_slot(encounter)
        if not slot:
            return encounter, None, None
        result = ExtractionResult(selected_value, "option", slot.grammar, 1.0, 0) if selected_value is not None else await self.extractor.extract(slot.grammar, text)
        if result.value is None:
            return encounter, result, slot
        try:
            self._set_value(encounter, slot.path, result.value)
        except (TypeError, ValueError) as error:
            result.value = None
            result.diagnostics.append(f"Validation rejected extraction: {error}")
            return encounter, result, slot
        encounter.updated_at = datetime.now(timezone.utc)
        encounter.extraction_telemetry[slot.path] = ExtractionTelemetry(engine=result.engine, confidence=result.confidence, grammar_name=result.grammar_name, attempts=result.attempts, diagnostics=result.diagnostics)
        if not self.machine.current_slot(encounter):
            encounter.status = EncounterStatus.FINISHED
        await self._save(encounter)
        return encounter, result, slot

    async def _save(self, encounter: CanonicalEncounter) -> None:
        record = await self.database.get(EncounterRecord, str(encounter.id))
        state = await self.database.get(IntakeSessionRecord, str(encounter.id))
        if not record or not state:
            raise HTTPException(status_code=404, detail="Intake session not found")
        record.canonical_json = encounter.model_dump_json()
        state.stage = self.machine.stage(encounter).value
        state.completion_percent = self.machine.completion_percent(encounter)
        await self.database.commit()

    @staticmethod
    def _set_value(encounter: CanonicalEncounter, path: str, value: object) -> None:
        if path == "patient.gender":
            value = str(value).lower()
        if path == "socrates.character":
            value = [value] if isinstance(value, str) else value
        if path in {"socrates.exacerbating_relieving.aggravating_factors", "ayurveda.ahara_vihara.dietary_patterns", "ayurveda.nidana"}:
            value = [value] if isinstance(value, str) else value
        target = encounter
        parts = path.split(".")
        for part in parts[:-1]: target = getattr(target, part)
        setattr(target, parts[-1], value)
        # Validate the mutated model and coerce nested enum values at the boundary.
        validated = CanonicalEncounter.model_validate(encounter.model_dump())
        encounter.__dict__.update(validated.__dict__)
