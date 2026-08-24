# CinemaBoard

CinemaBoard turns a **GLANCE Scroll Premier (8.5 ft)** into a movie-theater marquee: current theatrical movies, upcoming releases, TMDB ratings, release countdowns, a custom theater message, and optional weekend box-office gross data from a licensed provider.

## Screens

- **Weekend Box Office** — shows top weekend grosses if you configure a licensed JSON provider; otherwise displays a clear setup message.
- **Now Playing** — rotates through TMDB theatrical now-playing movies.
- **New Releases** — highlights movies released in roughly the last two weeks.
- **Coming Soon** — shows upcoming theatrical releases.
- **Movie Spotlight** — marquee-style featured movie with film-strip accents.
- **Ratings** — shows TMDB vote average; never mislabels it as IMDb or Rotten Tomatoes.
- **Release Countdown** — counts days to the next dated upcoming movie.
- **Theater Message** — optional custom message, e.g. `MOVIE NIGHT STARTS AT 7:30`.

## Hardware and dimensions

Current GDN docs state:

- height is always **32 px**,
- each Glance module is **64 px** wide,
- chained app canvases are supported up to **384 px**,
- GDN recommends 192 px or smaller for many apps, with content split across pages.

The GLANCE Scroll product page lists **PREMIER - 8.5 ft**. That size corresponds to the six-module maximum, so CinemaBoard uses:

```yaml
width: 384
height: 32
```

The app uses the full Premier canvas because long movie titles benefit from the marquee width while draw operations remain light.

## Requirements

- Python 3.9+
- The GDN SDK/CLI from <https://github.com/glance-led-dev/glance-dev-network>
- A TMDB API key
- Optional: licensed box-office data exposed as a small public JSON endpoint

## API setup

### TMDB key

1. Create/log into a TMDB account: <https://www.themoviedb.org/>
2. Open API settings: <https://www.themoviedb.org/settings/api>
3. Request/copy a **v3 API key**.
4. In the GLANCE app setup for CinemaBoard, paste it into **TMDB API key**.

The manifest uses `app_input_type: api-key`, so Glance stores the key encrypted. Do not hard-code keys in `app.star`.

### Optional box office

TMDB does **not** provide current U.S. weekend box-office gross rankings. If you have a licensed source, configure **Optional box-office JSON URL** with JSON like:

```json
{
  "movies": [
    {"rank": 1, "title": "Movie A", "weekendGross": 58400000},
    {"rank": 2, "title": "Movie B", "weekendGross": "$31.7M"}
  ]
}
```

See `docs/DATA_SOURCES.md` for provider research and schema details.

## Install / preview locally

From this workspace:

```bash
# one-time SDK setup used while building this app
python3 -m venv .venv-gdn
source .venv-gdn/bin/activate
pip install -e /tmp/glance-dev-network   # or your local clone of glance-dev-network

# validate and preview CinemaBoard
gdn validate apps/cinemaboard
gdn check apps/cinemaboard
gdn studio apps/cinemaboard
```

If you are working in a fresh GDN clone instead, copy `apps/cinemaboard` into that clone and run:

```bash
cd glance-dev-network
gdn studio apps/cinemaboard
```

## Build/test commands

```bash
source .venv-gdn/bin/activate
gdn validate apps/cinemaboard
gdn check apps/cinemaboard
gdn build apps/cinemaboard

# render one page with test inputs
gdn render apps/cinemaboard --page 2 --input tmdbapikey=YOUR_TMDB_KEY --out nowplaying.png
```

Validation status at handoff: **PASS** (`gdn validate`, `gdn check`, and `gdn build`).

## Configuration

| Field | Default | Notes |
| ----- | ------- | ----- |
| TMDB API key | blank | Required; encrypted GDN `api-key` input. |
| Region | `US` | Choices: `US`, `CA`, `GB`, `AU`. |
| Language | `en-US` | Choices: `en-US`, `en-CA`, `en-GB`, `en-AU`. |
| Number of movies | `5` | Choices: `3`, `5`, `8`, `10`. |
| Screen toggles | most on | GDN pages are static; disabled pages render the first enabled screen. |
| Theater Message | `WELCOME TO THE CINEMA` | Enable the Theater Message screen to show it. |
| Optional box-office JSON URL | blank | Use only a licensed/public JSON endpoint. |

## Refresh and caching

- Manifest refresh: **21600 seconds** (6 hours).
- TMDB HTTP cache TTL: **21600 seconds**.
- Optional box-office JSON TTL: **43200 seconds**.

Movie listings do not require minute-by-minute polling. These values keep data reasonably fresh and avoid unnecessary API traffic.

## Attribution

CinemaBoard uses TMDB movie data and TMDB vote averages. TMDB requires attribution for applications using its data; CinemaBoard labels ratings as `TMDB`, includes `TMDB` on movie-data pages where space permits, and documents TMDB here. This product uses the TMDB API but is not endorsed or certified by TMDB.

## Publishing / adding to your Glance

For a catalog GDN app, use Glance Dev Studio:

```bash
gdn studio apps/cinemaboard
```

Then click **Validate & Submit**. Studio validates, creates/uses your GitHub fork, pushes the app, and opens a pull request to the public GDN catalog.

The current GDN private-app docs describe a separate image-URL feature in the GLANCE Setup App. That feature accepts public PNG images, not a private Starlark app bundle. For a proper private GDN app, Glance currently asks users to contact Glance support; otherwise publish through the normal GDN review flow.

## Updating

To update CinemaBoard later:

```bash
cd /home/jrodarte/Documents/GLANCE_APPS
# Pull your repo, or copy/replace the latest apps/cinemaboard folder here.

gdn validate apps/cinemaboard
gdn check apps/cinemaboard
gdn studio apps/cinemaboard
```

Your TMDB API key and other settings live in the Glance app configuration, not in source code, so preserve/re-enter those settings when replacing or reinstalling the app. If you publish CinemaBoard through GDN, open Studio and click **Validate & Submit** again to submit the updated app.

## Troubleshooting

See `docs/TROUBLESHOOTING.md` for missing API keys, 401/403/429/500-style errors, malformed JSON, empty movie lists, region issues, and validation failures.

## Future enhancements

The data layer is split so future modules can be added without rewriting display pages:

- Plex Now Playing / Recently Added: add a `PlexProvider` that returns CinemaBoard movie-shaped dictionaries.
- Local theater showtimes: add a `ShowtimesProvider` page/provider if a legal showtimes API is available.
- Awards/Oscars: add another provider/page and reuse existing marquee drawing helpers.
