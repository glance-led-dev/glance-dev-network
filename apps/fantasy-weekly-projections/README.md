# Fantasy Weekly Projections

This week's start-'em board as a projection ladder: the top projected fantasy players at a position drawn as a staircase of club crests, the #1 step the tallest and gold, and a spotlight page for one player on his own pedestal.

## Page 1: the ladder

Four steps fall from left to right across the panel, one per player, in projection order. Each step shows:

- the club crest standing on the tread, with the **projected points** beside it (gold on the #1 step)
- the surname printed along the tread's lit edge, which is in the position's colour (gold for #1); a defense shows its nickname
- the rank numeral on the riser, where the step is tall enough to hold one
- a marker over the number: a green up-arrow when this week projects above the player's season average, an amber down-arrow when below, a chequered flag once his game is over
- the injury tag when Sleeper lists one (Q, D, OUT, IR, PUP, SUS), in its alarm colour

Steps are as wide as their name needs, so long surnames keep their letters. A double-barrelled name keeps its second half (NJIGBA) and a suffix is dropped. The header, in the space above the low end of the stairs, gives the position in its colour, the scoring and the week (and `#5-8` or `#9-10` on a lower ladder).

## Page 2: the spotlight

One player on a pedestal: his crest stands centred on a block with the points cut into it (gold for #1, the position colour otherwise). To the left:

- the rank (`#1 RB`, or `T1` on a tie)
- an injury pill
- a tier sized to a 12-team league: a star **STUD**, a tick **START** or a diamond **FLEX**
- first name over surname (city over nickname for a defense; San Francisco, Philadelphia, Jacksonville and Indianapolis are shortened)
- the projected stat line, such as `274 PASS 1.7 TD`

To the right:

- `VS SUN` (home) or `AT MON` (away) beside the opponent's crest
- the verdict against the season average, arrowed up or down

Once the game is over, the pedestal turns white and shows the actual points. The header reads `PPR FINAL`, the stat line is the real one, and `PROJ 13.6` sits underneath, arrowed up if he beat it.

## Settings

| Setting | Values |
|---|---|
| Position | `ALL` shows one position per refresh (QB, RB, WR, TE, K, DEF), the top four on the ladder, and spotlights the top 3 one lap at a time (a 12-minute lap). Pick one position to spotlight its top 10 in turn: the ladder shows 1-4, 5-8 or 9-10, whichever holds the player in the spotlight. |
| Scoring | `PPR`, `HALF PPR` or `STANDARD`. Players are re-ranked, and averaged, in the scoring you pick. |

## Data

All from Sleeper, no key needed:

- the current week from `api.sleeper.app/v1/state/nfl`
- projections from `api.sleeper.com/projections/nfl/<season>/<week>`
- home/away, game day and finished games from `api.sleeper.app/schedule/nfl/<type>/<season>`
- the season average from `api.sleeper.com/stats/nfl/<season>` (points / games played)
- actual points for finished games from `api.sleeper.com/stats/nfl/<season>/<week>`

Each frame fetches only the position on screen, at most five requests, and the two pages share them through the cache. The WR feeds are the biggest (850-920 KB against the 1 MB response cap). If the season-stats feed is ever too large, the average is simply left off. If a projections feed is too large, the panel says `WR FEED TOO LARGE`; in `ALL` it moves on to the next position instead.

The panel shows a message on an empty staircase when Sleeper is unreachable, when no projections are published yet for the week (Sleeper posts none for playoff weeks until the matchups are set), and in the preseason and offseason.
