# Waiver Targets

The best players **nobody in your league has rostered**, for **ESPN** and
**Sleeper** leagues. They're ranked by this week's projection, season points,
and how fast managers across Sleeper are adding them.

The panel is a **waiver wire**: a telephone wire strung between two poles,
with the best unrostered players hanging from it on clothespins.

- **target**: the top three at the position. The **#1** card hangs in the
  middle, bigger and framed in gold. It has his NFL club logo, the position
  and this week's opponent (or ON BYE, WAIVERS for an ESPN player still on
  waivers, or **CUT** plus the monogram of the team that dropped him, in
  that team's colour), any injury code, his projection in big type and his
  surname. A pixel flame with a count like **62K** means he's on Sleeper's
  trending list (adds across Sleeper in the last 24 hours). A small manila
  claim tag beside the projection shows what he means for **your** roster
  when your team is set: **WR2 / +7.0** means he'd be your second-best WR
  this week, 7.0 points better than your weakest WR with a game. **NEED / K**
  means you have no kicker, and **NO / GAIN** means you already have better.
  Without a team, the tag shows his season points (**SZN / 38**). The #2 and
  #3 cards hang on either side, each with a logo, rank, projection, injury
  code, a flame for a hot add, and the surname.
- **wire**: the wire goes on with #4, #5 and #6. With your team set, the
  third card is your manila claim ticket instead: your team crest, your
  waiver order (**WAIV #7**) and your FAAB left (**$73 LEFT**), or your
  team's name in a non-FAAB league.

Errors and empty wires (league not found, private league, offline, draft
not done yet, nobody worth adding) show as one sign pinned to the same wire.

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Optional. Your team name or manager name (part of it is fine). It adds your roster need to the tag and your waiver card to the wire. |
| Platform | Leave on AUTO: Sleeper IDs are 18-19 digits, ESPN IDs are shorter. |
| ESPN cookies | Only for **private** ESPN leagues (see below). |
| Position | ALL, QB, RB, WR, TE, K or DEF. ALL moves to the next position every refresh (RB, WR, TE, QB, RB, WR, DEF, K), so running backs and receivers come round twice. |

If you enter last season's Sleeper league ID, the app finds this season's
league for you.

Leave the League ID blank to see a demo league, labelled DEMO on the panel.

### Private ESPN leagues

ESPN only shares private leagues with a signed-in browser. In a desktop
browser logged into ESPN, open your league. Then open DevTools > Application >
Cookies > `https://fantasy.espn.com` and copy two values:

- `espn_s2` into **ESPN espn_s2 cookie**
- `SWID` (including the curly braces) into **ESPN SWID cookie**

Both are stored encrypted, like API keys. They are your ESPN login, so treat
them like a password.

### Yahoo

Not supported. Yahoo's fantasy API needs an OAuth sign-in, and a panel app
can't do that.

## How players are ranked

The score starts from **this week's projection**, then moves toward the
player's **season points per game**: a ninth of the way after two games, a
third from six games on. That way one big week doesn't outrank a strong
projection. A **hot add** earns up to 0.35 x his projection (never more than
3 points), with 150K adds in a day worth the full amount. That way a backup
can't top the list on buzz alone. A player on bye projects 0, so he drops
down the list.

## Where the numbers come from

- **Sleeper:** your league's rosters (every player, reserve and taxi slot
  counts as rostered), and Sleeper's weekly projections and season stats. The
  points are worked out in **your league's own scoring**: every scoring
  setting times the matching stat, so 6-point passing TDs, TE premium and
  yardage bonuses all count, even if you enter last season's league ID
  (the app follows it to this season's league). The trending adds also come
  from Sleeper, and this week's league transactions say who dropped the #1
  target.
- **ESPN:** your league's own free-agent and waiver pool. It gives ESPN's
  projection and season points in your league's scoring, plus the injury
  status. Sleeper's trending adds are matched to ESPN players by name and
  club; a defense is matched by its club.
- A bye is spotted when a club has no opponent in this week's projections,
  and the opponent comes from the same place.
- Your need and your waiver order use your own roster: the rosters the app
  already reads on Sleeper, and one more read of your team on ESPN.

The app refreshes every 5 minutes.
