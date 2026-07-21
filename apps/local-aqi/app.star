# Local AQI - US Air Quality Index + health guidance for a zip. (128x32, 2 pages)
#
# Live data from the EPA AirNow network. The endpoint takes a zip code
# directly, so there is no geocoding step.
#
# AirNow returns a LIST, one entry per pollutant it measures at that site:
#   [{"ParameterName":"PM2.5","AQI":42,"Category":{"Number":1,"Name":"Good"},
#     "ReportingArea":"Los Angeles", ...}, {...O3...}]
# The headline AQI is the HIGHEST of those, and that pollutant is the
# "dominant" one -- that is how the EPA defines the reported index.

# Short labels for the panel. AirNow's own names are too long for 128px
# ("Unhealthy for Sensitive Groups" will not fit anywhere).
CATS = {
    1: ["GOOD",      "green",   "leaf.png", "AIR IS CLEAN"],
    2: ["MODERATE",  "yellow",  "leaf.png", "FINE FOR MOST"],
    3: ["USG",       "orange",  "mask.png", "SENSITIVE: CARE"],
    4: ["UNHEALTHY", "red",     "mask.png", "LIMIT TIME OUT"],
    5: ["VERY BAD",  "magenta", "mask.png", "AVOID OUTDOORS"],
    6: ["HAZARD",    "red",     "mask.png", "STAY INDOORS"],
}

# AirNow's parameter codes vs something a person can actually read.
POLL_SHORT = {
    "PM2.5": "FINE PARTICLES",
    "PM10":  "COARSE DUST",
    "O3":    "OZONE",
    "OZONE": "OZONE",
    "NO2":   "NITROGEN DIOX",
    "SO2":   "SULFUR DIOXIDE",
    "CO":    "CARBON MONOX",
}

def _cat(num):
    if num in CATS:
        return CATS[num]
    return ["UNKNOWN", "gray", "leaf.png", "NO CATEGORY"]

def _s(ctx, key):
    # An unset input can come back as None, so coerce before .strip().
    v = ctx.inputs.get(key, "")
    if v == None:
        return ""
    return str(v).strip()

# ---------- the fetch ----------
# Returns either {"ok": True, ...} or {"ok": False, "title":..., "sub":...}
# so both pages can render the same failure the same way.

def fetch(ctx):
    key = _s(ctx, "apikey")
    zip = _s(ctx, "zip")

    if not key:
        return {"ok": False, "title": "NO API KEY", "sub": "ADD ONE IN SETTINGS"}
    if not zip:
        return {"ok": False, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}

    # http.get returns a DICT: {"status_code":..., "body":..., "json":...}
    r = http.get(
        "https://www.airnowapi.org/aq/observation/zipCode/current/",
        params = {
            "format": "application/json",
            "zipCode": zip,
            "distance": "50",      # miles; widen so rural zips still hit a station
            "API_KEY": key,
        },
        # Stations report hourly. No point asking more often than that.
        ttl_seconds = 900,
    )

    # ALWAYS check status_code before touching the json
    status = r["status_code"]
    if status == 401 or status == 403:
        return {"ok": False, "title": "BAD API KEY", "sub": "CHECK YOUR SETTINGS"}
    if status == 429:
        return {"ok": False, "title": "RATE LIMITED", "sub": "TRY AGAIN LATER"}
    if status != 200:
        return {"ok": False, "title": "API ERROR", "sub": "CODE " + str(status)}

    obs = r["json"]

    # An empty list is AirNow's way of saying "no station near that zip".
    # It is a 200, not an error, so it has to be handled separately.
    if not obs:
        return {"ok": False, "title": "NO DATA", "sub": "NO STATION NEAR " + zip}

    # Highest AQI across the reported pollutants is the headline number.
    best = obs[0]
    for o in obs:
        if int(o.get("AQI", -1)) > int(best.get("AQI", -1)):
            best = o

    aqi = int(best.get("AQI", 0))

    # A negative AQI means the sensor reported nothing this hour.
    if aqi < 0:
        return {"ok": False, "title": "NO READING", "sub": "STATION OFFLINE"}

    cat_num = int(best.get("Category", {}).get("Number", 1))
    label, color, icon, advice = _cat(cat_num)

    param = str(best.get("ParameterName", ""))
    poll = POLL_SHORT.get(param, param.upper())

    # Fall back to whatever AirNow calls this area if no city was typed in.
    city = _s(ctx, "city")
    if not city:
        city = str(best.get("ReportingArea", "AIR QUALITY"))

    return {
        "ok": True,
        "aqi": aqi,
        "cat": label,
        "color": color,
        "icon": icon,
        "advice": advice,
        "poll": poll,
        "city": city.upper(),
    }

def _err(c, d, bar):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = bar)
    c.text("AIR QUALITY", c.width // 2, 1, font = "5x7", color = "black", align = "center")
    c.text(d["title"], 4, 12, font = "6x8", color = "orange")
    c.text(d["sub"], 4, 23, font = "4x5", color = "gray")

# ---------- pages ----------

def now(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        _err(c, d, "orange")
        return

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = d["color"])
    c.text(d["city"], c.width // 2, 1, font = "5x7", color = "black", align = "center")
    c.text(str(d["aqi"]), 4, 11, font = "16x20", color = d["color"])
    c.text(d["cat"], c.width - 4, 12, font = "6x8", color = d["color"], align = "right")
    c.text("US AQI", c.width - 4, 24, font = "4x5", color = "gray", align = "right")

def health(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        _err(c, d, "blue")
        return

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text("HEALTH", c.width // 2, 1, font = "5x7", color = "white", align = "center")
    c.image(d["icon"], 3, 11, w = 13, h = 13)            # leaf when clean, mask when not
    c.text("MAIN POLLUTANT", 20, 11, font = "4x5", color = "gray")
    c.text(d["poll"], 20, 18, font = "4x5", color = "cyan")
    c.text(d["advice"], 20, 25, font = "4x5", color = "white")