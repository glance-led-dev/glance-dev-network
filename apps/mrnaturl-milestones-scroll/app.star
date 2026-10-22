# MrNaturl Milestone Watch - active MLB, NHL, NFL, NBA and MLS players closing in
# on career milestones: the next round number ("1 GOAL FROM 350") and the next
# name on the all-time list ("8 POINTS TO PASS HOWE (#7)"). Also franchise wins
# ("BILLS 1 WIN FROM 500") and head coach wins ("REID 3 WINS FROM 300").
#
# Data comes from MrNaturl's own static feed at /api/milestones.json, rebuilt
# every morning from the leagues' public stats (MLB, NHL), ESPN and Wikipedia,
# and served from Cloudflare Pages. About 6 KB, no API key, no inputs.
#
# Same app.star ships as mrnaturl-milestones (64 wide) and
# mrnaturl-milestones-scroll (192 wide). Layout branches on c.width.
#
# Every milestone reads as a sentence: gold for a round number ("1 GOAL FROM
# 350"), cyan for an all-time pass. Pixel-art balls mark the leagues.

FEED_URL = "https://mrnaturl-milestones.pages.dev/api/milestones.json"

GOLD = "#e8b020"     # round-number milestones
CYAN = "#4fb8d8"     # all-time passes
DIM = "#8a8a8a"
WHITE = "white"

TEAM_COLOR = "#6fb4ff"
COACH_COLOR = "#3fc8a8"

LEAGUE_COLOR = {
    "MLB": "#e8463c",
    "NHL": "#c8d0d8",
    "NFL": "#3fb950",
    "NBA": "#f08c28",
    "MLS": "#b48cff",
}

# --- pixel art --------------------------------------------------------------
# 9x9 sprites, one per league plus teams (trophy) and coaches (clipboard).
# Each letter is a color from PALETTE; "." is transparent.

PALETTE = {
    "W": "#f2f2f2",   # ball white
    "w": "#a8a8a8",   # ball shade
    "R": "#e8463c",   # baseball stitches
    "O": "#f08c28",   # basketball
    "o": "#b85a10",   # basketball shade
    "k": "#1a1a1a",   # seams
    "B": "#8a4a22",   # football
    "b": "#5e3014",   # football shade
    "S": "#c8d0d8",   # stick / rim
    "G": "#5a6068",   # puck side
    "g": "#8a9098",   # puck top
    "Y": "#e8b020",   # trophy
    "y": "#a87810",   # trophy shade
    "C": "#a06a3a",   # clipboard
    "P": "#e8e8e8",   # paper
    "L": "#4fb8d8",   # play lines
    "M": "#8a8a8a",   # clip
}

SPRITES = {
    "MLB": [
        "..WWWWW..",
        ".RWWWWWR.",
        "WWRWWWRWW",
        "WWRWWWRWW",
        "WWRWWWRWW",
        "WWRWWWRWw",
        "WWRWWWRww",
        ".RWWWWRw.",
        "..WWwww..",
    ],
    "NBA": [
        "..OOkOO..",
        ".kOOkOOk.",
        "OOkOkOkOO",
        "OOkOkOkOO",
        "kkkkkkkkk",
        "OOkOkOkOo",
        "OOkOkOkoo",
        ".kOOkOko.",
        "..OOkoo..",
    ],
    "NFL": [
        ".........",
        "...BBB...",
        ".BBBBBBB.",
        "BBWBWBWBB",
        "BBWWWWWBb",
        "BBBBBBBbb",
        ".BBBBbbb.",
        "...bbb...",
        ".........",
    ],
    "NHL": [
        "........S",
        ".......S.",
        "......S..",
        ".....S...",
        "SSSSS....",
        ".........",
        "..ggggg..",
        ".GgggggG.",
        "..GGGGG..",
    ],
    "MLS": [
        "..WWkWW..",
        ".WWkkkWW.",
        "WWWWkWWWW",
        "kWWWWWWWk",
        "kkWWkWWkk",
        "kWWkkkWWw",
        "WWWWkWWww",
        ".WkWWWkw.",
        "..kkwww..",
    ],
    "TEAM": [
        ".YYYYYYY.",
        "YYYYYYYyY",
        "Y.YYYYy.Y",
        ".YYYYYy..",
        "..YYYy...",
        "...YYy...",
        "....Y....",
        "..YYYyy..",
        "..YYYyy..",
    ],
    "COACH": [
        "...MMM...",
        ".CCMMMCC.",
        ".CPPPPPC.",
        ".CPLPPPC.",
        ".CPPLPPC.",
        ".CPPPLPC.",
        ".CPLPPLC.",
        ".CPPPPPC.",
        ".CCCCCCC.",
    ],
}

# 5x5 versions for the page headers.
MINI = {
    "MLB": [".WWW.", "RWWWR", "RWWWR", "RWWWw", ".WWw."],
    "NBA": [".OkO.", "kOkOk", "kkkkk", "kOkOo", ".Oko."],
    "NFL": [".BBB.", "BWBWB", "BWWWb", ".BBb.", "....."],
    "NHL": ["....S", "SSSS.", ".....", ".ggg.", "GGGGG"],
    "MLS": [".WkW.", "WkkkW", "kWWWk", "WWkWw", ".kww."],
    "TEAM": ["YYYYY", "YYYYy", ".YYy.", "..Y..", ".YYy."],
    "COACH": [".CMC.", "CPPPC", "CPLPC", "CLPLC", "CCCCC"],
}

def draw_sprite(c, key, x, y, scale, sprites = SPRITES):
    rows = sprites.get(key)
    if rows == None:
        return
    for j in range(len(rows)):
        row = rows[j]
        for i in range(len(row)):
            ch = row[i]
            if ch == ".":
                continue
            col = PALETTE[ch]
            if scale == 1:
                c.pixel(x + i, y + j, col)
            else:
                c.rect(x + i * scale, y + j * scale, x + i * scale + scale - 1,
                       y + j * scale + scale - 1, fill = col)

def sprite_key(item):
    kind = item.get("t", "")
    if kind == "team":
        return "TEAM"
    if kind == "coach":
        return "COACH"
    return item.get("lg", "")

# --- data and text helpers --------------------------------------------------

def get_data():
    resp = http.get(FEED_URL, ttl_seconds = 3600)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def wide(c):
    return c.width >= 128

def margin(c):
    if wide(c):
        return 8
    return 0

def fit(c, text, font, maxw):
    if maxw <= 0:
        return ""
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i].rstrip(" ") + "."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return ""

def small(c, text, x, y, maxw, color, align = "left"):
    # 4x5 when it fits, else the narrower (same height) picopixel, else cut.
    font = "4x5"
    if c.text_width(text, font) > maxw:
        font = "picopixel"
    c.text(fit(c, text, font, maxw), x, y, font = font, color = color,
           align = align)

def pick_font(c, text, fonts, maxw):
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return f
    return fonts[len(fonts) - 1]

def kind_color(item):
    if item.get("k", "r") == "p":
        return CYAN
    return GOLD

def split_line(item):
    # Break the feed's sentence into two halves that each read on their own:
    # "13 REC YDS FROM 8,000"      -> "13 REC YDS",  "FROM 8,000"
    # "4 K TO PASS VERLANDER (#8)" -> "4 K TO PASS", "VERLANDER #8"
    w = clean(item["w"])
    cut = w.find(" TO PASS ")
    if cut > 0:
        return [w[:cut + 8], w[cut + 9:]]
    cut = w.find(" FROM ")
    if cut > 0:
        return [w[:cut], w[cut + 1:]]
    return [w, ""]

def clean(text):
    # "(#8)" -> "#8"
    return text.replace("(#", "#").replace(")", "")

def drop_rank_clean(text):
    cut = text.rfind(" #")
    if cut > 0:
        return text[:cut]
    return text

def in_season(data, item):
    if "s" in item:
        return item["s"]
    return data.get("leagues", {}).get(item.get("lg", ""), {}).get("season", True)

def pace_text(data, item):
    if not in_season(data, item):
        return "NEXT SEASON"
    g = item.get("g", 1)
    n = int(g)
    if g > n:
        n += 1
    if n <= 1:
        return "NEXT GAME"
    return "IN ABOUT " + str(n) + " GAMES"

# --- shared screens ---------------------------------------------------------

def draw_no_data(c):
    c.clear()
    if wide(c):
        draw_sprite(c, "TEAM", 8, 7, 2)
        c.text("MILESTONE WATCH", 34, 5, font = "7x12", color = GOLD)
        c.text("FEED UNAVAILABLE", 34, 19, font = "4x5", color = DIM)
        c.text("CHECK BACK SOON", 34, 25, font = "4x5", color = DIM)
    else:
        draw_sprite(c, "TEAM", 1, 1, 1)
        c.text("MILESTONES", 12, 3, font = "4x5", color = GOLD)
        c.text("NO DATA", 32, 15, font = "4x5", color = DIM, align = "center")
        c.text("TRY LATER", 32, 22, font = "4x5", color = DIM, align = "center")

def draw_header(c, key, label, right, color):
    # Sprite + colored label on black, optional note on the right.
    left = margin(c)
    edge = c.width - 1 - margin(c)
    draw_sprite(c, key, left, 1, 1, MINI)
    c.text(label, left + 7, 1, font = "4x5", color = color)
    if right != "":
        lw = c.text_width(label, "4x5")
        if left + 7 + lw + 6 + c.text_width(right, "4x5") <= edge:
            c.text(right, edge + 1, 1, font = "4x5", color = DIM,
                   align = "right")
    c.line(left, 7, edge, 7, color = color)

def draw_empty(c, msg):
    c.text(msg, c.width // 2, 18, font = "4x5", color = DIM, align = "center")

# --- next up (the hero) -----------------------------------------------------
# Reads top to bottom: who, what they need, and how soon.

def next_up(c, ctx):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    item = data.get("next")
    if item == None:
        if wide(c):
            draw_sprite(c, "TEAM", 8, 7, 2)
            c.text("ALL CLEAR", 34, 5, font = "7x12", color = WHITE)
            c.text("NO MILESTONES CLOSE", 34, 22, font = "4x5", color = DIM)
        else:
            draw_header(c, "TEAM", "MILESTONES", "", GOLD)
            c.text("ALL CLEAR", 32, 13, font = "5x7", color = WHITE,
                   align = "center")
            c.text("NONE CLOSE", 32, 23, font = "4x5", color = DIM,
                   align = "center")
        return
    if wide(c):
        next_up_wide(c, data, item)
    else:
        next_up_narrow(c, data, item)

def next_up_wide(c, data, item):
    lg = item["lg"]
    left = margin(c)
    edge = c.width - 1 - margin(c)

    # League ball, 2x, with the league under it.
    draw_sprite(c, sprite_key(item), left, 2, 2)
    c.text(lg, left + 9, 25, font = "4x5", color = LEAGUE_COLOR.get(lg, WHITE),
           align = "center")

    tx = left + 26
    room = edge - tx + 1
    name = item["name"]
    if c.text_width(name, "6x8") > room:
        name = item["last"]
    nf = pick_font(c, name, ["7x12", "6x8"], room)
    ny = 2
    if nf == "6x8":
        ny = 4
    c.text(fit(c, name, nf, room), tx, ny, font = nf, color = WHITE)

    # The milestone as one sentence, biggest font that holds it.
    line = clean(item["w"])
    if c.text_width(line, "5x7") > room:
        line = drop_rank_clean(line)
    lf = pick_font(c, line, ["5x7", "4x5"], room)
    ly = 16
    if lf == "4x5":
        ly = 17
    c.text(fit(c, line, lf, room), tx, ly, font = lf, color = kind_color(item))

    small(c, "CLOSEST MILESTONE - " + pace_text(data, item), tx, 26, room, DIM)

def next_up_narrow(c, data, item):
    lg = item["lg"]
    draw_header(c, sprite_key(item), lg + " UP NEXT", "",
                LEAGUE_COLOR.get(lg, WHITE))

    last = item["last"]
    f = pick_font(c, last, ["6x8", "5x7", "4x5"], 63)
    ny = 10
    if f == "4x5":
        ny = 11
    c.text(fit(c, last, f, 63), 1, ny, font = f, color = WHITE)

    halves = split_line(item)
    second = halves[1]
    if c.text_width(second, "4x5") > 63:
        second = drop_rank_clean(second)
    color = kind_color(item)
    small(c, halves[0], 1, 20, 63, color)
    small(c, second, 1, 26, 63, color)

# --- league pages -----------------------------------------------------------

def draw_rows(c, items, tag):
    # tag = True puts the league on each row (teams and coaches pages).
    left = margin(c)
    edge = c.width - 1 - margin(c)

    if wide(c):
        # Four sentences: [league ball] NAME  4 K TO PASS VERLANDER #8
        rows = [9, 15, 21, 27]
        n = min(len(items), 4)
        name_w = 0
        for i in range(n):
            w = c.text_width(items[i]["last"], "4x5")
            if w > name_w:
                name_w = w
        if name_w > 60:
            name_w = 60
        name_x = left + 1
        if tag:
            name_x = left + 8
        text_x = name_x + name_w + 6
        room = edge - text_x + 1
        for i in range(n):
            it = items[i]
            y = rows[i]
            if tag:
                draw_sprite(c, it["lg"], left, y, 1, MINI)
            c.text(fit(c, it["last"], "4x5", name_w), name_x, y,
                   font = "4x5", color = WHITE)
            line = clean(it["w"])
            if c.text_width(line, "4x5") > room:
                line = drop_rank_clean(line)
            c.text(fit(c, line, "4x5", room), text_x, y, font = "4x5",
                   color = kind_color(it))
    else:
        # Two per page: NAME, then the milestone under it.
        tops = [9, 21]
        for i in range(min(len(items), 2)):
            it = items[i]
            y = tops[i]
            namew = 63
            if tag:
                right = it["lg"]
                c.text(right, 64, y, font = "4x5",
                       color = LEAGUE_COLOR.get(right, WHITE), align = "right")
                namew = 63 - c.text_width(right, "4x5") - 3
            small(c, it["last"], 1, y, namew, WHITE)
            small(c, short_line(c, it, 63), 1, y + 6, 63, kind_color(it))

def short_line(c, it, room):
    # Longest version of the milestone that fits on one 64-wide line.
    full = drop_rank_clean(clean(it["w"]))
    if c.text_width(full, "4x5") <= room:
        return full
    halves = split_line(it)
    if halves[1].startswith("FROM "):
        # "13 REC YDS FROM 8,000" -> "13 REC YDS TO 8,000"
        alt = halves[0] + " TO " + halves[1][5:]
        if c.text_width(alt, "4x5") <= room:
            return alt
    # "2 GAMES TO PASS COFFEY" -> "2 GP TO PASS COFFEY" -> "2 TO PASS COFFEY"
    alt = str(int(it.get("need", 0))) + " " + it["stat"] + " TO PASS " + halves[1]
    alt = drop_rank_clean(alt)
    if c.text_width(alt, "4x5") <= room:
        return alt
    return it["n"]

def draw_league(c, lg):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    info = data.get("leagues", {}).get(lg, {})
    items = info.get("items", [])
    color = LEAGUE_COLOR.get(lg, WHITE)

    right = ""
    if not info.get("season", True):
        right = "OFFSEASON"
    if wide(c):
        draw_header(c, lg, lg + " MILESTONES", right, color)
    else:
        draw_header(c, lg, lg + " CAREER", "", color)

    if len(items) == 0:
        msg = "NONE CLOSE"
        if not info.get("ok", True):
            msg = "NO DATA"
        draw_empty(c, msg)
        return
    draw_rows(c, items, False)

def draw_group(c, key, sprite, wide_label, narrow_label, color):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    items = data.get(key, [])
    if wide(c):
        draw_header(c, sprite, wide_label, "", color)
    else:
        draw_header(c, sprite, narrow_label, "", color)
    if len(items) == 0:
        draw_empty(c, "NONE CLOSE")
        return
    draw_rows(c, items, True)

def teams(c, ctx):
    draw_group(c, "teams", "TEAM", "TEAM WIN MILESTONES", "TEAM WINS",
               TEAM_COLOR)

def coaches(c, ctx):
    draw_group(c, "coaches", "COACH", "COACH WIN MILESTONES", "COACH WINS",
               COACH_COLOR)

def mlb(c, ctx):
    draw_league(c, "MLB")

def nhl(c, ctx):
    draw_league(c, "NHL")

def nfl(c, ctx):
    draw_league(c, "NFL")

def nba(c, ctx):
    draw_league(c, "NBA")

def mls(c, ctx):
    draw_league(c, "MLS")
