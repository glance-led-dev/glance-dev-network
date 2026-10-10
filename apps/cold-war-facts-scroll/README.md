# Cold War Facts

A different Cold War entry every day, written in the register of a museum
placard: what happened, when, where, and why it mattered. 90 curated entries
spanning 1945 to 1991.

There is nothing to set up. No API key, no account, no location. The app picks
today's entry from its own table, so it works on a panel that has never had a
network connection.

## The three pages

| page | what it shows |
|---|---|
| `headline` | The theme chip and its artwork, the title at the largest size that fits, the full date, and a timeline bar marking where in 1945–1991 this date sits. |
| `story` | Where it happened, and what happened, in up to three lines. Also carries the filter in force and this entry's position in the rotation (`1960S 7/26`). |
| `legacy` | Why it mattered, plus one short supplementary line from Wikipedia, credited on the page. |

Six themes, each with its own colour and its own drawing: **Iron Curtain** (a
wall in section), **Arms Race** (a missile on its gantry), **Space Race** (a
satellite), **Proxy Conflict** (a globe), **Espionage** (a keyhole plate), and
**Thaw and Collapse** (a clock with its hands backed off midnight). The artwork
is drawn from primitives rather than sprite strings, so a course of brickwork
can be restaggered a pixel at a time.

## Settings

- **Theme** — narrow the rotation to one strand of the era, or `ALL`.
- **Decade** — narrow it to one decade, or `ALL`. `1940S` runs from 1945;
  `1990S` runs to the dissolution of the USSR in December 1991.
- **Wikipedia line** — on by default. Turn it off and the app makes no network
  call at all.

A theme and a decade together can legitimately match nothing — there is no
1990s space-race entry. Rather than show a blank panel, the app keeps the theme,
widens the decade, and says so on the `story` page (`NO 1990S ENTRY`).

## Rotation

`idx = (ctx.now.yday - 1 + ctx.now.year * 3) % len(pool)` — one entry per day,
with the year term shifting where the sequence starts so the same date does not
land on the same entry every year. With all 90 entries in play the cycle runs
about three months.

## Data

**The table is the app.** Every word on `headline` and `story` comes from the
curated table in `app.star`, which is why those two pages cannot fail: they make
no network call at all. Live structured sources were tested against a comparable
history roster first and were not good enough to build on — Wikidata had no
inception date for 41 of 71 items and no country for any of them, and several
dates it did carry described a predecessor rather than the thing named.

**The one live call** is on `legacy` only: Wikipedia's REST summary endpoint
(`/api/rest_v1/page/summary/<Title>`), keyless, with a User-Agent and a 86400s
ttl matching `refresh`. It reads the `description` field — the one-line
descriptor, which is already caption-shaped — and falls back to `extract` only
if that is missing. The endpoint silently redirects some titles to a generic
article, so **the panel always draws the curated title and never the one that
comes back**. If the call is switched off, fails, offline, or the entry has no
clean ASCII article title, the row shows the curated place and date instead.
That is a fallback, not an error state, so the rail keeps its theme colour.

Dates were checked against Wikipedia article prose before shipping. Two
corrections came out of that check: Klaus Fuchs was arrested on **2 February
1950**, not 3 February, and the Gdańsk Agreement of 31 August 1980 did not found
Solidarity — the national federation followed on 17 September and was registered
on 10 November.

## Where sources disagree

The panel attributes contested claims rather than asserting them. The cases
that matter:

- **Nuclear test dates are local dates.** Ivy Mike is dated 1 November 1952 and
  Castle Bravo 1 March 1954, both local to the test site; in GMT they fall a day
  earlier. Sputnik 1 is dated 4 October 1957 UTC.
- **The Gulf of Tonkin.** The reported second attack of 4 August 1964 almost
  certainly never happened — the declassified 2005 NSA study, McNamara and Giáp
  all agree no North Vietnamese vessels were present. The entry says so.
- **The B-59 submarine.** The popular account in which one officer
  single-handedly vetoes a nuclear launch rests on uncorroborated oral testimony
  and is disputed by recent scholarship; the entry says the account is disputed
  rather than repeating it.
- **Chernobyl.** ~30 acute deaths are settled. Long-term projections are not:
  WHO and the Chernobyl Forum give 4,000–9,000 for the most-exposed populations,
  the TORCH report 30,000–60,000, and higher figures exist that their own
  publishers have distanced themselves from. The entry gives the acute figure and
  says the long-term tolls differ.
- **Casualty figures generally.** Hungary 1956 (~2,500 Hungarian and ~700 Soviet
  dead), Afghanistan (Soviet dead 14,453 officially against historian estimates
  up to ~26,000; Afghan deaths estimated from ~562,000 to ~2 million), Chile
  (~3,065–3,216 killed and disappeared across the Rettig and Valech commissions),
  and My Lai (347 per the US Army's Peers Inquiry, 504 per the Vietnamese
  memorial) are all given as ranges or attributed to whoever counted them.
- **Lumumba.** The killing was carried out by Katangan authorities with Belgian
  personnel present; Belgian, US and UK roles in enabling it are still argued
  over, and the entry says that rather than naming a culprit.
- **Multi-day events get their opening date.** The East German uprising began
  with strikes on 16 June 1953 and was suppressed on the 17th. Tet began on 30
  January 1968 and spread countrywide the next day. Poland's 1989 election ran in
  two rounds, 4 and 18 June. The Warsaw Pact's command structures were dissolved
  in February 1991, five months before the alliance formally ended on 1 July.
- **Place names are period names.** Sputnik 1 and Laika launched from the
  Tyuratam range; "Baikonur" was applied to the site from 1961, so the earlier
  entries say Tyuratam and the later ones Baikonur. Congo independence is dated
  from Léopoldville, Chernobyl from Pripyat in the Ukrainian SSR.

## Tone

Where an entry touches repression, coups, nuclear near-misses or mass death it
gives the date, the place and the scale plainly, and stops there. No graphic
detail, nothing sensationalised, nothing glorified, and no side of the era is
spared or singled out: the roster carries My Lai and the Guatemala and Iran
coups alongside Hungary 1956, Poznań and the Prague Spring.
