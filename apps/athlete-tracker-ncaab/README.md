# Athlete Tracker (NCAAB)

Track one men's Division I college basketball player on two consecutive pages. Page 1 always shows the selected player's season averages. Page 2 shows live statistics during a game, then the most recent ESPN final after it ends.

Both pages use the same approved layout as Team Tracker (NCAAB), including the player's name, jersey number, position, height, class, team logo, and PTS/REB/AST/STL/BLK.

## Preview

These are illustrative layout examples, not current game results.

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

- **Studio layout preview:** AUTO uses actual data. LIVE DEMO, NORMAL FINAL DEMO and OT FINAL DEMO use illustrative statistics for layout review.

The app uses ESPN's public basketball data and refreshes every 300 seconds. The dropdown contains 5,218 player entries across 365 schools from the October 13, 2026 roster audit. ESPN's rosters are still incomplete; this is not a claim that every current player is present. The bundled picker will need another update when ESPN posts the missing players. Athlete IDs distinguish similar names.

The refreshed design includes larger editable jerseys with white collars and centered numbers, school-colored backgrounds, 64 custom team marks, compact decimals, measured header spacing, and separate regulation/overtime final layouts. Long score rows retain full team abbreviations; PTS moves only when required for space. Missing statistics display `--` instead of invented zeroes. An alternate ESPN host is tried on API failure, but it is not an independent data source.

Validation passed for both pages. All 5,218 selection-to-ID mappings were checked, along with 41,752 foreground-text bounds cases across real roster names and stress-test game states. These checks and sampled previews cannot guarantee every future provider payload.
