# Viewing improvements after version 0.4

These are proposals, not shipped features.

1. **An easier position picker.** A companion setup page could list readable market names and provide checkboxes instead of asking people to paste tickers.
2. **Recovering from odds outages.** Persist the last successful odds snapshot with its age. Scoreboard outages already retain stale scores; an account API outage currently shows FEED ERROR.
3. **Physical-panel tuning.** Check the 12-pixel logos at normal viewing distance and offer a larger, alternating matchup page if needed.
4. **Large portfolio performance.** Background refresh could keep cold-start account fetches within Glance's HTTP deadline even for many pages of holdings.

Version 0.4 adds totals matchup logos, score and clock snapshots, freshness labels, a position counter, filters, pinning and minute-based rotation controls. Version 0.3's effective YES/NO spread selection and resolution statuses remain.
