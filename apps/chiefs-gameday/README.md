# Chiefs Game Day

A 128x32 Glance LED app that shows the Kansas City Chiefs' public game-day
status in the living room: kickoff countdown, live score with down and
distance, the final with a W/L, then the next game.

It displays only public NFL information. There are no accounts, no API keys,
no location inputs, and no personal data.

## Data

- ESPN public team schedule: `https://site.api.espn.com/apis/site/v2/sports/football/nfl/teams/12/schedule`
- ESPN public NFL scoreboard: `https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard`

No key is required. The schedule is cached for 180 seconds and the
scoreboard for 60 seconds. The app refreshes every 180 seconds. Kickoff
times are drawn in US Central Time (with US daylight-saving rules).

## Scenes

The one input, **Scene**, should stay on **AUTO** on the panel. The other
values only preview layouts and do not call ESPN:

- PREGAME, LIVE, FINAL, BYE, OFFSEASON, ERROR

## Preview locally

From a machine with the [GDN SDK](https://github.com/glance-led-dev/glance-dev-network) installed:

```bash
gdn validate .
gdn render . --input scene=AUTO --out previews/auto.png
gdn render . --input scene=LIVE --out previews/live.png
gdn studio .
```

Native 128x32 PNGs and 8x scaled copies live in `previews/`.

## Publish (not done)

Nothing has been published. To submit later: put this folder at
`apps/chiefs-gameday` in a fork of `glance-led-dev/glance-dev-network`,
run `gdn validate`, then use Glance Dev Studio's **Validate & Submit**
(or `gdn submit apps/chiefs-gameday`). That opens a pull request. The
Glance team reviews and merges it into the community catalog.
