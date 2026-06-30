// Extract a transcribe manifest from a JKU/Moodle course page.
//
// HOW TO USE:
//   1. Open the Moodle course page that lists the lectures (the page with the
//      "StreamURL" activities), logged in.
//   2. Open DevTools console (or have Claude run it via the Chrome extension) and paste this.
//   3. It prints lines of   <name><TAB><mp4_url>   -> save as manifest.tsv
//
// It finds every `mod/streamurl` activity, opens each one (using your session
// cookies), and pulls the underlying direct media URL (mp4/m4a/etc).
//
// NOTE: JKU lecture recordings are `streamurl` activities pointing at plain MP4
// files on download.jku.at (no login needed to download the mp4 itself, only to
// read the Moodle page). Other Moodle setups may embed players (Panopto/Kaltura/
// Opencast) - then you'd need yt-dlp on the player URL instead.

(async () => {
  const acts = [...document.querySelectorAll('li.activity, div.activity')]
    .map(li => {
      const a = li.querySelector('a[href]');
      const cls = [...li.classList].find(c => c.startsWith('modtype_')) || '';
      const name = li.querySelector('.instancename, .activityname');
      return { type: cls.replace('modtype_', ''),
               name: name ? name.innerText.trim().replace(/\s+/g, ' ') : '',
               href: a ? a.href : '' };
    })
    .filter(x => x.type === 'streamurl' && x.href);

  const clean = s => s.replace(/ StreamURL$/, '')
                      .replace(/[^\w]+/g, '_').replace(/^_+|_+$/g, '').slice(0, 60);

  const out = [];
  let i = 0;
  for (const x of acts) {
    i++;
    const idx = String(i).padStart(2, '0');
    try {
      const r = await fetch(x.href, { credentials: 'include' });
      const html = await r.text();
      const m = html.match(/https?:\/\/[^"'\s]+\.(?:mp4|m4a|mp3|webm|mov|m4v|m3u8)(?:\?[^"'\s]*)?/i);
      out.push(`${idx}_${clean(x.name)}\t${m ? m[0] : 'NO_MEDIA_FOUND'}`);
    } catch (e) {
      out.push(`${idx}_${clean(x.name)}\tERROR_${e.message}`);
    }
  }
  const tsv = out.join('\n');
  console.log('\n===== manifest.tsv =====\n' + tsv + '\n========================');
  return tsv;
})();
