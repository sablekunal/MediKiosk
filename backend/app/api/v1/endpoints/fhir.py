from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.schemas.fhir import FhirBundle
from app.services.fhir_mapper import FhirMapper
from app.services.intake_service import IntakeService

router = APIRouter()


@router.get("/{session_id}/fhir", response_model=FhirBundle)
async def export_fhir(session_id: str, database: AsyncSession = Depends(get_session)) -> FhirBundle:
    canonical = await IntakeService(database).get(session_id)
    mapper = FhirMapper()
    bundle = mapper.to_bundle(canonical)
    diagnostics = mapper.validate(bundle)
    if diagnostics:
        raise HTTPException(status_code=422, detail={"message": "FHIR bundle validation failed", "diagnostics": diagnostics})
    return bundle
