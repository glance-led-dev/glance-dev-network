# The Basement Cinema

A **NOW SHOWING** marquee for any home theater, built for SCROLL 384×32.

Point it at your public **Letterboxd** account and the panel becomes your
theater's marquee: the last film you logged is tonight's feature, and a
showcase strip plays your recent watches, your profile favorites, or any public
list. No Letterboxd account? It runs on its built-in library of 512 films.

## Screens

The app plays three pages in order.

| Page | What it shows |
|---|---|
| **Marquee** | The house sign: a lit-bulb frame, popcorn tubs at each wing, and *your* cinema name on a red banner. |
| **Now Showing** | Tonight's feature, drawn large: poster, title, MPAA certificate, director, year, runtime and your star rating. This is always your most recently logged Letterboxd film. |
| **Showcase** | A three-up strip of film tiles from the source you pick below. It shows the next three films every refresh, so a long set comes all the way around. |

### Showcase options

| Option | Plays |
|---|---|
| **Recent watches** *(default)* | Your Letterboxd diary, newest first — up to 24 films. |
| **Favorites** | The four films pinned to your Letterboxd profile. Change them on Letterboxd and the strip follows. |
| **Custom list** | Any public Letterboxd list, in rank order, shown under the list's own name. |

## Make it yours

| Setting | What it does |
|---|---|
| **Cinema name** | The name on the marquee banner — *THE BASEMENT CINEMA*, *THE BIJOU*, *THE REC ROOM ROXY*. Shown in caps and scaled to fit. |
| **Letterboxd username** | Your public Letterboxd username. Drives *Now Showing* and the *Showcase*. Leave it blank to run on the built-in library. |
| **Showcase** | Recent watches, Favorites or Custom list (above). |
| **List slug** | Custom list only: the last part of the list's URL. `letterboxd.com/<username>/list/top-10/` → `top-10`. |

No API key, no sign-in. Everything read is a public Letterboxd page.

## What every film shows

| Attribute | Source |
|---|---|
| Poster | Bundled 21×32 art, conditioned for the panel |
| Title and year | Letterboxd (live) or the library |
| Runtime | TMDB, via the library |
| Director | TMDB, via the library |
| MPAA certificate (G · PG · PG-13 · R · NC-17 · NR) | TMDB US theatrical release |
| Your star rating | Your Letterboxd diary, half-star precision |

## The film library

**512 well-known films, 1944 to 2026** — from *It's a Wonderful Life*,
*Rear Window* and *The Godfather* through the 80s and 90s canon to this year's
releases, with the 2000s and 2010s most heavily represented. Every film carries a poster, runtime and director; 508 of
512 carry an MPAA certificate (the rest never had a US theatrical release).

A film you log that *isn't* in the library still shows: it plays on a film-reel
tile with its live title and year. The library is what gives a film its poster
and full metadata.

## Refresh and network use

`refresh: 900` — the panel re-renders every **15 minutes**, in line with the
Glance team's guidance for data that doesn't change minute to minute. A
Letterboxd diary changes a few times a week at most.

Each render makes at most two Letterboxd requests, each cached for 15 minutes.
Posters are bundled, so there is no image fetching at render time.

## When something's missing

- **No username** — the marquee runs on the library: a different feature each
  day and the library's opening four in the showcase, with the rail dimmed.
- **Letterboxd unreachable** — same fallback. A marquee should never go dark.
- **Username not found** — the one problem a viewer can fix, so it gets a card
  that says so.

## Credits

Film metadata: this product uses the TMDB API but is not endorsed or certified
by TMDB. Not affiliated with Letterboxd. The drawn fallback tiles are original
pixel art, not reproductions of any film's poster, logo or characters.
