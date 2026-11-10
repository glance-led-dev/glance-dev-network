# PBR Bull Riding -- Professional Bull Riders on a 192x32 SCROLL panel.
#
# DESIGN. Bull riding is a weekend sport, so most of the week the panel's job
# is "when and where is the next event", and on event nights its job is "what
# just happened on that bull". Page 1 is the hero card for whichever is true
# right now: a countdown before an event, the latest ride while it is live
# (rider vs bull, rider score green or BUCKED OFF red), the winner once it is
# final. Page 2 is the context: the next three stops before an event, the
# event leaderboard during and after it. A bucking-bull sprite carries the
# app's identity so it reads as PBR between other apps in the scroll.
#
# Data: pbr.com's own event feeds (the same JSON its live ticker polls every
# 60s). No key. getupcomingeventlist lists upcoming events with a web status;
# geteventinfo?id= adds Results (leaderboard / final top 3), Tracker (latest
# ride) and Draw. Finished events drop out of the list, so between events the
# app shows the next event rather than the last result.

LIST_URL = "https://www.pbr.com/umbraco/api/eventlite/getupcomingeventlist"
INFO_URL = "https://www.pbr.com/umbraco/api/eventlite/geteventinfo"

# Tour setting -> CF series codes. Special events (Global Cup and the like)
# sit with the premier tour.
TOURS = {
    "UNLEASH THE BEAST": ["UTB", "SPCEVT"],
    "VELOCITY TOUR": ["PWVT"],
    "ALL TOURS": [],
}

TOUR_SHORT = {
    "UTB": "UNLEASH THE BEAST",
    "SPCEVT": "PBR SPECIAL EVENT",
    "PWVT": "VELOCITY TOUR",
    "TPD-US": "TOURING PRO",
}

LIVE_STATUSES = ["LivePre", "Live", "LivePost"]

COLORS = {
    "bg": "#000000",
    "text": "#F4F7FB",
    "label": "#8A93A6",
    "dim": "#4B5563",
    "hair": "#1E2430",
    # Tour accents. Leather gold for the premier tour, teal for Velocity --
    # brand colors, kept apart from the ride colors below.
    "UTB": "#D9A441",
    "SPCEVT": "#D9A441",
    "PWVT": "#2BB5C8",
    "TPD-US": "#8A93A6",
    # A qualified (8-second) ride is green; a buck-off is red.
    "ride": "#22C55E",
    "buck": "#EF4444",
    "live": "#EF4444",
    "soon": "#FFB020",
    "error": "#E8B04A",
    "error_sub": "#6A7090",
}

# Bucking bull, head down and hind end up. B body, H horn, E eye.
BULL = """
...........BB.....
..........BBBB..B.
.....BBBBBBBBBBBB.
H..BBBBBBBBBBBBB..
HHBBBBBBBBBBBBB...
.BEBBBBBBBBBBBB...
.BBBBBBB.....BBB..
..BB.BB.......BB..
..B...B........B..
"""
BULL_LEGEND = {"B": "#8B5A2B", "H": "#F4F7FB", "E": "#000000"}
BULL_W = 18
BULL_H = 9

MONTHS = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# Venue time zone codes the feed uses -> UTC offset in hours. Standard time;
# being an hour off in summer only moves the TONIGHT cutover near midnight.
TZ_OFFSET = {
    "EST": -5, "EDT": -4, "ET": -5,
    "CST": -6, "CDT": -5, "CT": -6,
    "MST": -7, "MDT": -6, "MT": -7,
    "PST": -8, "PDT": -7, "PT": -8,
}

FONTH = {"4x5": 5, "5x7": 7, "6x8": 8, "7x12": 12, "10x16": 16}


# ---- helpers -----------------------------------------------------------

def tour_codes(ctx):
    tour = str(ctx.inputs.get("tour", "UNLEASH THE BEAST")).upper()
    return TOURS.get(tour, TOURS["UNLEASH THE BEAST"])


def http_json(url, ttl, params = {}):
    resp = http.get(url, params = params, ttl_seconds = ttl)
    if resp["status_code"] != 200:
        return None
    return resp["json"]


def clip(c, text, font, max_w):
    text = str(text)
    for _i in range(40):
        if len(text) <= 1 or c.text_width(text, font) <= max_w:
            break
        text = text[:len(text) - 1]
    return text.strip()


def fit(c, text, fonts, max_w):
    # Largest font that fits, then hard-clip in the smallest.
    for f in fonts:
        if c.text_width(text, f) <= max_w:
            return text, f
    last = fonts[len(fonts) - 1]
    return clip(c, text, last, max_w), last


def tail_words(c, text, font, max_w):
    # Bull names carry a sponsor in front ("Marquis Metal Works Bill The
    # Butcher"); the bull's own name is the end, so drop words from the front.
    words = [w for w in str(text).upper().split(" ") if w != ""]
    for i in range(len(words)):
        trial = " ".join(words[i:])
        if c.text_width(trial, font) <= max_w:
            return trial
    if len(words) == 0:
        return ""
    return clip(c, words[len(words) - 1], font, max_w)


def rider_name(row):
    name = row.get("RiderNm")
    if name == None or str(name).strip() == "":
        name = (str(row.get("First_Name") or "") + " " + str(row.get("Last_Name") or "")).strip()
    return str(name).upper()


def last_name(full):
    parts = [p for p in str(full).split(" ") if p != ""]
    if len(parts) == 0:
        return "TBD"
    return parts[len(parts) - 1]


def fmt_score(v):
    # 89.75 -> "89.75", 262 -> "262", 88.5 -> "88.50"
    if v == None:
        return ""
    hundredths = int(float(v) * 100 + 0.5)
    whole = hundredths // 100
    frac = hundredths % 100
    if frac == 0:
        return str(whole)
    return str(whole) + "." + ("0" + str(frac) if frac < 10 else str(frac))


def days_from_civil(y, m, d):
    # Days since 1970-01-01 (Howard Hinnant's algorithm).
    if m <= 2:
        y = y - 1
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def parse_day(stamp):
    # "2026-12-11T19:45:00" -> [y, m, d, hour, minute]; digits only, so any
    # suffix the feed adds later doesn't matter.
    s = str(stamp)
    if len(s) < 10:
        return None
    y = int(s[0:4])
    m = int(s[5:7])
    d = int(s[8:10])
    hh = int(s[11:13]) if len(s) >= 13 else 0
    mm = int(s[14:16]) if len(s) >= 16 else 0
    return [y, m, d, hh, mm]


def date_label(days):
    first = parse_day(days[0]) if len(days) > 0 else None
    if first == None:
        return ""
    last = parse_day(days[len(days) - 1])
    label = MONTHS[first[1]] + " " + str(first[2])
    if last != None and (last[1] != first[1] or last[2] != first[2]):
        if last[1] == first[1]:
            label += "-" + str(last[2])
        else:
            label += "-" + MONTHS[last[1]] + " " + str(last[2])
    return label


def clock_label(hh, mm):
    suffix = "PM" if hh >= 12 else "AM"
    h12 = hh % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + ("0" + str(mm) if mm < 10 else str(mm)) + " " + suffix


def countdown(ctx, ev):
    # [text, color] for the countdown chip, in the venue's local time.
    days = ev["days"]
    first = parse_day(days[0]) if len(days) > 0 else None
    if first == None:
        return ["", COLORS["label"]]
    off = TZ_OFFSET.get(str(ev["tz"]).upper(), -6)
    local_day = (ctx.now.unix + off * 3600) // 86400
    diff = days_from_civil(first[0], first[1], first[2]) - local_day
    if diff < 0:
        return ["THIS WEEKEND", COLORS["soon"]]
    if diff == 0:
        return ["TONIGHT " + clock_label(first[3], first[4]), COLORS["soon"]]
    if diff == 1:
        return ["TOMORROW", COLORS["soon"]]
    return ["IN " + str(diff) + " DAYS", COLORS["text"]]


def city_label(ev):
    return str(ev["location"]).upper()


# ---- data --------------------------------------------------------------

def fetch_state(ctx):
    # One state for both pages: the focus event, its live info, and the
    # next few events after it.
    data = http_json(LIST_URL, 120)
    if data == None or type(data) != "list":
        return {"ok": False}
    codes = tour_codes(ctx)
    events = []
    for e in data:
        series = str(e.get("series") or "")
        if len(codes) > 0 and series not in codes:
            continue
        days = e.get("days") or []
        if len(days) == 0:
            continue
        events.append({
            "id": int(e.get("event_ID") or 0),
            "title": str(e.get("eventTitle") or ""),
            "series": series,
            "days": days,
            "location": str(e.get("eventLocation") or ""),
            "status": str(e.get("eventStatusWeb") or ""),
            "tz": str(e.get("timeZoneCd") or ""),
        })
    # Soonest first (ISO stamps sort as text).
    n = len(events)
    for i in range(n):
        for j in range(n - 1 - i):
            if str(events[j]["days"][0]) > str(events[j + 1]["days"][0]):
                tmp = events[j]
                events[j] = events[j + 1]
                events[j + 1] = tmp

    focus = None
    mode = "pre"
    for e in events:
        if e["status"] in LIVE_STATUSES:
            focus = e
            mode = "live"
            break
    if focus == None:
        for e in events:
            if e["status"] == "PostEvent":
                focus = e
                mode = "final"
                break
    if focus == None and len(events) > 0:
        focus = events[0]

    info = None
    if focus != None and mode != "pre" and focus["id"] > 0:
        # The site's own ticker polls this every 60s during a live event.
        got = http_json(INFO_URL, 60, {"id": str(focus["id"])})
        if got != None and type(got) == "dict":
            evs = got.get("Events") or []
            if len(evs) > 0:
                info = evs[0]

    after = [e for e in events if focus == None or e["id"] != focus["id"]]
    return {"ok": True, "mode": mode, "focus": focus, "info": info, "after": after}


# ---- drawing -----------------------------------------------------------

def draw_error(c, title, sub):
    c.fill(COLORS["bg"])
    c.sprite(BULL, 10, 11, legend = BULL_LEGEND)
    text, font = fit(c, title, ["6x8", "5x7", "4x5"], 181 - 34)
    c.text(text, 34, 9, font = font, color = COLORS["error"])
    c.text(clip(c, sub, "4x5", 181 - 34), 34, 21, font = "4x5", color = COLORS["error_sub"])


def accent(series):
    return COLORS.get(series, COLORS["label"])


def draw_tag(c, x, y, series, prefix = ""):
    # Small tour label: a 2x5 accent bar, then the tour name in grey.
    c.rect(x, y, x + 1, y + 4, fill = accent(series))
    label = prefix + TOUR_SHORT.get(series, "PBR")
    c.text(label, x + 4, y, font = "4x5", color = COLORS["label"])
    return x + 4 + c.text_width(label, "4x5")


def event_pre(c, ctx, ev):
    # Countdown card: bull | tour / CITY / title ... date / countdown.
    c.sprite(BULL, 10, 12, legend = BULL_LEGEND)
    x0 = 34
    right = 181
    draw_tag(c, x0, 2, ev["series"])

    date = date_label(ev["days"])
    cd = countdown(ctx, ev)
    right_w = c.text_width(date, "5x7")
    if c.text_width(cd[0], "4x5") > right_w:
        right_w = c.text_width(cd[0], "4x5")
    c.text(date, right, 12, font = "5x7", color = COLORS["text"], align = "right")
    c.text(cd[0], right, 22, font = "4x5", color = cd[1], align = "right")

    # The city is the hero, sized to whatever the right column leaves.
    city_w = right - right_w - 6 - x0
    city, font = fit(c, city_label(ev), ["7x12", "6x8", "5x7"], city_w)
    city_y = 11 if font == "7x12" else 13
    c.text(city, x0, city_y, font = font, color = COLORS["text"])
    title = str(ev["title"]).upper().replace("PBR ", "").replace(city_label(ev), "").strip()
    if title != "" and title != city.split(",")[0]:
        c.text(clip(c, title, "4x5", city_w), x0, 26, font = "4x5", color = COLORS["dim"])


def live_header(c, ev, word):
    # Red dot + LIVE (or FINAL in white) + city, then a hairline.
    x = 10
    if word == "LIVE":
        c.fill_circle(x + 2, 3, 2, COLORS["live"])
        c.text("LIVE", x + 7, 1, font = "4x5", color = COLORS["live"])
        x += 7 + c.text_width("LIVE", "4x5") + 5
    else:
        c.text(word, x, 1, font = "4x5", color = COLORS["text"])
        x += c.text_width(word, "4x5") + 5
    c.rect(x, 1, x + 1, 5, fill = accent(ev["series"]))
    c.text(clip(c, city_label(ev), "4x5", 181 - x - 4), x + 4, 1, font = "4x5", color = COLORS["label"])
    c.rect(10, 7, 181, 7, fill = COLORS["hair"])


def event_live(c, ev, info):
    live_header(c, ev, "LIVE")
    tracker = (info or {}).get("Tracker") or []
    if len(tracker) == 0:
        # Before the first out: show who is up first if the draw is posted.
        draw = (info or {}).get("Draw") or []
        if len(draw) > 0:
            d = draw[0]
            c.text("FIRST OUT", 10, 12, font = "4x5", color = COLORS["label"])
            full = str(d.get("RiderNm") or "TBD").upper()
            name, nfont = fit(c, full, ["6x8", "5x7"], 86)
            if name != full:
                name, nfont = fit(c, last_name(full), ["6x8", "5x7"], 86)
            c.text(name, 10, 20, font = nfont, color = COLORS["text"])
            c.text(tail_words(c, d.get("BullNm") or "", "5x7", 80), 181, 21, font = "5x7", color = COLORS["label"], align = "right")
        else:
            c.sprite(BULL, 10, 16, legend = BULL_LEGEND)
            c.text("CHUTES OPEN SOON", 34, 18, font = "5x7", color = COLORS["text"])
        return

    t = tracker[0]
    rider = rider_name(t)
    rscore = t.get("Rider_Score")
    bscore = t.get("Bull_Score")
    buck = t.get("Buck_Off_Time")
    qualified = rscore != None and float(rscore) > 0

    # Right: the hero result, measured first so names fit what is left.
    if qualified:
        hero = fmt_score(rscore)
        hero_font = "10x16"
        hero_col = COLORS["ride"]
        under = "BULL " + fmt_score(bscore) if bscore != None else ""
    else:
        hero = "BUCKED"
        hero_font = "7x12"
        hero_col = COLORS["buck"]
        under = ("AT " + fmt_score(buck) + "S") if buck != None and float(buck) > 0 else "NO SCORE"
    hero_w = c.text_width(hero, hero_font)
    hero_y = 10 if hero_font == "10x16" else 11
    c.text(hero, 181, hero_y, font = hero_font, color = hero_col, align = "right")
    c.text(under, 181, 27, font = "4x5", color = COLORS["label"], align = "right")

    left_w = 181 - hero_w - 6 - 10
    name, nfont = fit(c, rider, ["6x8", "5x7"], left_w)
    if name != rider:
        name, nfont = fit(c, last_name(rider), ["6x8", "5x7"], left_w)
    c.text(name, 10, 11, font = nfont, color = COLORS["text"])
    c.text("ON", 10, 22, font = "4x5", color = COLORS["dim"])
    on_w = c.text_width("ON", "4x5") + 4
    c.text(tail_words(c, t.get("Bull_Name") or "", "5x7", left_w - on_w), 10 + on_w, 21, font = "5x7", color = COLORS["label"])


def event_final(c, ev, info):
    live_header(c, ev, "FINAL")
    results = (info or {}).get("Results") or []
    if len(results) == 0:
        c.sprite(BULL, 10, 16, legend = BULL_LEGEND)
        c.text("RESULTS COMING SOON", 34, 18, font = "5x7", color = COLORS["text"])
        return
    win = results[0]
    total = fmt_score(win.get("RideScore"))
    c.text("WINNER", 10, 12, font = "4x5", color = COLORS["label"])
    hero_w = c.text_width(total, "10x16")
    c.text(total, 181, 11, font = "10x16", color = COLORS["text"], align = "right")
    c.text("POINTS", 181 - hero_w - 4, 22, font = "4x5", color = COLORS["dim"], align = "right")
    room = 181 - hero_w - c.text_width("POINTS", "4x5") - 12 - 10
    full = rider_name(win)
    name, font = fit(c, full, ["7x12", "6x8"], room)
    if name != full:
        name, font = fit(c, last_name(full), ["7x12", "6x8", "5x7"], room)
    c.text(name, 10, 19, font = font, color = COLORS["text"])


def event(c, ctx):
    state = fetch_state(ctx)
    c.fill(COLORS["bg"])
    if not state["ok"]:
        draw_error(c, "PBR FEED OFFLINE", "SCORES RETURN WHEN PBR.COM IS BACK")
        return
    ev = state["focus"]
    if ev == None:
        # Off-season or nothing announced yet -- not an error.
        c.sprite(BULL, 10, 12, legend = BULL_LEGEND)
        c.text("OFF SEASON", 34, 9, font = "6x8", color = COLORS["text"])
        c.text("NEXT SCHEDULE NOT POSTED YET", 34, 21, font = "4x5", color = COLORS["label"])
        return
    if state["mode"] == "live":
        event_live(c, ev, state["info"])
    elif state["mode"] == "final":
        event_final(c, ev, state["info"])
    else:
        event_pre(c, ctx, ev)


# ---- page 2 ------------------------------------------------------------

def board_rows(c, rows):
    # rows: [pos, name, value, value_color]; three 7px rows under a header.
    for i in range(len(rows)):
        if i >= 3:
            break
        r = rows[i]
        y = 9 + i * 8
        c.text(r[0], 10, y + 1, font = "4x5", color = COLORS["label"])
        val_w = c.text_width(r[2], "5x7")
        c.text(r[2], 181, y, font = "5x7", color = r[3], align = "right")
        room = 181 - val_w - 6 - 20
        name = r[1]
        if c.text_width(name, "5x7") > room:
            # Never cut a name mid-word: fall back to the last name.
            name = clip(c, last_name(name), "5x7", room)
        c.text(name, 20, y, font = "5x7", color = COLORS["text"])


def board(c, ctx):
    state = fetch_state(ctx)
    c.fill(COLORS["bg"])
    if not state["ok"]:
        draw_error(c, "PBR FEED OFFLINE", "SCORES RETURN WHEN PBR.COM IS BACK")
        return
    ev = state["focus"]
    mode = state["mode"]

    if mode != "pre" and ev != None:
        live_header(c, ev, "LIVE" if mode == "live" else "FINAL")
        results = (state["info"] or {}).get("Results") or []
        if len(results) == 0:
            c.text("LEADERBOARD AFTER THE FIRST RIDES", 10, 18, font = "4x5", color = COLORS["label"])
            return
        rows = []
        for r in results:
            pos = str(r.get("PositionTxt") or str(len(rows) + 1))
            rows.append([pos, rider_name(r), fmt_score(r.get("RideScore")), COLORS["text"]])
        board_rows(c, rows)
        return

    # Before an event: the stops after the one on page 1.
    after = state["after"]
    c.text("UP NEXT", 10, 1, font = "4x5", color = COLORS["text"])
    tag_x = 10 + c.text_width("UP NEXT", "4x5") + 5
    codes = tour_codes(ctx)
    if len(codes) > 0:
        draw_tag(c, tag_x, 1, codes[0])
    else:
        c.text("ALL PBR TOURS", tag_x, 1, font = "4x5", color = COLORS["label"])
    c.rect(10, 7, 181, 7, fill = COLORS["hair"])
    if len(after) == 0:
        c.text("NO MORE EVENTS POSTED YET", 10, 18, font = "4x5", color = COLORS["label"])
        return
    rows = []
    for e in after:
        rows.append(["", city_label(e), date_label(e["days"]), accent(e["series"])])
    for i in range(len(rows)):
        if i >= 3:
            break
        r = rows[i]
        y = 9 + i * 8
        c.rect(10, y + 1, 11, y + 5, fill = r[3])
        val_w = c.text_width(r[2], "5x7")
        c.text(r[2], 181, y, font = "5x7", color = COLORS["text"], align = "right")
        c.text(clip(c, r[1], "5x7", 181 - val_w - 6 - 15), 15, y, font = "5x7", color = COLORS["text"])
