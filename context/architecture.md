# AI-Assisted OPD Intake & Triage System — Architecture

**Target:** Rural Indian OPD settings, tier-3 villages, sub-center / PHC / district hospital deployment tiers, ABDM/ABHA integrated, offline-first.

> **Scope note:** this document is a **code-implementation overview** — repo layout, module boundaries, and language/tech choices for the backend and the two Flutter apps. It is not the full system/deployment diagram. For physical layout, network segmentation, hardware enclosure, security hardening, and the hackathon-vs-production demo configuration, see `variant-c-architecture.md`, which is the canonical deployment-tier reference.

---

## 1. Deployment tiers (design context)

Three architectural variants exist as deployment tiers of one product, sharing a canonical encounter JSON → FHIR mapping layer.

| Variant | Description | Target |
|---|---|---|
| A — Fully On-Device (MediKiosk-Lite) | All inference on patient-facing tablet | Minimal-budget single sub-centers |
| B — On-Device + doctor tablet | Same as A, plus dedicated doctor-side thin tablet for review/consent | Slightly larger sub-centers |
| C — Shared Compute Box | Waiting-room mini-PC/NUC runs all inference; both tablets are thin clients | PHC / district hospital, busy OPD |

This document details **Variant C**, the current build target.

**Non-negotiable principle:** all ABDM key material and decryption capability live only on the doctor's device, never on patient-facing or shared inference hardware — regardless of variant.

**Correction (supersedes earlier "HIU private keypair" phrasing):** ABDM does not use a single persistent HIU keypair that gets generated once and reused. Its encryption protocol (**Fidelius**) generates a **fresh ephemeral ECDH keypair for every individual data-flow transaction** — each consent-fulfillment request carries its own short-lived public key + nonce, and the shared secret is derived per-transaction via ECDH → HKDF-SHA256 → AES-256-GCM. The curve ABDM uses is a Weierstrass-form representation of Curve25519, which is not byte-compatible with the standard X25519 support Android Keystore added in API 31+ — so this should be implemented as a software crypto operation (e.g. the `abdm_fidelius` Dart package, which is interoperable with ABDM's reference `fidelius-cli`), not as a raw Keystore-generated EC key. Keystore's role is narrower: protecting whatever device-level secret guards the doctor app's local storage/session, not holding "the" ABDM key directly. No ephemeral key material or derived secret is ever transmitted to or generated on the kiosk or the compute box.

---

## 2. Hardware (Variant C reference — see `variant-c-architecture.md` for full physical/network layout)

- **Compute box:** Intel NUC 13 Pro class, i5/i7, 16–32GB RAM, CPU-only inference viable; optional entry GPU (RTX 3050/4060) for lower latency
- **Storage:** NVMe SSD 256GB+ (models ~8–12GB)
- **Networking:** NUC hosts its own local Wi-Fi AP (hostapd + dnsmasq) — tablets connect directly, no dependency on external router/internet for the on-prem loop
- **Patient kiosk tablet:** Android, mic-equipped, thin client (no inference)
- **Doctor tablet:** Android, thin client; generates/holds per-transaction ABDM (Fidelius) key material and performs local decryption

---

## 3. Three codebases

```
┌─────────────────┐        ┌──────────────────┐
│  Patient kiosk   │        │   ABDM / ABHA     │
│  Flutter, ABHA + │        │   Gateway         │
│  consent input   │        └────────▲──────────┘
└────────┬─────────┘                 │ encrypted bundle
         │                           │
         ▼                           │
┌────────────────────────────────────┴─────┐
│         Python backend (NUC)              │
│  FastAPI gateway + inference services     │
│  Relays consent, stores encrypted bundle  │
└────────────────────┬──────────────────────┘
                      ▼
         ┌────────────────────────────┐
         │        Doctor app          │
         │  Fetches + decrypts locally│
         │  with per-transaction      │
         │  Fidelius key material     │
         └─────────────────────────────┘
```

### 3.1 Python backend — `intake-backend/`

Runs on the NUC. Owns all AI inference, the question-tree engine, canonical/FHIR data, and ABDM API relay (auth only, no decryption).

```
intake-backend/
├── app/
│   ├── main.py                  # FastAPI entrypoint
│   ├── config.py                # env vars, model paths, ports
│   ├── api/
│   │   ├── encounters.py        # /encounters/* — create, get, update session
│   │   ├── asr.py               # /transcribe
│   │   ├── tts.py               # /synthesize
│   │   ├── ocr.py               # /ocr
│   │   ├── consent.py           # /consent/request, /consent/status, /consent/bundle
│   │   └── sync.py              # /sync/* — outbox status, force-sync
│   ├── tree_engine/
│   │   ├── engine.py             # state machine: (current_node, slot_value) → next_node
│   │   ├── trees/
│   │   │   ├── socrates.yaml
│   │   │   └── dashavidha.yaml
│   │   └── grammars/             # GBNF, one per slot-fill type
│   │       ├── yesno.gbnf
│   │       ├── duration.gbnf
│   │       └── body_location.gbnf
│   ├── llm/
│   │   ├── client.py             # wraps llama-server /v1/chat/completions
│   │   └── prompts.py            # node → phrasing templates
│   ├── abdm/
│   │   ├── gateway_client.py     # HIU API auth + ABDM Consent Manager calls
│   │   │                         # (auth/session token only — never handles
│   │   │                         #  key material or decryption)
│   │   └── models.py             # consent request/response schemas
│   ├── models/
│   │   ├── encounter.py          # canonical encounter Pydantic schema
│   │   └── fhir_mapper.py        # canonical JSON → FHIR R4 resources
│   ├── db/
│   │   ├── database.py           # SQLite engine/session
│   │   └── models.py             # encounters, outbox_queue, consent_status, encrypted_bundle (BLOB)
│   └── queue/
│       └── request_queue.py      # asyncio.Queue — LLM concurrency control
├── scripts/
│   ├── convert_quantize.sh       # llama.cpp GGUF conversion
│   └── start_all.sh              # launches llama-server + FastAPI
└── requirements.txt
```

**Inference services (same box, called by gateway):**
- LLM: `llama.cpp` server (`llama-server`) — Qwen2.5-7B-Instruct, GGUF Q4_K_M, GBNF-constrained decoding
- ASR: `sherpa-onnx` + AI4Bharat Indic Whisper (medium)
- TTS: Piper (ONNX voices, cache common phrases)
- OCR: PaddleOCR server-lite (primary) → TrOCR-base / Qwen2.5-VL-3B (fallback for handwriting)

**No Docker for the hackathon build.** Run everything as plain Python/Flutter processes on the NUC (`scripts/start_all.sh`, optionally under `supervisord`/`pm2`). This is purely a presentation-scope decision — Docker Compose is a fine later step for field packaging (golden-image builds, easier model/version pinning across boxes), but it adds setup and debugging overhead the hackathon doesn't need. Revisit once the demo is solid.

### 3.2 Patient kiosk — `kiosk_app/` (Flutter)

Thin client. Owns intake dialogue UI, audio capture/playback, and now **ABHA entry + consent initiation** (moved here to minimize doctor effort).

```
kiosk_app/
├── lib/
│   ├── main.dart
│   ├── config/api_config.dart        # backend base URL (local NUC IP)
│   ├── screens/
│   │   ├── welcome_screen.dart
│   │   ├── abha_consent_screen.dart  # ABHA ID entry/QR scan + consent request trigger
│   │   ├── intake_screen.dart        # question-tree flow UI
│   │   └── completion_screen.dart
│   ├── services/
│   │   ├── api_client.dart           # /encounters, /transcribe, /synthesize
│   │   ├── consent_service.dart      # /consent/request, poll /consent/status
│   │   ├── audio_service.dart        # mic capture, playback
│   │   └── offline_cache.dart        # sqflite — queue drafts if backend unreachable
│   ├── state/encounter_provider.dart
│   ├── widgets/
│   │   ├── question_bubble.dart
│   │   ├── mic_button.dart
│   │   └── language_selector.dart
│   └── l10n/                          # Indic language ARB files
└── pubspec.yaml
```

### 3.3 Doctor app — `doctor_app/` (Flutter)

Thin client for review, editing, and signing. ABDM surface reduced to **decryption only** — no direct gateway calls, no consent initiation.

```
doctor_app/
├── lib/
│   ├── main.dart
│   ├── config/api_config.dart
│   ├── screens/
│   │   ├── encounter_review_screen.dart   # edit/approve extracted data
│   │   └── record_fetch_screen.dart       # fetch encrypted blob, tap to decrypt, view
│   ├── services/
│   │   ├── backend_client.dart            # encounter review/edit, encrypted bundle fetch
│   │   └── abdm/
│   │       └── crypto/
│   │           ├── fidelius_client.dart   # abdm_fidelius pkg — per-transaction ephemeral
│   │           │                          # ECDH keypair + HKDF-SHA256 + AES-256-GCM,
│   │           │                          # byte-compatible with ABDM's fidelius-cli
│   │           └── keystore_bridge.dart   # platform channel → Android Keystore, used only
│   │                                      # to protect local app secrets/session, not to
│   │                                      # hold ABDM key material directly
│   │       └── consent_listener.dart      # background listener — reacts to consent
│   │                                      # APPROVED events pushed from backend and
│   │                                      # auto-generates the ephemeral keypair (see §4)
│   ├── platform/android/KeystoreModule.kt # native — local secret protection, never leaves device
│   ├── state/review_provider.dart
│   └── widgets/
│       ├── slot_editor.dart
│       ├── fhir_record_card.dart
│       └── consent_status_badge.dart
└── pubspec.yaml
```

---

## 4. ABDM / ABHA flow (kiosk-initiated, fetch runs during the kiosk visit)

**Sequencing principle:** ABHA entry fires the consent request immediately, not after the intake conversation. The rest of the kiosk session (SOCRATES intake, document scan, vitals) runs in parallel with patient OTP approval and record fetch, so the encrypted bundle is often already sitting on the backend by the time the patient finishes at the kiosk — instead of that fetch only starting after the patient has left for the consultation room. Decryption still happens exclusively on the doctor tablet; nothing about *who* holds key material changes.

| Step | Where | Needs connectivity | Needs ABDM key material |
|---|---|---|---|
| 1. ABHA ID entry (scan/manual) — **fires consent request immediately**, before intake begins | Kiosk | No (if pre-cached) | No |
| 2. Consent request → ABDM gateway | Backend (relays kiosk request) | Yes | No |
| 2a. **Kiosk proceeds directly into SOCRATES intake, document scan, vitals** — while steps 3–5 happen in the background | Kiosk | — | No |
| 3. Patient approval (OTP / ABHA app) | Patient's own phone | Yes | No |
| 4. **Doctor tablet's background consent listener reacts to the APPROVED event and auto-generates a fresh ephemeral ECDH keypair for this transaction**, no doctor action required for generation itself; public key sent (via backend relay) as part of the `HI-REQUEST` `keyMaterial` | Doctor tablet | Yes | Yes — generation only, public part only |
| 5. Encrypted FHIR bundle → backend | Backend (stores as-is) | Yes | No |
| 5a. **Kiosk polls `/consent/status` in the background throughout the visit** and shows a small non-blocking "Fetching past records…" indicator; no record content is ever rendered on the kiosk | Kiosk | Yes (best-effort) | No |
| 6. Local decryption (ECDH shared-secret derivation → HKDF-SHA256 → AES-256-GCM) using this transaction's ephemeral private key — gated behind doctor PIN/biometric per the security model, distinct from the ungated auto-keypair-generation in step 4 | **Doctor tablet only** | No | **Yes — private key** |

Only steps 4 and 6 touch ABDM key material, and the private half of that key never leaves the doctor tablet and is discarded after the transaction (it's ephemeral, not a long-term identity key). Steps 1–3, 5, and 5a involve no secret material — the encrypted bundle is inert without the transaction's private key, so it's safe to store on the shared NUC, and it's safe for the kiosk to poll its status.

`consent_status` field on each encounter: `not_requested → pending → approved → key_material_sent → fetched_encrypted → decrypted`. With this sequencing, an encounter frequently reaches `fetched_encrypted` while the patient is still physically at the kiosk, rather than only after they've moved to the waiting area.

**Offline handling (unchanged in spirit, now time-sensitive):** steps 2–5 require connectivity. Doctor/kiosk can initiate step 2 offline (queued in backend outbox); a background task retries when connectivity returns. Patient can approve later via their own phone even after leaving the kiosk. Step 4 now matters on a tighter timescale — ideally minutes, while the patient is still being seen — so the doctor tablet's consent listener treats a missed APPROVED event as a queued retry rather than a lazily-checked background task, but the underlying mechanism (retry queue) is the same one already used for connectivity gaps.

---

## 5. Language/tech summary

| Layer | Language / Tech |
|---|---|
| Kiosk + doctor tablet UI | Dart (Flutter) |
| Native platform bridge (Keystore) | Kotlin |
| Backend gateway, tree engine, service wrappers | Python (FastAPI) |
| LLM / ASR inference engines | C/C++ (llama.cpp, sherpa-onnx), consumed via bindings |
| Question trees, grammars, schemas | JSON/YAML, GBNF |
| Scripts | Bash |
| FHIR mapping | `fhir.resources` (Pydantic-based FHIR R4) |

---

## 6. Open items / decisions

- **Concurrency on shared compute box:** FIFO queue, max concurrency 1–2 on LLM server assumed sufficient given sequential OPD patient flow; continuous batching is a stretch goal, not a requirement. **Resolved for hackathon scope:** cap demo concurrency at 1–2 simultaneous patients (matches `variant-c-architecture.md` §7.3); revisit batching only if time remains.
- **Docker:** deferred by design — not a hackathon requirement (see §3.1). Containerize only as a later packaging step once the demo works end-to-end.
- **ABDM gateway session token** (a bearer token for backend↔ABDM gateway authentication, distinct from the per-transaction Fidelius key material described in §4): lives on the backend for gateway calls, refreshed per the ABDM sandbox's standard session/auth token lifecycle — confirm exact expiry window against the sandbox docs during implementation, but the architectural placement (backend-only, never on kiosk or doctor tablet) is settled.
- **Demo language pair:** **Resolved — Hindi + English**, wired end-to-end (ASR, tree question phrasing, TTS, doctor-facing summary). Other Indic languages remain schema-supported (`socrates.yaml` already carries `mr` phrasing as a second example) but are described to judges as "same pipeline, additional language packs," not built out for demo day.
- **`dashavidha.yaml`:** now written (see `tree_engine/trees/dashavidha.yaml`) — AYUSH tenfold-parameter tree covering Prakriti, Vikriti, Agni, Koshtha, Ahara-Vihara, and Nidana as patient-facing slot-fills, with Samprapti left as a downstream LLM synthesis step rather than a direct question, matching the SOCRATES tree's philosophy for its own `end` node.
- **GBNF grammar files:** now written for every `slot_fill` node referenced in `socrates.yaml` and `dashavidha.yaml` (see `tree_engine/grammars/`).
- **`fhir_mapper.py` field mapping:** now specified as a field-by-field canonical→FHIR R4 resource table (see `fhir_mapping.md`) — implement `fhir_mapper.py` directly from that table.
- **Variant positioning:** package A/B/C explicitly as deployment tiers in the final submission narrative.

---

## 7. Core design principles (carry forward across all sessions)

1. **Deterministic scaffolding over free-form LLM reasoning** — small on-device/edge LLMs are constrained to slot-filling within SOCRATES/Dashavidha question trees via grammar-based decoding, not open-ended dialogue.
2. **ABDM trust boundary is non-negotiable** — all ABDM key material (generated fresh per transaction via Fidelius) and decryption logic live only on the doctor's device; no persistent "HIU keypair" exists anywhere in the system. This holds even when the fetch is triggered eagerly at the kiosk (§4) — eagerness changes timing, never custody.
3. **Connectivity-independence as a first-class constraint** — every ABDM-dependent step is explicitly flagged and queued for deferred execution, not assumed available.
4. **One product, multiple deployment tiers** — all variants share the same canonical encounter JSON → FHIR mapping layer.
