# 10-Year Treasury Yield

The benchmark US 10-year Treasury yield, the number most people mean by
"the bond yield", with how far it has moved and where the curve stands.
No API key: the data comes straight from treasury.gov's daily par yield
curve feed.

## What the pages show

- **10Y**: the latest closing yield, plus its move over 1 day, 1 week
  (5 sessions) and 1 month (21 sessions) in basis points (1 bp = 0.01%).
  Green means the yield rose, red means it fell. The left rail on the wide
  build shows the day's move.
- **2Y-10Y spread**: the 10-year minus the 2-year in basis points, labelled
  `NORMAL` (10 bp or more), `FLAT` (0 to 9 bp) or `INVERTED` (below 0). The
  wide build adds a 30-session chart of the spread with the 0 bp line, plus
  both yields.

## Notes

- Treasury publishes once per business day, in the afternoon Eastern time.
  The panel refreshes hourly and shows the date of the close. Weekends and
  holidays show the last business day.
- No settings are needed.
- Data: <https://home.treasury.gov/resource-center/data-chart-center/interest-rates/>
