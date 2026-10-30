# Athlete Tracker (NCAAB)

Opponent rankings are not displayed. No AP badge, reserved badge space, or additional rankings request is included.

Track one men's Division I college basketball player on two consecutive pages. Page 1 always shows the selected player's season averages. Page 2 shows live statistics during a game, then the most recent ESPN final after it ends.

Page 1 also has a Next row: NXT, opponent abbreviation, weekday, date, then tip time in Eastern time, with daylight saving and date rollover handled together. The team schedule is cached for one hour. All five fields are retained; longer rows use measured spacing and adjust PTS only when needed. Unconfirmed tip times show TBD, no listed upcoming game shows NXT TBD, and an unavailable schedule source shows NXT OFFLINE. Missing schedules never replace season averages with invented game statistics.

When ESPN's default preseason schedule is empty or unavailable, the Next row also checks its regular-season schedule before showing TBD. Both reads are cached for one hour. Season averages remain ESPN's latest available posted averages; a scheduled upcoming season does not imply new-season player statistics already exist.

Both pages use the same approved layout as Team Tracker (NCAAB), including the player's name, jersey number, position, height, class, team logo, and PTS/REB/AST/STL/BLK.

## Preview

The averages image is a captured ESPN snapshot. The live/final examples are illustrative layouts, not current game results.

### Page 1 — Season averages

![A. Stojakovic season-average page](preview/stojakovic-average.png)

### Page 2 — Live game

![A. Stojakovic live-game page](preview/stojakovic-live.png)

### Page 2 — Final game

![A. Stojakovic final-game page](preview/stojakovic-final.png)

### Page 2 — Overtime final

![Overtime final](preview/overtime-final.png)

## Settings

- **Team + Player:** Search one combined dropdown, then choose the player from that school's current roster. Every selection includes the jersey number; no team, player, or game ID is required.

There are no public testing controls. Saved demo/game overrides from earlier versions are ignored. Automated layout test scenarios are kept outside the app folder; the production Studio uses this app's real settings and data path.

The app uses ESPN's public basketball data and refreshes every 300 seconds. The dropdown contains 5,417 player entries across 365 schools from the October 18, 2026 roster refresh. Only rosters identified by ESPN as the 2026–27 season were used for replacement. Bethune-Cookman, Miami (OH), New Hampshire, Texas A&M-Corpus Christi and Western Illinois still returned the previous season, so their existing options were retained. ESPN's rosters may remain incomplete; this is not a claim that every current player is present. The bundled picker requires periodic updates rather than updating itself automatically. Existing users whose selected option changed may need to reselect their player. Athlete IDs distinguish similar names.

Season averages use ESPN's structured player statistics endpoint, not JSON embedded in an HTML page. The selected athlete must be on the current team roster; only that team's row from the player's most recent posted season is used. Career totals and older former-team rows are not substituted. No posted history (including ESPN's 404 for a verified roster player) displays `--`; a bad response shape displays AVERAGES NOT POSTED, and transport errors display AVERAGES OFFLINE. Roster and averages retain their six-hour caches. Eight sampled real players matched the previous team-page values (two populated-stat samples and six without matching posted stats).

Michigan jerseys use official maize (#FFCB05); Campbell jerseys use official Campbell Orange (#EA7125). Other jersey, abbreviation-readability and layout rules are unchanged.

The refreshed design includes larger editable jerseys with white collars and centered numbers, school-colored backgrounds, 64 custom team marks, compact decimals, measured header spacing, and separate regulation/overtime final layouts. Long score rows retain full team abbreviations; PTS moves only when required for space. Missing statistics display `--` instead of invented zeroes. The shared roster request chooses the primary or alternate ESPN JSON host, then both pages reuse that host rather than retrying every endpoint separately. The cold-cache plan uses at most seven uncached requests for supported picker selections, below Glance's limit of eight. A failed individual endpoint still uses its unavailable-data state instead of unbounded retries. The alternate host is the same ESPN source, not an independent backup provider.

Version 0.2.1's final local audit passed 27,081 layout renders, 135,405 category/value alignment checks, and 10,834 biography/header renders across all 5,417 choices. Both pages passed Glance validation. Cold-cache tests remained within seven requests, and malformed-data/season-selection checks passed except for the separate platform limitation below. These tests do not guarantee future ESPN payloads or complete rosters. The missing picker on the live phone app still requires Glance to refresh and verify its published catalog settings; local Studio alone cannot certify that repair.

Platform limitation recorded during edge testing: a nonstandard bare NaN literal can fail inside Glance's HTTP-to-Starlark bridge before the app receives the response. The app cannot catch that host-level failure. The tested ESPN responses use ordinary JSON; this limitation is not reported as a passing app test.
