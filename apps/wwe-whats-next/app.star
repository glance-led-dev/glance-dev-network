# DESIGN. Miniature arena match-card on 192x32. Black field, 2px brand
# rail, compact eyebrow, wrestler names as the hero. No portraits, no
# source chrome, no full-screen header. Title matches with icons reuse
# the WWE Champions 72x32 belt at x=10. Previous-show results reuse that
# layout. City/time from the lineup when present. If the card omits them,
# WWE.com events fills the dated city and the single next PLE on the overview.
BRANDS = ["RAW", "SMACKDOWN", "NXT"]
COLORS = {"RAW": "#E10600", "SMACKDOWN": "#3D7EFF", "NXT": "#E7B43A", "WWE": "#D8DEE8"}
DEEP = {"RAW": "#6B0000", "SMACKDOWN": "#10244A", "NXT": "#3A2E10", "WWE": "#101018"}
INK = {"RAW": "#FFFFFF", "SMACKDOWN": "#FFFFFF", "NXT": "#101018", "WWE": "#101018"}
STATES = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY", "DC"]
STATE_NAMES = {"ALABAMA": "AL", "ALASKA": "AK", "ARIZONA": "AZ", "ARKANSAS": "AR", "CALIFORNIA": "CA", "COLORADO": "CO", "CONNECTICUT": "CT", "DELAWARE": "DE", "FLORIDA": "FL", "GEORGIA": "GA", "HAWAII": "HI", "IDAHO": "ID", "ILLINOIS": "IL", "INDIANA": "IN", "IOWA": "IA", "KANSAS": "KS", "KENTUCKY": "KY", "LOUISIANA": "LA", "MAINE": "ME", "MARYLAND": "MD", "MASSACHUSETTS": "MA", "MICHIGAN": "MI", "MINNESOTA": "MN", "MISSISSIPPI": "MS", "MISSOURI": "MO", "MONTANA": "MT", "NEBRASKA": "NE", "NEVADA": "NV", "NEW HAMPSHIRE": "NH", "NEW JERSEY": "NJ", "NEW MEXICO": "NM", "NEW YORK": "NY", "NORTH CAROLINA": "NC", "NORTH DAKOTA": "ND", "OHIO": "OH", "OKLAHOMA": "OK", "OREGON": "OR", "PENNSYLVANIA": "PA", "RHODE ISLAND": "RI", "SOUTH CAROLINA": "SC", "SOUTH DAKOTA": "SD", "TENNESSEE": "TN", "TEXAS": "TX", "UTAH": "UT", "VERMONT": "VT", "VIRGINIA": "VA", "WASHINGTON": "WA", "WEST VIRGINIA": "WV", "WISCONSIN": "WI", "WYOMING": "WY", "ONTARIO": "ON"}
SKIP_PLACE = ["THE", "A", "AN", "HIS", "HER", "THIS", "THAT", "RAW", "SMACKDOWN", "NXT", "WWE", "OUR", "YOUR", "SOCIAL", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY", "TONIGHT", "TODAY", "LAST", "NEXT", "RIGHT", "HERE", "LIVE", "GOING"]
PLACE_NAMES = {"SAN ANTONIO": "SAN ANTONIO, TX", "ST LOUIS": "ST. LOUIS, MO", "ORLANDO": "ORLANDO, FL", "CHICAGO": "CHICAGO, IL", "LAS VEGAS": "LAS VEGAS, NV", "LOS ANGELES": "LOS ANGELES, CA", "NEW YORK": "NEW YORK, NY", "HOUSTON": "HOUSTON, TX", "ATLANTA": "ATLANTA, GA", "BOSTON": "BOSTON, MA", "PHILADELPHIA": "PHILADELPHIA, PA", "DALLAS": "DALLAS, TX", "DETROIT": "DETROIT, MI", "MIAMI": "MIAMI, FL", "TORONTO": "TORONTO, ON", "NASHVILLE": "NASHVILLE, TN", "PHOENIX": "PHOENIX, AZ", "DENVER": "DENVER, CO", "SEATTLE": "SEATTLE, WA", "TAMPA": "TAMPA, FL", "CHARLOTTE": "CHARLOTTE, NC", "WASHINGTON": "WASHINGTON, DC", "NEW ORLEANS": "NEW ORLEANS, LA", "INDIANAPOLIS": "INDIANAPOLIS, IN", "CORPUS CHRISTI": "CORPUS CHRISTI, TX"}
MONTHS = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]

def settings(ctx):
    brand = str(ctx.inputs.get("brand", "AUTO")).upper()
    results = str(ctx.inputs.get("results", "ON")).upper()
    if results == "TRUE":
        results = "ON"
    if results == "FALSE":
        results = "OFF"
    return {"brand": brand, "valid": brand in BRANDS + ["AUTO"], "results": results == "ON"}

def day_number(y, m, d):
    # Gregorian date to Unix day; also handles December/January boundaries.
    y = y - (1 if m <= 2 else 0)
    era = y // 400
    yo = y - era * 400
    mp = m + (-3 if m > 2 else 9)
    return era * 146097 + yo * 365 + yo // 4 - yo // 100 + (153 * mp + 2) // 5 + d - 1 - 719468

def date_from_heading(heading, published):
    words = heading.replace("(", " ").replace(")", " ").replace(",", " ").replace("|", " ").split()
    pub = published.split()
    if len(pub) < 4 or not pub[3].isdigit():
        return None
    year = int(pub[3])
    pubmonth = 0
    for i in range(12):
        if MONTHS[i][:3] == pub[2].upper():
            pubmonth = i + 1
    # Fightful labels its card blocks with US dates such as (9/25).
    expanded = []
    for word in words:
        pieces = word.split("/")
        if len(pieces) in [2, 3] and pieces[0].isdigit() and pieces[1].isdigit() and int(pieces[0]) in range(1, 13):
            expanded.extend([MONTHS[int(pieces[0]) - 1], pieces[1]])
            if len(pieces) == 3:
                if len(pieces[2]) != 4 or not pieces[2].isdigit():
                    return None
                expanded.append(pieces[2])
        else:
            expanded.append(word)
    words = expanded
    for i in range(len(words) - 1):
        month = 0
        for mi in range(12):
            if words[i].rstrip(".") in [MONTHS[mi], MONTHS[mi][:3], "SEPT" if mi == 8 else ""]:
                month = mi + 1
        if month and words[i + 1].isdigit():
            day = int(words[i + 1])
            y = year + (1 if pubmonth == 12 and month == 1 else 0)
            if i + 2 < len(words) and words[i + 2].isdigit() and len(words[i + 2]) == 4:
                y = int(words[i + 2])
            lengths = [31, 29 if y % 4 == 0 and (y % 100 != 0 or y % 400 == 0) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
            if day > 0 and day <= lengths[month - 1]:
                return {"day": day_number(y, month, day), "label": MONTHS[month - 1][:3] + " " + str(day), "year": y}
    return None

def extras_from_heading(heading):
    # Only the text AFTER the dated parenthesis is a place/time candidate.
    # Never guess a city from the date itself (JANUARY 2, 2030).
    city = ""
    venue = ""
    time = ""
    h = str(heading).upper()
    rest = h
    cut = h.rfind(")")
    if cut >= 0:
        rest = h[cut + 1:].strip(" -")
    for w in (rest + " " + h).split():
        token = w.strip(".,")
        if len(token) >= 4 and token[0].isdigit() and "/" in token and token.endswith("C"):
            time = token
        if token.endswith("ET") and len(token) >= 3 and token[0].isdigit():
            time = token
        if token in ["8PM", "7PM", "9PM", "10PM"]:
            time = token
    comma = rest.find(", ")
    if comma >= 2 and comma + 4 <= len(rest):
        st = rest[comma + 2:comma + 4]
        if st in STATES:
            lead = rest[:comma].strip(" -")
            for prefix in ["IN ", "AT ", "FROM "]:
                if lead.startswith(prefix):
                    lead = lead[len(prefix):]
            if lead != "" and not lead[0].isdigit():
                city = lead + ", " + st
    return {"city": city, "venue": venue, "time": time}

def parse_place_chunk(chunk):
    lead = chunk.strip(" -")
    for stop in [" AND ", " FOR ", " WITH ", " FOLLOWING ", " AFTER ", " BEFORE ", " ON ", " WILL ", " ITS ", " IT'S "]:
        cut = lead.find(stop)
        if cut > 2:
            lead = lead[:cut]
    comma = lead.find(", ")
    if comma < 2:
        return ""
    name = lead[:comma].strip(" -")
    rest = lead[comma + 2:].strip()
    if name == "" or name.split()[0] in SKIP_PLACE:
        return ""
    st = rest.split()[0].strip(",.") if rest else ""
    if st in STATES:
        return name + ", " + st
    if st in STATE_NAMES:
        return name + ", " + STATE_NAMES[st]
    return ""

def city_from_prose(text):
    # 'episode of Raw from San Antonio, Texas' is a real location.
    # Skip 'last week ... from Mexico City' so prior towns never leak in.
    t = " " + str(text).upper().replace(".", "") + " "
    pos = 0
    for _ in range(12):
        i = -1
        marker = ""
        for m in [" FROM ", " IN ", " AT "]:
            at = t.find(m, pos)
            if at >= 0 and (i < 0 or at < i):
                i = at
                marker = m
        if i < 0:
            return ""
        before = t[max(0, i - 28):i]
        if any([bad in before for bad in ["LAST WEEK", "LAST NIGHT", "YESTERDAY", "LAST YEAR"]]):
            pos = i + 3
            continue
        city = parse_place_chunk(t[i + len(marker):])
        if city != "":
            return city
        after = t[i + len(marker):].strip()
        for key in PLACE_NAMES:
            if after.startswith(key + ",") or after.startswith(key + " ") or after.startswith(key + "!") or after.startswith(key):
                if len(after) == len(key) or after[len(key):len(key) + 1] in [" ", ",", "!", "-"]:
                    return PLACE_NAMES[key]
        pos = i + 3
    return ""

def time_from_prose(text):
    t = str(text).upper().replace("P.M.", "PM").replace("P.M", "PM").replace("A.M.", "AM")
    packed = t.replace(" ", "")
    if "8/7C" in packed:
        return "8/7C"
    if "8E/5P" in packed:
        return "8PM ET"
    words = t.replace(",", " ").split()
    for i in range(len(words)):
        w = words[i].strip(".,")
        if w in ["PM", "AM"] and i > 0 and words[i - 1][0].isdigit():
            clock = words[i - 1].strip(".,") + w
            if i + 1 < len(words) and words[i + 1].strip(".,") in ["ET", "CT", "PT"]:
                return clock + " " + words[i + 1].strip(".,")
            return clock
        if len(w) >= 4 and w[0].isdigit() and "/" in w and w.endswith("C"):
            return w
        if w.endswith("ET") and len(w) >= 3 and w[0].isdigit():
            return w
        if w in ["8PM", "7PM", "9PM", "10PM"]:
            return w
    return ""

def extras_from_item(heading, blurb):
    extra = extras_from_heading(heading)
    hay = str(heading) + " " + str(blurb)
    if extra["city"] == "":
        extra["city"] = city_from_prose(hay)
    if extra["time"] == "":
        extra["time"] = time_from_prose(hay)
    return extra


# Data model: kind, label, names, belt, icon, original announcement.
# Explicit non-title / qualifier stakes take precedence over champion names.
TITLES = [
    ["WOMEN'S WORLD", "WOMENS WORLD", "worldwhite"],
    ["WORLD HEAVYWEIGHT", "WORLD TITLE", "world"],
    ["WOMEN'S INTERCONTINENTAL", "WOMENS IC", "icwhite"],
    ["INTERCONTINENTAL", "IC TITLE", "ic"],
    ["WOMEN'S UNITED STATES", "WOMENS US", "uswhite"],
    ["UNITED STATES", "US TITLE", "us"],
    ["WOMEN'S TAG TEAM", "WOMENS TAG", "womentag"],
    ["WORLD TAG TEAM", "WORLD TAG", "worldtag"],
    ["WWE TAG TEAM", "WWE TAG", "wwetag"],
    ["NXT WOMEN'S NORTH AMERICAN", "NXT WOMENS NA", "nawhite"],
    ["NXT NORTH AMERICAN", "NXT NA TITLE", "na"],
    ["NXT WOMEN'S", "NXT WOMENS", "nxtwhite"],
    ["NXT TAG TEAM", "NXT TAG TITLE", "nxttag"],
    ["NXT", "NXT TITLE", "nxt"],
    ["WWE WOMEN'S", "WWE WOMENS", "women"],
    ["UNDISPUTED WWE", "WWE TITLE", "wwe"],
    ["WWE CHAMPIONSHIP", "WWE TITLE", "wwe"],
]

# 1v1s that the list writes as names-only, but the bout is the champion's title.
CHAMPIONS = [
    ["LYRA VALKYRIA", "WOMENS IC", "icwhite"],
]

def segment_text(raw):
    # Fonts have no apostrophe, so "WE'LL HEAR FROM X" draws as WELL HEAR.
    s = str(raw).upper().replace("'", "").replace("’", "")
    for prefix in ["WELL HEAR FROM ", "WE LL HEAR FROM ", "WE WILL HEAR FROM ", "FANS WILL HEAR FROM ", "HEAR FROM "]:
        if s.startswith(prefix):
            name = s[len(prefix):].strip(" .")
            for tail in [" ON RAW", " ON SMACKDOWN", " ON NXT", " TONIGHT", " THIS WEEK"]:
                if name.endswith(tail):
                    name = name[:len(name) - len(tail)].strip()
            if name != "" and " VS " not in name:
                return name + " TO SPEAK"
    return s

def normalize_item(raw):
    cleaned = raw.replace(" VS. ", " VS ").replace(" V. ", " VS ")
    label = "SINGLES MATCH"
    belt = ""
    icon = ""
    names = cleaned
    stakes = ""
    if ": " in cleaned:
        bits = cleaned.split(": ", 1)
        stakes = bits[0]
        names = bits[1]
        label = stakes
    # F4W writes title bouts as "X CHAMPION A DEFENDS AGAINST B".
    if " DEFENDS AGAINST " in names and " CHAMPION " in names.split(" DEFENDS AGAINST ", 1)[0]:
        left, right = names.split(" DEFENDS AGAINST ", 1)
        title, champ = left.split(" CHAMPION ", 1)
        stakes = (stakes + " " if stakes else "") + title + " CHAMPIONSHIP"
        label = stakes
        names = champ + " VS " + right
    if " VS " not in names:
        return {"kind": "segment", "label": "ANNOUNCED", "names": [], "text": segment_text(raw), "belt": "", "icon": "mic"}
    if " FOR THE " in names:
        names, stakes = names.split(" FOR THE ", 1)
        label = stakes
    # F4W writes stakes after the names: "X VS Y in a men's Money in the Bank qualifying match".
    if " IN A " in names:
        bits = names.split(" IN A ", 1)
        tail = bits[1]
        if "QUALIF" in tail or "TITLE" in tail or "CHAMPIONSHIP" in tail or "MITB" in tail or "MONEY IN THE BANK" in tail:
            names = bits[0]
            if stakes == "":
                stakes = tail
                label = stakes
    if "MONEY IN THE BANK" in stakes or "MITB" in stakes:
        label = "MITB QUALIFIER" if "QUALIF" in stakes else "MITB LADDER MATCH"
        icon = "mitb"
    elif "QUALIF" in stakes or "CONTENDER" in stakes or "NON-TITLE" in stakes or "NON TITLE" in stakes:
        label = "NON-TITLE MATCH" if "NON" in stakes else "CONTENDER MATCH" if "CONTENDER" in stakes else "QUALIFIER"
    else:
        # Only explicit title/championship stakes, not 'Champion X vs Y'.
        if "TITLE" in stakes or "CHAMPIONSHIP" in stakes:
            for meta in TITLES:
                if meta[0] in stakes:
                    label = meta[1]
                    belt = meta[2]
                    break
        for token, caption, art in [["STEEL CAGE", "STEEL CAGE", "cage"], ["LADDER", "LADDER MATCH", "ladder"], ["ROYAL RUMBLE", "ROYAL RUMBLE", "rumble"]]:
            if token in stakes:
                label = caption
                icon = art
    sides = [n.replace(" (C)", "").strip() for n in names.split(" VS ")]
    if len(sides) == 3 and label == "SINGLES MATCH":
        label = "TRIPLE THREAT"
        icon = "triple"
    if any([" & " in n or ", " in n for n in sides]) and label == "SINGLES MATCH":
        label = "TAG TEAM MATCH"
        icon = "tag"
    if belt == "" and len(sides) == 2 and label == "SINGLES MATCH":
        joined = " ".join(sides)
        for meta in CHAMPIONS:
            if meta[0] in joined:
                label = meta[1]
                belt = meta[2]
    return {"kind": "match", "label": label, "names": sides, "text": raw, "belt": belt, "icon": icon}

def select_show(shows, cfg):
    chosen = None
    for show in shows:
        if cfg["brand"] != "AUTO" and show["brand"] != cfg["brand"]:
            continue
        # Future adapters may supply kind='ple'; real dated PLEs compete with
        # weekly shows by start date. No fabricated PLE calendar is installed.
        if chosen == None or show["day"] < chosen["day"]:
            chosen = show
    return chosen

def visible_items(show):
    # Matches first so a title bout is never buried under "to speak" pages.
    items = show["items"]
    matches = [i for i in items if i["kind"] == "match"]
    other = [i for i in items if i["kind"] != "match"]
    if len(other) > 1:
        lines = [str(i.get("text", "")) for i in other]
        packed = {"kind": "segment", "label": "LIVE", "names": [], "text": lines[0], "texts": lines, "belt": "", "icon": "mic"}
        return matches + [packed]
    return matches + other


# Source adapter. Only explicit, dated WWE lineup headings followed by a list
# are accepted. Never infer a card from predictions, results, or article prose.
# Lineup uses two RSS URLs. WWE events fills a missing city and the next PLE.
FEED = "https://www.f4wonline.com/feed/"
FIGHTFUL_FEED = "https://www.fightful.com/feed/"
WWE_EVENTS = "https://www.wwe.com/events/results/all-events/all-dates/0/0/all/US"

def between(s, start, end):
    a = s.find(start)
    if a < 0:
        return ""
    b = s.find(end, a + len(start))
    return s[a + len(start):b] if b >= 0 else ""

def plain(s):
    # Bound work before walking the markup. Headings/list entries only.
    text = ""
    for fragment in s[:5000].split("<"):
        text = text + (fragment.split(">", 1)[1] if ">" in fragment else fragment)
    pairs = [["&amp;", "&"], ["&#038;", "&"], ["&#8217;", "'"], ["&#039;", "'"], ["&#39;", "'"], ["&apos;", "'"], ["&#8216;", "'"], ["’", "'"], ["‘", "'"], ["&#8211;", "-"], ["&#8212;", "-"], ["–", "-"], ["—", "-"], ["&#8220;", '"'], ["&#8221;", '"'], ["&quot;", '"'], ["&nbsp;", " "], ["\u00a0", " "], ["é", "e"], ["á", "a"], ["í", "i"], ["ó", "o"], ["ú", "u"], ["ñ", "n"]]
    for p in pairs:
        text = text.replace(p[0], p[1])
    return " ".join(text.upper().split())

def heading_brand(head):
    h = str(head)
    for b in BRANDS:
        if h.startswith("WWE " + b + " (") or h.startswith(b + " (") or h.startswith("WWE " + b + " LINEUP"):
            return b
    return ""

def keep_show(shows, show):
    # Same brand+day: keep the longer announced list so a later update
    # replaces an earlier incomplete card. Never mix two weeks together.
    for s in shows:
        if s["brand"] == show["brand"] and s["day"] == show["day"]:
            if len(show["items"]) > len(s["items"]):
                s["items"] = show["items"]
                s["source"] = show["source"]
            if s["city"] == "":
                s["city"] = show.get("city", "")
            if s["time"] == "":
                s["time"] = show.get("time", "")
            return
    shows.append(show)

def parse_feed(body, nowday, source = "F4W"):
    shows = []
    # A truncated feed is not evidence of a complete announced card.
    if type(body) != "string" or "</rss>" not in body or len(body) > 1500000:
        return shows
    for item in body.split("<item>")[1:51]:
        title = plain(between(item, "<title>", "</title>"))
        if any([bad in title for bad in ["RESULTS", "PREDICTION", "SPOILER", "ON THIS DAY"]]):
            continue
        published = between(item, "<pubDate>", "</pubDate>")
        content = between(item, "<content:encoded><![CDATA[", "]]></content:encoded>")
        if not content:
            continue
        # A lineup list must immediately follow a dated show heading or paragraph.
        # Fightful uses <p><strong>WWE SmackDown (9/25)</strong></p>, not <h2>.
        # F4W updates sometimes use "WWE Raw lineup for Monday, September 21, 2026".
        parts = content.split("<ul")
        for pi in range(1, min(len(parts), 16)):
            before = parts[pi - 1].rstrip()
            start = max(before.rfind("<h2"), before.rfind("<h3"), before.rfind("<p>"), before.rfind("<p "))
            if start < 0:
                continue
            head = plain(before[start:])
            part = parts[pi]
            brand = heading_brand(head)
            if not brand:
                continue
            date = date_from_heading(head, published)
            # Keep the show through its UTC calendar day. Weekly TV is 8PM ET,
            # and UTC midnight is 7PM CDT the evening before — dropping at
            # <= nowday made Monday Raw vanish before it even started.
            if date == None or date["day"] < nowday or date["day"] > nowday + 14:
                continue
            ul = part.split("</ul>", 1)[0] if "</ul>" in part else ""
            if not ul:
                continue
            rows = []
            for li in ul.split("<li")[1:25]:
                raw = plain(between(li, ">", "</li>"))
                if raw:
                    rows.append(normalize_item(raw))
            if rows:
                extra = extras_from_item(head, plain(title + " " + between(item, "<description>", "</description>") + " " + content[:2000]))
                keep_show(shows, {"brand": brand, "day": date["day"], "date": date["label"], "time": extra["time"], "city": extra["city"], "venue": extra["venue"], "items": rows, "source": source, "url": between(item, "<link>", "</link>"), "kind": "weekly"})
    return shows

def wwe_event_brand(window):
    wu = str(window).upper()
    best = -1
    brand = ""
    pairs = [["FRIDAY NIGHT SMACKDOWN", "SMACKDOWN"], ["MONDAY NIGHT RAW", "RAW"], ["NXT LIVE", "SKIP"], ["NXT", "NXT"]]
    for pair in pairs:
        i = wu.rfind(pair[0])
        if i > best:
            best = i
            brand = pair[1]
    if brand == "SKIP":
        return ""
    if best >= 0 and "RAW" in wu[best:best + 48] and "SMACKDOWN" in wu[best:best + 48]:
        return ""
    return brand

def parse_wwe_events(body):
    # Dated WWE.com event cards. City only when brand+calendar day match.
    found = []
    if type(body) != "string" or "venue-container" not in body or len(body) > 1500000:
        return found
    marker = 'class="venue-container">'
    pos = 0
    for _ in range(80):
        i = body.find(marker, pos)
        if i < 0:
            return found
        pos = i + len(marker)
        end = body.find("<", pos)
        if end < 0:
            continue
        city = plain(body[pos:end])
        if city.find(", ") < 2:
            continue
        window = body[max(0, i - 1800):i]
        brand = wwe_event_brand(window)
        di = window.rfind('datetime="')
        if brand == "" or di < 0:
            continue
        close = window.find('"', di + 10)
        dt = window[di + 10:close] if close > di + 10 else ""
        if len(dt) < 10:
            continue
        bits = dt[:10].split("-")
        if len(bits) != 3 or not bits[0].isdigit() or not bits[1].isdigit() or not bits[2].isdigit():
            continue
        y = int(bits[0])
        m = int(bits[1])
        d = int(bits[2])
        if m < 1 or m > 12 or d < 1:
            continue
        day = day_number(y, m, d)
        keep_show(found, {"brand": brand, "day": day, "date": "", "time": "", "city": city, "venue": "", "items": [], "source": "WWE", "kind": "place"})
    return found

def strip_day_suffix(w):
    for suf in ["TH", "ST", "ND", "RD"]:
        if len(w) > len(suf) and w.endswith(suf) and w[:len(w) - len(suf)].isdigit():
            return w[:len(w) - len(suf)]
    return w

def ple_label(title):
    t = str(title).upper()
    if "ROAD TO" in t:
        return ""
    for p in ["WWE/", "AAA/", "NXT ", "WWE "]:
        t = t.replace(p, "")
    t = t.strip(" -/")
    if "MONEY IN THE BANK" in t:
        return "MITB"
    if "WORLDS COLLIDE" in t:
        return "WORLDS COLLIDE"
    if "SURVIVOR" in t:
        return "SURVIVOR"
    if "WRESTLEMANIA" in t:
        return "WRESTLEMANIA"
    if "SUMMERSLAM" in t:
        return "SUMMERSLAM"
    if "ROYAL RUMBLE" in t:
        return "ROYAL RUMBLE"
    if "CROWN JEWEL" in t:
        return "CROWN JEWEL"
    if "WRESTLEPALOOZA" in t:
        return "WRESTLEPALOOZA"
    if "ELIMINATION CHAMBER" in t:
        return "CHAMBER"
    if "BACKLASH" in t:
        return "BACKLASH"
    if "BAD BLOOD" in t:
        return "BAD BLOOD"
    return t.split(":")[0].strip()

def parse_next_ple(body, nowday, year, month):
    # WWE trending cards only. One future PLE: earliest dated title.
    best = None
    if type(body) != "string" or "le-card-meta-title" not in body:
        return None
    parts = body.split("le-card-meta-title")
    for pi in range(1, min(len(parts), 12)):
        chunk = parts[pi][:800]
        name = ple_label(plain(between(chunk, ">", "</h3>")))
        if name == "":
            continue
        date_s = plain(between(chunk, 'le-card-meta-date">', "</p>"))
        words = date_s.replace(",", " ").split()
        m = 0
        d = 0
        for i in range(len(words)):
            token = strip_day_suffix(words[i].strip(".,"))
            for mi in range(12):
                if token in [MONTHS[mi], MONTHS[mi][:3], "SEPT" if mi == 8 else ""]:
                    m = mi + 1
            if m and token.isdigit() and d == 0:
                d = int(token)
        if m < 1 or d < 1:
            continue
        day = day_number(year, m, d)
        if day < nowday:
            if m < month:
                day = day_number(year + 1, m, d)
            else:
                continue
        if day < nowday:
            continue
        city = plain(between(chunk, 'le-card-meta-venue">', "</p>")).strip(" ,")
        event = {"name": name, "date": MONTHS[m - 1][:3] + " " + str(d), "city": city, "day": day}
        if best == None or event["day"] < best["day"]:
            best = event
    return best

def fill_wwe_meta(shows, ctx):
    if not shows:
        return
    response = http.get(WWE_EVENTS, ttl_seconds = 900)
    if response["status_code"] != 200:
        return
    body = response.get("body", "")
    places = parse_wwe_events(body)
    ple = parse_next_ple(body, ctx.now.unix // 86400, ctx.now.year, ctx.now.month)
    for s in shows:
        for p in places:
            if p["brand"] != s["brand"] or p["day"] != s["day"]:
                continue
            if s.get("city", "") == "" and p.get("city", "") != "":
                s["city"] = p["city"]
            break
        if ple != None:
            s["ple"] = ple

def apply_weekly_time(shows):
    # Lineup articles often omit start time. Weekly RAW/SD/NXT air at 8PM ET.
    for s in shows:
        if s.get("time", "") == "" and s["brand"] in BRANDS:
            s["time"] = "8PM ET"

def fetch_shows(cfg, ctx):
    query = "WWE" if cfg["brand"] == "AUTO" else "WWE " + cfg["brand"]
    providers = [[FIGHTFUL_FEED, "FTFL"], [FEED, "F4W"]] if cfg["brand"] == "SMACKDOWN" else [[FEED, "F4W"], [FIGHTFUL_FEED, "FTFL"]]
    shows = []
    for provider in providers:
        response = http.get(provider[0], params = {"s": query}, ttl_seconds = 900)
        if response["status_code"] == 200:
            found = parse_feed(response.get("body", ""), ctx.now.unix // 86400, provider[1])
            for show in found:
                keep_show(shows, show)
        chosen = select_show(shows, cfg)
        if cfg["brand"] != "AUTO" and chosen != None and chosen["city"] != "" and chosen["time"] != "":
            break
    fill_wwe_meta(shows, ctx)
    apply_weekly_time(shows)
    return shows


# Completed-show results. Fightful recap lines use "X def. Y to retain/win".
# Upcoming cards still ignore RESULTS titles. Winners are never inferred
# from "vs" lines, previews, or article prose.
def strip_managers(s):
    out = str(s)
    for _ in range(6):
        a = out.find(" (W/")
        if a < 0:
            break
        b = out.find(")", a)
        if b < 0:
            break
        out = out[:a] + out[b + 1:]
    return " ".join(out.split())

def clean_name(s):
    n = strip_managers(str(s).upper().replace("'", "").replace("’", ""))
    n = n.replace(" (C)", "").replace("(C)", "")
    return " ".join(n.split()).strip(" .")

def result_stakes(stakes):
    label = "MATCH"
    belt = ""
    s = str(stakes).replace("'", "").replace("’", "")
    if "TITLE" in s or "CHAMPIONSHIP" in s:
        for meta in TITLES:
            key = meta[0].replace("'", "").replace("’", "")
            if key in s:
                return [meta[1], meta[2]]
        label = "TITLE MATCH"
    elif "MONEY IN THE BANK" in s or "MITB" in s:
        label = "MITB QUALIFIER"
    return [label, belt]

def parse_result_line(raw):
    s = strip_managers(plain(raw) if "<" in str(raw) else str(raw).upper())
    s = s.replace("'", "").replace("’", "")
    s = " ".join(s.split())
    if s == "":
        return None
    outcome = ""
    if "NO CONTEST" in s:
        outcome = "nocontest"
    elif " DREW " in s or s.endswith(" DRAW") or " A DRAW" in s:
        outcome = "draw"
    elif " DEF. " in s:
        outcome = "win"
    else:
        return None
    stakes = ""
    body = s
    if ": " in s:
        bits = s.split(": ", 1)
        head = bits[0]
        if "TITLE" in head or "CHAMPIONSHIP" in head or "MITB" in head or "MONEY IN THE BANK" in head:
            stakes = head
            body = bits[1]
    meta = result_stakes(stakes)
    label = meta[0]
    belt = meta[1]
    winner = ""
    losers = []
    if outcome == "win":
        parts = body.split(" DEF. ", 1)
        winner = clean_name(parts[0])
        rest = parts[1] if len(parts) > 1 else ""
        for tail in [" TO RETAIN THE TITLES", " TO RETAIN THE TITLE", " TO RETAIN", " TO WIN THE TITLES", " TO WIN THE TITLE", " TO WIN", " TO BECOME THE NEW CHAMPION", " VIA DISQUALIFICATION", " VIA DQ"]:
            rest = rest.replace(tail, " ")
        rest = " ".join(rest.split()).strip(" .")
        if rest != "":
            losers = [clean_name(x) for x in rest.split(" & ")]
            losers = [n for n in losers if n != ""]
        if belt != "":
            if "TO RETAIN" in body or " (C)" in parts[0] or "(C)" in parts[0]:
                outcome = "retain"
            elif "TO WIN" in body or "NEW CHAMPION" in body or " TO BECOME" in body or " (C)" in parts[1] or "(C)" in parts[1]:
                outcome = "new"
        if "VIA DISQUALIFICATION" in body or " VIA DQ" in body:
            if outcome == "win":
                outcome = "dq"
        if winner == "":
            return None
    elif outcome == "draw":
        if " DREW " in body:
            bits = body.split(" DREW ", 1)
            losers = [clean_name(bits[0]), clean_name(bits[1].split(" TO ")[0])]
        elif " VS " in body:
            losers = [clean_name(n) for n in body.split(" VS ")]
            if losers:
                losers[len(losers) - 1] = clean_name(losers[len(losers) - 1].split(" END")[0].split(" GO")[0].split(" DRAW")[0])
    elif outcome == "nocontest":
        if " VS " in body:
            losers = [clean_name(n) for n in body.split(" VS ")]
            if losers:
                losers[len(losers) - 1] = clean_name(losers[len(losers) - 1].split(" END")[0].split(" GO")[0].split(" NO CONTEST")[0])
    return {"kind": "result", "label": label, "belt": belt, "winner": winner, "losers": losers, "outcome": outcome, "main": False, "text": s}

def result_lines(content):
    lines = []
    for li in str(content).split("<li")[1:40]:
        chunk = li.split("<ul")[0]
        if ">" not in chunk:
            continue
        raw = plain(chunk.split(">", 1)[1])
        parsed = parse_result_line(raw)
        if parsed != None:
            lines.append(parsed)
    return lines

def result_brand(title):
    t = str(title).upper()
    if "RESULTS" not in t:
        return ""
    if any([bad in t for bad in ["REVIEW", "PODCAST", "PREDICTION", "SPOILER", "ON THIS DAY"]]):
        return ""
    if "NXT" in t:
        return "NXT"
    if "SMACKDOWN" in t:
        return "SMACKDOWN"
    if "RAW" in t:
        return "RAW"
    return ""

def pick_result_items(matches):
    if not matches:
        return []
    last = len(matches) - 1
    main = matches[last]
    main["main"] = True
    if main["label"] == "MATCH" or main["label"] == "MITB QUALIFIER":
        main["label"] = "MAIN EVENT"
    picked = [main]
    for i in range(last):
        if matches[i]["belt"] != "":
            picked.append(matches[i])
    return picked

def parse_result_feed(body, nowday, brand):
    shows = []
    if type(body) != "string" or "</rss>" not in body or len(body) > 1500000:
        return shows
    for item in body.split("<item>")[1:51]:
        title = plain(between(item, "<title>", "</title>"))
        found = result_brand(title)
        if found != brand:
            continue
        published = between(item, "<pubDate>", "</pubDate>")
        content = between(item, "<content:encoded><![CDATA[", "]]></content:encoded>")
        if not content:
            continue
        date = date_from_heading(title + " " + plain(content[:400]), published)
        if date == None or date["day"] >= nowday or date["day"] < nowday - 21:
            continue
        matches = result_lines(content)
        if not matches:
            continue
        if not any([s["day"] == date["day"] for s in shows]):
            shows.append({"brand": brand, "day": date["day"], "date": date["label"], "items": matches})
    chosen = None
    for show in shows:
        if chosen == None or show["day"] > chosen["day"]:
            chosen = show
    if chosen == None:
        return []
    return pick_result_items(chosen["items"])

def fetch_results(cfg, ctx, brand):
    if not cfg["results"] or brand not in BRANDS:
        return []
    query = "WWE " + brand + " results"
    response = http.get(FIGHTFUL_FEED, params = {"s": query}, ttl_seconds = 900)
    if response["status_code"] != 200:
        return []
    return parse_result_feed(response.get("body", ""), ctx.now.unix // 86400, brand)


# Clean native pixel sprites; no animation or resampling.
def small_icon(c, kind, x, y, col):
    arts = {
        "mitb": ["....GGGG....", "....G..G....", ".GGGGGGGGGG.", ".GggggggggG.", ".GggGGggggG.", ".GGGGGGGGGG.", ".GggGGggggG.", ".GggggggggG.", ".GGGGGGGGGG."],
        "ladder": [
            "..WW....WW..",
            "..WW....WW..",
            "..WWWWWWWW..",
            "..WWWWWWWW..",
            "..WW....WW..",
            "..WW....WW..",
            "..WWWWWWWW..",
            "..WWWWWWWW..",
            "..WW....WW..",
            "..WW....WW..",
        ],
        "cage": ["WWWWWWWWWWWW", "W.W.W.W.W.WW", "WW.W.W.W.W.W", "W.W.W.W.W.WW", "WW.W.W.W.W.W", "W.W.W.W.W.WW", "WW.W.W.W.W.W", "W.W.W.W.W.WW", "WWWWWWWWWWWW"],
        "tag": [".WWW...WWW.", ".W.W...W.W.", ".WWW...WWW.", "...........", "WWWWW.WWWWW", "W...W.W...W", "W...W.W...W"],
        "triple": [".....W.....", "....WWW....", "...........", "..W.....W..", ".WWW...WWW."],
        "rumble": ["WWWWWWWWWWWW", "W..........W", "WWWWWWWWWWWW", "W..........W", "WWWWWWWWWWWW", "W..........W"],
        "mic": ["...WWW...", "..WWWWW..", "..WWWWW..", "...WWW...", "....W....", "....W....", "....W....", "...WWW..."],
    }
    if kind in arts:
        c.sprite(arts[kind], x, y, legend = {"W": col, "G": "#ECD36B", "g": "#167846"})



# Miniature match-card. Black field, 2px brand rail, names as the hero.
WHITE = "#F4F7FF"
MUTED = "#8B93A7"
GOLD = "#E7B43A"
BG = "#050506"
LEFT = 14
RIGHT = 180
FONT_HEIGHT = {"10x16": 16, "7x12": 12, "6x8": 8, "5x7": 7, "4x7": 7, "4x5": 5}
BELTS = {
    "worldwhite": "belts/worldwhite.png",
    "world": "belts/world.png",
    "icwhite": "belts/icwhite.png",
    "ic": "belts/ic.png",
    "uswhite": "belts/uswhite.png",
    "us": "belts/us.png",
    "womentag": "belts/womentag.png",
    "worldtag": "belts/worldtag.png",
    "wwetag": "belts/wwetag.png",
    "nawhite": "belts/nawhite.png",
    "na": "belts/na.png",
    "nxtwhite": "belts/nxtwhite.png",
    "nxttag": "belts/nxttag.png",
    "nxt": "belts/nxt.png",
    "women": "belts/women.png",
    "wwe": "belts/wwe.png",
}

def fit(c, text, width, fonts):
    s = str(text).upper()
    for f in fonts:
        if c.text_width(s, f) <= width:
            return [s, f]
    f = fonts[-1]
    for n in range(len(s), -1, -1):
        if c.text_width(s[:n] + "..", f) <= width:
            return [s[:n].rstrip() + "..", f]
    return ["", f]

def text(c, s, x, y, width, fonts = ["5x7", "4x5"], color = WHITE, align = "left"):
    result = fit(c, s, width, fonts)
    if result[0] == "":
        return
    c.text(result[0], x, y, font = result[1], color = color, align = align)

def last_name(s):
    parts = str(s).upper().replace(",", " ").split()
    if not parts:
        return ""
    return parts[len(parts) - 1]

def short_side(s):
    s = str(s).upper()
    if " & " in s:
        bits = []
        for n in s.split(" & "):
            bits.append(last_name(n))
        return " & ".join(bits)
    return s

def brand_col(show):
    return COLORS.get(show["brand"], WHITE)

def ground(c, col):
    c.fill(BG)
    # 3px brand rail at the safe-zone edge. Not a full-screen box.
    c.rect(10, 0, 12, 31, fill = col)

def slot_label(item, index):
    if item.get("belt"):
        return str(item["label"]).upper()
    icon = item.get("icon", "")
    if icon == "mitb":
        return str(item["label"]).upper()
    if icon == "cage":
        return "STEEL CAGE"
    if icon == "ladder":
        return str(item["label"]).upper()
    if item["kind"] == "segment":
        return "LIVE"
    if index == 0:
        return "MAIN EVENT"
    return str(item.get("label", "MATCH")).upper()

def eyebrow(c, show, item, index, total, x0 = LEFT, x1 = RIGHT):
    col = brand_col(show)
    brand = show["brand"]
    slot = slot_label(item, index)
    pos = str(index + 1) + "/" + str(total)
    posw = c.text_width(pos, "4x5")
    text(c, pos, x1, 2, 24, ["4x5"], MUTED, "right")
    # 'RAW MAIN EVENT' is 65px at 4x5. Brand in accent, slot in white.
    bw = c.text_width(brand, "4x5")
    text(c, brand, x0, 2, 70, ["4x5"], col)
    gap = x0 + bw + 4
    remain = x1 - posw - 4 - gap
    if remain > 12:
        text(c, slot, gap, 2, remain, ["4x5"], WHITE)

def vs_join(c, names, x0, x1, y, fonts, name_col, vs_col):
    # Draw NAME VS NAME [VS NAME] on one row. Largest font that fits.
    n = []
    for item in names:
        n.append(str(item).upper())
    for font in fonts:
        vs_w = c.text_width("VS", font)
        widths = []
        for item in n:
            widths.append(c.text_width(item, font))
        gap = 3
        total = 0
        for w in widths:
            total = total + w
        total = total + vs_w * (len(n) - 1) + gap * (2 * (len(n) - 1))
        if total <= x1 - x0:
            x = x0
            for i in range(len(n)):
                c.text(n[i], x, y, font = font, color = name_col)
                x = x + widths[i] + gap
                if i < len(n) - 1:
                    c.text("VS", x, y, font = font, color = vs_col)
                    x = x + vs_w + gap
            return True
    return False

def pair_block(c, left, right, x0, x1, y, col, vs_col):
    lefts = [str(left).upper(), short_side(left), last_name(left)]
    rights = [str(right).upper(), short_side(right), last_name(right)]
    # One hero line of full names first. Last-name clipping is a last resort.
    if vs_join(c, [lefts[0], rights[0]], x0, x1, y, ["6x8", "5x7", "4x7"], col, vs_col):
        return
    width = x1 - x0
    two_y = 10 if y + 17 > 26 else y
    for font in ["6x8", "5x7", "4x7", "4x5"]:
        if c.text_width(lefts[0], font) <= width and c.text_width(rights[0], font) <= width - c.text_width("VS ", font):
            c.text(lefts[0], x0, two_y, font = font, color = col)
            c.text("VS", x0, two_y + FONT_HEIGHT[font] + 1, font = font, color = vs_col)
            vw = c.text_width("VS", font) + 3
            c.text(rights[0], x0 + vw, two_y + FONT_HEIGHT[font] + 1, font = font, color = col)
            return
    for i in range(1, 3):
        if vs_join(c, [lefts[i], rights[i]], x0, x1, y, ["6x8", "5x7", "4x7"], col, vs_col):
            return
    mid = (x0 + x1) // 2
    text(c, lefts[2], x0, y, mid - x0 - 8, ["5x7", "4x5"], col)
    text(c, "VS", mid, y + 1, 14, ["4x5"], vs_col, "center")
    text(c, rights[2], mid + 10, y, x1 - (mid + 10), ["5x7", "4x5"], col)

def multi_block(c, names, x0, x1, y, col, vs_col):
    full = []
    short = []
    for n in names:
        full.append(str(n).upper())
        short.append(last_name(n))
    if vs_join(c, full, x0, x1, y, ["5x7", "4x7"], col, vs_col):
        return
    if vs_join(c, short, x0, x1, y, ["6x8", "5x7", "4x7"], col, vs_col):
        return
    # Two lines: first two on line 1, the rest on line 2.
    if vs_join(c, short[:2], x0, x1, y, ["5x7", "4x5"], col, vs_col):
        if len(short) > 2:
            vs_join(c, short[2:], x0, x1, y + 9, ["5x7", "4x5"], col, vs_col)
        return
    text(c, " VS ".join(short), x0, y, x1 - x0, ["4x5"], col)

def match_page(c, show, item, index, total, cfg):
    col = brand_col(show)
    names = item["names"]
    if item["belt"] and len(names) == 2:
        c.fill(BG)
        c.image(BELTS[item["belt"]], 10, 0)
        pos = str(index + 1) + "/" + str(total)
        text(c, pos, RIGHT, 2, 24, ["4x5"], MUTED, "right")
        text(c, slot_label(item, index), 91, 2, 70, ["4x5"], GOLD)
        pair_block(c, names[0], names[1], 91, RIGHT, 9, WHITE, col)
        return
    ground(c, col)
    eyebrow(c, show, item, index, total)
    if item["kind"] == "segment":
        lines = item.get("texts")
        if type(lines) != "list" or len(lines) == 0:
            lines = [item["text"]]
        if len(lines) == 1:
            text(c, lines[0], LEFT, 14, RIGHT - LEFT, ["6x8", "5x7", "4x5"], WHITE)
        else:
            text(c, lines[0], LEFT, 12, RIGHT - LEFT, ["5x7", "4x5"], WHITE)
            text(c, lines[1], LEFT, 22, RIGHT - LEFT, ["5x7", "4x5"], WHITE)
        return
    if len(names) >= 3:
        multi_block(c, names, LEFT, RIGHT, 14, WHITE, col)
        return
    if len(names) == 2:
        pair_block(c, names[0], names[1], LEFT, RIGHT, 14, WHITE, col)
        return
    text(c, item.get("text", item.get("label", "")), LEFT, 14, RIGHT - LEFT, ["6x8", "5x7", "4x5"], WHITE)

def overview_page(c, show, cfg):
    col = brand_col(show)
    ground(c, col)
    brand = show["brand"]
    text(c, brand, LEFT, 2, 110, ["6x8"], col)
    date = show.get("date", "")
    date_w = 0
    if date != "":
        text(c, date, RIGHT, 2, 70, ["6x8", "5x7", "4x5"], WHITE, "right")
        date_w = c.text_width(date, "6x8")
    bw = c.text_width(brand, "6x8")
    tag_x = LEFT + bw + 4
    tag_w = c.text_width("WHATS NEXT", "4x5")
    if tag_x + tag_w + 6 <= RIGHT - date_w:
        text(c, "WHATS NEXT", tag_x, 4, tag_w + 2, ["4x5"], MUTED)
    place = show.get("venue", "")
    if place == "":
        place = show.get("city", "")
    clock = show.get("time", "")
    if clock == "TIME TBA":
        clock = ""
    if place != "" and clock != "":
        text(c, place, LEFT, 12, 120, ["5x7", "4x5"], WHITE)
        text(c, clock, RIGHT, 12, 44, ["5x7", "4x5"], GOLD, "right")
    elif place != "":
        text(c, place, LEFT, 12, RIGHT - LEFT, ["5x7", "4x5"], WHITE)
    elif clock != "":
        text(c, clock, RIGHT, 12, 44, ["5x7", "4x5"], GOLD, "right")
    matches = len([i for i in show["items"] if i["kind"] == "match"])
    count = str(matches) + (" MATCH" if matches == 1 else " MATCHES")
    ple = show.get("ple")
    has_ple = type(ple) == "dict" and str(ple.get("name", "")) != ""
    if has_ple:
        # Gold plate, separate from the weekly card. Dark ink on #E7B43A.
        c.rect(13, 21, 191, 31, fill = GOLD)
        c.rect(13, 21, 191, 21, fill = "#101018")
        ink = "#101018"
        pdate = str(ple.get("date", "")).upper()
        pd_w = 0
        if pdate != "":
            text(c, pdate, RIGHT, 23, 50, ["6x8", "5x7", "4x5"], ink, "right")
            pd_w = c.text_width(pdate, "6x8")
        name = str(ple["name"]).upper()
        name_w = RIGHT - pd_w - 6 - LEFT
        if name_w > 12:
            text(c, name, LEFT, 23, name_w, ["6x8", "5x7", "4x5"], ink)
        if place == "":
            text(c, count, LEFT, 13, 70, ["4x5"], GOLD)
        return
    text(c, count, LEFT, 24, 70, ["4x5"], GOLD)
    extra = LEFT + c.text_width(count, "4x5") + 4
    if extra + c.text_width("ANNOUNCED", "4x5") <= 150:
        text(c, "ANNOUNCED", extra, 24, 70, ["4x5"], MUTED)

def message(c, cfg, headline, sub):
    brand = cfg["brand"] if cfg["brand"] in BRANDS else "WWE"
    col = COLORS[brand]
    ground(c, col)
    text(c, brand, LEFT, 2, 70, ["4x5"], col)
    text(c, "WHATS NEXT", RIGHT, 2, 90, ["4x5"], MUTED, "right")
    text(c, headline, LEFT, 12, RIGHT - LEFT, ["6x8", "5x7"], WHITE)
    text(c, sub, LEFT, 24, RIGHT - LEFT, ["4x5"], MUTED)

def draw(c, ctx, slot):
    cfg = settings(ctx)
    if not cfg["valid"]:
        message(c, cfg, "CHECK SETTINGS", "CHOOSE A WWE BRAND")
        return
    show = select_show(fetch_shows(cfg, ctx), cfg)
    if show == None:
        message(c, cfg, "CARD UNAVAILABLE", "CHECK BACK SOON")
        return
    if slot < 0:
        overview_page(c, show, cfg)
        return
    items = visible_items(show)
    if not items:
        message(c, cfg, "NO MATCHES ANNOUNCED", "CHECK BACK SOON")
        return
    # Four card pages, always the first four announced items. Minute-banking
    # hid title matches behind leftover TBA. Longer lists still do not wrap.
    index = slot
    if index >= len(items):
        leftover_page(c, show, cfg)
        return
    match_page(c, show, items[index], index, len(items), cfg)

def leftover_page(c, show, cfg):
    col = brand_col(show)
    ground(c, col)
    text(c, show["brand"], LEFT, 2, 70, ["4x5"], col)
    text(c, "WHATS NEXT", RIGHT, 2, 90, ["4x5"], MUTED, "right")
    text(c, "MORE MATCHES TBA", LEFT, 12, RIGHT - LEFT, ["6x8", "5x7"], WHITE)
    text(c, "CHECK BACK SOON", LEFT, 24, RIGHT - LEFT, ["4x5"], MUTED)

def result_star(c, x, y, col):
    c.sprite(["..Y..", "YYYYY", ".YYY.", "Y.Y.Y"], x, y, legend = {"Y": col})

def result_outcome(item):
    outcome = item.get("outcome", "")
    if outcome == "retain":
        return "RETAINS"
    if outcome == "new":
        return "NEW CHAMPION"
    if outcome == "draw":
        return "DRAW"
    if outcome == "nocontest":
        return "NO CONTEST"
    losers = item.get("losers", [])
    prefix = "DQ " if outcome == "dq" else "DEF. "
    if not losers:
        return prefix.strip() if outcome == "dq" else "FINAL"
    if len(losers) == 1:
        return prefix + losers[0]
    joined = prefix + " & ".join(losers)
    return joined

def result_page(c, show, item, cfg):
    col = brand_col(show)
    belt = item.get("belt", "")
    winner = str(item.get("winner", "")).upper()
    outcome = item.get("outcome", "")
    slot = "MAIN EVENT" if item.get("main") and belt == "" else str(item.get("label", "FINAL")).upper()
    brand = show["brand"]
    if slot.startswith(brand + " "):
        slot = slot[len(brand) + 1:]
    # Same 72x32 Champions belt as title-match cards. Winner sits in the
    # remaining 89px at x=91. 'STEPHANIE VAQUER' is 93px at 5x7, so the
    # ladder drops to 4x5 or the last name.
    if belt != "" and winner != "" and belt in BELTS:
        c.fill(BG)
        c.image(BELTS[belt], 10, 0)
        text(c, "FINAL", RIGHT, 2, 28, ["4x5"], GOLD, "right")
        final_w = c.text_width("FINAL", "4x5")
        label_w = RIGHT - final_w - 4 - 91
        if label_w > 12:
            text(c, slot, 91, 2, label_w, ["4x5"], GOLD)
        hero = winner
        if c.text_width(winner, "5x7") > RIGHT - 91:
            hero = last_name(winner)
        text(c, hero, 91, 10, RIGHT - 91, ["6x8", "5x7", "4x7", "4x5"], WHITE)
        line = result_outcome(item)
        if line != "":
            tone = GOLD if outcome in ["retain", "new"] else WHITE
            text(c, line, 91, 22, RIGHT - 91, ["5x7", "4x5"], tone)
        return
    ground(c, col)
    bw = c.text_width(brand, "4x5")
    text(c, brand, LEFT, 2, 50, ["4x5"], col)
    text(c, "FINAL", RIGHT, 2, 28, ["4x5"], GOLD, "right")
    final_w = c.text_width("FINAL", "4x5")
    label_x = LEFT + bw + 4
    label_w = RIGHT - final_w - 4 - label_x
    if label_w > 12:
        text(c, slot, label_x, 2, label_w, ["4x5"], WHITE)
    if outcome in ["draw", "nocontest"] or winner == "":
        hero = "NO CONTEST" if outcome == "nocontest" else "DRAW"
        text(c, hero, LEFT, 12, RIGHT - LEFT, ["6x8", "5x7"], WHITE)
        names = item.get("losers", [])
        if names:
            text(c, " VS ".join(names), LEFT, 23, RIGHT - LEFT, ["5x7", "4x5"], MUTED)
        return
    result_star(c, LEFT, 13, GOLD)
    text(c, winner, LEFT + 8, 12, RIGHT - LEFT - 8, ["6x8", "5x7", "4x7", "4x5"], WHITE)
    line = result_outcome(item)
    if line == "":
        return
    tone = GOLD if outcome in ["retain", "new"] else WHITE
    if outcome in ["win", "dq"] and c.text_width(line, "4x5") > RIGHT - LEFT:
        losers = item.get("losers", [])
        if len(losers) >= 2:
            line = ("DQ " if outcome == "dq" else "DEF. ") + str(len(losers)) + " OTHERS"
        elif losers:
            line = ("DQ " if outcome == "dq" else "DEF. ") + last_name(losers[0])
    text(c, line, LEFT, 23, RIGHT - LEFT, ["5x7", "4x5"], tone)

def load_results(cfg, ctx, show):
    if not cfg["results"] or show == None:
        return []
    return fetch_results(cfg, ctx, show["brand"])

def draw_result(c, ctx, index):
    cfg = settings(ctx)
    if not cfg["valid"]:
        message(c, cfg, "CHECK SETTINGS", "CHOOSE A WWE BRAND")
        return
    show = select_show(fetch_shows(cfg, ctx), cfg)
    if show == None:
        message(c, cfg, "CARD UNAVAILABLE", "CHECK BACK SOON")
        return
    found = load_results(cfg, ctx, show)
    if index >= len(found):
        if found:
            result_empty_page(c, show, cfg)
        else:
            leftover_page(c, show, cfg)
        return
    result_page(c, show, found[index], cfg)

def result_empty_page(c, show, cfg):
    col = brand_col(show)
    ground(c, col)
    text(c, show["brand"], LEFT, 2, 70, ["4x5"], col)
    text(c, "NO OTHER TITLES", LEFT, 12, RIGHT - LEFT, ["6x8", "5x7"], WHITE)
    text(c, "CHECK BACK SOON", LEFT, 24, RIGHT - LEFT, ["4x5"], MUTED)

def overview(c, ctx):
    draw(c, ctx, -1)

def card1(c, ctx):
    draw(c, ctx, 0)

def card2(c, ctx):
    draw(c, ctx, 1)

def card3(c, ctx):
    draw(c, ctx, 2)

def card4(c, ctx):
    draw(c, ctx, 3)

def result1(c, ctx):
    draw_result(c, ctx, 0)

def result2(c, ctx):
    draw_result(c, ctx, 1)

def result3(c, ctx):
    draw_result(c, ctx, 2)
