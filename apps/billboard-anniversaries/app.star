# Billboard Historical Chart Rewind for Glance LED Panels.
#
# The #1 song for "N years ago" is fetched live from mhollingshead/billboard-
# hot-100 (github.com/mhollingshead/billboard-hot-100), a community-maintained
# archive of every Billboard Hot 100 chart since 1958-08-04, served as static
# JSON off raw.githubusercontent.com and updated daily - confirmed live
# (recent.json returned tomorrow's chart-issue date when checked, and the
# 2016-10-15 chart matched the previously hand-entered "Closer" data). Not an
# official Billboard API - it's an unofficial third-party dataset with no
# stated license and no uptime guarantee, so it could go stale or disappear
# without warning. Billboard's own site was ruled out: billboard.com's
# robots.txt explicitly disallows AI-agent crawlers (including Claude/
# Anthropic by name), and there's no official free API either.
#
# Billboard has published a chart every single week since 1958 with no gaps,
# always dated a Saturday, so "N years ago" resolves to the nearest Saturday
# to today's date shifted back N years (see anniversary_chart_date below),
# not a literal same-day-N-years-back lookup.

def fetch_billboard_chart(date_str):
    # A past chart's contents never change once published, so this is cached
    # essentially permanently (30 days) - no reason to refetch a 2016 chart
    # every render cycle.
    return http.get(
        "https://raw.githubusercontent.com/mhollingshead/billboard-hot-100/main/date/" + date_str + ".json",
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

def nearest_saturday_days(days):
    # epoch day 0 (1970-01-01) was a Thursday, so weekday 0=SUN .. 6=SAT.
    weekday = (days + 4) % 7
    to_this_sat = 6 - weekday
    if to_this_sat <= 3:
        return days + to_this_sat
    return days + to_this_sat - 7

def anniversary_chart_date(ctx, years_ago):
    y = ctx.now.year - years_ago
    m = ctx.now.month
    d = ctx.now.day
    if m == 2 and d == 29:
        is_leap = (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)
        if not is_leap:
            d = 28
    target_days = days_from_civil(y, m, d)
    sat_days = nearest_saturday_days(target_days)
    sy, sm, sd = civil_from_days(sat_days)
    return str(sy) + "-" + pad2(sm) + "-" + pad2(sd)

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
    # header() draws a filled bar across the FULL width (not a left sidebar -
    # despite what this file used to claim) and returns the y just below it.
    # "#1 SONG" is dropped from this label - the intro page already covers
    # that framing, so it'd be redundant on every subsequent page.
    content_y = c.header(label.upper())

    chart_date = anniversary_chart_date(ctx, years_ago)
    resp = fetch_billboard_chart(chart_date)
    if resp["status_code"] != 200:
        draw_chart_unavailable(c)
        return

    entries = resp["json"].get("data", [])
    top = None
    for entry in entries:
        if entry.get("this_week", None) == 1:
            top = entry
            break
    if top == None:
        draw_chart_unavailable(c)
        return

    song_title = top.get("song", "")
    artist_name = top.get("artist", "")

    title_y = content_y + 2
    c.text(
        fit_text(c, song_title.upper(), "4x7", 124),
        1,
        title_y,
        font = "4x7",
        color = "white",
    )

    artist_y = title_y + 12
    c.text(
        fit_text(c, artist_name.upper(), "3x7", 124),
        1,
        artist_y,
        font = "3x7",
        color = "gray",
    )

def intro(c, ctx):
    # An original title card, not a reproduction of Billboard's actual
    # trademarked logo/wordmark - just this app's own bitmap-font styling.
    c.clear()
    c.text("BILLBOARD".upper(), 64, 2, font = "10x16_bold", color = "amber", align = "center")
    c.line(24, 20, 104, 20, "#555555")
    c.text("#1'S FROM YESTERYEAR".upper(), 64, 23, font = "4x7", color = "gray", align = "center")

def years_10(c, ctx):
    render_chart_page(c, ctx, 10)

def years_20(c, ctx):
    render_chart_page(c, ctx, 20)

def years_30(c, ctx):
    render_chart_page(c, ctx, 30)

def years_40(c, ctx):
    render_chart_page(c, ctx, 40)

def years_50(c, ctx):
    render_chart_page(c, ctx, 50)

def years_60(c, ctx):
    render_chart_page(c, ctx, 60)
