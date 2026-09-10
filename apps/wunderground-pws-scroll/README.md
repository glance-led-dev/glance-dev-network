# Personal Weather Station (PWS) – Weather Underground

Display real-time weather from **your** Weather Underground personal weather station on a Glance LED panel.

**Version 1.3** · App ID: `wunderground-pws-scroll`  
**By** [SlaterDen](https://https://github.com/SlaterDen/pwswu)

---

## App Settings

| Setting | Required | Description |
|--------|----------|-------------|
| **Station ID** | Yes | Your WU station ID (example: `KOKEDMON123`) |
| **API Key** | Yes | WU API key (encrypted api-key field in Glance) |
| **Temperature Unit** | Yes | **Fahrenheit** (°F, inHg, mph, in) or **Celsius** (°C, mb, km/h, mm) |
| **Location Label** | No | Custom label on the main page (e.g. `Home`). Blank = station city/neighborhood |

---

## How to Get Your API Key

1. Sign in via Weather Underground member devices:  
   (https://www.wunderground.com/member/api-keys)
2. Open the **API Keys** section for your account/devices.
3. Click **Generate**, copy the key, and paste it into the Glance app settings as **API Key**.

You need a station that reports to Weather Underground. Personal PWS API keys are free for compatible device owners.

---

## Pages

| Page | What’s shown |
|------|----------------|
| **Main** | Conditions + icon, temperature, feels-like, pressure & humidity gauges, dewpoint or UV, last-update age |
| **Wind** | Speed, gust, direction |
| **Rain** | Today’s total, rain rate, status, sparklines |
| **Alerts** | Active NWS alerts for the station lat/lon (U.S.). All-clear when none |

---

## Data Sources

| Source | Used for |
|--------|----------|
| **Weather Underground PWS API** (`api.weather.com`) | Current observations, 1-day history (pressure trend, recent rain, sparklines) |
| **National Weather Service** (`api.weather.gov`) | Active alerts near the station coordinates; office/point metadata |

This app is **not** affiliated with Weather Underground, The Weather Company, or the NWS. All weather data remains the property of those providers. Use of the WU API is subject to their terms and rate limits.

---

## Errors & Troubleshooting

| What you see | Likely cause | What to try |
|--------------|--------------|-------------|
| **PWS ERROR** / “Enter API Key + Station ID” | Missing or wrong settings | Confirm **Station ID** and **API Key** in app settings |
| **PWS ERROR** / no data | Bad key, wrong station id, or WU outage | Check the station page on WU; regenerate key if needed |
| **OFFLINE** / red age on main | Observation older than ~1 hour (3+ h shows OFFLINE) | Confirm the station is still uploading to WU |
| **NO RAIN DETECTED TODAY** | No precip total/rate today | Normal when dry |
| **Alerts: all clear** | No active NWS alerts at that point | Normal; not an error |
| Alerts empty / limited outside the U.S. | NWS coverage is U.S.-centric | Expected for many non-U.S. stations |
| Wrong unit (F vs C) | Temperature unit setting | Set **Fahrenheit** or **Celsius** in settings |
| UV missing, dewpoint shown | Station has no UV (or reports 0) | Normal; dewpoint is the fallback |

If one nearby station looks “stuck” (same values for hours) but others update, the feed may be stale even though WU still returns data—try another Station ID or wait for the age label to go red/OFFLINE.

---

## Conditions Engine (summary)

The main header picks a short label and icon from station sensors and, when relevant, NWS **warnings** (not watches), including severe thunderstorm and tornado warnings, rain, wind, fog, and clear/cloudy sky. UV/solar are used only when the station reports real sensor values.

A single PWS is a point measurement—always use official NWS sources for life-threatening weather.

---

## Notes

- Panel: **192×32**. Default refresh **120** seconds (layout may also control timing).
- Free WU PWS keys are typically limited to about **1,500 calls/day** and **30 calls/minute**. Requests use TTL caching where possible.
- Not affiliated with Weather Underground or the NWS.

---

## Credits

**SlaterDen** · Built for the [Glance Developer Network](https://glance-led.dev).