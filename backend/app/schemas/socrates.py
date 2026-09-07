from enum import StrEnum

from pydantic import BaseModel, Field, field_validator


class OnsetManner(StrEnum):
    SUDDEN = "sudden"
    GRADUAL = "gradual"
    UNKNOWN = "unknown"


class PainCharacter(StrEnum):
    SHARP = "sharp"
    DULL = "dull"
    THROBBING = "throbbing"
    BURNING = "burning"
    ACHING = "aching"
    COLICKY = "colicky"
    OTHER = "other"


class SiteAssessment(BaseModel):
    primary_location: str | None = Field(default=None, max_length=200)
    radiation_targets: list[str] = Field(default_factory=list, max_length=10)


class OnsetAssessment(BaseModel):
    manner: OnsetManner | None = None
    context: str | None = Field(default=None, max_length=500)


class TimeCourse(BaseModel):
    duration: str | None = Field(default=None, max_length=120)
    frequency: str | None = Field(default=None, max_length=120)
    pattern: str | None = Field(default=None, max_length=250)
    diurnal_variation: str | None = Field(default=None, max_length=250)


class ExacerbatingRelieving(BaseModel):
    aggravating_factors: list[str] = Field(default_factory=list, max_length=15)
    relieving_factors: list[str] = Field(default_factory=list, max_length=15)


class Severity(BaseModel):
    score: int | None = Field(default=None, ge=0, le=10)
    functional_impact: str | None = Field(default=None, max_length=300)


class SocratesProfile(BaseModel):
    site: SiteAssessment = Field(default_factory=SiteAssessment)
    onset: OnsetAssessment = Field(default_factory=OnsetAssessment)
    character: list[PainCharacter] = Field(default_factory=list, max_length=5)
    radiation: list[str] = Field(default_factory=list, max_length=10)
    associations: list[str] = Field(default_factory=list, max_length=20)
    time_course: TimeCourse = Field(default_factory=TimeCourse)
    exacerbating_relieving: ExacerbatingRelieving = Field(default_factory=ExacerbatingRelieving)
    severity: Severity = Field(default_factory=Severity)

    @field_validator("associations", "radiation")
    @classmethod
    def discard_blank_values(cls, value: list[str]) -> list[str]:
        return [item.strip() for item in value if item.strip()]
