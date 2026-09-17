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

- **Next** - the next event: what it is, when, where, and how far off. The
  chip names the kind of event and the whole panel takes its colour from
  it, so music and sport are distinguishable at a glance. A second chip
  appears only when the event is not simply on sale, so a rescheduled or
  cancelled date announces itself.
- **Upcoming** - the four events after that, each with its date, its time
  and its name, with the date in the same colour its kind carries on the
  first page.

## What it does and does not cover

Ticketmaster lists **ticketed** events. That is concerts, sports, comedy,
theatre, family shows and film events. It is not a community calendar, so
informal things - run clubs, meetups, anything without a ticket - are not
in this data and will not appear here.

`OTHER` is worth a look anyway: Ticketmaster files a lot of one-off local
events under its miscellaneous segment.

## Notes

- One request per render, cached for half an hour, and the panel refreshes
  every 30 minutes.
- **The radius alone does not bound the search.** A Tampa ZIP code at 25
  miles returns an event in Bielefeld, Germany unless the country is
  pinned too, so the request pins it to the US. A non-US postcode will
  therefore find nothing.
- The search window starts at midnight so the request stays cacheable
  through the day. Events that already started today are dropped against
  the panel clock instead, so nothing that has been and gone is shown.
- Prices and distances are left out on purpose. Ticketmaster returns them
  on some listings and not others, and a price shown for one event in ten
  reads as though the other nine were free.
- Long names lose their tour subtitle before anything else, so
  `ZAC BROWN BAND: LOVE & FEAR TOUR` shows as `ZAC BROWN BAND`.
- `N NEARBY` is Ticketmaster's own count of everything matching the
  search, not just the handful listed on the panel.
