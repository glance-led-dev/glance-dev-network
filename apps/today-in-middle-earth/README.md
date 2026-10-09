# Today in Middle-earth — Glance prototype

This is a **research preview for the 2028 sample rotation**, not the release app.
It deliberately shows “UNDER REVIEW” for 16 selected cards awaiting a direct
source check. It also refuses to run the 2028 arrangement in another year:
same-week placements must be regenerated when the weekday pattern changes.

`app.star` is generated from `arda_daily_content.json` by an external build
script (kept outside this folder, since apps ship app.star only). The generator
preserves a dated card's actual source day, converts diacritics for Glance's
uppercase bitmap font, and chooses one of three story type sizes. It refuses
text that will not fit the smallest four-line setting.

`concept_preview.png` is a visual design mockup, not an image from the Glance
renderer. Its typeface and glyph widths are approximate.

In the official [Glance Developer Network](https://glance-led.dev/docs/getting-started/quickstart/),
place this folder at `apps/today-in-middle-earth/`. Then run:

```sh
gdn validate apps/today-in-middle-earth
gdn studio apps/today-in-middle-earth
```

Use Studio's time-travel control to inspect 29 February, 15 March, 21 June,
28 December, and one of the 16 held dates (for example 14 May) in 2028. Check
both pages at native resolution and adjust copy against GDN's actual font
metrics. The concept image cannot establish that the panel has no clipping.

The app chooses the day in America/New_York, including DST. The source year is
the Arda event's year; 2028 is only the civil-year rotation used for testing.
Next: finish the 16 card decisions and reschedule their replacements globally
without reusing a story; regenerate a unique schedule for the launch year;
validate and render with GDN; then remove the research-only year guard.
