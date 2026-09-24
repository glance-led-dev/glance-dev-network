# Golf World Tours

A broadcast-style golf leaderboard for a 192x32 scroll panel. It covers the tours that the network's PGA Tour and LPGA apps leave out: **DP World Tour**, **PGA Tour Champions**, **Korn Ferry Tour** and **LIV Golf**. Each tour has its own emblem and colours: a navy/cyan globe, a gold trophy, a green road-to-the-flag and an orange LIV badge.

## Pages

| Page | During an event | Between events |
|---|---|---|
| `event` | Tour emblem, event, course and city, round status (live dot, suspended or complete), and a LEADER box (or CHAMPION box when the event is final) with the to-par score and thru | The next event with its course and dates, and a STARTS box counting down the days. When the field is set, a FIRST TEE box shows the first tee time |
| `board1` | P1-6 | Last winner: the name, the event, the winning score and the margin |
| `board2` | P7-12 | Field set: this week's defending champion, purse, par, yards and field size. Otherwise: the next three events |

Each board row has a position chip in the tour colour, a surname, the to-par score and an 18-tick hole strip under the name. The strip lights the holes played this round (a player who started on the back nine lights 10-18 first) and shows the hole just finished in white. A finished round shows a dim full strip, and a player who hasn't teed off shows an empty one. Scores follow the TV convention: red under par, white for level, blue over par.

## Settings

- **Tour**: DP World Tour (default), PGA Tour Champions, Korn Ferry Tour, LIV Golf.
- **Time zone**: sets the zone for tee times.

## Data

The app uses ESPN's public golf feeds, which need no key:

- `site.api.espn.com/apis/site/v2/sports/golf/<league>/scoreboard` gives the current event and the season calendar.
- `site.web.api.espn.com/apis/site/v2/sports/golf/leaderboard?league=<league>&event=<id>` gives positions, thru, tee times, course, purse and the defending champion. The competitors are not in position order, so the app sorts them by `sortOrder`.

The league codes are `eur`, `champions-tour`, `ntw` and `liv`. Tee times come from timeapi.io. A render makes at most 6 requests. Refresh is 300 s.

## Debug

Pass `_debug` to `render_app` to swap in a mock state: `live`, `complete`, `suspended`, `final`, `pre` or `off`.
