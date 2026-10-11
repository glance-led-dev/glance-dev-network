# NASCAR Scoring Pylon

NASCAR Scoring Pylon is a GLANCE sports app by reyos86. It shows a full-field running order for Cup, O’Reilly Auto Parts, or Trucks on a wide panel, with flag-colored header status and ticks for pits, DVP, garage/repair, fastest lap, and lead-lap separation. Viewers can mark up to three favorite cars so they can find them on the pylon at a glance.

![NASCAR Scoring Pylon preview](preview/preview.png)

## Preview

From the GLANCE Developer Network repository:

```powershell
pip install -e .
gdn studio apps/nascar-pylon
```

The browser-only preview is also available with:

```powershell
gdn preview apps/nascar-pylon
```

If the `gdn` executable is not on `PATH`, use `python -m gdn.cli` in its place.

## Configuration

- **Series** — `CUP`, `OREILLY`, or `TRUCKS` (default `CUP`). Selects which national series schedule and live feed to follow (Cup, O’Reilly Auto Parts, Trucks). The code still accepts a legacy `XFINITY` alias and maps it to the same series ID / `ORL` short label.
- **Favorite car 1–3** — optional car numbers to highlight (for example `24`). Type the number exactly as it appears on the car: `02` and `2` are different cars. A leading `#` is ignored. Leave blank for none; a number that is not in the field simply shows nothing.
- **Favorite highlight color** — `AQUA` (default), `PINK`, `WHITE`, `MAGENTA`, `CORAL`, `ORANGE`, or `YELLOW`. Only the favorite's position number and a dim row wash take the color, so status ticks and car-number colors never change. Greens, red, blue, and purple are left out because they blend with the gain/loss numbers, Chase bar, or fastest-lap tick, or are too dark on the LEDs.

## Pages

| Page | Contents |
|------|----------|
| **pylon** | Full running order in columns: car numbers with status ticks, plus a left header for series, session/stage, and laps to go (or `FINISHED`). |

Panel size is **384×32** (Scroll). Refresh is **300 seconds** (5 minutes). Series labels: `CUP`, `ORL`, `TRK`.

The refresh must stay at 300 seconds or slower: the favorite-car settings are free-text boxes, and Glance only allows free-text settings on apps that refresh every 5 minutes or slower.

## Data source

Public NASCAR Content Feed CDN (`cf.nascar.com`):

- Season schedule (`race_list_basic.json`, cached about one hour)
- Live / results feed for the selected series and race (shorter TTL while active)

No API key is required.

**Race selection:** prefer the next unfinished race’s live feed; if that is unavailable, fall back to the most recent finished race.

## Display behavior

- **Field layout** — cars sorted by running position, packed into columns (about five cars per column). The top-five column is highlighted. Overflow beyond panel width is dropped.
- **Position moves** — car number green for gains and red for losses (from feed differentials when present), otherwise white. The leader gets no special color; P1 is already the first slot on the pylon.
- **Favorites** — a favorite car's cell gets a dim wash in the chosen color and its position number turns that color. The car number, status ticks, Chase bar, and lead-lap cut are drawn exactly as they would be without it.
- **Pit tick (blue)** — recent pit within the last five leader laps; omitted when the car is out or repairing. After the checkered flag, the drive down pit road to the garage (logged by the feed as a stop on the final lap) is ignored.
- **DVP tick (orange)** — car is on Damaged Vehicle Policy.
- **Garage / repair** — yellow tick for garage or off-track (not retired), during races only. Before the green flag (lap 0 or the warm-up flag) only garage status counts, because the feed's on-track signal is unreliable then and has marked the gridded pole sitter as off track; in practice and qualifying, off-track cars keep muted numbers but no tick. Retired cars get a red DNF-style tick and muted numbers.
- **Fastest lap (purple)** — lowest positive last-lap time among cars still on track / in pits.
- **Lead lap** — soft cut before the first car a lap or more down; lapped cars use muted grey numbers.
- **Header** — series short name plus session context. Practice/qualifying show `PRACTICE` / `QUAL` (with short track name when space allows) so those sessions do not read as a green-flag race; race sessions show stage and laps to go. Accent color follows flag state when known.

No bundled car images — the pylon is number-and-tick typography only.

## Errors and empty states

- Schedule failure → `SCHEDULE ERROR` / `CF {status}`
- Nothing to show → `NO RACE` (with reason such as no finished race)
- Results feed failure → `NO RESULTS`
- Empty vehicle list → `NO FIELD`

Command-line example:

```powershell
gdn render apps/nascar-pylon --input "series=CUP"
gdn render apps/nascar-pylon --input "series=OREILLY"
gdn render apps/nascar-pylon --input "fav1=24" --input "fav2=9" --input "favcolor=PINK"
gdn validate apps/nascar-pylon
```

## Current technical limitations

- Series choices in settings are Cup / O’Reilly / Trucks (`XFINITY` remains a code-level legacy alias).
- Position deltas are approximate from the feed; the app does not store prior refreshes.
- Field width is limited by the 384px panel; not every entry may fit. A favorite car that falls outside the visible field is not shown.
- Favorites match the car number exactly as the feed prints it, so a car's number must be typed the way it appears (`02`, not `2`).
- Status ticks depend on fields present in the live-feed JSON.
- Depends on public CF CDN availability.
- Frames are still images redrawn on the refresh timer.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
