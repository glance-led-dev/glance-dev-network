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

# Local Sleeper V1

The community manifest remains unchanged: **60-second rotation**, ALL NFL and
NFL-team news, plus Sleeper trending adds/drops. The source retains **9x12**.
Sleeper supplies roster membership and player metadata; RotoWire supplies news.

## Local test setup

From the repository root, run:

```sh
python3 apps/fantasy-football-news-scroll/prepare_local.py --username YOUR_USERNAME --league-id YOUR_LEAGUE_ID --league-wire
gdn studio apps/fantasy-football-news-scroll/.gdn/fantasy-football-news-scroll
```

Use a Sleeper username, not the fantasy team's display name. Omit `--league-wire`
to keep global trending players. With it, both ADDS and DROPS exclude every
rostered, reserve, and taxi player in the league, including unowned teams.
`AVAILABLE IN LEAGUE` means absent from the cached rosters, not immediately
claimable: waiver timing, locks and eligibility are not checked. In this mode
that label replaces the bottom-row global add/drop count and ownership percentage.
The global mode retains those numbers.

Setup creates a **git-ignored `.gdn/` copy** with personal values, a compact player
catalog, `MY SLEEPER TEAM` in the dropdown (selected by default), and the local
`8x12` substitution. Never submit that generated copy. The source constants stay
blank; the community manifest does not expose a nonworking setting. Editing the
source requires rerunning setup to update the copy. Existing HTTP caches can be
reused, but player metadata must be regenerated daily. Run the same setup command
again when the panel requests a refreshed snapshot.

Sleeper's full player catalog is downloaded by the setup helper at most once per
24 hours and cached under `.gdn/players.json`. It is currently about 14 MB, larger
than GDN's 2,000,000-byte HTTP response cap. The helper embeds only ID, full name,
position and team in the ignored copy (about 0.8 MB); renders never fetch the full
catalog. The snapshot expires after 24 hours to avoid silently stale news matching.

## Request budget and caching

GDN permits eight uncached requests per run. The budget here covers both pages
together, even though validation and the production renderer can run pages
separately. Identical roster requests on both pages reuse the host cache.

| Data | TTL | Requests on a cold run |
| --- | --- | --- |
| RotoWire news OR ESPN team feed | 600 seconds | 1 |
| Sleeper username resolution, personal news only | 21,600 seconds | 1 |
| League rosters, shared by personal news and league wire | 600 seconds | 1 |
| Trending adds OR drops | 1,800 seconds | 1 |
| NFL state | 3,600 seconds | 1 |
| Research/ownership percentages, when week is valid | 3,600 seconds | 1 |
| Individual player fallback records | 21,600 seconds | At most 2 personalized / 4 global |

A complete local snapshot normally needs **6 cold requests** for both personalized
pages; the maximum is **8** with fallback player lookups. Global mode uses at most
**8** (one news + three waiver support + four player lookups). Previously, the
five-player lookup budget allowed nine requests when both pages ran together.
Fully warm requests do not count toward the ceiling. A fresh roster can take up
to ten minutes to appear; the panel still rotates each minute.

## Matching and failure behavior

- Personal news scans up to 100 items actually present in the current RSS response;
  it cannot recover older stories that RotoWire no longer supplies. ALL NFL keeps
  the existing 12-item behavior; ESPN team news is unchanged.
- Match normalized full names, ignoring capitalization, punctuation, spaces,
  hyphens and trailing Jr/Sr/II/III/IV/V. No last-name-only or fuzzy matching.
- Catalog name collisions are omitted conservatively. Nicknames, initials versus
  full first names, non-ASCII spelling differences, and renamed players can miss.
  There is no cross-source player ID in the RSS feed. Team defenses generally do
  not have individual-player RotoWire stories.
- Ownership uses `owner_id`; co-owners are not resolved in V1. IR/taxi count as
  rostered. Missing user/owner, malformed/offline roster data, missing player IDs,
  and expired metadata produce explicit messages instead of global news fallback.
- The waiver page examines the top 25 trending entries and displays up to three
  matching players. A position filter or exhausted fallback budget can yield no
  match; that does not mean the league has no available players.
- No opponent or transaction features were added.

## Verification

```sh
python3 apps/fantasy-football-news-scroll/test_sleeper.py
gdn check apps/fantasy-football-news-scroll
gdn validate apps/fantasy-football-news-scroll
gdn check apps/fantasy-football-news-scroll/.gdn/fantasy-football-news-scroll
gdn validate apps/fantasy-football-news-scroll/.gdn/fantasy-football-news-scroll
```

The fixtures execute real Starlark and render both pages, including name
normalization/collisions, IR/taxi exclusion, empty/invalid/unavailable rosters,
missing owners, incomplete/expired player snapshots, ADDS/DROPS, team/global
regression paths, and cold-request ceilings. Source validation may only exercise
fonts selected by that day's feed; a pass does not establish local `9x12` support
for every possible headline. Use the generated `8x12` copy for local previews.

## Before a community PR

This is a local V1, not a completed production settings integration. Agree with
GLANCE on a supported mechanism for user/league identifiers without free-text
inputs forcing refresh to 300. Do not add those inputs or slow rotation yet.
Also agree on a compact, maintained Sleeper metadata source (for example an
approved cached service) that fits the response and request budgets; a manually
regenerated developer snapshot is not a production solution. Re-run cold-cache,
error-path and render validation with that design. Keep personal values, generated
catalogs and `8x12` out of the diff, and retain `9x12` unless review requires a
separate font change.

Sleeper API reference: <https://docs.sleeper.com/>.
