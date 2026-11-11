# NFL DK Live: live DraftKings fantasy points from the glance-nfl-dk backend.
#
# Every page makes the SAME http.get (same url, params, headers), so one
# render fetches once and pages 2-5 are cache hits that agree on the data.
# Page N shows players 2N-1 and 2N (top 10 over 5 pages); with fewer
# players the pages wrap around.
# Every API value is checked before it reaches a c.* call, and every page
# always draws something (a page that errors shows black on the board).

BASE_URL = "https://glance.mdhoria.net"
TTL_SECONDS = 60
SHOW = 10

POSITIONS = ["ALL", "QB", "RB", "WR", "TE", "DST"]
GREEN = "#2EE86A"
AMBER = "#FFB020"
WHITE = "#FFFFFF"
DIM = "#8A8A8A"
RED = "#FF4040"

NUM_R = 190
PER_PAGE = 2

SAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,:/-+#()"

# Sample rows for the labelled DEMO screen (no key entered). Statuses are
# FINAL or SAMPLE so the demo never looks like a stale live game.
DEMO = {"updated": "", "week": 0, "players": [
    {"name": "D.MAYE", "team": "NE", "pos": "QB", "dk": 31.4, "status": "FINAL", "state": "post"},
    {"name": "J.ALLEN", "team": "BUF", "pos": "QB", "dk": 28.2, "status": "SAMPLE", "state": "in"},
    {"name": "B.ROBINSON", "team": "ATL", "pos": "RB", "dk": 27.5, "status": "FINAL", "state": "post"},
    {"name": "L.BURDEN", "team": "CHI", "pos": "WR", "dk": 26.7, "status": "FINAL", "state": "post"},
    {"name": "C.WILLIAMS", "team": "CHI", "pos": "QB", "dk": 25.1, "status": "FINAL", "state": "post"},
    {"name": "J.CHASE", "team": "CIN", "pos": "WR", "dk": 22.9, "status": "SAMPLE", "state": "in"},
    {"name": "S.BARKLEY", "team": "PHI", "pos": "RB", "dk": 19.8, "status": "FINAL", "state": "post"},
    {"name": "T.KELCE", "team": "KC", "pos": "TE", "dk": 15.3, "status": "FINAL", "state": "post"},
    {"name": "BUF DST", "team": "BUF", "pos": "DST", "dk": 9.0, "status": "SAMPLE", "state": "in"},
    {"name": "NE DST", "team": "NE", "pos": "DST", "dk": 4.0, "status": "FINAL", "state": "post"},
]}

def clean(v, n = 24):
    if type(v) != "string":
        return ""
    s = "".join([ch if ch in SAFE else " " for ch in v[:60].upper().elems()])
    return " ".join(s.split())[:n]

def fit(c, s, font, maxw):
    if c.text_width(s, font) <= maxw:
        return s
    for n in range(len(s) - 1, 0, -1):
        if c.text_width(s[:n] + ".", font) <= maxw:
            return s[:n] + "."
    return ""

def pts(v):
    if type(v) == "int":
        return str(v) + ".0"
    if type(v) == "float":
        x = int(v * 10 + (0.5 if v >= 0 else -0.5))
        sign = "-" if x < 0 else ""
        x = -x if x < 0 else x
        return sign + str(x // 10) + "." + str(x % 10)
    return "--"

def message(c, title, detail, color, demo = False):
    c.fill("black")
    c.rect(2, 3, 3, 26, fill = color)
    c.text("NFL DK LIVE" + (" / DEMO" if demo else ""), 10, 3, font = "4x5", color = DIM)
    c.text(title, 10, 11, font = "6x8", color = color)
    c.text(detail, 10, 23, font = "4x5", color = WHITE)

def fetch_data(ctx):
    # Returns [data, error, demo]. data is None when there is nothing to show.
    screen = str(ctx.inputs.get("screen", "LIVE")).strip().upper()
    key = ctx.inputs.get("apikey", "")
    key = key.strip() if type(key) == "string" else ""
    if screen == "LIVE" and not key:
        screen = "DEMO"
    if screen == "DEMO":
        return [DEMO, "", True]
    if screen == "ERROR":
        return [None, "SERVER DOWN", True]
    if screen == "NO GAMES":
        return [{"players": []}, "", True]

    names = ctx.inputs.get("players", "")
    names = ",".join([clean(n, 20) for n in names.split(",") if clean(n, 20)][:SHOW]) if type(names) == "string" else ""
    if names:
        url = BASE_URL + "/v1/players"
        params = {"names": names}
    else:
        pos = str(ctx.inputs.get("position", "ALL")).strip().upper()
        if pos not in POSITIONS:
            pos = "ALL"
        url = BASE_URL + "/v1/top"
        params = {"n": str(SHOW), "pos": "" if pos == "ALL" else pos}
    resp = http.get(url, params = params, headers = {"x-api-key": key}, ttl_seconds = TTL_SECONDS)
    code = resp.get("status_code") if type(resp) == "dict" else None
    if code in [401, 403]:
        return [None, "BAD API KEY", False]
    if code == 429:
        return [None, "RATE LIMITED", False]
    if code != 200:
        return [None, "SERVER DOWN", False]
    data = resp.get("json")
    if type(data) != "dict" or type(data.get("players")) != "list":
        return [None, "BAD DATA", False]
    return [data, "", False]

def players_of(data):
    out = []
    for p in data["players"]:
        if type(p) == "dict" and clean(p.get("name")) and type(p.get("dk")) in ["int", "float"]:
            out.append(p)
    out = sorted(out, key = lambda p: -p["dk"])
    return out[:SHOW]

def draw_row(c, p, rank, y, demo):
    # One 16px row: state bar | name / "#rank TEAM POS STATUS" | big DK number.
    name = clean(p.get("name"), 16)
    team = clean(p.get("team"), 4)
    pos = clean(p.get("pos"), 4)
    status = clean(p.get("status"), 20)
    live = p.get("state") == "in"
    color = AMBER if live else GREEN

    shown = pts(p["dk"])
    font = "11x14" if c.text_width(shown, "11x14") <= 56 else "9x12"
    c.text(shown, NUM_R, y + 1, font = font, color = color, align = "right")
    room = NUM_R - c.text_width(shown, font) - 4 - 5

    c.rect(0, y + 1, 2, 14, fill = color)
    c.text(fit(c, name, "6x8", room), 5, y + 1, font = "6x8", color = WHITE)
    tag = " ".join([x for x in ["#" + str(rank), team, pos, ("LIVE " + status) if live else status] if x])
    if demo:
        tag = "DEMO " + tag
    c.text(fit(c, tag, "4x5", room), 5, y + 10, font = "4x5", color = AMBER if demo else DIM)

def page(c, ctx, i):
    got = fetch_data(ctx)
    data = got[0]
    if data == None:
        detail = "CHECK KEY IN SETTINGS" if got[1] == "BAD API KEY" else "TRY AGAIN SOON"
        message(c, got[1], detail, RED, got[2])
        return
    ps = players_of(data)
    if not ps:
        message(c, "NO LIVE GAMES", "DK POINTS SHOW ON GAME DAY", AMBER, got[2])
        return
    pairs = (len(ps) + PER_PAGE - 1) // PER_PAGE
    first = (i % pairs) * PER_PAGE
    c.fill("black")
    for k in range(PER_PAGE):
        if first + k < len(ps):
            draw_row(c, ps[first + k], first + k + 1, k * 16, got[2])

def splash(c, ctx):
    # Title page: same cached request as the player pages, so it costs no fetch.
    got = fetch_data(ctx)
    data = got[0]
    sub = "LEADERS"
    if got[2] and data != None and data.get("players"):
        sub = "LEADERS - DEMO"
    elif data != None and data.get("players"):
        wk = data.get("week")
        if type(wk) == "int" and wk > 0:
            sub = "LEADERS - NFL WEEK " + str(wk)
    c.fill("black")
    c.rect(10, 3, 3, 26, fill = GREEN)
    top = "DK FANTASY POINTS"
    font = "9x12" if c.text_width(top, "9x12") <= 162 else "6x8"
    c.text(top, 17, 3, font = font, color = WHITE)
    c.text(fit(c, sub, "6x8", 164), 17, 20, font = "6x8", color = AMBER if got[2] and data != None and data.get("players") else GREEN)

def p1(c, ctx):
    page(c, ctx, 0)

def p2(c, ctx):
    page(c, ctx, 1)

def p3(c, ctx):
    page(c, ctx, 2)

def p4(c, ctx):
    page(c, ctx, 3)

def p5(c, ctx):
    page(c, ctx, 4)
