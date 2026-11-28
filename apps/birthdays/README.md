# Upcoming Birthdays

A Glance LED app that shows the next few birthdays on a living-room panel:
first name, date as MM/DD, and the age that person is turning. A **TODAY!**
badge highlights a birthday happening today, and both pages count down to
the next one.

Nothing about a real household is stored in these files. The panel reads only
what you type into the app's setup form.

## Inputs

- **Birthday list** — one person per line, or separated by semicolons:

      Alex,12/03,1996
      Sam,01/15,2018

  or on one line: `Alex,12/03,1996; Sam,01/15,2018`

  Use a first name only, then the date, then the birth year. Do not use
  colons: Glance cuts input values at a colon, so a full `https://` URL
  or `Name: date` line will not arrive intact.

  Leave the list blank to see the built-in demo names (the panel is labelled
  DEMO).

- **Time zone** — defaults to America/New_York. This is how the app decides
  what "today" is. Daylight saving is applied automatically for US zones.
  America/Chicago and other US zones are in the dropdown.

- **Names on the list page** — 3 or 4 fit this 32-pixel panel. 3 uses a larger
  font that is easier to read across a room; 4 is the default. A 5th name is
  counted as +N in the header. The next page always focuses on the soonest
  birthday.

## Pages

- **next** — the soonest birthday, large enough to read across the room.
- **soon** — the upcoming list, with a TODAY! highlight and a short countdown.

## What this app does not do

It does not connect to Google Calendar, and it does not fetch a secret iCal
address. A typed list keeps last names, notes, and other calendar events off
the panel and off Glance's servers.

This copy has not been published to the Glance community repo.
