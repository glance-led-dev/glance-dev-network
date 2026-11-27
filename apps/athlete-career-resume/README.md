# Athlete Career Resume

Pick any NFL, NBA, MLB or NHL player and the panel shows their whole career
rather than their week. Three pages on a 192x32 SCROLL panel: who they are,
what they have piled up, and what they won.

## Settings

| setting | what it is |
|---|---|
| **Player** | Around 3,250 players across the four leagues, A-Z, with the league in the name — `Patrick Mahomes (NFL)`, `Aaron Judge (MLB)`. Default: Patrick Mahomes (NFL). |

No API key. Nothing to set up.

## The look

Every page is drawn on the league's own playing surface — gridiron yard lines,
hardwood planks and arcs, rink boards and faceoff circles, an outfield's mown
diamond — tinted in the team's colour and pinned to about 3% luminance, so it
tells you the sport before you have read a word and never competes with what
sits on top of it. Text carries a one-pixel halo in the background colour so
it stays sharp over a yard line.

The rails are a three-segment bracket, and the lit segment is the page you are
looking at.

Team colour is spent to one rule: the accent is the trim if the trim is a real
colour, taken to full brightness, and it is refused if it lands near gold —
because gold belongs to the trophies and nothing else. Kansas City's gold
would otherwise have drawn the rail, the captions and the trophies in one
colour, and the trophies would have stopped being the thing you see.

## The pages

**Resume** — a player card. The kit in team colours with the number stamped on
it: helmet for football, jersey for basketball and baseball, sweater for
hockey. Then the surname on a nameplate at a fixed size — deliberately not
fitted to the panel, because fitting made a short name render *larger* than a
long one, which reads as the renderer guessing rather than as a design. Beside
it a league mark and the position on a coloured chip, and the college and
season count. On the right, the team crest and a shield with the draft pick
stamped into it; an undrafted player gets the word instead.

**Career** — the crest, then the one number that defines the player, as large
as the panel will draw it, chosen by position and league:

| | hero | beside it |
|---|---|---|
| NFL | passing / rushing / receiving yards, kicking or punting yards, tackles | touchdowns, and carries, catches or sacks |
| NBA | career points | rebounds, assists |
| MLB | home runs, or strikeouts for a pitcher | RBI and average, or wins and ERA |
| NHL | career points, or wins for a goaltender | goals and assists, or shutouts and save % |

To its right, one bar per season from the first to the most recent, scaled from
zero, on a baseline with five-year ticks: the shape of the career, not just its
sum. The best season is white and wears a crown with its value; the current
season is in the team's trim. Long careers pack tighter and then alternate two
tones, so twenty-four seasons read as a skyline rather than a picket fence.

A player with no scoring stats at all — an offensive lineman, a rookie yet to
play — gets games played instead, which is the honest number for them, and the
category glyph fills the crest column when the club has no crest art.

**Honors** — the trophy case: the three biggest hauls, each as its own trophy
with the number of times it was won, the most recent year, and the team crest
at the right. The silhouette is the label. Sixteen marks, so a Lombardi is not
a Larry O'Brien is not a Stanley Cup; the four championship trophies are the
only silver objects on the panel, so "won the whole thing" reads before any
shape is parsed. All-league teams keep their rank in the art as well as the
caption — 1st team is a solid star, 2nd is rimmed, 3rd is hollow — so a shelf
of three All-NBA selections is three different pictures. The rank is the last
thing that may be clipped from a caption, never the first.

ESPN lists no awards for most players, Travis Kelce included, so an empty
cabinet is the common case and is not drawn as an error. The page relabels
itself **Career Path** and shows every club instead: each crest, oldest on the
left, arrows between them, seasons underneath. One or two clubs are named in
full; from three on the crests carry it alone and the rest become a `+N`.

## Data

All from ESPN's athlete endpoints, per league — the profile, `/bio` for awards
and team history, and `/stats` for career totals and the per-season table.
Three requests, cached six hours. The manifest refreshes hourly; the cache
deliberately outruns it, because a career total only moves after a game, so
most renders are served from cache. If ESPN cannot be reached the panel says
so and retries rather than going blank.

## Trades and new players

Team, number, colours and team history are read live on every refresh, so a
traded player moves clubs on their own and the new crest appears on the career
path. The player list is merged from the four `athlete-tracker-*` apps, which
regenerate theirs weekly from ESPN ownership; a player who drops out leaves
the dropdown but keeps working for panels already set to them.

Team crests and the kit sprites are the hand-drawn pixel art from the
`athlete-tracker-*` apps; the award marks, league marks, playing surfaces and
the rest of the sprite work are drawn for this app. Team marks belong to their
owners.
