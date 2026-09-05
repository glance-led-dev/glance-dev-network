# F1 - Broadcast Live

Broadcast-style live timing for Formula 1 on a 384px panel.

A real page rotation — the panel requests one render per page, in order. There
are two rotations off one fixed five-page manifest, one for a live session and
one for between sessions:

| # | between sessions | live session |
|---|------------------|--------------|
| 1 | F1 wordmark · NEXT UP | F1 wordmark · LIVE |
| 2 | **NEXT RACE** — grand prix · circuit · local date/time | **event** — grand prix · session · flag / lap / air temp · circuit |
| 3 | **LAST RACE** — the full finishing order (12 across the page) | **ORDER P1–9** (car #, driver, tyre, gap to leader) |
| 4 | **CALENDAR** — the four grands prix after the next | **ORDER P10–18** |
| 5 | **CALENDAR** — the four after that (the rest that fits) | **ORDER P19–22** (only the cars on track; the rest stays black) |

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
- **Next-race date/time color** — color of the date/time text on the NEXT RACE
  card and the calendar.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
