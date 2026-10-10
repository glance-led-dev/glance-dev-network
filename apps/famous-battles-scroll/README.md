# Famous Battles

A different famous battle every day, from the Bronze Age to the twentieth
century: who fought, where, what happened and what changed because of it,
with the place marked on a world map. 73 battles, no key needed.

## Settings

| setting | what it is |
|---|---|
| **Era** | Narrow the roster to ancient, medieval, gunpowder or modern. |
| **Region** | Narrow it to where the battle was fought, using the modern region rather than whatever the place was called at the time. |

If a combination has nothing in it, the panel says so rather than showing
you the wrong period.

## The pages

- **Battle** - the battle of the day drawn in silhouette, with its name and
  year. Nine shapes carry the kind of fighting: a hoplite shield, an oared
  galley, a helm and sword, a curtain wall, a field gun, a ship of the
  line, a tank, a battleship and an aircraft.
- **Story** - what happened and what it changed, the war it belonged to,
  and one line of live summary from Wikipedia.
- **Where** - the place marked on a world map, with the country, the war
  and the region.

## Where the facts come from

The roster is **curated**, not queried, and every date was checked against
the prose of the Wikipedia article. Wikidata was tested first on a
comparable roster and was not usable: it had no date at all for more than
half the entries and no country for any of them.

The map positions are **not** guessed. Wikipedia's summary endpoint returns
coordinates for geolocated articles, and those were converted to cells on
the world map directly. Seven entries carry no coordinates, mostly because
they are campaigns rather than single points: Hastings, the Spanish Armada,
Lützen, Borodino, the Marne, Britain and Berlin. Those were placed by hand
at a representative location through the same formula.

That map is not a full equirectangular sheet. It spans 84N to 58S, so
latitude covers 142 degrees over 32 rows rather than 180, and using the
full range would put every battle several rows too far south. The
conversion was checked by reproducing known country positions for Britain,
Japan and Australia exactly before any battle was placed.

Only the story page goes to the network, so the other two pages keep
working with it down.

## About the dates

A single year is tidier than history usually is. Sieges and campaigns ran
for months, and for the oldest battles historians disagree by decades:
Megiddo is given here as 1457 BC, and Kadesh as 1274 BC, both of which
depend on which Egyptian chronology you follow. Where a battle ran across
a boundary, the year given is the one it is normally filed under.

## A note on what this is

These were catastrophes for the people in them. The panel says who fought,
what happened and what changed, in the register a museum label uses. The
roster is deliberately global rather than a list of European victories: it
includes Red Cliffs, Talas, Sekigahara, Ain Jalut, Plassey, Isandlwana,
Omdurman and the Little Bighorn, and several entries record defeats for the
side that wrote most of the surviving histories.

## Notes

- One request per render on the story page only, cached for an hour.
- The battle is chosen from the day of the year, with the year shifting
  where the sequence starts, so the same date does not land on the same
  battle every year.
- The curated name is always what is displayed. Two titles resolve through
  a redirect to an accented spelling, and the panel shows the plain form
  because no bundled font carries those letters.
