# Civic Center Muni

A 64×32 Glance app for San Francisco's **Muni Metro Civic Center station**.
The two pages show outbound and inbound trains separately. Each page fits up to
**eight letter/minute pairs** in two columns and four rows, using the regular
4×5 font with extra horizontal spacing. Route letters use line colors and minute
values are white. Read left-to-right, then top-to-bottom,
in arrival order. `0` means arriving now. The header reads
**EASTBOUND** for inbound toward Powell and **WESTBOUND** for outbound toward
Van Ness. There is no footer, station name, destination label, or unit suffix.

## Preview

From `/Users/dmitry/code/glance`:

```sh
.venv/bin/gdn studio apps/civic-center-muni
```

The local editor opens at `http://127.0.0.1:8766/`. With no token, both pages
show sample arrivals to preview a full grid. These are not actual train times;
the on-screen demo label has been removed at the user's request.

## Enable real arrivals

1. Request your free token at <https://511.org/open-data/token>.
2. Enter it into the **511 API token** field in Studio to preview live data.
3. On a published Glance installation, enter the token in the app's setup form.

The manifest uses Glance's `api-key` input type, which stores installed users'
keys encrypted. Keep a development token out of committed files. Do not put
your token into a publicly shared PNG URL.

**Refresh limitation:** the catalog app refreshes every **300 seconds** because
Glance prohibits API-key inputs at shorter refresh intervals. The displayed
minutes are a snapshot at render time, not a continuously ticking countdown.
For frequent updates, use Glance's personal hosted-PNG workflow and a separate
always-on renderer; that hosting path has not yet been configured here.

## Data

The app calls 511's `StopMonitoring` endpoint over HTTPS with `agency=SF`:

| Page | Public stop code | SFMTA internal ID |
| --- | --- | --- |
| Outbound | 16997 | 6997 |
| Inbound | 15727 | 5727 |

Stop codes and platform directions were checked against
[SFMTA's public stop metadata](https://www.sfmta.com/find-a-stop/query?include_stops=15727,16997)
on October 9, 2026. Route colors are brightened for the LED panel.

The parser uses expected arrival/departure timestamps, excludes scheduled-only,
cancelled, expired, stale and non-Metro predictions, separates the platforms,
sorts by arrival time, and removes duplicate trips. The screen explicitly shows
feed failures and empty predictions. A failed live request never falls back to
unlabeled sample data.

Two platform requests every five minutes use approximately 24 requests/hour for
one installation, below 511's [default 60/hour token limit](https://511.org/open-data/transit).
Repeated refreshes in Studio and other apps sharing your token can add requests.

Live authenticated requests were **verified on October 9, 2026**: both platform
feeds returned HTTP 200, with stop 15727 named `Metro Civic Center Station/Downtn`
and direction `IB`, and stop 16997 named `Metro Civic Center Station/Outbd` and
direction `OB`. The live preview rendered the actual arrivals. The development
token was entered in the preview field; it is not included in the manifest.
The parser has also been exercised with fixtures based on the
[official SIRI JSON specification](https://511.org/sites/default/files/2025-05/511%20SF%20Bay%20Open%20Data%20Specification%20-%20Transit.pdf).

## Check and build

```sh
.venv/bin/gdn check apps/civic-center-muni
.venv/bin/gdn validate apps/civic-center-muni
.venv/bin/gdn build apps/civic-center-muni
```

Build output is under `build/` and ignored by Git.

## Get it onto the screen

For the catalog route, [submit the app through Glance](https://glance-led.dev/docs/publish/).
It needs their review and publication before it appears in the device's app
catalog. This project has not been submitted or installed on your device.

For the personal route, [Glance accepts hosted PNGs](https://glance-led.dev/docs/private-apps/)
via the Setup app's Private Apps tab. Each direction needs a separate 64×32 PNG
endpoint. Treat those images as public; this app contains only public station
arrival information.
