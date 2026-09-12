# Harpcity Highlights — Sleeper

A four-page NFL fantasy display: matchup scores, lead/deficit, your season record and points for, and rotating league records.

## Setup

Enter the numeric league ID from your Sleeper league URL. Keep it as text to preserve all digits. Enter your exact team name or use a positive roster ID to select your team. No password or API key is needed.

- **League ID:** blank shows clearly labeled fictional demo data.
- **Team name:** case-insensitive exact match. Duplicate matches require a roster ID.
- **Roster ID:** 0 uses team name; a positive value overrides it.
- **Week:** 0 follows the current regular-season NFL week for the same season as your league. Select 1–18 explicitly for historical weeks or offseason viewing.
- **Mode:** live uses your inputs; demo makes no HTTP requests.

The league-records page cycles through two teams each minute in roster order. It does not claim playoff rank or infer division tiebreakers. Commissioner score overrides, including zero, take precedence. Scores may change after stat corrections. A lead is not declared a final victory.

Refresh and matchup cache are 60 seconds; device scheduling and source updates can add delay. League/user metadata and current NFL week are cached for 300 seconds. Each page uses at most six HTTP requests. No data persists between renders except the host HTTP cache.

No projections, win probabilities, or players-remaining counts are inferred. Players remaining requires a separate game-status source. Missing data shows an explicit error or no-matchup state.

## Validation

Run `gdn validate apps/harpcity-highlights` and `python apps/harpcity-highlights/test_app.py` with the GDN SDK installed. Preview images use fictional demo data. The fixture tests execute the actual Starlark app and renderer.

Data: https://docs.sleeper.com/ . This app is intended for personal, non-commercial use under Sleeper API terms. It does not modify Sleeper data.
