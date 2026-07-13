# Now Playing — the top 5 movies in theaters, from The Movie Database (TMDB).
#
# Built with an AI over a few iterations; see the "Build with AI" example page.
# Text (titles + ratings) refreshes live from TMDB when a key is set; the posters
# are a bundled snapshot of the current top 5 (GDN draws bundled PNGs, so the
# poster pack is refreshed periodically rather than fetched per render).

# A tiny 5x4 star, lit for the rating.
STAR = [
    [0, 0, 1, 0, 0],
    [1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0],
    [1, 1, 0, 1, 1],
]

# Accent colors for live results (the bundled sample carries its own, sampled
# from each poster).
PALETTE = ["#C65967", "#279AC6", "#C6AA00", "#2439C6", "#00C1C6"]

# Bundled snapshot (also the offline fallback). Accents were sampled from posters.
SAMPLE = [
    {"title": "TOY STORY 5", "vote": 7.4, "accent": "#C65967", "poster": "poster1.png"},
    {"title": "DISCLOSURE DAY", "vote": 6.7, "accent": "#279AC6", "poster": "poster2.png"},
    {"title": "BACKROOMS", "vote": 6.8, "accent": "#C6AA00", "poster": "poster3.png"},
    {"title": "SCARY MOVIE", "vote": 5.4, "accent": "#2439C6", "poster": "poster4.png"},
    {"title": "THE FURIOUS", "vote": 7.6, "accent": "#00C1C6", "poster": "poster5.png"},
]


def _fmt(v):
    v = float(v)
    whole = int(v)
    dec = int((v - whole) * 10 + 0.5)
    if dec >= 10:
        whole += 1
        dec = 0
    return str(whole) + "." + str(dec)


def _movies(ctx):
    key = ctx.inputs.get("tmdb_key", "")
    if key == "":
        return SAMPLE
    resp = http.get(
        "https://api.themoviedb.org/3/movie/now_playing",
        params = {
            "api_key": key,
            "region": ctx.inputs.get("region", "US"),
            "language": "en-US",
            "page": "1",
        },
        ttl_seconds = 3600,
    )
    if resp["status_code"] != 200 or resp["json"] == None:
        return SAMPLE
    res = resp["json"].get("results", [])
    out = []
    for i in range(len(res)):
        if len(out) >= 5:
            break
        m = res[i]
        out.append({
            "title": str(m["title"]).upper(),
            "vote": m.get("vote_average", 0.0),
            "accent": PALETTE[len(out)],
            "poster": "poster" + str(len(out) + 1) + ".png",
        })
    return out


def _page(c, ctx, i):
    movies = _movies(ctx)
    c.fill("black")
    if i >= len(movies):
        c.text("NO DATA", 64, 13, font = "5x7", color = "gray", align = "center")
        return
    m = movies[i]

    # poster (bundled, native 21x32) + accent stripe
    c.image(m["poster"], 0, 0)
    c.rect(22, 0, 24, 31, fill = m["accent"])

    tx = 28
    # rank badge, top-right, in the movie's accent color
    c.round_rect(112, 1, 126, 13, 2, fill = m["accent"])
    c.text(str(i + 1), 119, 3, font = "5x7", color = "black", align = "center")

    # title, wrapped to two lines
    c.text_wrapped(m["title"], tx, 1, 80, font = "5x7", color = "white", max_lines = 2)

    # rating: gold stars + a color-coded score
    full = int(float(m["vote"]) / 2.0 + 0.5)
    sx = tx
    for s in range(5):
        c.bitmap(STAR, sx, 24, "#FFC400" if s < full else "#4a4a2a")
        sx += 6

    vote = float(m["vote"])
    scol = "green" if vote >= 7.0 else ("amber" if vote >= 6.0 else "red")
    c.text(_fmt(vote), 126, 23, font = "5x7", color = scol, align = "right")


# One function per page. movie_1 is page 1 (the #1 film), movie_2 is page 2, etc.
def movie_1(c, ctx):
    _page(c, ctx, 0)


def movie_2(c, ctx):
    _page(c, ctx, 1)


def movie_3(c, ctx):
    _page(c, ctx, 2)


def movie_4(c, ctx):
    _page(c, ctx, 3)


def movie_5(c, ctx):
    _page(c, ctx, 4)
