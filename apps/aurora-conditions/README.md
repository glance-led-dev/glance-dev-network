# Aurora Conditions

Whether tonight is worth going outside for. The solar wind as it arrives,
the planetary K index at the hours you would actually be out, and a verdict
that only calls a night good when the aurora can reach *your* latitude and
the sky will let you see it. No key or account needed. US only, because the
ZIP lookup is.

## Settings

| setting | what it is |
|---|---|
| **ZIP code** | Your 5-digit US ZIP, e.g. `06001`. It sets how far south the aurora has to come to find you, plus your cloud cover, moon and local forecast hours. Leave it blank and the solar wind page still works on its own. |

## The pages

- **Solar wind** - Bz as the hero, because a southward Bz is what actually
  opens the door, with Bt, speed and density in the rail beside it. Each
  one is banded green to red against the values aurora chasers work to, and
  carries a trend arrow read over the last three hours.
- **Kp** - the forecast at 8pm, 11pm, 2am and 5am in your local time. Three
  hours apart because Kp is published in three-hour blocks, so anything
  closer would print the same number twice. The dotted line across the bars
  is the Kp *your* ZIP needs before the aurora reaches it - bars below the
  line are a quiet night wherever else they might be a show.
- **Tonight** - one verdict for the night, and the hour it belongs to.

## How the verdict is worked out

Three things multiply, rather than average, because any one of them at zero
ends the night:

- **Does the oval reach you.** NOAA puts the auroral oval's equatorward edge
  at 66 degrees magnetic latitude at Kp 0, moving about two degrees south
  per Kp step, with the glow visible a few hundred kilometres further south
  again. That is measured in *geomagnetic* latitude, not the latitude on a
  map - New England sits about nine degrees further north magnetically than
  geographically, which is the whole reason Connecticut ever sees an aurora.
  The app computes the dipole latitude for your ZIP.
- **Is the sky clear.** Hourly cloud cover for your ZIP.
- **Is it dark enough.** The moon's illuminated fraction weighted by how
  high it rides, so a full moon below the horizon costs nothing and the same
  moon overhead costs a great deal. Position is computed in the app, not
  fetched.

Each of the four hours is scored separately and the best one wins, so a
night that is solid cloud except for one clear window still reads as the
opportunity it is, and the header names the hour.

At 51 degrees magnetic - roughly Connecticut - that puts **MED** at around
Kp 5 (camera only, low on the northern horizon), **GOOD** near Kp 6.5
(moments of naked eye, much better through a lens) and **HIGH** above Kp 7
(naked eye, overhead). Further north those thresholds fall; at Fairbanks a
Kp 3 already clears them.

## Notes

- Sources: NOAA SWPC real-time solar wind (`rtsw_mag_1m`, `rtsw_wind_1m`)
  and planetary K index forecast, Open-Meteo for cloud cover and the local
  UTC offset, and Zippopotam for the ZIP lookup. All public and keyless.
- The solar wind feeds interleave three spacecraft and are larger than the
  host will load, so the app asks for the first 420 KB of each and reads the
  spacecraft NOAA flags as operational. The others are cross-checks; one of
  them has a degraded density sensor and reporting it would put a plausible
  wrong number on the panel.
- The verdict bands were checked against four dated photographs from one
  location in Connecticut, with the Kp for the minute each shutter fired and
  the sky brightness taken from the exposure the camera chose. All four land
  in the right band.
- Most nights below about 55 degrees magnetic will read **LOW**, and that is
  the honest answer rather than a fault. It is what makes the other nights
  worth trusting.
- The panel refreshes every 10 minutes.
