# NCAA Bracketology

Somelofske Sports' approved men's college basketball bracketology projection for a 192×32 Glance display. This is a projection, not a live NCAA tournament bracket or a prediction of individual game winners.

## Settings

- **Bracketology view:** Field of 64, Top 4 Seeds, My Team, Bubble, or Opening Round.
- **Team:** select any of the 365 supported Division I schools. The team selection is used by My Team.

Every view has the shared introduction followed by four content screens. No account, API key, spreadsheet access, or other setup is required.

## Views

- **Field of 64:** four projected regions, preserving alternative teams in opening-round slots rather than choosing a winner.
- **Top 4 Seeds:** the top four seeds in each region with overall rankings.
- **My Team:** selected-school projection and available resume metrics, Round of 64 opponent, and potential Round of 32 and Sweet 16 matchups. Schools outside the projected field are not assigned an invented slot.
- **Bubble:** Last Four Byes, Last Four In, First Four Out, and Multi-bid Conferences. First Four Out uses Somelofske Sports' confirmed overall-rank convention of 77–80. Next Four Out is not displayed.
- **Opening Round:** the projection's twelve opening games, split between automatic-qualifier and at-large groups.

## Updates and safeguards

The app reads a public, approved-only projection feed. The provider's working spreadsheet is not distributed with the app. A separate checker validates a READY revision and requires two stable checks at least ten minutes apart before publishing; invalid drafts leave its previously approved output in place.

The introduction's **UPDATED** date is the projection date, not the current date or a scrape timestamp. **SAVED** identifies the dated approved bracket bundled with this app release when its public feed cannot be read or validated. This bundled fallback is not a persistent record of every subsequent successful fetch; it is refreshed when a new app package is released. **UNDATED** means no usable projection date was supplied.

The app refreshes hourly. The approved feed has a 15-minute request cache; supplemental records and ranking sources have hourly caches. These caches do not create additional display refreshes or guarantee immediate propagation after an edit. No paid Parse service is used.

## Supplemental data

- Overall team records: shared current-season ESPN standings, matched by exact team ID. The approved feed's record snapshot is refreshed independently of the bracket. Valid new values replace individual records; a blank, missing, or failed ESPN response leaves those teams' previous values in place. A confirmed `0-0` is valid. If a school's valid saved record is absent, the app tries the U.S. and then U.K. standings directly, even when other schools have saved records.
- NET and Q1/Q2 records: NCAA NET table.
- WAB: NCAA's official NET-based WAB table only, never Torvik WAB. A current-season value must first be published by NCAA; last season's values remain unavailable.
- SOR: ESPN resume table, with the U.K. ESPN table as an alternate source.
- SOS: this app's ranking of Bart Torvik's played-schedule SOS values, not a projected or NCAA SOS rank.

All ESPN-backed data in this app (currently records and SOR) must have a validated ESPN U.K. recovery path, in both the reader and background publisher. A non-200 response, empty/malformed table, wrong season or missing/invalid school row counts as a failed lookup, not just connection errors. The U.K. response must pass the same exact-ID and current-season checks. ESPN U.K. is not a substitute for NCAA or Torvik data. AP rankings are not fetched by this app.

Missing, malformed, prior-season, or not-yet-published statistics remain `--`. Source coverage does not guarantee every provider publishes every supported school: Saint Francis is absent from the checked ESPN standings and Torvik export. No other school's values or fabricated zero records are substituted. Seasonal provider changes can temporarily make metrics unavailable without removing the approved projection.

The retained-metrics reader uses the existing approved feed's `team_resume` snapshot. Its background publisher merges valid SOR and official NCAA WAB values per school, retaining an absent school's previous value and its original verification timestamp. It rejects the wrong season/provider, duplicate identities, malformed values, and NCAA table date rollbacks. Saved values are preferred consistently across pages; missing saved fields may still try their direct sources. No new visual labels, layouts, or projection revision changes are introduced by metric retention.

The matching publisher was installed and verified November 21, 2026: ESPN U.S. returned HTTP 202 with no usable rows, ESPN U.K. recovered 365 SOR values, and the anonymous approved feed exposed all 365 saved values. Official NCAA WAB still had no current-season rows and was not published. Projection date, revision and content hash stayed unchanged. The existing two triggers were retained, with supplemental fetches still gated to one three-hour window.

Retained metrics need the matching background publisher installed and an available approved feed. The app is stateless: a total feed outage plus unavailable direct sources cannot recover a later saved metric from the bundled bracket alone. Values are retained within the same season until replaced by valid data; they are not falsely marked freshly verified during an outage. The publisher records verification times for diagnostics but the small panel does not show those timestamps.

All five pages share their source reads. The original release's full-app cold-cache audit passed all 372 settings scenarios with at most six distinct requests against the host's eight-request limit. The retained-metrics update also tests missing snapshots and both ESPN sources against the unchanged eight-request ceiling.

## Release

Package: `ncaa-bracketology`. The bundled approved projection is October 27, 2026, revision 2: 76 unique selected schools, 64 regional slots, twelve opening games, and 32 automatic qualifiers.

The catalog thumbnail (`preview/preview.png`) shows the opening My Team screen using Texas, enlarged 5x with exact pixels. The individual page previews remain available. Catalog previews show the approved projection; supplemental metrics depend on provider availability at preview generation time. Team marks identify their respective schools.
