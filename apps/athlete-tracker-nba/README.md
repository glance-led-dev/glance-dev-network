# Athlete Tracker (NBA)

Pick any NBA player and the panel draws them in a basketball jersey in their team's own
colours with their number on it (or the team crest, for a player who hasn't been
given a number yet). Beside it are their bio line and stats. Two pages on a
128x32 panel.

## Settings

| setting | what it is |
|---|---|
| **Player** | The top 750 NBA players by ESPN fantasy ownership, A-Z. Two players with the same name get their team added. Default: Nikola Jokic. |

## The pages

**Season**: the team logo top-right, position, height and weight, then the season
line: one big stat with two smaller ones beside it (points, rebounds and assists per game). The tag beside the big
stat says `SZN` for this season, or the season it's from (`25-26`) while the new one
hasn't started. An injured player gets their status in place of height and weight:
`IR · ANKLE` in red when they're out (IR, OUT, IL, suspended), amber for `QUES`,
`DOUBT` or `DTD`.

**Game**: the opponent's logo with `@` (away) or `VS` (home). Then one of:

- **LIVE** (red): the game clock, the score and the player's line so far.
- **PROJ** (blue): the date and time (Eastern) of the next game and a projection
  for it (ESPN's season projection divided by projected games). Preseason games are marked `PRE`. A questionable player shows
  `QUES` in amber in place of `PROJ`.
- **Injured**: a player who's out shows `IR` / `OUT` / `IL15` in red with the injury
  and ESPN's expected return date (`BACK 11/1`) instead of a projection.
- **FINAL**: for a few hours after the game.
- **DNP**: when the player is not on the game roster (or their injury tag).
- `NO NEXT GAME`: nothing on the schedule, with the season line.

## Data

All from ESPN: the athlete and overview endpoints, the core per-game stats endpoint
(about 20 KB) while a game is live, and the ESPN fantasy API for projections. Two or
three requests per refresh, every 5 minutes. If ESPN can't be reached the panel says
so instead of going blank.

## Trades and new players

Team, number, colours, injury status and schedule are read live from ESPN on every
refresh, so a traded player switches teams on their own. The player list itself is
refreshed weekly by a GitHub Action (`.github/workflows/athlete-tracker-players.yml`
running `tools/athlete_tracker_players.py`), which opens a PR when the top 750
changes. A player who drops out of the top 750 leaves the dropdown but keeps working
for panels already set to them.

Team logos are hand-drawn pixel art or ESPN's dark-background marks reduced to each
team's colours. Team marks belong to their owners.
