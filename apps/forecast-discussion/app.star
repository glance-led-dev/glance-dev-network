# Forecast Discussion (192x32)
#
# The local National Weather Service office's Area Forecast Discussion in
# plain English. Most offices open the discussion with a short KEY
# MESSAGES list written for the public; the app shows those (or the
# SYNOPSIS where an office has none), plus WHAT HAS CHANGED, with the
# forecaster shorthand translated. The technical sections (aviation,
# marine, climate, point temperature tables) are skipped, and so is any
# boating or aviation talk inside the summary; beach and coastal hazards
# stay.
#
# The intro shows where, which office and when, and picture tiles for the
# discussion's biggest topics, ranked, each kept only if the zip's own
# point forecast backs it up (no frost tile where lows stay in the 50s).
# The text flows across exactly five pages, each in the biggest font its
# text fits, so nothing repeats and nothing is left out. Every page names
# the town and zip it is for.
#
# Sources (no keys): zippopotam.us (OpenStreetMap for territories) to place
# the zip code; api.weather.gov for the forecast office, its latest
# discussion and the point forecast.

USER_AGENT = "GDN-Forecast-Discussion (glance-led-panel)"
NWS = "https://api.weather.gov/"

GOLD = "#F5C542"
TITLE = "#FFFFFF"
DIM = "#8A8F98"
BODY = "#E8E8E8"

SLOTS = 5   # point1..point5

# ---------- text and fonts ----------

FONT_PUNCT = {
    "4x5": " !#$%&'()+,-./:|",
    "5x7": " !$%&'()*+,-./:^|",
    "5x5": " $%+-.:",
    "picopixel": " !#$%&+-./:=>",
}
ALNUM = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

def font_ok(text, font):
    punct = FONT_PUNCT.get(font, " ")
    for i in range(len(text)):
        ch = text[i]
        if ALNUM.find(ch) < 0 and punct.find(ch) < 0:
            return False
    return True

def wrap(c, text, font, w):
    lines = []
    cur = ""
    for word in text.split(" "):
        cand = word if cur == "" else cur + " " + word
        if cur == "" or c.text_width(cand, font = font) <= w:
            cur = cand
        else:
            lines.append(cur)
            cur = word
    if cur != "":
        lines.append(cur)
    return lines

def fit_line(c, text, fonts, w):
    for f in fonts:
        if font_ok(text, f) and c.text_width(text, font = f) <= w:
            return text, f
    f = fonts[-1]
    for i in range(len(text), 0, -1):
        t = text[:i].strip() + ".."
        if c.text_width(t, font = f) <= w:
            return t, f
    return "", f

# ---------- plain English ----------

# Multi-word forecaster terms, matched on the lower-cased text.
PHRASES = [
    ("uncertainty remains above average in regards to", "forecasters are still unsure about"),
    ("uncertainty remains above average regarding", "forecasters are still unsure about"),
    ("above average uncertainty in", "forecasters are unsure about"),
    ("above-average uncertainty in", "forecasters are unsure about"),
    ("above average uncertainty", "more uncertainty than usual"),
    ("there is high confidence of", "forecasters are confident of"),
    ("there is high confidence in", "forecasters are confident in"),
    ("the development of a", "a"),
    ("area of low pressure", "storm system"),
    ("low pressure system", "storm system"),
    ("coastal low", "coastal storm"),
    ("frontal system", "front"),
    ("drastically cooler", "much cooler"),
    ("prolonged large seas", "big waves for days"),
    ("large seas", "big waves"),
    ("rough seas", "rough waves"),
    ("backdoor cold front", "cool front from the northeast"),
    ("back door cold front", "cool front from the northeast"),
    ("backdoor cool front", "cool front from the northeast"),
    ("backdoor front", "cool front from the northeast"),
    ("back door front", "cool front from the northeast"),
    ("upper-level ridge", "high pressure aloft"),
    ("upper level ridge", "high pressure aloft"),
    ("upper ridge", "high pressure aloft"),
    ("mid-level ridge", "high pressure aloft"),
    ("upper-level trough", "dip in the jet stream"),
    ("upper level trough", "dip in the jet stream"),
    ("upper trough", "dip in the jet stream"),
    ("shortwave trough", "disturbance"),
    ("short wave trough", "disturbance"),
    ("shortwave", "disturbance"),
    ("cold air advection", "colder air moving in"),
    ("warm air advection", "warmer air moving in"),
    ("moisture advection", "moisture moving in"),
    ("warm sector", "warm air ahead of the front"),
    ("deterministic models", "models"),
    ("deterministic guidance", "models"),
    ("ensemble members", "model runs"),
    ("ensemble guidance", "model runs"),
    ("guidance", "models"),
    ("radiational cooling", "clear-sky cooling"),
    ("boundary layer", "lowest air"),
    ("diurnal", "daytime"),
    ("instability", "storm fuel"),
    ("convection", "storms"),
    ("convective", "storm"),
    ("frontal passage", "the front passing"),
    ("above normal", "warmer than normal"),
    ("below normal", "cooler than normal"),
    ("advect in", "drift in"),
    ("retrograding back towards", "drifting back toward"),
    ("retrograding back toward", "drifting back toward"),
    ("retrograding", "drifting back"),
    ("retrograde", "drift back"),
    ("in regards to", "about"),
    ("at this time", "now"),
    ("at this point", "now"),
]

# Forecaster shorthand, one word at a time.
WORDS = {
    "enc": "eastern NC", "obx": "Outer Banks", "cwa": "area", "fcst": "forecast", "fcsts": "forecasts",
    "hts": "heights", "nrn": "northern", "srn": "southern", "ern": "eastern", "wrn": "western",
    "nrly": "northerly", "srly": "southerly", "erly": "easterly", "wrly": "westerly",
    "nerly": "northeasterly", "nwrly": "northwesterly", "serly": "southeasterly", "swrly": "southwesterly",
    "sct": "scattered", "bkn": "broken", "ovc": "overcast", "tstm": "thunderstorm", "tstms": "thunderstorms",
    "tsra": "thunderstorms", "shra": "showers", "pop": "rain chance", "pops": "rain chances",
    "qpf": "rainfall", "kt": "knots", "kts": "knots", "sca": "small craft advisory",
    "scas": "small craft advisories", "wx": "weather", "precip": "rain", "fropa": "front passage",
    "bndry": "boundary", "ivof": "near", "invof": "near", "aftn": "afternoon", "tngt": "tonight",
    "tonite": "tonight", "tmrw": "tomorrow", "wknd": "weekend", "pres": "pressure", "sfc": "surface",
    "upr": "upper", "lvl": "level", "avg": "average", "approx": "about", "mtn": "mountain",
    "mtns": "mountains", "elev": "elevation", "elevs": "elevations", "slgt": "slight", "chc": "chance",
    "mins": "low temps", "maxes": "high temps", "maxt": "high temps", "mint": "low temps",
    "hwo": "outlook", "rh": "humidity", "rhs": "humidity",
    "locales": "places", "nwd": "north", "swd": "south", "ewd": "east", "wwd": "west",
    "nely": "northeasterly", "nwly": "northwesterly", "sely": "southeasterly", "swly": "southwesterly",
    "lgt": "light", "mod": "moderate", "hvy": "heavy", "isold": "isolated", "ltg": "lightning",
    "vsby": "visibility", "seas": "waves", "ft": "feet", "nm": "miles", "cig": "clouds", "cigs": "clouds",
}

SAFE = {";": ",", "*": "", "=": "", "_": " ", "[": "", "]": "", "\"": "", "~": "about ", "<": "under ",
        ">": "over ", "@": "at ", "?": ".", "!": ".", "#": "", "{": "", "}": ""}

def drop_parens(t):
    out = ""
    depth = 0
    for i in range(len(t)):
        ch = t[i]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth = max(0, depth - 1)
        elif depth == 0:
            out += ch
    return out

def plain(t):
    t = " ".join(drop_parens(t).split())
    t = t.lower()
    for a, b in PHRASES:
        t = t.replace(a, b.lower())
    words = []
    for w in t.split(" "):
        core = w.strip(".,:;!?")
        if core in WORDS:
            w = w.replace(core, WORDS[core].lower(), 1)
        words.append(w)
    t = " ".join(words).replace(" ,", ",").replace(" .", ".")
    out = ""
    for i in range(len(t)):
        ch = t[i]
        out += SAFE.get(ch, ch)
    return " ".join(out.split()).upper()

# ---------- reading the discussion ----------

def is_stamp(t):
    # The "15/249 AM." that some offices put after a section title.
    return t.find("/") > 0 and (t.endswith("AM.") or t.endswith("PM."))

def sections(text):
    out = {}
    name = None
    buf = []
    for raw in text.split("\n"):
        s = raw.strip()
        k = s.find("...")
        if s.startswith(".") and not s.startswith("..") and k > 1:
            if name != None:
                out[name] = "\n".join(buf)
            name = s[1:k].strip().upper()
            rest = s[k + 3:].strip()
            buf = [rest] if rest != "" and not is_stamp(rest) else []
        elif s == "&&" or s == "$$":
            if name != None:
                out[name] = "\n".join(buf)
            name = None
            buf = []
        elif name != None:
            buf.append(s)
    if name != None:
        out[name] = "\n".join(buf)
    return out

def bullet(s):
    # Text after a list marker ("-", "*", "1)", "2."), else None.
    if s.startswith("-") or s.startswith("*"):
        return s[1:].strip()
    if len(s) > 2 and s[0].isdigit() and (s[1] == ")" or s[1] == "."):
        return s[2:].strip()
    return None

def label_item(s):
    # "Marine: Gale Watch..." -> ("MARINE", "Gale Watch...").
    k = s.find(":")
    if k > 2 and k < 16 and s[:k].replace(" ", "").isalpha():
        return s[:k].upper(), s[k + 1:].strip()
    return None, s

def key_items(body):
    # "-" and numbered lines start a message; "*" lines add detail to the
    # message above. Region headings ("West Coast...") and links are dropped.
    items = []
    cur = None
    primary = ""
    for s in body.split("\n"):
        if bullet(s) != None:
            primary = s[0] if (s[0] == "-" or s[0] == "*") else "1"
            break
    for s in body.split("\n"):
        low = s.lower()
        if (s == "" or low.startswith("http") or low.startswith("www.") or (s.endswith("...") and bullet(s) == None) or
            low.startswith("issued at ") or low.startswith("updated at ") or is_stamp(s)):
            if s == "" and cur != None:
                items.append(cur)
                cur = None
            continue
        b = bullet(s)
        if s.startswith("*") and primary != "*" and cur != None:
            cur["text"] = cur["text"] + " " + b
            continue
        lab, rest = label_item(s if b == None else b)
        if b != None or lab != None:
            if cur != None:
                items.append(cur)
            cur = {"label": lab, "text": rest}
        elif cur != None:
            cur["text"] = cur["text"] + " " + s
        else:
            cur = {"label": None, "text": s}
    if cur != None:
        items.append(cur)
    return [i for i in items if len(i["text"]) > 3]

# Explanations a forecaster tacks onto a point; cut there only when the
# whole summary can't fit the text pages.
CLAUSES = [" as ", " due to ", " because ", " while ", " although ", ", however", " which ", ", with ", " with "]

def condense(t, limit):
    out = []
    used = 0
    for sent in t.split(". "):
        sent = sent.strip().rstrip(".")
        if sent == "":
            continue
        if used + len(sent) > limit:
            low = sent.lower()
            cut = len(sent)
            for cl in CLAUSES:
                k = low.find(cl)
                if k >= 30 and k < cut:
                    cut = k
            sent = sent[:cut].rstrip(",")
            if len(out) > 0 and used + len(sent) > limit:
                break
        out.append(sent + ".")
        used += len(sent) + 2
        if used >= limit:
            break
    return " ".join(out)

def issued(text):
    # "215 PM EDT Thu Oct 15 2026" -> "THU 2:15 PM".
    for line in text.split("\n")[:20]:
        tk = line.strip().split(" ")
        if len(tk) == 7 and (tk[1] == "AM" or tk[1] == "PM") and tk[0].isdigit() and len(tk[0]) >= 3:
            return tk[3].upper() + " " + tk[0][:-2] + ":" + tk[0][-2:] + " " + tk[1]
    return ""

def office_name(text):
    for line in text.split("\n")[:20]:
        s = line.strip()
        if s.startswith("National Weather Service "):
            n = s[len("National Weather Service "):]
            return n.split("/")[-1].upper()
    return ""

SKIP_LABELS = ["MARINE", "BOATING", "AVIATION", "HYDROLOGY"]

# Boating and aviation wording. Beach and shore hazards (surf, rip
# currents, erosion, coastal flooding, surge) are kept.
OFF_WORDS = ["coastal waters", "marine", "mariners", "mariner", "boaters", "boater", "boating", "small craft",
             "gale", "gales", "storm force", "seas", "offshore waters", "nearshore waters", "open waters",
             "the waters", "all waters", "marine zones", "marine area", "gulf waters", "ocean zones", "coastal zones", "aviation", "vfr", "mvfr",
             "ifr", "lifr", "taf", "tafs", "terminals", "ceilings", "cigs", "llws", "knots", "kts", "kt"]
JOINS = [" and ", " with ", " while ", " as ", " but "]

# What a list item must mention to stand on its own once the boating clause
# ahead of it is gone ("..., high surf, and beach erosion are expected").
LAND_WORDS = ["surf", "beach", "erosion", "rip current", "flood", "overwash", "surge", "wind", "gust", "temperature",
              "rain", "shower", "storm", "heat", "cold", "snow", "frost", "freeze", "fog", "fire", "tornado"]

def has_land(t):
    low = t.lower()
    for w in LAND_WORDS:
        if low.find(w) >= 0:
            return True
    return False
LOWER = "abcdefghijklmnopqrstuvwxyz0123456789"

def norm(t):
    # Lower case, everything but letters and digits as spaces (same length).
    t = t.lower()
    out = ""
    for i in range(len(t)):
        out += t[i] if LOWER.find(t[i]) >= 0 else " "
    return out

def first_off(t):
    # Where the first boating/aviation word starts, else -1.
    n = " " + norm(t) + " "
    best = -1
    for w in OFF_WORDS:
        k = n.find(" " + w + " ")
        if k >= 0 and (best < 0 or k < best):
            best = k
    return best

def land_only(sent):
    # The sentence without its boating/aviation part: clauses about the water
    # go; a mixed clause keeps its start; "" when nothing useful is left.
    if first_off(sent) < 0:
        return sent
    parts = sent.split(", ")
    is_list = sent.find(", and ") >= 0 or sent.find(", or ") >= 0
    kept = []
    for k in range(len(parts)):
        pt = parts[k]
        at = first_off(pt)
        if at < 0:
            if k == 0 or len(kept) > 0 or (is_list and has_land(pt)):
                kept.append(pt)
            continue
        if k == 0:
            head = pt[:at]
            cut = -1
            for j in JOINS:
                q = head.rfind(j)
                if q > cut:
                    cut = q
            if cut >= 20:
                kept.append(pt[:cut])
    if len(kept) > 0:
        for lead in ["and ", "or ", "with "]:
            if kept[0].lower().startswith(lead):
                kept[0] = kept[0][len(lead):]
    if len(kept) == 2 and kept[1].lower().startswith("and "):
        out = kept[0] + " " + kept[1]
    else:
        out = ", ".join(kept)
    out = out.strip().rstrip(",. ")
    if len(out) < 20:
        return ""
    return out[0].upper() + out[1:] + "."

def land_text(t):
    out = []
    for sent in t.split(". "):
        if sent.strip() == "":
            continue
        kept = land_only(sent.strip())
        if kept != "":
            out.append(kept.rstrip(".") + ".")
    return " ".join(out)

def embedded_keys(sec):
    # A "KEY MESSAGES:" list inside another section's text: the lines after
    # it up to the first plain paragraph that follows the list.
    for name in ["DISCUSSION", "PREV DISCUSSION", "SYNOPSIS", "UPDATE", "SHORT TERM", "NEAR TERM"]:
        for k in sec:
            if k != name and not k.startswith(name + " "):
                continue
            lines = sec[k].split("\n")
            for i in range(len(lines)):
                if lines[i].strip().upper().startswith("KEY MESSAGES"):
                    out = []
                    seen = False
                    gap = False
                    for ln in lines[i + 1:]:
                        t = ln.strip()
                        if t == "":
                            gap = True
                            out.append("")
                            continue
                        if bullet(t) != None:
                            seen = True
                        elif seen and gap:
                            break
                        gap = False
                        out.append(t)
                    if seen:
                        return "\n".join(out)
    return ""

def section_body(sec, names):
    # The first named section with something left after the boating and
    # aviation filter.
    for name in names:
        for k in sec:
            if (k == name or k.startswith(name + " ")) and sec[k].strip() != "":
                t = land_text(" ".join(sec[k].split()))
                lab, rest = label_item(t)
                if lab != None:
                    t = rest
                if t.strip() != "":
                    return t
    return ""

def cards(text):
    """Everything to show, in the forecasters' order: what changed, then
    each key message (or the synopsis where an office has none). kind:
    new / point / big; raw = the forecasters' wording before plain()."""
    sec = sections(text)
    out = []
    new = land_text(" ".join(sec.get("WHAT HAS CHANGED", "").split()))
    if new != "":
        out.append({"kind": "new", "num": 0, "raw": new})
    keys = sec.get("KEY MESSAGES", "")
    if keys.strip() == "":
        keys = embedded_keys(sec)
    items = [i for i in key_items(keys) if i["label"] not in SKIP_LABELS]
    for i in items:
        t = land_text(" ".join(i["text"].split()))
        if t != "":
            out.append({"kind": "point", "num": 0, "raw": t})
    if len(items) == 0:
        big = section_body(sec, ["SYNOPSIS", "UPDATE", "DISCUSSION", "PREV DISCUSSION", "SHORT TERM", "NEAR TERM"])
        if big != "":
            out.append({"kind": "big", "num": 0, "raw": big if len(big) < 700 else condense(big, 600)})
    n = 0
    for k in range(len(out)):
        out[k]["i"] = k
        if out[k]["kind"] == "point":
            n += 1
            out[k]["num"] = n
        out[k]["text"] = plain(out[k]["raw"])
    return out

def filler(text):
    # The synopsis, when the key points alone are too short to fill the pages.
    s = section_body(sections(text), ["SYNOPSIS"])
    return plain(condense(s, 300)) if s != "" else ""

# ---------- topics, most important first ----------

# (name, words, color, tier): tier 1 = hazards, 2 = notable weather,
# 3 = trends. Within a tier the topic the forecasters raise first wins.
TOPICS = [
    ("TROPICAL", ["tropical storm", "hurricane", "tropical depression"], "#FF4FA3", 1),
    ("RECORD HEAT", ["record heat", "record high", "record warm"], "#FF5A4E", 1),
    ("HEAT", ["heat index", "heat advisory", "excessive heat", "extreme heat", "heat risk", "heat illness", "hot "], "#FF8C1A", 1),
    ("STORMS", ["thunderstorm", "severe"], "#C77DFF", 1),
    ("SNOW", ["snow", "winter storm", "blizzard"], "#FFFFFF", 1),
    ("ICE", ["freezing rain", "sleet", "icy"], "#9FD8FF", 1),
    ("FREEZE", ["freeze", "freezing temp", "below freezing", "hard freeze"], "#6FC3E0", 1),
    ("FROST", ["frost"], "#C9ECFF", 1),
    ("FLOOD", ["flood"], "#3DDC84", 1),
    ("FIRE DANGER", ["fire weather", "red flag", "critical fire", "fire danger"], "#FF6B35", 1),
    ("WIND", ["wind", "gust", "breezy", "santa ana"], "#2DD4BF", 2),
    ("RAIN", ["rain", "shower"], "#4C8DFF", 2),
    ("FOG", ["fog"], "#B0B7C3", 2),
    ("SMOKE", ["smoke", "air quality"], "#A8A29E", 2),
    ("ROUGH SURF", ["rip current", "high surf", "surf", "waves", "beach erosion", "overwash"], "#38BDF8", 2),
    ("COOLER", ["cooler", "colder", "chilly", "cool down", "cooldown", "crisp", "chillier"], "#7DD3FC", 3),
    ("WARMER", ["warmer", "warm up", "warming", "above normal"], "#FBBF24", 3),
    ("DRY", ["dry", "drier"], "#D6B37A", 3),
]

def topics(cs):
    found = []
    for n in range(len(TOPICS)):
        name, keys, col, tier = TOPICS[n]
        first = -1
        for c in cs:
            t = " " + c["text"].lower() + " "
            for k in keys:
                if t.find(k) >= 0:
                    first = c["i"]
                    break
            if first >= 0:
                break
        if first >= 0:
            found.append((tier, first, n, name, col))
    names = [f[3] for f in found]
    # The stronger word covers the weaker: record heat over heat, freeze over frost.
    found = [f for f in found if not ((f[3] == "HEAT" and "RECORD HEAT" in names) or (f[3] == "FROST" and "FREEZE" in names))]
    return [(f[3], f[4]) for f in sorted(found)]

# ---------- data ----------

def get(url, ttl, params = None, headers = None):
    h = {"User-Agent": USER_AGENT}
    if headers != None:
        h.update(headers)
    if params != None:
        return http.get(url, params = params, headers = h, ttl_seconds = ttl)
    return http.get(url, headers = h, ttl_seconds = ttl)

def geocode(text):
    # A 5-digit US zip (ZIP+4 uses its first five). An unknown zip answers
    # 404, cached like any other answer so a typo can't refetch every page.
    t = text.strip()[:5]
    if len(t) != 5 or not t.isdigit():
        return None
    # zippopotam has no Puerto Rico, Virgin Islands (00xxx), Guam (9691x-9693x)
    # or American Samoa (96799); those go straight to OpenStreetMap.
    territory = t.startswith("00") or (t >= "96910" and t <= "96939") or t == "96799"
    if not territory:
        r = get("https://api.zippopotam.us/us/" + t, 2592000)
        if r["status_code"] != 200 or r["json"] == None or len(r["json"].get("places", [])) == 0:
            return None
        p = r["json"]["places"][0]
        label = ascii_name((str(p.get("place name", t)) + " " + str(p.get("state abbreviation", ""))).strip())
        return {"lat": float(p["latitude"]), "lon": float(p["longitude"]), "label": label, "zip": t}
    r = get("https://nominatim.openstreetmap.org/search", 2592000,
            params = {"postalcode": t, "countrycodes": "us,pr,vi,gu,as,mp", "format": "json", "limit": "1", "addressdetails": "1"})
    if r["status_code"] != 200 or r["json"] == None or len(r["json"]) == 0:
        return None
    p = r["json"][0]
    a = p.get("address", {})
    place = a.get("city") or a.get("town") or a.get("village") or a.get("hamlet") or a.get("county") or t
    st = str(a.get("ISO3166-2-lvl4", "")).split("-")[-1] or str(a.get("country_code", "")).upper()
    return {"lat": float(p["lat"]), "lon": float(p["lon"]), "label": ascii_name((str(place) + " " + st).strip()), "zip": t}

FOLD = [("Å", "A"), ("Á", "A"), ("À", "A"), ("Â", "A"), ("Ä", "A"), ("Ã", "A"), ("É", "E"), ("È", "E"), ("Ê", "E"),
        ("Ë", "E"), ("Í", "I"), ("Ì", "I"), ("Î", "I"), ("Ï", "I"), ("Ó", "O"), ("Ò", "O"), ("Ô", "O"), ("Ö", "O"),
        ("Õ", "O"), ("Ú", "U"), ("Ù", "U"), ("Û", "U"), ("Ü", "U"), ("Ñ", "N"), ("Ç", "C"), ("'", ""), ("`", "")]

def ascii_name(t):
    t = t.upper()
    for a, b in FOLD:
        t = t.replace(a, b)
    return t

def coord(x):
    return str(int(x * 10000) / 10000.0)

def office_for(loc):
    # (forecast office, URL of the point forecast for this exact spot).
    r = get(NWS + "points/" + coord(loc["lat"]) + "," + coord(loc["lon"]), 2592000)
    if r["status_code"] != 200 or r["json"] == None:
        return None, None
    pr = r["json"].get("properties", {})
    return pr.get("cwa"), pr.get("forecast")

def numbers_in(t):
    # Every whole number in a string ("20 to 26 mph" -> [20, 26]).
    out = []
    cur = ""
    for i in range(len(t) + 1):
        ch = t[i] if i < len(t) else " "
        if ch.isdigit():
            cur += ch
        elif cur != "":
            out.append(int(cur))
            cur = ""
    return out

def point_forecast(url):
    # The 7-day forecast for the zip's own 1.5-mile grid square, boiled down:
    # coldest low, strongest wind or gust, best rain chance and the wording,
    # so a tile can be checked against this spot.
    if url == None:
        return None
    r = get(url, 1800)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    lo = 999
    gust = 0
    pop = 0
    text = ""
    for p in r["json"].get("properties", {}).get("periods", []):
        t = p.get("temperature")
        if t != None and not p.get("isDaytime"):
            lo = min(lo, int(t))
        for n in numbers_in(str(p.get("windSpeed", ""))):
            gust = max(gust, n)
        d = str(p.get("detailedForecast", ""))
        k = d.find("gusts as high as ")
        if k >= 0:
            ns = numbers_in(d[k:k + 24])
            if len(ns) > 0:
                gust = max(gust, ns[0])
        v = (p.get("probabilityOfPrecipitation") or {}).get("value")
        if v != None:
            pop = max(pop, int(v))
        text += " " + str(p.get("shortForecast", "")).lower() + " " + d.lower()
    return {"lo": lo, "gust": gust, "pop": pop, "text": text}

def local_check(name, pf):
    # Does this spot's own forecast back the tile up? Hazards the forecast
    # grid can't confirm (flood, fire, surf, tropical...) stay.
    if pf == None:
        return True
    t = pf["text"]
    if name == "FROST":
        return pf["lo"] <= 36 or t.find("frost") >= 0
    if name == "FREEZE":
        return pf["lo"] <= 32 or t.find("freeze") >= 0
    if name == "WIND":
        return pf["gust"] >= 25 or t.find("breezy") >= 0 or t.find("windy") >= 0
    if name == "RAIN":
        return pf["pop"] >= 20 or t.find("rain") >= 0 or t.find("shower") >= 0
    if name == "STORMS":
        return t.find("thunderstorm") >= 0 or t.find("t-storm") >= 0
    if name == "SNOW":
        return t.find("snow") >= 0
    if name == "ICE":
        return t.find("freezing rain") >= 0 or t.find("sleet") >= 0 or t.find("ice") >= 0
    if name == "FOG":
        return t.find("fog") >= 0
    return True

def local_topics(tp, pf):
    # The office-wide topics that hold for this spot.
    out = []
    for name, col in tp:
        ok = local_check(name, pf)
        if not ok and name == "FREEZE":
            # Not a freeze here, but maybe still frost.
            name, col = "FROST", "#C9ECFF"
            ok = local_check(name, pf)
        if ok:
            out.append((name, col))
    return out

def latest_afd(office):
    # The list is cached 10 minutes so, with the 15-minute refresh, a new
    # discussion shows within about 25 minutes; each issued one never changes.
    r = get(NWS + "products/types/AFD/locations/" + office, 600)
    if r["status_code"] != 200 or r["json"] == None:
        return None
    g = r["json"].get("@graph", [])
    if len(g) == 0:
        return None
    # If the newest one won't load, the one before it (usually cached
    # already) beats an empty page.
    for item in g[:2]:
        p = get(item["@id"], 86400)
        if p["status_code"] == 200 and p["json"] != None and p["json"].get("productText"):
            return p["json"]["productText"]
    return None

def world(ctx):
    z = str(ctx.inputs.get("zip", "") or "").strip()
    if z == "":
        return {"error": "ENTER YOUR ZIP CODE"}
    loc = geocode(z)
    if loc == None:
        return {"error": "ZIP CODE NOT FOUND"}
    office, fc_url = office_for(loc)
    if office == None:
        return {"error": "NO NWS OFFICE FOR THIS ZIP", "loc": loc}
    text = latest_afd(office)
    if text == None:
        return {"error": "DISCUSSION UNAVAILABLE", "loc": loc}
    cs = cards(text)
    tp = topics(cs)
    return {"loc": loc, "office": office_name(text) or office, "issued": issued(text), "cards": cs,
            "local": local_topics(tp, point_forecast(fc_url)), "filler": filler(text),
            "points": len([c for c in cs if c["kind"] == "point"])}

# ---------- laying the text out on the pages ----------

# (font, lines per page, line step, first line y), biggest first.
FACES = [("5x7", 3, 8, 8), ("5x5", 4, 6, 7), ("4x5", 4, 6, 7)]

def mark(card):
    # ">" stands for the drawn arrow on What's New.
    if card["kind"] == "new":
        return ">"
    if card["kind"] == "point":
        return str(card["num"])
    return ""

def mark_width(c, mk, font):
    if mk == ">":
        return 4
    return c.text_width(mk, font = font)

def draw_mark(c, mk, x, y, font):
    if mk == ">":
        h = 7 if font == "5x7" else 5
        for k in range(h // 2 + 1):
            c.line(x + k, y + k, x + k, y + h - 1 - k, GOLD)
        return
    c.text(mk, x, y, font = font, color = GOLD)

def sentence_list(t):
    out = []
    for part in t.split(". "):
        part = part.strip()
        if part != "":
            out.append(part if part.endswith(".") else part + ".")
    return out

def wrap_hang(c, text, font, first_w, rest_w):
    lines = []
    cur = ""
    w = first_w
    for word in text.split(" "):
        cand = word if cur == "" else cur + " " + word
        if cur == "" or c.text_width(cand, font = font) <= w:
            cur = cand
        else:
            lines.append(cur)
            cur = word
            w = rest_w
    if cur != "":
        lines.append(cur)
    return lines

def card_lines(c, card, font, by_sentence, hang = True):
    # The gold marker, then the card's lines lined up beside it (hang) or
    # running back to the left edge (more words a line). by_sentence starts
    # each sentence on a new line so pages can break cleanly between them.
    mk = mark(card)
    indent = mark_width(c, mk, font) + 4 if mk != "" else 0
    lines = []
    softs = []
    for sent in (sentence_list(card["text"]) if by_sentence else [card["text"]]):
        first = 188 - indent if len(lines) == 0 or hang else 188
        ls = wrap_hang(c, sent, font, first, 188 - indent if hang else 188)
        for k in range(len(ls)):
            lines.append(ls[k])
            softs.append(k == 0)
    out = []
    for k in range(len(lines)):
        # soft = a new sentence starts this line, a fair place for a page break
        soft = k > 0 and (softs[k] or lines[k - 1].endswith("."))
        comma = k > 0 and lines[k - 1].endswith(",")
        out.append({"card": card["i"], "mark": mk if k == 0 else "", "indent": indent if (k == 0 or hang) else 0,
                    "text": lines[k], "start": k == 0, "soft": soft, "comma": comma})
    return out

def break_cost(lines, cut):
    if lines[cut]["start"]:
        return 0
    if lines[cut]["soft"]:
        return 30
    return 60 if lines[cut]["comma"] else 100

def cut_cost(lines, cut):
    # Cost of starting a new page at line cut: the break itself, plus one
    # stray line of a card at the top of a page or a card's first line
    # alone at the bottom of one.
    n = len(lines)
    cost = break_cost(lines, cut)
    if not lines[cut]["start"] and (cut + 1 == n or lines[cut + 1]["start"]):
        cost += 60
    if lines[cut - 1]["start"] and not lines[cut]["start"]:
        cost += 40
    return cost

# What a page costs by the face it ends up in after enlarge(): breaks are
# chosen so as many pages as possible get the big letters.
PAGE_FACE_COST = {"5x7": 0, "5x5": 12, "4x5": 18}

def split_pages(c, lines, cap, font):
    # SLOTS non-empty pages of at most cap lines with the cheapest breaks,
    # the biggest letters and even pages (best split by dynamic
    # programming). Returns (pages, score).
    n = len(lines)
    if n < SLOTS or n > cap * SLOTS:
        return None, 0
    big = 1 << 30
    dp = [[big for i in range(n + 1)] for k in range(SLOTS + 1)]
    back = [[0 for i in range(n + 1)] for k in range(SLOTS + 1)]
    dp[0][0] = 0
    face_cost = {}
    for k in range(1, SLOTS + 1):
        for e in range(k, n + 1):
            for st in range(max(k - 1, e - cap), e):
                if dp[k - 1][st] >= big:
                    continue
                key = st * 1000 + e
                if key not in face_cost:
                    eg = enlarge(c, lines[st:e], font)
                    face_cost[key] = PAGE_FACE_COST[eg[1] if eg != None else font]
                cost = dp[k - 1][st] + abs((e - st) * SLOTS - n) * 2 // SLOTS + face_cost[key]
                if st > 0:
                    cost += cut_cost(lines, st)
                if cost < dp[k][e]:
                    dp[k][e] = cost
                    back[k][e] = st
    if dp[SLOTS][n] >= big:
        return None, 0
    pages = []
    e = n
    for k in range(SLOTS, 0, -1):
        st = back[k][e]
        pages.insert(0, lines[st:e])
        e = st
    return pages, dp[SLOTS][n]

# A smaller face costs a little, so it wins only when it breaks the text
# more cleanly.
FACE_COST = {"5x7": 0, "5x5": 5, "4x5": 10}

def try_layout(c, cs):
    best = None
    best_score = 0
    for font, cap, step, y0 in FACES:
        if len([cd for cd in cs if not font_ok(cd["text"], font)]) > 0:
            continue
        for by_sentence, hang in [(False, True), (True, True), (False, False), (True, False)]:
            lines = []
            for cd in cs:
                lines += card_lines(c, cd, font, by_sentence, hang)
            if len(lines) < SLOTS and not by_sentence and hang:
                return {"short": lines, "font": font, "step": step, "y0": y0}
            pages, score = split_pages(c, lines, cap, font)
            score += FACE_COST[font] + (5 if by_sentence else 0) + (0 if hang else 25)
            if pages != None and (best == None or score < best_score):
                best = {"pages": pages, "font": font, "step": step, "y0": y0}
                best_score = score
    return best

def layout(c, w):
    cs = w["cards"]
    if len(cs) == 0:
        return None
    lay = try_layout(c, cs)
    if lay != None and "short" in lay and w["filler"] != "":
        # Too little to fill the pages: add the synopsis as the big picture.
        lay = try_layout(c, cs + [{"kind": "big", "num": 0, "i": len(cs), "text": w["filler"]}])
    if lay == None:
        # Too long even in the smallest face: trim the
        # explanations off the longest points.
        trimmed = []
        for limit in [140, 90, 60, 40]:
            trimmed = []
            for cd in cs:
                d = dict(cd)
                d["text"] = plain(condense(cd["raw"], limit))
                trimmed.append(d)
            lay = try_layout(c, trimmed)
            if lay != None:
                break
        if lay == None:
            lines = []
            for cd in trimmed:
                lines += card_lines(c, cd, "4x5", False)
            lines = lines[:4 * SLOTS]
            lines[-1]["text"] = lines[-1]["text"] + "..."
            lay = {"pages": [lines[k:k + 4] for k in range(0, len(lines), 4)], "font": "4x5", "step": 6, "y0": 7}
    if "short" in lay:
        # Fewer lines than pages: one line a page, then the source.
        lay = {"pages": [[ln] for ln in lay["short"]], "font": lay["font"], "step": lay["step"], "y0": lay["y0"]}
    return lay

def page_label(w, page):
    ids = []
    for ln in page:
        if ln["card"] not in ids:
            ids.append(ln["card"])
    parts = []
    nums = []
    for i in ids:
        cd = w["cards"][i] if i < len(w["cards"]) else {"kind": "big", "num": 0}
        if cd["kind"] == "new":
            parts.append("WHAT'S NEW")
        elif cd["kind"] == "big":
            parts.append("THE BIG PICTURE")
        else:
            nums.append(cd["num"])
    if len(nums) > 0:
        word = "POINT" if len(parts) > 0 else "KEY POINT"
        if len(nums) == 1:
            t = word + " " + str(nums[0])
        else:
            t = word + "S " + str(nums[0]) + "-" + str(nums[-1])
        parts.append(t + " OF " + str(w["points"]))
    return " + ".join(parts)

# ---------- weather icons ----------

RAYS = [(0, -1), (1, -1), (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1)]

def sun(c, x, y, r, col, ray):
    for dx, dy in RAYS:
        k = 1 if dx != 0 and dy != 0 else 0
        c.line(x + dx * (r + 2 - k), y + dy * (r + 2 - k), x + dx * (r + 4 - k), y + dy * (r + 4 - k), ray)
    c.fill_circle(x, y, r, col)

def cloud(c, x, y, col):
    c.fill_circle(x - 5, y + 1, 4, col)
    c.fill_circle(x, y - 2, 5, col)
    c.fill_circle(x + 5, y + 1, 4, col)
    c.rect(x - 5, y + 1, x + 5, y + 5, fill = col)

def thermo(c, x, y, col, up):
    c.rect(x - 1, y - 8, x + 1, y + 4, fill = "#FFFFFF")
    c.rect(x, y - 3, x, y + 4, fill = col)
    c.fill_circle(x, y + 6, 3, col)
    ax = x + 7
    if up:
        c.fill_triangle(ax - 3, y - 3, ax + 3, y - 3, ax, y - 7, col)
        c.rect(ax - 1, y - 3, ax + 1, y + 2, fill = col)
    else:
        c.fill_triangle(ax - 3, y + 1, ax + 3, y + 1, ax, y + 5, col)
        c.rect(ax - 1, y - 4, ax + 1, y + 1, fill = col)

def flake(c, x, y, r, col):
    c.line(x - r, y, x + r, y, col)
    c.line(x, y - r, x, y + r, col)
    d = r * 7 // 10
    c.line(x - d, y - d, x + d, y + d, col)
    c.line(x - d, y + d, x + d, y - d, col)
    c.fill_circle(x, y, 1, col)

def icon(c, name, x, y):
    # A picture for a topic, centered on (x, y), about 20 x 18 pixels.
    if name == "RECORD HEAT" or name == "HEAT":
        sun(c, x, y - 1, 5, "#FFD23F" if name == "HEAT" else "#FF7A1A", "#FF3B1F")
        for k in range(3):
            xx = x - 7 + k * 6
            c.pixel(xx, y + 9, "#FFB703")
            c.pixel(xx + 1, y + 8, "#FFB703")
            c.pixel(xx + 2, y + 9, "#FFB703")
    elif name == "WARMER":
        thermo(c, x - 3, y, "#FF5A4E", True)
    elif name == "COOLER":
        thermo(c, x - 3, y, "#4CC9F0", False)
    elif name == "DRY":
        sun(c, x, y - 2, 4, "#FFD23F", "#F4A261")
        c.line(x - 9, y + 8, x + 9, y + 8, "#C08552")
        c.line(x - 3, y + 8, x - 1, y + 6, "#C08552")
        c.line(x + 3, y + 8, x + 5, y + 6, "#C08552")
    elif name == "RAIN" or name == "FLOOD":
        cloud(c, x, y - 4, "#C9D1D9")
        for k in range(4):
            xx = x - 6 + k * 4
            c.line(xx, y + 4, xx - 1, y + 7, "#4C8DFF")
        if name == "FLOOD":
            for k in range(0, 20, 4):
                c.line(x - 10 + k, y + 9, x - 8 + k, y + 8, "#3DDC84")
                c.line(x - 8 + k, y + 8, x - 6 + k, y + 9, "#3DDC84")
    elif name == "STORMS":
        cloud(c, x, y - 4, "#8E99A8")
        c.fill_triangle(x + 1, y + 1, x - 4, y + 6, x, y + 6, "#FFE600")
        c.fill_triangle(x, y + 5, x + 3, y + 5, x - 3, y + 10, "#FFE600")
    elif name == "SNOW":
        cloud(c, x, y - 4, "#E6EDF3")
        for dx, dy in [(-6, 5), (-1, 7), (4, 5), (8, 8), (-4, 9), (1, 10)]:
            c.pixel(x + dx, y + dy, "#FFFFFF")
    elif name == "ICE":
        cloud(c, x, y - 4, "#B8C4D0")
        for dx, dy in [(-6, 5), (-2, 7), (2, 5), (6, 7)]:
            c.rect(x + dx, y + dy, x + dx + 1, y + dy + 1, fill = "#9FD8FF")
    elif name == "FREEZE":
        flake(c, x, y, 8, "#9FD8FF")
    elif name == "FROST":
        # A smaller, paler flake over frosted ground.
        flake(c, x, y - 2, 6, "#E3F6FF")
        c.rect(x - 9, y + 7, x + 9, y + 8, fill = "#7FA7C2")
        for dx in [-8, -4, 0, 4, 8]:
            c.pixel(x + dx, y + 6, "#FFFFFF")
    elif name == "WIND":
        c.line(x - 9, y - 4, x + 4, y - 4, "#2DD4BF")
        c.line(x + 5, y - 5, x + 6, y - 7, "#2DD4BF")
        c.line(x - 9, y, x + 8, y, "#5EEAD4")
        c.line(x + 9, y - 1, x + 9, y - 3, "#5EEAD4")
        c.line(x - 9, y + 4, x + 2, y + 4, "#2DD4BF")
        c.line(x + 3, y + 5, x + 4, y + 7, "#2DD4BF")
    elif name == "FIRE DANGER":
        c.fill_triangle(x - 7, y + 8, x + 7, y + 8, x, y - 9, "#E63946")
        c.fill_triangle(x - 5, y + 8, x + 5, y + 8, x + 1, y - 4, "#FF8C1A")
        c.fill_triangle(x - 3, y + 8, x + 3, y + 8, x, y, "#FFE066")
    elif name == "FOG" or name == "SMOKE":
        col = "#B0B7C3" if name == "FOG" else "#A8A29E"
        for k in range(4):
            off = 3 if k % 2 == 1 else 0
            c.rect(x - 9 + off, y - 6 + k * 4, x + 6 + off, y - 5 + k * 4, fill = col)
    elif name == "ROUGH SURF":
        c.fill_circle(x - 1, y, 7, "#38BDF8")
        c.fill_circle(x + 2, y - 1, 4, "#000000")
        c.rect(x - 10, y + 6, x + 9, y + 8, fill = "#1E6FD9")
    elif name == "TROPICAL":
        c.fill_circle(x, y, 7, "#FF4FA3")
        c.fill_circle(x, y, 3, "#000000")
        c.fill_triangle(x + 2, y - 8, x + 9, y - 9, x + 6, y - 4, "#FF4FA3")
        c.fill_triangle(x - 2, y + 8, x - 9, y + 9, x - 6, y + 4, "#FF4FA3")
        c.fill_circle(x, y, 1, "#FFFFFF")
    else:
        sun(c, x + 3, y - 3, 4, "#FFD23F", "#FFB703")
        cloud(c, x - 2, y + 2, "#E6EDF3")

TILE = {
    "RECORD HEAT": ("#5C0A00", "#C2410C"), "HEAT": ("#5C1A00", "#D97706"), "WARMER": ("#4A2A00", "#B45309"),
    "COOLER": ("#062A4A", "#1D6FA5"), "FREEZE": ("#041C3A", "#2563EB"), "FROST": ("#0E2A40", "#4A86B0"), "SNOW": ("#14233A", "#4B6A8F"),
    "ICE": ("#0F2438", "#3B6E8F"), "RAIN": ("#0B1A33", "#28456B"), "FLOOD": ("#06261A", "#1C5A44"),
    "STORMS": ("#1A0533", "#4C1D95"), "WIND": ("#03282A", "#0F766E"), "FIRE DANGER": ("#330A00", "#9A3412"),
    "FOG": ("#1F2329", "#4B5563"), "SMOKE": ("#22201E", "#57534E"), "ROUGH SURF": ("#04203A", "#0369A1"),
    "TROPICAL": ("#33001A", "#9D174D"), "DRY": ("#2E1F0A", "#8A6A3A"),
}

def tile_colors(name):
    return TILE.get(name, ("#0B2545", "#2B6CB0"))

# ---------- pages ----------

def error_page(c, w):
    c.fill("#000000")
    c.text("FORECAST DISCUSSION", 2, 0, font = "4x5", color = GOLD)
    c.text(w["error"], 96, 13, font = "5x7", color = TITLE, align = "center")
    if w["error"] == "ENTER YOUR ZIP CODE":
        c.text("IN THIS APP'S SETTINGS", 96, 24, font = "4x5", color = DIM, align = "center")

def place(w):
    return w["loc"]["label"] + " " + w["loc"]["zip"]

def header(c, w, label):
    right, _ = fit_line(c, place(w), ["4x5"], 92)
    rw = c.text_width(right, font = "4x5")
    lab, f = fit_line(c, label, ["4x5"], 188 - rw - 6)
    c.text(lab, 2, 0, font = f, color = GOLD)
    c.text(right, 190, 0, font = "4x5", color = DIM, align = "right")

def short_office(w):
    # "MOREHEAD CITY NC" -> "MOREHEAD CITY" when the state matches the zip's.
    off = w["office"]
    if off.endswith(" " + w["loc"]["label"].split(" ")[-1]):
        off = off[:off.rfind(" ")]
    return off

def topic_tile(c, k, name, col, x0, y0, x1, y1, icon_y, label_y):
    # Gradient tile with the topic's picture, its rank in the corner and its
    # name (one or two lines) underneath.
    a, b = tile_colors(name)
    c.gradient_rect(x0, y0, x1, y1, a, b, horizontal = False)
    cx = (x0 + x1) // 2
    icon(c, name, cx, icon_y)
    c.rect(x0, label_y - 1, x1, y1, fill = "#000000")
    words = name.split(" ")
    w = x1 - x0 - 1
    if len(words) > 1 and c.text_width(name, font = "4x5") > w:
        for r in range(2):
            t, f = fit_line(c, words[r] if r == 0 else " ".join(words[1:]), ["4x5", "picopixel"], w)
            c.text(t, cx + 1, label_y + r * 6, font = f, color = col, align = "center")
    else:
        t, f = fit_line(c, name, ["4x5", "picopixel"], w)
        c.text(t, cx + 1, label_y + (3 if label_y < 24 else 0), font = f, color = col, align = "center")
    c.text(str(k + 1), x0 + 1, y0 + 1, font = "picopixel", color = GOLD)

def intro(c, ctx):
    # Where, which office and when on the left; the topics as picture
    # tiles on the right, most important first.
    w = world(ctx)
    if "error" in w:
        return error_page(c, w)
    c.fill("#000000")
    lab = w["loc"]["label"]
    town = lab[:lab.rfind(" ")] if lab.find(" ") > 0 else lab
    state = lab[lab.rfind(" ") + 1:] if lab.find(" ") > 0 else ""
    tp = w["local"][:4]
    n = len(tp)
    left = 80 if n >= 3 else 104
    t, f = fit_line(c, town, ["5x7", "4x5", "picopixel"], left - 3)
    c.text(t, 2, 1, font = f, color = TITLE)
    c.text(state + " " + w["loc"]["zip"], 2, 10, font = "4x5", color = TITLE)
    t, f = fit_line(c, "NWS " + short_office(w), ["4x5", "picopixel"], left - 3)
    c.text(t, 2, 18, font = f, color = DIM)
    c.text(w["issued"], 2, 25, font = "4x5", color = DIM)
    if n == 0:
        c.text("NO MAJOR", (left + 191) // 2, 9, font = "5x7", color = "#3DDC84", align = "center")
        c.text("WEATHER", (left + 191) // 2, 19, font = "5x7", color = "#3DDC84", align = "center")
        return
    tw_ = (192 - left - (n - 1)) // n
    for k in range(n):
        name, col = tp[k]
        x0 = left + k * (tw_ + 1)
        topic_tile(c, k, name, col, x0, 0, x0 + tw_ - 1, 31, 10, 20)

def point(c, ctx, n):
    w = world(ctx)
    if "error" in w:
        return error_page(c, w)
    c.fill("#000000")
    lay = layout(c, w)
    if lay == None or n > len(lay["pages"]):
        header(c, w, "FORECAST DISCUSSION")
        c.text("THAT'S THE LATEST FROM", 96, 11, font = "4x5", color = DIM, align = "center")
        c.text("NWS " + w["office"], 96, 19, font = "4x5", color = TITLE, align = "center")
        return
    page = lay["pages"][n - 1]
    header(c, w, page_label(w, page))
    font, step, y = lay["font"], lay["step"], lay["y0"]
    big = enlarge(c, page, lay["font"])
    if big != None:
        page, font, step, y = big
    for ln in page:
        if ln["mark"] != "":
            draw_mark(c, ln["mark"], 2, y, font)
        c.text(ln["text"], 2 + ln["indent"], y, font = font, color = BODY)
        y += step

def enlarge(c, page, font):
    # The page's own text rewrapped in the biggest face it fits, so a page
    # with room to spare gets bigger letters. Same words, same page breaks.
    pieces = []
    for ln in page:
        if ln["start"] or len(pieces) == 0:
            pieces.append({"mark": ln["mark"], "words": [ln["text"]]})
        else:
            pieces[-1]["words"].append(ln["text"])
    for f, cap, step, y0 in FACES:
        if f == font:
            return None
        out = []
        for pc in pieces:
            t = " ".join(pc["words"])
            if not font_ok(t, f):
                out = None
                break
            indent = mark_width(c, pc["mark"], f) + 4 if pc["mark"] != "" else (page[0]["indent"] if pc == pieces[0] else 0)
            ls = wrap(c, t, f, 188 - indent)
            for k in range(len(ls)):
                out.append({"mark": pc["mark"] if k == 0 else "", "indent": indent, "text": ls[k]})
        if out != None and len(out) <= cap:
            return out, f, step, y0
    return None

def point1(c, ctx):
    point(c, ctx, 1)

def point2(c, ctx):
    point(c, ctx, 2)

def point3(c, ctx):
    point(c, ctx, 3)

def point4(c, ctx):
    point(c, ctx, 4)

def point5(c, ctx):
    point(c, ctx, 5)
