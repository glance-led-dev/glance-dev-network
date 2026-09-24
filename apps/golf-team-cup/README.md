# Golf Team Cup

A live board for golf's team match-play cups: the **Presidents Cup** (USA v
International) and the **Ryder Cup** (USA v Europe), laid out like a TV score
bug on a 192x32 panel.

## Pages

| Page | During a cup | Between cups |
| --- | --- | --- |
| `cup` | Hero scoreboard: pixel crests, big points totals (with a hand-drawn ½), cup / session / LIVE state, and a tug-of-war bar. Each team's points fill in from its own end, the dim extension shows the projection if every match on the course finished as it stands, and the gold gate is the winning line (15½ of 30, 14½ of 28). | Countdown to the next cup (days to go, venue, dates). |
| `board1` | The current session's matches, first half. One row per match: both sides' surnames, the leader lit and the trailer dimmed, and a status pill in the leader's colour (`2 UP` + holes played, `AS`, `3&2` + `F` when final, or the tee time). Live matches come first, then finished, then upcoming. | Final score of the cup that just finished (or the roll of honour when that can't be fetched). |
| `board2` | The rest of the session, plus a session-points line when there's room. Singles days (12 matches) run 6 per page in two columns. | Roll of honour (last four cups), or the upcoming cups. |

Between sessions the boards show the last session's results, switching to the
next session's pairings and tee times 12 hours before its first tee.

## Data

ESPN's public golf API, no key:

- `site.api.espn.com/apis/site/v2/sports/golf/pga/scoreboard` finds this
  week's event whose name contains "Presidents Cup" or "Ryder Cup".
- `site.web.api.espn.com/apis/site/v2/sports/golf/leaderboard?league=pga&event=<id>`
  has the team points (`competitions[0][0]`) and one list of matches per
  session (`competitions[1..]`).

Upcoming cup dates/venues and older results are small tables in `app.star`
(`CUPS`, `HISTORY`), so the between-cups screens work offline. Update `CUPS`
when a new venue or date is announced. If ESPN is unreachable during a cup's
dates, the hero says live scoring is unavailable instead of showing a
countdown.

## Settings

- **Time zone**: tee times and the countdown use this zone (daylight saving
  is computed in the app, no time API).
- **Clock**: 12-hour or 24-hour tee times.

Refresh is 120 seconds.

## Testing

`_debug` (not a manifest input, inert when installed) renders mock states:
`live`, `singles`, `final`, `pre`, `ryder`, `between`, `offline`.
