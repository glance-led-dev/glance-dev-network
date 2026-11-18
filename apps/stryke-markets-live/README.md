# Stryke Markets Live

A 128×32 ticker for Glance Scroll with TOMS market prices, strategy returns, tick volume, HALO trade ideas, and alternating Market News and NewsIQ360.

## Setup

Add **Stryke Markets Live** in Glance Setup. The app uses Stryke Markets’ public TOMS feed and starts automatically. Leave both lineups blank to cycle through the available instruments and strategies.

- **Instrument lineup** accepts comma-separated TOMS symbols, such as `EURUSD.smx, XAUUSD.smm`. The same list filters Market Pulse and Tick Volume.
- **Strategy lineup** accepts comma-separated Marketplace strategy names or IDs.

The ticker refreshes every five minutes. Tick volume counts market-data updates. Strategy returns are shown for the available trailing periods. HALO displays only active ideas, so its page may be empty between publications.
