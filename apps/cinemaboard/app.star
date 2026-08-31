# CinemaBoard — Glance Scroll Premier movie-theater marquee
# Data: TMDB for theatrical movie metadata. Genuine weekend gross data is an
# optional provider, deliberately isolated behind fetch_boxoffice().

TMDB_BASE = "https://api.themoviedb.org/3"
TMDB_TTL = 21600          # 6 hours
BOXOFFICE_TTL = 43200    # 12 hours

GOLD = "amber"
TITLE = "white"
MONEY = "green"
RANK = "cyan"
SECONDARY = "gray"
ERROR = "red"
BORDER = "#303030"

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
GENRES = {
    28: "ACTION", 12: "ADVENTURE", 16: "ANIMATION", 35: "COMEDY",
    80: "CRIME", 99: "DOC", 18: "DRAMA", 10751: "FAMILY",
    14: "FANTASY", 36: "HISTORY", 27: "HORROR", 10402: "MUSIC",
    9648: "MYSTERY", 10749: "ROMANCE", 878: "SCI-FI", 10770: "TV",
    53: "THRILLER", 10752: "WAR", 37: "WESTERN",
}
ALLOWED = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,:;!?&'\"-/()+#$%"

# ---------- inputs / sanitizing ----------

def _input(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _bool(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == True:
        return True
    if v == False:
        return False
    s = str(v).strip().upper()
    return s == "TRUE" or s == "YES" or s == "1" or s == "ON"

def _int_input(ctx, key, fallback):
    s = _input(ctx, key, str(fallback))
    if not _all_digits(s):
        return fallback
    return int(s)

def cfg(ctx):
    # Validation requires every manifest input to be read. Centralizing config
    # also makes page fallback/dispatch consistent.
    return {
        "tmdbapikey": _input(ctx, "tmdbapikey", ""),
        "region": _input(ctx, "region", "US").upper(),
        "language": _input(ctx, "language", "en-US"),
        "count": _int_input(ctx, "moviecount", 5),
        "showboxoffice": _bool(ctx, "showboxoffice", True),
        "shownowplaying": _bool(ctx, "shownowplaying", True),
        "shownewreleases": _bool(ctx, "shownewreleases", True),
        "showcomingsoon": _bool(ctx, "showcomingsoon", True),
        "showspotlight": _bool(ctx, "showspotlight", True),
        "showratings": _bool(ctx, "showratings", True),
        "showcountdown": _bool(ctx, "showcountdown", True),
        "showmessage": _bool(ctx, "showmessage", False),
        "custommessage": _input(ctx, "custommessage", "WELCOME TO THE CINEMA"),
        "boxofficeurl": _input(ctx, "boxofficeurl", ""),
    }

def clean_text(v, fallback):
    if v == None:
        return fallback
    s = str(v).upper()
    s = s.replace("&AMP;", "&")
    s = s.replace("–", "-").replace("—", "-").replace("’", "'").replace("‘", "'")
    s = s.replace("“", "\"").replace("”", "\"").replace("É", "E")
    out = ""
    for i in range(len(s)):
        ch = s[i]
        if ch in ALLOWED:
            out += ch
        else:
            out += " "
    out = compact_spaces(out).strip()
    if out == "":
        return fallback
    return out

def compact_spaces(s):
    out = ""
    prev = False
    for i in range(len(s)):
        ch = s[i]
        if ch == " ":
            if not prev:
                out += ch
            prev = True
        else:
            out += ch
            prev = False
    return out

# ---------- date helpers ----------

def _all_digits(s):
    if s == None or len(str(s)) == 0:
        return False
    t = str(s)
    for i in range(len(t)):
        if not (t[i] >= "0" and t[i] <= "9"):
            return False
    return True

def parse_ymd(s):
    if s == None:
        return None
    t = str(s)
    if len(t) < 10:
        return None
    y = t[0:4]
    m = t[5:7]
    d = t[8:10]
    if t[4:5] != "-" or t[7:8] != "-":
        return None
    if not (_all_digits(y) and _all_digits(m) and _all_digits(d)):
        return None
    yy = int(y)
    mm = int(m)
    dd = int(d)
    if mm < 1 or mm > 12 or dd < 1 or dd > 31:
        return None
    return {"year": yy, "month": mm, "day": dd, "days": days_from_civil(yy, mm, dd)}

def days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def today_days(ctx):
    return days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)

def fmt_date(s):
    p = parse_ymd(s)
    if p == None:
        return "DATE TBA"
    return MONTHS[p["month"] - 1] + " " + str(p["day"])

# ---------- TMDB provider ----------

def tmdb_get(conf, path, params):
    if conf["tmdbapikey"] == "":
        return {"ok": False, "error": "ADD TMDB API KEY", "movies": []}
    p = {
        "api_key": conf["tmdbapikey"],
        "language": conf["language"],
        "region": conf["region"],
        "page": "1",
    }
    for k in params:
        p[k] = params[k]
    r = http.get(TMDB_BASE + path, params = p, ttl_seconds = TMDB_TTL)
    if r["status_code"] != 200:
        if r["status_code"] == 401:
            return {"ok": False, "error": "TMDB KEY REJECTED", "movies": []}
        if r["status_code"] == 429:
            return {"ok": False, "error": "TMDB RATE LIMITED", "movies": []}
        return {"ok": False, "error": "TMDB HTTP " + str(r["status_code"]), "movies": []}
    j = r["json"]
    if j == None or not ("results" in j):
        return {"ok": False, "error": "TMDB BAD DATA", "movies": []}
    raw = j.get("results", [])
    movies = []
    limit = conf["count"]
    if limit < 1:
        limit = 5
    for i in range(len(raw)):
        if len(movies) >= limit:
            break
        m = parse_movie(raw[i])
        if m != None:
            movies.append(m)
    if len(movies) == 0:
        return {"ok": False, "error": "NO MOVIES FOUND", "movies": []}
    return {"ok": True, "error": "", "movies": movies}

def parse_movie(m):
    if m == None:
        return None
    title = clean_text(m.get("title", m.get("name", "")), "UNTITLED")
    rel = str(m.get("release_date", ""))
    vote = m.get("vote_average", 0)
    vcount = m.get("vote_count", 0)
    pop = m.get("popularity", 0)
    gids = m.get("genre_ids", [])
    genre = "MOVIE"
    if len(gids) > 0:
        genre = GENRES.get(gids[0], "MOVIE")
    return {"title": title, "release": rel, "vote": vote, "votes": vcount, "pop": pop, "genre": genre}

def fetch_now(conf):
    return tmdb_get(conf, "/movie/now_playing", {})

def fetch_upcoming(conf):
    return tmdb_get(conf, "/movie/upcoming", {})

def pick_slot(ctx, movies):
    if len(movies) == 0:
        return None
    slot = ctx.now.yday * 4 + (ctx.now.hour // 6)
    return movies[slot % len(movies)]

# ---------- Optional box-office provider ----------

def fetch_boxoffice(conf):
    url = conf["boxofficeurl"]
    if url == "":
        return {"ok": False, "configured": False, "error": "NO BOX OFFICE PROVIDER", "rows": []}
    if not (url.startswith("https://") or url.startswith("http://")):
        return {"ok": False, "configured": True, "error": "BOX OFFICE URL BAD", "rows": []}
    r = http.get(url, ttl_seconds = BOXOFFICE_TTL)
    if r["status_code"] != 200:
        return {"ok": False, "configured": True, "error": "BOX OFFICE HTTP " + str(r["status_code"]), "rows": []}
    j = r["json"]
    if j == None:
        return {"ok": False, "configured": True, "error": "BOX OFFICE BAD JSON", "rows": []}
    arr = []
    if type(j) == "list":
        arr = j
    else:
        arr = j.get("movies", j.get("results", j.get("boxoffice", [])))
    rows = []
    for i in range(len(arr)):
        if len(rows) >= 5:
            break
        item = arr[i]
        title = clean_text(item.get("title", item.get("name", "")), "UNTITLED")
        gross = money_short(item.get("weekendGross", item.get("weekend_gross", item.get("gross", item.get("weekend", "")))))
        rank = clean_text(item.get("rank", str(i + 1)), str(i + 1))
        if gross == "":
            gross = "N/A"
        rows.append({"rank": rank, "title": title, "gross": gross})
    if len(rows) == 0:
        return {"ok": False, "configured": True, "error": "NO BOX OFFICE ROWS", "rows": []}
    return {"ok": True, "configured": True, "error": "", "rows": rows}

def money_short(v):
    if v == None:
        return ""
    s = str(v).strip().upper()
    if s == "":
        return ""
    if "$" in s or "M" in s or "K" in s or "B" in s:
        return clean_text(s, "")
    whole = s
    dot = s.find(".")
    if dot >= 0:
        whole = s[:dot]
    if not _all_digits(whole):
        return clean_text(s, "")
    n = int(whole)
    if n >= 1000000000:
        return "$" + str(n // 1000000000) + "." + str((n % 1000000000) // 100000000) + "B"
    if n >= 1000000:
        return "$" + str(n // 1000000) + "." + str((n % 1000000) // 100000) + "M"
    if n >= 1000:
        return "$" + str(n // 1000) + "K"
    return "$" + str(n)

# ---------- formatting / drawing helpers ----------

def rating_text(m):
    v = m.get("vote", 0)
    if v == None or v <= 0:
        return "TMDB N/R"
    n = int(v * 10 + 0.5)
    return "TMDB " + str(n // 10) + "." + str(n % 10)

def fit_text(c, s, font, max_w):
    t = clean_text(s, "")
    if c.text_width(t, font) <= max_w:
        return t
    suffix = "..."
    for _ in range(120):
        if len(t) <= 3:
            return t
        t = t[:len(t) - 1].strip()
        if c.text_width(t + suffix, font) <= max_w:
            return t + suffix
    return t

def best_font(c, s, fonts, max_w):
    for f in fonts:
        if c.text_width(clean_text(s, ""), f) <= max_w:
            return f
    return fonts[len(fonts) - 1]

def draw_frame(c):
    c.fill("black")
    c.rect(0, 0, c.width - 1, c.height - 1, outline = BORDER)
    c.line(1, 30, c.width - 2, 30, "#202020")

def draw_header(c, text, color):
    c.text(clean_text(text, "CINEMABOARD"), 8, 1, font = "5x7", color = color)
    c.line(8, 9, c.width - 9, 9, "#222222")

def draw_setup(c, title, sub, color):
    draw_frame(c)
    c.text(clean_text(title, "CINEMABOARD"), c.width // 2, 8, font = "7x12", color = color, align = "center")
    c.text(fit_text(c, sub, "5x7", c.width - 16), c.width // 2, 22, font = "5x7", color = SECONDARY, align = "center")

def draw_feature(c, header, movie, footer, accent):
    draw_frame(c)
    draw_header(c, header, accent)
    title = movie["title"]
    # Leave room for the footer; 16x20 is tempting but crowds a 32px sign.
    font = best_font(c, title, ["10x16_bold", "10x14", "7x12", "6x8"], c.width - 24)
    c.text(fit_text(c, title, font, c.width - 24), c.width // 2, 11, font = font, color = TITLE, align = "center")
    c.text(fit_text(c, footer, "5x7", c.width - 24), c.width // 2, 24, font = "5x7", color = SECONDARY, align = "center")

def draw_direct(kind, c, ctx, conf):
    if kind == "boxoffice":
        draw_boxoffice(c, ctx, conf)
    elif kind == "nowplaying":
        draw_nowplaying(c, ctx, conf)
    elif kind == "newreleases":
        draw_newreleases(c, ctx, conf)
    elif kind == "comingsoon":
        draw_comingsoon(c, ctx, conf)
    elif kind == "spotlight":
        draw_spotlight(c, ctx, conf)
    elif kind == "ratings":
        draw_ratings(c, ctx, conf)
    elif kind == "countdown":
        draw_countdown(c, ctx, conf)
    elif kind == "message":
        draw_message(c, ctx, conf)
    else:
        draw_credits(c, ctx, conf)

def enabled(conf, kind):
    return conf.get("show" + kind, True)

def dispatch(kind, c, ctx):
    conf = cfg(ctx)
    if enabled(conf, kind):
        draw_direct(kind, c, ctx, conf)
        return
    order = ["boxoffice", "nowplaying", "newreleases", "comingsoon", "spotlight", "ratings", "countdown", "message"]
    for i in range(len(order)):
        if enabled(conf, order[i]):
            draw_direct(order[i], c, ctx, conf)
            return
    draw_credits(c, ctx, conf)

# ---------- page bodies ----------

def draw_boxoffice(c, ctx, conf):
    bo = fetch_boxoffice(conf)
    draw_frame(c)
    draw_header(c, "WEEKEND BOX OFFICE", GOLD)
    if not bo["ok"]:
        c.text("GROSS DATA", c.width // 2, 11, font = "10x14", color = TITLE, align = "center")
        msg = "ADD PROVIDER JSON URL" if not bo["configured"] else bo["error"]
        c.text(fit_text(c, msg, "5x7", c.width - 20), c.width // 2, 25, font = "5x7", color = ERROR if bo["configured"] else SECONDARY, align = "center")
        return
    rows = bo["rows"]
    y = 11
    for i in range(len(rows)):
        if i >= 3:
            break
        r = rows[i]
        c.text("#" + fit_text(c, r["rank"], "5x7", 18), 8, y, font = "5x7", color = RANK)
        c.text(fit_text(c, r["title"], "5x7", c.width - 115), 34, y, font = "5x7", color = TITLE)
        c.text(fit_text(c, r["gross"], "5x7", 78), c.width - 8, y, font = "5x7", color = MONEY, align = "right")
        y += 7

def draw_nowplaying(c, ctx, conf):
    data = fetch_now(conf)
    if not data["ok"]:
        draw_setup(c, "CINEMABOARD", data["error"], ERROR)
        return
    m = pick_slot(ctx, data["movies"])
    draw_feature(c, "NOW PLAYING", m, rating_text(m) + " - " + m["genre"], GOLD)

def draw_newreleases(c, ctx, conf):
    data = fetch_now(conf)
    if not data["ok"]:
        draw_setup(c, "NEW RELEASES", data["error"], ERROR)
        return
    today = today_days(ctx)
    recent = []
    for i in range(len(data["movies"])):
        p = parse_ymd(data["movies"][i]["release"])
        if p != None:
            age = today - p["days"]
            if age >= 0 and age <= 14:
                recent.append(data["movies"][i])
    if len(recent) == 0:
        recent = data["movies"]
    m = pick_slot(ctx, recent)
    draw_feature(c, "NEW THIS WEEK", m, fmt_date(m["release"]) + " - " + rating_text(m), "cyan")

def draw_comingsoon(c, ctx, conf):
    data = fetch_upcoming(conf)
    if not data["ok"]:
        draw_setup(c, "COMING SOON", data["error"], ERROR)
        return
    today = today_days(ctx)
    future = []
    for i in range(len(data["movies"])):
        p = parse_ymd(data["movies"][i]["release"])
        if p != None:
            left = p["days"] - today
            if left >= 0 and left <= 120:
                future.append(data["movies"][i])
    if len(future) == 0:
        future = data["movies"]
    m = pick_slot(ctx, future)
    draw_feature(c, "COMING SOON", m, fmt_date(m["release"]) + " - " + m["genre"] + " - TMDB", "magenta")

def draw_spotlight(c, ctx, conf):
    data = fetch_now(conf)
    if not data["ok"]:
        draw_setup(c, "SPOTLIGHT", data["error"], ERROR)
        return
    m = pick_slot(ctx, data["movies"])
    draw_frame(c)
    # restrained film-strip motif
    for x in [3, c.width - 7]:
        c.line(x, 3, x, 28, GOLD)
        for y in [5, 11, 17, 23]:
            c.rect(x - 1, y, x + 1, y + 2, outline = GOLD)
    draw_header(c, "MOVIE SPOTLIGHT", GOLD)
    font = best_font(c, m["title"], ["10x16_bold", "10x14", "7x12", "6x8"], c.width - 40)
    c.text(fit_text(c, m["title"], font, c.width - 40), c.width // 2, 11, font = font, color = TITLE, align = "center")
    c.text(rating_text(m) + " - " + m["genre"], c.width // 2, 25, font = "5x7", color = SECONDARY, align = "center")

def draw_ratings(c, ctx, conf):
    data = fetch_now(conf)
    if not data["ok"]:
        draw_setup(c, "RATINGS", data["error"], ERROR)
        return
    best = data["movies"][0]
    for i in range(len(data["movies"])):
        m = data["movies"][i]
        if m["vote"] > best["vote"] and m["vote"] > 0:
            best = m
    draw_feature(c, "AUDIENCE BUZZ", best, rating_text(best) + " - SOURCE TMDB", "green")

def draw_countdown(c, ctx, conf):
    data = fetch_upcoming(conf)
    if not data["ok"]:
        draw_setup(c, "COUNTDOWN", data["error"], ERROR)
        return
    today = today_days(ctx)
    chosen = None
    chosen_left = 99999
    for i in range(len(data["movies"])):
        p = parse_ymd(data["movies"][i]["release"])
        if p != None:
            left = p["days"] - today
            if left >= 0 and left < chosen_left:
                chosen = data["movies"][i]
                chosen_left = left
    if chosen == None:
        draw_setup(c, "COUNTDOWN", "NO DATED RELEASES", SECONDARY)
        return
    label = "COMING TODAY" if chosen_left == 0 else "COMING IN " + str(chosen_left) + " DAYS"
    draw_feature(c, label, chosen, fmt_date(chosen["release"]) + " - TMDB", "cyan")

def draw_message(c, ctx, conf):
    draw_frame(c)
    msg = clean_text(conf["custommessage"], "WELCOME TO THE CINEMA")
    parts = msg.split(" ")
    line1 = msg
    line2 = ""
    if c.text_width(msg, "10x14") > c.width - 20 and len(parts) > 1:
        mid = len(parts) // 2
        line1 = ""
        line2 = ""
        for i in range(len(parts)):
            if i < mid:
                line1 += ("" if line1 == "" else " ") + parts[i]
            else:
                line2 += ("" if line2 == "" else " ") + parts[i]
    c.text("THEATER MESSAGE", c.width // 2, 2, font = "5x7", color = GOLD, align = "center")
    if line2 == "":
        font = best_font(c, line1, ["16x20", "10x16_bold", "10x14", "7x12"], c.width - 20)
        c.text(fit_text(c, line1, font, c.width - 20), c.width // 2, 10, font = font, color = TITLE, align = "center")
    else:
        c.text(fit_text(c, line1, "10x14", c.width - 20), c.width // 2, 10, font = "10x14", color = TITLE, align = "center")
        c.text(fit_text(c, line2, "10x14", c.width - 20), c.width // 2, 22, font = "10x14", color = TITLE, align = "center")

def draw_credits(c, ctx, conf):
    draw_frame(c)
    c.text("CINEMABOARD", c.width // 2, 5, font = "10x14", color = GOLD, align = "center")
    c.text("MOVIE DATA: TMDB", c.width // 2, 21, font = "5x7", color = SECONDARY, align = "center")

# ---------- declared GDN pages ----------

def boxoffice(c, ctx):
    dispatch("boxoffice", c, ctx)

def nowplaying(c, ctx):
    dispatch("nowplaying", c, ctx)

def newreleases(c, ctx):
    dispatch("newreleases", c, ctx)

def comingsoon(c, ctx):
    dispatch("comingsoon", c, ctx)

def spotlight(c, ctx):
    dispatch("spotlight", c, ctx)

def ratings(c, ctx):
    dispatch("ratings", c, ctx)

def countdown(c, ctx):
    dispatch("countdown", c, ctx)

def message(c, ctx):
    dispatch("message", c, ctx)

def credits(c, ctx):
    conf = cfg(ctx)
    draw_credits(c, ctx, conf)
