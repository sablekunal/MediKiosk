from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.schemas.canonical_encounter import CanonicalEncounter
from app.services.intake_service import IntakeService

router = APIRouter()


@router.get("/{session_id}/canonical", response_model=CanonicalEncounter)
async def get_canonical(session_id: str, database: AsyncSession = Depends(get_session)) -> CanonicalEncounter:
    return await IntakeService(database).get(session_id)
