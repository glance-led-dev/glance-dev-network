# Wikipedia Most Read

The five most-read Wikipedia articles of the day, with how many people
read them. No key or account needed.

## Settings

| setting | what it is |
|---|---|
| **Wikipedia edition** | Which language Wikipedia to read. Each edition has its own list, so the Spanish or Japanese one shows what those readers looked up, not a translation of the English list. |

## The pages

- **Article** - one entry at a time, rotating every minute: its rank on a
  podium tile (gold, silver, bronze, then grey), the title as large as it
  will fit, and under it an eye with the view count, an arrow with the
  change since the day before, and five small bars for the last five days
  of views - so a story that exploded overnight looks different from one
  that has been building all week.
- **Top four** - the list at once, each title on a bar scaled to the day's
  leader with the same podium colors and trend arrows, so you can see
  whether one story ran away with the day. The fifth is counted in the
  header.

## Notes

- Source: Wikimedia's public feed API, the `featured` endpoint for the
  chosen language.
- **The list is always for a finished day.** A day has to end before its
  views can be counted, so the feed returns yesterday. The panel prints
  the date the feed itself reports rather than assuming one.
- The Main Page is filtered out. It is the most-visited page on Wikipedia
  every single day and would crowd out the actual stories.
- View counts are real page views for that day, not estimates.
