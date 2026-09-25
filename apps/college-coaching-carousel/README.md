# College Coaching Carousel

Your college football program's head coach, on a 192 x 32 Glance panel.

Both school pages are a sideline scene: a chalk line and striped turf run
along the bottom, and the words sit on the things that stand there.

- **coach** - a big pixel-art coach (28 x 28) walks the sideline in the middle
  of the panel, headset on and clipboard out. He wears a polo in the school's
  main colour and a visor in its second colour. His collar turns red once
  this season's losses lead by two and gold while the team is unbeaten. On
  the left, a small school banner (the nickname, `CRIMSON TIDE`) hangs over
  the coach's name. Under the name is one pennant per season at the school,
  with this season's in gold. On the right, a stadium scoreboard shows the
  school logo and the coach's record at the school in amber bulbs
  (`212-128`, captioned `AT IOWA`): the verified total through 2025 plus
  this season. A first-season coach's board reads NEW HIRE over this
  season's record, and his strip names the coach he replaced
  (`REPLACES MOORE`).
- **resume** - this season on the scoreboard. The header, in the school
  colour, reads `2026 SEASON` and the conference standing (`1ST IN MWC`)
  when it fits. The record is in bulbs: amber, green while unbeaten, red
  once the losses lead by two. The AP Top 25 rank is a gold badge with last
  week's move as a green or red arrow. Beside the board is a wooden trophy
  case with one cup per title the coach has won as a head coach, with the
  year under each cup: gold for FBS national titles, silver for FCS, bronze
  for D-II / D-III / NAIA and silver Lombardis for Super Bowls. The line
  under the case names the coach, so the titles aren't read as the
  school's. A coach with no titles walks the sideline beside the board.

When ESPN can't be reached, a dark scoreboard on a dimmed sideline reads
ESPN OFFLINE, with a grey coach beside it.

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
are left out, and their scoreboard shows this season's record instead. This season's live record is
added on top, and only for 2026, so a stale total is never shown.

Championship counts cover titles won as a head coach through the 2025 season.
