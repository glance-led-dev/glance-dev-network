# DESIGN. User-approved three-zone SCROLL Studio composition: NFL identity
# left, game status center, weather hero right. KC is a 40x26 majority
# downsample of the official raster (white / Chiefs red / black). Other
# marks remain 36x22. Black background, white values, cool blue weather
# accents. Scores refresh each minute; weather is cached 15 minutes.
TEAMS = ["ARI", "ATL", "BAL", "BUF", "CAR", "CHI", "CIN", "CLE", "DAL", "DEN", "DET", "GB", "HOU", "IND", "JAX", "KC", "LAC", "LAR", "LV", "MIA", "MIN", "NE", "NO", "NYG", "NYJ", "PHI", "PIT", "SEA", "SF", "TB", "TEN", "WSH"]
LOGOS = {'ARI': 'assets/ari.png', 'ATL': 'assets/atl.png', 'BAL': 'assets/bal.png', 'BUF': 'assets/buf.png', 'CAR': 'assets/car.png', 'CHI': 'assets/chi.png', 'CIN': 'assets/cin.png', 'CLE': 'assets/cle.png', 'DAL': 'assets/dal.png', 'DEN': 'assets/den.png', 'DET': 'assets/det.png', 'GB': 'assets/gb.png', 'HOU': 'assets/hou.png', 'IND': 'assets/ind.png', 'JAX': 'assets/jax.png', 'KC': 'assets/kc.png', 'LAC': 'assets/lac.png', 'LAR': 'assets/lar.png', 'LV': 'assets/lv.png', 'MIA': 'assets/mia.png', 'MIN': 'assets/min.png', 'NE': 'assets/ne.png', 'NO': 'assets/no.png', 'NYG': 'assets/nyg.png', 'NYJ': 'assets/nyj.png', 'PHI': 'assets/phi.png', 'PIT': 'assets/pit.png', 'SEA': 'assets/sea.png', 'SF': 'assets/sf.png', 'TB': 'assets/tb.png', 'TEN': 'assets/ten.png', 'WSH': 'assets/wsh.png'}
# Demo venues: city plus IANA zone so STADIUM LOCAL is not stuck on CDT.
HOME = {"ARI": ["GLENDALE", "America/Phoenix"], "ATL": ["ATLANTA", "America/New_York"], "BAL": ["BALTIMORE", "America/New_York"], "BUF": ["ORCHARD PARK", "America/New_York"], "CAR": ["CHARLOTTE", "America/New_York"], "CHI": ["CHICAGO", "America/Chicago"], "CIN": ["CINCINNATI", "America/New_York"], "CLE": ["CLEVELAND", "America/New_York"], "DAL": ["ARLINGTON", "America/Chicago"], "DEN": ["DENVER", "America/Denver"], "DET": ["DETROIT", "America/Detroit"], "GB": ["GREEN BAY", "America/Chicago"], "HOU": ["HOUSTON", "America/Chicago"], "IND": ["INDIANAPOLIS", "America/Indiana/Indianapolis"], "JAX": ["JACKSONVILLE", "America/New_York"], "KC": ["KANSAS CITY", "America/Chicago"], "LAC": ["INGLEWOOD", "America/Los_Angeles"], "LAR": ["INGLEWOOD", "America/Los_Angeles"], "LV": ["LAS VEGAS", "America/Los_Angeles"], "MIA": ["MIAMI", "America/New_York"], "MIN": ["MINNEAPOLIS", "America/Chicago"], "NE": ["FOXBOROUGH", "America/New_York"], "NO": ["NEW ORLEANS", "America/Chicago"], "NYG": ["EAST RUTHERFORD", "America/New_York"], "NYJ": ["EAST RUTHERFORD", "America/New_York"], "PHI": ["PHILADELPHIA", "America/New_York"], "PIT": ["PITTSBURGH", "America/New_York"], "SEA": ["SEATTLE", "America/Los_Angeles"], "SF": ["SANTA CLARA", "America/Los_Angeles"], "TB": ["TAMPA", "America/New_York"], "TEN": ["NASHVILLE", "America/Chicago"], "WSH": ["LANDOVER", "America/New_York"]}
WHITE = "#F2F6FF"
MUTED = "#A7B4C8"
BLUE = "#65CBFF"
AMBER = "#FFD166"

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

def message(c, title, sub, good = False):
    c.fill("black")
    c.rect(10, 5, 12, 26, fill = "#56DC9B" if good else AMBER)
    fit(c, "NFL / GAME DAY WEATHER", 19, 1, 162, ["4x5"], MUTED)
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

def icon(c, code):
    code = number(code, -1)
    if code < 0:
        fit(c, "?", 169, 8, 10, ["5x7"], MUTED)
        return
    if code in [0, 1]:
        c.fill_circle(169, 9, 4, "#FFD166")
        for x, y, xx, yy in [[169,1,169,2],[169,16,169,17],[161,9,162,9],[176,9,177,9],[163,3,164,4],[174,14,175,15]]:
            c.line(x,y,xx,yy,"#FFD166")
        return
    c.rect(164, 6, 175, 11, fill = "#D4E5F4")
    c.rect(160, 9, 179, 12, fill = "#D4E5F4")
    c.rect(168, 4, 172, 10, fill = "#D4E5F4")
    if code in [71,73,75,77,85,86]:
        for x in [163, 169, 175]:
            c.pixel(x,15,WHITE)
            c.pixel(x+1,16,WHITE)
    elif code >= 51:
        for x in [163, 169, 175]:
            c.line(x,15,x-1,17,BLUE)
    elif code in [45,48]:
        c.line(161,15,177,15,MUTED)

def logo(c, ab, x):
    # Native team marks. KC is 40x26 from the official raster; others 36x22.
    if ab in TEAMS:
        c.image(LOGOS[ab], x, 1)
    else:
        fit(c, ab, x, 8, 40, ["5x7", "4x5"])

def draw(c, g, wx, metric, demo, timezone = "STADIUM LOCAL"):
    c.fill("black")
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
    # 40px logo slots: largest two-logo width that still leaves a score column.
    logo(c, a, 1)
    logo(c, h, 47)
    c.text("@", 42, 10, font = "4x5", color = MUTED)
    city = obj(obj(co.get("venue")).get("address")).get("city", "VENUE TBD")
    fit(c, city, 1, 27, 86, ["4x5"], MUTED)
    c.line(88, 3, 88, 28, "#354255")
    c.line(122, 3, 122, 28, "#354255")
    status = g["status"]
    if g["state"] == "in":
        fit(c, "DEMO" if demo else "LIVE", 91, 2, 30, ["4x5"], AMBER if demo else "#64E6AC")
        av = away.get("score", "-")
        hv = home.get("score", "-")
        av = obj(av).get("displayValue", "-") if type(av) == "dict" else av
        hv = obj(hv).get("displayValue", "-") if type(hv) == "dict" else hv
        fit(c, str(av) + "-" + str(hv), 91, 11, 30, ["6x8", "5x7", "4x5"])
        short = str(obj(status.get("type")).get("shortDetail", ""))
        per = int(number(status.get("period"), 0))
        label = "OT" if per > 4 else "Q" + str(per)
        if "half" in short.lower():
            label = "HALFTIME"
        else:
            label = label + " " + str(status.get("displayClock", ""))
        fit(c, label, 91, 25, 30, ["4x5"], MUTED)
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
        fit(c, "DEMO" if demo else "%d/%d" % (date[1], date[2]), 91, 2, 30, ["4x5"], AMBER if demo else MUTED)
        valid = co.get("timeValid", True)
        time = str(hour % 12 or 12) + ":" + fmt.pad(minute) + ("P" if hour >= 12 else "A")
        fit(c, time if valid else "TBD", 91, 11, 30, ["6x8", "5x7", "4x5"])
        fit(c, label, 91, 25, 30, ["4x5"], MUTED)
    if wx.get("error"):
        error = wx["error"]
        title = "FORECAST" if error == "FORECAST SOON" else "WEATHER"
        sub = "SOON" if error == "FORECAST SOON" else "UNAVAILABLE"
        fit(c, title, 128, 4, 53, ["4x5"], MUTED)
        fit(c, sub, 128, 13, 53, ["5x7", "4x5"], AMBER)
        fit(c, "CHECK LATER", 128, 25, 53, ["4x5"], MUTED)
        return
    # A three-digit or negative temperature is laddered before the icon at x160.
    temp = str(int(math.round(wx["temp"])))
    fit(c, temp, 127, 1, 26, ["10x16", "7x12", "5x7"])
    c.rect(154, 1, 156, 3, outline = WHITE)
    c.text("C" if metric else "F", 154, 8, font = "4x5", color = MUTED)
    icon(c, wx.get("code"))
    rain = wx.get("rain")
    wind = wx.get("wind")
    rp = str(int(math.round(max(0, min(100, rain))))) + "%" if rain != None else "--"
    wp = str(int(math.round(wind))) if wind != None else "--"
    fit(c, ("SNOW " if wx.get("code") in [71,73,75,77,85,86] else "RAIN ") + rp, 128, 20, 53, ["4x5"], BLUE)
    fit(c, "W " + wp + ("KMH" if metric else "MPH"), 128, 27, 53, ["4x5"], MUTED)

def gameday(c, ctx):
    team = str(ctx.inputs.get("team", "ALL") or "ALL").upper()
    metric = ctx.inputs.get("units", "F / MPH") == "C / KMH"
    mode = ctx.inputs.get("mode", "LIVE DATA")
    timezone = str(ctx.inputs.get("timezone", "STADIUM LOCAL") or "STADIUM LOCAL").upper()
    if team != "ALL" and team not in TEAMS:
        message(c, "UNKNOWN TEAM", "CHOOSE AN NFL TEAM IN SETTINGS")
        return
    if mode in ["DEMO KICKOFF", "DEMO LIVE"]:
        # Followed club at home vs GB (CHI if following GB). ALL uses GB @ CHI.
        h = "CHI" if team in ["ALL"] else team
        a = "CHI" if h == "GB" else "GB"
        info = HOME.get(h, ["VENUE TBD", "UTC"])
        start = days(2026, 9, 13) * 86400 + 17 * 3600
        tz = zone_at(info[1], start, 0)
        g = {"start": start, "state": "in" if mode == "DEMO LIVE" else "pre", "status": {"period": 3, "displayClock": "8:42", "type": {}}, "competition": {"venue": {"address": {"city": info[0]}}, "competitors": [{"homeAway": "away", "team": {"abbreviation": a}, "score": "17"}, {"homeAway": "home", "team": {"abbreviation": h}, "score": "14"}]}}
        wx = {"temp": 9 if metric else 48, "rain": 40, "wind": 19 if metric else 12, "code": 61, "offset": tz[0], "zone": tz[1]}
        draw(c, g, wx, metric, True, timezone)
        return
    now = ctx.now.unix
    # Include yesterday to retain a live game spanning UTC midnight.
    date = datetag(now // 86400 - 1) + "-" + datetag(now // 86400 + 21)
    feed = get("https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard", {"dates": date,"limit":100}, 60)
    if not feed or type(feed.get("events")) != "list":
        message(c, "SCORES OFFLINE", "CHECK CONNECTION / RETRY SHORTLY")
        return
    game = choose(feed["events"], team, now)
    if not game:
        message(c, "NO UPCOMING GAME", (team + " / NEXT 21 DAYS") if team != "ALL" else "NFL / NEXT 21 DAYS", True)
        return
    wx = weather(game, now, metric)
    draw(c,game,wx,metric,False,timezone)



