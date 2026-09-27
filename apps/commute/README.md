# Commute for Glance Scroll

Live traffic-aware commute estimates, named route signs, an optional stop, leave-by times, weather icons and route-area alerts on a 192 × 32 display.

This app uses your own authenticated Commute service. The companion source and setup instructions are included in [service/SETUP.md](service/SETUP.md). Deploy it on Cloudflare Free using SQLite-backed Durable Objects, configure your provider keys and private trip, then choose Live. No PC needs to stay awake. Cloudflare and traffic-provider free quotas still apply.

## Settings

- **Commute status URL:** your service's HTTPS `/status` URL.
- **Commute read key:** your private `READ_KEY`. This API-key field is encrypted by Glance; do not enter a routing provider key here.
- **Display:** Departure (default), Routes or Conditions. The first page is the selected commute view; the second shows route weather.
- **Today's trip:** Direct or Stopover.
- **Arrive by:** your configured time, 8:00, 8:15 or 8:30 AM in your configured time zone.
- **Preview scenario:** Live, or a visibly marked demo. Demos do not use the network.

Your private service holds the home, destination, optional stop and API keys. Stop duration defaults to five minutes. Addresses and stop names are configurable; Starbucks is not required.

## Your addresses and weather

Set `origin.address` and `destination.address` in your own Worker's private `CONFIG_JSON` secret, or use precise latitude/longitude for a parking entrance. Updating that secret recalculates the trip on the next collection; the Glance status URL and read key stay the same. The current Glance settings and companion do not edit addresses. See [step-by-step endpoint setup](service/SETUP.md#set-or-change-the-two-endpoints), including optional stops and route corridors.

**OHGO is optional.** For supported U.S. routes, NWS provides temperature, reported visibility, conditions and severe-weather alerts without an OHGO account or weather API key. Set `alertAreas` to every state your route crosses. The community example defaults to `ohgo: false`; NWS-only weather is treated as normal operation. This is not worldwide weather coverage.

Ohio users can keep `ohgo: true` and their `OHGO_KEY` to add the existing incidents, construction, slowdowns, delays and fresh pavement/road-sensor readings. Those road-sensor features are not synthesized for users without OHGO. TomTom traffic ETAs work in either mode.

## Display

The departure view puts the leave countdown, recommended route and the optional stop deadline together. Starbucks has its logo and an iced-coffee illustration. No arrival cushion is added. Routes and Conditions are selectable detail views; urgent weather alerts take priority in every view. Missing supplemental data does not displace the departure information.

Traffic is provided by TomTom, weather by NWS, and Ohio road events by OHGO. Waze navigation links do not provide Waze ETAs. "Normal" is the provider's historical duration. Leave-by is estimated from the current ETA, not a future-departure routing prediction.

The app requests refreshes every 60 seconds. Actual display timing also depends on the service and Glance. Traffic older than three minutes is visibly stale. Missing alert feeds stay unknown. OHGO reports are near the route and may concern adjacent or opposite-direction roads; county snow-emergency levels require a separate verified official-source adapter.

![Sample departure screen](preview/preview.png)

The route-weather page adds a sampled temperature range, lowest reported visibility, conditions, and fresh winter pavement readings when available. The companion lists observation locations, timestamps, pavement/subsurface temperatures and wind. Missing or stale readings stay unknown. NWS stations are near route sample points; OHGO road sensors must be within 350 m of the selected route.
