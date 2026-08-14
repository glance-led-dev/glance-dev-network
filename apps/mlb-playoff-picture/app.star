# MLB Playoff Picture (128x32)
#
# The playoff bracket as it stands right now: 8 pages - an intro card, the
# first-round byes (#1/#2 seeds in each league), AL and NL Wild Card Series
# matchups, AL and NL Division Series previews, and AL and NL "on the
# bubble" pages for the teams just missing the field. Each league's 6-team
# field follows the format used since 2022 (3 division winners seeded 1-3
# by record, 3 wild cards seeded 4-6): #1/#2 bye, #3 hosts #6, #4 hosts #5
# in the Wild Card Round, then #1 hosts the #4/#5 winner and #2 hosts the
# #3/#6 winner in the Division Series.
#
# Data from MLB's own public Stats API (statsapi.mlb.com) - no key required.
# Sibling app to mlb-offensive-leaders / mlb-pitching-leaders, same team
# color source.

TEAM_COLORS = {
    108: ["#BA0021"],  # LAA (Red)
    109: ["#A71930"],  # AZ (Sedona Red)
    110: ["#DF4601"],  # BAL (Orange)
    111: ["#BD3039"],  # BOS (Red)
    112: ["#0E3386"],  # CHC (Cubs Blue)
    113: ["#C6011F"],  # CIN (Red)
    114: ["#E31937"],  # CLE (Red)
    115: ["#333366", "#C4CED4"],  # COL (purple, silver - black dropped, too dark to read as a stripe)
    116: ["#FA4616"],  # DET (Orange)
    117: ["#F4911E"],  # HOU (Orange)
    118: ["#004687"],  # KC (Royal Blue)
    119: ["#005A9C"],  # LAD (Dodger Blue)
    120: ["#AB0003"],  # WSH (Red)
    121: ["#FF5910"],  # NYM (Orange)
    133: ["#EFB21E"],  # ATH (Gold)
    134: ["#FDB827"],  # PIT (Gold)
    135: ["#FFC425"],  # SD (Gold)
    136: ["#005C5C"],  # SEA (Northwest Green)
    137: ["#FD5A1E"],  # SF (Orange)
    138: ["#C41E3A"],  # STL (Cardinal Red)
    139: ["#8FBCE6"],  # TB (Columbia Blue)
    140: ["#003278"],  # TEX (Blue)
    141: ["#134A8E"],  # TOR (Blue)
    142: ["#D31145"],  # MIN (Scarlet Red)
    143: ["#E81828"],  # PHI (Red)
    144: ["#CE1141"],  # ATL (Scarlet)
    145: ["#27251F"],  # CWS
    146: ["#00A3E0"],  # MIA (Miami Blue)
    147: ["#0C2340"],  # NYY (Navy)
    158: ["#12284B"],  # MIL (Navy Blue)
}

AL_ID = 103
NL_ID = 104

# Original pixel-art cap silhouette (not a reproduction of any team's real
# logo/mark) - just a rounded crown + brim, filled in the team's own color.
# Two mirrored variants so the AL/NL halves of the byes page face each other.
HAT_ICON = [
    "..###..",
    ".#####.",
    "#######",
    "#######",
    "....###",
]
HAT_ICON_MIRRORED = [
    "..###..",
    ".#####.",
    "#######",
    "#######",
    "###....",
]

# ---------- color helpers ----------

def brightness(hex_color):
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)
    return (r * 299 + g * 587 + b * 114) // 1000

def badge_color(team_id):
    # Darkest of the team's colors - these badges carry white text, so a near-white
    # option (e.g. LAD's white) would be unreadable; the darkest color gives the best
    # contrast against white text while still reading as the team's color.
    colors = TEAM_COLORS.get(team_id, ["#444444"])
    best = colors[0]
    best_brightness = brightness(best)
    for color in colors:
        b = brightness(color)
        if b < best_brightness:
            best = color
            best_brightness = b
    return best

# ---------- network (keyless) ----------

def fetch_standings(standings_type, season):
    return http.get(
        "https://statsapi.mlb.com/api/v1/standings",
        params = {
            "leagueId": "103,104",
            "season": str(season),
            "standingsTypes": standings_type,
        },
        ttl_seconds = 60,
    )

def fetch_teams():
    return http.get(
        "https://statsapi.mlb.com/api/v1/teams",
        params = {"sportId": "1"},
        ttl_seconds = 2592000,
    )

def team_abbrev_map():
    resp = fetch_teams()
    m = {}
    if resp["status_code"] != 200:
        return m
    for t in resp["json"].get("teams", []):
        m[t["id"]] = t.get("abbreviation", "")
    return m

def team_city_map():
    resp = fetch_teams()
    m = {}
    if resp["status_code"] != 200:
        return m
    for t in resp["json"].get("teams", []):
        m[t["id"]] = t.get("locationName", "")
    return m

def team_nickname_map():
    resp = fetch_teams()
    m = {}
    if resp["status_code"] != 200:
        return m
    for t in resp["json"].get("teams", []):
        m[t["id"]] = t.get("teamName", "")
    return m

# ---------- seeding ----------
# Format used since 2022: 3 division winners seeded 1-3 by record, then the
# top 3 non-division-winners by wild card standing seeded 4-6.

def division_winners(div_records, league_id):
    winners = []
    for block in div_records:
        if block.get("league", {}).get("id") != league_id:
            continue
        for t in block.get("teamRecords", []):
            if t.get("divisionRank") == "1":
                winners.append(t)
    return winners  # up to 3, one per division

def sort_by_league_rank(teams):
    # Small manual sort (<=3 items) - Starlark has no sorted(..., key=...).
    items = list(teams)
    n = len(items)
    for i in range(n):
        for j in range(n - 1 - i):
            r1 = int(items[j].get("leagueRank", "999"))
            r2 = int(items[j + 1].get("leagueRank", "999"))
            if r1 > r2:
                items[j], items[j + 1] = items[j + 1], items[j]
    return items

def wildcard_top3(wc_records, league_id):
    for block in wc_records:
        if block.get("league", {}).get("id") == league_id:
            # the wildCard standingsType block already excludes division
            # winners and sorts the rest by wildCardRank ascending
            return block.get("teamRecords", [])[:3]
    return []

def seeds_for_league(div_records, wc_records, league_id):
    winners = sort_by_league_rank(division_winners(div_records, league_id))
    wc = wildcard_top3(wc_records, league_id)
    seeds = []
    for t in winners:
        seeds.append(t)
    for t in wc:
        seeds.append(t)
    return seeds  # seed order: index 0 = seed 1 ... index 5 = seed 6

# ---------- drawing ----------

def team_label(t, abbrev):
    team_id = t.get("team", {}).get("id", -1)
    return abbrev.get(team_id, "???")

def record_label(t):
    rec = t.get("leagueRecord", {})
    return str(rec.get("wins", 0)) + "-" + str(rec.get("losses", 0))

def city_line(city_name):
    return "GAMES IN " + city_name

def draw_badge(c, x, y, team_id, text):
    text = text.upper()
    w = c.text_width(text, font = "4x5")
    c.rect(x - 1, y - 1, x + w, y + 5, fill = badge_color(team_id))
    c.text(text, x, y, font = "4x5", color = "white", align = "left")

def draw_split_bg(c, y, away_id, home_id):
    c.rect(0, y - 1, 64, y + 5, fill = badge_color(away_id))
    c.rect(64, y - 1, 127, y + 5, fill = badge_color(home_id))
    c.line(64, y - 1, 64, y + 5, "black")

def draw_matchup_row(c, y, away_id, away_text, home_id, home_text):
    away_text = away_text.upper()
    home_text = home_text.upper()
    draw_split_bg(c, y, away_id, home_id)
    c.text(away_text, 32, y, font = "4x5", color = "white", align = "center")
    c.text(home_text, 96, y, font = "4x5", color = "white", align = "center")

def gms_line(city_name):
    return "GAMES 1 & 2 IN " + city_name

def draw_ds_row(c, y, bye_id, bye_text, wc_a_id, wc_a_text, wc_b_id, wc_b_text):
    bye_text = bye_text.upper()
    wc_a_text = wc_a_text.upper()
    wc_b_text = wc_b_text.upper()

    c.rect(0, y - 1, 32, y + 5, fill = badge_color(wc_a_id))
    c.rect(32, y - 1, 64, y + 5, fill = badge_color(wc_b_id))
    c.rect(64, y - 1, 127, y + 5, fill = badge_color(bye_id))

    c.text(wc_a_text, 16, y, font = "4x5", color = "white", align = "center")
    c.text(wc_b_text, 48, y, font = "4x5", color = "white", align = "center")
    c.text(bye_text, 96, y, font = "4x5", color = "white", align = "center")

    c.line(32, y - 1, 32, y + 5, "black")
    c.line(64, y - 1, 64, y + 5, "black")

def draw_ds_preview_page(c, ctx, league_id, league_label):
    c.fill("black")

    div_resp = fetch_standings("regularSeason", ctx.now.year)
    wc_resp = fetch_standings("wildCard", ctx.now.year)
    if div_resp["status_code"] != 200 or wc_resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        return

    seeds = seeds_for_league(
        div_resp["json"].get("records", []),
        wc_resp["json"].get("records", []),
        league_id,
    )
    if len(seeds) < 6:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        return

    nicknames = team_nickname_map()
    abbrev = team_abbrev_map()
    cities = team_city_map()

    c.rect(0, 0, 127, 6, fill = "white")
    c.text((league_label + " DIVISION SERIES").upper(), 64, 1, font = "4x5", color = "black", align = "center")

    seed1, seed2, seed3, seed4, seed5, seed6 = seeds[0], seeds[1], seeds[2], seeds[3], seeds[4], seeds[5]
    seed1_id = seed1.get("team", {}).get("id", -1)
    seed2_id = seed2.get("team", {}).get("id", -1)
    seed3_id = seed3.get("team", {}).get("id", -1)
    seed4_id = seed4.get("team", {}).get("id", -1)
    seed5_id = seed5.get("team", {}).get("id", -1)
    seed6_id = seed6.get("team", {}).get("id", -1)

    y = 8
    draw_ds_row(c, y, seed1_id, "1 " + team_label(seed1, nicknames),
                 seed4_id, team_label(seed4, abbrev), seed5_id, team_label(seed5, abbrev))
    y += 6
    c.text(gms_line(cities.get(seed1_id, "")).upper(), 64, y, font = "picopixel", color = "gray", align = "center")
    y += 6
    draw_ds_row(c, y, seed2_id, "2 " + team_label(seed2, nicknames),
                 seed3_id, team_label(seed3, abbrev), seed6_id, team_label(seed6, abbrev))
    y += 6
    c.text(gms_line(cities.get(seed2_id, "")).upper(), 64, y, font = "picopixel", color = "gray", align = "center")

def draw_wc_series_page(c, ctx, league_id, league_label):
    c.fill("black")

    div_resp = fetch_standings("regularSeason", ctx.now.year)
    wc_resp = fetch_standings("wildCard", ctx.now.year)
    if div_resp["status_code"] != 200 or wc_resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        return

    seeds = seeds_for_league(
        div_resp["json"].get("records", []),
        wc_resp["json"].get("records", []),
        league_id,
    )
    if len(seeds) < 6:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        return

    nicknames = team_nickname_map()
    cities = team_city_map()

    c.rect(0, 0, 127, 6, fill = "white")
    c.text((league_label + " WILD CARD SERIES").upper(), 64, 1, font = "4x5", color = "black", align = "center")

    seed3, seed4, seed5, seed6 = seeds[2], seeds[3], seeds[4], seeds[5]
    seed3_id = seed3.get("team", {}).get("id", -1)
    seed4_id = seed4.get("team", {}).get("id", -1)
    seed5_id = seed5.get("team", {}).get("id", -1)
    seed6_id = seed6.get("team", {}).get("id", -1)

    y = 8
    draw_matchup_row(c, y, seed6_id, "6 " + team_label(seed6, nicknames), seed3_id, "3 " + team_label(seed3, nicknames))
    y += 6
    c.text(city_line(cities.get(seed3_id, "")).upper(), 64, y, font = "picopixel", color = "gray", align = "center")
    y += 6
    draw_matchup_row(c, y, seed5_id, "5 " + team_label(seed5, nicknames), seed4_id, "4 " + team_label(seed4, nicknames))
    y += 6
    c.text(city_line(cities.get(seed4_id, "")).upper(), 64, y, font = "picopixel", color = "gray", align = "center")

def draw_byes_page(c, ctx):
    c.fill("black")

    div_resp = fetch_standings("regularSeason", ctx.now.year)
    wc_resp = fetch_standings("wildCard", ctx.now.year)
    if div_resp["status_code"] != 200 or wc_resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        return

    div_records = div_resp["json"].get("records", [])
    wc_records = wc_resp["json"].get("records", [])
    al_seeds = seeds_for_league(div_records, wc_records, AL_ID)
    nl_seeds = seeds_for_league(div_records, wc_records, NL_ID)
    if len(al_seeds) < 2 or len(nl_seeds) < 2:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        return

    nicknames = team_nickname_map()

    c.rect(0, 0, 127, 6, fill = "white")
    c.text("MLB FIRST ROUND BYES", 64, 1, font = "4x5", color = "black", align = "center")

    c.line(64, 7, 64, 31, "#555555")

    al1_id = al_seeds[0].get("team", {}).get("id", -1)
    nl1_id = nl_seeds[0].get("team", {}).get("id", -1)
    al2_id = al_seeds[1].get("team", {}).get("id", -1)
    nl2_id = nl_seeds[1].get("team", {}).get("id", -1)

    y = 10
    draw_badge(c, 6, y, al1_id, "1 " + team_label(al_seeds[0], nicknames))
    draw_badge(c, 72, y, nl1_id, "1 " + team_label(nl_seeds[0], nicknames))
    y += 10
    draw_badge(c, 6, y, al2_id, "2 " + team_label(al_seeds[1], nicknames))
    draw_badge(c, 72, y, nl2_id, "2 " + team_label(nl_seeds[1], nicknames))

# ---------- pages ----------

def intro(c, ctx):
    c.clear()
    c.text("MLB PLAYOFFS".upper(), 64, 3, font = "7x12", color = "white", align = "center")
    c.line(20, 18, 108, 18, "#555555")
    c.text("IF SEASON ENDED TODAY".upper(), 64, 21, font = "4x5", color = "gray", align = "center")
    # matches manifest.yaml's refresh (and fetch_standings' ttl_seconds) - keep in sync
    c.text("LIVE - UPDATES EVERY 60s".upper(), 64, 27, font = "picopixel", color = "#555555", align = "center")

def byes(c, ctx):
    draw_byes_page(c, ctx)

def al(c, ctx):
    draw_wc_series_page(c, ctx, AL_ID, "AL")

def nl(c, ctx):
    draw_wc_series_page(c, ctx, NL_ID, "NL")

def alds(c, ctx):
    draw_ds_preview_page(c, ctx, AL_ID, "AL")

def nlds(c, ctx):
    draw_ds_preview_page(c, ctx, NL_ID, "NL")

# ---------- on the bubble ----------
# The 3 teams just missing the field: ranks 4-6 in the wildCard standingsType
# block (ranks 1-3 there are the wild card holders, i.e. seeds 4-6 overall).

def wildcard_bubble3(wc_records, league_id):
    for block in wc_records:
        if block.get("league", {}).get("id") == league_id:
            return block.get("teamRecords", [])[3:6]
    return []

def bubble_gb_label(t):
    gb = t.get("wildCardGamesBack", "-")
    if gb in ("-", "", None):
        return "TIED"
    return gb + " GB"

def draw_bubble_row(c, y, team_id, left_text, right_text):
    c.rect(0, y - 1, 127, y + 5, fill = badge_color(team_id))
    c.text(left_text, 3, y, font = "4x5", color = "white", align = "left")
    c.text(right_text, 124, y, font = "4x5", color = "white", align = "right")

def draw_bubble_page(c, ctx, league_id, league_label):
    c.fill("black")

    wc_resp = fetch_standings("wildCard", ctx.now.year)
    if wc_resp["status_code"] != 200:
        c.text("DATA ERROR".upper(), 4, 12, font = "5x7", color = "red", align = "left")
        return

    bubble = wildcard_bubble3(wc_resp["json"].get("records", []), league_id)
    if len(bubble) < 3:
        c.text("NO DATA YET".upper(), 4, 12, font = "5x7", color = "gray", align = "left")
        return

    nicknames = team_nickname_map()

    c.rect(0, 0, 127, 6, fill = "white")
    c.text((league_label + " ON THE BUBBLE").upper(), 64, 1, font = "4x5", color = "black", align = "center")

    y = 9
    rank = 4
    for t in bubble:
        team_id = t.get("team", {}).get("id", -1)
        left = (str(rank) + " " + team_label(t, nicknames)).upper()
        right = bubble_gb_label(t).upper()
        draw_bubble_row(c, y, team_id, left, right)
        y += 8
        rank += 1

def albubble(c, ctx):
    draw_bubble_page(c, ctx, AL_ID, "AL")

def nlbubble(c, ctx):
    draw_bubble_page(c, ctx, NL_ID, "NL")
