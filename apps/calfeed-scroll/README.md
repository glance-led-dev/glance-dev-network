# Calfeed Agenda

Shows your next calendar event from a [calfeed](https://calfeed.io) feed:
merged calendars from Google, Microsoft, Apple or pushed dumps, sliced
into a view, served at one private URL. The panel never signs in
anywhere; the feed id is the whole configuration.

## Inputs

- **Label** — shown on every page. Blank uses the view's name. Two
  instances of the app, one per person's view, each labelled with a
  name, keep two calendars apart on one panel.
- **Label color** — the label's colour; give each instance its own.
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

## Pages

- **NOW** — the event that matters right now: the one in progress that
  started last, else the next one to start. All-day events appear only
  when nothing timed is left.
- **NEXT** — what follows it.

The time is the hero and wears the event's phase: white far off, amber
within 15 minutes, green while running (with its elapsed share drawn
along the bottom edge), sky blue for all-day.

Times come from the feed already rendered in the view's timezone; the
app does no date maths.
