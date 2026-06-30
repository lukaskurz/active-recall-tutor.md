#!/bin/zsh
# Transcribe lectures listed in a manifest with mlx-whisper large-v3 (Apple GPU).
#
# Usage:
#   transcribe_lectures.sh <manifest.tsv> [output_dir]
#
# manifest.tsv = one lecture per line:  <name><TAB><media_url>
#   e.g.   01_Intro<TAB>https://download.jku.at/.../Lecture1.mp4
# Produces <output_dir>/<name>.txt and <name>.srt. Deletes downloaded audio (transcripts only).
#
# Fetch path (env): FETCHER=ffmpeg (default; stream a public/plain URL) or
#   FETCHER=ytdlp (download via yt-dlp first — for HLS or auth-gated player streams,
#   e.g. Opencast). With ytdlp, set YTDLP_COOKIES="chrome:Profile" to reuse a browser
#   session's cookies. See README "Opencast / LTI courses".
# Sequential (single GPU). Lock-guarded: a second launch on the same output dir is a no-op.
# Idempotent: lectures whose .txt+.srt already exist are skipped, so you can safely re-run.
set -u
TOOLKIT="${0:A:h}"                              # dir of this script
PY="$TOOLKIT/mlxenv/bin/python"
MANIFEST="${1:?usage: transcribe_lectures.sh <manifest.tsv> [output_dir]}"
OUTDIR="${2:-$PWD}"
AUDIODIR="$(mktemp -d "${TMPDIR:-/tmp}/lectures.XXXXXX")"
LOCK="$OUTDIR/.transcribe.lock"
export MLX_WHISPER_REPO="${MLX_WHISPER_REPO:-mlx-community/whisper-large-v3-mlx}"
export WHISPER_LANGUAGE="${WHISPER_LANGUAGE:-en}"
FETCHER="${FETCHER:-ffmpeg}"                    # ffmpeg (stream public URL, default) | ytdlp (player/auth/HLS)
YTDLP_COOKIES="${YTDLP_COOKIES:-}"             # e.g. "chrome:Lukas" -> yt-dlp reads that Chrome profile's cookies
YTDLP_FORMAT="${YTDLP_FORMAT:-bestaudio/best}" # yt-dlp format selector (audio is all the transcriber needs)
mkdir -p "$OUTDIR"

if [ ! -x "$PY" ]; then
  echo "ERROR: venv missing. Run:  $TOOLKIT/setup.sh" ; exit 1
fi
if [ ! -f "$MANIFEST" ]; then echo "ERROR: manifest not found: $MANIFEST"; exit 1; fi

# --- single-instance guard (atomic mkdir) ---
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "$(date '+%H:%M:%S') already running for $OUTDIR (lock present) -> no-op exit"; exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null; rm -rf "$AUDIODIR" 2>/dev/null' EXIT INT TERM

echo "============================================================"
echo "TRANSCRIBE START $(date '+%F %H:%M:%S')  model=$MLX_WHISPER_REPO lang=$WHISPER_LANGUAGE fetcher=$FETCHER"
echo "manifest=$MANIFEST  out=$OUTDIR"
echo "============================================================"
t_all=$SECONDS; done_n=0; skip_n=0; fail_n=0

while IFS=$'\t' read -r -u 3 NAME URL; do
  [ -z "${NAME:-}" ] && continue
  case "$NAME" in \#*) continue;; esac          # allow # comments
  TXT="$OUTDIR/${NAME}.txt"; SRT="$OUTDIR/${NAME}.srt"
  WAV="$AUDIODIR/${NAME}.wav"; TMPA="$AUDIODIR/.${NAME}.partial.wav"
  ERR="$AUDIODIR/${NAME}.err.log"

  if [ -f "$TXT" ] && [ -f "$SRT" ]; then
    echo "[$NAME] already done, skipping."; skip_n=$((skip_n+1)); continue
  fi
  echo "------------------------------------------------------------"
  echo "[$NAME] START $(date '+%H:%M:%S')"

  # 1) obtain 16kHz mono audio from $URL. Two fetch paths (env FETCHER):
  #    ffmpeg (default) -> stream the remote file and extract audio in one step,
  #      so the multi-GB video never lands on disk. Works for public/plain URLs.
  #    ytdlp            -> download via yt-dlp first (handles HLS playlists and
  #      browser-session cookies), then extract audio locally. Use for player /
  #      auth-gated streams (Opencast Stream Security, Panopto, Kaltura, ...).
  #    -nostdin / </dev/null so ffmpeg can't consume the manifest. Atomic rename.
  t0=$SECONDS
  if [ "$FETCHER" = "ytdlp" ]; then
    DL="$AUDIODIR/${NAME}.src"
    if yt-dlp --no-warnings --no-progress \
         ${YTDLP_COOKIES:+--cookies-from-browser "$YTDLP_COOKIES"} \
         -f "$YTDLP_FORMAT" -o "$DL.%(ext)s" "$URL" </dev/null 2>"$ERR"; then
      SRC=$(ls -1 "$DL".* 2>/dev/null | head -1)
    else SRC=""; fi
    if [ -z "$SRC" ]; then
      echo "[$NAME] ERROR yt-dlp download failed (see $ERR)"; fail_n=$((fail_n+1)); continue
    fi
    if ffmpeg -nostdin -hide_banner -loglevel error -nostats -y \
         -i "$SRC" -vn -ac 1 -ar 16000 -c:a pcm_s16le "$TMPA" </dev/null 2>>"$ERR"; then
      mv "$TMPA" "$WAV"; rm -f "$SRC"
      echo "[$NAME] audio extracted (yt-dlp) in $((SECONDS-t0))s ($(du -h "$WAV"|cut -f1))"
    else
      rm -f "$TMPA" "$SRC"; echo "[$NAME] ERROR ffmpeg(extract) failed (see $ERR)"; fail_n=$((fail_n+1)); continue
    fi
  else
    if ffmpeg -nostdin -hide_banner -loglevel error -nostats -y \
         -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 10 \
         -i "$URL" -vn -ac 1 -ar 16000 -c:a pcm_s16le "$TMPA" </dev/null 2>"$ERR"; then
      mv "$TMPA" "$WAV"
      echo "[$NAME] audio extracted in $((SECONDS-t0))s ($(du -h "$WAV"|cut -f1))"
    else
      rm -f "$TMPA"; echo "[$NAME] ERROR ffmpeg failed (see $ERR)"; fail_n=$((fail_n+1)); continue
    fi
  fi

  # 2) transcribe on GPU; stdout (incl. DONE) -> main log, stderr (progress bar) -> err log
  t0=$SECONDS
  if "$PY" "$TOOLKIT/mlx_transcribe.py" "$WAV" "$OUTDIR/.${NAME}.partial" "$NAME" </dev/null 2>>"$ERR"; then
    mv "$OUTDIR/.${NAME}.partial.txt" "$TXT"
    mv "$OUTDIR/.${NAME}.partial.srt" "$SRT"
    echo "[$NAME] OK wall $((SECONDS-t0))s -> ${NAME}.txt / .srt"; done_n=$((done_n+1))
  else
    rm -f "$OUTDIR/.${NAME}.partial.txt" "$OUTDIR/.${NAME}.partial.srt"
    echo "[$NAME] ERROR transcription failed (see $ERR)"; fail_n=$((fail_n+1))
  fi

  rm -f "$WAV"          # transcripts only
done 3< "$MANIFEST"

echo "============================================================"
echo "TRANSCRIBE FINISHED $(date '+%F %H:%M:%S')  elapsed $(((SECONDS-t_all)/60))m$(((SECONDS-t_all)%60))s"
echo "done=$done_n skipped=$skip_n failed=$fail_n   transcripts in $OUTDIR: $(ls -1 "$OUTDIR"/*.txt 2>/dev/null | wc -l | tr -d ' ')"
echo "============================================================"
