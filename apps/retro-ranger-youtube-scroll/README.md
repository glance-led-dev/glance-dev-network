# Retro Ranger YouTube (Scroll)

Live YouTube channel statistics across three 192x32 Scroll pages:

1. Channel subscribers, lifetime views, and public video count.
2. Latest public upload title, views, and likes.
3. Subscriber goal progress.

The default channel is `@RetroRangerTV` with a goal of 1,500 subscribers. Both
settings are configurable, so the app can display any public YouTube channel.

## Setup

This app needs a YouTube Data API v3 key:

1. Create or select a project in the
   [Google Cloud Console](https://console.cloud.google.com/).
2. Enable [YouTube Data API v3](https://console.cloud.google.com/apis/library/youtube.googleapis.com).
3. Open **APIs & Services > Credentials** and create an API key.
4. Restrict the key to **YouTube Data API v3**.
5. Enter the key in the app's **YouTube Data API key** field. Glance stores
   `api-key` inputs encrypted.
6. Enter a `UC...` channel ID or an exact `@handle`, then choose a positive
   whole-number subscriber goal.

Never include an API key in source code, screenshots, issue reports, or pull
requests. With no key, the app displays clearly labelled sample data.

## Data behavior

- Refreshes every five minutes.
- Uses `channels.list`, the channel uploads playlist through
  `playlistItems.list`, and `videos.list`. It does not use `search.list`.
- Checks the five most recent upload-playlist entries and skips entries that
  are unavailable or private. Public Shorts and archived streams may appear.
- Missing statistics display `--`. A hidden subscriber count disables goal
  calculation.
- YouTube rounds public subscriber counts to three significant figures, so the
  number may differ from YouTube Studio.
- Long titles wrap across two lines and are clipped with an ellipsis when
  necessary. The display's bitmap fonts support Latin letters, digits, and a
  limited punctuation set.

## API usage

A complete uncached render makes three one-unit YouTube Data API calls. With a
five-minute refresh, one continuously active configuration uses approximately
864 quota units per day. Separate configurations and cache misses add usage.
