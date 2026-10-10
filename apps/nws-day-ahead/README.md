# NWS Day Ahead

A 64×32 Glance LED app: the rest of your day, or tomorrow, on one screen, from the
National Weather Service. Every slot leads with the chance of rain.

```
TODAY 69F/56F             TOMORROW 62/59
 NOW  12P  6P  10P         10P | 8A  12P  6P
```

- **Before 5pm:** today's high/low, then four hourly slots: 8A, 12P, 6P and 10P.
  After 8am the first slot shows the current hour (**NOW**).
- **From 5pm:** tomorrow's high/low, with tonight at 10P on the left, then tomorrow's
  8A, 12P and 6P. After 10pm, tonight's slot shows **NOW**.
- **Each slot:** an icon for NWS's condition code at that hour, the chance of
  precipitation (blue when above 0%), and the hour. Hours already past show a dash.

## Settings

| Setting | |
|---|---|
| Zip code | Any US zip code. NWS covers the US only. |

No API key needed. 5pm is local to the zip code, read from NWS's own timestamps,
so daylight saving is handled.

## Data

`api.weather.gov`: the `forecast` feed for the high/low, `forecastHourly` for the slots.
Condition codes are listed at [api.weather.gov/icons](https://api.weather.gov/icons).
Zip lookup is via `api.zippopotam.us`. Sprites are shared with `nws-forecast`.
