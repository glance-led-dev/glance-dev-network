# High School Sports

Displays one high school's current sports matchup on a 192x32 Glance display. The single scroll page automatically changes between the next game, a live game, and the most recent final.

## Setup

1. **Choose a sport.** Select Football, Boys Basketball, Girls Basketball, Baseball, Softball, Girls Volleyball, Boys Soccer, or Girls Soccer.
2. **Add the MaxPreps school URL.** Open the school's main MaxPreps page and copy its URL. Use a URL like `https://www.maxpreps.com/nc/charlotte/myers-park-mustangs/`. Do not use a sport schedule, matchup, recap, or individual game URL.
3. **Add Parse.** Create an account at [parse.bot](https://parse.bot), add the public `maxpreps.com API`, and copy your personal API key into the encrypted **Parse API key** setting. The app does not include, share, or fall back to someone else's key.
4. **Choose the display time zone.** The school timezone is detected automatically from its MaxPreps location. Display time zone controls the time shown on your Glance.
5. **Choose a live frequency.** The default is every 30 minutes. Select **No live pulls** when you only want upcoming and final results, or select a faster interval while actively following a game.
6. **Optional for baseball and softball:** enter the short GameChanger team ID to supplement live information without using Parse credits. MaxPreps and Parse are still required for the complete schedule, matchup, branding, and fallback data.

## What the display shows

- **Next:** opponent, records, scheduled date and time, and available season averages.
- **Live:** current score and the sport-specific period, set, half, inning, clock, bases, or outs when the source provides them.
- **Final:** final score and the available quarter, half, set, or line-score breakdown.
- Football remains on its latest final until Tuesday at 8:00 AM in the selected school's local time, when it changes to the next matchup.
- When usable live data is temporarily unavailable, the display retains the matchup and shows the most recent check time instead of presenting stale information as current.

## Display abbreviations and statuses

### Sports

- **FB:** football
- **MBB / WBB:** boys / girls basketball
- **BSBL / SFTB:** baseball / softball
- **VB:** girls volleyball
- **MSOC / WSOC:** boys / girls soccer

### Next-game statistics

- **PPG:** average points scored per game
- **PAPG:** average points allowed per game
- **RPG:** average runs scored per game
- **RAPG:** average runs allowed per game
- **GPG:** average goals scored per game
- **GAPG:** average goals allowed per game
- **SW / SL:** total volleyball sets won / lost
- **STRK:** current winning or losing streak; for example, `W3` or `L2`
- A green statistic is the more favorable value in that matchup: higher offense, lower defense allowed, or the better current streak.
- Team records use wins-losses, with a tie added when the source supplies one.

### Game statuses

- **Green LIVE:** the source returned usable current live-game data, such as a score or period.
- **White LIVE:** the game appears to be underway, but the latest check did not return usable live score details. The displayed score must not be treated as current.
- **UPDATED + time:** the most recent source/check time, converted to the selected display time zone. It appears when a game is marked live but usable live details are unavailable; it is not the game clock.
- **1Q–4Q:** football or basketball quarter; **HT** means halftime.
- **1H / 2H:** soccer half. **SET 1–SET 5** identifies the current volleyball set.
- **OT1, OT2, ...:** current overtime period.
- **PP:** postponed. **DELAY:** delayed or suspended. **FF:** forfeit.
- **FINAL:** completed game. **F OT, F OT2, ...:** completed in overtime.
- **F8, F9, ...:** baseball or softball final completed after the regulation seventh inning.
- Before a game, the right side of the header shows its scheduled local start time.

For live baseball and softball, the diamond shows occupied bases in the batting team's color. The arrow and inning number show the top or bottom of the inning, and the two indicators beneath it show the number of outs.

## Data and credits

- MaxPreps supplies schedules, matchups, records, scores, and available box-score details.
- For baseball and softball, an optional GameChanger Team ID lets the app use GameChanger's public feed for available live details. If the ID is blank, invalid, or temporarily unavailable, the normal MaxPreps path continues.
- GameChanger availability varies by game. Its public feed may provide only team names and scores; inning, outs, occupied bases, hits, and errors appear only when the source supplies them.
- The app uses MaxPreps Scoretracker as its only football live-score source.
- Each successful live Scoretracker request currently costs one Parse credit. The frequency selector shows the corresponding hourly rate.
- The default 30-minute frequency uses at most two live Scoretracker credits per hour.
- **No live pulls** uses zero in-game Scoretracker credits. Schedule, matchup, upcoming-game, and final-result updates continue normally; one completed-game request may still retrieve the final quarter breakdown.
- At Tuesday's 8:00 AM football rollover, the app refreshes both teams' schedules: two credits for the selected school and two for its opponent. The opponent schedule supplies the opposing streak when available.
- On a football game day, one `get_live_and_upcoming_games` request after 8:00 AM local confirms that the Tuesday matchup is still correct. It costs one credit and is cached for the entire date.
- The matchup request normally costs one additional credit. Football Scoretracker then costs one credit per selected live update after the game starts.
- Successful schedule and matchup responses are cached. Reopening the same matchup should not repeat those charges.
- Football schedule refreshes are limited to the Tuesday 8:00 AM local rollover. The game-day confirmation avoids another full schedule request if the matchup changed after Tuesday.
- Only Scoretracker repeats during a football game, at the frequency selected in settings.
- The app pauses sport-specific schedule calls during that sport's offseason.

Parse pricing and endpoint costs can change; check the usage page in your own Parse account.

## Common messages

- **KEY ERROR:** the Parse key is missing, invalid, or connected to the wrong Parse account/API.
- **URL ERROR:** the MaxPreps URL is not a valid main school page.
- **FEED ERROR:** the source could not be reached. The app waits briefly before retrying so repeated previews do not create a request burst.
- **NO GAME / NO UPCOMING:** MaxPreps does not currently list a usable matchup for the selected sport.
- **OFFSEASON:** the selected sport is outside its configured season and automatic pulls are paused.

## Updating settings

The school timezone is detected automatically from its MaxPreps location. You can change the sport, school URL, display timezone, or live frequency without deleting and re-adding the app. Select **No live pulls** for upcoming and final results without recurring in-game checks, or use a faster frequency only when you want closer live updates.
