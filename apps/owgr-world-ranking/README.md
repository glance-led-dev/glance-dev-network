# OWGR - World Ranking

The Official World Golf Ranking as a broadcast graphic for the 192x32 scroll panel.

| Page | Shows |
| --- | --- |
| `leader` | A gold No.1 medallion, flag, first and last name, a `WORLD NO.1` chip, average points and the lead over No.2 |
| `board1` | Positions 2-7 in two columns: rank tile (silver and bronze for 2 and 3), pixel flag, name, movement since last week |
| `board2` | Positions 8-13 |
| `movers` | The two biggest climbers and fallers inside the top 50 this week, with their new rank |

Movement: a green up arrow with the places gained, a red down arrow with the places lost, a grey dash when unchanged, and `NEW` when the player has no ranking from last week.

## Settings

- **Ranking**: `World` (default), or one OWGR region (Europe, North America, Asia, Australasia, Japan, Africa, South America). A region lists only players from that region, and still shows their world rank. The hero chip reads `EUROPE NO.1`, and `WORLD NO.2` replaces the lead line when the region's best is not world No.1.

## Data

`apiweb.owgr.com/api/owgr/rankings/getRankings`: the public API behind owgr.com. It needs no key and no User-Agent. One 50-row request (about 29 KB) feeds every page. The ranking updates on Mondays, so the app refreshes hourly and caches responses for an hour. When the API is unreachable, every page shows a dimmed medallion with a "rankings unavailable" message.

Flags are 10x7 pixel art drawn in code for about 40 countries: every nation in the top 150 and in each region's top 50. Any other country shows its 3-letter code. Accented names are folded to ASCII. When two players on the list share a surname, the boards add their initials (`T.KIM`, `S.W.KIM`).
