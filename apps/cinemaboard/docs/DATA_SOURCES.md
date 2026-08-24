# CinemaBoard Data Sources

Research date: 2026-08-24. Official GDN docs were read from <https://glance-led.dev/>. TMDB docs were read from <https://developer.themoviedb.org/> and TMDB attribution information from <https://www.themoviedb.org/about/logos-attribution>.

## Selected providers

CinemaBoard uses TMDB for movie metadata and TMDB vote averages. It does **not** label TMDB ratings as IMDb, Rotten Tomatoes, or audience scores from another service.

Genuine U.S. weekend box-office grosses are **not** provided by TMDB and no practical free, official, stable, legal weekend-gross API was identified. CinemaBoard therefore implements box-office as an optional provider interface instead of scraping a website or tightly coupling to an unofficial API.

## Comparison

| Provider | Movie Data | Box Office | Cost | Auth | Selected? |
| -------- | ---------- | ---------- | ---- | ---- | --------- |
| TMDB API v3 | Now playing, upcoming, release dates, genres, popularity, vote averages | Movie detail has budget/revenue for some titles, but not weekly/weekend domestic grosses or rankings | Free for typical personal/API use under TMDB terms | API key query parameter or Bearer token | Yes for movie metadata and TMDB ratings |
| IMDb / Box Office Mojo | Excellent editorial/source data on box office via website | Weekend grosses and domestic totals on site | No public self-serve official API found for this use | N/A for public API | No; no scraper used |
| The Numbers / Nash Information Services OpusData | Professional film and box-office datasets | Strong box-office coverage, including grosses, via licensed data products | Commercial/licensed | Contract/API credentials likely | Future licensed provider candidate |
| Comscore Movies | Industry-standard theatrical measurement | Strong box-office/showtime industry data | Commercial/licensed | Contract credentials | Future licensed provider candidate |
| OMDb API | Title lookup, IMDb-style metadata, selected ratings, some `BoxOffice` totals | Per-title box-office total when available, not current weekend ranking/gross list | Free/paid tiers | API key | Not selected for core app; less suitable than TMDB for current theatrical lists |
| RapidAPI box-office providers | Varies by provider | Some providers advertise box-office data | Free/paid varies | RapidAPI key | Not selected by default because providers vary in legality, freshness, terms, and stability |
| Web scraping Box Office Mojo / The Numbers | Possible technically | Possible technically | Free in dollars | None | Rejected: brittle and may violate terms |

## TMDB endpoints used

- `GET https://api.themoviedb.org/3/movie/now_playing`
- `GET https://api.themoviedb.org/3/movie/upcoming`

CinemaBoard passes:

- `api_key`
- `language`
- `region`
- `page=1`

The current TMDB docs note that Now Playing and Upcoming are discover calls behind the scenes and support `language`, `page`, and `region`.

## TMDB attribution

TMDB states that applications using its data or images are required to properly attribute TMDB as the source. CinemaBoard:

- labels ratings as `TMDB`,
- includes `TMDB` in release/countdown page footer text where space allows,
- documents TMDB as the movie data source here and in the README.

CinemaBoard does not use TMDB images/posters, so no image-logo asset is bundled.

## Optional box-office JSON provider schema

If you have a licensed data source, expose a small public HTTPS JSON endpoint shaped like one of these:

```json
{
  "movies": [
    {"rank": 1, "title": "Movie A", "weekendGross": 58400000},
    {"rank": 2, "title": "Movie B", "weekendGross": "$31.7M"}
  ]
}
```

or:

```json
[
  {"rank": 1, "name": "Movie A", "gross": 58400000}
]
```

Supported gross keys are `weekendGross`, `weekend_gross`, `gross`, or `weekend`. CinemaBoard caches this endpoint for 12 hours.
