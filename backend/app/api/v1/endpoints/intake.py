from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.services.intake_service import IntakeService

router = APIRouter()


class StartSessionRequest(BaseModel):
    patient: dict[str, Any] = Field(default_factory=dict)


class TurnRequest(BaseModel):
    transcript: str = Field(default="", max_length=4000)
    selected_value: str | int | None = None


class TurnResponse(BaseModel):
    session_id: str
    stage: str
    completion_percent: float
    next_prompt: str
    next_slot: str | None
    collected_slots: dict[str, Any]
    extraction: dict[str, Any] | None


@router.post("/session/start", response_model=TurnResponse, status_code=201)
async def start_session(request: StartSessionRequest, database: AsyncSession = Depends(get_session)) -> TurnResponse:
    service = IntakeService(database)
    encounter = await service.start({"patient": request.patient})
    slot = service.machine.current_slot(encounter)
    return TurnResponse(
        session_id=str(encounter.id), stage=service.machine.stage(encounter).value,
        completion_percent=service.machine.completion_percent(encounter), next_prompt=service.machine.next_prompt(encounter),
        next_slot=slot.path if slot else None, collected_slots=encounter.model_dump(mode="json"), extraction=None,
    )


@router.post("/session/{session_id}/turn", response_model=TurnResponse)
async def intake_turn(session_id: str, request: TurnRequest, database: AsyncSession = Depends(get_session)) -> TurnResponse:
    service = IntakeService(database)
    encounter, result, _ = await service.turn(session_id, request.transcript, request.selected_value)
    next_slot = service.machine.current_slot(encounter)
    return TurnResponse(
        session_id=session_id, stage=service.machine.stage(encounter).value,
        completion_percent=service.machine.completion_percent(encounter), next_prompt=service.machine.next_prompt(encounter),
        next_slot=next_slot.path if next_slot else None, collected_slots=encounter.model_dump(mode="json"),
        extraction={"value": result.value, "engine": result.engine, "grammar": result.grammar_name, "confidence": result.confidence, "attempts": result.attempts, "diagnostics": result.diagnostics} if result else None,
    )
