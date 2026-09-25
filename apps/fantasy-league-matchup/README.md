# My Fantasy Matchup

Your own fantasy football matchup, live, for **ESPN** and **Sleeper** leagues.

- **matchup**: your crest and your opponent's, both scores, and a pixel
  football field. The ball sits at your win probability, and each end zone is
  painted in the team's colour with its record. When the week is over, the
  ball crosses the loser's goal line, the middle reads FINAL / WON or LOST,
  and the 50-yard line shows your place in the league (3RD OF 12). From
  Tuesday until the first points of the new week, it shows last week's final
  instead of a 0.0 - 0.0 game.
- **outlook**: the race to Monday night. A bar for points scored so far, the
  projected rest of the week behind it, and the projected final score. Under
  each bar: the team's streak (W3 / L1), a helmet and a count for starters
  still to play (12 TO PLAY), and on Sleeper the team's top scorer so far.
  When you trail on projection, your line reads NEED 18.4.

Guillotine leagues on Sleeper have no head-to-head. There the opponent becomes
the **chop line**, the lowest-projected team that isn't you, and both scores
are projected totals. Your place shows as SAFE, RISK or CUT. The outlook page
lines up the crests in projected order, and in a big league the hidden middle
is counted (+7).

In a fantasy bye week (odd team count) the outlook shows your own race. In the
playoffs, a team without a game sees PLAYOFF BYE (a top seed resting) or
SEASON OVER with its final place.

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Your team name or your manager / username. Part of it is fine, and case doesn't matter. |
| Platform | Leave on AUTO: Sleeper IDs are 18-19 digits, ESPN IDs are shorter. |
| ESPN cookies | Only for **private** ESPN leagues (see below). |

A Sleeper league ID from last season is followed to this season's league
automatically.

Leave the League ID blank for a demo league, labelled DEMO on the panel.

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

- **ESPN:** a single request returns live scores, ESPN's projections,
  ESPN's own win probability and last week's results.
- **Sleeper:**
  - Live points come from the league's matchups.
  - Projections are priced in your league's exact scoring (6-point passing
    TDs, TE premium, first-down and yardage bonuses included). IDP starters
    have no Sleeper projection, so they count only the points they have.
  - The projected final uses actual points for starters whose game is over,
    the higher of actual and projection while a game is on, and the
    projection for starters still to play. Starters ruled out or on a bye
    count as played.
  - Win probability comes from a normal model over what is still to be
    scored, calibrated against ESPN's own win probability.
  - A league ID from last season is followed to this season's league, but
    that costs requests: on game days the app may then use last season's
    manager names, and from Tuesday to Thursday it can skip projections. Enter
    this season's ID to get everything.

The app refreshes every 5 minutes.
