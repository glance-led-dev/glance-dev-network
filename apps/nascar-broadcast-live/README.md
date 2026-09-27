# NASCAR - Broadcast Live

A broadcast-style live leaderboard for the NASCAR Cup, Xfinity (O'Reilly Auto
Parts), and Craftsman Truck series, built for a 192px panel.

A real page rotation — the panel requests one render per page, in order. Every
page has one fixed job and a permanent label; the manifest page list is fixed,
so each page reads in both a live session and between sessions:

| # | page | live session | between sessions |
|---|------|--------------|------------------|
| 1 | `logo` | series wordmark · LIVE | series wordmark · NEXT UP |
| 2 | `event` | track outline · race · session · flag / lap / stage / cautions / lead changes | NEXT RACE card |
| 3 | `order1` | ORDER P1–8 (car #, driver, gap, playoff badge) | LAST RACE — the full finishing order, a page at a time |
| 4–7 | `order2`–`order5` | ORDER P9–40 | LAST RACE — continued |
| 8 | `movers` | the biggest gainers and losers vs. their starting spot | SCHEDULE — the next races |

The order board is 2 columns × 4 rows on a 192 panel and 3 × 4 on 384/640.

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

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
