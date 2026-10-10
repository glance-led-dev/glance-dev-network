# SportBoards

Recent results, today's events, and upcoming events for a high school that
subscribes to SportBoards.

The school's schedule and results come from the SportBoards service, which
collects them from the systems the athletic department already uses. Nothing
has to be entered on the display.

## How the feed works

SportBoards plays one **programmed feed** of up to 16 pages. Community apps
are limited to 8 pages, so Glance shows it in two 8-page **blocks**:
Block A is feed pages 1–8, Block B is pages 9–16. Each appearance shows one
block. A day that fits in 8 pages uses Block A only.

| page type | width | what it shows |
|---|---|---|
| Event cards | two per page | Sport icon, event, opponent logo, and a `FINAL` / `TODAY` / `UPCOMING` chip |
| Schedule change | full | A priority announcement, for example a postponement |
| Sponsor | full | A school sponsor's logo, with its name set beside it when the logo's own lettering is too small to read |
| Featured | full | The featured event: school logo vs. opponent, the occasion, the time, and a ticket QR when one is available |

**What gets in**, most important first:

1. Priority announcements (up to two pages).
2. Every one of today's events.
3. The four most recent **varsity** results. Each schedule-change page takes
   the place of two of them.
4. Upcoming events, earliest first.
5. Remaining results, most recent first.

When there is more than 16 pages of content, the list is cut from the bottom.

**Where it goes:** schedule changes open the feed. Today's events and the
lead results then alternate in pairs, followed by upcoming events and older
results. Sponsors take pages 3 and 6 of each block, and the featured event
takes page 8 of each block. These pages are reserved only when the content
exists. Otherwise athletics fill them, so a page is never left blank.

Each sponsor appears at most once per block. With one sponsor it takes page 3
of each block; with two or more, both sponsor pages are used. Which sponsors
appear moves on with every refresh, so every sponsor on the list gets its turn.
A sponsor whose logo is bundled with the app shows that logo; one without
shows its name as text. The featured event is the first upcoming event (today counts) that
the athletic department marked as featured. It is not repeated as a normal
card. If a block runs out of new content, it shows the school's name page
once, then repeats events from the top of the feed.

**Which block shows:** every page of one appearance reads the same cached
schedule response (cached 45 seconds, with a 60-second refresh), so all
eight pages always agree. The block is chosen from that response's timestamp,
so each fresh render is effectively a coin flip between A and B. It can never
lock out Block B, but it does not strictly alternate. Strict
A → B → A → B needs a block number from the SportBoards service. Only
`select_block()` in `app.star` would change.

Cards carry the school through its colors: the sport icons keep the sport's
own colors with the school's colors as accents, and cards are separated by a
stripe in the school's primary color (color | white | white | color). The
school logo appears on the featured page rather than on every card.

## Demo

Until an access code is entered, the app plays a demo: a sample school with
sample games, marked DEMO on every page. Nothing in the demo is live, and it
makes no connection to SportBoards.

## Setting it up

1. Your athletic department receives a **SportBoards access code** when it
   subscribes. It is letters and numbers only.
2. Paste the code into **SportBoards access code**.
3. That's it. The code decides which school the board shows. There is no
   school to pick.

If the code is lost, revoked, or not working, contact SportBoards for a new
one. Each school's code is private to that school.

## Settings

| setting | what it is |
|---|---|
| **SportBoards access code** *(credential)* | The code SportBoards gave your athletic department. Required. |

## What the board shows

| on the panel | meaning |
|---|---|
| `SPORTBOARDS DEMO` and `DEMO` down the left edge | No access code entered yet; the board is showing sample data. |
| `ACCESS CODE NOT RECOGNIZED` | The code is wrong, expired, or revoked. |
| `SUBSCRIPTION INACTIVE` | The school's SportBoards subscription is not active. |
| `SCHEDULE UNAVAILABLE` | SportBoards could not be reached. The board tries again on its next refresh. |
| `SCHEDULE DATA ERROR` | SportBoards answered with data the board could not read. |
| `NO EVENTS TO SHOW` | Everything is working. There are no recent finals, events today, or upcoming events. |
| School name and logo | A block had more pages than new content. |

## What the SportBoards service will need to add

- **Schedule-change type:** urgency comes from an announcement's priority
  flag. The header reads `SCHEDULE CHANGE`, `CANCELLED`, `POSTPONED`,
  `TIME CHANGE` or `LOCATION CHANGE` when `announcement_type` is one of the
  agreed values (`schedule_change`, `cancellation`, `postponement`,
  `time_change`, `venue_change`), and `ALERT` otherwise. Those values need to
  be standardized in the service.
- **Ticket QR:** GDN cannot generate QR codes, and the service has no
  per-event ticket link. The featured page draws a QR from an event's
  `ticket_qr.modules` (a square grid of 21–29 rows of `0`/`1`), with an
  optional `ticket_qr.label`.
- **Strict block alternation:** a block number from the service would
  replace the timestamp coin flip.
- **Sponsor logos:** sponsor logos are remote images, which GDN cannot draw,
  so sponsor pages are text only.
