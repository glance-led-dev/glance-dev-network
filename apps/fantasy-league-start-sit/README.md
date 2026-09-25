# Start/Sit Optimizer

Your fantasy football lineup, checked against your bench on this week's
projections, for **ESPN** and **Sleeper** leagues.

- **swap**: the one move worth the most points, told like a sideline
  substitution board. The player to **START** is on the left under a green
  arrow, the player to **SIT** on the right under a red one, each over his NFL
  club's logo with his position and projection, his opponent (`@DAL`,
  `vs SEA`) and his kickoff (`SUN 1:00`, `SNF 8:20`, Eastern). The game that
  kicks off first wears a gold padlock: that's when the move locks. In the
  middle: the projected gain and the slot the new man takes
  (`+4.1 AT FLX`). When your new starter can't play the benched man's slot, a
  starter has to slide over to make room, and the top line says who
  (`WILSON > WR`).
  - A starter who is OUT, on IR, suspended or on a bye shows that tag in red
    and reads **BENCH**; an empty slot reads **FILL**.
  - A QUESTIONABLE / DOUBTFUL player gets an amber Q / D; one the feed
    projects 0.0 shows `Q 0.0` all in amber - he isn't expected to play.
  - If nothing needs changing you get the green **LINEUP IS OPTIMAL** screen.
    If a starter is out and your bench has nobody to replace him, it shows
    **BENCH X - ON IR** with a medic cross. Once every game has kicked off, it
    shows **LINEUP LOCKED**.
- **lineup**: your lineup card. Your team crest and name, a meter of your
  projected total now against the best lineup you could set (the gain in
  green), the top move's two club logos, every move plus every uncovered
  starter in a list, and along the bottom one cell per starting slot:
  - bright green: the slot the top move fills
  - green cap: other slots that change
  - red: a starter who won't play and nobody on your bench can cover
  - grey: the game has already kicked off, so the slot is locked
  - slate: no projection to judge (IDP players on Sleeper)
  - dark green: the slot is fine as it is

  A lineup of more than 12 slots folds its defensive (IDP) slots into one
  `IDP` cell so the offensive cells stay readable.

## How it picks

- It uses your league's own roster slots: QB, RB, WR, TE, K, DEF, FLEX,
  WR/RB, WR/TE, SUPERFLEX / OP and IDP slots.
- Players whose game has started are locked and stay where they are. So do
  players the feed has no projection for (IDP on Sleeper, for example).
- Every other slot is refilled by an exact assignment of players to slots:
  as many slots filled as possible, then the most projected points. A starter
  keeps his place unless someone beats him by at least 0.05 points, and keeps
  his own slot when he stays, so the lineup never reshuffles for nothing.
- Starters who are OUT, on IR, suspended or on a bye project 0 points.
- Each suggestion follows the substitution itself: the new man takes a slot,
  and if that slot's starter slid over to another slot, it follows him until
  someone leaves the lineup - that's the player to SIT. So every START fits
  the slot shown, and the gains of all the moves add up to the difference
  between your lineup and the best one.

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Your team name or your manager / username. Part of it is fine, and case doesn't matter. |
| Platform | Leave on AUTO: Sleeper IDs are 18-19 digits, ESPN IDs are shorter. |
| ESPN cookies | Only for **private** ESPN leagues (see below). |

A Sleeper league ID from last season is followed to this season's league
automatically. Leave the League ID blank for a demo lineup, labelled DEMO on
the panel. If the team name doesn't match anyone, the panel asks for it
rather than show someone else's lineup.

### Private ESPN leagues

ESPN only shares private leagues with a signed-in browser. In a desktop
browser logged into ESPN, open your league. Then open DevTools > Application >
Cookies > `https://fantasy.espn.com` and copy two values:

- `espn_s2` into **ESPN espn_s2 cookie**
- `SWID` (including the curly braces) into **ESPN SWID cookie**

Both are stored encrypted, like API keys. They are your ESPN login, so treat
them like a password.

### Yahoo

Not supported. Yahoo's fantasy API needs an OAuth sign-in, and a panel app
can't do that.

## Where the numbers come from

- **ESPN:** your roster with ESPN's own projections in your league's scoring,
  ESPN's lock flag for games that have started, and injury status.
  Opponents, kickoff times and bye weeks come from ESPN's NFL schedule. That's
  3 requests.
- **Sleeper:** your roster, your league's slots, and Sleeper's projections
  scored with your league's own scoring settings. Player names, positions, NFL
  teams, opponents, game days and injury status come from the projections
  too. When the request budget has room, ESPN's NFL schedule supplies kickoff
  times, home / away and byes. Otherwise (a league ID from last season uses
  all 8 requests):
  - the panel shows the opponent and game day without home / away or a time
  - a player is locked once his game day is over, or after 9 pm Eastern on
    game day
  - a team with no game in the projection feed is on bye

  That's 6-7 requests, 8 for last season's league ID. Sleeper's projections
  are about 2 MB, so the first render of the hour can take 20 seconds; every
  Sleeper league app shares that cost.
- Only NFL leagues: a Sleeper league for another sport shows
  **NOT AN NFL LEAGUE**.

The app refreshes every 5 minutes.
