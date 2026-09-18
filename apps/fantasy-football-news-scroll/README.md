# Fantasy Football News

NFL player news sorted the way a fantasy manager reads it, plus the waiver
wire's hottest pickups. No key or account needed. Built for scroll panels
(192x32).

## Settings

| setting | what it is |
|---|---|
| **News for** | `ALL NFL` (default) shows the latest player updates league-wide from RotoWire. Pick a team to see only that team's fantasy players (QB, RB, WR, TE, K) from ESPN, with their position, injury status, body part and expected return. |
| **Waiver wire** | `ADDS` shows who managers are grabbing most on Sleeper in the last 24 hours; `DROPS` shows who they are cutting. |
| **Waiver wire position** | `ALL`, or one of `QB` `RB` `WR` `TE` `K` `DEF` to narrow the waiver page. The news page is not filtered by this. |
| **Sleeper username** | Your Sleeper account username, used with the league ID to identify your roster for `MY SLEEPER TEAM` news. The fantasy team display name is not needed. |
| **Sleeper league ID** | The numeric ID from your Sleeper league URL. |
| **Show only players available in my league** | Exclude players on any roster, reserve or taxi squad from trending waiver players. Requires a league ID. |

## What the pages show

Every page is framed by the club:

- **Team logo** (left) - the club's pixel-art logo on black, closed off by a
  bar in its colours.
- **Position** (right) - the position pill over a pixel-art player in that
  club's uniform, with helmet stripe, facemask and number: the QB cocked to
  throw, the RB running with the ball tucked, the WR high-pointing a catch,
  the TE blocking, the K through his kick, and the defense squared up facing
  the offense.

Between them:

- **News** - one player update at a time, rotating every minute through the
  latest few, with a `1/5` counter. The player's name is the hero, the
  headline sits under it, and a coloured pill says what kind of news it is
  before you read a word. RotoWire's league-wide feed has no positions, so
  there the news kind's icon stands in for the player, and the club is read
  from the update itself ("in the Chiefs' 31-10 win"). An update that names no
  club gets the NFL shield.
- **Waiver wire** - the top three trending players, one at a time, with a
  flame for adds or an ice cube for drops, how many managers added or dropped
  him, and `OWNED`: the percentage of Sleeper leagues where he is already on
  a roster.

## The pills

| pill | icon | meaning |
|---|---|---|
| `OUT`, `INJURED RESERVE` (red) | red cross | ruled out, inactive, or on IR |
| `DOUBTFUL` (red-orange) | cross | listed doubtful |
| `QUESTIONABLE`, `INJURY` (amber) | cross | questionable, limited in practice, or hurt |
| `SUSPENDED` (amber) | penalty flag | suspended |
| `CLEARED` (green) | check | full practice, no designation, activated |
| `SIGNED` `TRADED` `RELEASED` `CLAIMED` `PROMOTED` (purple) | swap arrows | roster moves |
| `BOOM` (orange) | flame | touchdowns or a 100-yard day |
| `BUST` (ice) | ice cube | a quiet, fumbling or no-target game |
| `DEPTH CHART` (pink) | clipboard | starter, backup, workload news |
| `STAT LINE` (teal) | football | a box-score line |
| `NEWS` (white) | megaphone | anything else |

When following a team, ESPN's official designation (Out, Injured Reserve,
Doubtful, Questionable) always sets the pill. Otherwise the app reads the
headline for those phrases.

## Notes

- Sources: RotoWire's public NFL news RSS, ESPN's site API, and Sleeper's
  public API. Player news is cached for 10 minutes, trending players for 30.
- The panel redraws every minute so the rotation moves; the feeds are not
  asked that often.
- Nothing new to show is not an error: the page says `ALL QUIET` in green.
- Team logos are 40x24 pixel art, one per club plus the NFL shield, shipped
  in `assets/`.

---

# Sleeper personalization V1

Choose `MY SLEEPER TEAM` under News for, then enter your Sleeper username and
league ID. The app resolves your user ID, finds the roster owned by that user,
and shows matching RotoWire stories. The team display name is not needed.
The optional league-wire checkbox excludes players on any league roster,
reserve or taxi squad from trending adds and drops. `AVAILABLE IN LEAGUE` means
absent from cached rosters; it does not account for waiver locks or timing.
With no Sleeper settings, ALL NFL/team news and the global waiver page remain
available.

The app still rotates every minute (`refresh: 60`). News is cached for 600
seconds, trending for 1800, user resolution and individual player records for
21,600, and league rosters for 600. A cold run of both personalized pages uses
six requests, or at most eight if player fallbacks are needed.

Sleeper's full player catalog is about 14 MB, above GDN's 2 MB HTTP response
limit. This app bundles a compact public snapshot of player ID, name, position
and team (about 0.8 MB) for name matching. The local setup helper can regenerate
a test copy using a fresh catalog; the committed snapshot needs seasonal
maintenance or replacement with an approved compact endpoint. Matching uses
normalized full names, so nicknames, renamed players and ambiguous names can
be missed. RotoWire only supplies stories still in its current RSS response.
To refresh the committed catalog, run `python3
apps/fantasy-football-news-scroll/prepare_local.py --update-source-catalog`
and review the resulting public-data diff before submitting it.

For a prefilled local Studio preview, run:

```sh
python3 apps/fantasy-football-news-scroll/prepare_local.py --username YOUR_USERNAME --league-id YOUR_LEAGUE_ID --league-wire
gdn studio apps/fantasy-football-news-scroll/.gdn/fantasy-football-news-scroll
```

The generated `.gdn/` copy is git-ignored and must not be submitted. It embeds
a 24-hour player snapshot, prepopulates the Studio settings and substitutes
`8x12` for local rendering. The source retains the merged app's `9x12` face;
the local GDN build rejects it when a headline selects that font.

Verify with:

```sh
python3 apps/fantasy-football-news-scroll/test_sleeper.py
gdn check apps/fantasy-football-news-scroll
gdn validate apps/fantasy-football-news-scroll/.gdn/fantasy-football-news-scroll
```

For GLANCE review: the two free-text Sleeper settings coexist with
`refresh: 60` to preserve one-minute story rotation. The reviewer can decide
whether to keep this or use another supported input mechanism. The player
snapshot maintenance plan also needs review. Personal values stay out of the
source and the PR. Local source validation currently fails on unsupported
`9x12`; ask GLANCE whether their submission renderer supports the merged font.
