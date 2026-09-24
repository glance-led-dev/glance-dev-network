# Bambu Print Status — branded v2

Finished 192x32 dual-printer SCROLL dashboard. Content stays inside x=10..181.
Auto remains state-driven, with no printer/frame rotation. Four recognizable
device sprites replace the outline boxes. Bambu Lab's symbol and wordmark use
local raster adaptations of logo artwork; product names use dedicated geometric
wordmark PNGs rather than the GDN text font. Status and job text remain measured
bitmap text. See [asset provenance and dimensions](assets/README.md).

The `SPLASH` demo is a short startup-screen concept. It does not interrupt Live:
the host has no boot lifecycle or sub-refresh animation API. The static nozzle
sits at the current progress-bar fill edge; time does not move it.
Refresh and authenticated request caching remain unchanged.

## Setup

Each user supplies their own bridge/status endpoint and their own `READ_KEY`.
The data path is:

Bambu printer(s) -> Bambu Cloud -> local Bambu Glance Bridge -> user's
Cloudflare Worker -> Bambu Print Status GDN app

1. Configure your compatible bridge and Worker (see Backend setup below).
2. Enter the full HTTPS `/status` URL in **Status endpoint URL** (`endpoint`),
   for example `https://your-worker.your-subdomain.workers.dev/status`.
   This is a placeholder; replace it with your own endpoint.
3. Enter your bridge's `READ_KEY` in **Bambu status read API key** (`readkey`).
   Glance stores this through its encrypted `app_input_type: api-key` setting.
   The app sends it only as the `x-api-key` HTTP header to your configured endpoint.
4. Leave **Studio demo scenario** at **Live** and choose **View mode**:
   **Auto** (default), **AMS** (combined inventory), **AMS 2 Pro**, **AMS HT**,
   **Summary**, or **Diagnostics** (`viewmode`).

Refresh and HTTP cache TTL are both 300 seconds for the free-text and api-key
inputs. There is no default backend. Endpoint and key are never drawn on the
panel. Missing settings show SETUP REQUIRED / ADD ENDPOINT + KEY; a configured
endpoint without the `https://` prefix shows INVALID ENDPOINT / HTTPS REQUIRED.
A failed request shows NO PRINTER DATA / CHECK CONNECTION.

All named demo scenarios work without an endpoint or key and never request
network data. Sample selection stays explicit in settings. Per the design brief,
there is no DEMO text in the panel artwork; the review gallery labels scenarios
outside the 192x32 image. This passes GDN's checks without relaxing validation.

## Backend setup

This app requires a compatible Bambu Glance Bridge endpoint. The companion
bridge package provides the local Bambu Cloud collector and Cloudflare Worker.

### Companion backend

The companion backend project is available here:

https://github.com/nickolbp21-web/bambu-glance-bridge

It includes the local Bambu Cloud bridge, Cloudflare Worker, D1 setup,
Windows background-task scripts, and full installation instructions.

Your endpoint must return HTTP 200 with the JSON contract documented below;
an arbitrary printer API is not interchangeable with this bridge contract.
## Automatic presentation

- Both idle: compact Bambu symbol, distinct full-height printer sprites,
  model wordmarks and READY. Old jobs are hidden; daily totals live in Summary
  so that idle can prioritize recognizable device artwork.
- One printing/preparing: full-height device sprite, model wordmark, job,
  percentage, local completion clock, filament-colored bar, static progress
  nozzle and compact slot/type
  when it fits. The P2S sample job is Tegan Cat.
- Both active, including paused + printing: simultaneous rows with model,
  percentage/state, job, completion clock and independent progress colors.
- Errors/offline: red, above normal activity in priority. A second active
  printer remains visible. Paused uses amber and takes priority over start events.
- Start events: temporary NEW PRINT STARTED takeover. Finish events or FINISHED
  state: positive green completion screen, checkmark and full 100% progress bar.
- Idle temperature warnings show relevant hot bed/nozzle readings. Finished
  prints show HOT when the bridge signals a temperature warning.
- Stale: amber DATA STALE / CHECK BRIDGE. Failed or malformed HTTP data:
  NO PRINTER DATA / CHECK CONNECTION or CHECK BRIDGE.

`display_job` is preferred to `job`, with measured truncation. Completion clocks
use `estimated_completion_local`; UTC estimates and remaining minutes are not
substituted. Missing clocks are explicitly unknown. Actual completion timestamps
are shown only when `completed_at_local` or `finished_at_local` is supplied.
Layer context fits beside the local completion clock when a filament label is absent; job, percentage
and completion time retain priority.

Active filament RGB colors drive the status, nozzle and progress fill. Very dark
colors are lifted for LED contrast while preserving hue. Alpha in RGBA strings
is ignored. Invalid/missing colors fall back to the normal state color.



## AMS and diagnostics

AMS shows both printers simultaneously, up to five slots each: A1-A4 and HT1
(DY1 is renamed HT1). Actual color swatches and filament types are shown, with
an underline on the active slot. Remaining percentages are intentionally omitted
because they do not fit this fixed inventory grid without harming readability.

**AMS 2 Pro** shows its four-spool enclosure, A1-A4 color swatches, a colored
outline for the active slot, and an ACTIVE slot/material label. Dedicated AMS
screens retain the associated printer's model wordmark in the upper-right.
**AMS HT** shows the tall single-spool cover and dark display/base, with only
the loaded material, a color indicator, and ACTIVE or LOADED. It never draws
A1-A4 or slot-count filler text. Explicitly
empty slots show NOT LOADED; absent HT records show NO HT DATA / CHECK BRIDGE.
`HT*`, legacy `DY1`, or `device: "AMS HT"` identifies an HT record; `loaded: false`,
`empty: true`, or absent/empty material marks an unloaded slot. Dedicated views
prefer a printer with an active matching slot, then the first with matching data.
The printer model remains visible. The original combined AMS mode is retained.

**Summary** gives the daily counts and observed print duration their own branded
screen. Additional no-network demos cover SPLASH, AMS 2 PRO, AMS HT (active),
AMS HT LOADED, AMS HT EMPTY and DAILY SUMMARY.

Diagnostics is an explicit allowlist: bridge retrieval status, numeric
`age_seconds`, printer online state, and cloud connectivity. Unknown cloud status
is not claimed fresh. No raw diagnostics object, tokens, credentials, email,
serials, or IP addresses are rendered. Lifetime data is not shown.

## Bridge JSON contract

The `/status` response is a JSON object with a nonempty `printers` array.
A minimal ready response is:

```json
{"printers": [{"model": "P2S", "online": true, "state": "IDLE"}, {"model": "X2D", "online": true, "state": "IDLE"}]}
```

Each printer may supply `name`, `model`, `online`, `state`, `job`, `display_job`,
`progress` (0-100), `estimated_completion_local`, `completed_at_local` or
`finished_at_local`, `active_filament_color` (RGB/RGBA hex),
`active_filament_type`, `active_filament_slot`, `layer`, `total_layers`,
`ams_slots`, `temperature_warning`, `hot_components`, `bed_temp`, and
`nozzle_temp`. States are IDLE, PRINTING, PREPARING, PAUSED, ERROR, OFFLINE,
and FINISHED; RUNNING, PREPARE, FINISH, and READY are accepted aliases.
Optional top-level fields are `daily_summary`, `diagnostics`, `age_seconds`,
`stale`, and `event`. Diagnostics consumes `age_seconds` and `cloud_connected`.
Missing optional display values use the app's unknown/empty presentation.


`printers` is a list; this dashboard uses its first two records in bridge order.
The supplied printer fields are consumed directly. AMS slot dictionaries support
`slot`/`id`/`name`, `color`/`filament_color`, `type`/`filament_type`, and `active`.
Daily completed counts accept `completed_prints`, `prints_completed`,
`print_count`, `total_prints`, or `prints`; time is `observed_print_minutes`.

Events match printer model/name/id and accept numeric Unix expiry, ISO expiry
with UTC/offset, or `age_seconds` plus `ttl_seconds`. `expired: true` and
`active: false` suppress takeovers. If expiry is absent, the bridge owns event
lifetime and must remove expired events. An event with no identifiable printer
is used only when exactly one printing/preparing/finished printer is present.

## Verification

Run `py -3.14 apps/bambu-print-status/tests/check_behavior.py` for behavioral
checks, including configuration states, authenticated transport, and every demo
scenario without network access. The Python-compatible harness complements
actual Starlark rendering and full validation with Glance MCP.

Run `py -3.14 apps/bambu-print-status/tests/render_v2.py` with the repository's
Python dependencies installed to render all 32 demos, validate asset references
against the manifest, assert 192x32 dimensions and x=10..181 pixel bounds, and
regenerate the catalog and scenario gallery. `tests/build_assets.py` rebuilds
the 13 runtime PNG assets offline from the retained reference artwork.
If using the optional app-local dependencies on this workstation, first set
`$env:PYTHONPATH = (Resolve-Path apps/bambu-print-status/.render-deps).Path`.
That ignored directory is tooling only, not part of the app or its configuration.

Render setup required, invalid endpoint, simulated HTTP failure, both idle,
P2S printing, both printing, AMS inventory, and diagnostics with Glance MCP.
Authenticated retrieval requires your own running backend and key.

## Catalog previews

Regenerate submission images with explicit sample inputs, leaving the deployed
defaults at Live / Auto and the encrypted readkey input unchanged:

```powershell
py -3.14 -c "from gdn.preview import write_previews; write_previews('apps/bambu-print-status', inputs={'demo': 'P2S PRINTING', 'viewmode': 'Auto'})"
```

This writes `preview/main.png` and the enlarged `preview/preview.png` catalog
poster with a P2S sprite/wordmark, job name, percentage, completion clock, active
filament color, and progress bar. No API key is needed. GDN's current preview
writer supports app pages, not additional demo scenarios for the same page.
Inspect BOTH PRINTING separately with Glance MCP `render_app` and
`inputs={"demo": "BOTH PRINTING", "viewmode": "Auto"}`.

The full renderer also writes `preview/branded-v2.png`, a twelve-screen contact
sheet, and native 192x32 images for every demo under `preview/scenarios/`.

The MCP `write_previews` wrapper, Studio submission, and `gdn submit` currently
regenerate images using manifest defaults. Run the explicit command above after
any such generation to restore the demo catalog images. Do not change manifest
defaults to generate previews. This redesign was rendered and validated locally;
it was not pushed, submitted, or published.
