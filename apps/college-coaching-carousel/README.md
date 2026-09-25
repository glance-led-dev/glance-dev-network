# College Coaching Carousel

Your college football program's head coach, on a 192 x 32 Glance panel.

- **coach** - the school logo, the coach's name and a pixel-art coach in the
  school's kit: a polo in the main colour and a visor in the second colour.
  The collar turns red once this season's losses lead by two and gold while
  the team is unbeaten. The top line is the coach's record at the school
  (`212-128 AT IOWA`, the verified total through 2025 plus this season). The
  bottom line has one pennant per season at the school, with this season's in
  gold. A first-season coach gets a NEW HIRE chip and the name of the coach
  he replaced (`REPLACES MOORE`).
- **resume** - this season's record as the hero (green while unbeaten, red
  once the losses lead by two), the AP Top 25 rank as a gold badge with last
  week's move shown as a green or red arrow, the conference standing
  (`1ST IN MWC`) and a wooden trophy case. The case holds one cup per title
  the coach has won as a head coach, with the year under each cup: gold for
  FBS national titles, silver for FCS, bronze for D-II / D-III / NAIA and
  silver Lombardis for Super Bowls. The line under the case names the coach,
  so the titles aren't read as the school's.
- **tenure** - the 14 FBS head coaches who started before 2020, three per
  frame (the frame changes every 15 minutes). Each gets a logo, a rank
  (ties show as `T-5`), years in charge and a gold or grey bar scaled to
  Ferentz's 28 seasons. Your school's coach is underlined in gold.

One setting: **School** (any of the 138 FBS programs). No key needed.

## Data

- ESPN site API (`site.web.api.espn.com/.../college-football/teams/<id>`):
  record, conference standing and school colours. Cached 1 hour.
- ESPN core API: `.../seasons/<yr>/teams/<id>/coaches` for who the head coach
  is right now (cached 6 hours), and `.../rankings/1` for the AP poll (33 KB,
  cached 1 hour). The team feed's own rank switches to the CFP ranking in
  November, so the AP badge doesn't use it.

ESPN's coaching *history* isn't reliable enough to count tenure from. It has
bogus seasons before 2014, usually credits a December hire to the season he
was hired in, and misfiles some coaches. So each coach's first season comes
from a table of historical facts keyed by ESPN coach id, and that table is
only used while ESPN still lists the coach at the school. An interim season
counts only if the coach ran regular-season games (Swinney 2008), not if he
coached only the bowl (Freeman's first season is 2022). A coach who isn't in
the table, such as a later hire, falls back to ESPN's own seasons.

Records at the school come from a second table: wins and losses through the
2025 season, in the school's official credit. That means every stint, the
interim games he coached, and vacated wins removed (Iowa 2023). Each total was
summed from ESPN's season records and checked against the coach's per-season
record table from the school media guides. Coaches the sources disagree on
are left out and show `SINCE <year>` instead. This season's live record is
added on top, and only for 2026, so a stale total is never shown.

Championship counts cover titles won as a head coach through the 2025 season.
