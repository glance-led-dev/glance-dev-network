# Fortnite Player Tracker — a GDN Starlark app (64x32, 5 pages).
#
# DESIGN. One page per stat, not per player: WINS, K/D, WIN RATE, KILLS, and
# TOP 10S each get their own leaderboard, ranking up to 8 tracked players
# highest to lowest. 8 players is a hard ceiling, not a preference —
# ranking needs one fortnite-api.com lookup per player, and GDN hard-caps an
# app at 8 http calls per render (enforced by the runtime, not just a
# guideline), so 8 is the most this design can ever fetch in one go. All 8
# name inputs default blank, so a fresh install starts with an empty board
# rather than inheriting someone else's friend list as sample data.
#
# Kept deliberately to 5 pages — an earlier draft added a title screen and a
# pixel-art break page, but review feedback asked for something simpler, so
# both were cut in favor of just the leaderboards.
#
# 8 rows don't fit legibly on a 32px-tall screen at once (~4 fit), so each
# leaderboard splits into two halves — ranks 1-4, then 5-8 — that swap every
# render (60s is the platform's minimum refresh, so that's the fastest this
# can flip). Rank 1 gets the gold Victory Royale crown in place of a number (also
# the app's identity mark, since no game logo is used); the rest are numbered.
# The accent rail always wears the current stat's color, matching the design
# used throughout this app.
#
# Data comes from fortnite-api.com's public BR stats endpoint (Epic accounts
# only). Accuracy, headshots and "crown wins" aren't included — no current,
# legitimate Fortnite API exposes them. What's shown — wins, K/D, win rate,
# kills, top 10s — is all real, live, lifetime data.

CROWN = [
    [1, 0, 1, 0, 1],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
    [1, 1, 1, 1, 1],
]
CROWN_COLOR = "amber"

SLOTS = ["name1", "name2", "name3", "name4", "name5", "name6", "name7", "name8"]

# key into the stats dict, on-panel label, and this leaderboard's rail color.
STATS = [
    ("wins", "WINS", "amber"),
    ("kd", "K/D", "cyan"),
    ("winRate", "WIN RATE", "green"),
    ("kills", "KILLS", "orange"),
    ("top10", "TOP 10S", "purple"),
]

ROW_FONT = "4x5"
ROW_MAXW = 62  # 64 - 1px margin each side
ROWS_PER_HALF = 4
FRAME_SECONDS = 60  # matches manifest `refresh: 60` — one half flips per render
HEADER_MAXW = 62

def _fit(c, text, fonts, maxw):
    """Largest font in the ladder that fits; last resort if none do."""
    for f in fonts:
        if c.text_width(text, font = f) <= maxw:
            return f
    return fonts[-1]

def _clip(c, text, font, maxw):
    """Hard-clip a single word (Epic names have no spaces) to fit maxw."""
    if c.text_width(text, font = font) <= maxw:
        return text
    n = len(text)
    for i in range(n - 1, 0, -1):
        cand = text[:i]
        if c.text_width(cand, font = font) <= maxw:
            return cand
    return text[:1]

def _fmt_count(n):
    """Big integer counters (wins/kills/top10) compact past 10,000."""
    if n >= 10000:
        return _fmt1(n / 1000.0) + "K"
    return str(int(n))

def _fmt2(x):
    """Two decimal places without relying on %.2f float formatting."""
    v = int(x * 100 + 0.5)
    if v < 0:
        v = 0
    whole = v // 100
    frac = v % 100
    fracstr = str(frac)
    if len(fracstr) < 2:
        fracstr = "0" + fracstr
    return str(whole) + "." + fracstr

def _fmt1(x):
    """One decimal place, same trick as _fmt2."""
    v = int(x * 10 + 0.5)
    if v < 0:
        v = 0
    whole = v // 10
    frac = v % 10
    return str(whole) + "." + str(frac)

def _stat_value(d, key):
    if key == "kd":
        return _fmt2(d.get("kd", 0.0))
    if key == "winRate":
        return _fmt1(d.get("winRate", 0.0)) + "%"
    return _fmt_count(d.get(key, 0))

def fetch_stats(name, apikey):
    """One http.get per player; cached 5 min via ttl_seconds. All 5 stat pages
    read the same underlying per-player call, so once any page has fetched a
    player fresh, the rest reuse that cache for free — cache hits never count
    against the runtime's 8-calls-per-render limit, only genuine network
    fetches do."""
    resp = http.get(
        "https://fortnite-api.com/v2/stats/br/v2",
        params = {"name": name, "accountType": "epic"},
        headers = {"Authorization": apikey},
        ttl_seconds = 300,
    )
    status = resp["status_code"]
    if status == 200:
        j = resp["json"]
        data = j.get("data") if j else None
        if not data:
            return {"state": "notfound"}
        overall = data.get("stats", {}).get("all", {}).get("overall", {})
        if not overall:
            return {"state": "nostats"}
        overall["state"] = "ok"
        overall["name"] = data.get("account", {}).get("name", name)
        return overall
    if status == 401 or status == 403:
        return {"state": "badkey"}
    if status == 404:
        return {"state": "notfound"}
    return {"state": "offline"}

def make_demo(name):
    """Deterministic-per-name sample data so demo rankings are stable across
    all 5 stat pages, the same as a real leaderboard would be."""
    seed = len(name) * 7 + 13
    return {
        "state": "ok",
        "name": name,
        "wins": 30 + (seed * 11) % 300,
        "kd": 1.2 + (seed % 15) * 0.15,
        "winRate": 4 + (seed * 3) % 18,
        "kills": 800 + (seed * 97) % 12000,
        "top10": 120 + (seed * 41) % 900,
    }

def draw_crown(c, x, y):
    c.bitmap(CROWN, x, y, CROWN_COLOR)

def draw_frame(c, rail_color):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 1, fill = rail_color)

def collect_rows(ctx, stat_key):
    """One entry per non-blank player slot: (name, sort_key, display_value).
    A player whose lookup failed sorts last and shows '--' rather than
    dropping off the board entirely, so a typo'd name is visible, not silent."""
    apikey = ctx.inputs.get("apikey", "")
    demo = not apikey
    rows = []
    for slot in SLOTS:
        name = ctx.inputs.get(slot, "").strip()
        if not name:
            continue
        d = make_demo(name) if demo else fetch_stats(name, apikey)
        if d["state"] == "ok":
            raw = d.get(stat_key, 0)
            rows.append({"name": d.get("name", name), "sort": float(raw), "value": _stat_value(d, stat_key), "ok": True})
        else:
            rows.append({"name": name, "sort": -1.0, "value": "--", "ok": False, "err": d["state"]})
    rows_sorted = sorted(rows, key = lambda r: r["sort"], reverse = True)
    return rows_sorted, demo

ERROR_MESSAGES = {
    "badkey": ("BAD KEY", "CHECK SETTINGS"),
    "notfound": ("NOT FOUND", "CHECK SPELLING"),
    "nostats": ("NO MATCHES", "PLAY A GAME"),
    "offline": ("OFFLINE", "RETRY SOON"),
}

def _common_error(rows):
    """Most frequent failure reason across the roster, so one shared cause
    (a bad key, the API being down) gets one clear message instead of 8
    identical dashes with no explanation."""
    counts = {}
    for r in rows:
        e = r.get("err", "offline")
        counts[e] = counts.get(e, 0) + 1
    best, best_n = "offline", -1
    for e in ("badkey", "offline", "notfound", "nostats"):
        n = counts.get(e, 0)
        if n > best_n:
            best, best_n = e, n
    return best

def draw_row(c, y, rank, row):
    if rank == 1 and row["ok"]:
        draw_crown(c, 1, y)
        name_x = 7
    else:
        rank_str = str(rank)
        c.text(rank_str, 1, y, font = ROW_FONT, color = "gray")
        name_x = 1 + c.text_width(rank_str, font = ROW_FONT) + 2
    value_col = "white" if row["ok"] else "midgray"
    value_w = c.text_width(row["value"], font = ROW_FONT)
    c.text(row["value"], c.width - 1 - value_w, y, font = ROW_FONT, color = value_col)
    name_maxw = c.width - 1 - value_w - 2 - name_x
    name_text = _clip(c, row["name"].upper(), ROW_FONT, name_maxw)
    name_col = "white" if row["ok"] else "midgray"
    c.text(name_text, name_x, y, font = ROW_FONT, color = name_col)

def draw_empty(c):
    draw_frame(c, "midgray")
    draw_crown(c, 2, 3)
    c.text("NO PLAYERS", 9, 3, font = "4x5", color = "white")
    c.text("ADD NAMES", c.width // 2, 14, font = "6x8", color = "midgray", align = "center")
    c.text("IN SETTINGS", c.width // 2, 26, font = "picopixel", color = "gray", align = "center")

def draw_error(c, label, msg1, msg2):
    draw_frame(c, "amber")
    draw_crown(c, 2, 3)
    header = _clip(c, label, "4x5", HEADER_MAXW - 7)
    c.text(header, 9, 3, font = "4x5", color = "white")
    f1 = _fit(c, msg1, ["6x8", "5x7", "4x5"], HEADER_MAXW)
    m1 = _clip(c, msg1, f1, HEADER_MAXW)
    c.text(m1, c.width // 2, 13, font = f1, color = "amber", align = "center")
    m2 = _clip(c, msg2, "picopixel", HEADER_MAXW)
    c.text(m2, c.width // 2, 26, font = "picopixel", color = "gray", align = "center")

def render_leaderboard(c, ctx, stat_key, label, color):
    rows, demo = collect_rows(ctx, stat_key)
    if not rows:
        draw_empty(c)
        return

    if not demo and not any([r["ok"] for r in rows]):
        # Nobody resolved — one shared cause (bad key, API down), so show one
        # clear explanation instead of a leaderboard of 8 identical dashes.
        msg1, msg2 = ERROR_MESSAGES[_common_error(rows)]
        draw_error(c, label, msg1, msg2)
        return

    n = len(rows)
    frames = (n + ROWS_PER_HALF - 1) // ROWS_PER_HALF
    frame = (ctx.now.unix // FRAME_SECONDS) % frames if frames > 1 else 0
    start = frame * ROWS_PER_HALF

    draw_frame(c, color)
    # The rank numbers (1-4 vs 5-8) already signal there's a second half, so
    # the header just names the stat — no page-count tag competing for the
    # same tiny row.
    header = _clip(c, label + (" DEMO" if demo else ""), "4x5", HEADER_MAXW)
    c.text(header, 1, 2, font = "4x5", color = color)

    y = 9
    for i in range(ROWS_PER_HALF):
        idx = start + i
        if idx >= n:
            break
        draw_row(c, y, idx + 1, rows[idx])
        y += 6

def wins(c, ctx):
    render_leaderboard(c, ctx, "wins", "WINS", "amber")

def kd(c, ctx):
    render_leaderboard(c, ctx, "kd", "K/D", "cyan")

def winrate(c, ctx):
    render_leaderboard(c, ctx, "winRate", "WIN RATE", "green")

def kills(c, ctx):
    render_leaderboard(c, ctx, "kills", "KILLS", "orange")

def top10(c, ctx):
    render_leaderboard(c, ctx, "top10", "TOP 10S", "purple")
