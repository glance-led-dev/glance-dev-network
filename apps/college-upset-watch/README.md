# College Upset Watch

The week's biggest college football upsets on a 192 x 32 panel. No key needed.

## Pages

- **upsets** - one upset per 5-minute frame, most shocking first. The winner's
  logo sits on the left, the ranked team it beat on the right with a lightning
  strike in the tier colour through its logo, and the final score between
  them (OT marked beside it). A tier pill says how big it was: SHOCKER (14+
  point underdog), BIG UPSET (7+), UPSET, or RANKED FALLS (a ranked team lost,
  but the winner was the betting favourite). A blue ROAD tag marks a road win.
  A pixel underdog next to "+16.5" is the spread the winner was getting, and
  "ML +575" its moneyline. The loser's rank sits in a cracked badge with a
  falling arrow.
- **carnage** - how many ranked teams fell this week, with the logos of the
  fallen over rank badges coloured by tier (red shocker, orange big upset,
  amber upset, purple favoured winner).

RANKED FALLS cards only join the rotation in a week with fewer than two real
upsets; they always count on the carnage page. A week where every favourite
held shows a green CHALK WEEK screen once the whole slate is final; while
games are still being played it shows NO UPSETS YET with how many are final.

## Settings

- **Upsets to show** - ALL UPSETS, or BIG UPSETS ONLY (7+ point underdogs, or
  an unranked team over the top 10 when no line is on record).
- **Your school** - optional. Its upsets, pulled off or suffered, lead the
  rotation, and its logo gets gold corner brackets.

## Data

- ESPN's college scoreboard (the week's Top 25 slate). Finals only; a game in
  progress is never shown.
- Ranks are ESPN's AP / CFP rank: the AP poll until the first College Football
  Playoff ranking (early November), then the CFP Top 25.
- The current week is used once it has an upset on the board or half its games
  are final. Before that (a Thursday, a Saturday morning) the previous week
  shows. Bowl season shows bowl finals, falling back to the last regular week.
- ESPN's scoreboard drops the betting line when a game ends, so each upset's
  closing line and moneyline come from ESPN's odds endpoint (DraftKings),
  cached for a day.
- An upset is a final where a ranked team lost to an unranked or lower-ranked
  team. Unranked-vs-unranked results are not covered: the Top 25 slate doesn't
  include them.
- At most 8 requests per render: 2 scoreboards and up to 6 closing lines. When
  more than 6 ranked teams lose, the rest are graded by rank alone.

## Logos

`assets/L/` holds the 40 x 24 hero logos and `assets/S/` the 24 x 18 list
logos, one per FBS school, named by ESPN abbreviation. Texas A&M is `TAM.png`,
because asset names can't contain `&`. FCS schools, which have no logo in the
set, get a box in the school's colour with its abbreviation.
