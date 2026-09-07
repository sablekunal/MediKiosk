from datetime import datetime, timezone
from enum import StrEnum
from uuid import UUID, uuid4

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.schemas.ayurveda import AyurvedicProfile
from app.schemas.socrates import SocratesProfile


class AdministrativeGender(StrEnum):
    FEMALE = "female"
    MALE = "male"
    OTHER = "other"
    UNKNOWN = "unknown"


class EncounterStatus(StrEnum):
    IN_PROGRESS = "in-progress"
    FINISHED = "finished"
    CANCELLED = "cancelled"


class PatientDemographics(BaseModel):
    identifier: str | None = Field(default=None, max_length=100)
    given_name: str | None = Field(default=None, max_length=100)
    family_name: str | None = Field(default=None, max_length=100)
    birth_date: str | None = Field(default=None, pattern=r"^\d{4}-\d{2}-\d{2}$")
    gender: AdministrativeGender | None = None
    language: str = Field(default="en", min_length=2, max_length=10)


class ChiefComplaint(BaseModel):
    text: str | None = Field(default=None, max_length=1000)
    snomed_code: str | None = Field(default=None, max_length=30)
    icd10_code: str | None = Field(default=None, max_length=20)


class ExtractionTelemetry(BaseModel):
    model_config = ConfigDict(extra="forbid")

    engine: str = "unprocessed"
    confidence: float | None = Field(default=None, ge=0, le=1)
    grammar_name: str | None = None
    attempts: int = Field(default=0, ge=0)
    diagnostics: list[str] = Field(default_factory=list)
    extracted_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class CanonicalEncounter(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: UUID = Field(default_factory=uuid4)
    status: EncounterStatus = EncounterStatus.IN_PROGRESS
    started_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    patient: PatientDemographics = Field(default_factory=PatientDemographics)
    chief_complaint: ChiefComplaint = Field(default_factory=ChiefComplaint)
    socrates: SocratesProfile = Field(default_factory=SocratesProfile)
    ayurveda: AyurvedicProfile = Field(default_factory=AyurvedicProfile)
    extraction_telemetry: dict[str, ExtractionTelemetry] = Field(default_factory=dict)

    @field_validator("updated_at")
    @classmethod
    def updated_after_started(cls, value: datetime, info):
        started = info.data.get("started_at")
        if started and value < started:
            raise ValueError("updated_at must be on or after started_at")
        return value
