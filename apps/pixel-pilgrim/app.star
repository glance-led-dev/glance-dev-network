# Pixel Pilgrim -- one traveler moving through a shared route of cities.
#
# PILGRIM_API is blank while the shared service is developed. The deterministic
# fallback is for local visual testing; it does not pretend app.star has shared
# storage. Hidden preview inputs: _debugcity = CITY|ST, _debugslot = integer.

PILGRIM_API = ""
GEO_URL = "https://api.zippopotam.us/us/"

INK = "#020506"
GREEN = "#66D06B"
MINT = "#B8F2C0"
DIM = "#819292"
AMBER = "#FFD166"
SKY = "#17334D"

DIGITS = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4,
          "5": 5, "6": 6, "7": 7, "8": 8, "9": 9}

ROUTE = [
    {"city": "PORTLAND", "state": "ME", "scene": 0},
    {"city": "BROOKLYN", "state": "NY", "scene": 1},
    {"city": "PITTSBURGH", "state": "PA", "scene": 2},
    {"city": "ATLANTA", "state": "GA", "scene": 3},
    {"city": "NEW ORLEANS", "state": "LA", "scene": 4},
    {"city": "CHICAGO", "state": "IL", "scene": 5},
    {"city": "AUSTIN", "state": "TX", "scene": 6},
    {"city": "DENVER", "state": "CO", "scene": 7},
    {"city": "PHOENIX", "state": "AZ", "scene": 8},
    {"city": "LAS VEGAS", "state": "NV", "scene": 9},
    {"city": "LOS ANGELES", "state": "CA", "scene": 10},
    {"city": "SEATTLE", "state": "WA", "scene": 11},
]

KEEPSAKES = ["BLUE KEY", "TIN STAR", "RED FEATHER", "GLASS COIN",
             "TINY BELL", "MOON SEED", "BRASS MAP", "GREEN STONE"]


def zip_seed(value):
    seed = 0
    for i in range(len(value)):
        seed = seed * 10 + DIGITS.get(value[i], 0)
    return seed


def clean_place(city, state):
    city = str(city).strip().upper()
    state = str(state).strip().upper()
    if city == "":
        city = "YOUR CITY"
    return {"city": city, "state": state, "scene": (len(city) * 3 + len(state)) % 12}


def zip_input(ctx):
    return str(ctx.inputs.get("zip", "10001")).strip()


def is_zip(value):
    if len(value) != 5:
        return False
    for i in range(5):
        if value[i] not in DIGITS:
            return False
    return True


def local_place(ctx):
    debug = str(ctx.inputs.get("_debugcity", "")).strip()
    if debug != "":
        parts = debug.split("|")
        return clean_place(parts[0], parts[1] if len(parts) > 1 else "")
    zip_code = zip_input(ctx)
    if is_zip(zip_code):
        r = http.get(GEO_URL + zip_code, ttl_seconds = 86400)
        if r["status_code"] == 200 and r["json"]:
            places = r["json"].get("places", [])
            if places:
                p = places[0]
                return clean_place(p.get("place name", ""), p.get("state abbreviation", ""))
    # No city to name, so show the ZIP itself (no state marks this case).
    return clean_place(zip_code if zip_code != "" else "NOT SET", "")


def demo_state(ctx, local):
    zip_code = zip_input(ctx)
    slot = ctx.now.unix // 21600
    debug = str(ctx.inputs.get("_debugslot", "")).strip()
    if debug != "":
        slot = int(debug)
    count = len(ROUTE)
    current_i = slot % count
    your_i = zip_seed(zip_code) % count
    away = (your_i - current_i) % count
    current = ROUTE[current_i]
    if away == 0:
        current = local
    seconds_left = 21600 - ctx.now.unix % 21600
    hours_left = max(1, (seconds_left + 3599) // 3600)
    eta_hours = 0 if away == 0 else (away - 1) * 6 + hours_left
    previous = ROUTE[(current_i - 1) % count]
    following = ROUTE[(current_i + 1) % count]
    return {"current": current, "previous": previous, "next": following,
            "local": local, "is_here": away == 0, "eta_hours": eta_hours,
            "hours_left": hours_left,
            "keepsake": KEEPSAKES[(current_i - 1) % len(KEEPSAKES)]}


def service_place(d, key):
    place = d.get(key) or {}
    return clean_place(place.get("city", ""), place.get("state", ""))


def network_state(ctx):
    if PILGRIM_API == "":
        return demo_state(ctx, local_place(ctx))
    zip_code = zip_input(ctx)
    if not is_zip(zip_code):
        return {"lost": "CHECK ZIP"}
    # Keep ttl_seconds in sync with refresh in manifest.yaml.
    r = http.get(PILGRIM_API + "/v1/journey?zip=" + zip_code, ttl_seconds = 1800)
    if r["status_code"] == 400 or r["status_code"] == 422:
        return {"lost": "CHECK ZIP"}
    if r["status_code"] == 200 and r["json"] and r["json"].get("ok", False):
        d = r["json"]
        return {"local": service_place(d, "local"),
                "current": service_place(d, "current"),
                "previous": service_place(d, "previous"),
                "next": service_place(d, "next"),
                "is_here": d.get("is_here", False),
                "eta_hours": d.get("eta_hours", 0),
                "hours_left": d.get("hours_left", 1),
                "keepsake": str(d.get("keepsake", "")).upper()}
    # Never fall back to the demo route here: it would show a made-up location.
    return {"lost": "NO SIGNAL"}


def label(place, limit = 0):
    city = place["city"]
    state = place["state"]
    full = city + (", " + state if state != "" else "")
    if limit <= 0 or len(full) <= limit:
        return full
    # Drop the state before cutting the name: 'LOS ANGE, CA' reads as a typo.
    return city[:limit]


def found_text(keepsake, limit = 0):
    full = "FOUND " + keepsake
    return full if limit <= 0 or len(full) <= limit else keepsake


def eta_text(hours):
    if hours <= 0:
        return "VISITING NOW"
    days = hours // 24
    left = hours % 24
    if days > 0:
        return str(days) + "D " + str(left) + "H"
    return str(hours) + "H"


def bounds(c):
    return [8, 183] if c.width >= 128 else [0, 63]


def city_scene(c, place):
    b = bounds(c)
    x0 = b[0]
    x1 = b[1]
    scene = place.get("scene", 0)
    c.fill(INK)
    c.rect(x0, 7, x1, 21, fill = SKY)
    c.rect(x0, 22, x1, 31, fill = "#18332D")
    c.fill_circle(x1 - 9, 12, 4, AMBER)
    for x in range(x0 + 2, x1, 11):
        height = 5 + (x + scene * 3) % 9
        col = "#274E55" if (x // 11) % 2 == 0 else "#335B5A"
        c.rect(x, 22 - height, min(x + 8, x1), 27, fill = col)
        c.pixel(x + 2, 24 - height, AMBER)
        c.pixel(min(x + 6, x1), 26 - height, "#8FE3D1")
    c.hline(x0, 28, x1 - x0 + 1, "#3A6855")


def pilgrim(c, cx, ground):
    c.fill_circle(cx, ground - 13, 5, GREEN)
    c.rect(cx - 5, ground - 13, cx + 5, ground - 8, fill = GREEN)
    c.fill_circle(cx, ground - 11, 3, "#F1C27D")
    c.pixel(cx + 2, ground - 12, INK)
    c.rect(cx - 5, ground - 7, cx + 4, ground - 1, fill = "#4E8B62")
    c.rect(cx - 9, ground - 7, cx - 5, ground - 2, fill = AMBER)
    c.line(cx - 2, ground, cx - 5, ground + 3, MINT)
    c.line(cx + 2, ground, cx + 5, ground + 3, MINT)
    c.line(cx + 8, ground - 14, cx + 8, ground + 3, AMBER)
    c.pixel(cx + 7, ground - 15, MINT)


def top(c, title, right, color = GREEN):
    b = bounds(c)
    c.rect(b[0], 0, b[1], 6, fill = INK)
    if c.width >= 128:
        c.text(title, 11, 1, font = "4x5", color = color)
        c.text(right, 181, 1, font = "4x5", color = DIM, align = "right")
    else:
        c.text_fit(title, 2, 1, ["4x5", "3x4"], color = color, maxw = 60 if right == "" else 47)
        c.text(right, 62, 1, font = "4x5", color = DIM, align = "right")


def lost(c, message):
    city_scene(c, {"scene": 0})
    if c.width >= 128:
        pilgrim(c, 45, 25)
        c.rect(72, 8, 180, 30, fill = INK, outline = GREEN)
        c.text("PILGRIM STATUS", 126, 10, font = "4x5", color = DIM, align = "center")
        c.text(message, 126, 17, font = "7x12", color = AMBER, align = "center")
        top(c, "PIXEL PILGRIM", "")
    else:
        pilgrim(c, 31, 19)
        c.rect(0, 23, 63, 31, fill = INK)
        c.text(message, 32, 25, font = "4x5", color = AMBER, align = "center")


def where(c, ctx):
    s = network_state(ctx)
    if "lost" in s:
        return lost(c, s["lost"])
    city_scene(c, s["current"])
    if c.width >= 128:
        pilgrim(c, 45, 25)
        c.rect(72, 8, 180, 30, fill = INK, outline = GREEN)
        c.text("NOW VISITING", 126, 10, font = "4x5", color = DIM, align = "center")
        # Starts at 7x12: 10x16 at y=17 ends at y=33, through the box and off the panel.
        c.text_fit(label(s["current"], 25), 126, 17, ["7x12", "6x8", "5x7", "4x5", "3x4"], color = MINT, align = "center", maxw = 102)
        top(c, "PIXEL PILGRIM", str(s["hours_left"]) + "H LEFT")
    else:
        pilgrim(c, 31, 19)
        c.rect(0, 23, 63, 31, fill = INK)
        # 15 chars of 3x4 is the panel width, so the 'IN ' goes before the city is cut.
        place = s["current"]
        line = "IN " + label(place, 12) if len(place["city"]) <= 12 else label(place, 15)
        c.text_fit(line, 32, 23, ["3x4"], color = MINT, align = "center", maxw = 63)
        c.text(str(s["hours_left"]) + "H LEFT", 32, 28, font = "3x4", color = GREEN, align = "center")


def arrival(c, ctx):
    s = network_state(ctx)
    if "lost" in s:
        return lost(c, s["lost"])
    local_head = "YOUR CITY" if s["local"]["state"] != "" else "YOUR ZIP"
    arrival_head = "PILGRIM IS" if s["is_here"] else "ARRIVES IN"
    arrival_value = "HERE NOW" if s["is_here"] else eta_text(s["eta_hours"])
    c.fill(INK)
    if c.width >= 128:
        c.rect(10, 8, 181, 30, fill = "#0C1A18", outline = GREEN)
        c.text(local_head, 24, 11, font = "4x5", color = DIM)
        # y=17: 7x12 at y=18 ended on the box outline at y=30.
        c.text_fit(label(s["local"], 21), 24, 17, ["7x12", "6x8", "5x7", "4x5", "3x4"], color = GREEN, maxw = 88)
        c.vline(116, 10, 19, "#23443C")
        c.text(arrival_head, 148, 11, font = "4x5", color = DIM, align = "center")
        c.text_fit(arrival_value, 148, 17, ["7x12", "6x8", "5x7"], color = AMBER, align = "center", maxw = 58)
    else:
        # Rows at 1/7/13/19/25 keep the 1px gap; 5x7 ran into the row below it.
        c.text(local_head, 32, 7, font = "4x5", color = DIM, align = "center")
        c.text_fit(label(s["local"], 15), 32, 13, ["4x5", "3x4"], color = GREEN, align = "center", maxw = 60)
        c.text(arrival_head, 32, 19, font = "4x5", color = DIM, align = "center")
        c.text_fit(arrival_value, 32, 25, ["4x5", "3x4"], color = AMBER, align = "center", maxw = 60)
    top(c, "VISITING YOU" if s["is_here"] else "ON THE WAY", "")


def journal(c, ctx):
    s = network_state(ctx)
    if "lost" in s:
        return lost(c, s["lost"])
    city_scene(c, s["previous"])
    if c.width >= 128:
        c.rect(60, 8, 180, 30, fill = INK, outline = AMBER)
        # Rows at 10/16/24 clear the box outline at y=8 and y=30. 5x7 is the largest
        # city face that keeps the 1px gaps; 6x8 touched the rows around it.
        c.text("LAST CITY", 120, 10, font = "4x5", color = DIM, align = "center")
        c.text_fit(label(s["previous"], 27), 120, 16, ["5x7", "4x5", "3x4"], color = MINT, align = "center", maxw = 112)
        c.text(found_text(s["keepsake"]), 120, 24, font = "4x5", color = AMBER, align = "center")
    else:
        c.rect(0, 7, 63, 13, fill = INK)
        c.text_fit(label(s["previous"], 15), 32, 8, ["4x5", "3x4"], color = MINT, align = "center", maxw = 60)
        c.rect(0, 24, 63, 31, fill = INK)
        # 'FOUND RED FEATHER' is 67px even at 3x4, so long keepsakes lose the verb.
        c.text_fit(found_text(s["keepsake"], 15), 32, 25, ["4x5", "3x4"], color = AMBER, align = "center", maxw = 60)
    top(c, "TRAVEL JOURNAL" if c.width >= 128 else "LAST STOP", "")
