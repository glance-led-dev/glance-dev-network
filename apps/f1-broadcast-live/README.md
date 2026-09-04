# F1 - Broadcast Live

Broadcast-style live timing for Formula 1 on a 384px panel.

A real page rotation — the panel requests one render per page, in order:

1. **logo** — the F1 wordmark.
2. **event** — grand prix, circuit, and session; plus flag / lap / track
   weather while a session is running. Between sessions this is the next-race
   card.
3. **track** — the circuit shape, big.
4. **board1–board2 + feed1–feed2** — four "flex" slots that fill themselves
   from the current state so nothing is ever blank:
   - **Live session:** the full order a screen at a time (car #, driver, current
     tyre compound, gap to the leader), then a **race-control** feed (penalties,
     investigations, deleted laps, safety car) and, during a race, a
     **pit-stop** board (best stop time per driver).
   - **Between sessions:** the next-race card, the rest of the calendar (next
     three grands prix in your time zone), and the last race's podium.

## Data

- **OpenF1** (`api.openf1.org`) — live position, intervals, stints, weather,
  race control and pit stops. Free, no key. There is no "current session"
  endpoint, so the app pulls the latest session and checks it is actually
  inside its live window (plus an end-of-day grace) before trusting it.
- **Jolpica-Ergast** (`api.jolpi.ca`) — the schedule and the last result.

## Configuration

- **Temperature unit** — °C or °F for the live track-temperature reading.
- **Time zone** — grand prix dates/times are shown in this zone (F1's calendar
  spans every region).
- **Next-race date/time color** — color of the date/time text on the next-race
  card.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
