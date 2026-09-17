# Carbon in the Air

What burning fossil fuel leaves behind: the global CO2 concentration
measured today, the rise since 1979, and the yearly breathing cycle of the
planet. No key or account needed.

## Settings

| setting | what it is |
|---|---|
| **Compare against** | What the headline is measured against. `A YEAR AGO` uses the reading from the same day last year. `PRE-INDUSTRIAL` uses 280 ppm, the level the air held for thousands of years before coal. `1979` uses the first year of NOAA's global record. |
| **Chart span** | How far back the rise chart reaches: the whole record since 1979, or the last 20 or 10 years. |

## The pages

- **Now** - the concentration measured today, in parts per million, with
  how much higher it is than your chosen comparison, and the de-seasonalized
  trend beside it.
- **The rise** - the annual global mean for every year on record, drawn as
  a chart, with the first and last years labelled and the total increase
  across the span.
- **Yearly cycle** - the last year of daily readings. The sawtooth is real:
  CO2 falls through the northern summer as plants grow and take it up, then
  climbs back through the winter as they die back. The peak, the low and
  the size of the swing are named.

## What the numbers mean

- **ppm** is parts per million by mole fraction in dry air. 424 ppm means
  424 CO2 molecules for every million molecules of air.
- The source is **NOAA GML**, averaged across its four atmospheric baseline
  observatories: Barrow in Alaska, Mauna Loa in Hawaii, American Samoa, and
  the South Pole. These sit far from cities on purpose, so the number is
  the background level of the whole atmosphere rather than the air in any
  one place.
- NOAA publishes two columns and **they are not the same thing.** The
  *smoothed* value still carries the seasonal cycle; the *trend* has that
  cycle taken out. The headline here is the smoothed value, because that is
  what is actually in the air today, and the trend is shown beside it and
  labelled. In September the smoothed value sits below the trend, because
  September is near the annual low.
- The yearly swing is the biosphere, not a measurement error. It is roughly
  5 ppm globally, and much larger if you only look at the far north.

## Notes

- Source files: `co2_trend_gl.txt` (daily, from 2016) and
  `co2_annmean_gl.txt` (annual, from 1979), both plain text and public.
- Two requests per render, cached for an hour. Both are `.gov`, which the
  render host reaches directly.
- NOAA notes that the most recent year of data can still be revised as
  reference gases are recalibrated. The changes are normally small.
- The panel refreshes every hour, though the daily file only extends once
  a day.
