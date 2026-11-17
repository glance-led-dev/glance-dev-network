# NASCAR - Broadcast Live

A broadcast-style live leaderboard for the NASCAR Cup, Xfinity (O'Reilly Auto
Parts), and Craftsman Truck series, on a 384px panel.

A real page rotation — the panel requests one render per page, in order. Every
page has one fixed job and a permanent label; the manifest page list is fixed,
so each page reads in both a live session and between sessions:

| # | page | live session | between sessions |
|---|------|--------------|------------------|
| 1 | `logo` | series wordmark · LIVE (FINAL once it ends) · each stage winner behind a green-and-white checkered flag | series wordmark · NEXT UP |
| 2 | `event` | race · session · flag / lap / stage / cautions / lead changes · track shape | NEXT RACE card — race · track · local date/time and TV network · the last winner there · track shape |
| 3 | `order1` | ORDER P1–12 (car #, driver, gap, playoff badge) | LAST RACE — the full finishing order, 12 across the page |
| 4 | `order2` | ORDER P13–24 | SCHEDULE — the next races |
| 5 | `order3` | ORDER P25–36 | SCHEDULE — continued |
| 6 | `order4` | ORDER P37–40 | SCHEDULE — continued |
| 7 | `movers` | the biggest gainers and losers vs. their starting spot | SCHEDULE — the next race and the three after it: date, track, TV network |

### Off-season

Once a season is over (and until the next one's first weekend starts), the
pages switch to:

| page | off-season |
|------|------------|
| `logo` | the series logo, full height |
| `event` | countdown in days to the Daytona opener (DAYTONA 500 with the Duels' date, UNITED RENTALS 300, FRESH FROM FLORIDA 250) |
| `order1` | the series champion: car number in its livery, name in team colours, manufacturer |
| `order2`–`order5`, `movers` | every race of the season (Clash, Duels and All-Star included) and its winner in team colours |

TV networks show in their own colours: NBC with its peacock, FOX blue, USA
red, CW orange, FS1 / FS2 / TNT white.

Lapped runners show `-N LAP(S)` in the live order and the last-race result.
Stage winners carry a small green-and-white checkered flag beside their name,
one per stage won, on the race order and LAST RACE boards.

Once a race weekend's first session starts, the latest session stays on the
panel until the next one begins, so qualifying's order shows until the race
starts. A finished race stays up until 11:59 PM in the chosen time zone, then
the panel moves on to the next race. The panel refreshes every 60 seconds.

## Data

NASCAR's public Content Feed CDN (`cf.nascar.com`) — `race_list_basic` for the
schedule, TV networks and session times, the per-race `live-feed` for
everything in-session (running order, gaps, starting positions, stage, caution
and lead-change counts), the per-race `live-stage-points` for stage winners as
each stage ends, and the per-race `weekend-feed` for past winners. No API key.
NASCAR's feed has no race-control / penalty message stream the way F1's does.

## Configuration

- **Series** — Cup, O'Reilly (Xfinity), or Trucks.
- **Time zone** — race dates/times are shown in this zone (NASCAR publishes its
  schedule in US Eastern), and a finished race holds until midnight here.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
