#!/usr/bin/env python3
"""Transcribe one audio file with mlx-whisper on the Apple GPU.

Usage: python mlx_transcribe.py <audio_path> <out_prefix> [label]
Env:   MLX_WHISPER_REPO   (default mlx-community/whisper-large-v3-mlx)
       WHISPER_LANGUAGE   (default en)
Writes <out_prefix>.txt and <out_prefix>.srt
"""
import sys, time, os
import mlx_whisper

audio = sys.argv[1]
out_prefix = sys.argv[2]
label = sys.argv[3] if len(sys.argv) > 3 else os.path.basename(out_prefix)
repo = os.environ.get("MLX_WHISPER_REPO", "mlx-community/whisper-large-v3-mlx")
language = os.environ.get("WHISPER_LANGUAGE", "en")

def log(*a):
    print(f"[{label}]", *a, flush=True)

def fmt_ts(t):
    h = int(t // 3600); t -= h * 3600
    m = int(t // 60); t -= m * 60
    s = int(t); ms = int(round((t - s) * 1000))
    if ms == 1000: ms = 0; s += 1
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

log(f"transcribing with {repo} (GPU), lang={language} ...")
t0 = time.time()
result = mlx_whisper.transcribe(
    audio,
    path_or_hf_repo=repo,
    language=language,
    word_timestamps=False,
    condition_on_previous_text=False,   # breaks repetition/hallucination loops
    compression_ratio_threshold=2.4,    # re-decode runs that compress too well (repeats)
    no_speech_threshold=0.6,            # skip silence-only segments
    verbose=False,
)
el = time.time() - t0

# Collapse consecutive duplicate segments and drop empty ones, keeping .txt/.srt in sync.
raw = result.get("segments", [])
cleaned = []  # [start, end, text]
for seg in raw:
    text = seg["text"].strip()
    if not text:
        continue
    if cleaned and cleaned[-1][2] == text:
        cleaned[-1][1] = seg["end"]
    else:
        cleaned.append([seg["start"], seg["end"], text])

dur = cleaned[-1][1] if cleaned else (raw[-1]["end"] if raw else 0.0)
txt_path = out_prefix + ".txt"
srt_path = out_prefix + ".srt"
with open(txt_path, "w", encoding="utf-8") as ftxt, open(srt_path, "w", encoding="utf-8") as fsrt:
    for i, (st_, en_, text) in enumerate(cleaned, 1):
        fsrt.write(f"{i}\n{fmt_ts(st_)} --> {fmt_ts(en_)}\n{text}\n\n")
        ftxt.write(text + "\n")

speed = dur / el if el > 0 else 0
log(f"DONE {len(cleaned)} segs, audio {dur/60:.1f} min, transcribe {el/60:.2f} min, {speed:.2f}x realtime")
log(f"out {txt_path}")
log(f"out {srt_path}")
