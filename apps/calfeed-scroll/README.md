# Calfeed Agenda

Shows your next calendar event from a [calfeed](https://calfeed.io) feed:
merged calendars from Google, Microsoft, Apple or pushed dumps, sliced
into a view, served at one private URL. The panel never signs in
anywhere; the URL is the whole configuration.

## Inputs

- **Label** — shown on every page. Blank uses the view's name. Two
  instances of the app, one per person's view, each labelled with a
  name, keep two calendars apart on one panel.
- **Label color** — the label's colour; give each instance its own.
- **Feed URL** — in the calfeed console, open the view you want on the
  panel (a "next 24 hours, max 3 events" view works well), click
  *Create feed URL*, copy it. It is a secret: anyone holding it sees
  that view. Rotate it in the console if it leaks. Leave blank to see
  demo data (labelled DEMO on the panel).
- **Feed header** (optional) — only if you added a required header to
  the feed's *restrictions* in the console. Enter it as `Name=value`,
  e.g. `X-Feed-Key=secret123`.

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
