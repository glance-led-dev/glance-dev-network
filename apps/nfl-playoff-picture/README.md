# NFL Playoff Picture

If the season ended today: one conference's seven playoff seeds, drawn as the
wild-card bracket they would make, plus the teams chasing the last spot.

## Pages

- **bracket**: seven club logos in bracket order, `1 | 2 7 | 3 6 | 4 5`. The
  top seed sits alone under a gold crown and **BYE**. A bracket in the
  conference colour joins each wild-card pairing. Every logo wears its seed
  as a tab on its corner: a solid tab is a division winner (gold for the bye),
  a bare numeral a wild card. The record sits alone under the logo and turns
  green once ESPN marks the club clinched; a tie count is drawn dim, so two
  tie records side by side still read as two. The right of the title row shows
  the table's state: **CLINCHED** with a green check, **2025 FINAL** when the
  table is last season's final one (the title then reads **PLAYOFF FIELD**),
  or the season year.
- **hunt**: the next three teams outside the field (seeds 8 to 10, skipping
  any ESPN marks eliminated). Each one gets its full-size logo with its seed
  tab, plus its record, how many games back of the 7th seed it is (**TIED**
  when level on record) and its current streak (green W, red L). The gold
  ticket at top right is the last playoff spot: who holds it, and at what
  record.

## Settings

| Setting | Values |
|---|---|
| Conference | AFC, NFC |

## Data

ESPN standings (`site.web.api.espn.com/apis/v2/sports/football/nfl/standings`,
one ~160 KB call, no key). It carries `playoffSeed`, the record, the
`clincher` flag, the streak and the season year. Refreshes every 30 minutes, and the call is cached for the
same time.

## Screens

- **Offline**: a football on a grey rail, "ESPN OFFLINE".
- **Preseason** (no games played): a Lombardi on a green rail, "NO GAMES
  PLAYED YET".
- **Hunt page, late season**: once every non-playoff team is eliminated, it
  shows a Lombardi and "FIELD IS SET".
