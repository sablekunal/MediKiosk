# Canonical Encounter → FHIR R4 Mapping — v1

This is the source spec for `intake-backend/app/models/fhir_mapper.py`. It maps
every section of `canonical_encounter_schema.md` to a FHIR R4 resource, using
`fhir.resources` (Pydantic-based) as noted in `architecture.md` §5.

**Scope for hackathon build:** cover the resources needed to make the demo's
happy path (chief complaint → SOCRATES history → vitals → triage → summary)
representable as a valid FHIR bundle. `prior_records` (OCR'd documents) and
the AYUSH/Dashavidha slots map too, but are lower priority if time is short —
they degrade gracefully to `DocumentReference`/`Observation` resources with
sparser `code` bindings rather than blocking the rest of the bundle.

**General rule:** every canonical field with a `{ value, source, confidence }`
wrapper maps its `source`/`confidence` into the FHIR resource's
`extension[]` array (a locally-defined extension, not a standard ABDM/HL7
one) rather than dropping that provenance — it's exactly the kind of
machine-vs-doctor-confirmed distinction an auditor or a skeptical judge will
ask about.

---

## 1. Bundle shape

One `Bundle` (type: `collection`) per encounter, `Bundle.identifier` =
`encounter_id`. Resources below are entries in that bundle, cross-referenced
by `fullUrl` (`urn:uuid:<resource-local-id>`).

```
Bundle
├── Patient                (from `patient`)
├── Encounter               (from top-level + `device`, `triage`)
├── Condition                (from `chief_complaint`)
├── Observation[]           (from `history[].slots`, one per SOCRATES/
│                            Dashavidha slot — see §3)
├── Observation             (from `vitals`, one Observation per vital sign,
│                            or a single panel Observation with components —
│                            see §4)
├── DocumentReference[]      (from `prior_records[]`)
├── Flag[]                   (from `red_flags[]`)
├── ServiceRequest           (from `triage`, department routing)
└── Provenance                (bundle-level — records model/prompt versions
                                pulled from `ai_artifacts` rows, not stored
                                inline in the canonical doc)
```

`fhir.mapping_status` / `fhir.mapped_at` / `fhir.resource_ids` on the
canonical doc are populated by `fhir_mapper.py` after a successful mapping
run — `resource_ids` is a dict of `{resource_type: [fullUrl, ...]}` so the
mapping is traceable and idempotent (re-running doesn't duplicate resources;
it updates by fullUrl).

---

## 2. `patient` → `Patient`

| Canonical field | FHIR path | Notes |
|---|---|---|
| `patient.abha_id` | `Patient.identifier[0]` | `system`: ABDM's ABHA identifier system URI (confirm exact URI against ABDM sandbox docs at implementation time — placeholder `https://healthid.ndhm.gov.in` pending confirmation); `value`: the 14-digit ABHA number |
| `patient.abha_status` | `Patient.identifier[0].extension` | local extension `abha-verification-status`, value from `not_provided \| provided_unverified \| verified` |
| `patient.name` | `Patient.name[0].text` | single text field is sufficient for hackathon scope; don't bother splitting given/family for Indian naming conventions unless time allows |
| `patient.age` + `age_unit` | `Patient.birthDate` (approximate) or `Patient.extension` | prefer computing an approximate `birthDate` from `created_at` - age when unit is `years`; for `age_unit: months` (infants), use a local `reported-age-months` extension instead since FHIR `birthDate` granularity assumptions get awkward for infants |
| `patient.sex` | `Patient.gender` | direct enum map: `male\|female\|other` → FHIR's `male\|female\|other` (FHIR's `unknown` unused — canonical schema doesn't have that state) |
| `patient.phone` | `Patient.telecom[0]` | `system: phone`, `use: mobile` |
| `patient.village` | `Patient.address[0].text` | free text; don't attempt structured `line`/`district`/`state` decomposition for hackathon scope |
| `patient.guardian_name` | `Patient.contact[0].name.text` | only emitted when non-null; `Patient.contact[0].relationship` set to a generic "guardian" coding |

## 3. `chief_complaint` + `history[]` → `Condition` + `Observation[]`

- `chief_complaint` → one `Condition` resource. `Condition.code.text` =
  `text_normalized`; the raw ASR transcript (`text_raw`) goes into
  `Condition.note[0].text` rather than `code.text`, so the coded field stays
  clean while the verbatim capture is preserved for audit.
- `Condition.extension` carries `source` / `confidence` (same pattern as
  `Patient.identifier` above).
- Each `history[].slots.<slot_name>` → one `Observation`:
  - `Observation.code.text` = the slot name (`site`, `onset`, `character`,
    etc. for SOCRATES; `prakriti`, `agni`, etc. for Dashavidha)
  - `Observation.valueString` (or `valueInteger` for `severity`,
    `valueCodeableConcept` where an option-list slot has an obvious FHIR
    coding) = `slots.<slot>.value`
  - `Observation.extension` carries `source` + `confidence`
  - `Observation.subject` → the `Patient` resource
  - `Observation.focus` → the `Condition` resource for this `complaint_id`
    (links every slot-fill Observation back to the complaint it's about —
    important once multi-complaint encounters are exercised, per canonical
    schema's "intentionally deferred" note)
  - `Observation.category` = `"survey"` for SOCRATES slots (patient-elicited
    history) vs. a locally-defined `"ayush-assessment"` category for
    Dashavidha slots, so downstream consumers can filter by framework
    without parsing `code.text`

No slot is ever synthesized into a `Condition.code` coded diagnosis — the
system does not diagnose; `Condition` here only represents the patient-
reported chief complaint, and diagnosis stays the physician's responsibility
per the non-negotiable "AI is not a replacement for the physician" framing
in `problem_statement.md` §3.3 Module C.

## 4. `vitals` → `Observation`

One `Observation` per vital sign (not a single panel resource) — simpler to
implement correctly for a hackathon timeline, and each vital gets its own
standard LOINC code rather than inventing a bundled panel code:

| Canonical field | LOINC code (indicative — confirm before final submission) | Unit |
|---|---|---|
| `height_cm` | 8302-2 | cm |
| `weight_kg` | 29463-7 | kg |
| `bp_systolic` | 8480-6 | mmHg |
| `bp_diastolic` | 8462-4 | mmHg |
| `pulse_bpm` | 8867-4 | /min |
| `temp_c` | 8310-5 | Cel |
| `spo2` | 59408-5 | % |
| `rbs_mgdl` | 2339-0 | mg/dL |

Null fields are simply omitted (no `Observation` emitted), not emitted with
a null value — keeps the bundle free of empty resources. `recorded_by` /
`recorded_at` map to `Observation.performer` / `Observation.effectiveDateTime`.

## 5. `prior_records[]` → `DocumentReference`

- `capture_method: ocr` → `DocumentReference.content[0].attachment` holds a
  reference to the stored image (`image_ref`), not the raw bytes inline.
- `raw_text` → `DocumentReference.content[0].extension` (local extension,
  since raw OCR text isn't a standard `DocumentReference` field) — kept
  separate from the structured extraction so a doctor can always see what
  OCR actually read, independent of how well the structuring worked.
- `structured.medications[]` → a separate `MedicationStatement` resource per
  medication (not embedded in `DocumentReference`), cross-referenced via
  `MedicationStatement.derivedFrom` pointing back at the `DocumentReference`.
  This is the one place in the mapping where a single canonical array
  fans out into N resources of a different type — worth flagging in code
  comments since it's the least obvious mapping in this table.
- `reviewed` (boolean) → `DocumentReference.extension` local flag; not a
  standard field, but needed for the same audit-trail reasons as everywhere
  else in this schema.

## 6. `red_flags[]` → `Flag`

- One `Flag` resource per entry. `Flag.code.text` = `flag` name (e.g.
  `possible_appendicitis_pattern`). `Flag.extension` carries
  `triggered_by_rule` and `severity_level` (both local extensions — FHIR's
  own `Flag.priority` doesn't map cleanly onto the three-level
  `routine|priority|emergency` scale used here, so priority is *also*
  duplicated as a standard `Flag.priority` coding pointing at the closest
  built-in code, for anything downstream that only understands standard
  fields and ignores extensions).

## 7. `triage` → `ServiceRequest`

- `triage.level` → `ServiceRequest.priority` (map `routine→routine`,
  `priority→urgent`, `emergency→stat` — FHIR's `priority` enum doesn't have
  a perfect three-way match, `urgent` is the closest available value for
  the middle tier)
- `triage.suggested_department` → `ServiceRequest.category`
- `triage.rationale` → `ServiceRequest.reasonCode.text` (free text; not
  coded, since the rationale is a rule-engine explanation string, not a
  clinical code)
- `triage.doctor_override` → `ServiceRequest.extension` local field, only
  emitted once the override UI exists (canonical schema itself notes this
  field's `reason` sub-field is deferred — mapping follows the same
  deferral, add together)

## 8. `consent` → NOT mapped to a FHIR resource

Deliberately excluded from the bundle. `consent.*` fields describe the
system's *own* ABDM consent-and-fetch pipeline state (an implementation
detail — see `architecture.md` §4 and `canonical_encounter_schema.md`'s
notes on this block), not clinical content about the patient. Mapping it
to a FHIR `Consent` resource would conflate "our system's ABDM handshake
status" with "the patient's actual consent directives," which is exactly
the kind of category error a careful reviewer would flag. If ABDM consent
ever needs to be represented in a FHIR resource for HIS interoperability,
that's a separate, deliberate design decision — not a byproduct of this
mapping pass.

## 9. `review` → `Provenance`

- `review.status`, `reviewed_by`, `reviewed_at` → bundle-level
  `Provenance.agent` (the doctor) and `Provenance.recorded`.
- `review.edits[]` → NOT individually mapped into FHIR (FHIR has no clean
  per-field diff resource); instead each edit stays queryable from
  `doctor_reviews` (the SQLite table per `variant-c-architecture.md` §6)
  and is referenced from `Provenance.entity` only as a pointer
  (`doctor_reviews.review_id`), not inlined. The audit trail lives
  authoritatively in SQLite, not duplicated into the FHIR bundle.

## 10. `sync` / `schema_version` / `device` → not independently mapped

These are transport/lifecycle metadata about the canonical document itself,
not clinical content. `schema_version` goes into `Bundle.meta.tag` (so any
consumer of the bundle can tell which schema version produced it);
`sync.*` and `device.*` stay backend-internal and are never emitted into
the FHIR bundle at all.

---

## Implementation notes for `fhir_mapper.py`

- One pure function per resource type (`map_patient()`, `map_condition()`,
  `map_observations_from_history()`, `map_vitals()`, etc.), composed by a
  single `map_encounter_to_bundle(encounter: Encounter) -> Bundle` entry
  point — keeps each mapping testable in isolation, which matters given how
  many of these mappings involve a judgment call (see the `priority`
  three-to-four-value mismatch in §7, or the fan-out in §5) that's worth
  unit-testing explicitly rather than discovering wrong at demo time.
- Confirm the placeholder LOINC codes in §4 and the ABHA identifier system
  URI in §2 against current ABDM/NRCeS documentation before the final
  submission — both are marked indicative above specifically so they don't
  get treated as verified.
- `resource_ids` written back onto the canonical `fhir` block (see §1)
  should use the `fullUrl` values, not FHIR server-assigned IDs, since this
  mapping runs before (or independent of) any actual FHIR server
  submission — that's a separate, later integration step against the
  hospital's HIS/EMR, not part of this mapping pass.
