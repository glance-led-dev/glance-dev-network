# MrNaturl Probable Starters - today's NHL starting goalies and MLB probable
# pitchers, with each one's season record and save percentage or ERA.
#
# Data comes from MrNaturl's own static feed at /api/starters.json, rebuilt
# every 30 minutes from the NHL's and MLB's public data and ESPN (which marks
# each goalie Confirmed or Expected), served from Cloudflare Pages. No API
# key, no inputs.
#
# Same app.star ships as mrnaturl-starters (64 wide) and
# mrnaturl-starters-scroll (192 wide). The Scroll shows two games per page,
# the Glance LED one. The eight pages walk through the games still to come,
# NHL first, then MLB. On a night with more games than pages, the set shown
# moves along every 10 minutes so every game gets its turn.

FEED_URL = "https://mrnaturl-starters.pages.dev/api/starters.json"

GREEN = "#3fb950"    # goalie confirmed
AMBER = "#e8b020"    # goalie expected
DIM = "#8a8a8a"
RULE = "#5a6270"
WHITE = "white"
TEAM = "#8fb8ff"
NHL_C = "#c8d0d8"
MLB_C = "#e8463c"

PAGES = 8
ROTATE_SECONDS = 600

def get_data():
    resp = http.get(FEED_URL, ttl_seconds = 300)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def wide(c):
    return c.width >= 128

def fit(c, text, maxw):
    if maxw <= 0:
        return ""
    if c.text_width(text, "4x5") <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i].rstrip(" ") + "."
        if c.text_width(candidate, "4x5") <= maxw:
            return candidate
    return ""

def name_color(lg, side):
    if lg == "MLB" or side.get("n", "") == "TBD":
        return WHITE
    if side.get("s", "") == "C":
        return GREEN
    return AMBER

def player(lg, side):
    nm = side.get("n", "TBD")
    if lg == "MLB" and side.get("h", "") != "":
        nm = nm + " " + side["h"]
    return nm

# --- screens: each is one league and one or two games -----------------------

def screens(c, data):
    per = 2 if wide(c) else 1
    out = []
    for lg in ["NHL", "MLB"]:
        block = data.get(lg.lower(), {})
        games = block.get("games", [])
        for i in range(0, len(games), per):
            out.append({"lg": lg, "date": block.get("date", ""),
                        "games": games[i:i + per]})
    return out

def pick(c, ctx, data, page):
    scr = screens(c, data)
    n = len(scr)
    if n == 0:
        return None
    blocks = (n + PAGES - 1) // PAGES
    block = (ctx.now.unix // ROTATE_SECONDS) % blocks
    return scr[(block * PAGES + page) % n]

# --- drawing ----------------------------------------------------------------

def legend(c, edge, y):
    w = c.text_width("EXP", "4x5")
    c.text("EXP", edge, y, font = "4x5", color = AMBER, align = "right")
    c.rect(edge - w - 4, y + 1, edge - w - 2, y + 3, fill = AMBER)
    x = edge - w - 10
    w2 = c.text_width("CONF", "4x5")
    c.text("CONF", x, y, font = "4x5", color = GREEN, align = "right")
    c.rect(x - w2 - 4, y + 1, x - w2 - 2, y + 3, fill = GREEN)

def draw_wide(c, s):
    lg = s["lg"]
    left = 6
    edge = c.width - 1 - left
    title = "NHL GOALIES" if lg == "NHL" else "MLB PITCHERS"
    c.text(title + "  " + s["date"], left, 0, font = "4x5",
           color = NHL_C if lg == "NHL" else MLB_C)
    if lg == "NHL":
        legend(c, edge, 0)
    games = s["games"]
    if len(games) > 1:
        c.line(left, 19, edge, 19, color = RULE)
    lab = "SV" if lg == "NHL" else "ERA"
    tops = [7, 21]
    for i in range(len(games)):
        g = games[i]
        y = tops[i]
        for j in range(2):
            side = g.get("away", {}) if j == 0 else g.get("home", {})
            yy = y + 6 * j
            if j == 1:
                c.text("@", left, yy, font = "4x5", color = DIM)
            c.text(side.get("ab", ""), left + 6, yy, font = "4x5", color = TEAM)
            c.text(fit(c, player(lg, side), 60), left + 24, yy, font = "4x5",
                   color = name_color(lg, side))
            if side.get("r", "") != "":
                c.text(side["r"], left + 110, yy, font = "4x5", color = WHITE,
                       align = "right")
                c.text(side.get("v", ""), left + 134, yy, font = "4x5",
                       color = WHITE, align = "right")
                c.text(lab, left + 138, yy, font = "4x5", color = DIM)
        time_color = GREEN if g.get("t", "") == "LIVE" else DIM
        c.text(g.get("t", ""), edge, y, font = "4x5", color = time_color,
               align = "right")

def draw_small(c, s):
    lg = s["lg"]
    color = NHL_C if lg == "NHL" else MLB_C
    c.text("NHL GOALIES" if lg == "NHL" else "MLB PITCHERS", 1, 1,
           font = "4x5", color = color)
    c.line(0, 7, 63, 7, color = color)
    g = s["games"][0]
    away = g.get("away", {})
    home = g.get("home", {})
    c.text(away.get("ab", "") + " @ " + home.get("ab", ""), 1, 9, font = "4x5",
           color = TEAM)
    time_color = GREEN if g.get("t", "") == "LIVE" else DIM
    c.text(g.get("t", ""), 63, 9, font = "4x5", color = time_color,
           align = "right")
    rows = [away, home]
    for j in range(2):
        side = rows[j]
        yy = 17 + 7 * j
        stat = side.get("v", "")
        w = c.text_width(stat, "4x5") if stat != "" else 0
        if stat != "":
            c.text(stat, 63, yy, font = "4x5", color = DIM, align = "right")
        c.text(fit(c, side.get("n", "TBD"), 62 - w - 3), 1, yy, font = "4x5",
               color = name_color(lg, side))

def draw_empty(c, data):
    # Positive all-clear: nothing left to show today in either league.
    nhl = data.get("nhl", {}).get("note", "") or "NO GAMES TODAY"
    mlb = data.get("mlb", {}).get("note", "") or "NO GAMES TODAY"
    if wide(c):
        c.text("PROBABLE STARTERS", c.width // 2, 2, font = "6x8",
               color = WHITE, align = "center")
        c.text("NHL  " + nhl, c.width // 2, 15, font = "4x5", color = NHL_C,
               align = "center")
        c.text("MLB  " + mlb, c.width // 2, 23, font = "4x5", color = MLB_C,
               align = "center")
    else:
        c.text("STARTERS", 32, 2, font = "6x8", color = WHITE, align = "center")
        nhl = nhl.replace("NO GAMES TODAY", "NONE TODAY")
        mlb = mlb.replace("NO GAMES TODAY", "NONE TODAY")
        c.text("NHL " + fit(c, nhl, 46), 1, 15, font = "4x5", color = NHL_C)
        c.text("MLB " + fit(c, mlb, 46), 1, 23, font = "4x5", color = MLB_C)

def draw_no_data(c):
    if wide(c):
        c.text("PROBABLE STARTERS", c.width // 2, 2, font = "6x8",
               color = WHITE, align = "center")
        c.text("FEED UNAVAILABLE", c.width // 2, 16, font = "4x5", color = DIM,
               align = "center")
        c.text("CHECK BACK SOON", c.width // 2, 23, font = "4x5", color = DIM,
               align = "center")
    else:
        c.text("STARTERS", 32, 2, font = "6x8", color = WHITE, align = "center")
        c.text("NO DATA", 32, 15, font = "4x5", color = DIM, align = "center")
        c.text("TRY LATER", 32, 22, font = "4x5", color = DIM, align = "center")

def draw_page(c, ctx, page):
    c.clear()
    data = get_data()
    if data == None:
        draw_no_data(c)
        return
    s = pick(c, ctx, data, page)
    if s == None:
        draw_empty(c, data)
        return
    if wide(c):
        draw_wide(c, s)
    else:
        draw_small(c, s)

def games_1(c, ctx):
    draw_page(c, ctx, 0)

def games_2(c, ctx):
    draw_page(c, ctx, 1)

def games_3(c, ctx):
    draw_page(c, ctx, 2)

def games_4(c, ctx):
    draw_page(c, ctx, 3)

def games_5(c, ctx):
    draw_page(c, ctx, 4)

def games_6(c, ctx):
    draw_page(c, ctx, 5)

def games_7(c, ctx):
    draw_page(c, ctx, 6)

def games_8(c, ctx):
    draw_page(c, ctx, 7)
