ORANGE = "#BF5700"
WHITE = "white"
# 192-wide app: content spans x 11..179 (11px padding at the outer edges).
ART_X = 11      # art zone x 11..62
DIV_X = 66      # divider
TEXT_X = 71     # text zone x 71..179 (109px)
TEXT_W = 109
TOTAL = 3
URL = "https://site.api.espn.com/apis/site/v2/sports/football/college-football/news"
ALLOWED = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;!?'\"-+&/()#%$@"

# Filtering, tuned against real ESPN data. team=251 returns stories TAGGED to Texas, which
# includes many general stories (rankings, other teams' games). We rank them in tiers and
# fill the 3 slots from the best tier first, newest first, falling back to older or looser
# stories, so the app never shows an empty screen. No names are hardcoded.
# Tier 1: Texas is the story's first tagged team, news types only, not a list/opinion.
TYPES = ["HeadlineNews", "Recap", "Preview"]
# Headlines that start with one of these are skipped (lists, rankings, opinion).
BAD_STARTS = ["TOP ", "BEST ", "WORST ", "RANKING", "POWER RANK", "PREDICTION",
              "PICKS", "MAILBAG", "OPINION", "HOT TAKE", "WINNERS AND LOSERS", "GRADES"]
BAD_WORDS = ["TOP TROLLS", "POWER RANK", "PREDICTION", "TAKEAWAYS", "WHAT WE THINK",
             "BUBBLE WATCH", "PROJECTING", "BETTING LINES", "BEST BETS", "HOT TAKES",
             "MAILBAG", "OPINION:", "BOWL PROJECTIONS", "ODDS AFTER"]

# Texas Longhorns logo (Wikimedia Commons SVG), rasterized to 52x26: (y, x0, x1) runs.
LOGO_W = 52
LOGO_H = 26
LOGO_RUNS = [(0, 0, 5), (0, 46, 51), (1, 0, 8), (1, 43, 51), (2, 6, 10), (2, 41, 45),
             (3, 8, 11), (3, 40, 43), (4, 9, 13), (4, 38, 42), (5, 11, 15), (5, 22, 23),
             (5, 25, 26), (5, 28, 29), (5, 36, 40), (6, 12, 39), (7, 13, 38), (8, 15, 36),
             (9, 16, 35), (10, 14, 37), (11, 14, 37), (12, 20, 31), (13, 20, 31),
             (14, 21, 30), (15, 21, 30), (16, 22, 29), (17, 22, 29), (18, 23, 28),
             (19, 23, 28), (20, 23, 28), (21, 22, 29), (22, 22, 29), (23, 22, 29),
             (24, 23, 28), (25, 24, 27)]

def clean(s):
    s = s.upper()
    for a in ["\u2019", "\u2018"]:
        s = s.replace(a, "'")
    for a in ["\u201c", "\u201d"]:
        s = s.replace(a, "\"")
    for a in ["\u2013", "\u2014"]:
        s = s.replace(a, "-")
    out = ""
    for ch in s.elems():
        if ch in ALLOWED:
            out += ch
    return out

def first_team(a):
    for cat in a.get("categories", []):
        if cat.get("type", "") != "team":
            continue
        tid = cat.get("teamId", None)
        if tid != None:
            return str(tid)
        team = cat.get("team", None)
        if team != None:
            return str(team.get("id", ""))
    return ""

def is_bad(head):
    for b in BAD_STARTS:
        if head.startswith(b):
            return True
    for b in BAD_WORDS:
        if b in head:
            return True
    return False

def by_date(r):
    return r["p"]

def fetch():
    resp = http.get(URL, params={"team": "251", "limit": "50"}, ttl_seconds = 900)
    if resp["status_code"] != 200:
        return None
    rows = []
    for a in resp["json"].get("articles", []):
        head = clean(a.get("headline", ""))
        if head == "":
            continue
        rows.append({"h": head, "p": a.get("published", ""), "t": a.get("type", ""),
                     "first": first_team(a) == "251", "bad": is_bad(head)})
    tiers = [
        [r for r in rows if r["first"] and not r["bad"] and r["t"] in TYPES],
        [r for r in rows if r["first"] and not r["bad"] and r["t"] not in ["Media", "Eticket"]],
        [r for r in rows if r["first"] and not r["bad"]],
        [r for r in rows if not r["bad"]],
        rows,
    ]
    out = []
    for tier in tiers:
        for r in sorted(tier, key = by_date, reverse = True):
            if len(out) < TOTAL and r["h"] not in out:
                out.append(r["h"])
    return out

def logo(c):
    y0 = (32 - LOGO_H) // 2
    for r in LOGO_RUNS:
        c.rect(ART_X + r[1], y0 + r[0], ART_X + r[2], y0 + r[0], fill=ORANGE)

def tower(c):
    # UT Tower, centered in the art zone: white shaft and wings, burnt orange top.
    ox = 17
    c.rect(ox + 9, 28, ox + 30, 31, fill=WHITE)      # wings
    c.rect(ox + 14, 25, ox + 25, 27, fill=WHITE)     # central block
    c.rect(ox + 16, 10, ox + 23, 24, fill=WHITE)     # shaft
    c.rect(ox + 18, 11, ox + 21, 14, fill="black")   # clock
    c.pixel(ox + 19, 12, WHITE)
    c.pixel(ox + 19, 13, WHITE)
    c.pixel(ox + 20, 13, WHITE)
    for y in range(16, 24):
        c.pixel(ox + 18, y, "black")
        c.pixel(ox + 21, y, "black")
    c.rect(ox + 16, 9, ox + 23, 9, fill=ORANGE)      # cornice
    c.rect(ox + 17, 6, ox + 22, 8, fill=ORANGE)      # belfry
    for y in [7, 8]:
        c.pixel(ox + 18, y, "black")
        c.pixel(ox + 21, y, "black")
    c.rect(ox + 17, 5, ox + 22, 5, fill=ORANGE)      # roof
    c.rect(ox + 18, 4, ox + 21, 4, fill=ORANGE)
    c.rect(ox + 19, 3, ox + 20, 3, fill=ORANGE)
    c.rect(ox + 19, 0, ox + 20, 2, fill=ORANGE)      # finial

def wrap(c, s, font, maxlines):
    lines = []
    cur = ""
    for w in s.split(" "):
        t = w if cur == "" else cur + " " + w
        if c.text_width(t, font) <= TEXT_W:
            cur = t
        else:
            if cur != "":
                lines.append(cur)
            cur = w
    if cur != "":
        lines.append(cur)
    trunc = len(lines) > maxlines
    lines = lines[:maxlines]
    out = []
    for i in range(len(lines)):
        l = lines[i]
        tail = "..." if (trunc and i == maxlines - 1) else ""
        l = l + tail
        for _ in range(120):
            if c.text_width(l, font) <= TEXT_W or len(l) <= len(tail) + 1:
                break
            l = l[:len(l) - len(tail) - 1] + tail
        out.append(l)
    return out

def frame(c, idx, lines, font, pitch, glyph):
    col = ORANGE if idx % 2 == 0 else WHITE
    c.clear()
    if idx % 2 == 0:
        logo(c)
    else:
        tower(c)
    c.vline(DIV_X, 2, 29, "#3A1A00")
    y0 = (32 - (len(lines) * pitch - (pitch - glyph))) // 2
    for i in range(len(lines)):
        c.text(lines[i], TEXT_X, y0 + i * pitch, font=font, color=col)

def story(c, idx):
    stories = fetch()
    if stories == None or len(stories) == 0:
        frame(c, idx, ["NEWS OFFLINE", "WILL RETRY", "IN 15 MIN"], "5x7", 8, 7)
    else:
        head = stories[idx % len(stories)]
        big = wrap(c, head, "5x7", 5)
        if len(big) <= 4:
            frame(c, idx, big, "5x7", 8, 7)
        else:
            frame(c, idx, wrap(c, head, "4x5", 5), "4x5", 6, 5)

def splash(c, ctx):
    c.clear()
    # Football lying on its side behind the text: two parabolic arcs meet at the tips.
    for x in range(16, 176):
        dx = (x - 95.5) / 80.0
        hh = int(15 * (1 - dx * dx) + 0.5)
        c.rect(x, 15 - hh, x, 16 + hh, fill="#6E3400")
    for x in [36, 37, 41, 42]:
        dx = (x - 95.5) / 80.0
        hh = int(15 * (1 - dx * dx) + 0.5)
        c.rect(x, 15 - hh, x, 16 + hh, fill="#A85200")
        c.rect(191 - x, 15 - hh, 191 - x, 16 + hh, fill="#A85200")
    c.text_stroke("LONGHORN", 96, 1, font="10x16", color=ORANGE, stroke="white", thickness=1, align="center")
    c.text_stroke("FOOTBALL NEWS", 96, 16, font="10x16", color=ORANGE, stroke="white", thickness=1, align="center")

def story1(c, ctx):
    story(c, 0)

def story2(c, ctx):
    story(c, 1)

def story3(c, ctx):
    story(c, 2)