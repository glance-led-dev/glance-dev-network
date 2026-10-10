# DESIGN. Night-kickoff scoreboard on SCROLL: logos on the left (untouched
# marks, AT between them, turf-green city), amber LED clock in a dark board
# at center, weather as the glowing hero on the right. Mood chrome follows
# the forecast (sun/rain/snow) and flips green when the game is live.
TEAMS = ["ARI", "ATL", "BAL", "BUF", "CAR", "CHI", "CIN", "CLE", "DAL", "DEN", "DET", "GB", "HOU", "IND", "JAX", "KC", "LAC", "LAR", "LV", "MIA", "MIN", "NE", "NO", "NYG", "NYJ", "PHI", "PIT", "SEA", "SF", "TB", "TEN", "WSH"]
LOGOS = {'ARI': 'assets/ari.png', 'ATL': 'assets/atl.png', 'BAL': 'assets/bal.png', 'BUF': 'assets/buf.png', 'CAR': 'assets/car.png', 'CHI': 'assets/chi.png', 'CIN': 'assets/cin.png', 'CLE': 'assets/cle.png', 'DAL': 'assets/dal.png', 'DEN': 'assets/den.png', 'DET': 'assets/det.png', 'GB': 'assets/gb.png', 'HOU': 'assets/hou.png', 'IND': 'assets/ind.png', 'JAX': 'assets/jax.png', 'KC': 'assets/kc.png', 'LAC': 'assets/lac.png', 'LAR': 'assets/lar.png', 'LV': 'assets/lv.png', 'MIA': 'assets/mia.png', 'MIN': 'assets/min.png', 'NE': 'assets/ne.png', 'NO': 'assets/no.png', 'NYG': 'assets/nyg.png', 'NYJ': 'assets/nyj.png', 'PHI': 'assets/phi.png', 'PIT': 'assets/pit.png', 'SEA': 'assets/sea.png', 'SF': 'assets/sf.png', 'TB': 'assets/tb.png', 'TEN': 'assets/ten.png', 'WSH': 'assets/wsh.png'}
LOGO_WH = {"ARI": [28, 26], "ATL": [26, 26], "BAL": [39, 19], "BUF": [37, 25], "CAR": [36, 23], "CHI": [26, 26], "CIN": [35, 26], "CLE": [33, 26], "DAL": [36, 26], "DEN": [40, 23], "DET": [32, 26], "GB": [37, 24], "HOU": [28, 26], "IND": [23, 24], "JAX": [34, 26], "KC": [40, 26], "LAC": [38, 20], "LAR": [33, 24], "LV": [32, 26], "MIA": [32, 24], "MIN": [21, 26], "NE": [40, 20], "NO": [22, 24], "NYG": [31, 24], "NYJ": [38, 23], "PHI": [37, 26], "PIT": [24, 24], "SEA": [40, 23], "SF": [40, 25], "TB": [29, 25], "TEN": [24, 24], "WSH": [38, 21]}
# Equal 40x26 slots with a 9px gutter so "AT" (8px at 4x5) sits between marks.
SLOT_X = [2, 51]
SLOT_W = 40
SLOT_Y = 1
SLOT_H = 26
AT_W = 8
AT_H = 5
WHITE = "#F4F7FF"
MUTED = "#8A9BB0"
BLUE = "#78DCFF"
AMBER = "#FFBF00"
NIGHT = "#05070C"
SKY = "#10182A"
TURF = "#0C2218"
TURF_INK = "#9EE0B8"
BOARD = "#10141C"
BOARD_EDGE = "#2C3648"
LIVE = "#00DC46"

def obj(v):
    return v if type(v) == "dict" else {}

def seq(v):
    return v if type(v) == "list" else []

def number(v, default = None):
    if type(v) in ["int", "float"]:
        return v
    if type(v) == "string":
        s = v[1:] if v.startswith("-") else v
        parts = s.split(".")
        if len(parts) <= 2 and parts[0].isdigit() and (len(parts) == 1 or parts[1].isdigit()):
            return float(v)
    return default

def get(url, params = {}, ttl = 60):
    r = http.get(url, params = params, ttl_seconds = ttl)
    if r["status_code"] != 200:
        return {}
    return obj(r.get("json"))

# site.api.espn.com is Akamai-blocked from many networks. The website's
# site.web.api host returns the same scoreboard JSON. Date ranges 400 there,
# so callers walk week/year/seasontype instead. cdn.espn.com is the fallback.
SCOREBOARD = "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard"
SCOREBOARD_CDN = "https://cdn.espn.com/core/nfl/scoreboard"

def event_list(feed):
    items = feed.get("events")
    return items if type(items) == "list" else None

def scoreboard(params, use_cdn):
    if not use_cdn:
        return get(SCOREBOARD, params, 60)
    q = {"xhr": "1"}
    for k in params:
        q[k] = params[k]
    return obj(obj(get(SCOREBOARD_CDN, q, 60).get("content")).get("sbData"))

def nfl_events():
    feed = scoreboard({}, False)
    use_cdn = event_list(feed) == None
    if use_cdn:
        feed = scoreboard({}, True)
    events = event_list(feed)
    if events == None:
        return None
    seen = {}
    out = []
    for e in events:
        eid = str(obj(e).get("id", ""))
        if eid:
            seen[eid] = True
        out.append(e)
    week = number(obj(feed.get("week")).get("number"))
    year = number(obj(feed.get("season")).get("year"))
    stype = number(obj(feed.get("season")).get("type"), 2)
    if week == None:
        return out
    # Current week plus the next two covers the 21-day follow window.
    for extra in [1, 2]:
        more = event_list(scoreboard({
            "week": int(week + extra),
            "year": int(year) if year != None else 0,
            "seasontype": int(stype),
        }, use_cdn))
        for e in seq(more):
            eid = str(obj(e).get("id", ""))
            if eid and eid in seen:
                continue
            if eid:
                seen[eid] = True
            out.append(e)
    return out

# Gregorian conversion supports season boundaries without platform date parsing.
def days(y, m, d):
    y = y - (1 if m <= 2 else 0)
    era = y // 400
    yo = y - era * 400
    mp = m + (-3 if m > 2 else 9)
    return era * 146097 + yo * 365 + yo // 4 - yo // 100 + (153 * mp + 2) // 5 + d - 1 - 719468

def civil(day):
    z = day + 719468
    era = z // 146097
    doe = z - era * 146097
    yo = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yo + era * 400
    doy = doe - (365 * yo + yo // 4 - yo // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + (3 if mp < 10 else -9)
    return [y + (1 if m <= 2 else 0), m, d]

def stamp(s):
    s = str(s)
    if len(s) < 16:
        return None
    parts = [s[0:4], s[5:7], s[8:10], s[11:13], s[14:16]]
    for p in parts:
        if not p.isdigit():
            return None
    return days(int(parts[0]), int(parts[1]), int(parts[2])) * 86400 + int(parts[3]) * 3600 + int(parts[4]) * 60

def datetag(day):
    d = civil(day)
    return str(d[0]) + fmt.pad(d[1]) + fmt.pad(d[2])

def zone_at(zone, ts, fallback):
    # Kickoff can cross a DST boundary after the forecast was fetched.
    us = {"America/New_York": -5, "America/Detroit": -5, "America/Indiana/Indianapolis": -5, "America/Chicago": -6, "America/Denver": -7, "America/Los_Angeles": -8}
    year = civil(ts // 86400)[0]
    if zone in us:
        base = us[zone]
        mar = days(year, 3, 1)
        nov = days(year, 11, 1)
        start = (mar + (6 - (mar + 3) % 7) % 7 + 7) * 86400 + (2 - base) * 3600
        end = (nov + (6 - (nov + 3) % 7) % 7) * 86400 + (1 - base) * 3600
        dst = start <= ts and ts < end
        hour = base + (1 if dst else 0)
        labels = {-5: ["EST", "EDT"], -6: ["CST", "CDT"], -7: ["MST", "MDT"], -8: ["PST", "PDT"]}
        return [hour * 3600, labels[base][1 if dst else 0]]
    if zone == "America/Phoenix":
        return [-25200, "MST"]
    if zone in ["Europe/London", "Europe/Berlin", "Europe/Madrid"]:
        mar = days(year, 3, 31)
        oct = days(year, 10, 31)
        start = (mar - ((mar + 3) % 7 + 1) % 7) * 86400 + 3600
        end = (oct - ((oct + 3) % 7 + 1) % 7) * 86400 + 3600
        dst = start <= ts and ts < end
        hour = (0 if zone == "Europe/London" else 1) + (1 if dst else 0)
        return [hour * 3600, ("BST" if dst else "GMT") if zone == "Europe/London" else ("CEST" if dst else "CET")]
    # A labelled UTC fallback is safer than guessing an unfamiliar DST rule.
    return [0, "UTC"]

def fit(c, s, x, y, width, fonts = ["5x7", "4x5"], col = WHITE):
    s = str(s).upper()
    font = fonts[-1]
    for f in fonts:
        if c.text_width(s, f) <= width:
            font = f
            break
    if c.text_width(s, font) > width:
        for n in range(len(s), -1, -1):
            if c.text_width(s[:n] + "..", font) <= width:
                s = s[:n] + ".."
                break
    c.text(s, x, y, font = font, color = col)

def fit_center(c, s, cx, y, width, fonts = ["4x5"], col = WHITE):
    s = str(s).upper()
    font = fonts[-1]
    for f in fonts:
        if c.text_width(s, f) <= width:
            font = f
            break
    if c.text_width(s, font) > width:
        for n in range(len(s), -1, -1):
            if c.text_width(s[:n] + "..", font) <= width:
                s = s[:n] + ".."
                break
    c.text(s, cx, y, font = font, color = col, align = "center")

def message(c, title, sub, good = False):
    c.gradient_rect(0, 0, 191, 31, NIGHT, SKY, horizontal = False)
    rail = LIVE if good else AMBER
    c.rect(10, 4, 13, 27, fill = rail)
    fit(c, "GAME DAY WEATHER", 19, 1, 162, ["4x5"], MUTED)
    fit(c, title, 19, 10, 162, ["10x16", "6x8", "5x7"])
    fit(c, sub, 19, 26, 162, ["4x5"], MUTED)

def choose(events, team, now):
    best = None
    rank = 999999999999
    for e in events:
        e = obj(e)
        comps = seq(e.get("competitions"))
        if not comps:
            continue
        co = obj(comps[0])
        typ = obj(obj(co.get("status", e.get("status"))).get("type"))
        state = typ.get("state", "pre")
        name = typ.get("name", "")
        if state == "post" or name in ["STATUS_CANCELED", "STATUS_CANCELLED", "STATUS_POSTPONED"]:
            continue
        competitors = seq(co.get("competitors"))
        matched = team == "ALL"
        for p in competitors:
            if str(obj(obj(p).get("team")).get("abbreviation", "")).upper() == team:
                matched = True
        start = stamp(co.get("date", e.get("date", "")))
        if not matched or start == None:
            continue
        if state != "in" and start < now - 6 * 3600:
            continue
        r = start - (10000000000 if state == "in" else 0)
        if r < rank:
            rank = r
            best = {"competition": co, "start": start, "state": state, "status": obj(co.get("status", e.get("status")))}
    return best

def weather(game, now, metric):
    if not game["competition"].get("timeValid", True) and game["state"] != "in":
        return {"error": "TIME TBD"}
    venue = obj(game["competition"].get("venue"))
    addr = obj(venue.get("address"))
    name = venue.get("fullName", "")
    if not name:
        return {"error": "NO VENUE"}
    place = str(name) + ", " + str(addr.get("city") or "") + ", " + str(addr.get("state") or "") + ", " + str(addr.get("country") or "")
    geo = get("https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates", {"f": "json", "SingleLine": place, "outFields": "Match_addr,Addr_type", "maxLocations": 1}, 86400)
    candidates = seq(geo.get("candidates"))
    if not candidates:
        return {"error": "NO LOCATION"}
    candidate = obj(candidates[0])
    loc = obj(candidate.get("location"))
    if (number(candidate.get("score"), 0) < 90 or obj(candidate.get("attributes")).get("Addr_type") != "POI" or number(loc.get("x")) == None or number(loc.get("y")) == None):
        return {"error": "NO LOCATION"}
    wx = get("https://api.open-meteo.com/v1/forecast", {"latitude": loc["y"], "longitude": loc["x"], "hourly": "temperature_2m,precipitation_probability,weather_code,wind_speed_10m", "current": "temperature_2m,weather_code,wind_speed_10m", "temperature_unit": "celsius" if metric else "fahrenheit", "wind_speed_unit": "kmh" if metric else "mph", "forecast_days": 16, "timezone": "auto", "timeformat": "unixtime"}, 900)
    if not wx:
        return {"error": "WX OFFLINE"}
    local = zone_at(wx.get("timezone", ""), game["start"], number(wx.get("utc_offset_seconds"), 0))
    result = {"offset": local[0], "zone": local[1]}
    target = now if game["state"] == "in" else game["start"]
    hourly = obj(wx.get("hourly"))
    times = seq(hourly.get("time"))
    ix = -1
    # Require an actual forecast hour enclosing kickoff, never the nearest
    # available day: games outside the 16-day window get FORECAST SOON.
    for i in range(len(times)):
        t = number(times[i])
        if t != None and t <= target and target < t + 3600:
            ix = i
            break
    if ix < 0:
        result["error"] = "FORECAST SOON"
        return result
    for key, field in [["temp", "temperature_2m"], ["rain", "precipitation_probability"], ["wind", "wind_speed_10m"], ["code", "weather_code"]]:
        vals = seq(hourly.get(field))
        result[key] = number(vals[ix]) if ix < len(vals) else None
    if game["state"] == "in":
        current = obj(wx.get("current"))
        when = number(current.get("time"), 0)
        if when > now - 3600 and when <= now + 900:
            for key, field in [["temp", "temperature_2m"], ["wind", "wind_speed_10m"], ["code", "weather_code"]]:
                result[key] = number(current.get(field))
    if result.get("temp") == None:
        result["error"] = "WX UNAVAILABLE"
    return result

def wx_mood(code, live):
    if live:
        return LIVE
    code = number(code, 0)
    if code in [0, 1]:
        return AMBER
    if code in [71, 73, 75, 77, 85, 86]:
        return "#DCF4FF"
    if code >= 51:
        return BLUE
    if code in [45, 48]:
        return "#9AA8B8"
    return "#C8D4E8"

def icon(c, code, cx = 174, cy = 10):
    code = number(code, -1)
    if code < 0:
        fit(c, "?", cx - 2, cy - 2, 10, ["5x7"], MUTED)
        return
    if code in [0, 1]:
        c.fill_circle(cx, cy, 4, AMBER)
        c.fill_circle(cx, cy, 2, "#FFE48A")
        for x, y, xx, yy in [[cx, cy - 7, cx, cy - 6], [cx, cy + 6, cx, cy + 7], [cx - 7, cy, cx - 6, cy], [cx + 6, cy, cx + 7, cy], [cx - 5, cy - 5, cx - 4, cy - 4], [cx + 4, cy + 4, cx + 5, cy + 5], [cx + 4, cy - 5, cx + 5, cy - 4], [cx - 5, cy + 4, cx - 4, cy + 5]]:
            c.line(x, y, xx, yy, AMBER)
        return
    c.rect(cx - 6, cy - 1, cx + 5, cy + 2, fill = "#D4E5F4")
    c.rect(cx - 9, cy + 1, cx + 8, cy + 3, fill = "#D4E5F4")
    c.rect(cx - 2, cy - 3, cx + 2, cy + 1, fill = "#D4E5F4")
    if code in [71, 73, 75, 77, 85, 86]:
        for x in [cx - 8, cx - 1, cx + 6]:
            c.pixel(x, cy + 6, WHITE)
            c.pixel(x + 1, cy + 7, WHITE)
            c.pixel(x + 1, cy + 5, WHITE)
    elif code >= 51:
        for x in [cx - 8, cx - 1, cx + 6]:
            c.line(x, cy + 6, x - 1, cy + 9, BLUE)
    elif code in [45, 48]:
        c.line(cx - 10, cy + 6, cx + 9, cy + 6, MUTED)
        c.line(cx - 8, cy + 8, cx + 7, cy + 8, color.dim(MUTED, 60))

def logo(c, ab, slot_x):
    # Center each mark in a fixed 40x26 slot so AT is always the midpoint.
    if ab not in TEAMS:
        fit(c, ab, slot_x + 4, SLOT_Y + 8, SLOT_W - 8, ["5x7", "4x5"])
        return
    wh = LOGO_WH[ab]
    x = slot_x + (SLOT_W - wh[0]) // 2
    y = SLOT_Y + (SLOT_H - wh[1]) // 2
    c.image(LOGOS[ab], x, y)

def draw(c, g, wx, metric, timezone = "STADIUM LOCAL"):
    live = g["state"] == "in"
    mood = wx_mood(wx.get("code"), live)
    c.gradient_rect(0, 0, 191, 31, NIGHT, SKY, horizontal = False)
    c.gradient_rect(128, 0, 191, 31, NIGHT, color.dim(mood, 16), horizontal = True)
    co = g["competition"]
    away = {}
    home = {}
    for p in seq(co.get("competitors")):
        p = obj(p)
        if p.get("homeAway") == "home":
            home = p
        else:
            away = p
    a = str(obj(away.get("team")).get("abbreviation", "AWAY")).upper()
    h = str(obj(home.get("team")).get("abbreviation", "HOME")).upper()
    # AT sits in the true gap between the two bitmaps.
    aw = LOGO_WH[a] if a in LOGO_WH else [SLOT_W, SLOT_H]
    hw = LOGO_WH[h] if h in LOGO_WH else [SLOT_W, SLOT_H]
    a_x = SLOT_X[0] + (SLOT_W - aw[0]) // 2
    h_x = SLOT_X[1] + (SLOT_W - hw[0]) // 2
    a_y = SLOT_Y + (SLOT_H - aw[1]) // 2
    h_y = SLOT_Y + (SLOT_H - hw[1]) // 2
    gap0 = a_x + aw[0]
    gap1 = h_x
    at_x = gap0 + (gap1 - gap0 - AT_W) // 2
    at_y = (a_y + aw[1] // 2 + h_y + hw[1] // 2) // 2 - AT_H // 2
    city = obj(obj(co.get("venue")).get("address")).get("city", "VENUE TBD")
    mid = SLOT_X[0] + (SLOT_X[1] + SLOT_W - SLOT_X[0]) // 2
    fit_center(c, city, mid, 27, 88, ["4x5"], TURF_INK)
    c.line(92, 2, 92, 29, color.dim(mood, 40))
    c.line(128, 2, 128, 29, color.dim(mood, 40))
    # Stadium clock / live scoreboard, 94–127.
    c.round_rect(94, 1, 127, 24, 2, fill = BOARD)
    c.round_rect(94, 1, 127, 24, 2, outline = BOARD_EDGE)
    status = g["status"]
    cx = 111
    if live:
        c.badge("LIVE", 96, 2, color = "black", bg = LIVE, font = "4x5", pad = 1)
        av = away.get("score", "-")
        hv = home.get("score", "-")
        av = obj(av).get("displayValue", "-") if type(av) == "dict" else av
        hv = obj(hv).get("displayValue", "-") if type(hv) == "dict" else hv
        fit_center(c, str(av) + "-" + str(hv), cx, 10, 30, ["scoretext", "6x8", "5x7", "4x5"], WHITE)
        short = str(obj(status.get("type")).get("shortDetail", ""))
        per = int(number(status.get("period"), 0))
        label = "OT" if per > 4 else "Q" + str(per)
        if "half" in short.lower():
            label = "HALFTIME"
        else:
            label = label + " " + str(status.get("displayClock", ""))
        fit_center(c, label, cx, 26, 32, ["4x5"], MUTED)
    else:
        offset = int(wx.get("offset", 0))
        label = wx.get("zone", "UTC")
        zones = {"ET": "America/New_York", "CT": "America/Chicago", "MT": "America/Denver", "PT": "America/Los_Angeles", "UTC": "UTC"}
        if timezone in zones:
            offset = zone_at(zones[timezone], g["start"], 0)[0]
            label = timezone
        local = g["start"] + offset
        date = civil(local // 86400)
        hour = (local // 3600) % 24
        minute = (local // 60) % 60
        fit_center(c, "%d/%d" % (date[1], date[2]), cx, 2, 30, ["4x5"], MUTED)
        valid = co.get("timeValid", True)
        time = str(hour % 12 or 12) + ":" + fmt.pad(minute) + ("P" if hour >= 12 else "A")
        clock = time if valid else "TBD"
        fit_center(c, clock, cx, 9, 30, ["scoretext", "6x8", "5x7", "4x5"], AMBER)
        c.hline(100, 22, 22, color.dim(AMBER, 55))
        fit_center(c, label, cx, 26, 32, ["4x5"], MUTED)
    # Marks last so chrome never paints over the logos.
    logo(c, a, SLOT_X[0])
    logo(c, h, SLOT_X[1])
    c.text("AT", at_x, at_y, font = "4x5", color = WHITE)
    if wx.get("error"):
        error = wx["error"]
        title = "FORECAST" if error == "FORECAST SOON" else "WEATHER"
        sub = "SOON" if error == "FORECAST SOON" else "UNAVAILABLE"
        fit(c, title, 132, 4, 48, ["4x5"], MUTED)
        fit(c, sub, 132, 13, 48, ["5x7", "4x5"], AMBER)
        fit(c, "CHECK LATER", 132, 25, 48, ["4x5"], MUTED)
        return
    temp = str(int(math.round(wx["temp"])))
    tf = "10x16"
    for f in ["16x20", "10x16", "7x12", "5x7"]:
        if c.text_width(temp, f) <= 42:
            tf = f
            break
    tw = c.text_width(temp, tf)
    c.text(temp, 131, 1, font = tf, color = WHITE)
    deg_x = 131 + tw + 1
    c.rect(deg_x, 1, deg_x + 2, 3, outline = WHITE)
    c.text("C" if metric else "F", deg_x, 7, font = "4x5", color = MUTED)
    icon(c, wx.get("code"), 179, 6)
    rain = wx.get("rain")
    wind = wx.get("wind")
    snow = wx.get("code") in [71, 73, 75, 77, 85, 86]
    rp = str(int(math.round(max(0, min(100, rain))))) + "%" if rain != None else "--"
    wp = str(int(math.round(wind))) if wind != None else "--"
    fit(c, ("SNOW " if snow else "RAIN ") + rp, 131, 22, 40, ["4x5"], BLUE)
    fit(c, "W " + wp + ("KMH" if metric else "MPH"), 131, 27, 48, ["4x5"], MUTED)

def gameday(c, ctx):
    team = str(ctx.inputs.get("team", "ALL") or "ALL").upper()
    metric = ctx.inputs.get("units", "F / MPH") == "C / KMH"
    timezone = str(ctx.inputs.get("timezone", "STADIUM LOCAL") or "STADIUM LOCAL").upper()
    if team != "ALL" and team not in TEAMS:
        message(c, "UNKNOWN TEAM", "CHOOSE AN NFL TEAM IN SETTINGS")
        return
    now = ctx.now.unix
    events = nfl_events()
    if events == None:
        message(c, "SCORES OFFLINE", "CHECK CONNECTION / RETRY SHORTLY")
        return
    game = choose(events, team, now)
    if not game:
        message(c, "NO UPCOMING GAME", (team + " / NEXT 21 DAYS") if team != "ALL" else "NFL / NEXT 21 DAYS", True)
        return
    wx = weather(game, now, metric)
    draw(c,game,wx,metric,timezone)



