# Tempest Weather

Live conditions from your own WeatherFlow Tempest station.

Ships as a pair: **`tempest-weather`** (128x32) and **`tempest-weather-scroll`** (192x32). Same app, different panel width — set
whichever one matches your hardware; the settings below are identical.

Pages: `current`, `conditions`, `wind`, `rainfall`, `lightning`, `lightning2`, `uv`, `forecast`

## Setting it up

1. This reads **your** station, so you need a Tempest of your own.
2. Sign in at **<https://tempestwx.com>**.
3. Go to **Settings → Data Authorizations** and create a personal token.
4. Paste it into **Tempest API token**.
5. Set **Sensor elevation above sea level (ft)** to your ground elevation plus mounting height — 14.4 ft of ground plus a 20 ft pole is `34.4`.

## Settings

| setting | what it is |
|---|---|
| **Tempest API token (tempestwx.com > Settings > Data Authorizations)** *(credential)* | — |
| **Sensor elevation above sea level (ft)** | Ground elevation plus mounting height (e.g. 14.4 ft ground + 20 ft pole = 34.4). Leave 0 to show raw station pressure instead of a sea-level-corrected value. |

## Notes

- Leave elevation at `0` and the panel shows raw station pressure instead of a sea-level-corrected value. Neither is wrong, but only the corrected one is comparable to a forecast.
- The forecast page also uses the National Weather Service, which needs no key.

---

Settings ride a colon-separated render descriptor, so **a value containing `:` is cut
at the first colon before the app sees it** — which is why URLs are entered without
their scheme, or split into parts. See [CONTRIBUTING.md](../../CONTRIBUTING.md).
