# Google Calendar

Your next meeting, today's agenda, and the week ahead — on a Glance panel.

Ships as the usual pair: **`google-calendar`** (64x32, LED V2) and
**`google-calendar-scroll`** (192x32, SCROLL). Same `app.star`, different width.

| page | what it answers |
|---|---|
| `next` | What's next, and how long have I got? |
| `today` | What's left today? |
| `week` | How busy is the week? |

## Setting it up

The app reads your calendar's **secret iCal address**. No OAuth, no API key, and
it works for private calendars — which the Google Calendar API's key-only access
does not.

1. Open Google Calendar on the web → **Settings** (gear icon) → pick your
   calendar in the left sidebar → **Integrate calendar**.
2. Find **Secret address in iCal format**. It looks like:

   ```
   https://calendar.google.com/calendar/ical/you%40gmail.com/private-1a2b3c4d5e6f/basic.ics
                                            └──── Calendar ID ────┘ └─ Secret key ─┘
   ```

3. Paste the two halves into the app's settings:
   - **Calendar ID** — `you@gmail.com`, or `c_9f2b...@group.calendar.google.com`
     for a secondary calendar. The `%40` is just an encoded `@`; either form works.
   - **Secret key** — `1a2b3c4d5e6f`, with or without the `private-` prefix.
     Declared as an `api-key` input, so it is masked in the Studio and handled
     as a credential rather than a plain setting.

   Leave **Secret key** blank if the calendar is public.

> **Do not paste the whole `https://` link into one field.** Settings ride a
> colon-separated render descriptor, so a URL arrives at the app as the word
> `https` and nothing else. That is why the address is split in two here.

Anyone with the secret address can read your calendar, so treat it like a
password. Google can rotate it for you (**Reset** next to the secret address).

The Calendar ID is deliberately *not* an `api-key` field — it is usually just
your email address, and masking it would only make setup harder to check. The
token is the half that is actually secret.

**UTC offset** only matters for events your calendar stores in UTC. Events that
carry their own time zone are shown exactly as written, which stays correct
across a daylight-saving change — so most calendars never need this touched.

Out of the box the Calendar ID is `DEMO`, which shows a built-in sample week so
the app has something to show before you configure it. Replace it with your own.

## What it understands

The iCal feed is a raw export, not the tidy list the Calendar API returns, so
the app does the expansion itself:

- **Repeating events** — `RRULE` with `DAILY` / `WEEKLY` / `MONTHLY` / `YEARLY`,
  `INTERVAL`, `BYDAY` (including ordinals like "2nd Tuesday" and "last Friday"),
  `BYMONTHDAY`, `BYMONTH`, `COUNT` and `UNTIL`.
- **Exceptions** — a deleted occurrence (`EXDATE`) disappears; a moved or edited
  one (`RECURRENCE-ID`) replaces the instance it names rather than doubling it.
- **Cancelled** events are dropped.
- **All-day events** get their own treatment everywhere instead of pretending to
  be a 24-hour meeting.
- Times arrive in three different shapes (`VALUE=DATE`, a zoned wall clock, and
  real UTC) and only the last one is converted.

Rules are matched one candidate day at a time rather than by generating a series
from its first occurrence — a standup that started in 2019 is one arithmetic
check, not four thousand steps.

## Known limits

- **Event colours are not in the feed.** Google's `basic.ics` carries no
  `colorId`, so each event's colour is derived from a hash of its UID. It is
  stable per event and consistent across all three pages, but it will not match
  what you see on calendar.google.com. Nothing read from this feed can.
- **One calendar per app instance.** Add the app twice for two calendars.
- Very large exports are truncated at 2 MB by the runtime; a calendar that big
  will show the events it managed to parse.
- The `week` page plots 8am–11pm. Anything earlier or later is clamped to the
  ends of the strip.
