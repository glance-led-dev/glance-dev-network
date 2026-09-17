# Basement Marquee

A NOW SHOWING board for a home theater, built for SCROLL 384x32.

Everything is driven by a public **Letterboxd** account. *Now Showing* is always
your most recently logged film, drawn large. A mode-driven *Showcase* then scrolls
a **compressed strip** of three film tiles from one of three sources. Big card or
tile, every film shows the same content — poster, title, `year · runtime ·
director`, and the owner's star rating. Films in the curated pack carry a bundled
poster (and, where known, runtime + director); anything else rides the filmstrip
reel with whatever the feed gives.

## Settings

| Input | What it does |
|---|---|
| **Cinema name** | The name on the marquee banner. Shown in caps; scales to fit. Every basement names its cinema differently. |
| **Letterboxd username** | Your public Letterboxd account, e.g. `abartos27`. The newest entry in `letterboxd.com/<user>/rss/` is *Now Showing*. Leave blank to run on the pack alone. |
| **Feature source** | What the *Showcase* scrolls: `RECENT` = your diary, newest first; `FAVORITES` = the four films pinned on your Letterboxd profile; `LIST` = a public Letterboxd list. |
| **List slug** | Used only in `LIST` mode: the last path segment of a list URL, e.g. `letterboxd.com/abartos27/list/top-10/` → `top-10`. The list is shown under its own name. |

No API key is needed. Each source is public and read once every 15 minutes.

## Screens

- **Marquee** — the house splash: a lit-bulb frame, a striped popcorn tub (with
  a sparkle burst) at each wing, and the (configurable) cinema name centered on a
  red banner.
- **Now Showing** — your most recently logged film, drawn as the large highlight.
- **Showcase** — a compressed scroll of three rich film tiles from the chosen
  source, the window advancing by the minute so the whole set comes around:
  `FAVORITES` (your profile's pinned four), a public `LIST` in rank order (shown
  under its name), or the `RECENT` diary newest-first.
- **No data** — the rail goes dim and a pack pick takes the slot. A marquee
  should never go dark, so this is a graceful fallback rather than an error card.
- **Bad username** — the one failure a viewer can actually fix, so it gets a
  card that says so.

`FAVORITES` reads the `#favourites` grid on `letterboxd.com/<user>/`; change your
pinned favorites on Letterboxd and the strip follows.

## Poster art

Each film in `CANON` has a **bundled 21x32 poster PNG**. A drawn fallback tile
is resolved separately via `art_for(slug)` (`ART_BY_SLUG` in `app.star`); if the
poster file is missing, that tile renders instead, so a half-finished pack never
breaks a render. Films without bespoke art fall back to the filmstrip reel.

This is the pattern the official `now-playing` app uses. GDN draws **bundled**
PNGs — there is no render-time image fetch — so a poster pack is a snapshot you
refresh periodically, not a live lookup.

Posters are the film's **portrait theatrical poster**, taken from the JSON-LD
`image` on its Letterboxd page (*not* the `og:image`, which is a landscape
share card — baking that made posters look like screenshots). The tool bumps the
source to a large crop, steps the LANCZOS downscale down in halves, and lifts
contrast/saturation/sharpness so a 21×32 tile still reads as a poster.

### Refreshing the pack

`tools/refresh_pack.py` builds the pack for you: it reads a public Letterboxd
diary, crops each film's poster to 21x32, and rewrites the pack data (`CANON` /
`CANON_ORDER` / `BY_TITLE` / `POSTERS`, between the `# >>> PACK` markers in
`app.star`) plus the manifest `assets:` list.

**No API key needed** — the Letterboxd RSS carries each film's poster image URL
inline, so the pack is built straight from the diary:

```bash
source .venv/bin/activate          # Pillow + requests live here
python3 tools/refresh_pack.py apps/home-cinema-marquee --user abartos27
gdn validate apps/home-cinema-marquee
```

With **no `--user` and no key**, it re-pulls every canon film's portrait poster
from its Letterboxd page — the way to re-bake the whole pack's art after a
pipeline change, without touching the film set or their runtime/director:

```bash
python3 tools/refresh_pack.py apps/home-cinema-marquee
```

Recent films get *added* to the curated canon; `--replace` rebuilds it purely
from recent watches, `--limit N` caps how many to pull (default 30, so a full
list bakes without being cut off), `--no-overwrite` keeps existing PNGs,
`--dry-run` reports without writing. A keyless re-bake keeps any runtime/director
a film already had in the pack, so baking a list won't wipe curated metadata.

**Baking a list.** `--list <slug>` (with `--user`) bakes a public list in rank
order instead of the diary — the ranked films land at the front of `CANON_ORDER`,
so the Canon's top 4 becomes the list's top 4:

```bash
python3 tools/refresh_pack.py apps/home-cinema-marquee --user abartos27 --list top-10
```

Lists have no RSS, so the tool reads the list page (each film carries a
`data-item-slug`) and pulls each film's poster from its page's OpenGraph tags. It
sends a browser User-Agent and paces the requests, since Letterboxd rate-limits
(HTTP 429) a rapid bare-`requests` crawl. Keyless, this bakes poster + year;
runtime + director need the TMDB key below.

**Optional TMDB enrichment.** Set `TMDB_API_KEY` (free at
themoviedb.org/settings/api) and the tool also fills in each film's **runtime**
and **director** — which turns the *now showing* hero from a star rating into a
runtime. The RSS carries the TMDB id, so no search is needed. With no `--user`
*and* a key set, it re-fetches posters for the films already in the canon. The
key is read from the environment only and never written to disk. This product
uses the TMDB API but is not endorsed or certified by TMDB.

### Adding a film or poster by hand

The `# >>> PACK` block is plain literals — edit it directly. A film is a `CANON`
entry keyed by its Letterboxd slug (the last segment of the film's
`letterboxd.com/<user>/film/<slug>/` URL) with `[title, year, runtime, director,
poster.png, rating10]` (`rating10` is a 0–10 half-star scale, `0` = unrated);
add the same slug to `CANON_ORDER` and the poster filename to both
`POSTERS` and the manifest `assets:` list (the renderer rejects an undeclared
asset, and Starlark cannot check whether a file exists). For bespoke pixel art,
add a drawn tile and map it in `ART_BY_SLUG`.

The drawn tiles that ship here are original pixel art, one motif per film — they
are not reproductions of the films' posters, logos or characters.
