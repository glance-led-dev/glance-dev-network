# Now Showing — one movie or TV episode/show, always on the panel. (192x32, 2 pages)
#
# Two pages, so each half gets a bigger font than a 192-wide single line
# could ever hold:
#   title   - NOW SHOWING label, then NAME (YEAR) as the hero, then GENRE
#   details - S#:E# EPISODE + RUNTIME, then IMDB rating + RT rating
#             (each color-coded red/amber/green)
#
# One lookup: omdbapi.com — title (+year, +season/episode) -> ratings, genre,
# runtime. Needs the user's own free API key (omdbapi.com/apikey.aspx).
# This platform's install form is filled in once — there's no live search-as-
# you-type autocomplete, so the title is typed exactly and OMDb resolves it.
# An optional year narrows down remakes/reboots that share a title.

# ---------- input ----------

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _clean(v, fallback):
    if v == None or v == "" or v == "N/A":
        return fallback
    return v

# OMDb's "Year" field for shows is a range like "2008–2013" (or "2016–" if
# still running) using a Unicode en-dash — a glyph the bitmap fonts don't
# have, so it silently drops instead of erroring. Swap it for a plain hyphen.
def _clean_year(v):
    y = _clean(v, "")
    if not y:
        return ""
    return y.replace("–", "-").replace("—", "-").rstrip("-")

# ---------- OMDb ----------

def omdb_get(params):
    r = http.get("https://www.omdbapi.com/", params = params, ttl_seconds = 86400)
    if r["status_code"] == 401:
        return None, "KEY"
    if r["status_code"] != 200:
        return None, "HTTP " + str(r["status_code"])
    j = r["json"]
    if not j:
        return None, "EMPTY RESPONSE"
    if j.get("Response", "") != "True":
        return None, str(j.get("Error", "LOOKUP FAILED")).upper()
    return j, None

# Turn an omdb_get error into the two-line error screen.
def _fail(err):
    if err == "KEY" or "API KEY" in err:
        return {"ok": False, "title": "BAD API KEY", "sub": "CHECK OMDB KEY"}
    if err.startswith("HTTP"):
        return {"ok": False, "title": "OMDB UNAVAILABLE", "sub": "WILL RETRY"}
    return {"ok": False, "title": "TITLE NOT FOUND", "sub": "CHECK TITLE OR YEAR"}

def find_rt(ratings):
    for i in range(len(ratings)):
        if ratings[i].get("Source", "") == "Rotten Tomatoes":
            return ratings[i].get("Value", "N/A")
    return "N/A"

# Sample info. Shown, labelled DEMO, when nothing is set up yet (no title and
# no key) — that's also what the catalog preview renders. `_debug` = "show"
# (not a manifest input, so inert once shipped) renders the episode layout.
def _mock_info(kind):
    if kind == "show":
        return {
            "ok": True, "demo": True, "name": "THE BEAR", "year": "2022", "genre": "COMEDY, DRAMA",
            "headline": "S1:E7 REVIEW", "runtime": "20 MIN", "imdb": "9.4", "rt": "94%",
        }
    return {
        "ok": True, "demo": True, "name": "INTERSTELLAR", "year": "2014", "genre": "ADVENTURE, DRAMA, SCI-FI",
        "headline": "", "runtime": "169 MIN", "imdb": "8.7", "rt": "73%",
    }

def fetch_info(ctx):
    dbg = _s(ctx, "_debug", "")
    if dbg == "movie" or dbg == "show":
        return _mock_info(dbg)

    title = _s(ctx, "title", "")
    omdbkey = _s(ctx, "omdbkey", "")
    if not title and not omdbkey:
        return _mock_info("movie")
    if not title:
        return {"ok": False, "title": "NO TITLE", "sub": "ENTER A TITLE"}
    if not omdbkey:
        return {"ok": False, "title": "NO API KEY", "sub": "ADD OMDB KEY"}

    year = _s(ctx, "year", "")
    is_show = _s(ctx, "mediatype", "Movie") == "Show"
    season = _s(ctx, "season", "")
    episode = _s(ctx, "episode", "")

    if not is_show:
        params = {"apikey": omdbkey, "t": title, "type": "movie"}
        if year:
            params["y"] = year
        j, err = omdb_get(params)
        if j == None:
            return _fail(err)
        return {
            "ok": True,
            "name": str(j.get("Title", title)).upper(),
            "year": _clean_year(j.get("Year")),
            "headline": "",
            "runtime": _clean(j.get("Runtime"), "N/A").upper(),
            "genre": _clean(j.get("Genre"), "N/A").upper(),
            "imdb": _clean(j.get("imdbRating"), "N/A"),
            "rt": find_rt(j.get("Ratings", [])),
        }

    # Show: fetch series-level data first — it has the canonical title and
    # genre, which an episode-specific lookup often doesn't carry.
    series_params = {"apikey": omdbkey, "t": title, "type": "series"}
    if year:
        series_params["y"] = year
    sj, serr = omdb_get(series_params)
    if sj == None:
        return _fail(serr)

    name = str(sj.get("Title", title)).upper()
    # Default to the series' full run; a specific episode below narrows this
    # down to just that episode's air year.
    display_year = _clean_year(sj.get("Year"))
    genre = _clean(sj.get("Genre"), "N/A").upper()
    runtime = _clean(sj.get("Runtime"), "N/A").upper()
    imdb = _clean(sj.get("imdbRating"), "N/A")
    rt = find_rt(sj.get("Ratings", []))
    headline = ""

    if season and episode:
        ep_params = {"apikey": omdbkey, "t": title, "Season": season, "Episode": episode}
        if year:
            ep_params["y"] = year
        ej, eerr = omdb_get(ep_params)
        if ej == None:
            headline = "S" + season + ":E" + episode + " (NOT FOUND)"
        else:
            headline = "S" + season + ":E" + episode + " " + str(ej.get("Title", "")).upper()
            ep_runtime = _clean(ej.get("Runtime"), None)
            if ep_runtime:
                runtime = ep_runtime.upper()
            ep_imdb = _clean(ej.get("imdbRating"), None)
            if ep_imdb:
                imdb = ep_imdb
            # "Year" on an episode lookup is just that episode's air year;
            # fall back to the "Released" date's first 4 chars if OMDb
            # omits it for this title.
            ep_year = _clean_year(ej.get("Year"))
            if not ep_year:
                released = _clean(ej.get("Released"), "")
                if len(released) >= 4:
                    ep_year = released[:4]
            if ep_year:
                display_year = ep_year

    return {
        "ok": True,
        "name": name,
        "year": display_year,
        "headline": headline,
        "runtime": runtime,
        "genre": genre,
        "imdb": imdb,
        "rt": rt,
    }

# ---------- rating colors ----------

def imdb_color(s):
    if s == "N/A":
        return "gray"
    v = float(s)
    if v >= 7.0:
        return "green"
    if v >= 5.5:
        return "amber"
    return "red"

def rt_color(s):
    if s == "N/A":
        return "gray"
    v = float(s.replace("%", ""))
    if v >= 75.0:
        return "green"
    if v >= 50.0:
        return "amber"
    return "red"

# A small two-tone tomato in place of a "RT" label — bitmap fonts have no
# emoji glyphs (confirmed: a tomato emoji silently draws nothing), so this is
# the closest a 🍅 gets on an LED panel.
TOMATO_LEAF = [[0, 1, 0, 1, 0, 1, 0]]
TOMATO_BODY = [
    [0, 0, 1, 1, 1, 0, 0],
    [0, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 0],
]
TOMATO_W = 7

# ---------- pages ----------
# TITLE:   a bulb-lit NOW / SHOWING marquee sign on the left, the title as
#          the hero on the right, year + genre (or S#:E# episode) under it.
# DETAILS: up to three stat columns — RUNTIME (clock), IMDB (yellow badge),
#          CRITICS (tomato) — each a small labelled header over a big value.
#          A column with no data is dropped and the rest re-centre.

SAFE_L = 10      # scroll safe zone on a 192-wide app
SAFE_R = 181

SIGN_X0 = 10     # marquee sign box
SIGN_X1 = 56
SIGN_Y0 = 2
SIGN_Y1 = 29
HERO_X0 = 64     # title column

HERO_FONTS = ["7x12", "6x8", "5x7", "4x5"]  # largest first
FONT_H = {"8x12": 12, "7x12": 12, "6x8": 8, "5x7": 7, "4x5": 5}

# 7x12 is the cleanest big face (8x12's "I" is a solid block) but it only has
# letters, digits, space, "." and "-" — anything else would silently vanish,
# so a title with other punctuation steps down to 6x8.
HERO_SAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .-"

IMDB_YELLOW = "#F5C518"

CLOCK = [
    [0, 0, 1, 1, 1, 0, 0],
    [0, 1, 0, 0, 0, 1, 0],
    [1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 1, 0, 1],
    [0, 1, 0, 0, 0, 1, 0],
    [0, 0, 1, 1, 1, 0, 0],
]

# The bitmap fonts have no apostrophe; drop it rather than leave a gap.
def _glyphs(s):
    return s.replace("'", "").replace("’", "")

def _fit(c, text, font, max_w):
    t = text
    for _ in range(60):
        if c.text_width(t, font) <= max_w or len(t) <= 3:
            return t
        cut = t.rfind(" ")
        t = t[:cut] if cut > 0 else t[:len(t) - 1]
    return t

def _hero_ok(text):
    for ch in text.elems():
        if ch not in HERO_SAFE:
            return False
    return True

def _pick_font(c, chain, text, maxw):
    for f in chain:
        if f == "7x12" and not _hero_ok(text):
            continue
        if c.text_width(text, f) <= maxw:
            return f
    return chain[len(chain) - 1]

# "169 MIN" -> "2H 49M", "45 MIN" -> "45M". Anything unexpected passes through.
def _runtime(s):
    if s == "N/A":
        return s
    n = s.split(" ")[0]
    if not n.isdigit():
        return s
    m = int(n)
    if m < 60:
        return str(m) + "M"
    if m % 60 == 0:
        return str(m // 60) + "H"
    return str(m // 60) + "H " + str(m % 60) + "M"

def _demo_tag(c, info):
    if info.get("demo"):
        c.text("DEMO", SAFE_R, 1, font = "3x4", color = "gray", align = "right")

def _draw_error(c, title, sub):
    c.text(title, c.width // 2, 8, font = "6x8", color = "white", align = "center")
    c.text(sub, c.width // 2, 19, font = "5x7", color = "gray", align = "center")

def _marquee(c, color):
    # Dotted bulb border, one lit pixel every other step, corners included.
    for x in range(SIGN_X0, SIGN_X1 + 1, 2):
        c.pixel(x, SIGN_Y0, color)
        c.pixel(x, SIGN_Y1, color)
    for y in range(SIGN_Y0, SIGN_Y1 + 1, 2):
        c.pixel(SIGN_X0, y, color)
        c.pixel(SIGN_X1, y, color)
    cx = (SIGN_X0 + SIGN_X1 + 1) // 2
    c.text("NOW", cx, 7, font = "5x7", color = color, align = "center")
    c.text("SHOWING", cx, 18, font = "5x7", color = color, align = "center")

def title(c, ctx):
    c.fill("black")
    info = fetch_info(ctx)
    if not info["ok"]:
        _draw_error(c, info["title"], info["sub"])
        return

    label_color = _s(ctx, "labelcolor", "#FFBF00")
    _marquee(c, label_color)

    maxw = SAFE_R - HERO_X0 + 1
    cx = HERO_X0 + maxw // 2

    name = _glyphs(info["name"])
    nf = _pick_font(c, HERO_FONTS, name, maxw)
    name = _fit(c, name, nf, maxw)

    # Sub-line: the episode for a show, otherwise year (accent) + genre (gray).
    sub_font = "5x7"
    gap = 4
    nh = FONT_H[nf]
    y1 = (32 - (nh + gap + FONT_H[sub_font])) // 2
    if info.get("demo"):
        y1 = max(y1, 7)  # clear the DEMO tag
    y2 = y1 + nh + gap

    c.text(name, cx, y1, font = nf, color = "white", align = "center")

    if info["headline"]:
        ep = _glyphs(info["headline"])
        sf = _pick_font(c, ["5x7", "4x5"], ep, maxw)
        c.text(_fit(c, ep, sf, maxw), cx, y2 + (7 - FONT_H[sf]) // 2, font = sf, color = label_color, align = "center")
    else:
        year = info["year"]
        genre = _glyphs(info["genre"])
        if genre == "N/A":
            genre = ""
        sep = 6 if year and genre else 0
        yw = c.text_width(year, sub_font) if year else 0
        genre = _fit(c, genre, sub_font, maxw - yw - sep).rstrip(", ") if genre else ""
        gw = c.text_width(genre, sub_font) if genre else 0
        x = cx - (yw + sep + gw) // 2
        if year:
            c.text(year, x, y2, font = sub_font, color = label_color)
        if genre:
            c.text(genre, x + yw + sep, y2, font = sub_font, color = "gray")

    _demo_tag(c, info)

# Column headers — each draws centred on cx at row y and is 7px tall.
def _hdr_runtime(c, cx, y):
    w = 7 + 3 + c.text_width("RUNTIME", "4x5")
    x = cx - w // 2
    c.bitmap(CLOCK, x, y, "white")
    c.text("RUNTIME", x + 10, y + 1, font = "4x5", color = "gray")

def _hdr_imdb(c, cx, y):
    tw = c.text_width("IMDB", "4x5")
    x0 = cx - (tw + 4) // 2
    c.rect(x0, y, x0 + tw + 3, y + 6, fill = IMDB_YELLOW)
    c.text("IMDB", x0 + 2, y + 1, font = "4x5", color = "black")

def _hdr_rt(c, cx, y):
    w = 7 + 3 + c.text_width("CRITICS", "4x5")
    x = cx - w // 2
    c.bitmap(TOMATO_LEAF, x, y, "green")
    c.bitmap(TOMATO_BODY, x, y + 1, "red")
    c.text("CRITICS", x + 10, y + 1, font = "4x5", color = "gray")

def details(c, ctx):
    c.fill("black")
    info = fetch_info(ctx)
    if not info["ok"]:
        _draw_error(c, info["title"], info["sub"])
        return

    cols = []
    if info["runtime"] != "N/A":
        cols.append((_hdr_runtime, _runtime(info["runtime"]), "white"))
    if info["imdb"] != "N/A":
        cols.append((_hdr_imdb, info["imdb"], imdb_color(info["imdb"])))
    if info["rt"] != "N/A":
        cols.append((_hdr_rt, info["rt"], rt_color(info["rt"])))

    if not cols:
        c.text("NO DETAILS", c.width // 2, 8, font = "6x8", color = "white", align = "center")
        c.text("OMDB HAS NO RATINGS YET", c.width // 2, 19, font = "5x7", color = "gray", align = "center")
        _demo_tag(c, info)
        return

    n = len(cols)
    span = SAFE_R - SAFE_L + 1
    colw = span // n
    hdr_y = 6
    val_y = 17
    for i in range(n):
        hdr, val, color = cols[i]
        x0 = SAFE_L + i * colw
        cx = x0 + colw // 2
        if i > 0:
            c.line(x0, 6, x0, 25, "#333333")
        hdr(c, cx, hdr_y)
        vf = _pick_font(c, ["8x12", "6x8"], val, colw - 4)
        c.text(val, cx, val_y + (12 - FONT_H[vf]) // 2, font = vf, color = color, align = "center")

    _demo_tag(c, info)
