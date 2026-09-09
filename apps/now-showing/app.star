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
    if r["status_code"] != 200:
        return None, "HTTP " + str(r["status_code"])
    j = r["json"]
    if not j:
        return None, "EMPTY RESPONSE"
    if j.get("Response", "") != "True":
        return None, str(j.get("Error", "LOOKUP FAILED")).upper()
    return j, None

def find_rt(ratings):
    for i in range(len(ratings)):
        if ratings[i].get("Source", "") == "Rotten Tomatoes":
            return ratings[i].get("Value", "N/A")
    return "N/A"

# Temporary preview harness: `_debug` = "movie" or "show" returns mock info
# so the two pages can be rendered without a real OMDb key. Not a real
# manifest input, so it's inert once shipped.
def _mock_info(kind):
    if kind == "show":
        return {
            "ok": True, "name": "THE BEAR", "year": "2022-", "genre": "COMEDY, DRAMA",
            "headline": "S1:E7 REVIEW", "runtime": "20 MIN", "imdb": "9.4", "rt": "94%",
        }
    return {
        "ok": True, "name": "DUNE: PART TWO", "year": "2024", "genre": "ACTION, ADVENTURE, DRAMA",
        "headline": "", "runtime": "166 MIN", "imdb": "8.5", "rt": "92%",
    }

def fetch_info(ctx):
    dbg = _s(ctx, "_debug", "")
    if dbg == "movie" or dbg == "show":
        return _mock_info(dbg)

    title = _s(ctx, "title", "")
    if not title:
        return {"ok": False, "title": "NO TITLE", "sub": "ENTER A TITLE"}

    omdbkey = _s(ctx, "omdbkey", "")
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
            return {"ok": False, "title": "TITLE NOT FOUND", "sub": err}
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
        return {"ok": False, "title": "TITLE NOT FOUND", "sub": serr}

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
# Two pages. TITLE: NOW / SHOWING stacked in a left column, name over genre to
# its right. DETAILS: RUNTIME (with the episode number if it's a show), then
# the IMDb + Rotten Tomatoes ratings row -- no header. Each row picks the
# biggest font its own content fits in.

EDGE_MARGIN = 6
ROW_FONTS = ["6x8", "5x7", "4x5"]  # largest first
FONT_H = {"6x8": 8, "5x7": 7, "4x5": 6}

SIDEBAR_W = 48   # left NOW / SHOWING column on the title page
DIVIDER_X = 50
CONTENT_X = 54

def _fit(c, text, font, max_w):
    t = text
    for _ in range(60):
        if c.text_width(t, font) <= max_w or len(t) <= 3:
            return t
        cut = t.rfind(" ")
        t = t[:cut] if cut > 0 else t[:len(t) - 1]
    return t

def _pick_font(c, chain, width_of, maxw):
    for f in chain:
        if width_of(f) <= maxw:
            return f
    return chain[len(chain) - 1]

def _draw_error(c, title, sub):
    c.text(title, c.width // 2, 10, font = "6x8", color = "white", align = "center")
    c.text(sub, c.width // 2, 20, font = "4x5", color = "white", align = "center")

def title(c, ctx):
    c.fill("black")
    info = fetch_info(ctx)
    if not info["ok"]:
        _draw_error(c, info["title"], info["sub"])
        return

    label_color = _s(ctx, "labelcolor", "#FFBF00")
    # Left column: NOW / SHOWING stacked, with a hairline divider -- the same
    # shape the 384 build used, just narrower.
    c.text("NOW", SIDEBAR_W // 2, 7, font = "6x8", color = label_color, align = "center")
    c.text("SHOWING", SIDEBAR_W // 2, 16, font = "6x8", color = label_color, align = "center")
    c.line(DIVIDER_X, 4, DIVIDER_X, 27, "#444444")

    # Right column: name over genre, vertically centred in what's left.
    maxw = c.width - CONTENT_X - EDGE_MARGIN
    cx = CONTENT_X + maxw // 2

    name_line = info["name"]
    if info["year"]:
        name_line += " (" + info["year"] + ")"

    nf = _pick_font(c, ROW_FONTS, lambda f: c.text_width(name_line, f), maxw)
    nh = FONT_H[nf]
    gap = 3
    y1 = (32 - (nh + gap + FONT_H["4x5"])) // 2
    y2 = y1 + nh + gap
    c.text(_fit(c, name_line, nf, maxw), cx, y1, font = nf, color = "white", align = "center")
    c.text(_fit(c, info["genre"], "4x5", maxw), cx, y2, font = "4x5", color = "gray", align = "center")

def details(c, ctx):
    c.fill("black")
    info = fetch_info(ctx)
    if not info["ok"]:
        _draw_error(c, info["title"], info["sub"])
        return

    maxw = c.width - EDGE_MARGIN * 2

    top_parts = []
    if info["headline"]:
        top_parts.append(info["headline"])
    if info["runtime"] != "N/A":
        top_parts.append("RUNTIME: " + info["runtime"])
    top_line = "   ".join(top_parts)

    have_imdb = info["imdb"] != "N/A"
    have_rt = info["rt"] != "N/A"
    have_ratings = have_imdb or have_rt
    imdb_str = "IMDB " + info["imdb"]

    def row_width(font):
        w = 0
        if have_imdb:
            w += c.text_width(imdb_str, font)
        if have_imdb and have_rt:
            w += 12
        if have_rt:
            w += TOMATO_W + 3 + c.text_width(info["rt"], font)
        return w

    if top_line == "" and not have_ratings:
        c.text("NO DETAILS AVAILABLE", c.width // 2, 16, font = "5x7", color = "gray", align = "center")
        return

    top_font = _pick_font(c, ROW_FONTS, lambda f: c.text_width(top_line, f), maxw) if top_line != "" else None
    rat_font = _pick_font(c, ROW_FONTS, row_width, maxw) if have_ratings else None
    top_h = FONT_H[top_font] if top_font else 0
    rat_h = FONT_H[rat_font] if rat_font else 0

    if top_line != "" and have_ratings:
        row_gap = 4
        y1 = (32 - (top_h + row_gap + rat_h)) // 2
        y2 = y1 + top_h + row_gap
    elif top_line != "":
        y1 = (32 - top_h) // 2
        y2 = 0
    else:
        y1 = 0
        y2 = (32 - rat_h) // 2

    if top_line != "":
        c.text(_fit(c, top_line, top_font, maxw), c.width // 2, y1, font = top_font, color = "white", align = "center")

    if have_ratings:
        # IMDB rating and/or a tomato + Rotten Tomatoes rating — each
        # color-coded, and each entirely absent (not "N/A") when unavailable.
        x = (c.width - row_width(rat_font)) // 2
        if have_imdb:
            c.text(imdb_str, x, y2, font = rat_font, color = imdb_color(info["imdb"]))
            x += c.text_width(imdb_str, rat_font) + 12
        if have_rt:
            c.bitmap(TOMATO_LEAF, x, y2, "green")
            c.bitmap(TOMATO_BODY, x, y2 + 1, "red")
            c.text(info["rt"], x + TOMATO_W + 3, y2, font = rat_font, color = rt_color(info["rt"]))
