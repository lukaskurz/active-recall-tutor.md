#!/bin/zsh
# One-time setup: build an isolated venv with mlx-whisper on the Apple GPU.
# Safe to re-run (skips if the venv already imports mlx_whisper).
# Requires: Apple Silicon Mac, Homebrew python3.11, ffmpeg (brew install ffmpeg python@3.11).
set -e
TOOLKIT="${0:A:h}"
VENV="$TOOLKIT/mlxenv"

# pick an arm64 Python 3.11/3.12 that is NOT anaconda (keeps mlx isolated from your base env)
PYBIN=""
for cand in /opt/homebrew/bin/python3.11 /opt/homebrew/bin/python3.12 /opt/homebrew/bin/python3; do
  [ -x "$cand" ] && { PYBIN="$cand"; break; }
done
[ -z "$PYBIN" ] && { echo "ERROR: need Homebrew python (brew install python@3.11)"; exit 1; }
echo "Using base python: $PYBIN ($($PYBIN -c 'import platform;print(platform.machine())'))"

if [ -x "$VENV/bin/python" ] && "$VENV/bin/python" -c "import mlx_whisper" 2>/dev/null; then
  echo "venv already set up: $VENV"; exit 0
fi

echo "Creating venv at $VENV ..."
"$PYBIN" -m venv "$VENV"
"$VENV/bin/pip" install -q --upgrade pip
# numpy<2 is required because mlx-whisper -> numba needs it
"$VENV/bin/pip" install -q mlx-whisper numba "numpy<2"

echo "Verifying ..."
"$VENV/bin/python" - <<'PY'
import mlx_whisper, numba, numpy, mlx.core as mx
print("mlx_whisper OK | numba", numba.__version__, "| numpy", numpy.__version__, "| device", mx.default_device())
PY
command -v ffmpeg >/dev/null && echo "ffmpeg: $(command -v ffmpeg)" || echo "WARNING: ffmpeg not found -> brew install ffmpeg"
echo "Setup complete. Model downloads automatically on first transcription (~1.5GB, cached)."
