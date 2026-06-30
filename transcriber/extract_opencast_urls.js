// Extract a transcribe manifest from a JKU/Moodle *Opencast* course page.
//
// Use this for courses whose recordings play through an Opencast/LTI embed
// (mod/opencast) instead of plain `StreamURL` MP4 links. There is NO media URL
// in the Moodle page source: each tile launches an LTI session into JKU's
// separate Opencast engage server (media.jku.at), which exposes the real MP4
// track URLs through its Search API.
//
// HOW TO USE:
//   1. Open ONE recording first (click any tile / open `view.php?...&e=<uuid>`)
//      so the LTI launch establishes your Opencast (media.jku.at) session.
//      Then go back to the course page that lists all the tiles.
//   2. Run this in the DevTools console of that course page (or have Claude run
//      it via the Chrome extension), logged in.
//   3. It prints lines of   <name><TAB><mp4_url>   -> save as manifest.tsv,
//      then feed that to transcribe_lectures.sh (default FETCHER=ffmpeg works,
//      the media files on media.jku.at/static are publicly downloadable).
//
// It works by:
//   a) scraping every tile's episode UUID from the `&e=<uuid>` links + its
//      "Recording Lecture NN (DD.MM.YYYY)" heading,
//   b) calling the Opencast Search API  <ENGAGE>/search/episode.json?id=<uuid>
//      (credentialed, cross-origin — CORS + your engage session cookie allow it),
//   c) picking, per episode, the SMALLEST progressive MP4 track that has an audio
//      stream (audio is all the transcriber needs; the lecturer's mic is muxed
//      into every track, so the low-res presentation stream is enough -> least
//      to download).
//
// If a fetch comes back as non-JSON (an SSO/login page), your engage session
// isn't established yet — open one recording (step 1) and re-run.

(async () => {
  const ENGAGE = 'https://media.jku.at';   // JKU Opencast engage host (see README)

  const slug = s => s.replace(/[^\w]+/g, '_').replace(/^_+|_+$/g, '').slice(0, 60);

  // (a) scrape (uuid, index, date) from the tiles
  const seen = new Set();
  const eps = [];
  for (const a of document.querySelectorAll('a[href*="view.php"]')) {
    let u; try { u = new URL(a.href); } catch (e) { continue; }
    const id = u.searchParams.get('e');
    if (!id || seen.has(id)) continue;
    seen.add(id);
    const card = a.closest('.episode, li, div, article, section') || a;
    const text = (card.innerText || '').trim();
    const mNum = text.match(/Lecture\s+(\d+)/i);
    const mDate = text.match(/(\d{2})\.(\d{2})\.(\d{4})/);
    eps.push({
      id,
      idx: mNum ? mNum[1].padStart(2, '0') : null,
      date: mDate ? `${mDate[3]}-${mDate[2]}-${mDate[1]}` : null,
    });
  }
  if (!eps.length) { console.error('No opencast episode tiles found on this page.'); return ''; }

  // pick the smallest progressive MP4 track that carries audio
  const pickTrack = mp => {
    let tracks = mp && mp.media && mp.media.track;
    if (!tracks) return null;
    if (!Array.isArray(tracks)) tracks = [tracks];
    const cand = tracks.filter(t =>
      t.mimetype === 'video/mp4' && t.audio &&
      (!t.transport || t.transport === 'progressive') && /^https?:/.test(t.url || ''));
    if (!cand.length) return null;
    const size = t => ((t.video && t.video.bitrate) || 0) + ((t.audio && t.audio.bitrate) || 0);
    cand.sort((a, b) => size(a) - size(b));
    return cand[0];
  };

  // (b)+(c) resolve each episode via the Search API
  const out = [];
  let fallbackIdx = 0;
  for (const ep of eps) {
    fallbackIdx++;
    const idx = ep.idx || String(fallbackIdx).padStart(2, '0');
    try {
      const r = await fetch(`${ENGAGE}/search/episode.json?id=${ep.id}`,
        { credentials: 'include', headers: { Accept: 'application/json' } });
      const ct = r.headers.get('content-type') || '';
      if (!ct.includes('json')) {
        out.push({ idx, line: `${idx}_lecture\tNEEDS_ENGAGE_SESSION_open_one_recording_first (HTTP ${r.status})` });
        continue;
      }
      const j = await r.json();
      let res = (j['search-results'] || j).result;
      if (Array.isArray(res)) res = res[0];
      const mp = res && res.mediapackage;
      const tr = pickTrack(mp);
      const title = (mp && mp.title) || `Lecture ${idx}`;
      const mNum = title.match(/Lecture\s+(\d+)/i);
      const nn = mNum ? mNum[1].padStart(2, '0') : idx;
      const name = `${nn}_${slug((title.replace(/Recording\s+Lecture\s+\d+\s*/i, '').trim()) || ('Lecture_' + (ep.date || nn)))}`;
      out.push({ idx: nn, line: `${name}\t${tr ? tr.url : 'NO_MP4_TRACK_FOUND'}` });
    } catch (err) {
      out.push({ idx, line: `${idx}_lecture\tERROR_${err.message}` });
    }
  }

  out.sort((a, b) => a.idx.localeCompare(b.idx));
  const tsv = out.map(o => o.line).join('\n');
  console.log('\n===== manifest.tsv =====\n' + tsv + '\n========================');
  return tsv;
})();
