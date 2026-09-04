# NASCAR - Broadcast Live

A broadcast-style live leaderboard for the NASCAR Cup, Xfinity (O'Reilly Auto
Parts), and Craftsman Truck series, on a 384px panel.

Unlike the old single-page build that faked a scroll off the wall clock, this is
a real page rotation — the panel requests one render per page, in order:

1. **logo** — the series wordmark.
2. **event** — race name, track, and session; plus flag / lap / stage while the
   race is running. Between sessions this is the next-race card.
3. **track** — the track shape, big.
4. **board1–board5 + feed1–feed2** — seven "flex" slots that fill themselves
   from the current state so nothing is ever blank:
   - **Live race:** the full running order a screen at a time (car #, driver,
     gap to leader, manufacturer, playoff badge), then a **laps-led** board and
     a **pit-stop** board (best green-flag stop, stop count).
   - **Practice / qualifying:** the timing order, then **fastest-lap** and
     **biggest-movers** boards.
   - **Between sessions:** the next-race card, the rest of the schedule (next
     four races in your time zone), and the last race's result (top five).

## Data

NASCAR's public Content Feed CDN (`cf.nascar.com`) — `race_list_basic` for the
schedule and the per-race `live-feed` for everything in-session. Laps led, pit
stops, starting positions and best-lap speeds all come off that one feed, so
there are no extra endpoints and no API key.

## Configuration

- **Series** — Cup, O'Reilly (Xfinity), or Trucks.
- **Time zone** — race dates/times are shown in this zone (NASCAR publishes its
  schedule in US Eastern).
- **Next-race date/time color** — color of the date/time text on the next-race
  card.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
