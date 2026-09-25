# Heisman Trophy History

Every Heisman Trophy winner from Jay Berwanger (1935) to Fernando Mendoza (2025),
on a 192 x 32 panel. No network and no key: the history is baked into `app.star`.

## Pages

- **winner** - the trophy itself, one winner every five minutes. The bronze
  stiff-arm statue stands in the centre of the panel on a walnut pedestal, with the
  winner's name engraved on its brass plate. Two spotlights flank it: the year in
  gold on the left, with the position on a jersey in the school's colours and a gold
  star when his team also won the national title that season (18 winners). The
  school logo is on the right.
- **plaque** - the museum placard for the same winner. It shows the full name, the
  year, the school and position, and the school's trophy shelf (his own wins lit:
  both of Griffin's). Below that is a line of history. When there's no history line,
  it shows where the win ranks for the school instead ("3RD OF 7 NOTRE DAME
  HEISMANS", "UCLA'S ONLY HEISMAN").
- **count** - the trophy case.
  - **A school:** one bronze statue per win with the year under each (title
    years sparkle and turn gold), how long since the last one, and the logo in the
    same right-hand spotlight as the winner page.
  - **A decade:** that decade's winners in order, each logo over its year, a
    star beside the title years.
  - **ALL WINNERS:** the schools with two or more wins, ranked (USC 8; Notre Dame,
    Ohio State and Oklahoma 7; Alabama 4; ...) with gold, silver and bronze medals.
    Then **by position**: every winner as one coloured column from 1935 to 2025
    (QB 40, backs 43, receivers 5, ends and corners 3).

## Setting

**Show:**
- `ALL WINNERS` (default) walks the whole list, about 7.5 hours per lap.
- A decade (`1930S` ... `2020S`) or a school limits every page to those winners.

## Notes

- Reggie Bush (USC, 2005) is included: he forfeited the award in 2010 and the
  Heisman Trust restored it in 2024.
- Chicago, Yale and Princeton no longer play FBS football, so they have no logo in
  the set. They show a block monogram in the school colour with the name under it.
- Names on the pedestal plate are set tight around the dots ("F. MENDOZA",
  "J.D. CROW"). A name too long for the plate drops to initials and a smaller face.
  The plaque page always has room for the full name.
- Update once a year: add a row to `WINNERS` each December.
