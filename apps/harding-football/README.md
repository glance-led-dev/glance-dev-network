# Harding Football for Glance LED

Harding Bisons NCAA Division II football score on a 64x32 Glance panel,
refreshed every 5 minutes. No bridge needed — the app fetches the NCAA
scoreboard feed directly (a plain public GET, which is all Glance apps
can do).

## What it shows

A football icon and a status line on top, then:

- **Live:** a two-row scoreboard (away team over home team), Harding in
  gold, with the period + clock in the header (e.g. `3RD 1:47`, green).
- **Final:** the same scoreboard with `FINAL` in the header — green if
  Harding won, red if they lost. The losing side is dimmed.
- **Before kickoff:** the opponent (`VS` at home, `AT` on the road), the
  kickoff day + time in gold (e.g. `SAT 2:00PM`), and the date. Times are
  Central, Harding's home time zone; the feed gives Eastern and the app
  converts it.
- **Bye week / no game:** `NO GAME THIS WEEK`.
- **Feed down:** `NO SCORES` with the reason.

In the scoreboard the opponent is shown by its official NCAA 6-letter code
(e.g. `S NAZ` for Southern Nazarene, `ARKTEC` for Arkansas Tech).

## Data source

`https://ncaa-api.henrygd.me/scoreboard/football/d2/current/all-conf`
— the free ncaa-api proxy for the NCAA's own Division II scoreboard,
current week, all conferences. The app finds the game with Harding in it.
If the current week's feed has no Harding game (bye week), it falls back
to last week's feed so the panel keeps showing the most recent final.

There are no settings.
