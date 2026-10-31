# NCAA Bracketology

Kyle Somelofske's approved men's college basketball bracketology projection for a 192×32 Glance display. This is a projection, not a live NCAA tournament bracket or a prediction of individual game winners.

## Settings

- **Bracketology view:** Field of 64, Top 4 Seeds, My Team, Bubble, or Opening Round.
- **Team:** select any of the 365 supported Division I schools. The team selection is used by My Team.

Every view has the shared introduction followed by four content screens. No account, API key, spreadsheet access, or other setup is required.

## Views

- **Field of 64:** four projected regions, preserving alternative teams in opening-round slots rather than choosing a winner.
- **Top 4 Seeds:** the top four seeds in each region with overall rankings.
- **My Team:** selected-school projection and available resume metrics, Round of 64 opponent, and potential Round of 32 and Sweet 16 matchups. Schools outside the projected field are not assigned an invented slot.
- **Bubble:** Last Four Byes, Last Four In, First Four Out, and Multi-bid Conferences. First Four Out uses Kyle's confirmed overall-rank convention of 77–80. Next Four Out is not displayed.
- **Opening Round:** the projection's twelve opening games, split between automatic-qualifier and at-large groups.

## Updates and safeguards

The app reads a public, approved-only projection feed. The provider's working spreadsheet is not distributed with the app. A separate checker validates a READY revision and requires two stable checks at least ten minutes apart before publishing; invalid drafts leave its previously approved output in place.

The introduction's **UPDATED** date is the projection date, not the current date or a scrape timestamp. **SAVED** identifies the dated approved bracket bundled with this app release when its public feed cannot be read or validated. This bundled fallback is not a persistent record of every subsequent successful fetch; it is refreshed when a new app package is released. **UNDATED** means no usable projection date was supplied.

The app refreshes hourly. The approved feed has a 15-minute request cache; supplemental records and ranking sources have hourly caches. These caches do not create additional display refreshes or guarantee immediate propagation after an edit. No paid Parse service is used.

## Supplemental data

- Overall team records: one shared current-season ESPN standings response, matched by exact team ID.
- NET and Q1/Q2 records: NCAA NET table.
- WAB: NCAA WAB table.
- SOR: ESPN resume table.
- SOS: this app's ranking of Bart Torvik's played-schedule SOS values, not a projected or NCAA SOS rank.

Missing, malformed, prior-season, or not-yet-published statistics remain `--`. Source coverage does not guarantee every provider publishes every supported school: Saint Francis is absent from the checked ESPN standings and Torvik export. No other school's values or fabricated zero records are substituted. Seasonal provider changes can temporarily make metrics unavailable without removing the approved projection.

All five pages share their source reads. The release's full-app cold-cache audit passed all 372 settings scenarios with at most six distinct requests against the host's eight-request limit.

## Release

Package: `ncaa-bracketology`, version 0.3.1. The bundled approved projection is October 27, 2026, revision 2: 76 unique selected schools, 64 regional slots, twelve opening games, and 32 automatic qualifiers.

The catalog thumbnail (`preview/preview.png`) shows the opening My Team screen using Texas, enlarged 5x with exact pixels. The individual page previews remain available. Catalog previews show the approved projection; supplemental metrics depend on provider availability at preview generation time. Team marks identify their respective schools.
