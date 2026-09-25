# My Roster Report

Your own fantasy football roster, for **ESPN** and **Sleeper** leagues.
Page 1 is your locker room: every starter's jersey hanging in its stall, in
its status colour, so you see at a glance who is hurt or on bye. Page 2 is
the trainer's clipboard. Every frame there is one player who needs a
decision, most urgent first:

1. starters who are **OUT**, on **IR**, **DOUBTFUL** or **QUESTIONABLE** (worst
   status first, then by this week's projection),
2. players in an **IR slot** who are healthy again, or only questionable:
   **ACTIVATE**. Your league locks the lineup until you move them. Players
   still on IR stay off the report, because there's nothing to decide,
3. starters whose NFL club is on **bye**,
4. hurt players on your **bench**.

When nobody needs attention the clipboard page says **ROSTER HEALTHY**, with an
all-green body figure and the next kickoff.

## Pages

- **lineup** (page 1): the locker room. Your starting lineup is a bank of
  locker stalls across the panel, one stall per slot in your league's order.
  - **Nameplates** along the top carry the slot name your league uses (QB,
    RB, FLEX, SF, DL...). A starter who is good to go has a steel plate. A
    hurt starter's plate lights up in his status colour, so trouble shows
    along the top row at a glance.
  - **Jerseys** hang in each stall in the status colour, with a mark on the
    chest: X out, IR, D doubtful, ? questionable, B bye, and a tick for good
    to go. A grey jersey with ? is a player the feeds don't cover (deep IDP).
    An empty slot is an empty stall with just the hook.
  - **Your crest** hangs at the far end of the room (lineups of up to 10 slots; bigger
    IDP lineups use the whole width with smaller jerseys).
  - **The bench** along the bottom has your team name and a READY pill,
    for example `5 OF 9 READY`: green when everyone is ready, amber when one
    isn't, red when more aren't. Slots the feeds don't cover are left out of
    the count.
- **report** (page 2): the trainer's clipboard, one player per refresh.
  Brass studs on the bottom edge of the clipboard count the frames. The lit
  stud is the one on screen.
  - **Top row:** the status, the position, the lineup slot as your league
    names it (STARTER, FLEX, SF, W/R, BENCH, IR SLOT), and the player's
    projection (`PROJ 14.2`). When a tag was set before this week's Tuesday,
    the status chip dims and says **LAST WK**. It's last week's designation
    until the Wednesday report.
  - **Middle:** the player's name.
  - **Bottom row:** the body part, then the bench cover in green, for
    example `2 RB READY ON BENCH`. That counts healthy bench players at his
    position whose game hasn't started. `NO TE ON BENCH` shows in grey.
  - **Clipboard:** a body figure whose hurt part glows in the status colour:
    red for out, orange for doubtful, amber for questionable, green for
    activate. On a bye, the clipboard holds a calendar page with the week
    number instead.
  - **Right:** his club's logo, and under it the game and the decision
    deadline: `@DEN 4:25` (Sunday kickoff, ET), `VS KC MNF`, `@LV TNF`. It
    turns amber in the last 24 hours before kickoff, then reads LIVE and
    FINAL.

A QUESTIONABLE or DOUBTFUL tag drops off at that player's kickoff, because
by then the decision has been made.

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Your team name or your manager / username. Part of it is fine, and case doesn't matter. |
| Platform | Leave on AUTO: Sleeper IDs are 18-19 digits, ESPN IDs are shorter. |
| ESPN cookies | Only for **private** ESPN leagues (see below). |

A Sleeper league ID from last season is followed to this season's league
automatically. Teams renamed since last season are matched by their new
name. Leave the League ID blank for a demo roster, labelled DEMO on the
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

## Where the data comes from

- **Sleeper:**
  - Your roster, lineup slots and IR slots come from the league.
  - Every player's injury status, body part, news time, club and projection
    come from Sleeper's weekly projections. The projection uses your
    league's own scoring.
  - A starter the projections don't cover (IDP) is looked up on his own
    when the request budget allows.
- **ESPN:**
  - Your roster, injury statuses, lineup slots and projections come from
    the league.
  - The body part for the player on screen comes from his ESPN player card.
- **Both:** home/away, kickoff times and byes come from ESPN's public NFL
  schedule. If that can't be read, Sleeper leagues still show the opponent
  and the game day from Sleeper's own feed.

The app refreshes every 5 minutes and moves on to the next player each
time.
