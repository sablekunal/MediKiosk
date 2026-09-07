from datetime import datetime, timezone
from uuid import uuid4

from app.schemas.canonical_encounter import CanonicalEncounter
from app.schemas.fhir import FhirBundle

LOINC_PAIN_SEVERITY = "72514-3"
LOINC_BODY_SITE = "39111-0"
AYUSH_SYSTEM = "https://medikiosk.local/fhir/CodeSystem/ayush-assessment"


class FhirMapper:
    """Pure canonical-encounter to FHIR R4 JSON transformation with boundary validation."""

    def to_bundle(self, encounter: CanonicalEncounter) -> FhirBundle:
        patient_id = f"patient-{encounter.id}"
        encounter_id = f"encounter-{encounter.id}"
        entries: list[dict] = [
            {"fullUrl": f"urn:uuid:{patient_id}", "resource": self._patient(encounter, patient_id)},
            {"fullUrl": f"urn:uuid:{encounter_id}", "resource": self._encounter(encounter, encounter_id, patient_id)},
        ]
        if encounter.chief_complaint.text:
            entries.append({"resource": self._condition(encounter, patient_id, encounter_id)})
        entries.extend({"resource": resource} for resource in self._western_observations(encounter, patient_id, encounter_id))
        entries.extend({"resource": resource} for resource in self._ayush_observations(encounter, patient_id, encounter_id))
        return FhirBundle(type="collection", entry=entries)

    def validate(self, bundle: FhirBundle) -> list[str]:
        diagnostics: list[str] = []
        ids: set[str] = set()
        for index, entry in enumerate(bundle.entry):
            resource = entry["resource"]
            resource_type = resource["resourceType"]
            if resource_type not in {"Patient", "Encounter", "Condition", "Observation"}:
                diagnostics.append(f"entry {index}: unsupported resource type {resource_type}")
            if resource.get("id") in ids:
                diagnostics.append(f"entry {index}: duplicate resource id")
            ids.add(resource.get("id"))
        # fhir.resources supplies the full Pydantic R4/R4B validation when available.
        # The local structural checks above still yield useful diagnostics if a deployment
        # intentionally omits that optional validation package during an outage.
        try:
            from fhir.resources.bundle import Bundle

            payload = bundle.model_dump(mode="json")
            if hasattr(Bundle, "model_validate"):
                Bundle.model_validate(payload)
            else:  # fhir.resources versions backed by Pydantic v1
                Bundle.parse_obj(payload)
        except ImportError:
            diagnostics.append("fhir.resources is not installed; full FHIR schema validation was skipped")
        except Exception as error:
            diagnostics.append(f"FHIR R4 schema validation failed: {error}")
        return diagnostics

    @staticmethod
    def _patient(data: CanonicalEncounter, resource_id: str) -> dict:
        patient: dict = {"resourceType": "Patient", "id": resource_id}
        if data.patient.identifier:
            patient["identifier"] = [{"system": "https://medikiosk.local/patient-id", "value": data.patient.identifier}]
        names = [item for item in [data.patient.given_name, data.patient.family_name] if item]
        if names:
            patient["name"] = [{"text": " ".join(names), "given": [data.patient.given_name] if data.patient.given_name else []}]
        if data.patient.birth_date: patient["birthDate"] = data.patient.birth_date
        if data.patient.gender: patient["gender"] = data.patient.gender.value
        patient["communication"] = [{"language": {"text": data.patient.language}}]
        return patient

    @staticmethod
    def _encounter(data: CanonicalEncounter, resource_id: str, patient_id: str) -> dict:
        result = {
            "resourceType": "Encounter", "id": resource_id, "status": data.status.value,
            "class": {"system": "http://terminology.hl7.org/CodeSystem/v3-ActCode", "code": "AMB", "display": "ambulatory"},
            "subject": {"reference": f"urn:uuid:{patient_id}"},
            "period": {"start": data.started_at.isoformat()},
            "serviceType": {"text": "MediKiosk clinical intake"},
        }
        if data.chief_complaint.text:
            result["reasonCode"] = [{"text": data.chief_complaint.text}]
        return result

    @staticmethod
    def _condition(data: CanonicalEncounter, patient_id: str, encounter_id: str) -> dict:
        coding = []
        if data.chief_complaint.snomed_code:
            coding.append({"system": "http://snomed.info/sct", "code": data.chief_complaint.snomed_code})
        if data.chief_complaint.icd10_code:
            coding.append({"system": "http://hl7.org/fhir/sid/icd-10", "code": data.chief_complaint.icd10_code})
        code = {"text": data.chief_complaint.text}
        if coding: code["coding"] = coding
        return {"resourceType": "Condition", "id": str(uuid4()), "subject": {"reference": f"urn:uuid:{patient_id}"}, "encounter": {"reference": f"urn:uuid:{encounter_id}"}, "code": code, "clinicalStatus": {"coding": [{"system": "http://terminology.hl7.org/CodeSystem/condition-clinical", "code": "active"}]}}

    def _western_observations(self, data: CanonicalEncounter, patient_id: str, encounter_id: str) -> list[dict]:
        observations: list[dict] = []
        if data.socrates.severity.score is not None:
            observations.append(self._observation(patient_id, encounter_id, LOINC_PAIN_SEVERITY, "Pain severity", {"valueInteger": data.socrates.severity.score}))
        if data.socrates.site.primary_location:
            observations.append(self._observation(patient_id, encounter_id, LOINC_BODY_SITE, "Anatomical site", {"valueString": data.socrates.site.primary_location}))
        if data.socrates.character:
            observations.append(self._observation(patient_id, encounter_id, "95379-2", "Pain character", {"valueString": ", ".join(item.value for item in data.socrates.character)}))
        return observations

    def _ayush_observations(self, data: CanonicalEncounter, patient_id: str, encounter_id: str) -> list[dict]:
        values = [("agni", data.ayurveda.agni), ("koshtha", data.ayurveda.koshtha), ("prakriti", data.ayurveda.prakriti), ("vikriti", data.ayurveda.vikriti)]
        return [self._observation(patient_id, encounter_id, key, key.title(), {"valueCodeableConcept": {"coding": [{"system": AYUSH_SYSTEM, "code": value.value, "display": value.value}]}}) for key, value in values if value]

    @staticmethod
    def _observation(patient_id: str, encounter_id: str, code: str, display: str, value: dict) -> dict:
        return {"resourceType": "Observation", "id": str(uuid4()), "status": "final", "code": {"coding": [{"system": "http://loinc.org" if code.startswith("7") or code.startswith("9") or code.startswith("3") else AYUSH_SYSTEM, "code": code, "display": display}]}, "subject": {"reference": f"urn:uuid:{patient_id}"}, "encounter": {"reference": f"urn:uuid:{encounter_id}"}, "effectiveDateTime": datetime.now(timezone.utc).isoformat(), **value}
