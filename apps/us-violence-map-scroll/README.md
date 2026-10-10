# US Violence Map

A pixel map of the United States shaded by homicide rate, the states
carrying the highest rates, and where your own state sits. The numbers are
CDC provisional mortality data. No key or account needed.

## Settings

| setting | what it is |
|---|---|
| **Measure** | `HOMICIDE` (default) is all homicides. `FIREARM HOMICIDE` counts only those committed with a firearm. `FIREARM DEATHS` is every firearm death, which includes suicides and accidents and is therefore a much larger number. `DRUG OVERDOSE` is offered for comparison. |
| **Your state** | The state the third page reports on. That page lights it alone on the map, so you can see where it sits. |

## The pages

- **Map** - every state shaded by its rate, dark where rates are lowest and
  bright where they are highest, with the scale printed beside it. Alaska
  and Hawaii sit next to the map as two labelled squares, because at this
  size they cannot be drawn in place without being mistaken for the
  mainland. DC is a single pixel between Maryland and Virginia.
- **Highest rates** - the five jurisdictions with the highest rate, each
  with a bar, and the national rate underneath for scale.
- **Your state** - your state's rate, its rank, how it compares with the
  national rate, and the change from the 2024 calendar year. The rank is
  shown with the field it is out of (`#29/51`), and that field shrinks on
  measures where CDC suppresses some jurisdictions, since a suppressed rate
  is never ranked.

## What the numbers mean

- Every figure is a **rate per 100,000 people**, not a count, so states of
  different sizes can be compared. A rate of 6.0 means six deaths per
  100,000 residents over the period.
- The window is the most recent **12 months CDC has published**, which the
  panel names on the map page. It runs several months behind today, because
  death records take time to be certified and reported.
- These are **provisional** counts and get revised as more records arrive.
- Rates CDC suppresses, because the count is too small to publish safely,
  are shown as `NR` and are left out of the ranking.

## Notes

- Source: CDC's Mapping Injury, Overdose, and Violence data, the state file
  at `data.cdc.gov` (`fpsi-y8tj`), with the national figure from its
  companion national file (`t6u2-f84c`).
- The FBI's Crime Data Explorer was considered first, since violent crime
  is the more familiar measure. It needs an API key and serves one state
  per request, so a 50-state map would take 50 requests. The CDC file
  returns every state in one.
- The panel refreshes daily; CDC updates the file monthly.
