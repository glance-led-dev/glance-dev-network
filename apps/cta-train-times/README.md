# CTA Train Times (Chicago) — Glance app

Live Chicago "L" arrivals for one CTA station on a 128×32 Glance panel, laid out like a platform sign.

## What it shows
- The station name, over a stripe in the colors of every line stopping there.
- Two departure rows: a train in the line's color, the destination, and the minutes
  (`DUE` when arriving, `DLY` when CTA flags a delay). Each row is the next train to a
  different destination, so both directions show at once; a station with one destination
  shows its next two trains.

## Input
- **Station** (`station`) — dropdown of every 'L' station (whole station, both directions).
  Names shared across lines are tagged, e.g. "Western (Brown)" vs "Western (Pink)".

## Data
Arrivals come from a small caching proxy in front of the CTA Train Tracker `ttarrivals` API.
The proxy holds the CTA key server-side and caches each station for 60 s, so the app needs no
API key. Minutes are `arrT − tmst` from the response, so time zones and DST never enter the
math. The panel refreshes every 3 minutes.

## Preview / validate
```bash
gdn validate apps/cta-train-times
gdn preview apps/cta-train-times
```
