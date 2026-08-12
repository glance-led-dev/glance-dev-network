# CTA Train Times — Glance LED app

Live Chicago "L" arrival times for any CTA station on a 128×32 Glance panel.

## Files
- `manifest.yaml` — app config + user inputs (API key, station map ID)
- `app.star` — rendering logic (Starlark)

## Inputs
- **CTA Train Tracker API key** (`apikey`) — encrypted `api-key` field; never hardcoded.
- **Station (map ID)** (`mapid`) — 5-digit whole-station ID. Default `41190` = Jarvis (Red Line).

## Preview / validate
From the Glance repo (with this folder copied into `apps/cta-train-times/`):

```bash
gdn validate apps/cta-train-times
gdn preview apps/cta-train-times
```

Or open **Glance Dev Studio** (browser editor) and paste in `manifest.yaml` + `app.star`.
Set the API key and map ID in the input controls to see live data.

## Publish
Glance publishing is a pull request — copy this folder into `apps/` in your fork of the
Glance repo, commit, and open a PR.

## Notes / next step
- Times are computed as `arrT − tmst` from the CTA response, so DST/timezone never enter the math.
- Refresh + HTTP cache are both 30s.
- **Station picking:** v1 uses a free-text map ID. The end-goal dropdown of all ~145
  stations can be built from the City of Chicago "List of 'L' Stops" dataset
  (`data.cityofchicago.org`, MAP_ID column) — see the chat thread.
