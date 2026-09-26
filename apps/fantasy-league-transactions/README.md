# League Transaction Wire

Your own fantasy football league's waiver wire, for **ESPN** and **Sleeper**
leagues. Every move is shown newest first, printed like a telegram on a strip
of ticker tape: who made it, what they did, which player, and what they paid.

The tape is off-white paper with perforated edges and black type. The fantasy
team's crest and the player's NFL club logo are postage stamps stuck on the
end of the tape, and a FAAB bid is a red rubber stamp.

- **latest**: the newest move, big.
  - A claim or pickup reads like *BLITZ BRIGADE CLAIMED / J. WARREN RB
    [$23] / DROPS T. SPEARS STOP*. The verb is in green (claim, add), red
    (drop) or blue (trade) ink. The crest stamp shows how long ago it
    happened.
  - A free-agent pickup says which move of the week it is for that team
    (*3RD MOVE THIS WEEK*). A waiver claim in a league without FAAB says
    *ON WAIVERS*.
  - **Outbid:** when the winning claim took a player you also put a claim
    in for, the line underneath reads *YOUR $98 BID LOST* (your bid in
    grey). In a league without FAAB it says *BEAT YOUR CLAIM*. When several
    claims went through in the same waiver run, the one that beat you is
    the one shown.
  - A trade reads *TRADE / TT GETS T. MCLAURIN / GG GETS J. COOK +1*, with
    both teams' crests as stamps and a two-way arrow between them. Draft
    picks read *2027 R2* and FAAB in a trade reads *$15 FAAB*. A swap the
    commissioner forced between two teams reads *COMMISH TRADE*.
  - A drop shows the player in red ink. In a guillotine league, a chopped
    team reads *CUT*, with the blade as the picture stamp and how many
    players went back to waivers.
- **wire**: the tape runs on, torn into three by perforated tear marks. Each
  move has a crest stamp, a club-logo stamp, a green + or red - with the
  player's position, and the player with the bid (in red) or how long ago it
  happened. The last slot is the league desk:
  - **Wire king**: a crown next to the crest of the team with the most moves
    this week (2 or more, and no tie).
  - **Your FAAB**: how much of your waiver budget is left, with a red gauge.

  With neither to show, the last slot is another move. Empty slots read
  END OF THE WIRE.

**Your team is marked in gold.** Your crest stamp gets a gold edge with YOU
printed on it, and your FAAB left ($77 LEFT) is at the end of the hero's last
line. On the wire page your moves have a gold bar underneath.

The wire covers this week, plus last week while this week has fewer than 4
moves. A league with no moves shows **QUIET WIRE** (telegraph poles, a slack
wire and a blank strip of tape). Before the draft the app says the wire opens
after your draft. Errors are typed on a short strip of tape, with what to do
underneath.

Free agents have no club, so they show the NFL shield, or a grey helmet on
the wire page. Team defences show as the club's logo with D/ST.

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Your team name or your manager / username. It turns on the gold YOU marks, your FAAB left and the outbid tags. Part of the name is fine, and case doesn't matter. |
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

## Where the moves come from

- **Sleeper:**
  - The league's transactions for this week, plus last week while this
    week has fewer than 4 moves. Only completed moves are shown. Failed
    waiver claims are only used to spot the ones that lost your bid.
  - The FAAB bid is the winning bid on the claim. FAAB left is the league's
    waiver budget minus what your roster has spent.
  - Player names come from one lookup for the players on screen. That
    lookup is not a documented Sleeper API. If it fails, the app logs a
    warning and uses a built-in list of the 300 most-traded players, then
    Sleeper's per-player endpoint.
- **ESPN:**
  - The league's transactions for this scoring period and the last one:
    waiver claims (with the bid, in FAAB leagues), free-agent adds and
    drops, and failed claims (for the outbid tags).
  - Trades come from the league's activity feed, which is the only place
    ESPN lists them. Only trades from the last 14 days are shown.
  - FAAB left is the league's acquisition budget minus what your team has
    spent.
  - Player names come from one lookup in ESPN's player pool.

The app refreshes every 10 minutes.
