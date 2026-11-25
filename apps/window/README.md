# Window

A window onto a national park, live, on a **192x32** panel. Eighteen public
webcams, and the panel shows whichever one the sun is highest over at this
minute — first light over Acadia, mid-morning on the rim of the Grand
Canyon, afternoon in Denali, the last of the day on Kīlauea.

![Window](preview/preview.png)

No key, no account. Every camera is a US federal feed in the public domain.

## Why it follows the sun

A webcam panel sounds simple until you look at one at two in the morning.
I checked all twenty cameras I could find at 06:45 UTC: every single one was
black, fogged in, or showing infrared mush. Pointing the panel at one
favourite camera gets you something lovely for half the day and a dark
rectangle for the other half.

So the app ranks the cameras by the sun's altitude over each one and shows
the brightest. That costs nothing — solar position is arithmetic, not an API
call — and it means the panel is lit from about 11:30 UTC, when the sun
clears the Maine coast, until about 04:00 UTC, when it leaves Kīlauea.

The gap is real and the app does not pretend otherwise. For roughly seven
hours a night there is genuinely nothing in the United States to look at, so
those hours get a card naming the next window to catch the light and how
long until it does, and a board of the three closest behind it. Both are
drawn from arithmetic alone, so they work even with the network down.

## The eighteen windows

| Window | Where | Local zone |
|---|---|---|
| **Acadia** | Maine | Eastern |
| **Shenandoah** | Virginia | Eastern |
| **Great Smoky Mtns** | Tennessee | Eastern |
| **Mammoth Cave** | Kentucky | Central |
| **Theodore Roosevelt** | North Dakota | Central |
| **Big Bend** | Texas | Central |
| **Glacier Basin** | Rocky Mountain NP, Colorado | Mountain |
| **Yellowstone** | West entrance, Wyoming | Mountain |
| **Grand Canyon** | Yavapai Point, looking northwest | Mountain, no DST |
| **Kolb Studio** | Grand Canyon, north over the Battleship | Mountain, no DST |
| **Glacier** | St Mary, Montana | Mountain |
| **Yosemite** | California | Pacific |
| **Lassen Volcanic** | California | Pacific |
| **Mount Rainier** | Washington | Pacific |
| **North Cascades** | Washington | Pacific |
| **Olympic** | Washington | Pacific |
| **Denali** | Alaska | Alaska |
| **Kīlauea** | Hawaiʻi | Hawaiʻi, no DST |

Most of these are the Park Service's **air-quality cameras**. They exist to
measure visibility, which means every one is pointed at the best view in the
park on purpose, and the whole network answers to a single URL template.
They were missed the first time round: a sweep of park pages only finds the
cameras embedded as plain `<img>` tags, and misses both these and everything
behind `nps.gov/media/webcam/view.htm`. Sixty-one cameras turned out to be
reachable in all; these eighteen are the ones that are both worth looking at
and spread out enough to keep the panel lit.

Acadia at 68W to Kīlauea at 156W is 88 degrees of longitude — close to six
hours — so the stretch when nowhere in the list is lit is about as short as
public American cameras allow.

The time on the picture is the local time **at the camera**, not yours.
Arizona and Hawaiʻi do not keep daylight saving and the app knows it.

## Not every camera tells the truth

A camera can fail in three ways, and not one of them is an HTTP error.

**It can be dead** and serve black. **It can be frozen** and serve
yesterday's sunshine at midnight — Zion and Isle Royale both do this; fetch
twice, fifteen minutes apart, and you get byte-for-byte the same image.
**Or it can serve a flat card that says IMAGE UNAVAILABLE**, which is
bright, plausible and has no landscape in it at all. The Bryce Canyon
camera was doing exactly that when this was written, and a whited-out lens
at Crater Lake came through as a frame with three colours in it.

Of 61 cameras checked, 12 served byte-identical frames seven minutes apart.
The worst offenders are left out of the set — but any camera can fail this
way at any time, and `http.get` hands back no `Last-Modified` to check
against. So every frame is tested on arrival:

- the sun is well up and the frame is nearly black → the camera is down,
- the sun is well past dusk and the frame is sunlit → the frame is stale,
- the frame uses fewer than 8 of its 20 allowed colours → there is no
  landscape in it: a flat card, a white-out, or a lens cap.

That last test is free. The quantiser has already counted the colours, and
a real landscape uses all twenty.

Either way the app moves to the next camera rather than pass it off as live.
If you have pinned a camera and its frame fails, you get `NOT LIVE` rather
than a pretty lie.

## Settings

| Setting | What it does |
|---|---|
| **Which window** | `FOLLOW THE SUN`, or pin one park and stay there, dark or not. |
| **The other window** | The second page. `THE NEXT BEST LIT`, or pin a second park. |
| **Clock** | 12 or 24 hour, for the time shown on the picture. |

The two settings are independent, so you can pin one window and let the
other follow the sun, pin both, or let both roam. Whatever one page is
showing is never offered to the other, so you will not get the same park
twice.

## How a photograph gets onto a panel

`http.get` carries text, not bytes, and `c.image()` only reads files shipped
inside the app — so an image from the internet has no obvious way in. The
way through is [images.weserv.nl](https://images.weserv.nl), which fetches
any public image, crops and resizes it, and re-encodes it as a PNG with
**stored** (uncompressed) deflate blocks returned as base64. With `l=0`
there is nothing to inflate, so the decoder here is forty lines rather than
a zlib implementation. The technique is cfdmb's — [`rain-watch`](../rain-watch)
reads weather radar the same way.

## Where to cut the band

A 16:9 camera cropped to 6:1 keeps under a third of the frame, so *which*
third decides whether the panel is a photograph or a stripe of empty sky. I
compared the options on a daylight frame: a band through the middle of Zion
is a wall-worthy picture, while fitting the whole frame inside 192x32 gives
a 43-pixel postage stamp adrift in black.

weserv applies a manual crop *after* resizing, which would merely clamp a
192-pixel-wide image, but `fit=cover` with `a=crop-50-NN` crops about a
focal point *before* the resize. Every camera carries its own `NN`, set by
eye: 32% at the New River Gorge, where the ridge sits high in frame, down to
56% at Kīlauea, where the horizon is low. Cropping high also keeps the
caption bars that several NPS cameras burn into the bottom of the frame off
the panel.

## Drawing it

192x32 is 6144 pixels, while a page may emit at most 4096 draw ops and no
single bitmap may hold more than 4096 cells. `c.sprite` emits one bitmap per
colour in its legend, so the frame is quantised to at most 80 colours and
laid down in three 64-wide chunks.

The quantiser runs in Starlark, which rules out a nearest-colour search. The
buckets are fixed arithmetic — 32 steps of grey for anything near-neutral,
48 coarse chroma cells for everything else — while each bucket's colour is
the mean of the pixels that landed in it. Fixed buckets, adaptive palette,
one pass. The `overhead` app uses the same quantiser.

A bitmap is a row of `0`/`1` integers in the scene, so each colour on a
192x32 page costs about 15 KB and the app's pages share a 1 MiB budget. How
many of the 80 buckets a photograph reaches depends on the weather, which
would leave the size of the app up to the sky, so a page keeps only its 20
most populous buckets and folds each thinner one into the survivor nearest
it in colour, recomputing that survivor's mean over the pixels it inherits.
On real webcam frames this does not move the RMS error against the original
at all — 9.4 either way, against 31.4 for a uniform 4x4x4 cube — and it caps
the page art at 0.72 MiB however the light falls.

Worth knowing if you are building something similar: `gdn validate` renders
one page at a time, so it never sees the total. Studio builds every page
into one scene and will tell you when they do not fit.

## Data sources

| Source | Cached |
|---|---|
| `nps.gov/featurecontent/ard/webcams` — eleven air-quality cameras | 240s |
| `nps.gov/webcams-*` — four park cameras embedded directly | 240s |
| `cdn.pixelcaster.com` — Kolb Studio, via the Grand Canyon Conservancy | 240s |
| `volcanoes.usgs.gov` — Kīlauea, from the Hawaiian Volcano Observatory | 240s |

`refresh` is 300s. One page makes one call when the first camera answers
with a believable frame, and at most three if it does not. The night pages
make none at all.

## When something is missing

| Screen | Meaning |
|---|---|
| `EVERY WINDOW IS DARK` | the sun is below the horizon at all eighteen, with the next sunrise named |
| `NEXT LIGHT` | the three windows closest to catching the sun |
| `NO PICTURE` | the camera did not answer |
| `NOT LIVE` | a pinned camera's frame does not match where the sun is |

No demo mode. A window that invents a view is not a window.

## Running it

From the repository root:

```bash
gdn studio apps/window
```

Rendering one page:

```bash
gdn render apps/window --page 1 --input "place=GRAND CANYON"
```

To see the no-data screens, set `GDN_HTTP_OFFLINE=1` first.

If `gdn` is not on `PATH`, use `python -m gdn` in its place.

**A note on the preview images.** They show New River Gorge and Longs Peak
in mid-morning light, because they were made in mid-morning light. Render
them again at 02:00 Eastern and they will honestly show the night card and
the sunrise board instead, which is what the panel does at that hour.

Webcam imagery courtesy of the National Park Service and the U.S. Geological
Survey.

Built for the [GLANCE Developer Network](https://github.com/glance-led-dev/glance-dev-network).
