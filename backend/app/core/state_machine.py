from dataclasses import dataclass
from enum import StrEnum
from typing import Any

from app.schemas.canonical_encounter import CanonicalEncounter


class IntakeStage(StrEnum):
    DEMOGRAPHICS_COLLECTION = "DEMOGRAPHICS_COLLECTION"
    CHIEF_COMPLAINT_IDENTIFICATION = "CHIEF_COMPLAINT_IDENTIFICATION"
    SOCRATES_ELABORATION = "SOCRATES_ELABORATION"
    AYURVEDIC_PARIKSHA_EXPLORATION = "AYURVEDIC_PARIKSHA_EXPLORATION"
    ENCOUNTER_SYNTHESIS = "ENCOUNTER_SYNTHESIS"
    FHIR_SERIALIZATION_AND_DISPATCH = "FHIR_SERIALIZATION_AND_DISPATCH"


@dataclass(frozen=True, slots=True)
class Slot:
    path: str
    stage: IntakeStage
    grammar: str
    prompt: str
    required: bool = True


SLOTS: tuple[Slot, ...] = (
    Slot("patient.given_name", IntakeStage.DEMOGRAPHICS_COLLECTION, "body_location", "What is your first name?"),
    Slot("patient.birth_date", IntakeStage.DEMOGRAPHICS_COLLECTION, "body_location", "What is your date of birth?"),
    Slot("patient.gender", IntakeStage.DEMOGRAPHICS_COLLECTION, "body_location", "What is your gender?"),
    Slot("chief_complaint.text", IntakeStage.CHIEF_COMPLAINT_IDENTIFICATION, "socrates", "What brings you in today?"),
    Slot("socrates.site.primary_location", IntakeStage.SOCRATES_ELABORATION, "body_location", "Where exactly is the symptom located?"),
    Slot("socrates.onset.context", IntakeStage.SOCRATES_ELABORATION, "duration", "When did it start, and what were you doing then?"),
    Slot("socrates.character", IntakeStage.SOCRATES_ELABORATION, "character", "How would you describe it: sharp, dull, throbbing, burning, aching, or colicky?"),
    Slot("socrates.time_course.duration", IntakeStage.SOCRATES_ELABORATION, "duration", "How long does it last or how long has it been present?"),
    Slot("socrates.exacerbating_relieving.aggravating_factors", IntakeStage.SOCRATES_ELABORATION, "exacerbating_relieving", "What makes it worse or better?"),
    Slot("socrates.severity.score", IntakeStage.SOCRATES_ELABORATION, "severity", "On a scale of zero to ten, how severe is it now?"),
    Slot("ayurveda.agni", IntakeStage.AYURVEDIC_PARIKSHA_EXPLORATION, "agni", "How is your digestion: Manda, Tikshna, Vishama, or Sama?"),
    Slot("ayurveda.koshtha", IntakeStage.AYURVEDIC_PARIKSHA_EXPLORATION, "koshtha", "Which bowel tendency fits best: Krura, Madhyama, or Mridu?"),
    Slot("ayurveda.prakriti", IntakeStage.AYURVEDIC_PARIKSHA_EXPLORATION, "prakriti", "Which constitution has a clinician identified: Vata, Pitta, Kapha, or a combination?"),
    Slot("ayurveda.vikriti", IntakeStage.AYURVEDIC_PARIKSHA_EXPLORATION, "vikriti", "Which current dosha imbalance best describes you, if known?"),
    Slot("ayurveda.ahara_vihara.dietary_patterns", IntakeStage.AYURVEDIC_PARIKSHA_EXPLORATION, "ahara_vihara", "Please describe your diet, meal regularity, sleep, and activity."),
    Slot("ayurveda.nidana", IntakeStage.AYURVEDIC_PARIKSHA_EXPLORATION, "nidana", "What lifestyle or dietary triggers seem related to this concern?"),
)


class IntakeStateMachine:
    def missing_slots(self, encounter: CanonicalEncounter) -> list[Slot]:
        return [slot for slot in SLOTS if not self._present(encounter, slot.path)]

    def current_slot(self, encounter: CanonicalEncounter) -> Slot | None:
        missing = self.missing_slots(encounter)
        return missing[0] if missing else None

    def stage(self, encounter: CanonicalEncounter) -> IntakeStage:
        slot = self.current_slot(encounter)
        return slot.stage if slot else IntakeStage.FHIR_SERIALIZATION_AND_DISPATCH

    def completion_percent(self, encounter: CanonicalEncounter) -> float:
        complete = len(SLOTS) - len(self.missing_slots(encounter))
        return round(complete / len(SLOTS) * 100, 1)

    def next_prompt(self, encounter: CanonicalEncounter) -> str:
        slot = self.current_slot(encounter)
        if slot:
            return slot.prompt
        return "Intake is complete. Your clinician will review the structured encounter."

    @staticmethod
    def _present(encounter: CanonicalEncounter, path: str) -> bool:
        value: Any = encounter
        for part in path.split("."):
            value = getattr(value, part)
        return value is not None and value != [] and value != ""
