# Local Closings research log

Investigation of U.S. school/business closings **technology families** (not hostname lists). August 2026: many live feeds are empty; an empty structured response is a successful test.

Ownership group is not the same thing as a closings vendor.

## Previously supported (unchanged)

### Gray GSync / NewsTicker

```text
Ownership group: Gray Media (also some Allen Media)
Station examples: 21Alive (WPTA), WTHI, WLFI
Closings URLs: https://www.21alivenews.com/weather/closings/
               https://www.wthitv.com/weather/closings/
               https://www.wlfi.com/weather/closings/
Underlying vendor/system: Arc GSync `gsync-closings` / NewsTicker XML
Data endpoint: {origin}/pf/api/v3/content/fetch/gsync-closings
Format: JSON (`totalResults`, `organizations`)
Reusable adapter?: yes
Implemented?: yes (existing)
Notes: Allen Media WTHI/WLFI HTML contains `gsync-closings`. No Allen-specific parser.
```

### TownNews / BLOX XML

```text
Ownership group: various TownNews/BLOX CMS stations
Station examples: KOAM
Closings URLs: https://www.koamnewsnow.com/weather/closings-and-delays/
Underlying vendor/system: TownNews BLOX `/app/closings/*.xml`
Data endpoint: {origin}/app/closings/KOAM-closingsC.xml (prefer named file over 404 closings.xml)
Format: XML `<File>` / `<Closing>`
Reusable adapter?: yes
Implemented?: yes (existing)
Notes: CBS Philadelphia KYW feed is the same BLOX XML shape on cbsnewsstatic.com.
```

### Nexstar WordPress / PSG

```text
Ownership group: Nexstar (and Nexstar-hosted sites)
Station examples: KSN, Four States Homepage, FOX4 Kansas City
Closings URLs: https://www.ksn.com/closings/
               https://www.fourstateshomepage.com/weather/closings/
               https://www.fox4kc.com/weather/closings/
Underlying vendor/system: Lakana/Nexstar WP + PSG iframe
Data endpoint: media.psg.nexstardigital.net/... or wp-json/wp/v2/pages?slug=closings
Format: HTML widget / WP JSON
Reusable adapter?: yes
Implemented?: yes (existing)
Notes: FOX4 KC is Nexstar technology, not FOX O&O WorldNow.
```

### NBC O&O WordPress

```text
Ownership group: NBC owned-and-operated
Station examples: NBCDFW
Closings URLs: https://www.nbcdfw.com/weather/school-closings/
Underlying vendor/system: NBC station WordPress
Data endpoint: page HTML + {origin}/wp-json/nbc/v1/school-closings
Format: HTML (`closings--inactive`) / JSON list
Reusable adapter?: yes
Implemented?: yes (existing)
Notes: Empty copy includes "Forecast: School's Open."
```

### Scripps Brightspot / FlashAlert

```text
Ownership group: Scripps (and any station embedding FlashAlert)
Station examples: KOAA
Closings URLs: https://www.koaa.com/weather/school-closings-delays
Underlying vendor/system: Brightspot `module--closings` and/or FlashAlert
Data endpoint: page HTML; FlashAlert `cwc-closures.php?RegionID=`
Format: HTML
Reusable adapter?: yes
Implemented?: yes (existing; iframe follow-up added for non-Scripps embeds)
Notes: FlashAlert is a third-party vendor, not Scripps-only.
```

## New / expanded families

### FlashAlert iframe (cross-group)

```text
Ownership group: Scripps; some Sinclair (KATU); other FlashAlert markets
Station examples: KOAA (Scripps), KATU (Sinclair)
Closings URLs: https://www.koaa.com/weather/school-closings-delays
               https://katu.com/weather/closings
Underlying vendor/system: FlashAlert News Wire
Data endpoint: https://www.flashalertnewswire.net/IIN/reportsX/cwc-closures.php?RegionID=
Format: HTML (`cwcReportContainer` / "No information reported.")
Reusable adapter?: yes
Implemented?: yes (extract iframe/script URL even from escaped Next.js HTML, then fetch)
Notes: Sinclair is mixed. KATU uses FlashAlert; WJLA/KOMO/WSYX/WSET/KTUL do not.
```

### WorldNow orgname HTML (FOX O&O + most Sinclair)

```text
Ownership group: FOX owned-and-operated; Sinclair (most researched stations)
Station examples: FOX 5 NY, FOX 2 Detroit, FOX 29 Philly, FOX 5 Atlanta,
                  WJLA, KOMO, WSYX, WSET, KTUL
Closings URLs: https://www.fox5ny.com/closings
               https://www.fox2detroit.com/closings
               https://www.fox29.com/closings
               https://www.fox5atlanta.com/closings
               https://wjla.com/weather/closings
               https://komonews.com/weather/closings
Underlying vendor/system: WorldNow-style HTML table (`.orgname` / `.status`)
Data endpoint: https://media.foxtv.com/{callsign}/closings/closings.html (or .htm)
               {origin}/resources/ftptransfer/{callsign}/closings/*.html
Format: HTML
Reusable adapter?: yes
Implemented?: yes
Notes: Empty copy is usually "There are no active records at this time."
       Atlanta iframe uses "No Closings Reported".
       FOX 5 DC iframe uses a different empty table ("THERE ARE CURRENTLY NO CLOSINGS OR CANCELLATIONS").
       KTUL also links Newsroom Solutions login (`secure1.newsroomsolutions.com`) — admin only, not implemented.
```

### TEGNA closings module

```text
Ownership group: TEGNA
Station examples: WFAA, KHOU, KARE 11, 9NEWS, 11Alive
Closings URLs: https://www.wfaa.com/closings
               https://www.khou.com/closings
               https://www.kare11.com/closings
               https://www.9news.com/closings
               https://www.11alive.com/closings
Underlying vendor/system: TEGNA Digital closings module (`closings__*`)
Data endpoint: none public; listing is server-rendered on the page
Format: HTML (`closings__error` = "No delays or closings.")
Reusable adapter?: yes
Implemented?: yes
Notes: `/feeds/syndication/rss/weather/closings` is news articles, not the listing. Do not use it.
       Guessed JSON paths 404. Populated rows use `closings__title` / `closings__body` (from CSS).
```

### Hearst closingsData

```text
Ownership group: Hearst Television
Station examples: KMBC, WISN, WCVB, KCRA, WPTZ/mynbc5
Closings URLs: https://www.kmbc.com/weather/closings
               https://www.wisn.com/weather/closings
               https://www.wcvb.com/weather/closings
               https://www.kcra.com/weather/closings
Underlying vendor/system: Hearst Next.js pages; admin vendor reportclosing.com (login only)
Data endpoint: embedded RSC `closingsData` (`closings: []`, `total: 0`); also SSR empty copy
Format: embedded JSON-like payload + HTML empty copy
Reusable adapter?: yes
Implemented?: yes
Notes: No public JSON URL found. reportclosing.com is not a listing API.
```

### CBS News school-closings XML

```text
Ownership group: CBS-owned local news sites on cbsnews.com
Station examples: WBZ Boston, WJZ Baltimore, KDKA Pittsburgh, WCCO Minnesota, KYW Philadelphia
Closings URLs: https://www.cbsnews.com/boston/school-closings/
               https://www.cbsnews.com/baltimore/school-closings/
               https://www.cbsnews.com/pittsburgh/school-closings/
               https://www.cbsnews.com/minnesota/school-closings/
               https://www.cbsnews.com/philadelphia/school-closings/
Underlying vendor/system: CBS Integrations SchoolClosings (`provider: newsroom` or `bti`)
Data endpoint: https://assets1.cbsnewsstatic.com/Integrations/SchoolClosings/PRODUCTION/CBS/{callsign}/...
Format: NewsTicker XML (`NUM_CLOSINGS` / `RECORD`) or BLOX `<File>` (KYW)
Reusable adapter?: yes (follow the `feed` URL; do not assume one XML dialect)
Implemented?: yes
Notes: Chicago uses Emergency Closing Center iframe (React SPA) — no public JSON/XML, not implemented.
       NY/LA cbsnews.com/{market}/school-closings/ 404 at research time.
```

### Cox Arc closing-list

```text
Ownership group: Cox Media Group
Station examples: WSB-TV, WPXI, KIRO 7
Closings URLs: https://www.wsbtv.com/weather/school-closings/
               https://www.wpxi.com/weather/school-closings/
               https://www.kiro7.com/weather/school-closings/
Underlying vendor/system: Arc Publishing `closing-list` widget
Data endpoint: none public; widget is server-rendered
Format: HTML (`No results found` / Results 0 of 0)
Reusable adapter?: yes for empty detection
Implemented?: yes (empty confirmed; populated row classes not observed in August)
Notes: `/weather/closings/` on these sites is often an article index, not the live board.
       WFTV `/weather/school-closings/` 404 at research time.
```

### Arc Fusion SchoolClosings

```text
Ownership group: Heritage Broadcasting (9&10 / WWTV); any Arc site with this feature
Station examples: 9&10 News
Closings URLs: https://www.9and10news.com/weather/school-closings/
Underlying vendor/system: Arc XP Fusion feature `SchoolClosings/default`
Data endpoint: {origin}/pf/api/v3/content/fetch/weather-school-closings
Format: JSON (`closing[]` with `name1`, `status`, `statuscode`, `entitytype`);
        empty HTML copy "No active school closings at this time."
Reusable adapter?: yes
Implemented?: yes
Notes: Not Gray GSync. Empty JSON is `{lastUpdated, _id}` with no `closing` key.
       Rows with `statuscode` "0" are skipped (same as the site's widget).
       Populated HTML uses `.school .name` / `.status` if the JSON follow-up is unused.
```

## Investigated, not implemented as a new family

### Sinclair as a single parser

Sinclair stations share a Next.js CMS, but closings are **not** one feed:

- KATU → FlashAlert iframe
- WJLA, KOMO, WSYX, WSET, KTUL → WorldNow ftptransfer HTML
- KTUL also has Newsroom Solutions **admin** login

Implemented the vendors, not a fake Sinclair adapter.

### CBS Chicago / Emergency Closing Center

```text
Ownership group: CBS Chicago / WGN Radio widget on CBS
Station examples: https://www.cbsnews.com/chicago/school-closings/
Underlying vendor/system: emergencyclosingcenter.com React SPA
Data endpoint: iframe https://wgnr-closings.emergencyclosingcenter.com/index.html
Format: JS-only; no useful HTML listing without executing JavaScript
Reusable adapter?: no public JSON/XML found
Implemented?: no
```

### Newsroom Solutions

```text
Ownership group: appears on some Sinclair pages (KTUL)
Closings URLs: https://www.secure1.newsroomsolutions.com/s/closings?client=...
Underlying vendor/system: Newsroom Solutions
Data endpoint: login/admin HTML, not a public listing
Reusable adapter?: not for Glance
Implemented?: no
```

### FOX O&O gaps

- `foxla.com/closings`, `fox26houston.com/closings`, `fox7austin.com/closings` 404
- FOX 5 DC iframe HTML is a different empty table; empty copy is handled, populated markup not observed
- Do not treat Nexstar FOX affiliates as FOX O&O

### Vendors looked for and not found on these TV pages

RSchoolToday, SchoolMessenger, AlertSense, CivicReady, Blackboard/Finalsite, PowerSchool public feeds were **not** confirmed as the engine behind the researched station closings pages.

### Montana, Utah and Wyoming sweep

These three states had no readable source. Every TV station, the Townsquare and iHeart radio sites, public radio and the main newspapers in each were probed. Each site was tried at about 25 closings paths, the Gray, Arc, Nexstar WP and TownNews feeds, and Sinclair `ftptransfer`. FlashAlert region IDs 1–40 were also enumerated.

Found and added:
- **KPAX Missoula** (Scripps): the closings module lives at `/school-closings-delays`, not under `/weather/`. It's the same module as KIVI and KOAA.
- **ABC4 Salt Lake City** (Nexstar): `/wp-json/wp/v2/pages?slug=closings` returns the real closings page, created for the Feb 2023 storm.
- **Wyoming News Now** (Gray, on TownNews): there's no BLOX closings app. Instead it posts one "School Closings and Delays" article per storm in the `weather/closings` section. The TownNews search feed (`/search/?f=json&t=article&c=weather/closings&l=1&s=start_time&sd=desc`) is 6 KB and returns the article body as HTML lines with `starttime`. The Feb 19, 2025 article parses to 30 rows across WY, western NE and northern CO.
- **FlashAlert region 25:** Medford/Klamath Falls/Grants Pass. Regions 8 and 29 are test regions and 26 is national.

Checked and left out:
- **The other MTN Scripps stations** (KTVQ, KRTV, KXLH, KBZK, KXLF, KTVH): `/weather/closings` is an empty shell, also empty in archived winter copies. `/school-closings-delays` is a 404.
- **FOX 13 Salt Lake** (Scripps): `/weather/closings` is a hand-typed RichText note. A Provo "Two Hour Late Start on Tuesday" item has stayed on it from Dec 2025 to Nov 2026.
- **KUTV, KJZZ, NBC Montana** (Sinclair): `ftptransfer` closings files are 403 (absent).
- **KSL:** `/closings` returns an empty 200 body. KSL and KSL NewsRadio post closings as articles.
- **KULR, Montana Right Now** (Cowles, TownNews): no closings app or closings section.
- **Radio** (Townsquare: K2 Radio, KGAB, KGVO, KMMS…): tag pages and articles only.
- **Newspapers** (Lee, Adams, APG): no closings section.

### Coverage-gap sweep (biggest uncovered areas)

The gaps were ranked by how many ZIP codes a new source could bring within 35 miles. The worst were Los Angeles, Chicago, the Bay Area, Albany, Miami and San Diego. About 230 candidate links were then run through the app.

- **Chicago:** the Emergency Closing Center widget (`wgnr-closings.emergencyclosingcenter.com`) loads `media.psg.nexstardigital.net/WGNR/closings/closings.json`. The same folder serves `closings.xml` in NewsTicker format (`DATA/RECORD`, `RUN_DATE`), which the app already reads. WGN's own WordPress page only iframes the widget. Of about 120 Nexstar call signs, only WGNR, WCBD, WJW and WJZY have this XML; the rest are 403.
- **Nexstar page names vary:** `/wp-json/wp/v2/pages?search=closing` finds them (`closings-and-delays` at NEWS10, `chicago-area-school-closings` at WGN). A `closings-and-delays` address also matched the TownNews URL rule, which skipped the Nexstar reader; fixed.
- **Nexstar pages that aren't lists:** OurQuadCities (an image), MyStateline (a text note), WSAV (an organisation login), WRBL and WDHN (hand-typed lists), FOX59 (a PSG embed that is 403), and KTLA, PIX11, KRON 4, FOX40 and WFLA (no closings page found). OzarksFirst iframes `schoolclosingsnet.com`, which sits behind a Cloudflare challenge.
- **Gray domains that moved** (301): WIFR → rockfordnewsfirst.com, NBC15 → wmtv15news.com, KMOV → firstalert4.com, WAVE → wdrbwave.com, KBJR → northernnewsnow.com, NBC29 → 29news.com.
- **NBC owned:** NBC Los Angeles, NBC Bay Area, NBC 7 San Diego and NBC 6 Miami all use the same school-closings page as NBC New York.
- **Sinclair file names have capitals:** WCYB `Schools.html` and KRCG `WebClose.htm` were missed by a lowercase-only search.
- **ABC 17 (KMIZ):** iframes `npgdigital.com/kmiz/closings.html`, a two-table HTML page ("No Active School Closings"). No other NPG station has one.
- **No list:** KOMU (an empty TownNews section), News 12 (`/closings` is 404), WFMZ, and the CBS News pages for LA, SF, Miami, Sacramento and Chicago.

## HTTP budget

Adapters fetch the pasted page, then **at most one** follow-up (GSync JSON, BLOX XML, PSG/FlashAlert/WorldNow iframe, CBS XML, WP JSON, or Arc `weather-school-closings`). TEGNA, Hearst, Cox, NBC HTML, Scripps HTML, and Arc SchoolClosings empty copy use the page body only when that is the listing.
