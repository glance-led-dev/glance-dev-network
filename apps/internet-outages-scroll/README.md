# Internet Outages

Where the internet is down right now: a world map with the affected
countries lit, and the worst outages ranked. No key or account needed.

## Settings

| setting | what it is |
|---|---|
| **Look back** | How far back to count: 6 hours, 24 hours, 3 days or 7 days. A short window shows what is broken now; a long one also catches outages that have since recovered. |
| **Show** | `COUNTRIES` ranks whole nations. `REGIONS` ranks states and provinces, which surfaces a big outage inside one part of a large country. |

## The pages

- **World map** - every country with a detected outage lit on the map,
  brighter for the more severe, with the count and the worst-hit place
  named beside it. When nothing is wrong anywhere the map stays dim and
  the panel says so in green, which is the normal state of the world.
- **Worst** - the four hardest-hit places, each with a severity bar, and
  how many outage events each has had in the window.

## What the numbers mean

- The source is **IODA**, the Internet Outage Detection and Analysis
  project at Georgia Tech. It watches three independent signals - BGP
  routing, active probing of address blocks, and darknet traffic - and
  scores a place when they drop below what its own history predicts.
- The **severity score** is IODA's own. It combines how far below normal
  a place fell with how long it stayed there, so a brief nationwide
  blackout and a long partial one can score similarly. It is a ranking
  number, not a percentage of people offline.
- **Events** is how many separate outage episodes were detected in the
  window.
- An outage here means connectivity the internet itself can see
  disappearing. The cause might be a cable fault, a power cut, a storm,
  or a government shutting access off; the data does not say which.

## Notes

- Source: `api.ioda.inetintel.cc.gatech.edu`, public and keyless.
- Alaska, Hawaii and other small territories may be too small to light a
  pixel on a map this size, but they are still ranked on the second page.
- The panel refreshes every 15 minutes.
