# Fantasy Weekly Projections

This week's start-'em board: the top projected fantasy players at each position, one per frame, with the matchup drawn as two team logos and the number standing on a patch of turf.

Each card shows:

- the player's club logo and a stripe in the position's colour
- **projected points** (the hero) on a field band with yard lines, under `PPR PROJ` / `HALF PROJ` / `STD PROJ`
- the verdict against the player's season average: a green up-arrow `AVG 17.1` when this week projects above it, an amber down-arrow when below
- once the game is over, `FINAL` with the actual points on the turf, the real stat line, and the projection underneath (arrowed up if he beat it)
- the rank (`#1 RB`, or `T1` on a tie), an injury pill when Sleeper lists one (Q, D, OUT, IR, PUP, SUS) and a tier: a star **STUD**, a tick **START** or a diamond **FLEX**, sized to a 12-team league
- first name over surname (city over nickname for a defense; San Francisco, Philadelphia, Jacksonville and Indianapolis are shortened)
- the projected stat line behind the number, such as `274 PASS YD 1.7 TD` or `99 YD 4.3 REC 1.0 TD`
- `VS SUN` (home) or `AT MON` (away) with the game day, over the opponent's logo

## Settings

| Setting | Values |
|---|---|
| Position | `ALL` rotates QB, RB, WR, TE, K and DEF, top 3 each (a 36-minute lap). Pick one position to step through its top 10. |
| Scoring | `PPR`, `HALF PPR` or `STANDARD`. Players are re-ranked, and averaged, in the scoring you pick. |

## Data

All from Sleeper, no key needed:

- the current week from `api.sleeper.app/v1/state/nfl`
- projections from `api.sleeper.com/projections/nfl/<season>/<week>`
- home/away, game day and finished games from `api.sleeper.app/schedule/nfl/<type>/<season>`
- the season average from `api.sleeper.com/stats/nfl/<season>` (points / games played)
- actual points for finished games from `api.sleeper.com/stats/nfl/<season>/<week>`

Each frame fetches only the position on screen. The WR feeds are the biggest (850-920 KB against the 1 MB response cap): if the season-stats feed is ever too large the average is simply left off, and if a projections feed is too large the panel says `WR FEED TOO LARGE` (in `ALL` it moves on to the next position instead).

The panel shows a message when Sleeper is unreachable, when no projections are published yet for the week (Sleeper posts none for playoff weeks until the matchups are set), and in the preseason and offseason.
