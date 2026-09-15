# F1 - Broadcast Live

Broadcast-style live timing for Formula 1 on a 384px panel.

A real page rotation — the panel requests one render per page, in order. There
are two rotations off one fixed four-page manifest, one for a live session and
one for between sessions:

| # | between sessions | live session |
|---|------------------|--------------|
| 1 | F1 mark · **NEXT RACE** — grand prix · circuit · local date/time · circuit outline | F1 mark · **LIVE** — grand prix · session · flag / lap / air temp · circuit outline |
| 2 | **LAST RACE** — finishing order P1–8 | **ORDER P1–8** (car #, driver, tyre, gap to leader) |
| 3 | **LAST RACE** — P9–16 | **ORDER P9–16** |
| 4 | **CALENDAR** — the four grands prix after the next | **ORDER P17–22** |

Air temperature on the live `event` page follows the **Temperature unit**
dropdown (°C / °F).

## Data

- **OpenF1** (`api.openf1.org`) — live position, intervals, stints, weather.
  Free, no key. There is no "current session" endpoint, so the app pulls the
  latest session and checks it is actually inside its live window (plus an
  end-of-day grace) before trusting it.
- **Jolpica-Ergast** (`api.jolpi.ca`) — the calendar and the last result.

## Configuration

- **Temperature unit** — °C or °F for the live air-temperature reading.
- **Time zone** — grand prix dates/times are shown in this zone (F1's calendar
  spans every region).
- **Date color** — accent, red, green, blue, white, yellow, magenta or cyan for
  the date/time on the next-race page and the calendar.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
