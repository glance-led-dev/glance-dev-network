# Wildcat Bar: custom messages, football and men's basketball.
BLUE = "#2788FF"
WHITE = "#FFFFFF"
NAVY = "#00143A"


def fit(c, text, x, y, width, fonts, ink=WHITE):
    text = str(text).upper()
    chosen = fonts[-1]
    for f in fonts:
        if c.text_width(text, font=f) <= width:
            chosen = f
            break
    if c.text_width(text, font=chosen) > width:
        for n in range(len(text), -1, -1):
            short = text[:n] + "..."
            if c.text_width(short, font=chosen) <= width:
                text = short
                break
    c.text_stroke(text, x, y, font=chosen, color=ink,
                  stroke="black", thickness=1, align="center")


def ball(c, sport, x, y):
    if sport == "Kentucky basketball":
        c.fill_circle(x, y, 6, color="#ED8A22")
        c.circle(x, y, 6, color="#FFC16B")
        c.line(x - 5, y, x + 5, y, color="#693008")
        c.line(x, y - 5, x, y + 5, color="#693008")
        c.line(x - 4, y - 4, x + 4, y + 4, color="#693008")
    else:
        c.round_rect(x - 8, y - 5, x + 8, y + 5, 5, fill="#9F542A")
        c.line(x - 4, y, x + 4, y, color=WHITE)
        for dx in [-2, 0, 2]:
            c.line(x + dx, y - 2, x + dx, y + 2, color=WHITE)


def base(c):
    c.fill(NAVY)
    c.hline(3, 0, c.width - 6, BLUE)
    c.hline(3, 31, c.width - 6, BLUE)


def main(c, ctx):
    sport = ctx.inputs.get("sport", "Kentucky football")
    msg = ctx.inputs.get("setting1", "").strip().upper()
    if not msg:
        msg = "WELCOME TO THE WILDCAT BAR"
    base(c)
    ball(c, sport, 13, 16)
    ball(c, sport, c.width - 14, 16)
    width = c.width - 52
    center = c.width // 2
    if msg == "WELCOME TO THE WILDCAT BAR":
        first = "WELCOME TO THE"
        second = "WILDCAT BAR"
    elif "|" in msg:
        parts = msg.split("|", 1)
        first = parts[0].strip()
        second = parts[1].strip()
    elif c.text_width(msg, font="8x12") <= width:
        fit(c, msg, center, 8, width, ["10x15", "8x12", "7x12", "5x7"], WHITE)
        return
    else:
        words = msg.split()
        first = ""
        second = ""
        overflow = False
        for word in words:
            candidate = (first + " " + word).strip()
            if not overflow and c.text_width(candidate, font="7x12") <= width:
                first = candidate
            else:
                overflow = True
                second = (second + " " + word).strip()
        if not first:
            first = second
            second = ""
    fit(c, first, center, 2, width, ["7x12", "5x7"], BLUE)
    fit(c, second, center, 16, width, ["10x15", "8x12", "7x12", "5x7"], WHITE)


def leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)


def mdays(y, m):
    return [31, 29 if leap(y) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1]


def weekday(y, m, d):
    t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
    yy = y - 1 if m < 3 else y
    return (yy + yy // 4 - yy // 100 + yy // 400 + t[m - 1] + d) % 7


def eastern(date, valid):
    if len(date) < 16:
        return "DATE TBD", "TIME TBD"
    y = int(date[:4])
    m = int(date[5:7])
    d = int(date[8:10])
    h = int(date[11:13])
    minute = int(date[14:16])
    # US Eastern daylight saving: second Sunday in March to first in November.
    march = 8 + (7 - weekday(y, 3, 8)) % 7
    nov = 1 + (7 - weekday(y, 11, 1)) % 7
    dst = m > 3 and m < 11
    if m == 3:
        dst = d > march or (d == march and h >= 7)
    if m == 11:
        dst = d < nov or (d == nov and h < 6)
    if not valid:
        return str(m) + "/" + str(d), "TIME TBD"
    h = h - (4 if dst else 5)
    if h < 0:
        h += 24
        d -= 1
        if d == 0:
            m -= 1
            if m == 0:
                m = 12
                y -= 1
            d = mdays(y, m)
    hour = h % 12
    if hour == 0:
        hour = 12
    clock = str(hour) + ":" + ("0" if minute < 10 else "") + str(minute)
    clock += "PM ET" if h >= 12 else "AM ET"
    return str(m) + "/" + str(d), clock


def games(ctx):
    sport = ctx.inputs.get("sport", "Kentucky football")
    year = ctx.now.year
    path = "football/college-football"
    if sport == "Kentucky basketball":
        path = "basketball/mens-college-basketball"
        if ctx.now.month >= 7:
            year += 1
    elif ctx.now.month <= 2:
        year -= 1
    url = "https://site.api.espn.com/apis/site/v2/sports/" + path + "/teams/96/schedule"
    found = {}
    partial = False
    for phase in [1, 2, 3]:
        r = http.get(url, params={"season": str(year), "seasontype": str(phase)}, ttl_seconds=300)
        data = r.get("json")
        if r.get("status_code") != 200 or type(data) != "dict":
            partial = True
            continue
        for e in data.get("events", []):
            if e.get("season", {}).get("year", year) != year:
                continue
            key = e.get("id", "")
            if key:
                found[key] = e
    pairs = []
    for key in found:
        pairs.append((found[key].get("date", ""), key))
    result = []
    for pair in sorted(pairs):
        result.append(found[pair[1]])
    return result, partial


def score(team):
    value = team.get("score")
    if type(value) == "dict":
        return str(value.get("displayValue", "?"))
    return str(value) if value != None else "?"



def schedulepage(c, ctx, index):
    if ctx.inputs.get("displaymode", "Messages only") != "Messages and schedule":
        main(c, ctx)
        return
    sport = ctx.inputs.get("sport", "Kentucky football")
    label = "UK BASKETBALL" if sport == "Kentucky basketball" else "UK FOOTBALL"
    entries, partial = games(ctx)
    c.fill(NAVY)
    if not entries:
        fit(c, label, c.width // 2, 3, c.width - 12, ["7x12", "5x7"], BLUE)
        fit(c, "FEED UNAVAILABLE" if partial else "NO GAMES LISTED", c.width // 2, 18, c.width - 12, ["5x7"], WHITE)
        return
    groups = (len(entries) + 5) // 6
    # Seven schedule pages, six games each. Longer seasons use successive batches.
    batch = (ctx.now.unix // 300) % ((groups + 6) // 7)
    group = (batch * 7 + index) % groups
    title = label + "  " + str(group + 1) + "/" + str(groups)
    if partial:
        title += "  PARTIAL FEED"
    else:
        title += "  TIMES ET"
    c.text(title, 4, 0, font="5x7", color=BLUE)
    c.hline(3, 7, c.width - 6, "#164175")
    half = c.width // 2
    c.vline(half, 9, 22, "#164175")
    for row in range(6):
        pos = group * 6 + row
        if pos >= len(entries):
            continue
        event = entries[pos]
        comps = event.get("competitions", [])
        if not comps:
            continue
        comp = comps[0]
        uk = {}
        other = {}
        for side in comp.get("competitors", []):
            if str(side.get("team", {}).get("id", side.get("id", ""))) == "96":
                uk = side
            else:
                other = side
        team = other.get("team", {})
        opponent = team.get("abbreviation", "TBD").upper()
        st = comp.get("status", {}).get("type", {})
        state = st.get("state", "pre")
        date, clock = eastern(comp.get("date", event.get("date", "")), comp.get("timeValid", event.get("timeValid", False)))
        mark = "VS" if comp.get("neutralSite") or uk.get("homeAway") == "home" else "@"
        left = date + " " + mark + " " + opponent
        ink = WHITE
        if state == "post" or state == "in":
            result = "LIVE" if state == "in" else ("W" if uk.get("winner") else "L")
            if state == "post" and score(uk) == score(other):
                result = "T"
            right = result + " " + score(uk) + "-" + score(other)
            ink = "#FFDC50" if state == "in" else WHITE
        else:
            right = clock.replace(" ET", "").replace("TIME ", "")
            if st.get("name", "") != "STATUS_SCHEDULED":
                right = st.get("description", right).upper()
        x = 4 if row < 3 else half + 4
        y = 9 + (row % 3) * 8
        full = left + "  " + right
        fit(c, full, x + (half - 8) // 2, y, half - 10, ["5x7"], ink)


def schedule1(c, ctx):
    schedulepage(c, ctx, 0)


def schedule2(c, ctx):
    schedulepage(c, ctx, 1)


def schedule3(c, ctx):
    schedulepage(c, ctx, 2)


def schedule4(c, ctx):
    schedulepage(c, ctx, 3)


def schedule5(c, ctx):
    schedulepage(c, ctx, 4)


def schedule6(c, ctx):
    schedulepage(c, ctx, 5)


def schedule7(c, ctx):
    schedulepage(c, ctx, 6)