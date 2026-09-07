from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api.v1.router import router as api_router
from app.core.config import get_settings
from app.core.database import create_database_schema


@asynccontextmanager
async def lifespan(_: FastAPI):
    await create_database_schema()
    yield


settings = get_settings()
app = FastAPI(
    title="MediKiosk Variant C API",
    version="0.1.0",
    description="Deterministic clinical intake and FHIR R4 export. Not a diagnostic service.",
    lifespan=lifespan,
)
app.include_router(api_router, prefix=settings.api_v1_prefix)
