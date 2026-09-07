# MediKiosk — Variant C Detailed Architecture
### Shared Waiting-Room Compute Box + Thin Doctor Tablet

This document is the **canonical system/deployment diagram** for Variant C: physical layout, network segmentation, security hardening, and the hackathon-vs-production demo configuration. For repo layout and code-module structure (Python backend, kiosk app, doctor app), see `architecture.md` — that document is a code-implementation overview only and defers to this one for everything physical/deployment-level.

One small computer in the patient waiting area running all AI inference for that room, cheap I/O terminals for patients, and a thin doctor's tablet that holds review/sign authority and generates/holds the ABDM Fidelius key material per transaction.

---

## 1. Design principles

1. **Compute is centralized per room; trust authority is not.** The waiting-room box does all inference and never holds ABDM key material or signs anything. The doctor's tablet does no inference and holds all signing/consent authority.
2. **The clinical workflow is a deterministic state machine, not an LLM decision.** The LLM fills slots and drafts text inside a workflow the code controls — identical philosophy to the original server design, just running on smaller hardware.
3. **Every patient-facing terminal is disposable.** A terminal holds no persistent patient data — it streams to the box and clears its buffer the moment an encounter is submitted. Losing or swapping a terminal loses nothing.
4. **The compute box is a hostile-environment device.** It sits in a public waiting room. Assume it can be physically tampered with, and design so that theft or tampering exposes as little as possible.
5. **ABDM is asynchronous, best-effort enrichment — never a blocking dependency**, exactly as in the original design.
6. **Everything is recoverable from durable local state.** A reboot of the box, a terminal, or the tablet should resume, not lose, in-progress encounters.

---

## 2. Physical & network layout

```
                              WAITING ROOM (public)
        ┌──────────────────────────────────────────────────────┐
        │                                                       │
        │   Terminal 1        Terminal 2        Terminal 3      │
        │  (Android tablet,  (Android tablet,  (Android tablet, │
        │   kiosk-mode app,   kiosk-mode app,   kiosk-mode app,  │
        │   no local AI)      no local AI)      no local AI)     │
        │        │                 │                 │          │
        └────────┼─────────────────┼─────────────────┼──────────┘
                  │                │                 │
                  └──────── isolated Wi-Fi SSID ──────┘
                         (client isolation ON —
                          terminals cannot see each other)
                                    │
                                    ▼
                  ┌───────────────────────────────────┐
                  │   WAITING-ROOM COMPUTE BOX         │
                  │   (locked steel enclosure,         │
                  │    bolted down, no exposed ports)  │
                  │                                    │
                  │   Mini-PC: Intel N100/N305 or      │
                  │   Ryzen embedded, 16–32 GB RAM,     │
                  │   optional entry GPU, NVMe SSD      │
                  │   (full-disk encrypted)             │
                  └────────────────┬────────────────────┘
                                   │
                        separate LAN segment/VLAN
                        (staff-only Wi-Fi or Ethernet)
                                   │
                                   ▼
                  ┌───────────────────────────────────┐
                  │        DOCTOR'S TABLET             │
                  │   (private room, staff custody)    │
                  └────────────────┬────────────────────┘
                                   │
                        whenever connectivity exists
                                   ▼
                  ┌───────────────────────────────────┐
                  │      ABDM / Hospital HIS           │
                  └───────────────────────────────────┘
```

**Two logical networks, minimum:** a patient-facing Wi-Fi SSID with client isolation enabled (terminals can reach the compute box but not each other), and a staff-only segment carrying compute-box ↔ doctor-tablet traffic. On a single router this is achievable with guest-network/VLAN features present on most consumer routers — you don't need enterprise switches for a hackathon build, but it's worth doing even at that scale because it's free and closes an easy attack path.

---

## 3. Component architecture

### 3.1 Patient Terminal (I/O only)

```
┌─────────────────────────────────────┐
│         TERMINAL APP (kiosk mode)    │
│                                       │
│  UI: language select → intake flow   │
│      → document scan → vitals        │
│                                       │
│  Captures: mic audio (streamed),     │
│  camera frames (documents), touch    │
│  events, ABHA ID/QR                  │
│                                       │
│  Holds: nothing after submission —   │
│  buffer cleared immediately          │
│                                       │
│  Talks to: Compute Box only, over    │
│  mTLS WebSocket/HTTPS                │
└───────────────────────────────────────┘
```

No model, no database beyond a small in-memory session buffer, no ABDM logic. A terminal can be a locked-down Android tablet running a single kiosk-mode app (Android's Screen Pinning / dedicated MDM kiosk profile) — cheap, replaceable, low attack surface.

### 3.2 Waiting-Room Compute Box (all inference)

```
┌─────────────────────────────────────────────────────────┐
│                    COMPUTE BOX                            │
│                                                             │
│  ┌───────────────────────────────────────────────────┐   │
│  │           Local API Gateway (FastAPI)              │   │
│  │  - mTLS termination, per-device auth token          │   │
│  │  - request validation, rate limiting                │   │
│  └───────────────────────┬─────────────────────────────┘   │
│                          │                                  │
│  ┌───────────────────────▼─────────────────────────────┐   │
│  │        Encounter State Machine (in code, not AI)     │   │
│  └───┬─────────────┬─────────────┬──────────────┬───────┘   │
│      │             │             │              │           │
│      ▼             ▼             ▼              ▼           │
│  ┌───────┐    ┌─────────┐   ┌─────────┐   ┌───────────┐    │
│  │  ASR  │    │   OCR   │   │   TTS   │   │ Dialogue/ │    │
│  │ faster│    │PaddleOCR│   │  Piper  │   │ Summary   │    │
│  │whisper│    │+TrOCR   │   │         │   │ (Qwen2.5- │    │
│  │       │    │(+optional│   │         │   │  7B via   │    │
│  │       │    │ Qwen-VL) │   │         │   │ llama.cpp │    │
│  │       │    │          │   │         │   │  server)  │    │
│  └───┬───┘    └────┬─────┘   └────┬────┘   └─────┬─────┘   │
│      └─────────────┴──────────────┴──────────────┘         │
│                          │                                  │
│                          ▼                                  │
│              Deterministic Triage Rules (code)              │
│                          │                                  │
│                          ▼                                  │
│              Local SQLite (encounter drafts,                │
│              job queue, audit log)                          │
│                          │                                  │
│                          ▼                                  │
│              Encrypted local file store                     │
│              (raw audio/images — short retention)            │
└─────────────────────────────────────────────────────────────┘
```

All AI services run as separate local processes behind the gateway (plain processes for the hackathon build — see §7; containerizing them is a later packaging step, not a hackathon requirement), each exposing a small internal HTTP API (`/internal/asr`, `/internal/ocr`, `/internal/dialogue`, `/internal/summary`) — same "inference gateway" idea as your original design, just sized to one box instead of a cluster. This keeps model swaps (e.g., upgrading TrOCR-small to a VLM later) isolated to one service.

### 3.3 Doctor Tablet (thin client + trust authority)

```
┌─────────────────────────────────────┐
│           DOCTOR APP                 │
│                                       │
│  - Live queue (RED/YEL/GRN),         │
│    pulled from Compute Box            │
│  - Structured summary view            │
│    (rendered from JSON the box sent) │
│  - Accept / Edit / Reject / Sign      │
│  - ABDM module (Fidelius protocol):   │
│      • Generates a fresh ephemeral    │
│        ECDH keypair per transaction   │
│        (software crypto, e.g.         │
│         abdm_fidelius pkg — not a     │
│         persistent Keystore EC key)   │
│      • Consent request/approval flow  │
│      • Decrypt received FHIR bundles  │
│        (ECDH→HKDF-SHA256→AES-256-GCM) │
│      • Merge into summary view        │
│  - No AI models, no raw audio/image   │
│    storage — only structured data     │
└───────────────────────────────────────┘
```

The tablet is intentionally the least powerful device in the system computationally, and the most protected operationally. It carries no model weights at all.

### 3.4 ABDM / ABHA path — kiosk-initiated consent, fetch runs during the kiosk visit

The ABDM flow follows the canonical architecture: the **patient-facing kiosk initiates the consent request**, while the **doctor tablet remains the only device that generates and holds ABDM key material (via the Fidelius protocol) and performs local decryption**. This key material is a fresh ephemeral ECDH keypair generated per transaction, not a persistent identity key — there is no single long-lived "HIU private key" anywhere in the system.

**Sequencing change:** ABHA entry fires the consent request immediately — the first thing that happens after language selection, before the SOCRATES intake conversation begins — rather than being deferred until later in the kiosk flow. The intake conversation, document scan, and vitals capture then proceed as "cover time" for the patient's OTP approval and the subsequent fetch, so the encrypted bundle is frequently already sitting on the compute box by the time the patient finishes at the kiosk. This is a timing change only: custody of key material is unchanged — the kiosk never sees, requests, or holds any key material at any point.

```
Patient / Kiosk
       │
       │  1. ABHA ID entry / QR scan
       │     (no private key) — fires immediately,
       │     before intake conversation starts
       ▼
Compute Box
       │
       │  2. Consent request → ABDM Gateway
       │     (backend relays request; no key material)
       ▼
       ┌─────────────────────────────────────────────┐
       │  2a. Kiosk proceeds directly into SOCRATES    │
       │  intake, document scan, vitals — runs in      │
       │  parallel with steps 3–5 below. Kiosk polls   │
       │  /consent/status in the background and shows  │
       │  a non-blocking "Fetching past records…"      │
       │  indicator. No record content ever reaches    │
       │  the kiosk.                                   │
       └─────────────────────────────────────────────┘
ABDM Consent Manager
       │
       │  3. Patient approval
       │     OTP / ABHA app (patient's own phone)
       ▼
Doctor Tablet
       │
       │  4. Background consent listener reacts to the
       │     APPROVED event and auto-generates a fresh
       │     ephemeral ECDH keypair for this transaction
       │     (Fidelius protocol) — no doctor action needed
       │     for generation; public key + nonce relayed
       │     via Compute Box as part of the HI-REQUEST
       ▼
ABDM / HIU-HIP network
       │
       │  5. Encrypted FHIR bundle (AES-256-GCM,
       │     key derived via ECDH+HKDF-SHA256)
       ▼
Compute Box
       │
       │  Stores encrypted bundle as-is
       │  Cannot decrypt it
       ▼
Doctor Tablet
       │
       │  6. Local decryption using this transaction's
       │     ephemeral private key, gated behind doctor
       │     PIN/biometric (§8.4) — distinct from the
       │     ungated auto-keypair-generation in step 4 —
       │     then discards the private key
       ▼
Doctor reviews / merges relevant data
```

**Trust boundary (unchanged):**

- The **patient kiosk** handles ABHA identification and initiates the consent workflow, now as the very first kiosk action. It also polls fetch status for UI purposes only.
- The **compute box** acts as the local gateway/relay and may store the encrypted bundle, but has **no ABDM key material and no decryption capability**.
- The **doctor tablet** generates a fresh ephemeral ECDH keypair for each transaction (now auto-triggered by a background listener rather than a manual doctor action) and performs decryption locally, gated by PIN/biometric; the private half is discarded after use rather than persisted as a long-term identity key.
- No private key material is ever transmitted to the kiosk, compute box, or ABDM relay service, regardless of how early or eagerly the fetch is triggered.

**Consent state per encounter:**

```text
NOT_REQUESTED
      ↓
PENDING
      ↓
APPROVED
      ↓
KEY_MATERIAL_SENT
      ↓
FETCHED_ENCRYPTED
      ↓
DECRYPTED
```

With the revised sequencing, encounters commonly reach `FETCHED_ENCRYPTED` while the patient is still at the kiosk (during intake/document scan/vitals) rather than only after they've left for the waiting area.

ABDM-dependent steps are asynchronous. If connectivity is unavailable, the request is queued locally and retried when connectivity returns. Patient approval may occur later through the patient's own phone, without requiring the patient to remain at the kiosk. Because step 4 now matters on a tighter timescale (ideally within the patient's kiosk visit, not just "eventually"), a missed APPROVED event on the doctor tablet is treated as a queued retry the moment the tablet reconnects, using the same outbox/retry mechanism already in place for connectivity gaps elsewhere in the system — no new failure-handling mechanism is introduced, just a tighter expectation on latency.

---

## 4. AI model stack (summary)

| Task | Model | Footprint | Where it runs |
|---|---|---|---|
| ASR | AI4Bharat Indic Whisper small/medium, INT8 | ~250–800 MB | Compute box |
| TTS | Piper (per-language voice) | ~20–60 MB | Compute box |
| OCR — printed | PaddleOCR server-lite | ~15–20 MB | Compute box |
| OCR — handwriting | TrOCR-base, or Qwen2.5-VL-3B (INT4) if a GPU is present | 250 MB–2 GB | Compute box |
| Dialogue + summary | Qwen2.5-7B-Instruct (Q4_K_M) served via `llama.cpp` server, JSON-schema constrained decoding for summary output | ~4.5 GB | Compute box |
| Triage | Deterministic rule engine | 0 MB | Compute box |
| FHIR mapping | Deterministic code | 0 MB | Compute box or tablet |
| ABDM consent/decrypt | Fidelius protocol: per-transaction ephemeral ECDH + HKDF-SHA256 + AES-256-GCM, no model | negligible | **Doctor tablet only** |

---

## 5. Encounter state machine

```
CREATED → IDENTIFIED (fires ABDM consent request here, in parallel)
   → INTAKE_IN_PROGRESS → DOCS_SCANNED
   → TRIAGE_COMPLETE → SUMMARY_DRAFTED → SYNCED_TO_DOCTOR
   → DOCTOR_REVIEW → (EDITED | ACCEPTED | REJECTED) → SIGNED
   → ABDM_ENRICHMENT_PENDING (parallel, non-blocking, started at IDENTIFIED —
      see note below)
   → ABDM_OUTBOUND_QUEUED → SYNCED_TO_ABDM → COMPLETE
```

**Note on ABDM timing:** `ABDM_ENRICHMENT_PENDING` is shown after `SIGNED` in the linear list above because that's where it typically *completes and is confirmed* relative to doctor review, but the underlying consent request/fetch (§3.4) is actually **kicked off back at `IDENTIFIED`**, not held until after signing. In practice, by the time the encounter reaches `DOCTOR_REVIEW`, `ABDM_ENRICHMENT_PENDING` has frequently already progressed to `FETCHED_ENCRYPTED` in parallel with `INTAKE_IN_PROGRESS` through `SUMMARY_DRAFTED`. This is a display/sequencing nuance, not a new state — the state machine still has one linear path for the intake/triage/review side and one parallel track for ABDM, exactly as already modeled; only the parallel track's start point moved earlier.

Any step can fail and resume from its last durable state (e.g., `OCR_RETRY_PENDING`), same recovery philosophy as the original architecture — just implemented as SQLite-backed job rows instead of a distributed event bus, which is appropriate at single-box scale.

---

## 6. Data model (SQLite on the compute box)

```sql
patients        (patient_id, abha_id, name, dob, gender, mobile)
encounters      (encounter_id, patient_id, status, started_at, ended_at)
observations    (observation_id, encounter_id, code, value, source, observed_at)
documents       (document_id, encounter_id, type, object_uri, sha256, confidence)
ai_artifacts    (artifact_id, encounter_id, type, model_name, model_version,
                 prompt_version, input_hash, output_json, created_at)
triage_decisions(decision_id, encounter_id, severity, rule_set_version,
                 reasons_json, created_at)
doctor_reviews  (review_id, encounter_id, doctor_id, action, changes_json,
                 created_at)     -- stored/synced from the tablet
abdm_transactions(transaction_id, encounter_id, status, consent_reference,
                 retry_count, last_attempt_at)   -- lives on the tablet
audit_log       (event_id, actor_type, action, encounter_ref, before_hash,
                 after_hash, timestamp)   -- hash-chained, append-only
```

The tablet keeps its own lightweight mirror (encounters + summaries + reviews only — never raw audio/images), so a doctor can keep reviewing already-synced patients even if the box briefly restarts.

---

## 6.1 ABDM trust-boundary invariant

The following rule is non-negotiable across all deployment tiers:

> **ABDM key material and record-decryption capability exist only on the doctor's device.**

Note this is not a single static "HIU keypair" — ABDM's Fidelius protocol generates a fresh ephemeral ECDH keypair per data-flow transaction. The invariant is about *where* that generation and decryption happen (doctor's device only), not about a persistent secret being stored there.

The kiosk may identify the patient and initiate consent. The compute box may authenticate to the ABDM gateway, relay consent requests, receive encrypted bundles, and persist encrypted bytes. It must never possess any ABDM private key material or a code path capable of decrypting ABDM health records.

## 7. Feasibility recommendations

These are aimed specifically at getting this built and demoed reliably within a hackathon timeline, while staying realistic for eventual field deployment.

1. **No Docker for the hackathon build.** Run each service (gateway, ASR, OCR, LLM server) as a plain local process, launched via `start_all.sh` (supervisord/pm2 optional), against a single SQLite file. This is purely a presentation-scope call — Docker Compose is a reasonable step later for field packaging (golden-image builds, consistent versions across many boxes), but it's unnecessary setup/debugging overhead for a hackathon timeline. Revisit once the end-to-end demo works.
2. **Go CPU-only first; treat the GPU as a stretch goal.** Whisper-small and Qwen2.5-7B (Q4) both run acceptably on a modern CPU for one active conversation at a time, which is likely all a demo needs. Adding a GPU adds procurement risk, driver setup time, and power/cooling complexity you don't need to solve during a hackathon crunch.
3. **Cap your demo concurrency at 1–2 simultaneous patients**, not 4. This keeps the local inference server simple (no need to tune batching aggressively) and makes the demo predictable in front of judges.
4. **Use the actual ABDM Sandbox environment**, not a mocked API. NHA provides a public sandbox for exactly this purpose — it's realistic, free, and saves you from having to fake a consent flow that judges may ask pointed questions about.
5. **Ship a "golden image," not a fresh install script.** Pre-bake the OS + all model weights + containers onto one disk image, and flash new boxes from that image via USB. Villages won't have the bandwidth to download several GB of models on deployment day — this also gives you a fast recovery path if a box fails (flash a spare, don't rebuild).
6. **Keep the job queue as SQLite rows, not a message broker.** Redis/NATS is the right call at real multi-box hospital scale; at single-box hackathon scale it's unnecessary infrastructure to build and explain.
7. **Use off-the-shelf Android tablets as terminals** running a single kiosk-mode app (Android's built-in Screen Pinning, or a basic MDM profile) rather than custom hardware — cheapest, fastest to build, and a believable procurement story for judges asking about real-world cost.
8. **Resolved: demo language pair is Hindi + English**, wired end-to-end (ASR, tree question phrasing, TTS, doctor-facing summary). Describe remaining Indic languages to judges as "same pipeline, additional language packs" rather than trying to get every language working before demo day.

---

## 8. Security hardening

### 8.1 Physical security of the compute box
- Lockable steel enclosure, bolted to a wall or fixed furniture — treat it like an ATM, not a desktop PC.
- No exposed USB/HDMI/Ethernet ports on the accessible face; route cabling internally.
- Disable boot-from-USB in firmware, set a BIOS/UEFI password, enable Secure Boot.
- Full-disk encryption (LUKS) on the box's SSD.
- **Practical extra measure for both security and a strong demo point:** require a physical security token/USB key, held by clinic staff overnight, to unlock the disk-encryption key each morning. A stolen box without that token is inert data — nothing to decrypt without it. This is cheap to implement (a systemd unit that waits for a specific USB device before unsealing the encrypted volume) and demonstrates real security thinking to judges.

### 8.2 Data minimization and retention
- Auto-purge raw audio and scanned document images from the compute box **once the structured summary has been synced to and confirmed by the doctor tablet** — typically within hours, not indefinitely. Keep only the structured JSON and hashes long-term.
- This directly reduces the value of the compute box as a target: even a successful physical compromise yields little beyond whatever is currently mid-processing.

### 8.3 Network security
- Separate patient-facing Wi-Fi (client isolation on) from the staff segment carrying box↔tablet traffic.
- mTLS between every terminal↔box and box↔tablet connection, with per-device certificates issued at provisioning time — not shared passwords.
- Per-device auth tokens at the API gateway; reject any unrecognized device ID outright.
- No inbound internet access to the compute box at all — outbound-only, and only for the ABDM relay function.

### 8.4 Trust boundary enforcement
- The compute box's software should have **no code path capable of generating or reading ABDM key material** — don't just avoid calling it, structurally exclude the capability so a compromised box can't be repurposed to exfiltrate a transaction's private key even by an attacker with code execution on the box.
- ABDM consent decisions require doctor tablet authentication (PIN/biometric) — a stolen tablet alone shouldn't be sufficient to approve consent requests.

### 8.5 Auditability
- Hash-chain the audit log (`this_hash = sha256(prev_hash + event)`), so any tampering with historical entries is detectable even without a distributed ledger — cheap to implement, meaningfully raises the bar for covering up unauthorized access.
- Every AI artifact keeps its model name/version/prompt version, same governance envelope as the original design, so any output is traceable to exactly what produced it.

### 8.6 DPDP alignment
- Frame this as "architecture designed to support DPDP Act 2023 and applicable rules" rather than claiming compliance outright — compliance also depends on organizational policy, consent notices, and process, not just the technical design.
- Technical controls above (minimization, retention limits, encryption, access control, auditability) map directly to the DPDP principles worth calling out explicitly in your submission: purpose limitation, data minimization, security safeguards, and accountability.

---

## 9. Suggested build order for the hackathon

1. Deterministic state machine + SQLite schema (no AI yet) — get a fake patient through the full lifecycle with hardcoded data.
2. Wire in ASR + the dialogue/slot-filling model for one language, one chief complaint branch (e.g., chest pain via SOCRATES).
3. Wire in OCR for one document type (printed prescription).
4. Wire in the deterministic triage rules against real vitals + red-flag symptoms.
5. Wire in summary generation with JSON-schema-constrained decoding.
6. Build the doctor tablet's review/sign UI, syncing against the box over LAN.
7. Wire in the ABDM sandbox consent flow last — it's the most isolated component and the least likely to block your core demo if it's not fully finished.
8. Layer in the security hardening items (disk encryption, mTLS, hash-chained audit log) once the happy path works end-to-end — these are additive and won't block core functionality if time runs short.

---

## 10. Presentation/demo configuration (kiosk collapsed onto the laptop)

For the hackathon demo, the **patient terminal and the compute box collapse onto one laptop** — no separate tablet/mini-PC needed to show the concept live. The **doctor's device stays separate** (a tablet, or a second laptop) so judges can still see the two-role split that's central to the pitch.

```
                    DEMO LAPTOP                          DOCTOR DEVICE
┌─────────────────────────────────────────────┐      ┌────────────────────┐
│  Kiosk UI (fullscreen browser/Electron       │      │   Doctor App        │
│  window, kiosk-mode) — same UI a patient     │      │  (tablet or 2nd     │
│  terminal would show                         │      │   laptop)           │
│         │                                    │      │                    │
│         ▼                                    │      │  - Live queue      │
│  Local inference services, all on            │      │  - Structured      │
│  localhost (same processes described         │      │    summary view    │
│  in Section 3.2):                            │      │  - Accept/Edit/    │
│   - ASR (faster-whisper)                     │      │    Sign            │
│   - OCR (PaddleOCR/TrOCR)                    │      │  - ABDM consent    │
│   - TTS (Piper)                              │◀────▶│    module (key     │
│   - Dialogue/Summary (Qwen2.5-7B via         │  LAN/│    lives here)     │
│     llama.cpp server)                        │  Wi-Fi│                   │
│   - Deterministic triage rules               │      └────────────────────┘
│   - SQLite (encounter drafts, audit log)     │
└───────────────────────────────────────────────┘
```

**What stays identical to the real architecture:**
- The trust boundary — the laptop still never holds the ABDM private key or performs consent/signing; that stays on the doctor's device.
- The state machine, data model, model stack, and sync protocol between the two devices are unchanged — you're demoing the real pipeline, just on consolidated hardware.

**What's different for the demo only (call this out explicitly to judges rather than letting it look like the production design):**
- In production, the patient terminal and the compute box are deliberately separate for cost (cheap disposable terminals vs. one shared box) and for physical security (a locked, disk-encrypted enclosure vs. a screen a patient touches). Collapsing them onto one laptop for the demo is purely a presentation convenience.
- You lose the ability to demo multi-terminal concurrency (one box serving several patients at once) unless you open a second browser window/tab pointed at the same localhost services — which is actually a nice option if you want to show batching working, since it doesn't require a second physical device.

**Practical setup:**
1. Run all inference services + the API gateway locally as plain processes (`start_all.sh`), bound to `localhost` instead of a LAN address.
2. Run the kiosk web/Electron app pointed at `localhost` instead of the box's LAN IP.
3. Connect the doctor device to the laptop's Wi-Fi hotspot (or the same router) so it can reach the laptop's gateway over LAN — this is the one piece of real networking you still need for the demo to show device-to-device sync.
4. If you want to show multi-patient concurrency, open a second kiosk browser window and run two encounters through in parallel — same localhost backend handles both via the batching you already built.

Want me to also fold the doctor side onto the same laptop (second window/tab you flip to), or keep it on a separate device as above?

---

## 11. Tech stack summary

| Layer | Choice |
|---|---|
| Terminal app (production) | Android (Kotlin/Flutter), kiosk-mode |
| Terminal app (demo) | Same UI, run as a fullscreen browser/Electron window on the laptop |
| Doctor app | Android/iPad (Flutter or native), thin client |
| Compute box OS | Ubuntu Server (LTS), LUKS full-disk encryption |
| Box orchestration | Plain processes for hackathon (`start_all.sh`); Docker Compose deferred to a later field-packaging step |
| API gateway | FastAPI |
| LLM serving | `llama.cpp` server (Qwen2.5-7B-Instruct, Q4_K_M) |
| ASR | `faster-whisper` (Indic Whisper fine-tunes) |
| OCR | PaddleOCR + TrOCR-base (optional Qwen2.5-VL-3B) |
| TTS | Piper |
| Local DB | SQLite (box), SQLite (tablet mirror) |
| Object storage | Encrypted local filesystem (short retention) |
| Transport security | mTLS, per-device certificates |
| ABDM/FHIR | Kiosk-initiated consent via backend relay; doctor tablet performs local decryption; box acts as blind encrypted-bundle relay |
| Audit | Hash-chained append-only log |
