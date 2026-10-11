# Scholar Citations

One researcher's Google Scholar profile on a 192x32 panel.

- **Top level:** the researcher's name on the left, and today's date in a pill of the highlight colour on the right.
- **Bottom level:** a bar chart of citations per year with no year or axis labels. The current year is in the highlight colour and past years are light gray. Beside it are total citations, h-index (H-IDX) and i10-index in white, and this year's citations (labelled with the year, in the highlight colour). Underneath, right-aligned, is this year compared with last year: green and up when ahead, red and down when behind.

## Inputs

| Input | What to enter |
|---|---|
| **SerpApi API key** *(credential)* | Sign up free at [serpapi.com](https://serpapi.com/users/sign_up), then copy the key from [serpapi.com/manage-api-key](https://serpapi.com/manage-api-key). Leave it blank to see a demo profile. |
| **Google Scholar profile ID** | The `user=` value in the profile address. For `https://scholar.google.com/citations?user=tyJLhv4AAAAJ&hl=en` that is `tyJLhv4AAAAJ`. Enter the ID only, not the whole link. **If the ID has an underscore, type each one as a dot**, including a first character: `_Ab-Cd_EAAAJ` becomes `.Ab-Cd.EAAAJ`. Dashes are fine as they are. See the notes below. |
| **Highlight color** | Red, Orange, Yellow, Green, Cyan, Blue (default), Purple, Pink or White. Colors this year's bar, this year's citation count and the pill behind today's date. On Red and Pink the date is written in white; on the rest, in black. |

The date and when "this year" starts follow US Eastern time, with daylight saving applied automatically.

## Data

One call to SerpApi's [Google Scholar Author API](https://serpapi.com/google-scholar-author-api) (`engine=google_scholar_author`, `num=1` so the article list is skipped). The app reads:

- `author.name`
- `cited_by.table`: the `all` values of `citations`, `h_index` and `i10_index`
- `cited_by.graph`: citations per year. Years Scholar leaves out are drawn as zero.

## Quota

The panel re-renders every hour so the date changes on time. The SerpApi fetch is cached for 24 hours, so each profile still uses about 30 searches a month. SerpApi's free plan allows 250. Every install uses its own key, so installs don't share a quota.

## Notes

- **Why underscores need a stand-in.** On the panel, settings reach the app packed into one string in which `:` separates the fields, `_` separates one setting from the next, and the first `-` separates a setting's name from its value. A Scholar ID with an underscore is split apart on the way, and the panel shows `ERROR DISPLAY STUCK CODE: E500` even though the same ID works in the IDE. Dashes after the first one come through intact, and so does a dot, which the app turns back into `_`. For the same reason a pasted profile link arrives as just `https`, and the panel then says ID, NOT THE LINK.
- **This year vs last year** compares this year's citations so far with all of last year. Early in the year it is usually red, and it catches up as the year goes on. Scholar gives only yearly totals, so there is no figure for the same date last year.
- The four numbers are laid out from the right edge, and the chart gets whatever width is left. Bars are 3 px while the years fit, then 2 px, then 1 px, and after that only the most recent years are shown. The tallest year fills the chart.
- The four numbers use one font (6x9) for every profile, sized for a 5-digit total, 3-digit h-index and i10-index, and a 4-digit count for this year. Only numbers bigger than that drop to 6x8, then 5x7, so the chart keeps its space.
- The demo profile (Ada Lovelace, when no key is set) has no DEMO badge; the date pill takes that spot.

## Screens

| State | Panel |
|---|---|
| No key | Demo profile |
| No profile ID | NO PROFILE ID / ADD YOUR SCHOLAR ID |
| Whole link pasted | ID, NOT THE LINK / ENTER THE PROFILE ID ONLY |
| Unknown ID | PROFILE NOT FOUND / CHECK THE SCHOLAR ID |
| Key rejected | KEY REJECTED / CHECK YOUR SERPAPI KEY |
| Quota used up | SEARCH LIMIT HIT / SERPAPI QUOTA USED UP |
| SerpApi unreachable | SERPAPI UNREACHABLE / RETRIES NEXT REFRESH |
