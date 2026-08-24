# CinemaBoard Troubleshooting

## Setup page says `ADD TMDB API KEY`

Add your TMDB API key in the GLANCE app configuration for CinemaBoard. The manifest input is `TMDB API key` and is stored using GDN's encrypted `api-key` input type.

## `TMDB KEY REJECTED`

TMDB returned HTTP 401. Check that you entered the v3 API key from <https://www.themoviedb.org/settings/api>. Do not paste a password. If you regenerated the key, update the CinemaBoard app configuration.

## `TMDB RATE LIMITED`

TMDB returned HTTP 429. CinemaBoard refreshes every 6 hours and caches TMDB responses for 6 hours, so this should be rare. Wait and retry, and avoid repeatedly forcing previews with the same key.

## `TMDB HTTP 0` or another HTTP status

HTTP 0 means the request timed out or could not connect. Other codes indicate a TMDB/API/network error. CinemaBoard should continue to render a readable fallback instead of crashing.

## No box-office grosses

This is expected until you configure `Optional box-office JSON URL`. TMDB does not provide current weekend domestic gross rankings. Use a licensed provider and expose the small JSON schema documented in `DATA_SOURCES.md`.

## Box-office page says `BOX OFFICE BAD JSON`

The configured URL did not return valid JSON. It must be public and return JSON, not HTML.

## Box-office page says `NO BOX OFFICE ROWS`

The JSON was valid, but CinemaBoard did not find a `movies`, `results`, `boxoffice`, or top-level array containing title/gross rows.

## Long titles are clipped or shortened

CinemaBoard intentionally truncates long titles with `...` after trying smaller fonts. GDN does not provide animated scrolling text; pages are still images that re-render on the refresh interval.

## A disabled screen still shows content

GDN page lists are static. CinemaBoard cannot remove a page from the rotation at runtime, so disabled pages render the first enabled screen rather than showing blank content.

## Validation fails

Run:

```bash
source .venv-gdn/bin/activate  # if you used the local venv in this workspace
gdn validate apps/cinemaboard
gdn check apps/cinemaboard
```

Common causes:

- adding a manifest input but not reading it in `app.star`,
- using more than 8 pages,
- using an API-key input key with `_` or `-`,
- lowercase text not drawing because GDN bitmap fonts are uppercase-oriented.

## Region looks wrong

CinemaBoard supports `US`, `CA`, `GB`, and `AU` in the manifest. TMDB region behavior depends on TMDB's theatrical release data for each country.
