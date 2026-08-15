# Now Showing — one movie or TV episode/show, always on the panel. (320x32, 1 page)
#
# Layout: a stacked "NOW / SHOWING" label on the left, then three lines:
#   1. NAME  S#:E# EPISODE  (RUNTIME)
#   2. GENRE
#   3. IMDB rating   RT rating          (each color-coded red/amber/green)
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
    r = http.get("https://www.omdbapi.com/", params = params, ttl_seconds = 3600)
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

def fetch_info(ctx):
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

# ---------- page ----------

SIDEBAR_W = 56
DIVIDER_X = 58
CONTENT_X = 64
RIGHT_DIVIDER_GAP = 6
RIGHT_EDGE_MARGIN = 6

LINE_H = {"6x8": 8, "5x7": 7, "4x5": 6}
CONTENT_FONTS = ["6x8", "5x7", "4x5"]  # largest first

def fit_text(c, text, font, max_w):
    # Shrink to whole words first (no mid-word cuts), then char-by-char only
    # if a single word still doesn't fit. Backstop for a panel narrow enough
    # (192px here, vs. the 384px the loop above was tuned for) that even the
    # smallest font in CONTENT_FONTS can still overflow a long title/genre.
    t = text
    for _ in range(60):
        if c.text_width(t, font) <= max_w or len(t) <= 3:
            return t
        cut = t.rfind(" ")
        t = t[:cut] if cut > 0 else t[:len(t) - 1]
    return t

def main(c, ctx):
    c.fill("black")

    info = fetch_info(ctx)
    if not info["ok"]:
        c.text(info["title"], c.width // 2, 10, font = "6x8", color = "white", align = "center")
        c.text(info["sub"], c.width // 2, 20, font = "4x5", color = "white", align = "center")
        return

    label_color = _s(ctx, "labelcolor", "#FFBF00")

    # Left sidebar: NOW / SHOWING stacked, vertically centered.
    c.text("NOW", SIDEBAR_W // 2, 7, font = "6x8", color = label_color, align = "center")
    c.text("SHOWING", SIDEBAR_W // 2, 16, font = "6x8", color = label_color, align = "center")
    c.line(DIVIDER_X, 4, DIVIDER_X, 28, "#444444")

    right_divider_x = c.width - RIGHT_EDGE_MARGIN
    c.line(right_divider_x, 4, right_divider_x, 28, "#444444")
    maxw = right_divider_x - RIGHT_DIVIDER_GAP - CONTENT_X

    line1 = info["name"]
    if info["year"]:
        line1 += " (" + info["year"] + ")"
    if info["headline"]:
        line1 += " " + info["headline"]
    if info["runtime"] != "N/A":
        line1 += " - " + info["runtime"]

    have_imdb = info["imdb"] != "N/A"
    have_rt = info["rt"] != "N/A"
    imdb_str = "IMDB " + info["imdb"]

    def row3_width(font):
        w = 0
        if have_imdb:
            w += c.text_width(imdb_str, font)
        if have_imdb and have_rt:
            w += 12
        if have_rt:
            w += TOMATO_W + 3 + c.text_width(info["rt"], font)
        return w

    # All three rows share one font: the largest tier where name/episode/
    # runtime, genre, and ratings each fit on their single line. The panel
    # is 384px wide specifically so this rarely has to drop below 6x8.
    font = CONTENT_FONTS[len(CONTENT_FONTS) - 1]
    for f in CONTENT_FONTS:
        if (c.text_width(line1, f) <= maxw and
            c.text_width(info["genre"], f) <= maxw and
            row3_width(f) <= maxw):
            font = f
            break

    h = LINE_H[font]
    y1 = 2
    y2 = y1 + h + 2
    y3 = y2 + h + 3  # a touch more clearance: the tomato hangs below its own baseline

    c.text(fit_text(c, line1, font, maxw), CONTENT_X, y1, font = font, color = "white")
    c.text(fit_text(c, info["genre"], font, maxw), CONTENT_X, y2, font = font, color = "gray")

    # If even the smallest font can't fit both ratings on row 3, drop RT --
    # IMDB alone still says something; the two together would just overflow.
    if row3_width(font) > maxw:
        have_rt = False

    # IMDB rating and/or a tomato + Rotten Tomatoes rating — each
    # color-coded, and each entirely absent (not "N/A") when unavailable.
    # Tomato and text share row 3's baseline with the IMDB rating.
    x = CONTENT_X
    if have_imdb:
        c.text(imdb_str, x, y3, font = font, color = imdb_color(info["imdb"]))
        x += c.text_width(imdb_str, font) + 12
    if have_rt:
        c.bitmap(TOMATO_LEAF, x, y3, "green")
        c.bitmap(TOMATO_BODY, x, y3 + 1, "red")
        c.text(info["rt"], x + TOMATO_W + 3, y3, font = font, color = rt_color(info["rt"]))
