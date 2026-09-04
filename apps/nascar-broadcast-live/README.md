# NASCAR - Broadcast Live

A broadcast-style live leaderboard for the NASCAR Cup, Xfinity (O'Reilly Auto
Parts), and Craftsman Truck series, on a 384px panel.

A real page rotation — the panel requests one render per page, in order. Every
page has one fixed job and a permanent label; the manifest page list is fixed,
so each page reads in both a live session and between sessions:

| # | page | live session | between sessions |
|---|------|--------------|------------------|
| 1 | `logo` | series wordmark · LIVE | series wordmark · NEXT UP |
| 2 | `event` | race · session · flag / lap / stage / cautions / lead changes · track shape | NEXT RACE card |
| 3 | `order1` | ORDER P1–12 (car #, driver, gap, playoff badge) | LAST RACE — the full finishing order, 12 across the page |
| 4 | `order2` | ORDER P13–24 | SCHEDULE — the next races |
| 5 | `order3` | ORDER P25–36 | SCHEDULE — continued |
| 6 | `order4` | ORDER P37–40 | SCHEDULE — continued |
| 7 | `movers` | the six biggest gainers and six biggest losers vs. their starting spot | SEASON — race N of the schedule, playoff round, next race |

Lapped runners show `-N LAP(S)` in the live order and the last-race result.

## Data

NASCAR's public Content Feed CDN (`cf.nascar.com`) — `race_list_basic` for the
schedule and the per-race `live-feed` for everything in-session (running order,
gaps, starting positions, stage, caution and lead-change counts). No API key.
NASCAR's feed has no race-control / penalty message stream the way F1's does.

## Configuration

- **Series** — Cup, O'Reilly (Xfinity), or Trucks.
- **Time zone** — race dates/times are shown in this zone (NASCAR publishes its
  schedule in US Eastern).
- **Next-race date/time color** — color of the date/time text on the cards.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
