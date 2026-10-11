##NCAA College Basketball Rivalry Tracker – Glance

Display head-to-head series records over the last seven seasons, AP rankings, last game results, active winning streaks, and upcoming matchup dates for any two Division I men's college basketball teams on a wide LED panel.

Version 1.0 · App ID: ncaam-rivalry-tracker
By SlaterDen

#App Settings
Setting	Required	Description
Team 1	Yes	First school, picked from a dropdown of all D1 teams (default: Duke)
Team 2	Yes	Second school, picked from the same dropdown (default: North Carolina)
Team Name Length	Yes	Abbreviations (e.g. DUKE, UNC) or Full Name (long names are clipped to fit the team chip)
No API key is needed: all data comes from ESPN's public scoreboard API.

#Screens & Layout

The app is a single page (main) designed for a 192×32 panel, with a 10 px safe zone on each side.

Screen	What's shown
Series view	Team chips in team colors at the top corners with the rivalry name centered between them. Below, each team's win total over the last seven seasons in large digits flanks a split-color progress bar. AP rank (#4) and active win streak (W3) sit beside each team's total. A white tick above the bar marks the midpoint, so you can see who leads at a glance.
First meeting	Shown when no games between the two teams are found. Displays FIRST MEETING with any rankings and the next scheduled date.
#Bottom Row
LAST: Most recent result, winner listed first (e.g. DUKE 74-71).
SINCE: Earliest season in the data the series is counted from (e.g. SINCE 2020). It is hidden when there isn't room.
NEXT: Date of the next scheduled game, LIVE if a game is in progress, or TBD.
#Rivalry Names

Matchups with a known rivalry show its name in gold, for example Tobacco Road (Duke–UNC), Bedlam (Oklahoma–Oklahoma State), Red River Rivalry (Oklahoma–Texas), and The Holy War (BYU–Utah). Other pairs show SERIES. Long names fall back to shorter versions when they don't fit between the team chips.

#Data Sources
Source	Used for
ESPN (site.api.espn.com)	Team schedules (used to tally the series), next game, and AP rankings. Team abbreviations and colors are built into the app from ESPN's team list.

The series record is calculated by the app from Team 1's schedule for the current season and the six before it. ESPN serves one season per request and an app may make eight requests per render, so seven seasons is the window. Regular-season and conference-tournament games count; NCAA tournament and other postseason games are not included. The SINCE label shows how far back the count goes.

Rankings show only from November through April. In the offseason they are hidden so last season's final poll isn't mistaken for a current one.

This app is not affiliated with the NCAA or ESPN. All sports data remains the property of its respective providers.

#Errors & Troubleshooting
What you see	Likely cause	What to try
PICK TWO DIFFERENT TEAMS	Team 1 and Team 2 are the same	Choose two different schools
TEAM NOT RECOGNIZED	A saved school is no longer in the dropdown	Pick both teams again
ESPN UNAVAILABLE	Network issue or ESPN outage	Try again later
FIRST MEETING	No games between the teams in the available data	Normal for teams that haven't played, or for series older than the data coverage
#Notes
Panel: designed for 192×32 wide LED panels.
Refresh: once a day. The current and previous seasons are cached for 24 hours, older seasons for a week, and rankings for 6 hours, so new results appear the next day.
Dates are shifted from UTC to approximate US time so evening tip-offs show the correct day.
Credits

SlaterDen · Built for the Glance Developer Network.