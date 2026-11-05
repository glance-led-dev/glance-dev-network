# Calfeed Agenda

Shows your next calendar event from a [calfeed](https://calfeed.io) feed:
merged calendars from Google, Microsoft, Apple or pushed dumps, sliced
into a view, served at one private URL. The panel never signs in
anywhere; the feed id is the whole configuration.

## Inputs

- **Label** — shown on every page. Blank uses the view's name. Two
  instances of the app, one per person's view, each labelled with a
  name, keep two calendars apart on one panel.
- **Label color** — the label's colour, picked from the named palette; give each instance its own.
- **Far-off color**, **Soon color**, **Running color**, **All-day
  color** — the four phase colours, each picked from the same palette.
  The chosen colour dresses the left rail, the state word, the hero time
  and the calendar glyph, so the panel says which phase the event is in
  before you read a word of it:
  - *Far-off* (white) — the event starts more than 15 minutes from now.
  - *Soon* (amber) — it starts within 15 minutes.
  - *Running* (green) — it is in progress; this colour also paints the
    elapsed bar along the bottom edge.
  - *All-day* (sky blue) — it is an all-day event.

  Defaults are the four above. OFFLINE and ALL CLEAR keep amber and
  green whatever you pick — those are the app's own states, not an
  event's phase.
- **Feed ID** — in the calfeed console, open the view you want on the
  panel (a "next 24 hours, max 3 events" view works well), click
  *Create feed URL*, copy it. The URL looks like
  `https://calfeed.io/v1/feed/4f9c2a1e8b7d6c5a4f9c2a1e8b7d6c5a`; the
  hex part after `/v1/feed/` is the feed id. **Paste only the id — the
  app builds the URL.** Glance separates an app's settings with colons,
  so a value containing one (a whole `https://...` URL included) reaches
  the app cut short at the colon, which is why the app asks for the id
  alone. It is still a secret: anyone holding it sees that view. Rotate
  it in the console if it leaks. Leave blank to see demo data (labelled
  DEMO on the panel).
- **Feed header** (optional) — only if you added a required header to
  the feed's *restrictions* in the console. Enter it as `Name=value`,
  e.g. `X-Feed-Key=secret123`. It must contain no colon, for the same
  reason as above.

## The source badge

If a calendar in your calfeed view has a short name, the feed sends it
with every event and the panel draws it on the top row, between the
label and the state word — `WORK  CFS  50M` — so you can see which
calendar the event came from. With the view's *use source colours*
option on, the badge wears that calendar's own colour; otherwise it
takes the label's.

The badge is the first thing dropped when the row is full: a long label
beside a long state word (`CANDELA` next to `12M LEFT`) fills the row's
58 pixels on its own, and the badge goes rather than eating characters
off the name. On 64x32 expect it whenever the state word is short; on wider
panels it is almost always there.

The view's *tag titles* option prefixes every title with the same short
name (`[CFS] DESIGN REVIEW`), which costs room in the title line. With
the badge doing that job on the top row, you can turn *tag titles* off.

## Pages

- **NOW** — the event that matters right now: the one in progress that
  started last, else the next one to start. All-day events appear only
  when nothing timed is left.
- **NEXT** — what follows it.

The time is the hero and wears the event's phase: by default white far
off, amber within 15 minutes, green while running (with its elapsed
share drawn along the bottom edge), sky blue for all-day — each one a
dropdown above.

Times come from the feed already rendered in the view's timezone; the
app does no date maths.
