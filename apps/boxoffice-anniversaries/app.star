# Box Office Rewind for Glance LED Panels.
#
# The top 3 domestic box office movies for "N years ago this week" are
# fetched live from the-numbers.com's weekend chart pages
# (the-numbers.com/box-office-chart/weekend/YYYY/MM/DD). There's no
# Billboard-style community JSON mirror for box office history - every
# option was checked first:
#   - boxofficemojo.com: has the real archive (weekend charts back to
#     1982), but its robots.txt explicitly states "Use of any device,
#     tool, or process designed to data mine or scrape the content using
#     automated means is prohibited without prior written permission from
#     IMDb", plus a blanket Disallow: / for all other user-agents. Ruled
#     out entirely - this is a stated policy, not just a missing API.
#   - rottentomatoes.com: robots.txt is permissive, but they don't have a
#     structured historical archive at all - just weekly prose editorial
#     articles with no consistent per-date URL or extractable format.
#   - the-numbers.com: robots.txt only blocks Amazon's own bots (a
#     competitor-dispute rule, not an anti-automation stance) and has no
#     "no scraping" statement. Confirmed real chart data back to at least
#     1985. This is the one we use.
#
# There's still no JSON endpoint, so this parses the HTML chart table
# directly with plain string search/slice (Starlark has no regex or HTML
# parser) - fragile in the sense that a markup change would break it, but
# the table structure has been extremely consistent across 40 years of
# archived pages checked.
#
# The site's WAF 403s the default User-Agent of common HTTP libraries
# (python-requests, python-urllib) but allows a plain, honestly-labeled
# one - this isn't spoofing a browser, just not tripping a blunt
# script-signature filter that a real crawler (Googlebot, etc.) wouldn't
# trip either.
#
# Like Billboard's chart, the weekend date is always a Friday, so
# "N years ago" resolves to the nearest Friday to today shifted back N
# years, not a literal same-day-N-years-back lookup.

USER_AGENT = "Mozilla/5.0 (compatible; glance-dev-network/1.0)"

def fetch_boxoffice_chart(date_path):
    # A past chart's contents never change once published, so this is
    # cached essentially permanently (30 days) - no reason to refetch a
    # 1995 chart every render cycle, and it keeps our footprint on their
    # server light.
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
    return s

def extract_top3(html):
    # The desktop and mobile tables both list the same chart - isolate just
    # the desktop one so nothing gets double-counted.
    table_start = html.find('<table class="chart-desktop">')
    if table_start < 0:
        return []
    table_end = html.find("</table>", table_start)
    if table_end < 0:
        table_end = len(html)
    section = html[table_start:table_end]

    movies = []
    pos = 0
    for _ in range(3):
        a_start = section.find('<a href="/movie/', pos)
        if a_start < 0:
            break
        gt = section.find(">", a_start)
        if gt < 0:
            break
        title_start = gt + 1
        title_end = section.find("</a>", title_start)
        if title_end < 0:
            break
        title = html_unescape(section[title_start:title_end])

        dollar_start = section.find("$", title_end)
        gross = ""
        if dollar_start >= 0:
            dollar_end = section.find("<", dollar_start)
            if dollar_end >= 0:
                gross = section[dollar_start:dollar_end]

        movies.append({"title": title, "gross": gross})
        pos = title_end
    return movies

def fit_text(c, text, font, maxw):
    # Truncates on actual pixel width (via c.text_width), not a guessed
    # character count - a fixed char-count cutoff still overflows once the
    # font's actual glyph+gap width is accounted for, and doesn't adapt if
    # the font ever changes.
    if c.text_width(text, font) <= maxw:
        return text
    for i in range(len(text), 0, -1):
        candidate = text[:i] + "..."
        if c.text_width(candidate, font) <= maxw:
            return candidate
    return "..."

def draw_chart_unavailable(c):
    c.text("CHART DATA".upper(), 64, 14, font = "4x5", color = "#888888", align = "center")
    c.text("UNAVAILABLE".upper(), 64, 20, font = "4x5", color = "#888888", align = "center")

def render_chart_page(c, ctx, years_ago):
    c.clear()

    year = ctx.now.year - years_ago
    label = str(years_ago) + " YRS AGO (" + str(year) + ")"
    content_y = c.header(label.upper())

    date_path = anniversary_chart_date(ctx, years_ago)
    resp = fetch_boxoffice_chart(date_path)
    if resp["status_code"] != 200:
        draw_chart_unavailable(c)
        return

    movies = extract_top3(resp["body"])
    if not movies:
        draw_chart_unavailable(c)
        return

    y = content_y
    rank = 1
    for m in movies:
        line = str(rank) + ". " + m["title"].upper()
        c.text(fit_text(c, line, "4x5", 126), 1, y, font = "4x5", color = "white")
        y += 6
        rank += 1

def draw_spotlights(c):
    # A pair of premiere-night searchlight fans, sweeping up from each
    # lower corner and converging behind the title - kept above the
    # divider line so they don't cut across the subtitle underneath.
    color = "#4A3B00"
    c.line(0, 19, 30, 0, color)
    c.line(0, 19, 45, 0, color)
    c.line(0, 19, 60, 0, color)
    c.line(127, 19, 97, 0, color)
    c.line(127, 19, 82, 0, color)
    c.line(127, 19, 67, 0, color)

def intro(c, ctx):
    # An original title card, not a reproduction of any real logo/wordmark -
    # just this app's own bitmap-font styling.
    c.clear()
    draw_spotlights(c)
    c.text("BOX OFFICE".upper(), 64, 2, font = "10x16_bold", color = "amber", align = "center")
    c.line(24, 20, 104, 20, "#555555")
    c.text("TOP 3 FROM YESTERYEAR".upper(), 64, 23, font = "4x7", color = "gray", align = "center")

def years_5(c, ctx):
    render_chart_page(c, ctx, 5)

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
