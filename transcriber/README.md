# Lecture transcription toolkit (local, Apple-GPU Whisper)

Reusable pipeline that downloads JKU/Moodle lecture recordings, transcribes them
locally with **mlx-whisper `large-v3` on the M1 GPU**, and writes `.txt` + `.srt`
per lecture. Designed for **transcripts-only**: the downloaded audio is deleted
after each lecture (no video/audio kept).

Built/validated on: Apple M1 Max, macOS, Homebrew ffmpeg + python@3.11.
First use case: JKU course 42092 "Deep Learning: Geometric Techniques" (2026S),
12 lectures, ~12.8 h audio → ~87k words in ~41 min.

---

## Quick start (new lectures)

```sh
cd /Users/lukaskurz/Desktop/recording/transcriber

# 1. one-time environment setup (idempotent; safe to re-run)
./setup.sh

# 2. build a manifest.tsv of  <name><TAB><media_url>  (see step A below)

# 3. transcribe -> writes <name>.txt / <name>.srt into the output dir
./transcribe_lectures.sh /path/to/manifest.tsv /path/to/output_dir
```

Run it in the background for big batches:
```sh
nohup ./transcribe_lectures.sh manifest.tsv ../newcourse >> run.log 2>&1 &
tail -f run.log
```

It is **idempotent** (skips lectures already transcribed) and **lock-guarded**
(a second launch on the same output dir is a no-op), so re-running after an
interruption just resumes.

---

## Step A — get the media URLs (build the manifest)

Lectures on JKU Moodle are **`StreamURL` activities** that point at plain MP4
files on `download.jku.at`. To collect them:

1. Open the Moodle **course page** that lists the lectures (logged in).
2. Run `extract_moodle_urls.js` in the browser console (or have Claude run it via
   the Chrome extension). It prints `manifest.tsv` lines: `NN_name <TAB> url`.
3. Save those lines to a `manifest.tsv`. Delete any lectures you don't want, fix
   the `name` column to taste (no spaces; `.txt`/`.srt` are named from it).
   Lines starting with `#` are ignored.

See `manifest.example.tsv` for the format (the 12 GDL lectures).

> The MP4s on `download.jku.at` are directly downloadable (no auth) — only the
> Moodle *page* needs your login to read. If a course embeds a player instead
> (Panopto/Kaltura/Opencast/YouTube), use `yt-dlp <player_url>` to get the media,
> then point the manifest at the downloaded file path or stream URL.

---

## Step A (variant) — Opencast / LTI courses

Some JKU courses don't use `StreamURL` links; they embed recordings through an
**Opencast** player via an **LTI launch** (the activity type is `mod/opencast`).
There is **no media URL in the Moodle page** — each tile auto-submits a signed LTI
form into JKU's separate **Opencast engage server, `media.jku.at`** (cross-origin),
which is the only place that knows the real track URLs.

How to build the manifest for such a course:

1. Open the Moodle course page that lists the recording tiles (logged in).
2. **Open one recording** (click any tile, or open `mod/opencast/view.php?...&e=<uuid>`).
   This LTI launch establishes your **`media.jku.at` session** (the engage host).
   You can confirm the host: it's the `action=` host of the `<form>` inside the
   `filter/opencast/ltilaunch.php` iframe. JKU runs standard Opencast, so the host
   is `media.jku.at`. Then go **back to the course page**.
3. Run **`extract_opencast_urls.js`** in that page's console (or via the Chrome
   extension). It scrapes each tile's episode UUID, calls the Opencast **Search API**
   `https://media.jku.at/search/episode.json?id=<uuid>` (credentialed; CORS + your
   engage session cookie allow the cross-origin fetch), and for each episode picks
   the **smallest progressive MP4 track that has audio** — audio is all the
   transcriber needs, and JKU muxes the lecturer's mic into every track, so the
   low-res *presentation* (slides) stream is enough and the smallest to download.
   It prints `manifest.tsv` lines `NN_name <TAB> https://media.jku.at/static/.../concat.mp4`.
   > If a line says `NEEDS_ENGAGE_SESSION...`, you skipped step 2 — open one
   > recording so the engage session exists, then re-run.
4. Save the lines to `manifest.tsv`, fix the `name` column to taste, and run
   `transcribe_lectures.sh` as usual.

**Downloading:** on JKU's Opencast the `media.jku.at/static/...` track files are
**publicly downloadable** (only the engage *Search API* needs your session, not the
media files), so the default `FETCHER=ffmpeg` streams them directly — no cookies,
no yt-dlp. If a different Opencast instance protects its tracks (signed
"Stream Security" URLs, or a session-only CDN) or serves **HLS** instead of
progressive MP4, switch to the yt-dlp fetch path:

```sh
# fetch via yt-dlp (handles HLS + reuses a Chrome profile's cookies)
FETCHER=ytdlp YTDLP_COOKIES="chrome:Lukas" \
  ./transcribe_lectures.sh manifest.tsv ../particle-sims
```

`YTDLP_COOKIES` is passed to `yt-dlp --cookies-from-browser` (format
`browser[:profile]`). Reading Chrome's cookie store may trigger a one-time macOS
Keychain prompt ("Chrome Safe Storage"). `YTDLP_FORMAT` (default `bestaudio/best`)
overrides the yt-dlp format selector. Because some Opencast track URLs are
short-lived, resolve the manifest **shortly before** running the batch.

> First Opencast use case: JKU course 2026S360019 "All Lecture Recordings 2026S"
> (particle simulations), 11 recordings, ~13.7 h → `../particle-sims/`.

---

## Files

| file | purpose |
|---|---|
| `setup.sh` | creates `mlxenv/` venv, installs `mlx-whisper` (+ numba, numpy<2) |
| `transcribe_lectures.sh` | the batch runner (download→audio→GPU transcribe→cleanup) |
| `mlx_transcribe.py` | transcribes one audio file → `.txt` + `.srt` |
| `extract_moodle_urls.js` | browser snippet to harvest `StreamURL` MP4s into a manifest |
| `extract_opencast_urls.js` | browser snippet for Opencast/LTI courses (Search API → manifest) |
| `manifest.example.tsv` | example manifest (the GDL course) |
| `mlxenv/` | isolated Python venv (created by setup.sh) |

---

## Options (env vars)

```sh
# different model (smaller = faster, less accurate)
MLX_WHISPER_REPO=mlx-community/whisper-medium-mlx ./transcribe_lectures.sh m.tsv out

# different language (default en); use the ISO code, or unset for auto-detect
WHISPER_LANGUAGE=de ./transcribe_lectures.sh m.tsv out

# fetch via yt-dlp instead of streaming with ffmpeg (HLS / auth-gated players)
FETCHER=ytdlp YTDLP_COOKIES="chrome:Lukas" ./transcribe_lectures.sh m.tsv out
```

| env var | default | purpose |
|---|---|---|
| `FETCHER` | `ffmpeg` | `ffmpeg` streams a public URL; `ytdlp` downloads first (HLS/auth) |
| `YTDLP_COOKIES` | _(empty)_ | `yt-dlp --cookies-from-browser` arg, e.g. `chrome:Lukas` |
| `YTDLP_FORMAT` | `bestaudio/best` | yt-dlp format selector (audio is all that's needed) |
| `WHISPER_LANGUAGE` | `en` | transcription language (ISO code; unset = auto-detect) |
| `MLX_WHISPER_REPO` | `…/whisper-large-v3-mlx` | model repo |

Useful model repos: `mlx-community/whisper-large-v3-mlx` (default, best),
`mlx-community/whisper-large-v3-turbo` (faster), `mlx-community/whisper-medium-mlx`.

---

## How it works / why these choices

- **ffmpeg streams the remote MP4 and extracts 16 kHz mono audio** in one step,
  so the multi-GB video never touches disk. (~150 MB wav per ~80-min lecture.)
- **mlx-whisper runs on the Apple GPU** (CTranslate2 / faster-whisper is CPU-only
  on Macs). Measured ~24× real-time for `large-v3` here.
- **`condition_on_previous_text=False` + consecutive-duplicate collapse** in
  `mlx_transcribe.py` removes Whisper's repetition/hallucination loops (e.g.
  `of of of`, `the, uh,` ×40) that appear in silence/discussion gaps. This also
  *speeds it up*, because the decoder stops re-decoding stuck segments.
- Audio is read on **FD 3** in the loop and ffmpeg gets `-nostdin`, so ffmpeg
  can't swallow the manifest from stdin (a classic `while read` + ffmpeg bug).

## Requirements

```sh
brew install ffmpeg python@3.11      # if not already present
```
Apple Silicon required (MLX uses the Metal GPU). The `large-v3` model (~1.5 GB)
downloads from Hugging Face on first run and is cached in `~/.cache/huggingface`.

## Environment note

mlx-whisper needs `numpy<2`, which conflicts with `jax`/`opencv` in the base
anaconda env — that's exactly why everything lives in the isolated `mlxenv/`
venv and nothing is installed into anaconda base.
