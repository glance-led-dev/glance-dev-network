# Harding Football for Glance LED

Harding Bisons NCAA Division II football score on a 64x32 Glance panel,
refreshed every 5 minutes. No bridge needed — the app fetches the NCAA
scoreboard feed directly (a plain public GET, which is all Glance apps
can do).

## What it shows

- **Live:** Harding's score in gold on the left, opponent's in white on
  the right, with the period + clock underneath (e.g. `3RD 1:47`, green).
- **Final:** same scores, with `FINAL` underneath — green if Harding won,
  red if they lost.
- **Before kickoff:** `VS` with the kickoff day + Central time underneath
  (e.g. `SAT 3:00PM`). The feed gives Eastern time; the app converts it.
- **Bye week / no game:** `NO GAME THIS WEEK`.
- **Feed down:** `NO DATA` with the reason.

The opponent is shown by its official NCAA 6-letter code (e.g. `S NAZ`
for Southern Nazarene, `OK BAP` for Oklahoma Baptist, `ARKTEC` for
Arkansas Tech).

## Data source

`https://ncaa-api.henrygd.me/scoreboard/football/d2/current/all-conf`
— the free ncaa-api proxy for the NCAA's own Division II scoreboard,
current week, all conferences. The app finds the game with Harding in it.
If the current week's feed has no Harding game (bye week), it falls back
to last week's feed so the panel keeps showing the most recent final.

The `Feed URL` setting is optional and normally left blank (the app uses
the default above). It exists so the feed can be pointed elsewhere if
the default ever moves.

## Load it in Studio

1. Copy `apps/harding-football/` into the `apps/` folder of your cloned
   Glance repo (the same clone you used for dexcom-glucose).
2. Open Studio (`studio.bat`), open the Harding Football app.
3. No settings to fill in — **Save & Render** and you should see the
   current score. (Today's game is live while it's on; otherwise you'll
   see the last final or the next kickoff.)
4. Publish from Studio the same way as dexcom-glucose when ready.
