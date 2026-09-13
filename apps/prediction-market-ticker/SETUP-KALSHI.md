# Set up your own Kalshi feed

This guide connects your own Kalshi positions to Prediction Market Ticker. It uses the Node server in [feed-server](feed-server/) and Fly.io as one hosting option. A server is required because the Glance app does not store your Kalshi private key or sign account requests.

The connector reads your nonzero positions and market prices, then provides a JSON feed for the display. It makes no order or trade requests. It paginates the portfolio and includes all nonzero holdings. For supported football events it adds matchup metadata and ESPN score/clock snapshots, without sending your credentials or holdings to ESPN.

Version 0.4 adds position filters, pinning, a position counter, and a choice of 1/2/3/5 minutes per position. Deploy this updated connector and update the Glance app to use these settings. The panel fetches once per minute and does not animate the clock between snapshots. Scoreboard failures leave odds usable with SCORE N/A or STALE SCORE.

## Before you start

You need your own Kalshi account with API access, a Fly.io account, the [Fly command-line tool](https://fly.io/docs/flyctl/install/), and OpenSSL for key conversion. This example uses paid hosting resources; review your hosting account's costs before launching it.

These terminal commands are for macOS or Linux. Replace the example app name, key ID and file paths with your own values.

## 1. Get the connector files

Download this repository or clone it. From the repository's top-level folder, copy the connector into a separate working folder:

```bash
cp -R apps/prediction-market-ticker/feed-server ../my-market-feed
cd ../my-market-feed
cp fly.toml.example fly.toml
```

This folder contains the complete server, Dockerfile and a generic Fly configuration. It has no account credentials and no connection to the author's account.

## 2. Create a Kalshi API key

In [Kalshi profile settings](https://kalshi.com/account/profile), create an API key. Save its key ID and download the private key. Kalshi displays the private key only at creation, so keep the downloaded file. Follow [Kalshi's API key guide](https://docs.kalshi.com/getting_started/api_keys) if the account screens have changed.

Store the key outside the downloaded repository and outside the connector folder. The server expects an unencrypted PKCS#8 key beginning with `-----BEGIN PRIVATE KEY-----`. If your download begins with `-----BEGIN RSA PRIVATE KEY-----`, convert it:

```bash
openssl pkcs8 -topk8 -nocrypt \
  -in '/full/path/to/downloaded-kalshi-key.txt' \
  -out '/full/path/to/kalshi-key-pkcs8.pem'
chmod 600 '/full/path/to/kalshi-key-pkcs8.pem'
```

If your downloaded key already begins with `-----BEGIN PRIVATE KEY-----`, use that file directly.

## 3. Create your hosting app

From your `my-market-feed` folder:

```bash
fly auth login
fly launch --no-deploy --name your-unique-app-name --ha=false --no-db --no-redis --no-object-storage
```

Replace `your-unique-app-name` with a unique lowercase name you choose. Accept using the existing configuration if prompted. No database, Redis instance or object storage is needed. The template uses port 8080 and redirects to HTTPS, which the GDN feed client supports.

Check the generated `fly.toml`: `app` must name your new app and `internal_port` must be 8080. See [Fly's launch guide](https://fly.io/docs/launch/create/) for account or launch questions.

## 4. Store your credentials and deploy

Run the following from that same folder. Use your key ID and the path to your PKCS#8 key file:

```bash
fly secrets set --stage \
  KALSHI_KEY_ID='YOUR_KEY_ID' \
  KALSHI_PRIVATE_KEY="$(cat '/full/path/to/kalshi-key-pkcs8.pem')"
fly deploy --ha=false
```

Fly supplies these values to the running server as secrets; the Dockerfile copies only `server.mjs`. Do not put key contents into source files, the Glance settings, screenshots or GitHub. Read [Fly's secrets guide](https://fly.io/docs/apps/secrets/) for how stored secrets work.

## 5. Check the feed

Open your own app's JSON address in a browser:

```text
https://your-unique-app-name.fly.dev/?json=1
```

You should see `"ok": true` and a `rows` list. With nonzero positions, rows contain labels, percentages and football team metadata where recognized. If there are no positions, an empty list is normal. If `ok` is false, check the key ID, key format and server logs with `fly logs`.

The root address without `?json=1` returns a legacy PNG image. The Glance community app needs the JSON address above.

## 6. Connect your Glance display

Once Prediction Market Ticker is available in the catalog, add it to your display. Paste your JSON address into **Feed URL**, leave **League for older feeds** on **Auto**, save, and enable the app. Allow the next refresh for it to appear.

## How the connector behaves

- It calculates the held side's probability from available bid/ask prices and uses previous YES-side quotes to calculate the change. Missing previous quotes produce no change indicator.
- It includes all nonzero positions. Version 2 apps filter and rotate these locally using the selected minute interval. Clock timing can repeat or skip a market on an individual display refresh.
- It identifies the named team and opponent from recognized NFL/college-football market and event tickers. Spread YES displays the named team with a negative line; spread NO displays the opponent with a positive line. The numerical spread comes from the market threshold, not the ticker suffix. Unresolved matchups keep an explicit YES/NO label.
- OVER/UNDER is used for recognized game totals, not for spreads or every market with a numerical threshold. For whole-number thresholds, a strict greater-than condition is shown using the equivalent half-point line for integer football scores, avoiding the implication of a push. Short labels do not replace the full contract description or its cancellation rules.
- Closed markets show CLOSED; determined markets awaiting final settlement show PENDING. Settled/finalized markets with a YES/NO result show WON or LOST for your held side. These labels are not an account payout ledger.
- It requires no ongoing local computer session once hosted.

## Optional settings

| Server setting | Purpose |
|---|---|
| `KALSHI_LABELS` | JSON object mapping full market tickers to short custom labels. Prefer ten characters or fewer. |
| `KALSHI_CACHE_MS` | Minimum interval between account refreshes; defaults to 15000 milliseconds. |
| `PANEL_WIDTH` | Only affects the legacy PNG endpoint. Keep it at 64 for a 64 × 32 panel. |

Set optional values through your hosting provider's environment/secret settings. For spreads, the calculated held-team label takes precedence over a custom label to avoid showing the wrong side. A supplied custom label is retained as `custom_label` in the feed. Other market types can still use custom labels.

## Feed visibility

The example's feed and diagnostic endpoints have no authentication. Anyone who can reach the URL can read returned market rows and diagnostic information. Your private key is used on the server and is not included in the feed. If you need authenticated access to the feed, add it to your server and ensure the Glance fetch path can supply the required credentials before using that setup.

For a different host or your own adapter, follow the [feed format](FEED-FORMAT.md).
