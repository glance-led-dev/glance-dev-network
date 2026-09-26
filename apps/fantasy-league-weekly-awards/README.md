# Fantasy Weekly Awards

Your fantasy league's awards for the week just played, for **ESPN** and
**Sleeper** leagues. Three pages, each a slot at the banquet. A slot shows one
award at a time and moves to its next award every 5 minutes. Every award has
its own pixel-art trophy, with the winning team's crest and name beside the
number that won it.

| Page | Awards (one per refresh) | Art |
|---|---|---|
| podium | **Top scorer**: the week's best score and who it beat. **Player of the week**: the league's top-scoring starter, with his NFL club logo and the fantasy team that started him | gold cup, club logo |
| games | **Closest game**: the narrowest margin. **Unluckiest**: the highest score that still lost. **Biggest blowout**: the widest margin, with the final score | stopwatch, storm cloud, starburst |
| shame | **Lowest score**: the week's low. **Left on bench**: best possible lineup minus the lineup that was started | toilet, bench and helmet |

**Your team first.** When your team wins one of a page's awards (even one
nobody wants), the page shows that award first and puts a white **YOU** tag on
it.

**Your week.** Every award also has a strip along the bottom showing how your
own week went, for example `YOU 4TH OF 10  123.0 W`: where your score ranked
in the league, your score, and whether you won. The strip appears when the
**Your team** setting matches a team.

**Season trophy shelf (ESPN).** Small gold cups under the top scorer's trophy
count how many weeks that team has had the league's top score this season.
**SEASON HIGH** or **SEASON LOW** appears when this week's score beat every
earlier week.

### Which week

The awards cover the most recent completed week:

- **ESPN:** the current matchup week once every game in it is decided,
  otherwise the week before.
- **Sleeper:** the week before the current NFL week. A week counts as done on
  Tuesday morning, after Monday night's game.

During week 1, before any week has finished, the pages show week 1 so far,
labelled **SO FAR**.

### Guillotine leagues (Sleeper)

A guillotine league has no head-to-head games, so two pages hand out
different awards:

- **games** shows **Still standing** and **Close shave**:
  - **Still standing** has the crest of every team that played, best score
    first. The team that was cut is crossed out, and the heading shows how
    many teams are left. Leagues with more than 10 teams show two rows of
    small crests with the cut team's score in red. Your own crest has a white
    rim.
  - **Close shave** is the team that survived the blade by the smallest
    margin.
- **shame** shows **Chopped** (the team that was cut, with the guillotine)
  and **Left on bench**.

## Setup

| Setting | What to enter |
|---|---|
| League ID | The number in your league's web address: ESPN `...?leagueId=12345678`, Sleeper `sleeper.com/leagues/<18-19 digits>`. Pasting the whole URL works too. |
| Your team | Your team name or your manager / username. Part of it is fine, and case doesn't matter. |
| Platform | Leave on AUTO: Sleeper IDs are 18-19 digits, ESPN IDs are shorter. |
| ESPN cookies | Only for **private** ESPN leagues (see below). |

A Sleeper league ID from last season is followed to this season's league
automatically. Leave the League ID blank for a demo league, labelled DEMO on
the panel.

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

## Where the numbers come from

- **Team scores** are your league's own final scores for the week, in its own
  scoring.
- **Left on bench:**
  - ESPN: the best legal lineup is built from every rostered player's points
    and eligible slots, using your league's lineup settings, IDP slots
    included. Injured reserve doesn't count.
  - Sleeper: the lineup slots come from the league's settings, and positions
    come from Sleeper's weekly stats. A player the app can't place, such as
    an IDP starter, stays in the lineup as started, so the figure never
    overstates what was left on the bench.
- **Player of the week** is the highest-scoring player in any starting
  lineup, in your league's scoring.
- A two-week ESPN playoff matchup reads the bench and player awards from its
  last week.
- If an award can't be worked out (for example, the lineup data isn't
  available), the page skips it and shows its other awards.
- Long team names are never cut mid-word. If the whole name doesn't fit, the
  panel shows the manager's name, then the name's first words, then the team
  abbreviation.

The app refreshes every 5 minutes.
