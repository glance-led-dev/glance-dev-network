# Hokies Wrestling (64x32)

All Virginia Tech wrestling, from MatSavant's public data files. No Worker, API
key, or extra setup is needed.

## Pages

- **next:** the next dual (TONIGHT, TOMORROW or the date, the opponent in its team colors, start time, and home or away) or the next tournament, whichever comes first. For a day after a dual it shows the FINAL score with W or L.
- **team:** projected NCAA finish (VT's place among MatSavant's team projections), trophy (top-4) odds and title odds.
- **card1, card2, card3:** one ranked Hokie each, rotating every minute through all 10 weights. Each card shows weight, record, last name, FLO rank and IM (InterMat) rank, All-American odds (AA) and NCAA title odds (TITLE). The FLO rank turns green if he moved up since last week's rankings and red if he moved down.

## Data (all from MatSavant, no key needed)

- Rankings: `/data/p4p/2027.json`, cached 1 hour
- Dual schedule and results: `/data/schedule/duals_2026-27.json`, cached 15 minutes
- Team projections: `/data/xtp/2027/xtp_team_odds_history_2027.json`, cached 1 hour

MatSavant's schedule has no start times or tournaments, so `DUAL_TIMES` and `TOURNAMENTS` at the top of `app.star` hold them, copied from hokiesports.com. Update those, and the season in each URL, next season.

## Install

1. Copy this folder into `glance-dev-network\apps\`.
2. Run `gdn validate apps/vt-wrestling`.
3. Run `gdn studio` to preview it.

## Coming next

A live dual page that takes over the app while VT is wrestling.

