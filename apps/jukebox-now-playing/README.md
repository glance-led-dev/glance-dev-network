# Jukebox Now Playing

The song currently playing in the **Bar** zone of the P$ Jukebox (Home Assistant + Alexa), as a two-line
SCROLL card: title, artist, and a progress bar with elapsed / total time. Radio
stations show `LIVE`; when nothing is playing (or the jukebox can't be reached) the panel goes completely dark.

Pages: `now_playing`

## Setting it up

1. In the jukebox repo, deploy `netlify/functions/now-playing.mjs` (it is served at
   `/.netlify/functions/now-playing`).
2. In Netlify **Site settings > Environment variables**, set `HA_BASE_URL` and
   `HA_TOKEN` (and `CF_ACCESS_CLIENT_ID` / `CF_ACCESS_CLIENT_SECRET` if Home Assistant
   sits behind Cloudflare Access). These stay on Netlify; this app never sees them.
3. Put the endpoint address in **Now-playing URL**, without `https://`, for example
   `yoursite.netlify.app/.netlify/functions/now-playing`.

## Settings

| setting | what it is |
|---|---|
| **Now-playing URL** | The jukebox's now-playing address, without `https://`. Leave blank to see the bundled demo. |

## Notes

- The endpoint returns only `playing`, `title`, `artist`, `album`, `startedAt` and
  `idleAt`. The queue, guest names and cover art are not exposed.
- The panel font has no apostrophe, so `DON'T` shows as `DONT`.
- The panel redraws about once a minute, so the progress bar steps rather than crawls.
