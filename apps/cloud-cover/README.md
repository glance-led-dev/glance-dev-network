# Cloud Cover

A live satellite view of your own patch of the Earth on a **192x32** panel.
GOES-19 sits over 75.2W and GOES-18 over 137.0W, both 35,786 km up, and
they photograph the Americas every ten minutes. This puts your corner of
that picture on the glass, full bleed.

![Cloud Cover](preview/preview.png)

No key, no account. Both sources are public.

## The two pages

**close** — your region, centred on your ZIP code, with a small target
marking the spot. GeoColor, so it is cloud by day and city lights by night.
The clouds are where they actually are: look out of the window, then look at
the panel.

**storm** — the same sky as cloud-top temperature, pulled back a little.
Grey where the air is quiet, then green, yellow and red as the tops climb.
It says something the photograph cannot, and because it reads temperature
rather than light it is just as good at three in the morning.

Both pages carry the state and coast outlines, because a 192x32 strip of
cloud is beautiful and completely unplaceable without them.

There used to be a third page showing the whole hemisphere. A 5,424-pixel
disk resampled to 32 across is a blur, and it has been dropped.

## How a photograph gets onto a panel

This is the part worth knowing about, because at first glance it is
impossible. `http.get` carries text, not bytes, and `c.image()` only reads
files shipped inside the app — so an image from the internet has no way in.

The way through is [images.weserv.nl](https://images.weserv.nl). It will
fetch any public image, resize it to exactly 192x32 and re-encode it as a
PNG with **stored** (uncompressed) deflate blocks, handed back as base64
text. That last part is the trick: with `l=0` there is nothing to inflate,
so the decoder in `app.star` is forty lines rather than a zlib
implementation. The technique is cfdmb's — [`rain-watch`](../rain-watch)
reads weather radar exactly this way, and it is the reason this app exists
at all.

## Which picture, and which frame

NASA's [GIBS](https://nasa-gibs.github.io/gibs-api-docs/) serves GOES
imagery over WMS, which takes an arbitrary bounding box and output size. So
the frame can be centred on a ZIP code at any scale, with no tile stitching
and no projection maths beyond one cosine to stop the longitude span from
stretching.

GIBS lists a frame in its time index slightly **before** the pixels exist,
and the placeholder is a 104-byte transparent PNG — which the proxy
faithfully re-encodes into a full-size black one, so no response-size check
can catch it. Two things follow, and both are in the code:

- the newest listed frame is skipped by default, and
- a frame with no light in it at all is treated as missing and the app
  steps back ten minutes and asks again, up to three times.

Asking for an explicit timestamp matters too. Letting GIBS pick the default
time failed **two renders in ten** in testing; an explicit timestamp did not
fail once in ten.

## How current is it

However far behind GIBS is running, which is not a fixed number: measured at
twenty minutes one morning and two hours forty the next. The app always
draws the newest frame GIBS admits to, less one ten-minute step, and prints
that frame's own time on the panel rather than the clock's — so what you are
looking at is never in doubt, even on a slow day.

An hour of lag sounds worse than it is: at the `NORMAL` setting one pixel is
17 km, so an hour of a weather system's travel is two or three pixels.

If the newest frame ever falls more than three hours behind, the panel stops
showing a time and says how old the picture is, in amber. It would rather
admit to being stale than quietly pretend.

## Settings

| Setting | What it does |
|---|---|
| **US ZIP code** | Where the view is centred. GOES-East is used east of about 112W and GOES-West beyond it, so Alaska and Hawaii work. |
| **How close** | `TIGHT`, `NORMAL` or `WIDE` on the first page — about 330, 550 or 890 km from top to bottom. |
| **Mark your spot** | The target at your ZIP code, on or off. |
| **State lines** | The outlines, on or off. On by default. |

A 6:1 panel is wider than it feels: 32 rows of 5 degrees is 555 km tall,
which at the same scale makes the picture some 3300 km across. `NORMAL`
already spans most of the width of the lower 48.

## Data sources

| Source | Used for | Cached |
|---|---|---|
| `gibs.earthdata.nasa.gov` (WMS) | both frames, GeoColor and band 13 | 300s |
| `gibs.earthdata.nasa.gov` (time index) | which frame is the newest | 300s |
| `api.zippopotam.us` | ZIP code to latitude and longitude | 30 days |

The outlines are not fetched. They are carried in the app, from the US
Census cartographic boundary file.

`refresh` is 600s, matching the satellite's ten-minute cadence. The region
pages make two calls on a good render and at most four if the newest frames
come back empty; the limit is eight.

## When something is missing

| Screen | Meaning |
|---|---|
| `NO LOCATION` / `CHECK THE ZIP CODE` | the ZIP is not five digits |
| `NO LOCATION` / `NO SUCH US ZIP CODE` | the lookup does not know it |
| `NO LOCATION` / `ZIP LOOKUP DID NOT ANSWER` | zippopotam did not answer |
| `NO FRAME INDEX` / `GIBS DID NOT ANSWER` | the time index did not answer |
| `NO PICTURE` / `THE GOES-EAST FRAME DID NOT ARRIVE` | three frames in a row came back empty |

There is no demo mode. A panel whose whole purpose is to show you the real
sky has no business inventing one.

## The state lines

NASA is no help here. `Reference_Features` draws nothing at all through
WMS, and the `Coastlines` layer put 19 lit pixels on a 6144-pixel panel —
anti-aliased hairlines do not survive a downscale to 32 rows. So the
outlines are carried in the app instead, from the US Census cartographic
boundary file.

**Only the borders between states are drawn.** A segment belonging to two
states is the line between them, and nothing in a photograph from orbit can
show it. A segment belonging to one state is an outside edge — coast, lake
shore, national boundary — and the satellite draws every one of those
already, by the water being darker than the land. Tracing them a second
time added no information and two thirds of the table, all of it in the
wiggliest places: Long Island, Cape Cod, the Chesapeake, the Great Lakes.
That is what made the panel look like a thicket. Dropping them took the
close page from 218 line ops to 96.

Getting the rest of it right took three goes, and every failure looked like
a styling problem right up until it was measured against the source.

**Rings are the wrong unit.** The first version simplified each state's
boundary on its own. Kansas and Nebraska each carry the line between them;
Douglas-Peucker kept different vertices on each pass; the two copies landed
a pixel apart. Most of what looked like a map was railroad track — 18% of
the panel lit, and unreadable.

**A long step has to be broken up along the line.** Each step is two
characters, so anything wider gets split. Clamping each axis separately
walks as far as it can in latitude, then in longitude — turning a long
diagonal into a dogleg that wanders degrees from the border it is meant to
be drawing. Subdividing into equal steps fixes it. This stayed invisible
while points were close together and appeared the moment chaining made the
runs long.

**A chain must stop where borders meet.** Walk through a junction and the
chain runs up one border and down another; simplify that and the corner
gets cut — a clean diagonal straight across the map where no border exists.
Nodes of any degree other than two are terminals.

So: snap every point to an eighth of a degree, which makes a shared
boundary the *same* sequence on both sides; break the rings into segments;
drop the 838 duplicates; chain the survivors between junctions; simplify
each arc at 0.08°; and split long steps along the line. The result agrees
with the raw Census file pixel-for-pixel 63% of the time at panel
resolution, and almost all of the rest is a one-pixel grid offset.

An eighth of a degree is about 14 km — under one pixel at the close zoom,
where one pixel is 0.2°. The table packs into a 1.9 KB string.

Drawing is one pass: decode, project, skip any segment whose ends land on
the same pixel or that falls entirely off one edge. That leaves 96 line ops
on the close page, against a 4096 limit.

The lines were dotted for a while, which was treating the symptom. With the
geometry right, a solid line is both quieter and clearer. Dark copper, so
it sits under the weather rather than on top of it — amber read like a road
atlas, and brighter copper still won the frame.

**If you build something like this: render your table against the source
data at six times panel resolution before trusting it.** Every one of these
faults was obvious in that comparison and invisible on the panel, where
each just looked like ugly styling.

## Notes on the drawing

192x32 is 6144 pixels, while a page may emit at most 4096 draw ops and no
single bitmap may hold more than 4096 cells. `c.sprite` emits one bitmap per
colour in its legend, so the frame is quantised to at most 80 colours and
laid down in three 64-wide chunks — a few dozen bitmaps of 2048 cells each,
inside both limits.

The quantiser has to run in Starlark, which rules out a nearest-colour
search: 6144 pixels against 80 colours is half a million comparisons. So the
buckets are **fixed** and cheap — 32 steps of grey for anything
near-neutral, which is most of a satellite picture, and 48 coarse chroma
cells for land, city lights and the sunlit limb — while the **colour** of
each bucket is the mean of the pixels that landed in it, which costs one
running total. Fixed buckets, adaptive palette, one pass. Measured against
the original frame it lands about three times closer than a uniform 4x4x4
colour cube, which turns cloud into confetti.

Eighty buckets is what the scheme can distinguish, not what a page may
spend. A bitmap is a row of `0`/`1` integers in the scene, so each colour on
a wide page costs about 15 KB, and the three pages share a 1 MiB budget —
which three photographs blew through at 1.31 MiB. How many buckets a frame
reaches is decided by the cloud, so each wide page now keeps its 20 most
populous and folds every thinner one into the survivor nearest it in colour,
recomputing that survivor's mean over the pixels it inherits. RMS error
against the original goes from 5.6 to 8.7 — still far better than the 31.4
of the uniform cube — and the app is 0.80 MiB with a ceiling of 0.81 MiB
that no weather can push past. The disk page keeps 32 colours, because at
32x30 its cells cost a sixth as much and the limb needs the gradient.

Worth knowing if you are building something similar: `gdn validate` renders
one page at a time, so it never sees the total and passed throughout.
Studio builds every page into one scene and will tell you when they do not
fit.

Near the end of the map — Alaska, Hawaii — the bounding box is slid back
onto it rather than narrowed, because narrowing it would collapse the wide
page onto the close one. The viewer stops being dead centre when that
happens, which is why the target is positioned from the bounding box rather
than pinned to the middle. At the far edge of what a satellite can see you
may catch the curve of the disk itself in a corner, black and sharp. That is
the edge of the world as GOES can see it, not a fault.

Nothing on these pages is a label standing in for a thing. It is the thing.

## Running it

From the repository root:

```bash
gdn studio apps/cloud-cover
```

Rendering one page:

```bash
gdn render apps/cloud-cover --page 2 --input "zip=80202"
```

To see the no-data screens, set `GDN_HTTP_OFFLINE=1` first — every
`http.get` then fails, which is what the publish-time validator does.

If `gdn` is not on `PATH`, use `python -m gdn` in its place.

The preview images show a daylight pass over Colorado; the app renders
whatever the satellite is looking at when your panel asks.

Imagery courtesy of NOAA and NASA's Global Imagery Browse Services, part of
the Earth Observing System Data and Information System.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
