# DESIGN. A glucose number from across the room: the current reading
# is the hero on the left, lit in its range color, with the trend
# arrow and the change since the last reading underneath. On the right
# is a 3-hour trace over a dim green 70-180 target band, so a rise or
# drop shows before you read any numbers. Each segment takes the color
# of its range: green in range, amber high, red for <54 or >250.
# The app shows labelled DEMO data until a Nightscout site and token
# are entered. After that it never shows made-up data: a failed fetch
# draws an error screen instead.

HERO_X = 6        # 6px scroll-safe padding at the left edge
CHART_X0 = 62     # hero numbers are at most 50px ("288" in 16x20_bold)
CHART_X1 = 121    # 6px scroll-safe padding at the right edge
CHART_Y0 = 2
CHART_Y1 = 22
WINDOW_MIN = 180  # 36 readings at 5-minute intervals

UP = [
    "...X...",
    "..XXX..",
    ".XXXXX.",
    "XXXXXXX",
    "...X...",
    "...X...",
    "...X...",
]
UP45 = [
    ".XXXXXX",
    "..XXXXX",
    "...XXXX",
    "..XXXXX",
    ".XXX.XX",
    "XXX...X",
    ".X.....",
]
FLAT = [
    "...X...",
    "...XX..",
    "...XXX.",
    "XXXXXXX",
    "...XXX.",
    "...XX..",
    "...X...",
]
DOUBLE_UP = [
    "..X.....X..",
    ".XXX...XXX.",
    "XXXXX.XXXXX",
    "..X.....X..",
    "..X.....X..",
    "..X.....X..",
    "..X.....X..",
]

def flip(art):
    return [art[len(art) - 1 - i] for i in range(len(art))]

ARROWS = {
    "DoubleUp": DOUBLE_UP,
    "SingleUp": UP,
    "FortyFiveUp": UP45,
    "Flat": FLAT,
    "FortyFiveDown": flip(UP45),
    "SingleDown": flip(UP),
    "DoubleDown": flip(DOUBLE_UP),
}

# A made-up afternoon (oldest first): a post-lunch rise into the high
# range, then back into range and rising again.
DEMO_SGV = [
    118, 121, 125, 131, 140, 152, 166, 179, 190, 198, 203, 205,
    202, 196, 188, 178, 167, 157, 148, 140, 133, 127, 122, 118,
    115, 113, 112, 112, 114, 117, 121, 126, 131, 136, 140, 145,
]

def demo_data(ctx):
    # Newest first, like the Nightscout API; the latest reading is 2 min old.
    newest_ms = (ctx.now.unix - 120) * 1000
    n = len(DEMO_SGV)
    out = []
    for i in range(n):
        out.append({
            "sgv": DEMO_SGV[n - 1 - i],
            "date": newest_ms - i * 300 * 1000,
            "direction": "FortyFiveUp" if i == 0 else "",
        })
    return out

def range_color(sgv):
    if sgv < 54 or sgv > 250:
        return "red"
    if sgv < 70 or sgv > 180:
        return "amber"
    return "green"

def parse_offset_minutes(raw):
    # The offset is free text: accept "-6", "5.5", "+9", and fall back to
    # UTC for anything else instead of crashing the render.
    s = str(raw).strip()
    sign = 1
    if s.startswith("-"):
        sign = -1
        s = s[1:]
    elif s.startswith("+"):
        s = s[1:]
    parts = s.split(".")
    if len(parts) > 2 or not parts[0].isdigit():
        return 0
    minutes = int(parts[0]) * 60
    if len(parts) == 2 and parts[1].isdigit():
        minutes += int(float("0." + parts[1]) * 60)
    return sign * minutes

def clock(ms, off_min):
    secs = (ms // 1000 + off_min * 60) % 86400
    hour = secs // 3600
    minute = (secs % 3600) // 60
    hh = hour % 12
    if hh == 0:
        hh = 12
    return str(hh) + ":" + fmt.pad(minute) + ("A" if hour < 12 else "P")

def fetch_data(domain, token):
    domain = domain.replace("https://", "").replace("http://", "").strip("/")
    # refresh is 300s and CGMs post every 5 min, so the ttl matches both.
    resp = http.get("https://" + domain + "/api/v1/entries/sgv.json?count=36&token=" + token, ttl_seconds=300)
    if resp["status_code"] != 200:
        return None, resp["status_code"]
    data = [e for e in (resp["json"] or []) if e.get("sgv") and e.get("date")]
    if len(data) == 0:
        return None, 200
    return data, 200

def draw_error(c, line1, line2):
    c.text(line1, 64, 7, font="6x8", color="red", align="center")
    c.text(line2, 64, 20, font="4x5", color="gray", align="center")

def draw_chart(c, data, now_ms):
    h = CHART_Y1 - CHART_Y0

    # Scale to the data, but always keep the whole 70-180 band in view
    # and some headroom at the top for the DEMO tag.
    vals = [int(e["sgv"]) for e in data]
    lo = min(55, min(vals) - 5)
    hi = max(215, max(vals) + 15)

    def y_of(v):
        v = max(lo, min(hi, v))
        return CHART_Y1 - (v - lo) * h // (hi - lo)

    def x_of(ms):
        age_min = (now_ms - ms) // 60000
        return CHART_X1 - age_min * (CHART_X1 - CHART_X0) // WINDOW_MIN

    # Target band 70-180, with its edges a step brighter.
    c.rect(CHART_X0, y_of(180), CHART_X1, y_of(70), fill=color.dim("green", 12))
    c.hline(CHART_X0, y_of(180), CHART_X1 - CHART_X0 + 1, color.dim("green", 30))
    c.hline(CHART_X0, y_of(70), CHART_X1 - CHART_X0 + 1, color.dim("green", 30))

    pts = []
    for e in data:
        x = x_of(e["date"])
        if x >= CHART_X0 and x <= CHART_X1:
            pts.append((x, y_of(e["sgv"]), e["sgv"]))
    pts = sorted(pts)
    for i in range(1, len(pts)):
        a = pts[i - 1]
        b = pts[i]
        # Skip gaps over ~15 min so a sensor dropout reads as a break.
        if b[0] - a[0] <= 6:
            c.line(a[0], a[1], b[0], b[1], range_color(b[2]))
    if len(pts) > 0:
        last = pts[len(pts) - 1]
        col = range_color(last[2])
        c.fill_circle(last[0], last[1], 2, color.dim(col, 35))
        c.rect(last[0] - 1, last[1] - 1, last[0], last[1], fill="white")

def main(c, ctx):
    c.clear()
    domain = str(ctx.inputs.get("nightscouturl", "") or "").strip()
    token = str(ctx.inputs.get("token", "") or "").strip()
    off_min = parse_offset_minutes(ctx.inputs.get("tzoffset", "-6"))

    demo = domain == "" or token == "" or domain == "yoursite.onrender.com"
    if demo:
        data = demo_data(ctx)
    else:
        data, status = fetch_data(domain, token)
        if data == None:
            if status == 401 or status == 403:
                draw_error(c, "BAD TOKEN", "CHECK NIGHTSCOUT TOKEN")
            elif status == 200:
                draw_error(c, "NO READINGS", "NOTHING FROM YOUR CGM YET")
            else:
                draw_error(c, "NO SIGNAL", "CHECK NIGHTSCOUT URL")
            return

    data = sorted(data, key = lambda e: -e["date"])
    entry = data[0]
    sgv = int(entry["sgv"])
    now_ms = ctx.now.unix * 1000
    age_min = (now_ms - entry["date"]) // 60000
    stale = age_min > 15
    col = "gray" if stale else range_color(sgv)

    # Hero: the reading, then trend arrow + change since last reading.
    c.text(str(sgv), HERO_X, 2, font="16x20_bold", color=col)
    art = ARROWS.get(entry.get("direction", ""))
    tx = HERO_X
    if art != None and not stale:
        c.sprite(art, tx, 25, color=col)
        tx += len(art[0]) + 3
    if len(data) > 1:
        delta = sgv - int(data[1]["sgv"])
        c.text(("+" if delta >= 0 else "") + str(delta), tx, 25, font="5x7", color="white")
    c.text("MG/DL", 56, 26, font="4x5", color="midgray", align="right")

    draw_chart(c, data, now_ms)

    total = 0
    for e in data:
        total += int(e["sgv"])
    c.text("AVG " + str(total // len(data)), CHART_X0, 26, font="4x5", color="gray")
    if stale:
        c.text(str(age_min) + "M OLD", CHART_X1, 26, font="4x5", color="red", align="right")
    else:
        c.text(clock(entry["date"], off_min), CHART_X1, 26, font="4x5", color="skyblue", align="right")
    if demo:
        c.text("DEMO", CHART_X1, CHART_Y0, font="4x5", color="amber", align="right")
