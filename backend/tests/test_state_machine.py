from app.core.state_machine import IntakeStage, IntakeStateMachine
from app.schemas.canonical_encounter import CanonicalEncounter


def test_state_machine_starts_with_demographics_and_tracks_progress():
    encounter = CanonicalEncounter()
    machine = IntakeStateMachine()
    assert machine.stage(encounter) == IntakeStage.DEMOGRAPHICS_COLLECTION
    assert machine.current_slot(encounter).path == "patient.given_name"
    assert machine.completion_percent(encounter) == 0
