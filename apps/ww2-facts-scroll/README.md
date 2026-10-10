# WW2 Facts

One dated fact from the Second World War every day, written the way a museum
places a placard: what happened, when, where, and why it mattered. 97 curated
entries, so the rotation runs for months without repeating.

No account, no API key, nothing to set up. The app works with the network
switched off.

## Settings

| setting | what it is |
|---|---|
| **Front** | Which part of the war the daily entry is drawn from. `ALL FRONTS` (default) uses the whole roster. Every other choice narrows it to one front, and each front has its own colour and its own artwork. |
| **Period** | Which years to draw from — `WHOLE WAR` (default), `BEFORE THE WAR` (the run-up, 1937 to August 1939), or one of three war periods. The timeline page dims the years outside the period you pick. |
| **Wikipedia line** | On by default. Adds one live line of supplementary context to the timeline page. Turn it off and the app makes no network request at all. |

A front and a period that together match nothing — `NORTH AFRICA` with
`BEFORE THE WAR`, say — falls back to the whole roster rather than showing an
empty panel. Every combination of the three settings renders.

## The pages

- **Event** — what and when. The front's artwork on the left, the date in the
  chip row, the title as the hero, and the place beneath it. A short title
  gets a large single line; a longer one drops to two smaller lines rather
  than being clipped.
- **Why** — why it mattered, in plain prose across the full width, with the
  key figure in the chip row already carrying the words that say what it
  counts.
- **Timeline** — where in the war the entry sits. The bar runs from 1937 to
  the end of 1945: the pale band is the war itself, the brighter band is the
  period you selected, and the marker is today's entry. Underneath sits one
  supplementary line, live from Wikipedia or from the app's own text.

## The fronts

Each front has a colour and a drawing, carried by the accent rail, the chip
and the timeline marker, so the front reads from across a room.

| front | colour | artwork |
|---|---|---|
| Western Europe | sky blue | fighter aircraft |
| Eastern Front | red | tank |
| Pacific & Asia | green-teal | aircraft carrier |
| North Africa | sand | tank under a desert sun |
| Atlantic & Sea | violet | convoy escort |
| Home Front | pink | searchlights over rooftops |
| Science & Code | cyan | Enigma rotors |
| War Production | steel | factory |
| Remembrance | bone | memorial flame |
| Conferences | olive | signed document |

## On the difficult entries

The roster includes the Holocaust, Babi Yar, Katyn, Nanjing, the Bataan and
Burma marches, the Bengal famine, the bombing of Dresden, and Hiroshima and
Nagasaki. Leaving them out would misrepresent the war. They are drawn in bone
white with a memorial flame, never in a front colour and never beside a
weapon, and the text gives the date, the place and the scale and then stops.
Where a figure is an estimate or is contested, the panel says so rather than
printing a false precision.

## Data

A curated table, written and checked by hand against the prose of the English
Wikipedia article named in each row. Live sources were tested for the core
facts and rejected: they carry no reliable date for a large share of
historical events, and several dates they do carry describe a predecessor
rather than the event named.

So **pages 1 and 2 never touch the network** — the panel cannot go blank.
Page 3 alone adds one line from Wikipedia's REST summary endpoint
(`/api/rest_v1/page/summary/<title>`, no key, one request per day, cached for
24 hours). That response is checked against the title it was asked for before
a word of it is drawn, because the endpoint silently redirects some titles to
a broader article — which is how a panel ends up captioning one battle with
another campaign's summary. Anything that fails the check, or any failed
request, falls back to the app's own curated line, and the page says which of
the two it is showing. The curated name is what the app displays, always;
the API's normalised title is never shown.

## Where sources disagree, and what this app chose

Every figure below is an estimate or is actively contested. The panel carries
the range or says the toll is disputed.

- **Total war dead** — the app uses **60–75 million**, which is what Wikipedia
  now states. The higher 70–85 million range is widely cited elsewhere.
- **The Holocaust** — "around six million", the form Wikipedia and memorial
  museums use. A narrower scholarly estimate is ~5.7 million; records are
  incomplete, so no exact count exists.
- **Auschwitz** — 1.1 million murdered, of about 1.3 million deported. The
  Soviet-era figure of 4 million stood on the memorial plaque until 1991 and
  is superseded.
- **Dresden** — 22,700–25,000, settled by the 2010 Dresden Historians'
  Commission. Much higher figures originate in Nazi propaganda.
- **Nanjing** — deliberately given as disputed. Scholarly estimates run from
  about 40,000 to over 200,000; China's official figure is 300,000.
- **Bengal famine** — about 2 million, within a published range of 800,000 to
  3.8 million.
- **Hiroshima and Nagasaki** — given as ranges (90,000–166,000 and
  60,000–80,000) covering deaths from blast and radiation to the end of 1945.
- **Okinawa** — civilian deaths are given as "tens of thousands"; published
  estimates range from 40,000 to 150,000.
- **Leningrad** — 872 days, and civilian deaths of one to one and a half
  million. The familiar "900 days" is a rounding.
- **Warsaw Ghetto Uprising** — at least 13,000 killed. The Stroop Report's
  56,065 is treated by historians as inflated.
- **T-34 production** — 57,000 by 1945. The commonly quoted 84,070 includes
  post-war and licensed production.
- **Women in war work** — the app cites the 50% rise in employed American
  women from 1940 to 1944, because the headline totals are inconsistent
  between sources.

Dates that are not the ones most often quoted:

- **Stalingrad** is dated **17 July 1942**, the Wikipedia infobox start. The
  familiar 23 August is when the assault on the city itself began.
- **El Alamein** ran 23 October to **4 November** 1942, not 11 November.
- **The Soviet invasion of Manchuria** is dated **9 August 1945**, the local
  date; the Wikipedia infobox gives 8 August. The difference is a time zone.
- **Chain Home** is dated **August 1938**, when the first five stations came
  on line, not 1937 and not 1940.
- **Italy's armistice** is dated 8 September 1943, the announcement; it was
  signed on 3 September and kept secret, and the panel says so.

Some entries describe a campaign, a programme or a whole war rather than a
single day — the Battle of the Atlantic, the Holocaust, the human cost, the
Liberty ships, the T-34, women in war work, the French Resistance, the
Tuskegee Airmen, the Burma Railway, the Bengal famine and the Katyn massacre
among them. Those carry a representative date, and the timeline marker should
be read as "about here" rather than as a single event.

**Not independently re-verified:** the Darwin raid death toll ("over 230";
published figures run 235–243) and the Philippine Sea aircraft losses ("about
600"). Both are well established but were not checked against article prose
alongside the rest.

## Notes

- The entry turns over once a day, from the day of the year, with a term that
  shifts the starting point each year so the same date does not land on the
  same entry every year.
- Every string drawn on the panel is folded to the glyph set the bundled fonts
  actually carry — they are uppercase-only and have no apostrophe. Accented
  letters fold to ASCII rather than disappearing.
- Where a line is abridged to fit, it ends in `..` so the cut reads as
  deliberate.
- `refresh` is hourly, which keeps the panel current through midnight; the
  Wikipedia request is cached for a day, so it runs at most once per entry.
