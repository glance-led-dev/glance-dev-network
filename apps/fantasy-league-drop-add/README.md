# Drop & Add

The best waiver-wire moves for your own **ESPN** or **Sleeper** fantasy
football team, on two pages.

- **move**: your single best move. The player to drop is on the left in
  red under his NFL club logo, the player to add is on the right in green.
  The gain sits between them ("+6.3 PTS/WK") over a red-to-green swap arrow
  carrying a position pill (QB, RB, WR, TE or FLEX). Names read as initial
  + last name (M.WASHINGTON), so two Washingtons never get mixed up.
  - ESPN shows how many leagues roster the player you'd add ("88% OWN",
    amber from 50%: move before somebody else does). The ADD label turns
    into an amber **CLAIM** when he is on waivers.
  - Sleeper shows **WIRE**, or **WAIVERS** in amber when your league has no
    daily waivers (every add is a claim).
  - When no move gains at least 2 points per week, a green padlock card
    says **ROSTER IS TIGHT** and quotes the best gain on offer.
- **next_moves**: moves 2 and 3 as two rows, each with a position pill, a
  pixel jersey in each player's club colours, a small swap arrow and the
  gain. With only one more move, the second row ticks off the positions
  that are set. With none, the page becomes a QB / RB / WR / TE line-up
  card: each spot SET with the best gain the wire offers there (or SWAP
  when page 1 moves it).

## How a player is valued

Rest-of-season points per week, a weighted average of what's known:

- **ESPN:** `(PPG x games + season projection per game x 4 + this week's projection) / (games + 5)`.
  ESPN's season projection keeps a two-game hot streak from overselling
  a player.
- **Sleeper:** `(PPG x games + this week's projection x 4) / (games + 4)`.
  Sleeper has no season projection small enough for a panel to download.

A part that's missing drops out of the average. A player on a bye keeps
his PPG and season projection. The move page names the metric it used:
**PPG+PROJ**, or **SEASON PPG** / **WEEK PROJ** when only one source is
available (see Sleeper below).

## Roster rules

- A player who is **OUT, DOUBTFUL**, on IR, PUP, suspended or NA is never
  suggested as a drop. A hurt starter is a hold. Players in IR / reserve
  and taxi slots are never dropped either.
- A healthy player with no projection this week (a bye) is only suggested
  as a drop once he has 3 games of PPG (2 when there are no projections).
- After week 1, a healthy player with **no games and no projection** is
  worth 0.0 and is the first drop.
- Free agents who are OUT, DOUBTFUL, on IR, PUP or suspended are never
  suggested. Nor is a free agent with one game and no projection (a fluke
  risk).
- If the player you'd drop has a projection this week, the free agent
  must out-project him too, so two quiet games never get a star cut.
- Moves are same position (a QB for a QB), plus one **FLEX** move: your
  weakest bench RB / WR / TE for the best RB / WR / TE on the wire.
- No player appears in two moves. Kickers and defences are left out: they
  are weekly streams, not rest-of-season moves.

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Your team name or your manager / username. Part of it is fine, and case doesn't matter. The panel asks for it if it matches nothing, because the swaps are for your roster. |
| Platform | Leave on AUTO: Sleeper IDs are 18-19 digits, ESPN IDs are shorter. |
| ESPN cookies | Only for **private** ESPN leagues (see below). |

A Sleeper league ID from last season is followed to this season's league
automatically. Leave the League ID blank for a demo, labelled DEMO on the
panel.

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

- **ESPN:** your roster, plus the top 20 free agents and waiver players (by
  % owned) at each position you roster, with ESPN's season lines, season
  projection and this week's projection. Points are in your league's own
  scoring.
- **Sleeper:** your league's rosters and waiver settings, Sleeper's season
  stats and Sleeper's projection for this week, scored with your league's
  own scoring settings (6-point passing TDs, TE premium and yardage bonuses
  included).
  - A panel app may make 8 requests per refresh. A league ID from **last
    season** needs extra lookups to find this season's league. That leaves
    room for the season stats only, so the page says **SEASON PPG** and the
    tag is WIRE. Enter this season's ID to get PPG+PROJ and the waiver
    setting.
  - Sleeper's WR stats file sits close to the 1 MB a panel app can
    download. If it arrives broken, the panel says **SLEEPER WR FEED BUSY**
    rather than quietly leaving receivers out.
  - In **week 1**, before any games, moves use the **WEEK PROJ**
    projection alone.

The app refreshes every 15 minutes.
