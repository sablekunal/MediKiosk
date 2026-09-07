from typing import Any

from pydantic import BaseModel, Field, field_validator


class FhirBundle(BaseModel):
    resourceType: str = "Bundle"
    type: str = "collection"
    entry: list[dict[str, Any]] = Field(default_factory=list)

    @field_validator("resourceType")
    @classmethod
    def must_be_bundle(cls, value: str) -> str:
        if value != "Bundle":
            raise ValueError("FHIR export must have resourceType Bundle")
        return value

    @field_validator("entry")
    @classmethod
    def entries_need_resources(cls, entries: list[dict[str, Any]]) -> list[dict[str, Any]]:
        for entry in entries:
            resource = entry.get("resource")
            if not isinstance(resource, dict) or not resource.get("resourceType"):
                raise ValueError("Every Bundle.entry requires a FHIR resource")
        return entries
