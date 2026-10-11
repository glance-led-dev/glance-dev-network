# Tempest Compact

Live readings from your own WeatherFlow Tempest station, a six-hour outlook, and any
National Weather Service watches, warnings or advisories in force where the station
stands. Three pages on a single 64x32 panel.

You need a personal WeatherFlow API token. Everything else — your station, its
coordinates, its name — is read from your account, so for most people the token is the
only thing to fill in. Without one the panel shows a sample reading rather than
sitting blank, and the alerts page tells you what to do.

## Setting it up

1. Sign in at **<https://tempestwx.com>** with the account your station is on.
2. Go to **Settings → Data Authorizations → Create Token**.
3. Paste it into **Tempest API token**. It is stored encrypted.

## Settings

| setting | what it is |
|---|---|
| **Tempest API token** *(credential)* | Personal token from tempestwx.com — Settings, then Data Authorizations, then Create Token. |
| **Units** | `imperial` shows Fahrenheit, inches and mph; `metric` shows Celsius, millimetres and km/h. The colour coding follows the actual conditions, not the numbers on screen, so it means the same thing either way. |
| **Pressure** | Chosen separately from the other units, since plenty of people want Fahrenheit alongside millibars. `mb` shows 1016, `inhg` shows 30.00. |
| **Wind arrow points** | `from` aims the arrow back along the bearing the wind is coming from, the way a weather vane sits. `to` aims it the way the wind is blowing. |

## The pages

**Now** — the temperature is the hero, coloured on a continuous ramp from deep blue at
-20F through to red at 105F, so the colour alone tells you roughly where you are before
you read the digits. To its right, dew point over barometric pressure, each with a
trend arrow. Below, today's rainfall and yesterday's; the raindrop brightens while
precipitation is actually falling and stays dull otherwise. The bottom row is wind
direction, speed and gust, or `CALM` when there is nothing to report.

Dew point is banded rather than ramped, because the thresholds are the point:
**below 40 white, 40-50 green, 50-60 yellow, 60-70 orange, above 70 red.** That last
band is the one you feel.

**Outlook** — conditions now, six hours out, and tomorrow: an icon, the chance of
precipitation, and the temperature for each. Tomorrow's figure is the forecast high.

**Alerts** — active NWS alerts for the station's coordinates, coloured to the NWS
standard: **warning red, watch yellow, advisory blue.** One alert gets a full banner
with the hazard and its expiry; several are stacked so every one stays visible at
once, most urgent first. With nothing active the page is a green all-clear naming the
station, which is a state worth seeing rather than a blank screen. Outside the United
States it says so plainly instead of pretending to cover you.

## How the dew point trend is worked out

The arrow beside the dew point is a rate, not a comparison of two instants. The app
pulls three hours of raw observations from the station's own device, converts each to
a dew point using the Magnus approximation without logarithms — Starlark has no `log`
— and averages the ten oldest and the ten newest readings. The difference between
those two averages, divided by the hours between them, gives degrees per hour. The
arrow appears only past 0.7F per hour in either direction, and no arrow is drawn at
all when the station has not reported enough history to be sure.

Averaging both ends is what stops the arrow flickering between renders when the dew
point hovers on a threshold. The dew point itself is approximate — accurate to about a
degree above 50% relative humidity, less so in very dry air — because it is derived
from temperature and humidity rather than measured directly.

## Notes

- The app reads one station: the lowest station id on the account the token belongs
  to. A WeatherFlow token is issued per account rather than per station, so an account
  with more than one station cannot point this app at a different one. Almost nobody
  has more than one, and a setting that picked a station by its position in the API's
  list turned out to swap stations on its own whenever that list came back in a
  different order — so the app now makes one stable choice instead of offering an
  unreliable one.
- Everything on the Now and Outlook pages comes from WeatherFlow's `better_forecast`
  endpoint plus your station's raw device observations. Alerts come from
  `api.weather.gov`, which covers the United States only.
- The panel's clock is the station's own observation timestamp, never the renderer's,
  so two renders of the same reading always agree.
- Nothing is stored anywhere. The token is used to read your station and nothing else.
- When something is wrong the panel says so in words rather than a status code —
  `BAD TOKEN` / `WRONG OR OLD`, `NO STATIONS` / `NONE ON KEY`, `NO READINGS` /
  `IS IT ON?`, `WF IS DOWN` / `NOT YOUR END` — two lines, what happened and what to
  do about it.
- A missing reading is shown as missing. The panel will not print a confident `0`
  because the station dropped out.
