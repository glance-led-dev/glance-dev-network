# Weekly Streamers

The best free agents to stream this week in **your own** ESPN or Sleeper
league: defense, kicker and tight end, plus quarterback. In superflex and 2QB
leagues the QB always counts; in 1-QB leagues a QB only shows when he beats
your starter (he's out, on bye, or the slot is empty). Only players nobody in
your league has rostered, and whose game hasn't kicked off, are shown.

Each pick is printed as a **game ticket** across the panel: the main ticket
in the streamer's club colours, and a tear-off stub that gives the verdict.

- **pick1 / pick2**: the two best streams, ranked by how many points they beat
  your current starter at that slot by. Each ticket has:
  - the player (or the defense's club) and the week along the top
  - seat-and-row style fields: **POS** (in the position colour), **PROJ**
    (the projection), and a **VS** / **AT** plate between the streamer's and
    the opponent's NFL logos, with the game day under it (SUN, or TNF / SNF /
    MNF)
  - the fine print: one line on why the matchup is good:
    - DEF: the opponent's points per game and projected sacks
    - K: the team's implied points
    - TE / QB: the total points per game the opponent gives up
  - the stub, past the perforated tear line: green with the gain, e.g.
    `+3.4 OVER YOUR K` (or `YOUR DEF ON BYE`, `IS OUT`, `IS EMPTY`); slate
    with a minus when your starter is still better; dark with a padlock and
    his points (`4.2 YOUR TE SCORED`) when your starter already played -
    that slot is locked for the week, so it ranks last.

  If no free agent beats any of your starters, pick1 is your own team's
  ticket: **YOUR STARTERS ARE BEST** with your team crest and a green KEEP
  stub (or **LINEUP LOCKED** when every slot has already played).
- **board**: every streaming slot side by side, one small ticket each. Each
  has the logo and projection of the best free agent at that position, and
  its gain over your starter. With one or two slots the tickets are wider
  and add the player, VS / @ opponent and the matchup reason; a league with
  one streaming slot shows its best two free agents.

Errors (bad league ID, private league, offline) show a grey ticket with the
problem printed on it and the stub stamped VOID.

Only positions your league actually starts are considered. A league with no
kicker gets no kicker picks. If your starter is on bye, out, or the slot is
empty, the stub says so (on ESPN, a starter projected 0 shows as
`YOUR DEF PROJ 0.0` - ESPN's matchup data doesn't say whether he's on bye or
out).

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Your team name or your manager / username. Part of it is fine, and case doesn't matter. Without it, the app still shows the best free agents but can't compare them with your starters. |
| Platform | Leave this on AUTO. Sleeper IDs are 18-19 digits, ESPN IDs are shorter. |
| ESPN cookies | Only for **private** ESPN leagues (see below). |

A Sleeper league ID from last season is followed to this season's league
automatically. Leave the League ID blank to see a demo league, labelled DEMO
on the panel.

### Private ESPN leagues

ESPN only shares private leagues with a signed-in browser. In a desktop
browser logged into ESPN, open your league. Then open DevTools > Application >
Cookies > `https://fantasy.espn.com` and copy two values:

- `espn_s2` into **ESPN espn_s2 cookie**
- `SWID` (including the curly braces) into **ESPN SWID cookie**

Both are stored encrypted, like API keys. They are your ESPN login, so treat
them like a password.

### Yahoo

Not supported. Yahoo's fantasy API needs an OAuth sign-in, which a panel app
can't do.

## Where the numbers come from

- **Sleeper:** your league's rosters and lineup slots, plus Sleeper's weekly
  projections priced in your league's exact scoring settings (including
  missed field goals when your league scores them). Once games have started,
  your starters' actual points this week.
- **ESPN:** the free-agent and waiver pool at each position, sorted by
  ESPN's projection in your league's own scoring. Your starters' projections
  come from your league's matchup.
- **Schedule:** ESPN's NFL schedule gives each club's opponent, home or away,
  kickoff and bye week.
- **Matchup lines:** ESPN's NFL standings give points for and against per
  game. Implied team points and projected sacks come from Sleeper's defense
  projections.

Players whose game has kicked off (on Sunday afternoon, only the late and
night games are left; on Monday, only Monday night), and players who are out
or on bye, are left out. The app refreshes every 5 minutes. Free agents are cached
for 15 minutes and projections for an hour.
