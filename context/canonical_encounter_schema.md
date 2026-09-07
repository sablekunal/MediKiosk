# Canonical Encounter Schema — v1

This is the single source of truth for the shape of an OPD encounter. The Python backend's `encounter.py` Pydantic model, `fhir_mapper.py`, the kiosk app's `encounter_provider.dart`, and the doctor app's `review_provider.dart` all read/write this shape. Changing a field here means updating all four.

**Design rules:**
- Every value captured from ASR/OCR/LLM slot-filling carries its own `source` and `confidence` — never just a bare value. The doctor needs to know what's machine-inferred vs. what they've confirmed.
- Nothing in this schema ever contains decrypted ABDM external-record content on the backend/NUC. That content only exists in-memory on the doctor tablet after local decryption (see `consent` block).
- `schema_version` is mandatory on every document from day one, even for the hackathon build — cheap now, painful to retrofit.

---

## Full example instance

```json
{
  "schema_version": "1.0",
  "encounter_id": "enc_8f3a1c2e",
  "created_at": "2026-09-07T09:12:00+05:30",
  "updated_at": "2026-09-07T09:41:00+05:30",
  "language": "hi",
  "device": {
    "kiosk_id": "kiosk-01",
    "created_by": "kiosk"
  },

  "patient": {
    "abha_id": "12-3456-7890-1234",
    "abha_status": "verified",
    "name": "Rina Devi",
    "age": 34,
    "age_unit": "years",
    "sex": "female",
    "phone": "98xxxxxxxx",
    "village": "Example village, Block X",
    "guardian_name": null
  },

  "chief_complaint": {
    "text_raw": "pet me dard ho raha hai teen din se",
    "text_normalized": "abdominal pain, 3 days",
    "source": "asr",
    "confidence": 0.88
  },

  "history": [
    {
      "complaint_id": "c1",
      "framework": "socrates",
      "linked_to": "chief_complaint",
      "slots": {
        "site": { "value": "abdomen_lower_right", "source": "asr", "confidence": 0.81 },
        "onset": { "value": "3_days_gradual", "source": "asr", "confidence": 0.9 },
        "character": { "value": "cramping", "source": "asr", "confidence": 0.75 },
        "radiation": { "value": "none", "source": "asr", "confidence": 0.7 },
        "associations": { "value": ["nausea"], "source": "asr", "confidence": 0.66 },
        "time_course": { "value": "constant", "source": "asr", "confidence": 0.7 },
        "exacerbating_relieving": { "value": "worse_on_movement", "source": "asr", "confidence": 0.6 },
        "severity": { "value": 6, "source": "asr", "confidence": 0.85 }
      }
    }
  ],

  "vitals": {
    "height_cm": null,
    "weight_kg": 58,
    "bp_systolic": 118,
    "bp_diastolic": 76,
    "pulse_bpm": 88,
    "temp_c": 37.6,
    "spo2": 98,
    "rbs_mgdl": null,
    "recorded_by": "kiosk_manual_entry",
    "recorded_at": "2026-09-07T09:18:00+05:30"
  },

  "prior_records": [
    {
      "record_id": "pr1",
      "source_type": "prescription",
      "capture_method": "ocr",
      "raw_text": "Tab. Pantoprazole 40mg OD ...",
      "structured": {
        "medications": [
          { "name": "Pantoprazole", "dose": "40mg", "frequency": "OD" }
        ]
      },
      "ocr_confidence": 0.72,
      "image_ref": "img_prescr_001.jpg",
      "reviewed": false
    }
  ],

  "red_flags": [
    {
      "flag": "possible_appendicitis_pattern",
      "triggered_by_rule": "site_rlq_plus_severity",
      "severity_level": "priority",
      "triggered_at": "2026-09-07T09:20:00+05:30"
    }
  ],

  "triage": {
    "level": "priority",
    "suggested_department": "general_medicine",
    "computed_by": "rule_engine",
    "computed_at": "2026-09-07T09:20:05+05:30",
    "rationale": "RLQ abdominal pain + fever + 3-day gradual onset",
    "doctor_override": null
  },

  "consent": {
    "abha_consent_status": "not_requested",
    "consent_request_id": null,
    "hip_ids": [],
    "key_material_sent_at": null,
    "fetched_encrypted_at": null,
    "decrypted_at": null,
    "encrypted_bundle_ref": null
  },

  "fhir": {
    "mapping_status": "not_mapped",
    "mapped_at": null,
    "resource_ids": {}
  },

  "review": {
    "status": "pending_doctor_review",
    "reviewed_by": null,
    "reviewed_at": null,
    "edits": []
  },

  "sync": {
    "status": "local_only",
    "last_sync_attempt": null,
    "retry_count": 0
  }
}
```

---

## Field reference by section

### `patient`
| Field | Type | Notes |
|---|---|---|
| `abha_id` | string, nullable | 14-digit ABHA number if provided |
| `abha_status` | enum | `not_provided` \| `provided_unverified` \| `verified` |
| `age_unit` | enum | `years` \| `months` — needed for infants |
| `sex` | enum | `male` \| `female` \| `other` |
| `guardian_name` | string, nullable | required for minors or when patient can't self-report |

### `history[].slots`
Every slot value is wrapped as `{ value, source, confidence }`.
- `source` enum: `asr` \| `manual_entry` \| `ocr` \| `doctor_edit`
- `confidence`: float 0–1. ASR/OCR always populate this; `manual_entry`/`doctor_edit` set it to `1.0`.
- Slot keys for the `socrates` framework match the node `slot` names in `socrates.yaml` exactly (see the tree doc) — this is what lets the tree engine write directly into this structure.

### `red_flags[]`
Populated only by deterministic rule nodes in the tree (see `red_flag_check` node type in the SOCRATES tree), never by free-form LLM judgment. Each rule has a stable `rule_id` so triage logic and audit trails stay traceable.

### `triage.level`
Enum: `routine` \| `priority` \| `emergency`. `computed_by` is always `rule_engine` initially; a doctor can set `doctor_override` to a different level with a required one-line `reason` (add that field if/when you build the override UI — omitted here as not yet in scope).

### `consent.abha_consent_status`
Enum: `not_requested` → `pending` → `approved` → `key_material_sent` → `fetched_encrypted` → `decrypted`. Matches the flow in `architecture.md` §4. `encrypted_bundle_ref` is a pointer to the opaque encrypted blob stored on the backend (a BLOB column or file ref) — the backend never has a field for decrypted external-record content. Decrypted content lives only transiently in the doctor app's memory/local state, not in this canonical document as persisted on the NUC.

### `review.edits[]`
Each edit: `{ field_path, old_value, new_value, edited_by, edited_at }`. This is what gives you an audit trail when a doctor corrects an ASR mis-transcription or overrides a slot value — useful both for trust/safety and for a nice hackathon demo moment ("doctor caught what the AI got wrong").

### `sync.status`
Enum: `local_only` \| `queued` \| `synced`. Relevant once you have >1 compute box or a district-level aggregation point; for a single-box hackathon demo this can stay `local_only` throughout, but the field should exist now so nothing upstream has to change shape later.

---

## What's intentionally deferred (not missing — just out of hackathon scope)
- Multi-complaint encounters beyond one `history[]` entry per chief complaint (schema already supports a list, just may only be exercised once in the demo).
- `dashavidha` framework slots — same `history[]` array, different `framework` value and slot key set; add a `dashavidha.yaml` tree analogous to the SOCRATES one when you get to it.
- Explicit `doctor_override.reason` field on triage — add when you build that UI.
