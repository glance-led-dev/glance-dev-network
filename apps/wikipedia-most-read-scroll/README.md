# Wikipedia Most Read

The five most-read Wikipedia articles of the day, with how many people
read them. No key or account needed.

## Settings

| setting | what it is |
|---|---|
| **Wikipedia edition** | Which language Wikipedia to read. Each edition has its own list, so the Spanish or Japanese one shows what those readers looked up, not a translation of the English list. |

## The pages

- **Article** - one entry at a time, rotating every minute: its rank on a
  pale tile, the title as large as it will fit, and the view count.
- **Top five** - the whole list at once, each title on a bar scaled to the
  day's leader, so you can see whether one story ran away with the day.

## Notes

- Source: Wikimedia's public feed API, the `featured` endpoint for the
  chosen language.
- **The list is always for a finished day.** A day has to end before its
  views can be counted, so the feed returns yesterday. The panel prints
  the date the feed itself reports rather than assuming one.
- The Main Page is filtered out. It is the most-visited page on Wikipedia
  every single day and would crowd out the actual stories.
- View counts are real page views for that day, not estimates.
