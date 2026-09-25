# NFL Team Leaders

Your NFL team's season leaders, one category per page, each drawn as a
trading card. The card is framed in the club's jersey colour. On the left is
a photo window with a pixel-art player in the club's uniform, standing on
turf under a night sky with a halo behind him. He is doing the page's job. The window's left column
holds the club logo small in the top corner and his real jersey number. On
the right is the stat side, with the nameplate across the top in the club's
trim colour: the player's name, plus a small stamp for his league rank (or
the card year when there is no rank).

| page | shows |
|---|---|
| passing | the passer's name on the nameplate, his league rank as the plate's stamp, and his yards (big) with TDs and INTs |
| rushing | the rusher's name and rank, his yards, carries and TDs |
| receiving | the receiver's name and rank, his yards, catches and TDs; the figure changes with his position (WR, TE or RB) |
| defense | the tackle, sack and interception leaders, each number on a small trim-colour plate, with `+1` when the lead is shared; the card year sits under the logo |

Zero stats are always shown ("6 TD 0 INT"), even when ESPN leaves them out.
The league rank appears only when the player is in the NFL's top 32. When
the name leaves no room on the nameplate, the rank moves to the unit row.

**Input:** Team (a dropdown of all 32 clubs).

**Data:** ESPN's public core API. Each page fetches `teams/{id}/leaders`,
plus one athlete lookup per leader for the name, jersey number and position.
The three offense pages share one call to the league-wide leaders (the top 32
per stat) for the rank, so a full render stays within 8 requests. No key
needed. Before a club's first game of the season the app shows last
season's leaders, without the rank. Their cards carry the year stamp
('2025 SEASON' when it fits) so it is clear which season is on screen.

**Refresh:** every 30 minutes. Leaders only change after games.
