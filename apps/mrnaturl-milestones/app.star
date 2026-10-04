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

def get_data():
    resp = http.get(FEED_URL, ttl_seconds = 3600)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def wide(c):
    return c.width >= 128

def margin(c):
    if wide(c):
        return 6
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

def fit_line(c, text, font, maxw):
    # Drop the all-time rank "(#9)" before cutting the line short.
    if c.text_width(text, font) > maxw and text.endswith(")"):
        cut = text.rfind(" (")
        if cut > 0:
            text = text[:cut]
    return fit(c, text, font, maxw)

def pick_font(c, text, choices, maxw):
    for choice in choices:
        if c.text_width(text, choice[0]) <= maxw:
            return choice
    return choices[len(choices) - 1]

def kind_color(item):
    if item.get("k", "r") == "p":
        return CYAN
    return GOLD

# --- shared screens ---------------------------------------------------------

def draw_no_data(c):
    c.clear()
    if wide(c):
        c.text("MILESTONE WATCH", c.width // 2, 4, font = "6x8", color = GOLD,
               align = "center")
        c.text("FEED UNAVAILABLE", c.width // 2, 16, font = "4x5", color = DIM,
               align = "center")
        c.text("CHECK BACK SOON", c.width // 2, 23, font = "4x5", color = DIM,
               align = "center")
    else:
        c.text("MILESTONES", 32, 4, font = "4x5", color = GOLD, align = "center")
        c.text("NO DATA", 32, 15, font = "4x5", color = DIM, align = "center")
        c.text("TRY LATER", 32, 22, font = "4x5", color = DIM, align = "center")

def draw_header(c, label, right, color):
    # Filled bar in the league color, black text on it.
    left = margin(c)
    edge = c.width - 1 - margin(c)
    c.rect(left, 0, edge, 6, fill = color)
    c.text(label, left + 2, 1, font = "4x5", color = "black")
    if right != "":
        room = edge - left - 6 - c.text_width(label, "4x5")
        if c.text_width(right, "4x5") + 4 <= room:
            c.text(right, edge - 1, 1, font = "4x5", color = "black",
                   align = "right")

# --- next up (the hero) -----------------------------------------------------

def next_up(c, ctx):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    item = data.get("next")
    if item == None:
        draw_header(c, "NEXT UP", "", GOLD)
        c.text("ALL CLEAR", c.width // 2, 12, font = "6x8", color = WHITE,
               align = "center")
        c.text("NONE CLOSE", c.width // 2, 24, font = "4x5", color = DIM,
               align = "center")
        return

    lg = item["lg"]
    color = LEAGUE_COLOR.get(lg, WHITE)
    left = margin(c)
    inner = c.width - 2 * margin(c)

    if wide(c):
        draw_header(c, "NEXT MILESTONE", lg, color)
        name = item["name"]
        choices = [["7x12", 12], ["6x8", 8]]
        if c.text_width(name, "6x8") > inner - 4:
            name = item["last"]
        chosen = pick_font(c, name, choices, inner - 4)
        c.text(fit(c, name, chosen[0], inner - 4), left + 2,
               9 + (13 - chosen[1]) // 2, font = chosen[0], color = WHITE)
        c.text(fit_line(c, item["w"], "4x5", inner - 4), left + 2, 25,
               font = "4x5", color = kind_color(item))
    else:
        draw_header(c, "NEXT UP", lg, color)
        last = item["last"]
        chosen = pick_font(c, last, [["6x8", 8], ["4x5", 6]], 62)
        c.text(fit(c, last, chosen[0], 62), 1, 9, font = chosen[0],
               color = WHITE)
        c.text(fit(c, item["n"], "4x5", 62), 1, 19, font = "4x5",
               color = kind_color(item))
        c.text(item["stat"], 1, 26, font = "4x5", color = color)

# --- league pages -----------------------------------------------------------

def draw_rows(c, items, color, tag):
    # tag = True puts the league on each row (teams and coaches pages).
    left = margin(c)
    edge = c.width - 1 - margin(c)

    if wide(c):
        # Four rows: kind marker, [league], name, then the milestone in gold
        # (round number) or cyan (all-time pass).
        rows = [9, 15, 21, 27]
        n = min(len(items), 4)
        name_w = 0
        for i in range(n):
            w = c.text_width(items[i]["last"], "4x5")
            if w > name_w:
                name_w = w
        if name_w > 56:
            name_w = 56
        name_x = left + 4
        if tag:
            name_x = left + 4 + c.text_width("MLB", "4x5") + 4
        text_x = name_x + name_w + 5
        for i in range(n):
            it = items[i]
            y = rows[i]
            c.rect(left, y, left + 1, y + 4, fill = kind_color(it))
            if tag:
                c.text(it["lg"], left + 4, y, font = "4x5",
                       color = LEAGUE_COLOR.get(it["lg"], WHITE))
            c.text(fit(c, it["last"], "4x5", name_w), name_x, y,
                   font = "4x5", color = WHITE)
            c.text(fit_line(c, it["w"], "4x5", edge - text_x), text_x, y,
                   font = "4x5", color = kind_color(it))
    else:
        # Two per page, two lines each: name and stat (or league), then
        # the milestone.
        tops = [9, 21]
        for i in range(min(len(items), 2)):
            it = items[i]
            y = tops[i]
            right = it["stat"]
            right_color = color
            if tag:
                right = it["lg"]
                right_color = LEAGUE_COLOR.get(it["lg"], WHITE)
            right_w = c.text_width(right, "4x5")
            c.text(right, 63, y, font = "4x5", color = right_color,
                   align = "right")
            c.text(fit(c, it["last"], "4x5", 60 - right_w), 1, y,
                   font = "4x5", color = WHITE)
            c.text(fit(c, it["n"], "4x5", 62), 1, y + 6, font = "4x5",
                   color = kind_color(it))

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
        draw_header(c, lg + " MILESTONES", right, color)
    else:
        draw_header(c, lg, right, color)

    if len(items) == 0:
        msg = "NONE CLOSE"
        if not info.get("ok", True):
            msg = "NO DATA"
        c.text(msg, c.width // 2, 16, font = "4x5", color = DIM,
               align = "center")
        return
    draw_rows(c, items, color, False)

def draw_group(c, key, wide_label, narrow_label, color):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    items = data.get(key, [])
    if wide(c):
        draw_header(c, wide_label, "", color)
    else:
        draw_header(c, narrow_label, "", color)
    if len(items) == 0:
        c.text("NONE CLOSE", c.width // 2, 16, font = "4x5", color = DIM,
               align = "center")
        return
    draw_rows(c, items, color, True)

def teams(c, ctx):
    draw_group(c, "teams", "TEAM MILESTONES", "TEAMS", TEAM_COLOR)

def coaches(c, ctx):
    draw_group(c, "coaches", "COACH MILESTONES", "COACHES", COACH_COLOR)

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
