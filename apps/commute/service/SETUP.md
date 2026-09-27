# Activate your own Commute

Live operation needs your own routing account and deployed private service. OHGO is optional. U.S. route weather and severe-weather alerts come from NWS independently of OHGO. Enter secrets locally or in Cloudflare's secret fields; do not paste them into shared issues, public configuration or screenshots.

## 1. Accounts

- Create a TomTom developer key with Routing and Search access at the [TomTom developer portal](https://developer.tomtom.com/). The service can accept precise coordinates instead of addresses, removing the need to geocode.
- NWS weather needs no API key: supply the required identifying `NWS_USER_AGENT` string. This integration covers supported U.S. locations; it is not a worldwide weather service. See [NWS API documentation](https://www.weather.gov/documentation/services-web-api).
- Optional, for Ohio routes: register for an [OHGO](https://publicapi.ohgo.com/) key to add incidents, construction, travel delays, dangerous slowdowns and available road-weather sensors. Without OHGO, leave `ohgo` false and omit `OHGO_KEY`.
- Use your Cloudflare account with Workers and SQLite-backed Durable Objects enabled (available on Cloudflare Free). Review the account's provider quotas before enabling frequent checks. This app does not create or upgrade paid subscriptions.

## 2. Private trip configuration

Copy `worker/config.example.json` to an unshared file named `config.private.json`. Fill in the locations, stop, time zone and arrival time. Each location accepts either `{ "address": "your complete address" }` or `{ "lat": 40.0, "lon": -84.0 }` (these numbers are illustrative).

For a campus, hospital or large workplace, use the actual parking entrance coordinates rather than the street address of the entire campus. Ambiguous geocoding deliberately fails with CHECK LOCATIONS. A route cannot be confirmed until its destination entrance is correct.

### Set or change the two endpoints

Each person deploys their own service and stores their own configuration. They do not use someone else's endpoint or read key. In `config.private.json`, set:

```json
"origin": {"address": "YOUR COMPLETE HOME OR START ADDRESS"},
"destination": {"address": "YOUR COMPLETE WORK OR DESTINATION ADDRESS"}
```

These are fields inside the complete configuration, not a standalone JSON document. Include city, state and ZIP. Alternatively use `lat` and `lon` coordinates, particularly for a parking entrance. Set `timeZone`, `arriveBy` and the traffic-check window for the trip. Set `alertAreas` to **every U.S. state the route crosses**, for example `["NY", "NJ"]`; do not leave the Ohio example for an out-of-state trip.

To change an existing trip, open Cloudflare **Workers & Pages → your Commute Worker → Settings → Variables and Secrets**, edit the `CONFIG_JSON` secret, and replace its value with the complete updated JSON. Save/deploy the secret change. With the CLI, run `npx wrangler secret put CONFIG_JSON` from the `worker` folder and enter that same complete JSON at the private prompt. Do not place it on a command line or in a public repository.

Open the companion with the same read key. The next collection resolves the new endpoints, recalculates routes and resamples weather. It may briefly show WAIT FOR FIRST CHECK. The service isolates old configuration data, so the previous home's route is not presented as the new route. Check the route and destination before relying on the new estimate. The Glance status URL and read key remain the same; Glance's current settings and the companion do **not** include an address editor.

The two endpoints describe one journey. TomTom compares alternative roads between them automatically. `routeOptions` is only needed to request particular corridors; it is not where the home/work addresses go.

### Weather with or without OHGO

| Feature | NWS-only (`ohgo: false`) | OHGO enabled with a key |
|---|---|---|
| Temperature, visibility when reported, conditions and icons | Nearby NWS observations sampled along the actual route | NWS plus available nearby OHGO atmospheric sensors |
| Severe-weather alerts | NWS route/zone matching in configured states | Same NWS coverage |
| Pavement temperature, reported ice/snow and subsurface readings | Not available; never inferred from air temperature | Available where fresh OHGO sensors report them |
| Ohio incidents, construction, slowdowns and travel delays | OHGO reports disabled; TomTom traffic ETA still works | OHGO reports near the route |

NWS observations are checked near the start, route midpoint and destination, with repeated stations deduplicated. Missing visibility stays unknown. No OHGO account is required for weather, and deliberately disabling OHGO does not create a failed-feed warning. Enabling it without a valid key does show unavailable coverage. To retain OHGO, keep `ohgo: true` and the existing `OHGO_KEY` secret; the new community example does not change existing deployed configurations.

An optional stop is configured with `stop.enabled`, `stop.name`, `stop.location` and `stop.durationMinutes`. Any business or errand stop is supported; coffee is just an example.

For specific route corridors, add up to two `routeOptions` entries. Each contains a `name` and a `via` array of up to six `{lat,lon}` points in travel order. Place each point on the correct carriageway. These routes are compared with the provider's automatic alternatives; point placement must be checked on a map. Live road labels still come from the returned route.

Arrival presets in Glance and the companion are 8:00, 8:15 and 8:30 AM. The Configured option uses any valid `arriveBy` value from this private file. Changing the preset recalculates leave-by estimates without making an extra routing request.

## 3. Dedicated Worker

From the `worker` folder, deploy with `npx wrangler deploy`. The configuration creates a dedicated SQLite-backed Durable Object; no KV namespace or paid subscription is needed. Set these Worker secrets using protected prompts or your Cloudflare dashboard:

- `CONFIG_JSON`: your private route configuration as a JSON string.
- `TOMTOM_KEY`: the routing provider key.
- `OHGO_KEY`: optional; required only when `ohgo` is true.
- `READ_KEY`: a separate randomly generated secret of at least 24 characters.
- `NWS_USER_AGENT`: an identifying application user-agent string.

The first authenticated GET to `/status` starts the collector. It initially returns WAIT FOR FIRST CHECK, then recurring Durable Object alarms collect data approximately every minute without a browser or PC remaining open. Public requests cannot trigger provider queries. Alarms retry after failures; old traffic is not marked current.

The example activity window is weekdays 06:30–08:30 local time, with hourly traffic checks outside it. Change `days`, `activeStart`, `activeEnd` and `outsideIntervalMinutes` as needed. A window with identical start/end times means all day on the selected weekdays.

There is no public “refresh provider data” endpoint. Scheduled collection controls usage; opening the companion or checking Glance reads the stored result. With one automatic direct query and an enabled stop, each collection uses three routing requests. Two configured route corridors add two more. Search geocoding is cached for seven days. Check current plan limits; continuous one-minute operation is not assumed free.

SQLite storage keeps snapshots consistent. Statewide feeds are split into atomic chunks to respect row-size limits. Cloudflare Free includes 100,000 storage-row writes and 13,000 GB-seconds per day; limits are shared with other applications. Exceeding a free limit stops operations rather than charging an overage. A two-hour weekday traffic window and hourly traffic checks outside it use about 17,000 TomTom requests in a typical month with two configured corridors and a stop. Check your routing plan allowance; five-hour default windows can exceed its free allowance. NWS and road alerts continue independently every minute. See Cloudflare and TomTom current pricing before changing collection cadence.

## 4. Glance and Waze companion

After the first scheduled collection, open the Worker root URL in a browser. Enter the private read key to view ETAs, all matched alerts, feed availability and Waze navigation buttons. The key stays in the tab's memory and is never placed in a URL or browser storage.

In Glance, configure:

- **Status URL:** the Worker's HTTPS URL ending in `/status`.
- **Read key:** the separate `READ_KEY`, entered into the encrypted API-key field.
- **Today's trip:** Direct or Stopover.
- **Arrive by:** Configured, 08:00, 08:15 or 08:30.
- **Preview scenario:** Live.

Use the normal GDN catalogue submission/review workflow for distribution. Passing local validation does not install the app on a device or make it available in the catalogue.

## 5. Optional county snow levels

`countyAdvisoryFeed` may point to a trusted HTTPS JSON adapter that verifies the relevant official sheriff/county source. No county adapter is supplied or active by default. Do not label a weather forecast, social-media guess or inferred road condition as an official snow level.

The response schema is:

```json
{
  "advisories": [
    {
      "county": "Example",
      "authority": "Example County Sheriff",
      "sourceUrl": "https://example.gov/current-advisory",
      "level": 2,
      "updatedAt": "CURRENT ISO-8601 VERIFICATION TIME",
      "expires": "FUTURE ISO-8601 EXPIRY TIME",
      "geometry": {"type": "Polygon", "coordinates": []}
    }
  ]
}
```

Replace the empty geometry with the actual county boundary. `updatedAt` is when the adapter last verified the official level, not an invented issue time. Reports must be verified within 30 minutes and unexpired. Level 0 means an explicitly verified no-current-level result. Coverage is only the configured counties. A missing or invalid feed stays UNKNOWN.

## Live acceptance checks still required

1. Confirm origin, parking entrance, coffee stop and corridor points on a map.
2. Verify authenticated live routing returns the intended roads and sensible traffic times for direct and stopover journeys.
3. Verify NWS coverage for the route; also verify OHGO feeds if that integration is enabled.
4. Observe at least two scheduled collections and confirm timestamps advance without manual refresh.
5. Compare displayed estimates with a current driving app at the same time. Waze and TomTom can differ; do not present either as identical to the other.
6. Confirm the Glance device's actual refresh cadence and input delivery after catalogue availability.

The package's offline tests and rendered demos do not satisfy these live checks.
