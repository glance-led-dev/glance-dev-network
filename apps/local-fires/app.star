# Local Fires - wildfire activity + nearest active fire for a US zip. (128x32, 2 pages)
#
# Live data from NIFC's WFIGS interagency feed, the same source the agencies
# use. It is a public ArcGIS layer, so no API key is needed.
#
# Two calls: zip -> lat/lon (zippopotam.us), then a spatial query for fires
# within SEARCH_MI of that point.
#
# NOTE ON "RISK": there is no free forecast index for fire danger, so this is
# NOT a predicted rating. It is derived from real activity on the ground --
# how close the nearest active fire is, and how many are burning nearby.

PI = 3.141592653589793
TWO_PI = 6.283185307179586

SEARCH_MI = 100        # how far out to look for the nearest fire
ACTIVE_MI = 50         # what counts as "nearby" for the active tally

FIRE_URL = "https://services3.arcgis.com/T4QMspbfLg3qTGWY/arcgis/rest/services/WFIGS_Incident_Locations_Current/FeatureServer/0/query"

# ---------- tiny math (Starlark has no math module) ----------

def _cos(x):
    n = int(x / TWO_PI)
    x = x - float(n) * TWO_PI
    if x > PI:
        x = x - TWO_PI
    if x < -PI:
        x = x + TWO_PI
    x2 = x * x
    term = 1.0
    total = 1.0
    for i in range(1, 9):
        term = -term * x2 / float((2 * i - 1) * (2 * i))
        total = total + term
    return total

def _sqrt(v):
    if v <= 0.0:
        return 0.0
    g = v
    for i in range(20):
        g = 0.5 * (g + v / g)
    return g

def _miles(lat1, lon1, lat2, lon2):
    # Equirectangular approximation. Well under a mile of error at these ranges,
    # and far cheaper than a full haversine in Starlark.
    mlat = (lat1 + lat2) / 2.0 * PI / 180.0
    dy = (lat2 - lat1) * 69.17
    dx = (lon2 - lon1) * 69.17 * _cos(mlat)
    return _sqrt(dx * dx + dy * dy)

# ---------- helpers ----------

def _s(ctx, key, fallback):
    # An unset input can come back as None, so coerce before using it.
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _attr(a, names, fallback):
    # WFIGS field names have shifted over the years, so try a few spellings
    # rather than depending on one.
    for n in names:
        if n in a and a[n] != None:
            return a[n]
    return fallback

def _num(v, fallback):
    if v == None:
        return fallback
    return float(v)

def _acres(v):
    # 125000 -> "125K AC", 340 -> "340 AC"
    n = int(v + 0.5)
    if n >= 10000:
        return str(n // 1000) + "K AC"
    return str(n) + " AC"

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]


def fit_words(c, text, options, maxw):
    """[font, text] that genuinely fits maxw, trimmed at a word boundary.

    fit_font only chooses a size: when even the smallest option overflows it
    still returns one, and c.text() then draws the whole string anyway. That is
    how a long incident name ran through the CONTAINED column beside it and off
    the panel -- "BRIDGE CREEK COMPLEX FIRE" is 25 characters and no font in
    the list makes that fit 80px.

    Whole words only, because a hard cut leaves things like "BRIDGE CREEK COMP"
    that read as a rendering fault rather than an abbreviation.
    """
    f = fit_font(c, text, options, maxw)
    if c.text_width(text, f) <= maxw:
        return [f, text]
    parts = text.split(" ")
    out = ""
    for w in parts:
        trial = w if out == "" else out + " " + w
        if c.text_width(trial, f) > maxw:
            break
        out = trial
    if out != "":
        return [f, out]
    for k in range(len(text), 0, -1):
        if c.text_width(text[:k], f) <= maxw:
            return [f, text[:k]]
    return [f, ""]

# ---------- step 1: zip -> lat/lon ----------

def _geocode(zip):
    # Zip codes rarely move, so cache for a day.
    r = http.get("https://api.zippopotam.us/us/" + zip, ttl_seconds = 86400)
    if r["status_code"] != 200:
        return None

    places = r["json"].get("places", [])
    if not places:
        return None

    p = places[0]
    # The place name rides along with the coordinates -- the response already
    # carries it, so naming the panel costs no extra call.
    return [float(p["latitude"]), float(p["longitude"]),
            str(p.get("place name", "")).upper()]

# ---------- step 2: fires near that point ----------
# Returns {"ok": True, ...} or {"ok": False, "title":..., "sub":...}

def fetch(ctx):
    zip = _s(ctx, "zip", "")
    if not zip:
        return {"ok": False, "title": "NO ZIP CODE", "sub": "ADD ONE IN SETTINGS"}

    loc = _geocode(zip)
    if loc == None:
        return {"ok": False, "title": "BAD ZIP", "sub": zip + " NOT FOUND"}

    lat = loc[0]
    lon = loc[1]

    # ArcGIS spatial query: everything within SEARCH_MI of this point.
    # outFields=* so we are not depending on one exact schema.
    r = http.get(
        FIRE_URL,
        params = {
            "f": "json",
            "geometry": str(lon) + "," + str(lat),
            "geometryType": "esriGeometryPoint",
            "inSR": "4326",
            "outSR": "4326",
            "spatialRel": "esriSpatialRelIntersects",
            "distance": str(SEARCH_MI),
            "units": "esriSRUnit_StatuteMile",
            "outFields": "*",
            "returnGeometry": "true",
            "resultRecordCount": "200",
        },
        # The interagency feed updates on the order of hours.
        ttl_seconds = 3600,
    )

    # ALWAYS check status_code before touching the json
    status = r["status_code"]
    if status != 200:
        return {"ok": False, "title": "FEED ERROR", "sub": "CODE " + str(status)}

    body = r["json"]
    if not body:
        return {"ok": False, "title": "NO DATA", "sub": "EMPTY RESPONSE"}

    # ArcGIS reports its own errors inside a 200 response.
    if "error" in body:
        return {"ok": False, "title": "FEED ERROR", "sub": "QUERY REJECTED"}

    feats = body.get("features", [])

    fires = []
    for f in feats:
        a = f.get("attributes", {})
        g = f.get("geometry", {})

        fx = g.get("x", None)
        fy = g.get("y", None)
        if fx == None or fy == None:
            continue

        # Skip prescribed burns; this app is about wildfires.
        kind = str(_attr(a, ["IncidentTypeCategory", "attr_IncidentTypeCategory"], "WF"))
        if kind and kind.upper() != "WF":
            continue

        name = str(_attr(a, ["IncidentName", "attr_IncidentName", "poly_IncidentName"], ""))
        acres = _num(_attr(a, ["DailyAcres", "attr_DailyAcres", "GISAcres", "poly_GISAcres"], None), 0.0)
        contain = _num(_attr(a, ["PercentContained", "attr_PercentContained"], None), -1.0)

        d = _miles(lat, lon, float(fy), float(fx))
        if d > float(SEARCH_MI):
            continue

        fires.append({
            "name": name.upper(),
            "dist": d,
            "acres": acres,
            "contain": contain,
        })

    # Nearest first.
    nearest = None
    active = 0
    for f in fires:
        if f["dist"] <= float(ACTIVE_MI):
            active = active + 1
        if nearest == None or f["dist"] < nearest["dist"]:
            nearest = f

    # Risk band from real proximity, not a forecast index.
    if nearest == None:
        risk = "LOW"
        color = "green"
    elif nearest["dist"] <= 10.0:
        risk = "EXTREME"
        color = "red"
    elif nearest["dist"] <= 25.0:
        risk = "HIGH"
        color = "orange"
    elif nearest["dist"] <= 50.0:
        risk = "MODERATE"
        color = "yellow"
    else:
        risk = "LOW"
        color = "green"

    return {
        "ok": True,
        "place": loc[2],
        "risk": risk,
        "color": color,
        "active": active,
        "nearest": nearest,
    }

def _err(c, d, bar):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = bar)
    c.text("FIRE WATCH", c.width // 2, 1, font = "5x7", color = "white", align = "center")
    c.text(d["title"], 4, 12, font = "6x8", color = "orange")
    c.text(d["sub"], 4, 23, font = "4x5", color = "gray")

# ---------- pages ----------

def status(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        _err(c, d, "red")
        return

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "red")
    # Named from the zip lookup rather than a hand-typed label. A typed label
    # was as long as the user made it; a looked-up one can be anything the
    # postal database holds, so drop to 4x5 for the long ones -- "RANCHO SANTA
    # MARGARITA" is 132px at 5x7 and would run off a 128 panel.
    head = d["place"] or "FIRE WATCH"
    c.text(head, c.width // 2, 1,
           font = fit_font(c, head, ["5x7", "4x5"], c.width - 4),
           color = "white", align = "center")
    c.image("flame.png", 3, 10, w = 13, h = 16)          # custom icon from this folder
    c.text("ACTIVITY", 22, 10, font = "4x5", color = "gray")
    c.text(d["risk"], 22, 17, font = "7x12", color = d["color"])
    c.text(str(d["active"]) + " ACTIVE", c.width - 3, 11, font = "4x5", color = "orange", align = "right")
    c.text("IN 50 MI", c.width - 3, 24, font = "4x5", color = "gray", align = "right")

def nearest(c, ctx):
    d = fetch(ctx)
    if not d["ok"]:
        _err(c, d, "orange")
        return

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "orange")
    c.text("NEAREST FIRE", c.width // 2, 1, font = "5x7", color = "black", align = "center")

    n = d["nearest"]

    # No fire within SEARCH_MI is the normal case most of the year.
    if n == None:
        c.text("NONE WITHIN", 3, 12, font = "5x7", color = "green")
        c.text(str(SEARCH_MI) + " MILES", 3, 22, font = "5x7", color = "green")
        return

    nm = n["name"]
    if nm:
        nm = nm + " FIRE"
    else:
        nm = "UNNAMED FIRE"
    # Measure the CONTAINED column and give the name what is actually left,
    # rather than a fixed 80px it was free to overrun.
    room = c.width - 3 - c.text_width("CONTAINED", "4x5") - 8
    nf = fit_words(c, nm, ["5x7", "4x5"], room)
    c.text(nf[1], 3, 11, font = nf[0], color = "orange")

    c.text(str(int(n["dist"] + 0.5)) + " MI", 3, 21, font = "5x7", color = "white")
    c.text(_acres(n["acres"]), 44, 21, font = "5x7", color = "gray")

    c.text("CONTAINED", c.width - 3, 11, font = "4x5", color = "gray", align = "right")
    if n["contain"] < 0.0:
        c.text("N/A", c.width - 3, 20, font = "6x8", color = "gray", align = "right")
    else:
        c.text(str(int(n["contain"] + 0.5)) + "%", c.width - 3, 20, font = "6x8", color = "green", align = "right")