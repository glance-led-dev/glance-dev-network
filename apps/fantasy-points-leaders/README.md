# Fantasy Points Leaders

The top fantasy scorers at every position, for last week or the season so far,
from Sleeper's public stat feed. No key is needed.

## Pages

- **podium**: the top three at one position on a gold, silver and bronze
  podium (2nd, 1st, 3rd from left to right). Each step is topped with a
  stripe in the player's club colours and carries the club's logo and the
  player's points, with the surname above it. The position, the week (or
  the season's year) and the scoring system sit on the left.
  Long surnames are shortened the way fantasy apps do (`S-NJIGBA`, `CEH`,
  `MCCAFFRY`); a defense is shown by its club code (`CAR`).
- **spotlight**: one leader at a time, hung like a medal: the points on a
  plaque framed in the medal colour, on a ribbon in the club's two colours.
  Next to it are the fantasy rank (WR1, RB2 ...), the week and opponent
  (`WK 2 VS DET`), the name, the stat line behind the score
  (`9 REC 155 YD 3 TD`), and the team logo.

Players on the same score share a rank and a medal (three kickers on 16.0
are all K1, shown `T-K1`). When two different scores would both round to
the same figure, both are shown to two decimals (`29.78`, `29.76`).

Each refresh (every 3 minutes) moves the spotlight to the next leader. With
**ALL** positions the app works through QB, RB, WR, TE, K and DEF, showing
the top three at each, and the podium stays on the same position as the
spotlight. With one position picked, the spotlight cycles through its top
five. For a season total the spotlight shows points per game and games
played instead of the opponent.

## Settings

| Setting | Choices |
|---|---|
| Position | ALL, QB, RB, WR, TE, K, DEF |
| Scoring | PPR, HALF PPR, STANDARD. Kickers and defenses score the same under all three. |
| Timeframe | LAST WEEK, SEASON |

**LAST WEEK** is the most recent week that has been played in full. It
switches over once Monday night's game is final. In the offseason and
preseason, both timeframes show last season's final leaders.

## Data

- `api.sleeper.app/v1/state/nfl`: the current season, week and phase
  (cached for 1 hour).
- `api.sleeper.com/stats/nfl/<season>[/<week>]?position[]=<pos>`: one
  position per request (cached for 30 minutes). The largest feed is season
  WR, at about 840 KB. If it ever grows past the 1 MB response cap, the app
  shows last week instead of an error.

Team logos are the 40 x 24 pixel-art set from Fantasy Football News, plus
the same clubs at 24 x 18 (`assets/S/`) for the podium steps.
