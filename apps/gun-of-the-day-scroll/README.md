# Arsenal Facts

A different piece of significant military engineering every five minutes,
written like a museum placard: what it is, who designed it, when it appeared,
and why it mattered. Four curated rosters — **guns, aircraft, vehicles and
ships** — 206 pieces in all, from a 1650 blunderbuss to a 2023 stealth
bomber.

## Settings

| setting | what it is |
|---|---|
| **Subject** | ALL, GUNS, AIRCRAFT, VEHICLES or SHIPS. On ALL the subject turns over with each piece, so the panel shows a rifle, then a fighter, then a tank, then a ship. |
| **Era** | Narrow to one period: before 1850, 1850 to 1899, 1900 to 1945, 1946 to 1989, or 1990 onward. |
| **Kind** | Narrow to one kind within the subject — pistols, bombers, tanks, submarines and so on. |

If a combination has nothing in it the panel says which setting is in the
way and what to change, rather than going blank. Asking for `SHIPS` and
`PISTOLS` together reads **PISTOLS ARE NOT SHIPS / SET SUBJECT TO GUNS OR
ALL**.

## The pages

- **Today** — the piece drawn large in silhouette, with its name and the
  year it appeared. The whole top of the panel is given to the artwork,
  because at this size detail needs the room; what kind of thing it is and
  where it came from are on the specs page.
- **Story** — why it mattered, in up to three lines of the largest type
  that will hold it.
- **Specs** — origin, year, designer and kind, laid out as a placard.

## How the piece is chosen

The panel redraws every five minutes, and a new piece is chosen on the same
beat, from `ctx.now.unix // 300`. With **Subject** on ALL the subject
advances first and the roster second, so you get one from each subject in
turn rather than a hundred guns before the first aircraft. Dividing the tick
by the number of active rosters means each roster steps forward once per
cycle, so nothing is ever skipped — every one of the 206 pieces comes round.

## The silhouettes

Sixty-two profiles, each a `c.sprite` string in a five-tone legend —
highlight, mid, dark, accent, glass. One `c.sprite` call costs a single draw
op no matter how many pixels it lights, which is what makes per-pixel art
affordable inside the 4096-op page budget; that is why these are sprites
rather than assemblies of rectangles.

The accent tone is the era colour, so the furniture, the tracks and the
waterline shift as the decades do and consecutive pieces look different at a
glance. Widths differ on purpose: a derringer is 48px beside a 170px musket,
and a Monitor is 123px beside a 172px Nimitz, because relative size is part
of the story. Guns and aircraft are centred in the art band; vehicles and
ships drop to the bottom of it so they sit on their tracks and their
waterline.

Aircraft are drawn in plan view, everything else in side profile.

## Where the facts come from

The rosters are **curated**, not queried. That was a deliberate choice after
testing the obvious live sources against the original firearms roster:

- **Wikidata** has no inception date at all for 41 of those 71 pieces, and
  no country of origin for a single one of them. Several dates it does
  carry describe something other than the piece named: it dates the
  Charleville musket to 1675, which is when the armoury was founded rather
  than when the 1717 pattern appeared, and its dates for the M1 carbine,
  the MP 40 and the M2 Browning each belong to a predecessor model.
- **Wikipedia's short descriptions** range from excellent to the single
  word "Revolver".

So the placard facts are written here and checked against the prose of the
Wikipedia articles. The last field of every entry records which article a
piece was checked against — that is provenance, not a fetch.

**The app makes no network requests at all.** An earlier version put one
line of live Wikipedia summary at the foot of the story page; it was
dropped so the curated text could have a third line instead, which is a
better use of the same 32 pixels. Nothing here can fail, and the panel
needs no connection.

## About the dates

A year on a placard is tidier than history usually is. These are the
**commonly cited** year a design appeared, was adopted or was commissioned,
and sources disagree by a year or two on plenty of them, because a design
year, a patent year, a first production year and an adoption year are four
different things. The Colt Single Action Army was designed for the 1872
trials and adopted in 1873; the StG 44 carried two earlier designations
before it got that name in 1944; a warship has a launch date and a
commissioning date that are rarely the same year.

## Notes

- The story text sizes itself: three lines of 5x7 carry about 84
  characters, and the block is centred, so a short entry does not leave a
  hole where a third line would have been.
- Where the designer field is blank it reads NO SINGLE DESIGNER, which is
  the honest answer for a pattern like the Brown Bess or a whole type like
  the blunderbuss. It does not claim that history failed to record a name.
- This is a history app. It covers what a piece was, who made it and what
  changed because of it, in the same register a museum label would use.
