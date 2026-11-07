# Sleeper Matchup Tracker

Your Sleeper fantasy matchups across two leagues, plus live Patriots and
Vikings scores — on a 64x32 Glance panel. No API keys: Sleeper and ESPN are
both keyless.

## Pages (8, rotating)

**Per league** (tagged `TPL` / `LHL` in gold so you always know which league
you're looking at):

- **Matchup** — pre-kickoff: records and who you're up against. Live/final:
  your score vs your opponent's, color-coded by who's winning.
- **Top Plays** — your 3 highest scorers; anyone at **4+ points glows
  orange**. Your lowest starter (under 10 pts) gets a red flag row: the bust.

**Boards** — both leagues' standings side by side (top 3 + your row, gold).

**NFL:**

- **Patriots / Vikings** — live score, game status (`SUN 4:25P`, `3rd 4:12`,
  `FINAL`), and the top pass/rush/receiving stat leader rotating every 20 s
  (pre-game these are season leaders; live/final they're game stats).
- **Divisions** — AFC East + NFC North side by side; NE / MIN in gold.

## Inputs

- `sleeperuser` — your Sleeper username (default `Probrum`).
- `tplleague` — first league ID (default: The Perfectly League).
- `lhlleague` — second league ID (default: Love Hate League).

## Data & refresh

- Panel re-renders every 120 s. Sleeper matchups cache 120 s, ESPN
  scoreboard 90 s, standings/rosters 1 h, users/player names 24 h.
- Each page stays inside the 8-uncached-requests-per-render ceiling.

## Known limits

- Sleeper has no projections endpoint, so "bust" = your lowest-scoring
  starter, not actual-vs-projection.
- "4+ points" is a highlight on the Top Plays page, not a push alert —
  the panel refreshes every 2 minutes while games are live.
