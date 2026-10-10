# WWE What's Next

Upcoming RAW, SmackDown, and NXT cards on a native **192×32** SCROLL panel.
Overview, announced matches, and optional previous-show results — still frames,
no portraits, no animation.

![WWE What's Next preview](preview/preview.png)

The overview is the event plate: brand, city, time, match count, and the next
Premium Live Event on a gold bar. Match pages put names in the hero slot.
Championship bouts reuse the WWE Champions 72×32 belt art.

If the pinned weekly show has no posted lineup yet, overview still shows the
next Premium Live Event — name, day, start time, and city — instead of
CARD UNAVAILABLE. Match pages stay empty until a card is announced. The PLE
title picks the largest font that fits and leaves a gap before the date chip.

## Settings

| Input | What it does |
|------|----------------|
| **Show** | `AUTO` picks the earliest dated future card. Pin `RAW`, `SMACKDOWN`, or `NXT`. |
| **Show Previous Results** | `ON` adds pages for the last completed show of that brand: main event plus title matches. |

## Pages

1. **Overview** — brand, date, city, start time, next PLE.
2. **Card 1–4** — announced matches, title bouts with belts, packed “to speak” segments.
3. **Results 1–3** — previous main event and championships, when Results is on.

Empty and missing cards show **CARD UNAVAILABLE**. Invalid settings show
**CHECK SETTINGS**.

## Data

Live lineups come from dated Fightful and F4W RSS posts. City and the next PLE
are filled from WWE.com events when the card omits them. Weekly TV without a
listed time is shown as **8PM ET**. Coverage follows what those feeds publish,
not a complete WWE calendar.

Refresh is 30 minutes. HTTP cache is 900 seconds. No API key.

## Art

The overview, empty and error screens show a pixel-art ring tinted with the
brand. Match pages carry a 2x sprite for the match type (face-off, tag team,
triple threat, ladder, steel cage, Money in the Bank case, mic for promos), and
results without a belt show the winner with arms raised.

Catalog previews use a fixed demo card: set `PREVIEW_DEMO = True` in
`app.star`, regenerate the previews, then set it back to `False`.
