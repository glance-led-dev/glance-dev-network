# Calfeed Agenda
#
# DESIGN. One event per page, the time as the hero. Page NOW shows the
# event that matters right now: the one in progress that started last,
# else the next one to start; all-day events only when nothing timed is
# left today. Page NEXT shows what follows it. A calendar glyph on the
# left is the app's identity; the hero time wears the event's phase
# colour (white far off, amber within 15 minutes, green running), and a
# running event paints its elapsed share along the bottom edge.
#
# The feed does the date maths: every event carries start_unix/end_unix
# and `local` {date, weekday, time} in the view's own zone, so this file
# never converts a timezone.
#
# Fetch: one http.get per render, ttl 60 (the feed is cached 60 s
# upstream). The manifest's refresh is 300, not 60: Glance requires
# refresh >= 300 for apps with free-text or colour inputs, and this one
# has both. See https://glance-led.dev/docs/build-with-ai/prompt/.

SOON_SECONDS = 15 * 60

COLOR_FAR = "white"
COLOR_SOON = "amber"
COLOR_RUNNING = "green"
COLOR_ALLDAY = "skyblue"
COLOR_LABEL_DEFAULT = "#9AA3B2"
COLOR_TRACK = "#20262E"
COLOR_CARD_BG = "#0B0C12"
COLOR_CARD_TITLE = "#E8B04A"
COLOR_CARD_SUB = "#6A7090"

HERO_FONTS_WIDE = ["16x20", "10x16"]
HERO_FONTS_NARROW = ["10x16", "6x8"]
TITLE_FONTS_WIDE = ["6x8", "5x7", "4x5"]
NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]
FONTH = {"16x20": 20, "10x16": 16, "6x8": 8, "5x7": 7, "4x5": 5}

# 9x9 calendar: two rings, a header band, a grid of days.
CALENDAR_ART = """
.#.....#.
#########
#########
#.......#
#.#.#.#.#
#.......#
#.#.#.#.#
#.......#
#########
"""

# Demo data, shown (labelled) until a feed URL is configured: the three
# steps to set the app up, as events. Two pages cannot show three, so
# the demo alternates per refresh period (refresh is 300): steps 1+2, then
# 2+3, the first of the pair always running.
DEMO_STEPS = ["GO: CALFEED.IO", "CREATE VIEW", "ADD TO GLANCE"]

def demo_feed(now):
    h = 3600
    first = (now // 300) % 2
    steps = DEMO_STEPS[first:]
    return {
        "view": {"name": "DEMO", "today": "", "timezone": "UTC"},
        "events": [
            ev(steps[0], now - 20 * 60, now + 10 * 60),
            ev(steps[1], now + 2 * h, now + 3 * h),
        ],
    }

def ev(title, start, end):
    return {
        "title": title,
        "start_unix": start,
        "end_unix": end,
        "all_day": False,
        "local": {"date": "", "weekday": "", "time": hhmm(start), "end_time": hhmm(end)},
    }

def hhmm(unix):
    m = (unix // 60) % (24 * 60)
    return pad2(m // 60) + ":" + pad2(m % 60)

# This Starlark's % has no width flags.
def pad2(n):
    return ("0" if n < 10 else "") + str(n)

# ---- data ---------------------------------------------------------------

# [feed, state]: state is "live", "demo" or "offline".
def fetch_feed(ctx):
    url = str(ctx.inputs.get("feedurl", "")).strip()
    if url == "":
        return [demo_feed(ctx.now.unix), "demo"]
    resp = http.get(url, headers = feed_headers(ctx), ttl_seconds = 60)
    if resp["status_code"] != 200 or not resp["json"]:
        return [None, "offline"]
    return [resp["json"], "live"]

# The optional feed header, configured as "Name=value" ("Name: value"
# works too). Whatever the calfeed feed's restriction requires.
def feed_headers(ctx):
    raw = str(ctx.inputs.get("feedkey", "")).strip()
    sep = raw.find("=")
    if sep < 0:
        sep = raw.find(":")
    if sep < 1:
        return {}
    name = raw[:sep].strip()
    value = raw[sep + 1:].strip()
    return {name: value} if name != "" and value != "" else {}

def is_running(e, now):
    return (not e.get("all_day")) and e["start_unix"] <= now and now < e["end_unix"]

# The event the panel should show now: the running one that started
# last, else the next timed one to start, else today's all-day event.
def pick_now(events, now):
    running = [e for e in events if is_running(e, now)]
    if running:
        best = running[0]
        for e in running:
            if e["start_unix"] > best["start_unix"]:
                best = e
        return best
    timed = [e for e in events if (not e.get("all_day")) and e["start_unix"] > now]
    if timed:
        return timed[0]
    for e in events:
        if e.get("all_day") and e["end_unix"] > now:
            return e
    return None

# What follows the chosen event, timed events first, all-day last.
def pick_next(events, chosen, now):
    if chosen == None:
        return None
    later = [e for e in events if (not e.get("all_day")) and e["start_unix"] > now and e != chosen]
    if later:
        return later[0]
    for e in events:
        if e.get("all_day") and e != chosen and e["end_unix"] > now:
            return e
    return None

# [label, color] for the event's phase; the words and the colour can never
# disagree. `wide` picks verbose copy; 64 px holds about 7 characters
# next to the page tag ("10 MIN LEFT" is 55 px in 4x5, the row has 36).
def phase(e, now, wide):
    if e.get("all_day"):
        return ["ALL DAY", COLOR_ALLDAY]
    if is_running(e, now):
        left = (e["end_unix"] - now) // 60
        if left <= 0:
            return ["ENDING", COLOR_RUNNING]
        return [("%d MIN LEFT" if wide else "%dM") % left, COLOR_RUNNING]
    until = e["start_unix"] - now
    if until <= SOON_SECONDS:
        return [("IN %d MIN" if wide else "IN %dM") % max(until // 60, 1), COLOR_SOON]
    return [when_label(e, until, wide), COLOR_FAR]

def when_label(e, until, wide):
    weekday = str(e.get("local", {}).get("weekday", "")).upper()
    if until >= 24 * 3600 and weekday != "":
        return weekday
    if until >= 3600:
        return "IN %dH" % (until // 3600)
    return ("IN %d MIN" if wide else "IN %dM") % (until // 60)

def title_of(e):
    t = str(e.get("title", "") or "BUSY").upper()
    return t if t != "" else "BUSY"

# ---- drawing helpers ----------------------------------------------------

# Largest font that fits, then a hard clip; nothing in the API clips.
def fit_clip(c, text, fonts, maxw):
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]

def nodata(c, title, sub):
    c.fill(COLOR_CARD_BG)
    wide = c.width >= 128
    ft, tt = fit_clip(c, title, NODATA_FONTS, c.width - 8)
    ty = 4 if wide else 5
    c.text(tt, c.width // 2, ty, font = ft, color = COLOR_CARD_TITLE, align = "center")
    fs, ts = fit_clip(c, sub, ["5x7", "4x5"], c.width - 8)
    c.text(ts, c.width // 2, 22 if wide else 18, font = fs, color = COLOR_CARD_SUB, align = "center")

# Two short lines: what, and what to do. Narrow copy fits 64 px in 4x5.
def offline(c):
    if c.width >= 128:
        nodata(c, "CALFEED OFFLINE", "CHECK FEED URL")
    else:
        nodata(c, "OFFLINE", "CHECK URL")

def all_clear(c, sub):
    c.fill("black")
    c.rect(0, 0, 1, c.height - 1, fill = COLOR_RUNNING)
    c.text("ALL CLEAR", c.width // 2, 5, font = "6x8" if c.width >= 128 else "5x7", color = COLOR_RUNNING, align = "center")
    c.text(sub, c.width // 2, 18, font = "4x5", color = COLOR_LABEL_DEFAULT, align = "center")

# The label is the eyebrow's left side: the configured one, else the
# view's name, else DEMO. NEXT pages append the page name so two
# instances (yours, your wife's) still say whose event is on screen.
def label_color(ctx):
    col = str(ctx.inputs.get("labelcolor", "")).strip()
    return col if col != "" else COLOR_LABEL_DEFAULT

def eyebrow_text(ctx, state, view_name, page):
    label = str(ctx.inputs.get("label", "")).strip().upper()
    if label == "":
        label = str(view_name).upper()  # the demo feed's view is called DEMO
    return label + (" NEXT" if page == "NEXT" else "")

# One event card. `eyebrow` is the page name (NOW / NEXT).
def card(c, e, now, eyebrow, state, view_name, ctx):
    c.fill("black")
    wide = c.width >= 128
    label, col = phase(e, now, wide)
    left = 10 if wide else 0
    right = c.width - (10 if wide else 0)

    # Identity: the calendar glyph (rows 0-8), phase-coloured. The hero
    # starts below it: 16x20 at y 10 on wide, 10x16 at y 9 on narrow.
    c.sprite(CALENDAR_ART, left, 0, color = col)
    text_x = left + 11

    # Eyebrow row (y 1..5), 4x5. Wide: label left, phase right. Narrow
    # (53 px after the glyph, about 10 characters): NOW pages keep the
    # phase and clip the label to what is left of it; NEXT pages keep
    # the " NEXT" suffix instead, since the hero colour already carries
    # the phase and the page name is what tells the two apart.
    lw = c.text_width(label, "4x5")
    lx = right - lw
    if wide or eyebrow != "NEXT":
        tf, tag = fit_clip(c, eyebrow_text(ctx, state, view_name, eyebrow), ["4x5"], lx - text_x - 2)
        c.text(tag, text_x, 1, font = tf, color = label_color(ctx))
        c.text(label, lx, 1, font = "4x5", color = col)
    else:
        suffix = " NEXT"
        room = right - text_x - c.text_width(suffix, "4x5")
        tf, tag = fit_clip(c, eyebrow_text(ctx, state, view_name, "NOW"), ["4x5"], room)
        c.text(tag + suffix, text_x, 1, font = tf, color = label_color(ctx))

    # Hero: the time (or ALL DAY), phase-coloured.
    hero = "ALL DAY" if e.get("all_day") else str(e["local"]["time"])
    fonts = HERO_FONTS_WIDE if wide else HERO_FONTS_NARROW
    hf, ht = fit_clip(c, hero, fonts, right - left)
    hy = 10 if wide else 9
    c.text(ht, left, hy, font = hf, color = col)

    # Title: to the right of the hero on wide, under it on narrow.
    title = title_of(e)
    if wide:
        tx = left + c.text_width(ht, hf) + 6
        tf, tt = fit_clip(c, title, TITLE_FONTS_WIDE, right - tx)
        c.text(tt, tx, hy + (FONTH[hf] - FONTH[tf]) // 2, font = tf, color = "white")
    else:
        # 4x5 on rows 26-30 keeps row 31 free for the progress bar and
        # a 1 px gap under the hero (rows 9-24).
        tf, tt = fit_clip(c, title, ["4x5"], right - left)
        c.text(tt, left, 26, font = tf, color = "white")

    # A running event shows its elapsed share along the bottom edge.
    if is_running(e, now):
        total = e["end_unix"] - e["start_unix"]
        pct = 100 * (now - e["start_unix"]) // total if total > 0 else 0
        c.progress_bar(left, c.height - 1, right - left, 1, pct, color = col, bg = COLOR_TRACK)

# ---- pages --------------------------------------------------------------

def now(c, ctx):
    feed, state = fetch_feed(ctx)
    if state == "offline":
        offline(c)
        return
    e = pick_now(feed.get("events", []), ctx.now.unix)
    if e == None:
        all_clear(c, "NO EVENTS")
        return
    card(c, e, ctx.now.unix, "NOW", state, feed.get("view", {}).get("name", ""), ctx)

def next(c, ctx):
    feed, state = fetch_feed(ctx)
    if state == "offline":
        offline(c)
        return
    events = feed.get("events", [])
    chosen = pick_now(events, ctx.now.unix)
    e = pick_next(events, chosen, ctx.now.unix)
    if e == None:
        all_clear(c, "NOTHING AFTER" if chosen != None else "NO EVENTS")
        return
    card(c, e, ctx.now.unix, "NEXT", state, feed.get("view", {}).get("name", ""), ctx)
