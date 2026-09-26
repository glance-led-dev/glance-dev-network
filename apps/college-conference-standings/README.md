# College Conference Standings

FBS conference standings as a logo ladder, for any of the 11 FBS conferences
(including the Sun Belt's two divisions and the FBS Independents).

## Pages

- **ladder** - four schools at a time in standings order: rank, logo, conference
  record (white), and overall record (gray) with a green up or red down arrow for
  the current streak. A Top-25 school carries a gold AP-rank bug under its
  standing number. Schools level with first place on conference win percentage
  are gold and wear a crown; before any conference game has been played, the
  best overall records go gold on the overall row instead. A football marks the
  legend. The divider beside the conference name is split into one segment per
  frame, and the lit segment is the frame on screen. Frames step every refresh
  (2 minutes). The Sun Belt's division word (EAST / WEST) is white under the
  orange conference name.
- **leader** - the first-place school's full logo and name, with its AP rank and
  a gold conference trophy when the name leaves room. A shared lead reads
  "SEC CO-LEADER 5-WAY" and the hero rotates among the co-leaders every refresh;
  before conference play it reads "BEST OVERALL". The bottom row rotates too:
  conference and overall records with the streak (a flame for two or more wins
  in a row, ice for two or more losses), then points for / against / differential,
  then the record against AP Top-25 teams once one has been played. The Sun Belt
  alternates its East and West leaders.

## Settings

- **Conference** - SEC, Big Ten, Big 12, ACC, American, Mountain West, Sun Belt,
  MAC, Conference USA, Pac-12, FBS Independents.

## Data

ESPN's standings feed, one conference per request
(`site.web.api.espn.com/apis/v2/sports/football/college-football/standings?group=<id>`,
about 300 KB). Order is ESPN's own conference seeding; first place is decided on
conference win percentage, as the standings are kept. AP ranks come from the
same feed. Cached for 30 minutes.
No key needed.

## Logos

`assets/` holds a 24 x 18 (`<ABBR>_S.png`, ladder) and a 40 x 24 (`<ABBR>.png`,
leader) pixel-art logo for all 138 FBS schools, named by ESPN abbreviation.
`TA&M` is stored as `TAMU` and `M-OH` as `MOH`. A school missing from the set
draws its abbreviation in a box instead.
