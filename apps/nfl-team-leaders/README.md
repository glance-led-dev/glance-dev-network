# NFL Team Leaders

Your NFL team's season leaders, one category per page. Every page has the
club's logo and a pixel-art player in the club's uniform. The player is drawn
doing the page's job and carries the leader's real jersey number.

| page | shows |
|---|---|
| passing | the passer on a jersey-colour nameplate, his yards (hero), TDs and INTs, and his league rank |
| rushing | the rusher's yards (hero), carries and TDs, and his league rank |
| receiving | the receiver's yards (hero), catches and TDs, and his league rank; the figure changes with his position (WR, TE or RB) |
| defense | the tackle, sack and interception leaders, each number on a jersey-colour plate, with `+1` when the lead is shared |

Zero stats are always shown ("6 TD 0 INT"), even when ESPN leaves them out.
The league rank appears only when the player is in the NFL's top 32.

**Input:** Team (a dropdown of all 32 clubs).

**Data:** ESPN's public core API. Each page fetches `teams/{id}/leaders` and
one athlete lookup per leader for the name, jersey number and position. The
hero pages share one call to the league-wide leaders (top 32 per stat) for
his rank, so a full render stays within 8 requests. No key needed. Before a
club's first game of the season the app shows last season's leaders, without
the rank. The year under the logo always says which season is on screen, and
it turns the club colour when it is last season.

**Refresh:** every 30 minutes. Leaders only change after games.
