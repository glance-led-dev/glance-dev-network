# Calfeed Agenda
#
# DESIGN. One event per page. Page NOW shows the event that matters
# right now: the one in progress that started last, else the next one
# to start; all-day events only when nothing timed is left today. Page
# NEXT shows what follows it. The event's phase colour (white far off,
# amber within 15 minutes, green running, sky blue all-day -- each one a
# dropdown, those four are only the defaults) dresses the left rail, the
# countdown word, the start time and the calendar glyph beside it; the
# title sits under it in white. A running event paints its elapsed share
# along the bottom row.
#
# The eyebrow row carries a third thing when the feed offers it: the
# event's source badge (calfeed's `source_short_name`, up to 3
# characters) between the label and the state word, in the source's own
# colour when the view serves one. It is the first thing dropped when
# the row is full -- see chrome().
#
# The feed does the date maths: every event carries start_unix/end_unix
# and `local` {date, weekday, time} in the view's own zone, so this file
# never converts a timezone.
#
# Fetch: one http.get per render, ttl 60 (the feed is cached 60 s
# upstream). The manifest's refresh is 300, not 60: Glance requires
# refresh >= 300 for apps with free-text inputs, and this one
# has one. See https://glance-led.dev/docs/build-with-ai/prompt/.

SOON_SECONDS = 15 * 60

# The default of each colour dropdown; the OFFLINE and CLEAR screens
# keep them literally, since those are the app's own states rather than
# an event's phase.
COLOR_FAR = "white"
COLOR_SOON = "amber"
COLOR_RUNNING = "green"
COLOR_ALLDAY = "skyblue"
COLOR_LABEL_DEFAULT = "gray"
COLOR_TRACK = "#20262E"

BADGE_CHARS = 3  # the feed promises <= 3, but nothing drawn is unbounded
BADGE_GAP = 4    # px between the badge and each of its neighbours

# 64x32 grid: rail x 0-1, content x 4..61. Eyebrow y 1-5, hairline y 7,
# hero y 9-20, title y 23-29, progress bar y 31.
RAIL_W = 2
TEXT_X = 4
PAD = 2
HERO_FONTS = ["9x12", "6x8"]
TITLE_FONTS = ["5x7", "4x5"]
SUB_FONTS = ["4x5"]
FONTH = {"9x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

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

# 3x5 chevron after the label: this is the NEXT page.
CHEVRON_ART = """
#..
.#.
..#
.#.
#..
"""
CHEVRON_W = 5  # 2 px gap + 3 px glyph

# The input takes the feed's id, not its URL: Glance separates an app's
# settings with colons, so a pasted "https://calfeed.io/v1/feed/<id>"
# reaches the app truncated to "https". The app builds the URL instead.
FEED_BASE = "https://calfeed.io/v1/feed/"
FEED_PATH = "/v1/feed/"
HEX_DIGITS = "0123456789abcdefABCDEF"

# Demo data, shown (labelled) until a feed id is configured: the three
# steps to set the app up, as events. Two pages cannot show three, so
# the demo alternates per refresh period (refresh is 300): steps 1+2, then
# 2+3, the first of the pair always running.
DEMO_STEPS = ["CALFEED.IO", "CREATE VIEW", "PASTE ID"]

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

# The demo events name a source but no colour, so the demo shows the
# badge in the label colour -- the shape a feed without source colours
# has.
def ev(title, start, end):
    return {
        "title": title,
        "start_unix": start,
        "end_unix": end,
        "all_day": False,
        "source_short_name": "CAL",
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
    feed_id = read_feed_id(ctx)
    if feed_id == "":
        return [demo_feed(ctx.now.unix), "demo"]
    if feed_id == None:
        return [None, "offline"]
    resp = http.get(FEED_BASE + feed_id, headers = feed_headers(ctx), ttl_seconds = 60)
    if resp["status_code"] != 200 or not resp["json"]:
        return [None, "offline"]
    return [resp["json"], "live"]

# The configured id: "" when there is none (demo data), None when the
# value cannot be one (the CHECK FEED screen). Only the id is asked for,
# but a whole feed URL is taken apart rather than refused, and stray
# whitespace, a trailing slash or a trailing ".txt" are dropped.
def read_feed_id(ctx):
    raw = str(ctx.inputs.get("feedid", "")).strip()
    at = raw.find(FEED_PATH)
    if at >= 0:
        raw = raw[at + len(FEED_PATH):]
    if raw.endswith("/"):
        raw = raw[:-1]
    if raw.endswith(".txt"):
        raw = raw[:-4]
    raw = raw.strip()
    if raw == "":
        return ""
    if len(raw) > 64:
        return None
    for ch in raw.elems():
        if HEX_DIGITS.find(ch) < 0:
            return None
    return raw

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

# [words, color] for the event's phase, words long form first; the words
# and the colour can never disagree. The four colours are the viewer's,
# the constants only their defaults.
def phase(e, now, ctx):
    if e.get("all_day"):
        return [["ALL DAY"], color_input(ctx, "alldaycolor", COLOR_ALLDAY)]
    if is_running(e, now):
        running = color_input(ctx, "runningcolor", COLOR_RUNNING)
        left = (e["end_unix"] - now) // 60
        if left <= 0:
            return [["ENDING"], running]
        return [[left_label(left) + " LEFT", left_label(left)], running]
    until = e["start_unix"] - now
    if until <= SOON_SECONDS:
        return [["IN %dM" % max(until // 60, 1)], color_input(ctx, "sooncolor", COLOR_SOON)]
    return [[when_label(e, until)], color_input(ctx, "farcolor", COLOR_FAR)]

def left_label(mins):
    return "%dM" % mins if mins < 60 else "%dH" % (mins // 60)

def when_label(e, until):
    weekday = str(e.get("local", {}).get("weekday", "")).upper()
    if until >= 24 * 3600 and weekday != "":
        return weekday[:3]
    if until >= 3600:
        return "IN %dH" % (until // 3600)
    return "IN %dM" % (until // 60)

def title_of(e):
    t = str(e.get("title", "") or "BUSY").upper()
    return t if t != "" else "BUSY"

# The event's source badge: calfeed sends `source_short_name` only when
# the view's calendars have short names, so absent, blank or not-a-string
# all mean "no badge".
def badge_of(e):
    name = e.get("source_short_name")
    if type(name) != "string":
        return ""
    return name.strip().upper()[:BADGE_CHARS]

# The source's own colour, sent as #rrggbb only when the view has source
# colours on. Validated here rather than trusted: an unparseable colour
# raises inside c.text() and a raised host error kills the whole render.
def badge_color(e, fallback):
    col = e.get("color")
    if type(col) != "string":
        return fallback
    col = col.strip()
    if len(col) != 7 or not col.startswith("#"):
        return fallback
    for ch in col[1:].elems():
        if HEX_DIGITS.find(ch) < 0:
            return fallback
    return col

# ---- drawing helpers ----------------------------------------------------

# Largest font that fits, then a hard clip; nothing in the API clips.
# A clipped string ends in ".." so the cut reads as deliberate.
def fit_clip(c, text, fonts, maxw):
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            cut = t[:k].rstrip() + ".."
            if c.text_width(cut, pick) <= maxw:
                t = cut
                break
    return [pick, t]

# The shared frame of every screen: a 2 px rail on the left edge in the
# screen's state colour, and the eyebrow row (y 1..5): label left in the
# label colour, a state word right-aligned, measured first, and the
# source badge between them, right-aligned against the state word.
# `words` is the state word, long form first: the long one is used only
# when the label still fits whole beside it. On NEXT pages a chevron
# after the label marks the page. `badge` is "" on the screens that have
# no event (OFFLINE, CLEAR).
def chrome(c, ctx, label, words, col, page, badge, badge_col):
    c.fill("black")
    c.rect(0, 0, RAIL_W, c.height, fill = col)
    lcol = color_input(ctx, "labelcolor", COLOR_LABEL_DEFAULT)
    right = c.width - PAD
    chev = CHEVRON_W if page == "NEXT" else 0
    lw = c.text_width(label, "4x5") + chev
    word = words[len(words) - 1]
    for w in words:
        if TEXT_X + lw + 4 + c.text_width(w, "4x5") <= right:
            word = w
            break
    sx = right - c.text_width(word, "4x5")
    c.text(word, sx, 1, font = "4x5", color = col)

    # The badge is measured against the UNCLIPPED label, so it can never
    # cost the label characters it would otherwise have kept: "CANDELA"
    # is 34 px in 4x5 and "12M LEFT" 36 px, which already overruns the
    # row's 58 px (x 4..61) between them -- there the badge is dropped
    # rather than clipping the name to "CAND..". When it is dropped,
    # `room` below is the width the label had before the badge existed.
    bw = c.text_width(badge, "4x5") if badge != "" else 0
    if bw > 0 and TEXT_X + lw + BADGE_GAP + bw + BADGE_GAP > sx:
        bw = 0
    if bw > 0:
        c.text(badge, sx - BADGE_GAP - bw, 1, font = "4x5", color = badge_col)

    room = sx - TEXT_X - 4 - chev - (bw + BADGE_GAP if bw > 0 else 0)
    lf, lt = fit_clip(c, label, ["4x5"], room)
    c.text(lt, TEXT_X, 1, font = lf, color = lcol)
    if page == "NEXT":
        c.sprite(CHEVRON_ART, TEXT_X + c.text_width(lt, lf) + 2, 1, color = lcol)
    c.hline(TEXT_X, right - 1, 7, color = COLOR_TRACK)

# The hero row (y 9..20) with the calendar glyph as the app's identity
# on its right, then a sub line (y 23..29).
def hero_and_sub(c, hero, col, sub, sub_col, sub_fonts):
    right = c.width - PAD
    c.sprite(CALENDAR_ART, right - 9, 10, color = color.dim(col, 55))
    hf, ht = fit_clip(c, hero, HERO_FONTS, right - 9 - 2 - TEXT_X)
    c.text(ht, TEXT_X, 9 + (12 - FONTH[hf]) // 2, font = hf, color = col)
    sf, st = fit_clip(c, sub, sub_fonts, right - TEXT_X)
    c.text(st, TEXT_X, 23 + (7 - FONTH[sf]) // 2, font = sf, color = sub_col)

# Two short lines: what, and what to do.
def offline(c, ctx):
    chrome(c, ctx, eyebrow_text(ctx, ""), ["OFFLINE"], COLOR_SOON, "NOW", "", "")
    hero_and_sub(c, "--:--", COLOR_SOON, "CHECK FEED", COLOR_LABEL_DEFAULT, SUB_FONTS)

def all_clear(c, ctx, view_name, page, sub):
    chrome(c, ctx, eyebrow_text(ctx, view_name), ["CLEAR"], COLOR_RUNNING, page, "", "")
    hero_and_sub(c, "FREE", COLOR_RUNNING, sub, COLOR_LABEL_DEFAULT, SUB_FONTS)

# One colour dropdown's value: the chosen palette name, or the default
# when the input is blank. All five colour inputs read through this.
def color_input(ctx, key, default):
    col = str(ctx.inputs.get(key, "")).strip()
    return col if col != "" else default

# The label is the eyebrow's left side: the configured one, else the
# view's name, else DEMO, so two instances (yours, your wife's) still
# say whose event is on screen.
def eyebrow_text(ctx, view_name):
    label = str(ctx.inputs.get("label", "")).strip().upper()
    if label == "":
        label = str(view_name).upper()  # the demo feed's view is called DEMO
    return label if label != "" else "CALENDAR"

# An all-day event's hero: TODAY while it runs, else its weekday.
def allday_hero(e, now):
    if e["start_unix"] <= now:
        return "TODAY"
    weekday = str(e.get("local", {}).get("weekday", "")).upper()
    return weekday[:3] if weekday != "" else "SOON"

# One event card. `page` is the page name (NOW / NEXT).
def card(c, e, now, page, view_name, ctx):
    words, col = phase(e, now, ctx)
    lcol = color_input(ctx, "labelcolor", COLOR_LABEL_DEFAULT)
    chrome(c, ctx, eyebrow_text(ctx, view_name), words, col, page,
           badge_of(e), badge_color(e, lcol))

    # Hero: the start time (or TODAY / weekday for all-day), phase-
    # coloured; the title under it in white, the largest that fits.
    hero = allday_hero(e, now) if e.get("all_day") else str(e["local"]["time"])
    hero_and_sub(c, hero, col, title_of(e), "white", TITLE_FONTS)

    # A running event shows its elapsed share along the bottom row.
    if is_running(e, now):
        total = e["end_unix"] - e["start_unix"]
        pct = 100 * (now - e["start_unix"]) // total if total > 0 else 0
        right = c.width - PAD
        c.progress_bar(TEXT_X, c.height - 1, right - TEXT_X, 1, pct, color = col, bg = COLOR_TRACK)

# ---- pages --------------------------------------------------------------

def now(c, ctx):
    feed, state = fetch_feed(ctx)
    if state == "offline":
        offline(c, ctx)
        return
    view_name = feed.get("view", {}).get("name", "")
    e = pick_now(feed.get("events", []), ctx.now.unix)
    if e == None:
        all_clear(c, ctx, view_name, "NOW", "NO EVENTS")
        return
    card(c, e, ctx.now.unix, "NOW", view_name, ctx)

def next(c, ctx):
    feed, state = fetch_feed(ctx)
    if state == "offline":
        offline(c, ctx)
        return
    view_name = feed.get("view", {}).get("name", "")
    events = feed.get("events", [])
    chosen = pick_now(events, ctx.now.unix)
    e = pick_next(events, chosen, ctx.now.unix)
    if e == None:
        all_clear(c, ctx, view_name, "NEXT", "NOTHING AFTER" if chosen != None else "NO EVENTS")
        return
    card(c, e, ctx.now.unix, "NEXT", view_name, ctx)
