# Events Near Me

What is on around your ZIP code: the next ticketed event with its date,
time and venue, then the ones after it. Concerts, games, comedy and
theatre, from Ticketmaster.

## Settings

| setting | what it is |
|---|---|
| **ZIP code** | The US ZIP code to search around. |
| **Event type** | `ALL`, or one kind: music, sports, arts and theatre, film, or `OTHER`, which is Ticketmaster's own miscellaneous bucket. |
| **Search radius** | 10, 25, 50 or 100 miles from that ZIP code. |
| **How far ahead** | The next 7, 30 or 90 days, or `ANYTIME`. A short window tells you what is on this week; `ANYTIME` reaches months out, because arena shows go on sale early. |
| **Ticketmaster API key** | Your own free Discovery key. |

## Getting a key

There is no shared demo key for this API, so the panel needs one of your
own. It is free and immediate: register at
<https://developer-acct.ticketmaster.com/user/register>, create an app,
and copy the Consumer Key. Until a key is set the panel shows a setup
screen rather than pretending to have data.

## The pages

The panel is drawn as a ticket on a black ground. A stub on the left
carries a 16 px picture of the kind of event, lit in its colour with white
highlights (a pair of notes, a trophy, comedy and tragedy masks, a strip of
film, or a ticket for anything else), with a perforated tear line down its
edge; the body to the right carries the words. Nothing is filled solid:
lit strokes on black read across a room where holes in a bright block do
not.

- **Next** - the next event. The stub shows the picture and the date as a
  calendar leaf (month over a big day number); the body has the kind of
  event as a chip, the city, the event name as the hero, its start time,
  venue, and how far off it is (TONIGHT, TOMORROW, THIS FRI, IN 2 WEEKS).
  A second chip appears only when the event is not simply on sale, so a
  rescheduled or cancelled date announces itself.
- **Upcoming** - the three events after that, each with its date, its name
  and its time, with the date in the same colour its kind carries on the
  first page. The stub shows a ticket, Ticketmaster's count of everything
  matching the search, and the ZIP code it was searched around.

## What it does and does not cover

Ticketmaster lists **ticketed** events. That is concerts, sports, comedy,
theatre, family shows and film events. It is not a community calendar, so
informal things - run clubs, meetups, anything without a ticket - are not
in this data and will not appear here.

`OTHER` is worth a look anyway: Ticketmaster files a lot of one-off local
events under its miscellaneous segment.

## Notes

- Two requests per render: the ZIP code is geocoded at zippopotam.us
  (cached for a day), then Ticketmaster is asked for events around that
  point (cached for half an hour). The panel refreshes every 30 minutes.
- **Why the ZIP is geocoded first.** Ticketmaster's own `postalCode`
  filter is an exact match on the venue's postcode, in any country, and
  the radius does nothing beside it: a Tampa 33602 search returned an
  event in Bielefeld, Germany (postcode 33602), and 90210 at 100 miles
  returned one event where a point search returns thousands. Searching
  by the ZIP's coordinates makes the radius setting mean what it says.
  The country is still pinned to the US, and a ZIP that zippopotam does
  not know shows a `ZIP NOT FOUND` setup screen.
- The search window starts at midnight so the request stays cacheable
  through the day. Events that already started today are dropped against
  the panel clock instead, so nothing that has been and gone is shown.
- Prices and distances are left out on purpose. Ticketmaster returns them
  on some listings and not others, and a price shown for one event in ten
  reads as though the other nine were free.
- Long names lose their tour subtitle before anything else, so
  `ZAC BROWN BAND: LOVE & FEAR TOUR` shows as `ZAC BROWN BAND`.
- The count in the tile on the Upcoming page is Ticketmaster's own count
  of everything matching the search, not just the handful listed on the
  panel.
