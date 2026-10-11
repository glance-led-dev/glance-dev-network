# College Playoff Bubble

The 12-team College Football Playoff race on a 192 x 32 panel, with every FBS school's logo. No key needed.

## Pages

- **bracket**: one quarterfinal path per frame. The two first-round logos, with their seeds, sit over a drawn bracket that runs into the bye seed's big logo, next to a gold BYE ticket. The paths are 1 v 8/9, 2 v 7/10, 3 v 6/11 and 4 v 5/12. A locked place carries its mark by the seed: a gold crown for a projected Power 4 champion, a gold padlock for the Group of 6 bid or Notre Dame. The bye seed's mark and tag (SEC, B10, G6, IND...) sit under SEED.
- **bubble**: three frames.
  - LAST 4 IN: the lowest four at-large teams. Each shows its rank with a green up or red down chevron for its move in the poll, and its lead over the first team out in poll points (PTS GAP, e.g. +160).
  - FIRST 4 OUT: the same, with how many points each team is short of the last team in (e.g. -160).
  - AUTO BIDS: the four projected Power 4 champions (crown and league) and the best Group of 6 team (padlock and G6).

  Once the committee ranks there are no poll points, so the rows show each team's record and the title says which poll it is.
- **myteam**: pick your school. The name row carries its rank, poll movement and record. The status is the hero: SEED 8, 2ND OUT or UNRANKED, with the school's crown or padlock when it holds a lock. To its right:
  - for seeds 5-12, the first-round opponent's logo, with HOSTS SEED 9 or AT SEED 5 under it;
  - for seeds 1-4, the BYE ticket, with PLAYS 8/9 WINNER under it;
  - for a team outside the field, its points gap to the last team in.

Frames advance one per refresh (300 s).

## Format

These are the 2026 rules, set by the CFP management committee in January 2026:

- **12 teams.** Automatic places go to:
  - the ACC, Big 12, Big Ten and SEC champions, whatever their ranking;
  - the highest-ranked Group of 6 team (American, CUSA, MAC, Mountain West, Pac-12 or Sun Belt), champion or not;
  - Notre Dame, whenever it is ranked in the top 12.

  The other places (seven, or six with Notre Dame in) go at large to the highest-ranked teams left.
- **Straight seeding by ranking.** The top four teams get first-round byes whether or not they won their conference. A qualifier ranked outside the top 12 takes the lowest seed. The bracket is never reseeded.
- **First round:** seeds 5-8 host seeds 12-9 (5 v 12, 6 v 11, 7 v 10, 8 v 9).

If the format changes, the rules live in `build()` and `PATHS` in `app.star`.

## Projection

- **Rankings used:** until the committee's own rankings appear in November, the AP poll stands in. The panel says **PROJ**, and the source poll is named on the page (for example "AP WK 4"). Once ESPN's feed carries the College Football Playoff rankings, the app switches to them and the tab says **CMTE**.
- **Projected champions:** the highest-ranked team in each Power 4 conference is treated as its champion. The teams receiving votes are read too, in points order, so an unranked champion or Group of 6 team is still found. If one can't be found, its place shows as a blank TBD shield.
- **Records:** ESPN lists every team receiving votes with a 0-0 record, so those records aren't shown.
- **Selection Day:** from noon ET on Selection Day (the Sunday after the first Saturday in December; 6 Dec 2026) the real field is set and ESPN's feed drops the committee poll. From then until the final AP poll, the panel says THE FIELD IS SET instead of projecting.
- **Before and after the season:** before any poll is out the panel says NO RANKINGS YET. Once the final AP poll is published it says SEASON COMPLETE.

## Data

ESPN's `site.web.api.espn.com/apis/site/v2/sports/football/college-football/rankings` (about 640 KB), cached for an hour. Conferences come from the app's own FBS table.

## Logos

`assets/L/<ABBR>.png` are 40 x 24 and `assets/S/<ABBR>.png` are 24 x 18. Both use the shared FBS logo set's file names, so polished logos can be copied straight over. The one exception is Texas A&M: `TA&M.png` in the shared set is `TAMU.png` here.
