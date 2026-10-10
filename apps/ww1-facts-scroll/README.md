# WW1 Facts

A different First World War fact every day, written the way a museum writes a
placard: what happened, when, where, and why it mattered. 103 curated entries
covering 1914 to 1918, the alliances and crises that led into the war, and the
treaties, memorials and remembrance that followed.

No account, no key, nothing to set up. The panel picks the day's entry itself.

## The pages

- **Headline** - the theatre chip in its own colour, the full date, the title
  of the entry, and a timeline bar showing where in the war that day sits,
  running from the declaration on 28 July 1914 to the armistice on
  11 November 1918. Ticks on the bar mark the start of 1915, 1916, 1917 and
  1918. Entries that fall outside the war - the Triple Alliance, the Treaty of
  Lausanne - get `BEFORE THE WAR` or `AFTER THE ARMISTICE` and their year
  instead of a marker pinned to the end of a bar it does not belong on.
- **Scene** - drawn artwork for the entry, the place, and one sentence on what
  happened.
- **Legacy** - why it mattered, and one supplementary line along the bottom.

## Settings

| setting | what it is |
|---|---|
| **Front or theatre** | Narrows the rotation to one part of the war. `ALL FRONTS` (default) uses the whole roster. A single theatre gives a shorter, deeper rotation, so it comes round sooner. |
| **Year** | Narrows the rotation to one year. `BEFORE 1914` covers the alliances, the naval race and the Balkan crises; `AFTER 1918` covers the peace treaties and the memorials. |

Combining the two can select nothing - there is no air-war entry before 1914.
The panel says so and names the two settings to widen. That is not an error
screen; it is the honest answer to the question that was asked.

## The roster

103 entries, by theatre:

| chip | colour | entries | covers |
|---|---|---|---|
| ROAD TO WAR | bronze | 10 | alliances, the naval race, the Balkan crises, the July crisis |
| WESTERN FRONT | khaki gold | 16 | Belgium to the Meuse-Argonne |
| EASTERN FRONT | steel blue | 8 | Tannenberg to Brest-Litovsk, and the Russian revolutions |
| ITALY & BALKANS | alpine green | 9 | Serbia, the Isonzo, Caporetto, Salonika, Vittorio Veneto |
| OTTOMAN FRONTS | desert orange | 12 | Gallipoli, the Caucasus, Mesopotamia, the Arab Revolt, Palestine |
| WAR AT SEA | teal | 10 | Coronel to Scapa Flow, the blockade and the U-boat campaign |
| WAR IN THE AIR | pale sky | 7 | the first air victory to the Red Baron |
| BEYOND EUROPE | violet | 9 | Africa, the Pacific, China, India, and the troops the empires raised |
| HOME FRONT | rose | 10 | munitions, conscription, rationing, the Easter Rising, the 1918 influenza |
| ARMISTICE & AFTER | silver | 12 | the armistices, the treaties, the memorials |

By year: 7 before 1914, then 22 in 1914, 14 in 1915, 13 in 1916, 17 in 1917,
22 in 1918, and 8 after 1918.

The rotation is `(day of year - 1 + year * 3) % entries`, the house idiom, so
the same calendar date does not land on the same entry every year.

## On the hard entries

Several entries are about gas, genocide, famine, the sinking of ships full of
men, and the killing of civilians at home. They are in because leaving them
out would misrepresent the war. They are written the way a memorial museum
writes them: the date, the place, the scale, and nothing else. No adjective
does work the fact can do on its own, there is no graphic detail on the panel,
and nothing is glorified. The hardest entries are deliberately given the
quietest artwork - a line of walking figures, a row of grave markers.

## Where the data comes from

**The roster is curated and lives in `app.star`.** Live structured sources were
tested for this and rejected: Wikidata carries no inception date for a large
share of events of this kind, and several dates it does carry describe a
predecessor of the thing named. Every date here was checked against the prose
of the linked article rather than an infobox field.

**One live call, on one page.** The `legacy` page asks Wikipedia's REST summary
endpoint for the entry's article and draws its one-line `description` field
along the bottom - the field is already written as a single line ("1916 battle
of the First World War"), which is the only shape that fits a 34-character
strip. An `extract` clipped to 34 characters is a fragment, not a fact.

- **The live line is used only if it fits the strip whole.** Clipping one is a
  factual loss, not a cosmetic one: Wikipedia describes the Somme as "WWI
  battle pitting France and Britain against Germany", and cut to 34 characters
  that reads "WWI BATTLE PITTING FRANCE AND BRITAIN", as though France and
  Britain had fought each other. Anything that does not fit whole is dropped in
  favour of the curated note - which always fits, and is usually the better
  line in any case, since "57,470 BRITISH CASUALTIES DAY 1" says more than a
  genre label does.
- The marker at the left of that strip is **blue when the line came off the
  wire** and **the theatre colour when it is the curated note** that ships with
  the entry. Either way the strip says something true and complete.
- The call is cached for a day and the URL only changes when the entry does,
  so a panel on its normal refresh makes one uncached request a day against a
  budget of eight per render.
- **Expect the curated note most days.** Only about a third of the articles
  have a description short enough to fit whole, so two entries in three show
  the curated line. The live line is a bonus, not the design.
- `headline` and `scene` never touch the network, so the two pages carrying the
  title, the date, the artwork and the prose cannot fail.
- The endpoint silently redirects some titles to a generic article, so the
  curated title is always what the panel draws. The API's own normalised title
  is never displayed.

## Dates, and where sources disagree

- **Russian dates are New Style.** Russia used the Julian calendar until 1918,
  so the February Revolution is dated 8 March 1917 and the October Revolution
  7 November 1917 - the Gregorian dates on which they happened. The entries say
  so on the panel.
- **Casualty figures for the largest battles are ranges, not counts.** Verdun
  and the Somme in particular have no agreed total; the figures here are the
  commonly cited ones rather than any single authority's. Where a figure is a
  single army's loss on a single day, such as the 57,470 British casualties on
  1 July 1916, it is much better attested than a battle total and is given as
  such.
- **The Armenian Genocide death toll** is given as about 1 million. Scholarly
  estimates run from roughly 600,000 to 1.5 million; the entry uses the round
  figure most commonly cited and dates the start to 24 April 1915, the arrest
  of Armenian community leaders in Constantinople, which is the date marked as
  Remembrance Day.
- **The 1918 influenza death toll** is given as at least 50 million. Estimates
  range from 17 million to 100 million; 50 million is the figure most often
  quoted and is stated as a floor, not a total.
- **Gallipoli** appears twice, for the landing and for the evacuation, and both
  point at the same article.
- **The Turnip Winter** is dated 15 December 1916 as a marker for the winter of
  1916-17, which is a season rather than a day. It is the only entry in the
  roster whose date stands for a period rather than an event.
- **The Fokker Scourge** is dated 1 July 1915, the first victory by a Fokker
  Eindecker with synchronised gun; the period it names runs to early 1916.
- **Bosnia was annexed on 6 October 1908** here; sources vary between the 4th,
  the 5th and the 6th.
- **"Serbia accepted nearly all of it"** follows the traditional reading of the
  reply to the July ultimatum. Christopher Clark and others read the same
  document as a highly qualified refusal. This is a real historiographical
  split, not a settled fact.
- **Verdun's "about 300,000 died"** sits at the high end of a disputed range;
  estimates of those killed run from roughly 219,000 upward, and combined
  casualties are often given as 700,000 or more.
- **Tannenberg's 92,000 prisoners** is Hindenburg's own figure, which the
  literature flags as possibly inflated.
- **The Lusitania's 1,198 dead** is the most common figure; sources give 1,195
  to 1,201 depending on how the count is taken.
- **The 881,000 tons sunk in April 1917** varies with whether British-only or
  all Allied and neutral shipping is counted.
- **The RAF entry claims no precedence.** It is often called the first
  independent air force, but Finland's dates from 6 March 1918, so the entry
  says only that it was independent of both army and navy.
- **The Mendi's 616 dead** is the figure on the memorials; the literature also
  gives 646, and the two are not reconciled.
- **The Chinese Labour Corps' "about 2,000 never went home"** is the usual
  Western estimate. Some Chinese scholarship puts the figure as high as 20,000.
- **The armistice "signed at 5.10"** falls inside a range sources give as 5:00
  to 5:45 a.m. Paris time.
- **Gallipoli's "about 130,000 died"** is a combined total whose components are
  individually disputed.
- **Dreadnought "built in a year and a day"** is the famous keel-to-trials
  figure; full commissioning took until December 1906.

Every date, place and figure in the roster was checked against the prose of its
linked article before release, and 32 corrections were made as a result -
among them the Zeebrugge VCs (eight, not the eleven of a well-known book
title), the Tsingtao siege length, Serbia's population, the chlorine tonnage at
Ypres, and seven article titles that were dead or pointed at the wrong subject.

## Fonts and text

Every font on the panel is uppercase only and none carries an apostrophe or a
double quote, so all text is filtered before it is drawn. Accented letters are
folded to ASCII rather than dropped, since a name with a letter missing is
worse than a name spelled plainly. That filter matters most for the live line,
which is the only text on the panel this app did not write.

## Panel

192x32. Content sits inside x 10-181; the two columns at the left edge are the
accent rail, which carries the theatre colour on every page.
