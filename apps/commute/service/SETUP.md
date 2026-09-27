# Activate your own Commute

The app is built, but live operation needs your routing account, OHGO registration and a deployed private service. Enter secrets locally or in Cloudflare's secret fields; do not paste them into shared issues, public configuration or screenshots.

## 1. Accounts

- Create a TomTom developer key with Routing and Search access at the [TomTom developer portal](https://developer.tomtom.com/). The service can accept precise coordinates instead of addresses, removing the need to geocode.
- Register for an OHGO key at [OHGO](https://publicapi.ohgo.com/). Its documented resources include incidents, construction and road-weather stations, not arbitrary home-to-work routing.
- Use your Cloudflare account with Workers and SQLite-backed Durable Objects enabled (available on Cloudflare Free). Review the account's provider quotas before enabling frequent checks. This app does not create or upgrade paid subscriptions.

## 2. Private trip configuration

Copy `worker/config.example.json` to an unshared file named `config.private.json`. Fill in the locations, stop, time zone and arrival time. Each location accepts either `{ "address": "your complete address" }` or `{ "lat": 40.0, "lon": -84.0 }` (these numbers are illustrative).

For a campus, hospital or large workplace, use the actual parking entrance coordinates rather than the street address of the entire campus. Ambiguous geocoding deliberately fails with CHECK LOCATIONS. A route cannot be confirmed until its destination entrance is correct.

An optional stop is configured with `stop.enabled`, `stop.name`, `stop.location` and `stop.durationMinutes`. Any business or errand stop is supported; coffee is just an example.

For specific route corridors, add up to two `routeOptions` entries. Each contains a `name` and a `via` array of up to six `{lat,lon}` points in travel order. Place each point on the correct carriageway. These routes are compared with the provider's automatic alternatives; point placement must be checked on a map. Live road labels still come from the returned route.

Arrival presets in Glance and the companion are 8:00, 8:15 and 8:30 AM. The Configured option uses any valid `arriveBy` value from this private file. Changing the preset recalculates leave-by estimates without making an extra routing request.

## 3. Dedicated Worker

From the `worker` folder, deploy with `npx wrangler deploy`. The configuration creates a dedicated SQLite-backed Durable Object; no KV namespace or paid subscription is needed. Set these Worker secrets using protected prompts or your Cloudflare dashboard:

- `CONFIG_JSON`: your private route configuration as a JSON string.
- `TOMTOM_KEY`: the routing provider key.
- `OHGO_KEY`: your OHGO key.
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
3. Verify OHGO and NWS schemas with the user's live account and inspect feed coverage for the commute.
4. Observe at least two scheduled collections and confirm timestamps advance without manual refresh.
5. Compare displayed estimates with a current driving app at the same time. Waze and TomTom can differ; do not present either as identical to the other.
6. Confirm the Glance device's actual refresh cadence and input delivery after catalogue availability.

The package's offline tests and rendered demos do not satisfy these live checks.
