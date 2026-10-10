# NFL Bye Week Tracker

Which NFL teams are resting this week and next, and when your own team's bye
comes. Made for setting fantasy lineups: a bye is the one week a lineup can
be wrecked by the schedule rather than an injury. The crescent moon is the
app's mark - a bye is the week a club sleeps.

## Pages

- **thisweek**: the teams on bye this week, as a row of their logos. Weeks
  with one or two byes also show each team's nickname. Weeks with five or six
  byes split into two frames that swap every 5 minutes (a 1/2 counter shows
  there is more), and the team count turns red-orange - that is the week to
  plan around. A week without byes shows the NFL shield, NO BYES in green,
  and the whole league as a 32-tile mosaic in club colours, one column per
  division, every tile lit because every team plays.
- **nextweek**: the same for next week, so you can plan ahead.
- **myteam**: your team's logo, a big crescent moon beside its bye week, and
  on the right a countdown (THIS WEEK in amber, NEXT WEEK / IN N WEEKS in sky
  blue, BYE DONE in green) over the game it comes back for (BACK @ SEA), or,
  once the bye is done, how many games are left. Beneath is the season as
  18 cells: won weeks green, lost red, a tie white, weeks ahead dark, a
  small moon in the bye week, and a white tick under the current week.

Out of the regular season the week pages say so (PRESEASON / PLAYOFFS /
OFFSEASON) with the league mosaic dimmed, instead of going blank.

## Settings

- **Your team**: the team shown on the myteam page.

## Data

ESPN's public NFL scoreboard and team schedule (`site.web.api.espn.com`), no
key needed. A team's bye is worked out as the one regular-season week missing
from its 17 games (ESPN's own `byeWeek` field was stale for several 2026
teams, so it is only a fallback). The current week is cached for 1 hour.
Specific weeks and team schedules are cached for 12 hours, because byes are
fixed for the season.

Team logos are the 40 x 24 pixel art from Fantasy Football News.
