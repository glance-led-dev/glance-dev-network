# Development and submission

The app is `app.star` plus `manifest.yaml` and bundled assets. `feed-server/` is an optional Node 22 Kalshi adapter with a Dockerfile and a generic Fly configuration; it is deployed separately by each feed owner. Setup instructions are in [SETUP-KALSHI.md](SETUP-KALSHI.md).

## Preview

From the GDN repository root, with its virtual environment active:

```bash
gdn studio apps/prediction-market-ticker
```

Set Feed URL to a compatible feed. For an account-free preview, serve [example-feed.json](example-feed.json) locally or on your own web host and use that URL in local Studio. A local URL works only for local Studio; the published render service needs an internet-reachable URL.

The images in `docs/display-examples.png` use sample odds. If editing files outside Studio, click Reload before editing or saving in Studio again.

## Validation

From the GDN repository root:

```bash
gdn check apps/prediction-market-ticker
gdn validate apps/prediction-market-ticker
python apps/prediction-market-ticker/tests/check_render.py
node apps/prediction-market-ticker/feed-server/server.test.cjs
```

The render checks use the actual Starlark runtime for all 102 teams, aliases, long labels, boundary percentages, signed spread views, settlement states, legacy feeds and error screens. Server regression checks cover the held-team switch, actual thresholds versus ticker suffixes, unresolved matchups, totals, custom-label precedence and NO-side price preservation. They write preview sheets to a temporary directory, or an output directory supplied as the script's argument. Server tests mock the upstream account API; no private key is needed.

## Publishing

Use Validate & Submit in Studio, or `gdn submit apps/prediction-market-ticker`. Glance reviews the submission before making the app available in its catalog. See [Glance's publishing guide](https://glance-led.dev/docs/publish/submit/).

Only this app folder belongs in the submission. It includes a generic connector template and instructions; each user's credentials, account feed address and generated hosting configuration must stay outside the public repository. Keep local account data out of generated preview images as well.

## Compatibility

The manifest uses the device-compatible `feedurl` input key. Saved local Studio input maps using `feed_url` are still read by the app. Users updating older settings should re-enter the URL in Feed URL.

When changing the connector, update its tests and the setup guide together. The legacy PNG endpoint has its own renderer; matchup logos and scores are in the GDN app. Update the server's TEAM_CODES and TEAM_ALIASES when changing the app's catalog. The server uses Node 22's native fetch and AbortSignal for ESPN.

Version 2 tests additionally cover totals, score ordering, phases, ambiguity, deduplicated scoreboard requests, stale fallback, portfolio pagination, counters up to 1,000, filters, pin validation and 1/2/3/5-minute rotation boundaries. All text is checked for clipping and overlap. HTTP cache behavior is checked explicitly.

Deploy the updated connector and reload/update the GDN app to enable version 2 features. Installing local files does not deploy the feed or submit the app to Glance. No account-authenticated production test runs as part of the test suite. Large cold portfolios can exceed the GDN HTTP deadline; measure real-account response time before public launch.

For proposed future viewing improvements, see [ROADMAP.md](ROADMAP.md).
