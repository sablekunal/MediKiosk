from fastapi import APIRouter

from app.api.v1.endpoints import encounter, fhir, health, intake, media

router = APIRouter()
router.include_router(health.router, tags=["health"])
router.include_router(intake.router, prefix="/intake", tags=["intake"])
router.include_router(encounter.router, prefix="/encounter", tags=["encounter"])
router.include_router(fhir.router, prefix="/encounter", tags=["fhir"])
router.include_router(media.router, prefix="/media", tags=["local media inference"])
