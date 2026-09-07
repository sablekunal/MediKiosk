from app.schemas.canonical_encounter import CanonicalEncounter
from app.services.fhir_mapper import FhirMapper


def test_fhir_export_contains_patient_encounter_and_observation():
    encounter = CanonicalEncounter.model_validate({"patient": {"given_name": "Asha"}, "chief_complaint": {"text": "Chest pain"}, "socrates": {"severity": {"score": 7}}})
    mapper = FhirMapper()
    bundle = mapper.to_bundle(encounter)
    assert bundle.resourceType == "Bundle"
    assert {entry["resource"]["resourceType"] for entry in bundle.entry} >= {"Patient", "Encounter", "Condition", "Observation"}
    assert mapper.validate(bundle) == []
