"""Download all local MediKiosk runtime models into a chosen model directory.

Run after ``pip install -e '.[llm,services]'``. This script downloads model assets only;
no inference request or patient data leaves the appliance.
"""

from __future__ import annotations

import argparse
import shutil
import urllib.request
from pathlib import Path


QWEN_REPO = "Qwen/Qwen2.5-7B-Instruct-GGUF"
QWEN_FILES = [
    "qwen2.5-7b-instruct-q4_k_m-00001-of-00002.gguf",
    "qwen2.5-7b-instruct-q4_k_m-00002-of-00002.gguf",
]
PIPER_BASE = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0"
PIPER_VOICES = {
    "en": "en/en_US/lessac/medium/en_US-lessac-medium",
    "hi": "hi/hi_IN/pratham/medium/hi_IN-pratham-medium",
}


def download_file(url: str, target: Path) -> None:
    if target.is_file() and target.stat().st_size > 0:
        print(f"Already present: {target.name}")
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    print(f"Downloading: {target.name}")
    urllib.request.urlretrieve(url, target)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=Path("./models"))
    parser.add_argument("--skip-llm", action="store_true")
    parser.add_argument("--skip-asr", action="store_true")
    parser.add_argument("--skip-ocr", action="store_true")
    args = parser.parse_args()
    output = args.output.resolve()
    required_bytes = 8 * 1024**3
    free_bytes = shutil.disk_usage(output.anchor).free
    if not args.skip_llm and free_bytes < required_bytes:
        raise SystemExit(f"At least 8 GB free is required for Qwen plus runtime cache; only {free_bytes / 1024**3:.1f} GB is available.")

    if not args.skip_llm:
        from huggingface_hub import hf_hub_download

        for filename in QWEN_FILES:
            hf_hub_download(repo_id=QWEN_REPO, filename=filename, local_dir=output / "llm")

    for language, voice_path in PIPER_VOICES.items():
        voice_dir = output / "tts" / language
        for suffix in (".onnx", ".onnx.json"):
            download_file(f"{PIPER_BASE}/{voice_path}{suffix}", voice_dir / f"{language}{suffix}")

    # These packages handle their authoritative model downloads and caches themselves.
    # Instantiation here makes acquisition explicit and allows an offline kiosk run afterward.
    if not args.skip_asr:
        from faster_whisper import WhisperModel

        WhisperModel("Systran/faster-whisper-small", device="cpu", compute_type="int8", download_root=str(output / "asr"))
        print("ASR model ready")
    if not args.skip_ocr:
        import os

        os.environ["PADDLE_PDX_CACHE_HOME"] = str(output / "ocr")
        from paddleocr import PaddleOCR

        PaddleOCR(lang="en", use_doc_orientation_classify=False, use_doc_unwarping=False, use_textline_orientation=False)
        print("OCR model ready")

    print("All selected local model assets are ready.")


if __name__ == "__main__":
    main()
