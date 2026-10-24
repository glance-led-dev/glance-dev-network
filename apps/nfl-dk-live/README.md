# NFL DK Live

Live DraftKings fantasy points for NFL players during games, on a 192 x 32 GLANCE Scroll.

Data comes from the keyed [glance-nfl-dk](https://github.com/jnwallen/glance-nfl-dk) backend at
`https://glance.mdhoria.net`, which polls ESPN every 60 s during games and computes DK scoring.

## Pages
A title page (`splash`: DK FANTASY POINTS / `LEADERS - NFL WEEK N`; week omitted when unknown or no data, `LEADERS - DEMO` in demo mode), then five pages (`p1`..`p5`), two players per page = the top 10. Each 16 px row has a state bar,
the name, `#rank TEAM POS STATUS`, and a big DK number on the right. **Green** = game final,
**amber** = game in progress. With fewer players the pages wrap. All five pages make the
identical request, so one render = one fetch.

Other screens: `BAD API KEY` (401/403), `RATE LIMITED` (429), `SERVER DOWN` (anything else),
`BAD DATA`, and `NO LIVE GAMES` when the list is empty. With no key the app plays a labelled DEMO (every row tagged DEMO; sample statuses are FINAL or SAMPLE).

## Inputs
| key | type | notes |
|---|---|---|
| `apikey` | api-key | sent as `x-api-key`. Empty = demo. |
| `position` | dropdown | ALL / QB / RB / WR / TE / DST -> `/v1/top?n=10&pos=` |
| `players` | free-text | optional `J.ALLEN, B.ROBINSON, BUF DST` -> `/v1/players?names=` (overrides position, up to 10) |
| `screen` | dropdown | LIVE (default) / DEMO / ERROR / NO GAMES sample screens, no network |

## Assets
None (team logos were dropped in 0.2.0 to fit two players per page).

## Preview
`gdn build apps/nfl-dk-live --input screen=DEMO`
