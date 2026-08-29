# Capitol Vote — latest U.S. House / Senate roll calls on a 192x32 panel.
#
# Official sources (no API key):
#   House  clerk.house.gov/evs/{year}/index.asp  -> roll{NNN}.xml
#   Senate senate.gov LIS vote_menu_{congress}_{session} -> vote XML/HTML
#
# Starlark has no XML/XPath module. Tags are pulled with string finds.
# Frames are still images; the panel advances on the manifest refresh timer.

HEADERS = {
    "User-Agent": "GlanceCapitolVote/1.0 (GDN; official roll-call display)",
    "Accept": "application/xml, text/xml, text/html;q=0.9, */*;q=0.8",
}

INDEX_TTL = 300
VOTE_TTL = 900
CLOSE_MARGIN = 5

# 7x7 capitol marks. Senate has an extra column so the chambers differ
# without changing the rest of the scoreboard.
DOME_HOUSE = """
...#...
..###..
.#####.
##.#.##
#######
#.###.#
#######
"""

DOME_SENATE = """
...#...
..###..
.#####.
#.#.#.#
#######
#.#.#.#
#######
"""

# Left-rail width. Same color on every frame so the rotation reads as one show.
RAIL = 3

# ---------- small helpers ----------

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def chamber_choice(ctx):
    v = _s(ctx, "chamber", "Both").upper()
    if v == "HOUSE":
        return "HOUSE"
    if v == "SENATE":
        return "SENATE"
    return "BOTH"

def collapse_ws(s):
    s = s.replace("\n", " ").replace("\r", " ").replace("\t", " ")
    s = s.replace("&nbsp;", " ").replace("&#160;", " ")
    s = s.replace("&amp;", "&").replace("&quot;", "\"")
    s = s.replace("&lt;", "<").replace("&gt;", ">")
    for _ in range(40):
        if s.find("  ") < 0:
            break
        s = s.replace("  ", " ")
    return s.strip()

def strip_tags(s):
    out = ""
    i = 0
    n = len(s)
    for _ in range(n + 1):
        if i >= n:
            break
        lt = s.find("<", i)
        if lt < 0:
            out = out + s[i:]
            break
        out = out + s[i:lt]
        gt = s.find(">", lt)
        if gt < 0:
            break
        i = gt + 1
    return collapse_ws(out)

def xml_text(body, tag):
    close = "</" + tag + ">"
    open1 = "<" + tag + ">"
    start = body.find(open1)
    if start >= 0:
        start = start + len(open1)
    else:
        open2 = "<" + tag + " "
        p = body.find(open2)
        if p < 0:
            return ""
        gt = body.find(">", p)
        if gt < 0:
            return ""
        start = gt + 1
    end = body.find(close, start)
    if end < 0:
        return ""
    return strip_tags(body[start:end])

def to_int(s):
    t = str(s).strip()
    out = ""
    for i in range(len(t)):
        if t[i].isdigit():
            out = out + t[i]
        else:
            break
    if out == "":
        return 0
    return int(out)

def get_ok(url, ttl):
    r = http.get(url, headers = HEADERS, ttl_seconds = ttl)
    code = r["status_code"]
    body = r["body"]
    if body == None:
        body = ""
    return code, body

def get_body(url, ttl):
    code, body = get_ok(url, ttl)
    if code != 200:
        return ""
    return body

# Congress 1 began in 1789. A new Congress convenes Jan 3 of odd years.
def congress_session(ctx):
    y = ctx.now.year
    m = ctx.now.month
    d = ctx.now.day
    if m == 1 and d < 3:
        y = y - 1
    congress = (y - 1789) // 2 + 1
    session = 1
    if y % 2 == 0:
        session = 2
    return congress, session, y

def prev_session(congress, session):
    if session == 2:
        return congress, 1
    return congress - 1, 2

# ---------- result / bill display ----------

def result_short(raw):
    u = collapse_ws(raw).upper()
    if u == "":
        return "VOTED"
    if u == "P":
        return "PASSED"
    if u == "F":
        return "FAILED"
    if u == "A":
        return "AGREED"
    if u.find("CONFIRMED") >= 0:
        return "CONFIRMED"
    if u.find("AGREED") >= 0:
        return "AGREED"
    if u.find("REJECTED") >= 0:
        return "REJECTED"
    if u.find("FAILED") >= 0:
        return "FAILED"
    if u.find("PASSED") >= 0:
        return "PASSED"
    # Keep a short official token rather than inventing a outcome.
    cut = u.find(" ")
    if cut > 0 and cut <= 10:
        return u[:cut]
    if len(u) > 12:
        return u[:12]
    return u

def result_color(short):
    if short == "PASSED" or short == "AGREED" or short == "CONFIRMED":
        return "green"
    if short == "FAILED" or short == "REJECTED":
        return "red"
    return "yellow"

def fmt_house_bill(raw):
    t = collapse_ws(raw).upper()
    if t == "":
        return ""
    t = t.replace("H CON RES", "H.CON.RES.")
    t = t.replace("H J RES", "H.J.RES.")
    t = t.replace("H RES", "H.RES.")
    t = t.replace("H R ", "H.R. ")
    t = t.replace("S CON RES", "S.CON.RES.")
    t = t.replace("S J RES", "S.J.RES.")
    t = t.replace("S RES", "S.RES.")
    if t.startswith("S ") and t.find(".") < 0:
        t = "S. " + t[2:]
    return t

def fmt_senate_bill(raw):
    t = collapse_ws(raw)
    if t == "":
        return ""
    return t.upper()

def clean_title(raw):
    t = collapse_ws(raw)
    low = t.lower()
    prefixes = [
        "an original bill to ",
        "a bill to ",
        "an act to ",
        "a joint resolution ",
        "a concurrent resolution ",
        "a resolution ",
    ]
    for p in prefixes:
        if low.startswith(p):
            t = t[len(p):]
            break
    return collapse_ws(t)

def shorten_procedural(text):
    # Only used when the full title cannot wrap. Meaning stays the same.
    u = text.upper()
    pairs = [
        ["MOTION TO INVOKE CLOTURE:", "CLOTURE:"],
        ["ON CLOTURE ON THE MOTION TO PROCEED", "CLOTURE TO PROCEED"],
        ["MOTION TO INVOKE CLOTURE ON THE MOTION TO PROCEED", "CLOTURE TO PROCEED"],
        ["ON THE MOTION TO TABLE", "TABLE"],
        ["ON THE NOMINATION OF", "NOMINATION:"],
        ["ON THE NOMINATION:", "NOMINATION:"],
        ["ON AGREEING TO THE AMENDMENT", "AMENDMENT"],
        ["ON MOTION TO SUSPEND THE RULES AND PASS", "SUSPEND RULES AND PASS"],
        ["ON MOTION TO RECOMMIT", "RECOMMIT"],
        ["ON THE MOTION TO PROCEED", "PROCEED"],
        ["MOTION TO PROCEED TO", "PROCEED TO"],
    ]
    for p in pairs:
        u = u.replace(p[0], p[1])
    return collapse_ws(u)

def split_when(vote):
    d = short_date(vote["date"]).replace("-", " ")
    t = vote["time"].upper()
    if t != "":
        return d, t
    colon = d.find(":")
    if colon <= 0:
        return d, ""
    chunk = d[:colon]
    sp = chunk.rfind(" ")
    if sp < 0:
        return d, ""
    return chunk[:sp].strip(), d[sp + 1:].strip()

def short_date(s):
    u = s.upper()
    pairs = [
        ["JANUARY", "JAN"], ["FEBRUARY", "FEB"], ["MARCH", "MAR"],
        ["APRIL", "APR"], ["JUNE", "JUN"], ["JULY", "JUL"],
        ["AUGUST", "AUG"], ["SEPTEMBER", "SEP"], ["OCTOBER", "OCT"],
        ["NOVEMBER", "NOV"], ["DECEMBER", "DEC"],
    ]
    for pair in pairs:
        u = u.replace(pair[0], pair[1])
    u = u.replace(", ", " ")
    return collapse_ws(u)

def is_close(vote):
    if not vote["ok"]:
        return False
    yea = vote["yea"]
    nay = vote["nay"]
    if yea + nay <= 0:
        return False
    d = yea - nay
    if d < 0:
        d = -d
    return d <= CLOSE_MARGIN

def empty_vote(chamber, reason):
    return {
        "ok": False,
        "chamber": chamber,
        "reason": reason,
        "roll": 0,
        "bill": "",
        "question": "",
        "title": "",
        "result": "",
        "result_short": "",
        "yea": 0,
        "nay": 0,
        "present": 0,
        "nv": 0,
        "required": "",
        "date": "",
        "time": "",
    }

def ok_vote(chamber, roll, bill, question, title, result, yea, nay, present, nv, required, date, time):
    short = result_short(result)
    return {
        "ok": True,
        "chamber": chamber,
        "reason": "",
        "roll": roll,
        "bill": bill,
        "question": collapse_ws(question),
        "title": clean_title(title),
        "result": collapse_ws(result),
        "result_short": short,
        "yea": yea,
        "nay": nay,
        "present": present,
        "nv": nv,
        "required": collapse_ws(required),
        "date": collapse_ws(date),
        "time": collapse_ws(time),
    }

# ---------- House ----------

def find_latest_house_roll(html):
    latest = 0
    low = html.lower()
    pos = 0
    needle = "rollnumber="
    for _ in range(500):
        p = low.find(needle, pos)
        if p < 0:
            break
        n = to_int(low[p + len(needle):p + len(needle) + 4])
        if n > latest:
            latest = n
        pos = p + len(needle)
    if latest > 0:
        return latest
    pos = 0
    for _ in range(500):
        p = low.find("roll", pos)
        if p < 0:
            break
        if p + 11 <= len(low) and low[p + 7:p + 11] == ".xml":
            nstr = low[p + 4:p + 7]
            if nstr.isdigit():
                n = int(nstr)
                if n > latest:
                    latest = n
        pos = p + 4
    return latest

def parse_house_xml(body, roll):
    meta_end = body.find("<vote-data")
    meta = body
    if meta_end > 0:
        meta = body[:meta_end]
    totals_at = meta.find("<totals-by-vote")
    totals = meta
    if totals_at >= 0:
        totals = meta[totals_at:totals_at + 1200]
    yea_s = xml_text(totals, "yea-total")
    if yea_s == "":
        yea_s = xml_text(totals, "aye-total")
    nay_s = xml_text(totals, "nay-total")
    if nay_s == "":
        nay_s = xml_text(totals, "no-total")
    bill = fmt_house_bill(xml_text(meta, "legis-num"))
    question = xml_text(meta, "vote-question")
    title = xml_text(meta, "vote-desc")
    result = xml_text(meta, "vote-result")
    date = xml_text(meta, "action-date")
    time = xml_text(meta, "action-time")
    n = to_int(xml_text(meta, "rollcall-num"))
    if n == 0:
        n = roll
    if result == "" and n == 0:
        return empty_vote("HOUSE", "MALFORMED HOUSE VOTE")
    if bill == "":
        bill = "ROLL #" + str(n)
    return ok_vote(
        "HOUSE", n, bill, question, title, result,
        to_int(yea_s), to_int(nay_s),
        to_int(xml_text(totals, "present-total")),
        to_int(xml_text(totals, "not-voting-total")),
        "", date, time,
    )

def find_latest_house_roll_loose(html):
    # index.asp sometimes lists the roll as link text without a .xml href.
    latest = 0
    low = html.lower()
    pos = 0
    for _ in range(500):
        p = low.find("roll", pos)
        if p < 0:
            break
        nstr = low[p + 4:p + 7]
        if nstr.isdigit():
            n = int(nstr)
            if n > latest:
                latest = n
        pos = p + 4
    return latest

def house_roll_from_list(body):
    roll = find_latest_house_roll(body)
    if roll <= 0:
        roll = find_latest_house_roll_loose(body)
    return roll

def discover_house_roll(year):
    for base in [200, 100, 0]:
        code, body = get_ok("https://clerk.house.gov/evs/" + str(year) + "/ROLL_" + fmt.pad(base, 3) + ".asp", INDEX_TTL)
        if code == 0:
            return -1
        n = house_roll_from_list(body)
        if n > 0:
            return n
    return 0

def fetch_house_for_year(year):
    roll = discover_house_roll(year)
    if roll < 0:
        return 0, empty_vote("HOUSE", "HOUSE FEED DOWN")
    if roll <= 0:
        return 0, empty_vote("HOUSE", "NO HOUSE VOTES YET")
    pad = fmt.pad(roll, 3)
    xml = get_body("https://clerk.house.gov/evs/" + str(year) + "/roll" + pad + ".xml", VOTE_TTL)
    if xml == "":
        return roll, empty_vote("HOUSE", "HOUSE VOTE UNAVAILABLE")
    vote = parse_house_xml(xml, roll)
    return roll, vote

def fetch_house(ctx):
    congress, session, year = congress_session(ctx)
    roll, vote = fetch_house_for_year(year)
    if vote["ok"]:
        print("HOUSE", year, "roll", vote["roll"], vote["bill"], vote["result_short"], vote["yea"], "-", vote["nay"])
        return vote
    if vote["reason"] != "NO HOUSE VOTES YET":
        return vote
    roll2, vote2 = fetch_house_for_year(year - 1)
    if vote2["ok"]:
        print("HOUSE fallback", year - 1, "roll", vote2["roll"], vote2["bill"], vote2["result_short"])
        return vote2
    return vote

# ---------- Senate ----------

def find_latest_senate_vote(body, congress, session):
    latest = 0
    prefix = "vote_" + str(congress) + "_" + str(session) + "_"
    pos = 0
    for _ in range(800):
        p = body.find(prefix, pos)
        if p < 0:
            break
        nstr = body[p + len(prefix):p + len(prefix) + 5]
        if nstr.isdigit():
            n = int(nstr)
            if n > latest:
                latest = n
        pos = p + len(prefix)
    if latest > 0:
        return latest
    pos = 0
    for _ in range(800):
        p = body.find("<vote_number>", pos)
        if p < 0:
            break
        n = to_int(body[p + 13:p + 18])
        if n > latest:
            latest = n
        pos = p + 13
    if latest > 0:
        return latest
    pos = 0
    for _ in range(800):
        p = body.find("vote=", pos)
        if p < 0:
            break
        n = to_int(body[p + 5:p + 10])
        if n > latest:
            latest = n
        pos = p + 5
    return latest

def senate_menu_body(congress, session):
    base = "https://www.senate.gov/legislative/LIS/roll_call_lists/vote_menu_"
    suffix = str(congress) + "_" + str(session)
    xml = get_body(base + suffix + ".xml", INDEX_TTL)
    if xml != "" and (xml.find("vote_number") >= 0 or xml.find("vote_") >= 0):
        return xml
    return get_body(base + suffix + ".htm", INDEX_TTL)

def senate_vote_body(congress, session, roll):
    pad = fmt.pad(roll, 5)
    folder = "vote" + str(congress) + str(session)
    name = "vote_" + str(congress) + "_" + str(session) + "_" + pad
    base = "https://www.senate.gov/legislative/LIS/roll_call_votes/" + folder + "/" + name
    xml = get_body(base + ".xml", VOTE_TTL)
    if xml != "" and xml.find("<vote_number") >= 0:
        return xml
    if xml != "" and xml.find("Vote Number") >= 0:
        return xml
    return get_body(base + ".htm", VOTE_TTL)

def label_value(body, label):
    p = body.find(label)
    if p < 0:
        p = body.find(label.lower())
    if p < 0:
        return ""
    rest = body[p + len(label):p + len(label) + 240]
    rest = strip_tags(rest)
    # cut at a following ALL-CAPS field label when present
    for stop in ["Vote Number:", "Vote Date:", "Required For Majority:", "Vote Result:", "Measure Number:", "Measure Title:", "Vote Counts:"]:
        sp = rest.find(stop)
        if sp > 0:
            rest = rest[:sp]
    return collapse_ws(rest)

def digits_after(body, needle):
    p = body.find(needle)
    if p < 0:
        return 0
    i = p + len(needle)
    n = len(body)
    for _ in range(80):
        if i >= n:
            return 0
        ch = body[i]
        if ch.isdigit():
            out = ""
            last = i + 8
            if last > n:
                last = n
            for j in range(i, last):
                if body[j].isdigit():
                    out = out + body[j]
                else:
                    break
            if out == "":
                return 0
            return int(out)
        if ch == "<":
            gt = body.find(">", i)
            if gt < 0 or gt - i > 80:
                return 0
            i = gt + 1
        else:
            i = i + 1
    return 0

def parse_senate_xml(body, roll):
    # Prefer metadata before the member list (v2 can parse members later).
    meta_end = body.find("<members")
    meta = body
    if meta_end > 0:
        meta = body[:meta_end]
    n = to_int(xml_text(meta, "vote_number"))
    if n == 0:
        n = roll
    result = xml_text(meta, "vote_result")
    if result == "":
        result = xml_text(meta, "vote_result_text")
    question = xml_text(meta, "question")
    if question == "":
        question = xml_text(meta, "vote_question_text")
    title = xml_text(meta, "vote_title")
    if title == "":
        title = xml_text(meta, "document_title")
    if title == "":
        title = xml_text(meta, "vote_document_text")
    bill = xml_text(meta, "document_type")
    num = xml_text(meta, "document_number")
    if bill != "" and num != "":
        bill = collapse_ws(bill + " " + num)
    if bill == "":
        bill = xml_text(meta, "document_name")
    if bill == "":
        # nominations often live in the title / PN number in the question
        bill = fmt_senate_bill(label_value(meta, "Measure Number:"))
    bill = fmt_senate_bill(bill)
    date = xml_text(meta, "vote_date")
    required = xml_text(meta, "majority_requirement")
    count_at = meta.find("<count")
    count = meta
    if count_at >= 0:
        count = meta[count_at:count_at + 800]
    yea = to_int(xml_text(count, "yeas"))
    nay = to_int(xml_text(count, "nays"))
    present = to_int(xml_text(count, "present"))
    nv = to_int(xml_text(count, "absent"))
    if nv == 0:
        nv = to_int(xml_text(count, "not_voting"))
    if result == "" and n == 0:
        return empty_vote("SENATE", "MALFORMED SENATE VOTE")
    if bill == "":
        bill = "ROLL #" + str(n)
    return ok_vote(
        "SENATE", n, bill, question, title, result,
        yea, nay, present, nv, required, date, "",
    )

def parse_senate_html(body, roll):
    n = to_int(label_value(body, "Vote Number:"))
    if n == 0:
        n = roll
    result = label_value(body, "Vote Result:")
    question = label_value(body, "Question:")
    title = label_value(body, "Measure Title:")
    bill = fmt_senate_bill(label_value(body, "Measure Number:"))
    date = label_value(body, "Vote Date:")
    required = label_value(body, "Required For Majority:")
    yea = digits_after(body, "YEAs")
    nay = digits_after(body, "NAYs")
    nv = digits_after(body, "Not Voting")
    present = digits_after(body, "Present")
    if result == "" and question == "" and n == 0:
        return empty_vote("SENATE", "MALFORMED SENATE VOTE")
    if bill == "":
        bill = "ROLL #" + str(n)
    return ok_vote(
        "SENATE", n, bill, question, title, result,
        yea, nay, present, nv, required, date, "",
    )

def parse_senate_vote(body, roll):
    if body.find("<vote_number") >= 0 or body.find("<roll_call_vote") >= 0:
        v = parse_senate_xml(body, roll)
        if v["ok"]:
            return v
    return parse_senate_html(body, roll)

def fetch_senate_for(congress, session):
    if congress < 101 or session < 1 or session > 2:
        return empty_vote("SENATE", "BAD SESSION")
    menu = senate_menu_body(congress, session)
    if menu == "":
        return empty_vote("SENATE", "SENATE MENU UNAVAILABLE")
    roll = find_latest_senate_vote(menu, congress, session)
    if roll <= 0:
        return empty_vote("SENATE", "NO SENATE VOTES YET")
    detail = senate_vote_body(congress, session, roll)
    if detail == "":
        return empty_vote("SENATE", "SENATE VOTE UNAVAILABLE")
    return parse_senate_vote(detail, roll)

def fetch_senate(ctx):
    congress, session, year = congress_session(ctx)
    vote = fetch_senate_for(congress, session)
    if vote["ok"]:
        print("SENATE", congress, session, "roll", vote["roll"], vote["bill"], vote["result_short"], vote["yea"], "-", vote["nay"])
        return vote
    if vote["reason"] != "NO SENATE VOTES YET":
        return vote
    pc, ps = prev_session(congress, session)
    vote2 = fetch_senate_for(pc, ps)
    if vote2["ok"]:
        print("SENATE fallback", pc, ps, "roll", vote2["roll"], vote2["bill"], vote2["result_short"])
        return vote2
    return vote

# ---------- drawing ----------
#
# Same scoreboard: blue House / amber Senate headers, giant official result,
# YEA/NAY bars, then title + margin. Polish is spacing and hierarchy only.

TITLE_PAD = 8
TITLE_MAXW = 176

def chamber_theme(chamber):
    if chamber == "SENATE":
        return "amber", "black"
    return "blue", "white"

def chamber_mark(chamber):
    if chamber == "SENATE":
        return DOME_SENATE
    return DOME_HOUSE

def result_icon(short):
    if short == "PASSED" or short == "AGREED" or short == "CONFIRMED":
        return "check"
    if short == "FAILED" or short == "REJECTED":
        return "x"
    return ""

def join_words(words, a, b):
    out = words[a]
    for i in range(a + 1, b):
        out = out + " " + words[i]
    return out

def wrap2(c, text, font, maxw):
    w = c.text_width(text, font)
    words = text.split(" ")
    # One line if it fits with slack; otherwise prefer a balanced 2-line wrap.
    if w <= maxw and (w + 24 <= maxw or len(words) < 2):
        return [text]
    if len(words) < 2:
        return []
    best = []
    best_score = 100000
    for i in range(1, len(words)):
        a = join_words(words, 0, i)
        b = join_words(words, i, len(words))
        wa = c.text_width(a, font)
        wb = c.text_width(b, font)
        if wa <= maxw and wb <= maxw:
            score = wa - wb
            if score < 0:
                score = -score
            if a.endswith(":") or a.endswith("-"):
                score = score - 50
            b0 = b.split(" ")[0]
            if b0 == "TO" or b0 == "OF" or b0 == "AND" or b0 == "THE" or b0 == "FOR":
                score = score + 20
            if best == [] or score < best_score:
                best = [a, b]
                best_score = score
    if best != []:
        return best
    if w <= maxw:
        return [text]
    return []

def wrap3(c, text, font, maxw):
    words = text.split(" ")
    if len(words) == 0:
        return []
    if c.text_width(words[0], font) > maxw:
        return []
    lines = []
    cur = words[0]
    for i in range(1, len(words)):
        cand = cur + " " + words[i]
        if c.text_width(cand, font) <= maxw:
            cur = cand
        else:
            lines.append(cur)
            cur = words[i]
            if c.text_width(cur, font) > maxw:
                return lines
            if len(lines) >= 3:
                return lines
    lines.append(cur)
    if len(lines) > 3:
        return lines[:3]
    return lines

def fit_title(c, text, maxw):
    raw = collapse_ws(text).upper()
    if raw == "":
        return [], "5x7"
    short = shorten_procedural(raw)
    fonts = ["6x8", "5x7", "4x5"]
    # Prefer a larger font, even if that means shortening procedural wording.
    # Bill titles usually do not match those phrases, so they stay intact.
    for font in fonts:
        lines = wrap2(c, raw, font, maxw)
        if lines != []:
            return lines, font
        if short != "" and short != raw:
            lines = wrap2(c, short, font, maxw)
            if lines != []:
                return lines, font
    for src in [raw, short]:
        if src == "":
            continue
        lines = wrap3(c, src, "4x5", maxw)
        if lines != []:
            return lines, "4x5"
    return [raw], "4x5"

def draw_title_lines(c, lines, font, x, y, maxw):
    n = len(lines)
    glyph = font_line_h(font)
    if font == "6x8":
        lh = 11
    elif font == "5x7":
        lh = 10
    elif n >= 3:
        lh = 7
    else:
        lh = 8
    total_h = glyph + (n - 1) * lh
    # Body is y=11..31 (21px). Center the block; keep 2px off the bottom edge.
    body_h = c.height - 11
    yy = 11 + (body_h - total_h) // 2
    if yy < 11:
        yy = 11
    if yy + total_h > c.height - 1:
        yy = c.height - 1 - total_h
        if yy < 11:
            yy = 11
    for line in lines:
        if c.text_width(line, font) <= maxw:
            c.text(line, x, yy, font = font, color = "white")
        else:
            c.text_fit(line, x, yy, [font, "4x5"], color = "white", maxw = maxw)
        yy = yy + lh

def font_line_h(font):
    if font == "6x8":
        return 8
    if font == "5x7":
        return 7
    return 6

def draw_rail(c, chamber):
    bg, fg = chamber_theme(chamber)
    c.rect(0, 0, RAIL - 1, c.height - 1, fill = bg)

def draw_count_bar(c, x, y, w, h, n, scale, color):
    c.rect(x, y, x + w - 1, y + h - 1, fill = "darkgray")
    if scale < 1 or n < 1 or w < 1:
        return
    fw = (w * n) // scale
    if fw < 1:
        return
    if fw > w:
        fw = w
    c.rect(x, y, x + fw - 1, y + h - 1, fill = color)

def draw_chamber_bar(c, vote, left_label, show_bill):
    bg, fg = chamber_theme(vote["chamber"])
    c.rect(0, 0, c.width - 1, 8, fill = bg)
    c.sprite(chamber_mark(vote["chamber"]), 7, 1, color = fg)
    label = left_label.upper()
    c.text(label, 17, 1, font = "5x7", color = fg)
    roll = "#" + str(vote["roll"])
    c.text(roll, c.width - 8, 1, font = "5x7", color = fg, align = "right")
    if not show_bill:
        return
    bill = vote["bill"].upper()
    if bill == "":
        return
    lw = c.text_width(label, "5x7")
    rw = c.text_width(roll, "5x7")
    bx = 17 + lw + 10
    maxw = c.width - 10 - rw - bx
    if maxw >= 24:
        c.text_fit(bill, bx, 1, ["5x7", "4x5"], color = fg, maxw = maxw)

def draw_unavailable(c, heading, detail):
    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "darkgray")
    c.sprite(DOME_HOUSE, 3, 1, color = "gray")
    c.text("CAPITOL VOTE", 13, 1, font = "5x7", color = "white")
    c.text(heading.upper(), 6, 12, font = "6x8", color = "amber")
    c.text_fit(detail.upper(), 6, 23, ["5x7", "4x5"], color = "gray", maxw = 180)

def draw_headline(c, vote):
    if not vote["ok"]:
        draw_unavailable(c, "DATA UNAVAILABLE", vote["reason"])
        return
    c.fill("black")
    draw_chamber_bar(c, vote, vote["chamber"], True)
    short = vote["result_short"]
    col = result_color(short)
    font = "10x16"
    rw = c.text_width(short, font)
    icon = result_icon(short)
    extra = 0
    if icon != "":
        extra = 10
    max_result = c.width - 12 - extra
    if rw > max_result:
        font = "6x8"
        rw = c.text_width(short, font)
    group = rw + extra
    rx = (c.width - group) // 2
    if rx < 6:
        rx = 6
    ry = 10
    if font != "10x16":
        ry = 12
    c.text(short, rx, ry, font = font, color = col)
    if icon != "":
        c.icon(icon, rx + rw + 2, ry + 4, color = col)
    q = vote["question"].upper()
    if q == "":
        q = vote["title"].upper()
    c.text_fit(q, c.width // 2, 26, ["4x5"], color = "gray", align = "center", maxw = 180)

def draw_tally(c, vote):
    if not vote["ok"]:
        draw_unavailable(c, "DATA UNAVAILABLE", vote["reason"])
        return
    c.fill("black")
    close = is_close(vote)
    draw_rail(c, vote["chamber"])
    if close:
        c.rect(RAIL, 0, c.width - 1, c.height - 1, outline = "amber")

    yea = vote["yea"]
    nay = vote["nay"]
    scale = yea + nay
    if scale < 1:
        scale = 1
    # Same pixel scale for both bars: fill = bar_w * count / (yea+nay).
    # Reserve a 3-digit 10x16 column plus an 8px gutter so totals never crowd the bars.
    count_w = c.text_width("000", "10x16")
    label_x = RAIL + 3
    bar_x = label_x + 21
    count_x = c.width - 13
    gutter = 8
    bar_w = count_x - count_w - gutter - bar_x
    if bar_w < 40:
        bar_w = 40

    c.text("YEA", label_x, 4, font = "5x7", color = "green")
    c.text("NAY", label_x, 20, font = "5x7", color = "red")
    draw_count_bar(c, bar_x, 4, bar_w, 8, yea, scale, "green")
    draw_count_bar(c, bar_x, 20, bar_w, 8, nay, scale, "red")
    c.text(str(yea), count_x, 0, font = "10x16", color = "green", align = "right")
    c.text(str(nay), count_x, 16, font = "10x16", color = "red", align = "right")

def draw_title(c, vote):
    if not vote["ok"]:
        draw_unavailable(c, "DATA UNAVAILABLE", vote["reason"])
        return
    c.fill("black")
    draw_chamber_bar(c, vote, vote["chamber"], True)
    title = vote["title"].upper()
    if title == "":
        title = vote["question"].upper()
    if title == "":
        title = vote["bill"].upper()
    lines, font = fit_title(c, title, TITLE_MAXW)
    if lines == []:
        lines = [title]
        font = "4x5"
    draw_title_lines(c, lines, font, TITLE_PAD, 11, TITLE_MAXW)

def draw_stats(c, vote):
    if not vote["ok"]:
        draw_unavailable(c, "DATA UNAVAILABLE", vote["reason"])
        return
    if is_close(vote):
        draw_close(c, vote)
        return
    c.fill("black")
    draw_chamber_bar(c, vote, "MARGIN", False)
    yea = vote["yea"]
    nay = vote["nay"]
    margin = yea - nay
    if margin >= 0:
        mlab = "+" + str(margin)
        mcol = "green"
        side = "YEA"
    else:
        mlab = "+" + str(-margin)
        mcol = "red"
        side = "NAY"
    c.text(mlab, 6, 10, font = "10x16", color = mcol)
    mw = c.text_width(mlab, "10x16")
    c.text(side, 6 + mw + 4, 14, font = "6x8", color = mcol)

    pair = str(yea) + " - " + str(nay)
    c.text(pair, c.width - 6, 11, font = "5x7", color = "white", align = "right")
    if vote["nv"] > 0:
        c.text("NV " + str(vote["nv"]), c.width - 6, 20, font = "4x5", color = "gray", align = "right")
    elif vote["present"] > 0:
        c.text("P " + str(vote["present"]), c.width - 6, 20, font = "4x5", color = "gray", align = "right")
    elif vote["required"] != "":
        c.text("NEED " + vote["required"].upper(), c.width - 6, 20, font = "4x5", color = "gray", align = "right")

    day, clock = split_when(vote)
    c.text_fit(day, 6, 26, ["4x5"], color = "darkgray", maxw = 100)
    if clock != "":
        c.text_fit(clock, c.width - 6, 26, ["4x5"], color = "darkgray", align = "right", maxw = 80)

def draw_close(c, vote):
    c.fill("black")
    c.rect(0, 0, c.width - 1, c.height - 1, outline = "amber")
    c.rect(0, 0, c.width - 1, 8, fill = "amber")
    c.sprite(chamber_mark(vote["chamber"]), 3, 1, color = "black")
    c.text("CLOSE VOTE", 13, 0, font = "6x8", color = "black")
    c.text("#" + str(vote["roll"]), c.width - 4, 1, font = "5x7", color = "black", align = "right")
    yea = vote["yea"]
    nay = vote["nay"]
    margin = yea - nay
    if margin >= 0:
        mlab = "+" + str(margin)
        mcol = "green"
        side = "YEA"
    else:
        mlab = "+" + str(-margin)
        mcol = "red"
        side = "NAY"
    c.text(mlab, 6, 10, font = "10x16", color = mcol)
    mw = c.text_width(mlab, "10x16")
    c.text(side, 6 + mw + 4, 14, font = "6x8", color = mcol)
    pair = str(yea) + " - " + str(nay)
    c.text(pair, c.width - 6, 12, font = "6x8", color = "white", align = "right")
    col = result_color(vote["result_short"])
    c.text(vote["result_short"], c.width - 6, 22, font = "5x7", color = col, align = "right")

def votes_for(ctx):
    choice = chamber_choice(ctx)
    house = None
    senate = None
    if choice != "SENATE":
        house = fetch_house(ctx)
    if choice != "HOUSE":
        senate = fetch_senate(ctx)
    return choice, house, senate

def score(c, ctx):
    choice, house, senate = votes_for(ctx)
    if choice == "SENATE":
        draw_headline(c, senate)
        return
    draw_headline(c, house)

def tally(c, ctx):
    choice, house, senate = votes_for(ctx)
    if choice == "SENATE":
        draw_tally(c, senate)
        return
    draw_tally(c, house)

def title(c, ctx):
    choice, house, senate = votes_for(ctx)
    if choice == "BOTH":
        draw_headline(c, senate)
        return
    if choice == "SENATE":
        draw_title(c, senate)
        return
    draw_title(c, house)

def extra(c, ctx):
    choice, house, senate = votes_for(ctx)
    if choice == "BOTH":
        draw_tally(c, senate)
        return
    if choice == "SENATE":
        draw_stats(c, senate)
        return
    draw_stats(c, house)
