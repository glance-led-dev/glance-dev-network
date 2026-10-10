# MrNaturl Probable Starters - today's NHL starting goalies and MLB probable
# pitchers, with each one's season record and save percentage or ERA.
#
# Data comes from MrNaturl's own static feed at /api/starters.json, rebuilt
# every 30 minutes from the NHL's and MLB's public data and ESPN (which marks
# each goalie Confirmed or Expected), served from Cloudflare Pages. No API
# key, no inputs.
#
# Same app.star ships as mrnaturl-starters (64 wide) and
# mrnaturl-starters-scroll (192 wide), one game per page on both. The eight
# pages walk through the games still to come, NHL first, then MLB. On a night with more games than pages, the set shown
# moves along every 10 minutes so every game gets its turn. A league in its
# offseason does not appear at all.

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

def fit(c, text, maxw, font = "4x5"):
    if maxw <= 0:
        return ""
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i].rstrip(" ") + "."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return ""

def name_color(lg, side):
    if lg == "MLB" or side.get("n", "") == "TBD":
        return WHITE
    if side.get("s", "") == "C":
        return GREEN
    return AMBER

# --- screens: each is one game ----------------------------------------------

def screens(c, data):
    out = []
    for lg in ["NHL", "MLB"]:
        block = data.get(lg.lower(), {})
        games = block.get("games", [])
        for i in range(len(games)):
            out.append({"lg": lg, "date": block.get("date", ""),
                        "games": [games[i]]})
    return out

def pick(c, ctx, data, page):
    scr = screens(c, data)
    n = len(scr)
    if n == 0:
        return None
    blocks = (n + PAGES - 1) // PAGES
    block = (ctx.now.unix // ROTATE_SECONDS) % blocks
    return scr[(block * PAGES + page) % n]

# --- logos ------------------------------------------------------------------

# Pixel-art team marks, shared with athlete-tracker-nhl / athlete-tracker-mlb.
LOGOS = {
    "mlb_ari": "assets/mlb_ari.png",
    "mlb_ath": "assets/mlb_ath.png",
    "mlb_atl": "assets/mlb_atl.png",
    "mlb_bal": "assets/mlb_bal.png",
    "mlb_bos": "assets/mlb_bos.png",
    "mlb_chc": "assets/mlb_chc.png",
    "mlb_chw": "assets/mlb_chw.png",
    "mlb_cin": "assets/mlb_cin.png",
    "mlb_cle": "assets/mlb_cle.png",
    "mlb_col": "assets/mlb_col.png",
    "mlb_det": "assets/mlb_det.png",
    "mlb_hou": "assets/mlb_hou.png",
    "mlb_kc": "assets/mlb_kc.png",
    "mlb_laa": "assets/mlb_laa.png",
    "mlb_lad": "assets/mlb_lad.png",
    "mlb_mia": "assets/mlb_mia.png",
    "mlb_mil": "assets/mlb_mil.png",
    "mlb_min": "assets/mlb_min.png",
    "mlb_nym": "assets/mlb_nym.png",
    "mlb_nyy": "assets/mlb_nyy.png",
    "mlb_phi": "assets/mlb_phi.png",
    "mlb_pit": "assets/mlb_pit.png",
    "mlb_sd": "assets/mlb_sd.png",
    "mlb_sea": "assets/mlb_sea.png",
    "mlb_sf": "assets/mlb_sf.png",
    "mlb_stl": "assets/mlb_stl.png",
    "mlb_tb": "assets/mlb_tb.png",
    "mlb_tex": "assets/mlb_tex.png",
    "mlb_tor": "assets/mlb_tor.png",
    "mlb_wsh": "assets/mlb_wsh.png",
    "nhl_ana": "assets/nhl_ana.png",
    "nhl_bos": "assets/nhl_bos.png",
    "nhl_buf": "assets/nhl_buf.png",
    "nhl_car": "assets/nhl_car.png",
    "nhl_cbj": "assets/nhl_cbj.png",
    "nhl_cgy": "assets/nhl_cgy.png",
    "nhl_chi": "assets/nhl_chi.png",
    "nhl_col": "assets/nhl_col.png",
    "nhl_dal": "assets/nhl_dal.png",
    "nhl_det": "assets/nhl_det.png",
    "nhl_edm": "assets/nhl_edm.png",
    "nhl_fla": "assets/nhl_fla.png",
    "nhl_la": "assets/nhl_la.png",
    "nhl_min": "assets/nhl_min.png",
    "nhl_mtl": "assets/nhl_mtl.png",
    "nhl_nj": "assets/nhl_nj.png",
    "nhl_nsh": "assets/nhl_nsh.png",
    "nhl_nyi": "assets/nhl_nyi.png",
    "nhl_nyr": "assets/nhl_nyr.png",
    "nhl_ott": "assets/nhl_ott.png",
    "nhl_phi": "assets/nhl_phi.png",
    "nhl_pit": "assets/nhl_pit.png",
    "nhl_sea": "assets/nhl_sea.png",
    "nhl_sj": "assets/nhl_sj.png",
    "nhl_stl": "assets/nhl_stl.png",
    "nhl_tb": "assets/nhl_tb.png",
    "nhl_tor": "assets/nhl_tor.png",
    "nhl_utah": "assets/nhl_utah.png",
    "nhl_van": "assets/nhl_van.png",
    "nhl_vgk": "assets/nhl_vgk.png",
    "nhl_wpg": "assets/nhl_wpg.png",
    "nhl_wsh": "assets/nhl_wsh.png",
}

LOGO_SIZE = {
    "mlb_ari": (19, 16),
    "mlb_ath": (23, 19),
    "mlb_atl": (20, 19),
    "mlb_bal": (20, 19),
    "mlb_bos": (13, 19),
    "mlb_chc": (19, 19),
    "mlb_chw": (14, 19),
    "mlb_cin": (26, 18),
    "mlb_cle": (12, 19),
    "mlb_col": (16, 19),
    "mlb_det": (13, 19),
    "mlb_hou": (19, 19),
    "mlb_kc": (19, 19),
    "mlb_laa": (12, 19),
    "mlb_lad": (13, 19),
    "mlb_mia": (23, 18),
    "mlb_mil": (17, 19),
    "mlb_min": (18, 19),
    "mlb_nym": (13, 19),
    "mlb_nyy": (17, 19),
    "mlb_phi": (14, 19),
    "mlb_pit": (13, 19),
    "mlb_sd": (14, 19),
    "mlb_sea": (12, 19),
    "mlb_sf": (13, 19),
    "mlb_stl": (15, 19),
    "mlb_tb": (22, 19),
    "mlb_tex": (17, 19),
    "mlb_tor": (24, 19),
    "mlb_wsh": (24, 19),
    "nhl_ana": (23, 19),
    "nhl_bos": (19, 19),
    "nhl_buf": (19, 19),
    "nhl_car": (26, 16),
    "nhl_cbj": (23, 18),
    "nhl_cgy": (22, 19),
    "nhl_chi": (26, 19),
    "nhl_col": (25, 19),
    "nhl_dal": (23, 19),
    "nhl_det": (26, 19),
    "nhl_edm": (19, 19),
    "nhl_fla": (22, 19),
    "nhl_la": (26, 19),
    "nhl_min": (26, 17),
    "nhl_mtl": (26, 18),
    "nhl_nj": (19, 19),
    "nhl_nsh": (26, 16),
    "nhl_nyi": (19, 19),
    "nhl_nyr": (20, 19),
    "nhl_ott": (24, 19),
    "nhl_phi": (19, 13),
    "nhl_pit": (20, 19),
    "nhl_sea": (15, 19),
    "nhl_sj": (26, 19),
    "nhl_stl": (24, 19),
    "nhl_tb": (21, 19),
    "nhl_tor": (25, 19),
    "nhl_utah": (26, 17),
    "nhl_van": (20, 19),
    "nhl_vgk": (14, 19),
    "nhl_wpg": (19, 19),
    "nhl_wsh": (26, 19),
}

# The feed uses the leagues' own abbreviations; the logo files use ESPN's.
LOGO_ALIAS = {
    "nhl_lak": "nhl_la", "nhl_njd": "nhl_nj", "nhl_tbl": "nhl_tb",
    "nhl_sjs": "nhl_sj", "nhl_uta": "nhl_utah", "nhl_vgs": "nhl_vgk",
    "mlb_cws": "mlb_chw", "mlb_az": "mlb_ari", "mlb_oak": "mlb_ath",
    "mlb_was": "mlb_wsh", "mlb_tbr": "mlb_tb", "mlb_kcr": "mlb_kc",
    "mlb_sdp": "mlb_sd", "mlb_sfg": "mlb_sf",
}

def logo_key(lg, ab):
    k = lg.lower() + "_" + ab.lower()
    k = LOGO_ALIAS.get(k, k)
    return k if k in LOGOS else ""

def draw_logo(c, lg, ab, x, y, w, h, align):
    # Team mark inside the box x,y,w,h; the abbreviation if there is no mark.
    # Returns the width drawn.
    k = logo_key(lg, ab)
    if k == "":
        lw, lh = c.text_width(ab, "6x8"), 8
    else:
        lw, lh = LOGO_SIZE[k]
    lx = x + (w - lw) // 2
    if align == "left":
        lx = x
    elif align == "right":
        lx = x + w - lw
    ly = y + (h - lh) // 2
    if k == "":
        c.text(ab, lx, ly, font = "6x8", color = TEAM)
    else:
        c.image(LOGOS[k], lx, ly)
    return lw

# --- drawing ----------------------------------------------------------------

def status(lg, side):
    if lg == "MLB":
        h = side.get("h", "")
        return h + "HP" if h != "" else ""
    if side.get("n", "") == "TBD":
        return ""
    return "CONFIRMED" if side.get("s", "") == "C" else "EXPECTED"

def time_color(g):
    return GREEN if g.get("t", "") == "LIVE" else WHITE

def draw_wide(c, s):
    # Face-off: away logo far left, home logo far right, each starter's
    # name, record, stat and status facing the middle, game time between.
    lg = s["lg"]
    g = s["games"][0]
    away = g.get("away", {})
    home = g.get("home", {})
    left = 6
    right = c.width - 1 - left
    box = 26
    draw_logo(c, lg, away.get("ab", ""), left, 1, box, 21, "center")
    draw_logo(c, lg, home.get("ab", ""), right - box + 1, 1, box, 21, "center")
    c.text(away.get("ab", ""), left + box // 2, 25, font = "4x5", color = DIM,
           align = "center")
    c.text(home.get("ab", ""), right - box // 2 + 1, 25, font = "4x5",
           color = DIM, align = "center")

    ax = left + box + 5
    hx = right - box - 5
    namew = (hx - ax - 6) // 2
    lab = "SV" if lg == "NHL" else "ERA"
    sides = [[away, ax, "left"], [home, hx, "right"]]
    for side, x, al in sides:
        c.text(fit(c, side.get("n", "TBD"), namew, "5x7"), x, 2, font = "5x7",
               color = name_color(lg, side), align = al)
        if side.get("r", "") != "":
            c.text(side["r"], x, 12, font = "4x5", color = WHITE, align = al)
            v = side.get("v", "")
            vw = c.text_width(v, "4x5")
            lw = c.text_width(lab, "4x5")
            if al == "left":
                c.text(v, x, 19, font = "4x5", color = WHITE)
                c.text(lab, x + vw + 3, 19, font = "4x5", color = DIM)
            else:
                c.text(lab, x, 19, font = "4x5", color = DIM, align = "right")
                c.text(v, x - lw - 3, 19, font = "4x5", color = WHITE,
                       align = "right")
        st = status(lg, side)
        if st != "":
            col = DIM if lg == "MLB" else name_color(lg, side)
            c.text(st, x, 26, font = "4x5", color = col, align = al)

    cx = (ax + hx) // 2
    c.text(g.get("t", ""), cx, 11, font = "5x7", color = time_color(g),
           align = "center")
    c.text(s["date"], cx, 20, font = "4x5", color = DIM, align = "center")
    c.text(lg, cx, 26, font = "4x5", color = NHL_C if lg == "NHL" else MLB_C,
           align = "center")

def draw_small(c, s):
    # Logo vs logo on top with the game time between, then one row per
    # starter: name (green/amber = confirmed/expected goalie) and stat.
    lg = s["lg"]
    g = s["games"][0]
    away = g.get("away", {})
    home = g.get("home", {})
    aw = draw_logo(c, lg, away.get("ab", ""), 0, 0, 30, 19, "left")
    hw = draw_logo(c, lg, home.get("ab", ""), 34, 0, 30, 19, "right")
    gap_l = aw
    gap_r = 64 - hw
    cx = (gap_l + gap_r) // 2
    t = g.get("t", "")
    font = "4x5" if c.text_width(t, "4x5") <= gap_r - gap_l - 2 else "3x4"
    c.text(t, cx, 4, font = font, color = time_color(g), align = "center")
    c.text("@", cx, 11, font = "4x5", color = DIM, align = "center")
    rows = [away, home]
    for j in range(2):
        side = rows[j]
        yy = 20 + 6 * j
        stat = side.get("v", "")
        w = c.text_width(stat, "4x5") if stat != "" else 0
        if stat != "":
            c.text(stat, 63, yy, font = "4x5", color = WHITE, align = "right")
        c.text(fit(c, side.get("n", "TBD"), 62 - w - 3), 1, yy, font = "4x5",
               color = name_color(lg, side))

def draw_empty(c, data):
    # No games left to show. Leagues in their offseason are left out; if
    # both are, the panel says so once.
    lines = []
    for lg in ["NHL", "MLB"]:
        note = data.get(lg.lower(), {}).get("note", "") or "NO GAMES TODAY"
        if note != "OFFSEASON":
            lines.append([lg, note])
    title = "PROBABLE STARTERS" if wide(c) else "STARTERS"
    cx = c.width // 2
    c.text(title, cx, 2, font = "6x8", color = WHITE, align = "center")
    if len(lines) == 0:
        c.text("OFFSEASON", cx, 17, font = "4x5", color = DIM, align = "center")
        return
    ys = [15, 23] if len(lines) == 2 else [19]
    for i in range(len(lines)):
        lg = lines[i][0]
        note = lines[i][1]
        gap = "  "
        if not wide(c):
            note = note.replace("NO GAMES TODAY", "NO GAMES")
            gap = " "
        color = NHL_C if lg == "NHL" else MLB_C
        c.text(fit(c, lg + gap + note, c.width - 2), cx, ys[i], font = "4x5",
               color = color, align = "center")

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
