# Athlete Tracker

Pick an NFL, NBA, NHL or MLB player and the panel draws them in their gear: a
basketball jersey, football helmet, hockey sweater or baseball jersey in the
team's own colours with their number on it. Beside it are their bio line and stats.
Two pages on a 128x32 panel.

## Settings

| setting | what it is |
|---|---|
| **Player** | About 1,000 players, the top 250 per league by ESPN fantasy ownership, shown as `Patrick Mahomes (NFL)`. Two players with the same name in one league get their team added. |

## The pages

**Season**: the team logo top-right, position, height and weight, then the season
line: one big stat with two smaller ones beside it. What the stats are depends on
the position: QB, RB, WR/TE, kicker, NHL skater or goalie, MLB hitter or pitcher.

**Game**: the opponent's logo with `@` (away) or `VS` (home). Then one of:

- **LIVE** (red): the game clock, the score and the player's line so far.
- **PROJ** (blue): the date and time (Eastern) of the next game and a projection for it.
  NFL projections are ESPN's per-game numbers. For the other leagues it is ESPN's
  season projection divided by projected games.
- **FINAL**: for a few hours after the game.
- **DNP**: when the player is not on the game roster.
- `NO NEXT GAME`: nothing on the schedule (for example, the season is over), with the season line.

## Data

All from ESPN: the athlete and overview endpoints, the core per-game stats endpoint
(about 20 KB) while a game is live, and the ESPN fantasy API for projections. That is
two or three requests per refresh, every 5 minutes. If ESPN can't be reached the
panel says so instead of going blank.

## Updating the player list

The dropdown and the ID table in `app.star` are generated. Refresh them at the start
of a season or after a trade deadline:

```
python tools/athlete_tracker_players.py            # top 250 per league
python tools/athlete_tracker_players.py --top 100
```

A player who falls out of the top N leaves the dropdown but keeps their ID entry, so
panels already set to them keep working.

Team logos are ESPN's, reduced to each team's own palette at 19px. Team marks belong
to their owners.
