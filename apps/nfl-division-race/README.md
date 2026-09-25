# NFL Division Race

Your NFL team's division race on a 192 x 32 panel.

- **race**: the division hangs down the left edge as a rafter banner: AFC red
  or NFC blue with the conference cut out of it and a star, and the direction
  in white beside it. The banner turns gold once the division is clinched or
  the season is over. Then the four club logos, left to right in standings
  order, each with its record and current streak (green W, red L) under it.
  First place is in gold (two golds means a tie at the top). Your team's
  record sits on a navy nameplate.
- **team**: the same banner, your club's logo and its record as the hero. The
  header says where it stands: 1ST / T-1ST / 2ND PLACE (gold when leading),
  CLINCHED or CHAMPIONS with a gold trophy, OUT OF THE RACE in red once it
  can no longer catch the leader, FINAL: 3RD PLACE after the season, KICKOFF
  SOON before week 1. Its division record is top right. Four labelled numbers
  on the right: SEED (green inside the top seven), STRK (green on a win
  streak, red on a losing one), DIFF (point differential, green positive, red
  negative), and GB (games behind) for a chaser or MAGIC (the magic number,
  gold at 4 or less) for the leader.

## Settings

| Setting   | What it does                                    |
|-----------|-------------------------------------------------|
| Your team | Picks the division (race page) and the club (team page). |

## Data

ESPN's public standings feed (`site.web.api.espn.com/apis/v2/sports/football/nfl/standings?level=3&seasontype=2`),
which nests the standings by conference and division. No key needed. The app
pins the regular season, so preseason records never show, and it sorts each
division by playoff seed (ESPN's own tiebreak ranking) because ESPN does not
keep a finished season in order. It refreshes every 30 minutes and caches the
feed for the same time.

Between seasons the feed keeps last season's final standings until early
August, so the panel shows that final table (gold banner, champion in gold)
until the new season's 0-0 table arrives; from then until week 1 the team
page says KICKOFF SOON.

Clinched and eliminated use wins only (17 games): a leader has clinched when
the runner-up can no longer reach its wins, and a club is out when it can no
longer reach the leader's. Tiebreakers can decide a race a week earlier than
the panel shows.

If ESPN is unreachable, the panel says so on a grey rail.

The team logos are the 40 x 24 pixel art from Fantasy Football News.
