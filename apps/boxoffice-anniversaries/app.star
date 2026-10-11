# Box Office Rewind for Glance LED Panels (192x32).
#
# Shows the top 3 domestic box office movies from this weekend 10, 15, 20,
# 25, 30, 35 and 40 years ago, with each one's weekend gross and how long
# it had been in theaters.
#
# Chart data comes from the-numbers.com's weekend charts
# (the-numbers.com/box-office-chart/weekend/YYYY/MM/DD). There's no JSON
# endpoint, so the HTML chart table is parsed with plain string search
# (Starlark has no regex or HTML parser); if the markup ever changes the
# app shows "CHART DATA UNAVAILABLE" rather than crashing. Full weekend
# charts exist from the early 1980s on, which is why the oldest page is 40
# years ago.
#
# The site rejects the default User-Agent of common HTTP libraries, so
# requests send a plain, honestly-labeled one.
#
# Weekend charts cover Friday-Sunday, so "N years ago" uses the weekend
# whose Friday is nearest to today's date N years back.

USER_AGENT = "Mozilla/5.0 (compatible; glance-dev-network/1.0)"

def fetch_boxoffice_chart(date_path):
    # A past chart never changes once published, so it's cached for 30
    # days, which also keeps the load on their server light.
    return http.get(
        "https://www.the-numbers.com/box-office-chart/weekend/" + date_path,
        headers = {"User-Agent": USER_AGENT},
        ttl_seconds = 2592000,
    )

def civil_from_days(z):
    # Howard Hinnant's days-since-epoch -> (year, month, day). z = days since 1970-01-01.
    z = z + 719468
    era = (z // 146097) if z >= 0 else ((z - 146096) // 146097)
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = (mp + 3) if mp < 10 else (mp - 9)
    if m <= 2:
        y = y + 1
    return (y, m, d)

def days_from_civil(y, m, d):
    # Howard Hinnant's (year, month, day) -> days-since-epoch (1970-01-01).
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def pad2(n):
    s = str(n)
    if len(s) < 2:
        s = "0" + s
    return s

def nearest_friday_days(days):
    # epoch day 0 (1970-01-01) was a Thursday, so weekday 0=SUN .. 6=SAT.
    weekday = (days + 4) % 7
    to_this_fri = (5 - weekday) % 7
    if to_this_fri <= 3:
        return days + to_this_fri
    return days + to_this_fri - 7

def anniversary_chart_date(ctx, years_ago):
    y = ctx.now.year - years_ago
    m = ctx.now.month
    d = ctx.now.day
    if m == 2 and d == 29:
        is_leap = (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)
        if not is_leap:
            d = 28
    target_days = days_from_civil(y, m, d)
    fri_days = nearest_friday_days(target_days)
    fy, fm, fd = civil_from_days(fri_days)
    return str(fy) + "/" + pad2(fm) + "/" + pad2(fd)

def html_unescape(s):
    s = s.replace("&amp;", "&")
    s = s.replace("&#039;", "'")
    s = s.replace("&#39;", "'")
    s = s.replace("&rsquo;", "'")
    s = s.replace("&lsquo;", "'")
    s = s.replace("&quot;", "\"")
    # Curly quotes and dashes have no glyph in the panel fonts (c.text
    # silently drops them), so fold them to plain ASCII.
    s = s.replace("\u2019", "'").replace("\u2018", "'")
    s = s.replace("\u201c", "\"").replace("\u201d", "\"")
    s = s.replace("\u2013", "-").replace("\u2014", "-")
    s = s.replace("\u00e9", "e").replace("\u00c9", "E")
    return s

def cell_text(row, start):
    # Text inside the next <td ...>...</td> at or after `start`, plus the
    # position just past it. Returns ("", -1) if there's no further cell.
    td = row.find("<td", start)
    if td < 0:
        return ("", -1)
    gt = row.find(">", td)
    end = row.find("</td>", gt)
    if gt < 0 or end < 0:
        return ("", -1)
    return (row[gt + 1:end].strip(), end + 5)

def title_from_slug(slug):
    # A few chart rows have an empty link (e.g. The Amazing Spider-Man,
    # July 2012), so rebuild the title from the URL slug:
    # "Amazing-Spider-Man-The" -> "The Amazing Spider Man". A trailing
    # "-(2012)" year tag is dropped and a trailing article moves to the front.
    paren = slug.find("-(")
    if paren > 0:
        slug = slug[:paren]
    words = slug.split("-")
    if len(words) > 1 and words[len(words) - 1] in ("The", "A", "An"):
        words = [words[len(words) - 1]] + words[:len(words) - 1]
    return " ".join(words)

def extract_top3(html):
    # The desktop and mobile tables both list the same chart - isolate just
    # the desktop one so nothing gets double-counted. Columns: rank, prev
    # rank ("(new)" or "(3)"), title, weekend gross, weekly change,
    # theaters, theater average, total gross, days in release.
    table_start = html.find('<table class="chart-desktop">')
    if table_start < 0:
        return []
    table_end = html.find("</table>", table_start)
    if table_end < 0:
        table_end = len(html)
    section = html[table_start:table_end]

    movies = []
    pos = section.find("<tbody>")
    if pos < 0:
        pos = 0
    for _ in range(3):
        tr = section.find("<tr>", pos)
        if tr < 0:
            break
        tr_end = section.find("</tr>", tr)
        if tr_end < 0:
            break
        row = section[tr:tr_end]
        pos = tr_end

        cells = []
        p = 0
        for _ in range(9):
            txt, p = cell_text(row, p)
            if p < 0:
                break
            cells.append(txt)
        if len(cells) < 3:
            break

        title = cells[2]
        slug = ""
        a_start = title.find("<a ")
        if a_start >= 0:
            href = title.find('href="/movie/', a_start)
            if href >= 0:
                slug_end = title.find('"', href + 13)
                if slug_end >= 0:
                    slug = title[href + 13:slug_end]
            gt = title.find(">", a_start)
            a_end = title.find("</a>", gt)
            if gt >= 0 and a_end >= 0:
                title = title[gt + 1:a_end]
        if title.strip() == "" and slug != "":
            title = title_from_slug(slug)
        movies.append({
            "title": html_unescape(title),
            "prev": cells[1] if len(cells) > 1 else "",
            "gross": cells[3] if len(cells) > 3 else "",
            "days": cells[8] if len(cells) > 8 else "",
        })
    return movies

def _all_digits(s):
    if len(s) == 0:
        return False
    for i in range(len(s)):
        if s[i] < "0" or s[i] > "9":
            return False
    return True

def _one_dec(v):
    whole = int(v)
    tenth = int((v - float(whole)) * 10.0 + 0.5)
    if tenth > 9:
        whole = whole + 1
        tenth = 0
    return str(whole) + "." + str(tenth)

def format_gross(gross_str):
    # "$12,345,678" -> "$12.3M", "$845,000" -> "$845K". Returns "" if the
    # scraped text isn't a clean dollar figure, so a bad parse just omits
    # the gross instead of crashing the render (Starlark has no try/except).
    if gross_str == "":
        return ""
    digits = gross_str.replace("$", "").replace(",", "")
    if not _all_digits(digits):
        return ""
    value = float(int(digits))
    if value >= 1000000.0:
        return "$" + _one_dec(value / 1000000.0) + "M"
    if value >= 1000.0:
        return "$" + str(int(value / 1000.0 + 0.5)) + "K"
    return "$" + str(int(value))

def medal_color(rank):
    if rank == 1:
        return "#FFD700"  # gold
    if rank == 2:
        return "#C0C0C0"  # silver
    if rank == 3:
        return "#CD7F32"  # bronze
    return "white"

def decade_color(year):
    # A loose era palette with two shades per decade - early (years ending
    # 0-4) and late (5-9) - so pages five years apart in the same decade
    # still get their own color: 80s hot pink / neon orange, 90s turquoise /
    # purple, 2000s Y2K blue / lime, 2010s orchid / coral, 2020s spring
    # green / lavender.
    decade = (year // 10) * 10
    late = year % 10 >= 5
    if decade <= 1980:
        return "#FFA040" if late else "#FF69B4"
    elif decade == 1990:
        return "#B57BFF" if late else "#40E0D0"
    elif decade == 2000:
        return "#9ACD32" if late else "#1E90FF"
    elif decade == 2010:
        return "#FF7F66" if late else "#DA70D6"
    else:
        return "#B9A3E3" if late else "#00FF7F"

def fit_text(c, text, font, maxw):
    # Truncates with "..." to fit maxw pixels.
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i] + "..."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return "..."

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def draw_chart_unavailable(c):
    c.text("CHART DATA", 96, 14, font = "4x5", color = "#888888", align = "center")
    c.text("UNAVAILABLE", 96, 20, font = "4x5", color = "#888888", align = "center")

def weekend_label(fy, fm, fd):
    # Friday-Sunday span, e.g. "SEP 30-OCT 2, 2016" or "OCT 7-9, 2016".
    sy, sm, sd = civil_from_days(days_from_civil(fy, fm, fd) + 2)
    if sm == fm:
        span = MONTHS[fm - 1] + " " + str(fd) + "-" + str(sd)
    else:
        span = MONTHS[fm - 1] + " " + str(fd) + "-" + MONTHS[sm - 1] + " " + str(sd)
    return span + ", " + str(sy)

def status_tag(m):
    # "NEW" in its opening weekend, else which week of release it's in.
    # Days in release count from the original release, so a re-release
    # (The Lion King in 2011: 6,319 days) gets "RE-REL" instead of "WK 903".
    if m["prev"].lower() == "(new)":
        return ("NEW", "#00FF7F", "4x5")
    days = m["days"].replace(",", "")
    if _all_digits(days):
        if int(days) > 365:
            return ("RE-REL", "#888888", "picopixel")
        return ("WK " + str(int(days) // 7 + 1), "#888888", "4x5")
    return ("", "#888888", "4x5")

GROSS_R = 164   # right edge of the weekend-gross column
TAG_X = 168     # left edge of the NEW / WK N column
GROSS_W = 34    # widest gross ("$105.3M") in 4x5

# picopixel is narrower but has no apostrophe or parentheses, so it's only
# used for a long title it can draw completely.
PICO_MISSING = "'()\",;?@*"

def title_fit(c, title, maxw):
    if c.text_width(title, "4x5") <= maxw:
        return (title, "4x5")
    ok = True
    for i in range(len(PICO_MISSING)):
        if PICO_MISSING[i] in title:
            ok = False
    if ok and c.text_width(title, "picopixel") <= maxw:
        return (title, "picopixel")
    return (fit_text(c, title, "4x5", maxw), "4x5")

def render_chart_page(c, ctx, years_ago):
    c.clear()

    date_path = anniversary_chart_date(ctx, years_ago)
    fy, fm, fd = int(date_path[0:4]), int(date_path[5:7]), int(date_path[8:10])

    # Header bar in the weekend's decade color: "N YEARS AGO" left, the
    # Friday-Sunday weekend right.
    c.rect(0, 0, 191, 8, fill = decade_color(fy))
    c.text(str(years_ago) + " YEARS AGO", 2, 1, font = "5x7", color = "black")
    c.text(weekend_label(fy, fm, fd), 189, 1, font = "5x7", color = "black", align = "right")

    resp = fetch_boxoffice_chart(date_path)
    if resp["status_code"] != 200:
        draw_chart_unavailable(c)
        return

    movies = extract_top3(resp["body"])
    if not movies:
        draw_chart_unavailable(c)
        return

    # Three 7px rows (the picopixel rank badge sets the height): rank badge,
    # title, weekend gross, then a NEW / WK N tag.
    y = 10
    rank = 1
    for m in movies:
        badge_w = c.badge(str(rank), 1, y, color = "black", bg = medal_color(rank), font = "picopixel", pad = 2)
        title_x = 1 + badge_w + 3
        gross_str = format_gross(m["gross"])
        title, tf = title_fit(c, m["title"].upper(), GROSS_R - GROSS_W - 3 - title_x)
        c.text(title, title_x, y + 1, font = tf, color = "white")
        if gross_str:
            c.text(gross_str, GROSS_R, y + 1, font = "4x5", color = medal_color(rank), align = "right")
        tag, tag_color, tag_font = status_tag(m)
        if tag:
            c.text(tag, TAG_X, y + 1, font = tag_font, color = tag_color)
        y += 7
        rank += 1

DECADES = [(1980, "80S"), (1990, "90S"), (2000, "00S"), (2010, "10S"), (2020, "20S")]

def draw_spotlights(c, color):
    # Premiere-night searchlight fans sweeping up from both lower corners.
    for dx in (30, 45, 60, 75):
        c.line(0, 21, dx, 0, color)
        c.line(191, 21, 191 - dx, 0, color)

def intro(c, ctx):
    c.clear()
    draw_spotlights(c, "#4A3B00")
    tx = (192 - c.text_width("BOX OFFICE", "16x20_bold")) // 2
    c.text("BOX OFFICE", tx + 1, 1, font = "16x20_bold", color = "#7A3E00")
    c.text("BOX OFFICE", tx, 0, font = "16x20_bold", color = "#FFC000")
    # Decade tiles, each split into that decade's early and late shades -
    # the colors of the chart pages' header bars.
    bw = 38
    x_start = (192 - bw * len(DECADES)) // 2
    for i in range(len(DECADES)):
        year, lbl = DECADES[i]
        x0 = x_start + i * bw
        half = (bw - 1) // 2
        c.rect(x0, 22, x0 + half - 1, 31, fill = decade_color(year))
        c.rect(x0 + half, 22, x0 + bw - 2, 31, fill = decade_color(year + 5))
        c.text(lbl, x0 + (bw - 1) // 2, 24, font = "5x7", color = "black", align = "center")

def years_10(c, ctx):
    render_chart_page(c, ctx, 10)

def years_15(c, ctx):
    render_chart_page(c, ctx, 15)

def years_20(c, ctx):
    render_chart_page(c, ctx, 20)

def years_25(c, ctx):
    render_chart_page(c, ctx, 25)

def years_30(c, ctx):
    render_chart_page(c, ctx, 30)

def years_35(c, ctx):
    render_chart_page(c, ctx, 35)

def years_40(c, ctx):
    render_chart_page(c, ctx, 40)
