# SPPL Live

Live weekly matchup scores and league standings for the Straight-Up Pigskin Pick'em League.

The app displays six graphical pages on a 384×32 Glance Scroll Pro:

1. Weekly matchups 1–4
2. Weekly matchups 5–8
3. Standings 1–4
4. Standings 5–8
5. Standings 9–12
6. Standings 13–16

Every page carries the approved SPPL shield. Current owner-uploaded team artwork is bundled for DPH, FIG, LONG, and PP; teams without uploaded artwork use an abbreviation badge rather than invented art.

Data comes from the league's public, read-only Glance endpoint at `https://sppl.wtf/api/glance/data` and refreshes every 60 seconds. The endpoint exposes only team abbreviations, team-logo URLs, aggregate scores, records, and points-for totals. It does not expose owner names, email addresses, authentication data, or individual picks.
