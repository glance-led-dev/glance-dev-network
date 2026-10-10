# Grid Carbon

How clean the electricity coming out of the wall is right now: the share
of the grid running carbon-free, the carbon intensity of a kilowatt-hour,
and the fuels behind it. No key or account needed.

## Settings

| setting | what it is |
|---|---|
| **Grid** | `GREAT BRITAIN` (National Grid), `CALIFORNIA` (CAISO), `TEXAS` (ERCOT) or `NEW YORK` (NYISO). |

## The pages

- **Now** - the carbon-free share as the hero, with a meter that fills the
  same way, and the carbon intensity in grams of CO2 per kilowatt-hour
  beside it. Green above 60 percent carbon-free, amber in the middle, red
  when the grid is mostly fossil.
- **Fuel mix** - the four largest sources right now, each with a bar and
  its share, in the colours these fuels carry on any grid chart.

## Where the carbon number comes from

- **Great Britain publishes it.** National Grid measures the intensity and
  names a band for it, from `VERY LOW` to `VERY HIGH`. That is the figure
  shown, unchanged.
- **The US grids do not.** CAISO, ERCOT and NYISO publish a fuel mix in
  megawatts and no carbon figure, so this app calculates one: each fuel's
  output times that fuel's lifecycle emissions factor, divided by total
  generation. The factors are National Grid's own published table, so a
  Texan number and a British number are built the same way.
- That makes the US figure an **estimate**, and the panel marks it `EST`.
  It is a fuel-mix calculation, not a measurement.
- **Imports and storage are shown in the mix but left out of the carbon
  maths.** Neither has a generation footprint at the point it enters the
  grid, and guessing at the source behind an import would be inventing a
  number. California relies on imports heavily, so its estimate describes
  what California is generating, not everything Californians consume.

## Notes

- Sources: `api.carbonintensity.org.uk`, `caiso.com/outlook`,
  `ercot.com` fuel mix, and `mis.nyiso.com` real-time fuel mix. All public
  and keyless.
- Great Britain's feed reports percentages directly; the three US feeds
  report megawatts, which the app converts to shares.
- The panel refreshes every 15 minutes.
