# Personal Weather Station (PWS) – Weather Underground

Display real-time weather from **your** Weather Underground personal weather station on a Glance LED panel.

**Version 1.5** · App ID: `wunderground-pws-scroll`  
**By** [SlaterDen](https://github.com/SlaterDen/pwswu)

---

## App Settings

| Setting | Required | Description |
|--------|----------|-------------|
| **PWS Station ID** | Yes | Your WU station ID (example: `KOKEDMON123`). Spaces are trimmed and letters are uppercased automatically |
| **Weather Underground API Key** | Yes | Your WU API key (stored encrypted by Glance). Spaces are trimmed automatically |
| **Temperature Unit** | No | **Fahrenheit** (°F, inHg, mph, in) is the default. **Celsius** gives °C, mb, km/h, mm |
| **City Label (Optional)** | No | Custom label on the main page (example: `Home`). Leave blank to use the station's city or neighborhood |

Until both the Station ID and API Key are filled in, the app shows a **DEMO** screen.

---

## How to Get Your API Key

1. Sign in to Weather Underground and open your API keys page:  
   <https://www.wunderground.com/member/api-keys>  
   (Account → My Devices → **API Keys** tab)
2. Click **Generate**, copy the key, and paste it into the Glance app settings as **Weather Underground API Key**.
3. Find your **Station ID** on the same account's **My Devices** page, or on your station's WU page.

You need a station that reports to Weather Underground. Personal PWS API keys are free for compatible device owners. Keep your key private and don't post it publicly.

---

## Pages

| Page | What's shown |
|------|----------------|
| **Main** | Conditions + icon, temperature, feels-like, pressure and humidity gauges, dewpoint or UV, time of the last station report |
| **Wind** | Speed, gust, direction |
| **Rain** | Today's total, rain rate, storm total, sparklines, and a rotating storm-status headline |
| **Alerts** | Active NWS alerts for the station's lat/lon (U.S.), up to 3. A tornado or severe thunderstorm warning takes over the whole page. "All clear" when none |

---

## Data Sources

| Source | Used for |
|--------|----------|
| **Weather Underground PWS API** (`api.weather.com`) | Current observations, 1-day history (pressure trend, recent rain), rain history and sparklines |
| **National Weather Service** (`api.weather.gov`) | Active alerts near the station coordinates; office/city lookup |

This app is **not** affiliated with Weather Underground, The Weather Company, or the NWS. All weather data remains the property of those providers. Use of the WU API is subject to their terms and rate limits.

---

## Errors & Troubleshooting

| What you see | Likely cause | What to try |
|--------------|--------------|-------------|
| **DEMO – SAMPLE DATA** | Station ID or API Key is blank | Enter both in the app settings |
| **PWS ERROR** / BAD API KEY | WU rejected the key | Check the key on the WU API Keys page; regenerate it if needed |
| **PWS ERROR** / NO DATA FOR STATION | WU has no data for that station ID | Check the Station ID spelling and that the station is online on WU |
| **PWS ERROR** / WU UNAVAILABLE | Weather Underground is down or slow | Wait for the next refresh |
| **ALERTS ERROR** / NWS UNAVAILABLE | The NWS alerts service didn't respond | Wait for the next refresh. The other pages keep working |
| **OFFLINE** in the main header | The newest station report is over 1 hour old | Confirm the station is still uploading to WU |
| **NO RAIN DETECTED TODAY** | No precipitation total or rate today | Normal when dry |
| **Alerts: all clear** | The NWS reports no active alerts at that point | Normal, not an error |
| Alerts empty or limited outside the U.S. | NWS coverage is U.S.-only | Expected for non-U.S. stations |
| Wrong unit (F vs C) | Temperature Unit setting | Set **Fahrenheit** or **Celsius** in settings |
| UV missing, dewpoint shown | Station has no UV sensor (or reports 0), or UV is below 5 | Normal. Dewpoint is the fallback and UV appears at 5 or higher |

If a nearby station looks "stuck" (same values for hours) while others update, the feed may be stale even though WU still returns data. Check the report time on the main page, try another Station ID, or wait for OFFLINE to appear.

---

## Conditions Engine (summary)

The main header picks a short label and icon from station sensors and, when relevant, NWS **warnings** (not watches). It covers severe thunderstorm and tornado warnings, rain, wind, fog, and clear/cloudy sky. UV and solar readings are used only when the station reports real sensor values. If the NWS can't be reached, the main page still works and simply skips the alert-based conditions.

A single PWS is a point measurement. Always use official NWS sources for life-threatening weather.

---

## What's New in 1.5

- Clear error screens for a bad API key, an unknown station, WU outages, and NWS outages
- DEMO screen when the API Key or Station ID is missing
- City Label setting fixed, and now optional with automatic fallback to the station's city
- Station ID and API Key are cleaned up automatically (spaces, lowercase)
- The Rain page no longer says "no rain" when WU can't be reached
- The Alerts page no longer says "all clear" when the NWS can't be reached
- The main page shows the time of the last station report instead of a "minutes ago" label, which can go stale between refreshes
- Fewer network requests on the main page (pressure trend and rain checks share one history fetch)
- Feels-like fixed for Celsius and for stations that report no heat index
- Celsius color thresholds corrected
- Text positions are measured instead of assumed, so long labels and conditions no longer collide

---

## Notes

- Panel: **192×32**. The app refreshes about every **15 minutes**.
- Free WU PWS keys are typically limited to about **1,500 calls/day** and **30 calls/minute**. Requests use TTL caching, and pages share data where possible, to stay well under those limits.
- Hybrid units (°C with mph) are planned for a future update.
- Not affiliated with Weather Underground or the NWS.

---

## Credits

**SlaterDen** · Built for the [Glance Developer Network](https://glance-led.dev).