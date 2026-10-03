"""Regenerate the player dropdowns of the four Athlete Tracker apps from ESPN.

Runs weekly in GitHub Actions (.github/workflows/athlete-tracker-players.yml),
which opens a PR when a list changes. It can also be run by hand:

    python tools/athlete_tracker_players.py              # top 750 per league
    python tools/athlete_tracker_players.py --top 500
    python tools/athlete_tracker_players.py --league nfl

For each league it rewrites two generated blocks and nothing else:
  * apps/athlete-tracker-<league>/manifest.yaml  - the `player` dropdown choices
  * apps/athlete-tracker-<league>/app.star       - PLAYERS, label -> ESPN athlete id

Players are ranked by ESPN fantasy ownership. PLAYERS only ever grows: a player
who drops out of the top N leaves the dropdown but keeps their entry, so panels
already set to them keep working. Trades need no regeneration at all - the app
reads team, number and colours live from ESPN on every render.
"""
import argparse
import datetime
import json
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# league -> (ESPN fantasy game, ESPN site path, default player)
LEAGUES = {
    "nfl": ("ffl", "football/nfl", "Patrick Mahomes"),
    "nba": ("fba", "basketball/nba", "Nikola Jokic"),
    "nhl": ("fhl", "hockey/nhl", "Connor McDavid"),
    "mlb": ("flb", "baseball/mlb", "Shohei Ohtani"),
}
PAGE = 250   # players per fantasy API request


def app_dir(league):
    return os.path.join(ROOT, "apps", "athlete-tracker-" + league)


def get(url, headers=None):
    req = urllib.request.Request(url, headers=dict({"User-Agent": "athlete-tracker"}, **(headers or {})))
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode("utf-8"))


def fantasy_seasons(game, today):
    """Seasons to try, newest first. NBA/NHL seasons are named for the year they end."""
    y = today.year
    if game in ("fba", "fhl"):
        return [y + 1, y] if today.month >= 8 else [y, y - 1]
    if game == "ffl":
        return [y, y - 1] if today.month >= 3 else [y - 1, y - 2]
    return [y, y - 1]


def top_players(game, n, today):
    """Top n active players by fantasy ownership, paged so large n works."""
    for season in fantasy_seasons(game, today):
        url = (f"https://lm-api-reads.fantasy.espn.com/apis/v3/games/{game}/seasons/{season}"
               f"/segments/0/leaguedefaults/3?view=kona_player_info")
        out, seen = [], set()
        try:
            offset = 0
            while len(out) < n:
                filt = {"players": {"limit": PAGE, "offset": offset, "filterActive": {"value": True},
                                    "sortPercOwned": {"sortPriority": 1, "sortAsc": False}}}
                batch = [p["player"] for p in get(url, {"x-fantasy-filter": json.dumps(filt)}).get("players", [])]
                if not batch:
                    break
                for p in batch:
                    # team defenses are not people
                    if p.get("id", 0) > 0 and "D/ST" not in p.get("fullName", "") and p["id"] not in seen:
                        seen.add(p["id"]); out.append(p)
                offset += PAGE
        except Exception as e:
            print(f"  {game} {season}: {e}", file=sys.stderr)
            out = out if len(out) >= 50 else []
        if out:
            return season, out[:n]
    raise SystemExit(f"no fantasy players for {game}")


def team_abbrevs(site):
    """Team id -> abbreviation, only used to tell apart players who share a name.
    site.api.espn.com has broken before while site.web.api.espn.com kept working."""
    for host in ("site.api.espn.com", "site.web.api.espn.com"):
        try:
            data = get(f"https://{host}/apis/site/v2/sports/{site}/teams")
            teams = data["sports"][0]["leagues"][0]["teams"]
            return {int(t["team"]["id"]): t["team"]["abbreviation"] for t in teams}
        except Exception as e:
            print(f"  {host} teams: {e}", file=sys.stderr)
    return {}   # duplicate names get "(FA)" rather than failing the run


def read_existing(league):
    src = open(os.path.join(app_dir(league), "app.star"), encoding="utf-8").read()
    m = re.search(r"# BEGIN PLAYERS.*?\n(.*?)# END PLAYERS", src, re.S)
    found = {}
    if m:
        for label, pid in re.findall(r'"(.+?)": (\d+),', m.group(1)):
            found[label] = int(pid)
    return found


def build(league, n, today):
    game, site, _ = LEAGUES[league]
    season, players = top_players(game, n, today)
    abbr = team_abbrevs(site)
    names = {}
    for p in players:
        names.setdefault(p["fullName"], []).append(p)
    current = {}
    for name, group in names.items():
        for p in group:
            # two players with one name (Will Smith) get their team added
            label = name if len(group) == 1 else f"{name} ({abbr.get(p.get('proTeamId'), 'FA')})"
            current[label] = p["id"]
    print(f"{league.upper()}: {len(players)} players (fantasy season {season})")
    return current


def write(league, current):
    table = read_existing(league)
    known_ids = set(table.values())
    for label, pid in current.items():
        if pid not in known_ids or label not in table:
            table[label] = pid

    # app.star: the full, append-only lookup table
    path = os.path.join(app_dir(league), "app.star")
    src = open(path, encoding="utf-8").read()
    body = "".join(f"    {json.dumps(k)}: {pid},\n" for k, pid in sorted(table.items(), key=lambda kv: kv[0].lower()))
    block = ("# BEGIN PLAYERS (generated by tools/athlete_tracker_players.py; do not edit by hand)\n"
             "PLAYERS = {\n" + body + "}\n# END PLAYERS")
    src = re.sub(r"# BEGIN PLAYERS.*?# END PLAYERS", lambda _: block, src, flags=re.S)
    open(path, "w", encoding="utf-8", newline="\n").write(src)

    # manifest.yaml: only the current top N, A-Z
    choices = sorted(current, key=lambda s: s.lower())
    want = LEAGUES[league][2]
    default = want if want in current else choices[0]
    path = os.path.join(app_dir(league), "manifest.yaml")
    man = open(path, encoding="utf-8").read()
    flow = "[" + ", ".join(json.dumps(c) for c in choices) + "]"
    # docs call the list `choices`; the Studio/tooling read `options`. Write both.
    block = ("  # BEGIN PLAYER INPUT (generated by tools/athlete_tracker_players.py)\n"
             "  - key: player\n"
             "    app_input_type: dropdown\n"
             "    type: choice\n"
             "    label: Player\n"
             f"    default: {json.dumps(default)}\n"
             "    help: Pick a player. Page 1 shows their season, page 2 their live game or next-game projection.\n"
             f"    choices: {flow}\n"
             f"    options: {flow}\n"
             "  # END PLAYER INPUT")
    man = re.sub(r"  # BEGIN PLAYER INPUT.*?  # END PLAYER INPUT", lambda _: block, man, flags=re.S)
    open(path, "w", encoding="utf-8", newline="\n").write(man)
    print(f"  dropdown: {len(choices)} players; lookup table: {len(table)} players")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--top", type=int, default=750, help="players per league (default 750)")
    ap.add_argument("--league", choices=sorted(LEAGUES), action="append", help="only these leagues (default: all)")
    args = ap.parse_args()
    today = datetime.date.today()
    for lg in args.league or list(LEAGUES):
        if not os.path.isdir(app_dir(lg)):
            print(f"{lg.upper()}: apps/athlete-tracker-{lg} not in this checkout, skipped")
            continue
        write(lg, build(lg, args.top, today))
