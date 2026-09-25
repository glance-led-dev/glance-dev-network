# Fantasy Injury Report

This week's NFL injury report, ranked by fantasy impact. The centre of the panel is an X-ray lightbox: a full-body skeleton lies across the film, and the bone where the player is hurt glows with a halo round it, red for OUT or IR, orange for DOUBTFUL and amber for QUESTIONABLE. The film's bottom edge is labelled like a radiograph, with the player's name on the left and the body part on the right, and the club logo sits in the film's corner. To the left, the status is a rubber stamp with the position (and a white `MNF`, `TNF` or `SAT` pill for a game not on a Sunday) under it. To the right is the number that matters. An undisclosed injury puts a "?" on the film.

## Pages

- **gametime**: the decisions you still have to make. QUESTIONABLE and DOUBTFUL players, ranked by this week's projected points (`PROJ`), with the opponent under the number. Once a player's game day has passed he drops off, so on Sunday night only the Monday night calls are left.
- **out**: the holes in lineups. Players ruled OUT this week come first, then IR and PUP moves from the last 14 days, ranked by points per game this season (`PPG`). The injury note (`SURGERY`, `FRACTURE`, `SPRAIN`) sits under the number when Sleeper has one. Only players who have played this season are listed.

Both pages list players worth at least 5 points (projected, or per game), up to 8 per page. Each page shows one player at a time and moves to the next every two minutes, with an n/N counter under the stamp. The film's caption names the body part. For an undisclosed injury it shows how fresh the news is instead (`UPD 3H AGO`).

## Settings

- **Position**: ALL, QB, RB, WR or TE.
- **Scoring**: PPR, HALF PPR or STANDARD. This sets both the ranking and the number shown. HALF and STD are tagged above the number when there is room.

## Data

The data comes from Sleeper's public API. No key is needed.

- NFL week: `api.sleeper.app/v1/state/nfl`, cached for 1 hour.
- Projections: `api.sleeper.com/projections/nfl/{season}/{week}`, one request for WR, one for RB and one for QB and TE together, cached for 30 minutes.
- Season stats: `api.sleeper.com/stats/nfl/{season}`, split the same way, cached for 1 hour.

Each page makes at most 4 requests, and both pages together at most 7, inside the 8 a render may make even when every cache has expired. Designations that are not injuries (coach's decision, personal, rest) are skipped. In the playoffs the week reads as the round (`WILDCARD`, `DIVISION`, `CONF RD`, `SB LXI`). In the preseason and offseason the panel says so and names week 1 as the return. When there is nobody to show, every bone on the film lights green.
