# Sleeper Matchup

Your live Sleeper fantasy football matchup on a 64x32 panel: your username and
score on the left, your opponent's on the right. Uses Sleeper's free public API,
so no key is needed.

## Settings

- **Sleeper username**: your username exactly as it appears on your Sleeper
  profile (without the @). Leave it blank to see a demo screen.
- **League name or ID**: any part of your league's name (for example
  `DYNASTY`) or the league ID from the Sleeper web address
  (`sleeper.com/leagues/<league ID>/...`). Leave it blank to use your first
  league this season.

## What it shows

- Top: both managers' usernames. Long names are shortened to fit.
- Middle: both scores to one decimal. Your score is green when you lead, red
  when you trail, white when tied.
- Bottom: the week, and the margin (`+26.2`, `-4.5` or `TIED`).

The panel refreshes every 5 minutes. On a bye week, in the offseason, or if
Sleeper can't be reached, it says so in plain words instead of showing old
numbers.
