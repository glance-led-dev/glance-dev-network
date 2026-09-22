# World Countries

One UN member state at a time on a 192x32 panel, picked at random each minute.

- **Left:** the country's flag.
- **Top row:** the country's name.
- **Second row:** its continent, in that continent's colour, and its 2026 overall power rank on the right.
- **Third row:** its official or national languages.
- **Bottom row:** its population on the left and its area in km² on the right.

## Data

| Field | Source |
|---|---|
| Countries | The 193 [United Nations member states](https://www.un.org/en/about-us/member-states), and only those. Observer states and territories are not included. |
| Continent, languages, population, area | The owner's country profile spreadsheet (CountryInfo reference values). Population is a rough figure, and reference years vary by country. |
| Power rank | The U.S. News 2026 overall power ranking, as reproduced by [World Population Review](https://worldpopulationreview.com/country-rankings/most-powerful-countries). |

The power ranking covers 100 countries. The other 93 show **NOT IN TOP 100**, not a made-up rank of 101. The index doesn't order the countries outside its top 100.

Nothing is fetched at render time. The table is built into `app.star`.

## How it reads

- **Names:** most names are shown as the UN list gives them. A few long formal names use their common short form: North Korea, South Korea, Laos, DR Congo, Tanzania, Syria, Russia, Moldova, Brunei, and St Vincent and the Grenadines.
- **Font size:** names use the 5x7 font where they fit and 4x5 where they don't (Central African Republic and St Vincent and the Grenadines).
- **Apostrophes:** none of the bundled fonts has an apostrophe, so Cote d'Ivoire's is drawn as a small tick.
- **Languages:** as many as fit are shown, then **+N** for the rest (for example FRENCH, LINGALA, KONGO +2).
- **Numbers:** population and area are rounded to three significant figures: 1.37B, 89.7M, 331K, 2.02.
- **Timing:** a new country every minute, never the same one twice in a row. The pick is worked out from the clock, so two panels side by side show the same country.

## Flags

The flags are PNGs in `assets/`, named by lowercase ISO 3166 code (`fr.png`), one per UN member state, and all 193 are listed under `assets:` in the manifest.

- **Size:** flags are drawn at their own size, 40 px wide and 16–30 px tall, centred in a 40 px box. The panel only resizes images by nearest neighbour, which would break thin stripes and small stars, so almost nothing is scaled.
- **Tall flags:** the five flags too tall for the panel are shrunk to 30 px tall: Monaco, Niger, Belgium, Switzerland and Nepal. All five are simple shapes that survive the scaling.

## Testing a specific country

A hidden `_country` input takes an ISO code and shows that country instead of the random pick:

```
gdn render apps/world-countries --input _country=CD --out dr-congo.png
```
