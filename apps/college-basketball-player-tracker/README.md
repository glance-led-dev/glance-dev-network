# Team Boxscore Tracker (NCAA)

Eight 128×32 player cards for a selected men's Division I basketball team. During games, the rotation includes the five starters and three highest-scoring bench players, sorted by points. Between games it shows the eight highest season averages.

## Display

School-colored backgrounds, editable jerseys with centered numbers and white collars, team logos, and a prominent points column. Position, height and class use the larger 4x5 font; the height mark is stacked vertically with one-pixel gaps to the digits. Player surnames take priority over optional biography details. Initials distinguish duplicate surnames, and exceptionally long names shorten with a final period rather than overflowing.

Live scores sit beneath REB/AST/STL/BLK. Status labels include 1H, 2H, HT, OT, OT2 and subsequent overtime numbers. Regulation finals show FINAL; overtime finals show FINAL OT, FINAL OT2, etc., with a visible separator. The halftime scoreboard sits four pixels before HT. Opponent rankings are not displayed or fetched.

PTS, REB, AST, STL and BLK use 4x5 labels in every display state. Each number is centered beneath its label. Supporting season averages are drawn once as complete outlined values, preserving the decimal gaps; wider values use the smaller fallback font. Points retain their original font ladder and full-size decimal.

Long scoreboards stay on one line without shortening team codes. The PTS label and number move left only when the measured score row needs room. If the jersey boundary prevents a full-height horizontal fit, a compact number sits above the footer with a blank row separating it from both its label and the scoreboard. Ordinary score rows keep their approved positions.

## Illustrative previews

These are layout examples with demonstration statistics, not current game results.

![Season averages](preview/stojakovic-average.png)
![Live](preview/stojakovic-live.png)
![Regulation final](preview/stojakovic-final.png)
![Overtime final](preview/overtime-final.png)

The generated eight-page catalog poster is [preview/preview.png](preview/preview.png).

## Settings

- **Team:** Select from the app's 365-school directory. No API key is needed.

The five-minute refresh interval is unchanged. ESPN supplies rosters, season averages and game data. Live scoreboard and boxscore reads use short caches; roster and season-average reads are cached for six hours. An alternate ESPN API host is tried when the primary API request fails; this is not an independent data provider. HTML season-average reads do not have that API-host fallback.

Roster members without posted season-average rows show `--`. A roster with fewer than eight eligible players shows LINEUP NOT POSTED on unfilled cards. Source failures and unposted boxscores have explicit fallback screens. Automatic live coverage depends on ESPN listing the game and its boxscore; this app does not add a separate exhibition-stat feed.

Game selection is automatic. Saved testing/demo overrides from earlier versions are ignored. There are no scenario/demo or manual game-ID settings. Automated-test fixtures are kept outside the release-app folders and are not served by the Studio previews.

## Release checks

Local validation checks all 365 selections and logo assets, all eight page entrypoints, player selection, centered stat values, decimal preservation, long score lines, larger biography text, exceptional surnames, source failures and the absence of public test controls. Layout fixtures and mocked ESPN responses are test evidence, not claims about actual games. These checks cannot guarantee every future provider payload or upstream roster completeness.

After Glance publishes an approved update, verify the actual phone setup form contains only Team, preserves the selected school, and rotates eight pages. No credentials or local review harness files belong in this public app folder.
