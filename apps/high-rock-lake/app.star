# High Rock Lake — Glance Classic app (64x32)
#
# Page 1 "brand": the Lake.Life sun/wave mark + "HIGH ROCK LAKE"
# Page 2 "water": current level (ft below full pond), rise/fall forecast,
#                 and water temperature.
#
# NOTE ON DATA SOURCES: neither site below exposes a JSON API, so this app
# scrapes plain text out of their HTML by searching for known label strings
# and reading the characters around them. That's inherently fragile — if
# either site redesigns its page, these lookups can silently start
# returning "N/A". Re-check this app in gdn studio (it'll show the raw
# fetched text) if the water page ever looks wrong.
#
# Verified 2026-08-18 against live pages via a real browser (not just a
# text summary), so this reflects actual page structure, not a guess:
#
#   - https://savehighrocklake.org/hrinfo1.asp
#       Text nodes render in this order (each label/value pair sits in its
#       own table cell, NOT one inline sentence like "N - Feet Below
#       Full" — there's no dash joining them):
#         High Rock Lake
#         1.75
#         Feet Below Full
#         ...
#         Water Temperature
#         90.0°
#       Because the number and its label live in separate tags, we can't
#       just substring-search the raw body (the tag soup between them
#       breaks a naive "last word before the landmark" search). We strip
#       tags to plain text first (see _strip_tags), then do the landmark
#       search against that — same idea, just tag-agnostic.
#   - https://ww4.cubecarolinas.com/lake/levels?orgID=3
#       HTML table, one row per reservoir, e.g.:
#         <tr><td>High Rock</td><td>653.24</td><td>1.76</td>
#             <td><img src=".../fluctuate_F.gif"></td></tr>
#       Confirmed by inspecting each row directly: fluctuate_F.gif = fall,
#       fluctuate_R.gif = rise, fluctuate_S.gif = steady. This lookup
#       stays on the RAW body (not tag-stripped) since the code we need
#       lives inside the <img src="..."> attribute, which tag-stripping
#       would throw away.

LEVEL_URL = "https://savehighrocklake.org/hrinfo1.asp"
FORECAST_URL = "https://ww4.cubecarolinas.com/lake/levels?orgID=3"

# Cap how much of the body we bother tag-stripping/scanning. Both pages put
# the numbers we want near the top; this just bounds worst-case work.
_SCAN_CAP = 20000


def _strip_tags(s):
    """Turn 'raw HTML text' into roughly what a browser's innerText would
    show: tags removed (each collapsed to a single space), attribute
    values (hrefs, image src, etc.) discarded along with them. Good enough
    to make landmark/number searches tag-agnostic; not a real HTML parser.
    """
    out = []
    in_tag = False
    for i in range(len(s)):
        ch = s[i]
        if ch == "<":
            in_tag = True
            out.append(" ")
        elif ch == ">":
            in_tag = False
        elif not in_tag:
            out.append(ch)
    return "".join(out)


def _extract_number_before(text, landmark):
    """Grab the trailing number in the chunk of text just before `landmark`.
    Expects tag-stripped text, e.g. text="... 1.75 Feet Below Full ..."
    landmark="Feet Below Full" -> "1.75"
    """
    idx = text.find(landmark)
    if idx == -1:
        return None
    before = text[:idx].strip()
    if before.endswith("-"):
        before = before[:-1].strip()
    parts = before.split()
    if len(parts) == 0:
        return None
    return parts[-1]


def _extract_number_after(text, landmark, window=40):
    """Grab the first number found shortly after `landmark`.
    Expects tag-stripped text, e.g. text="...Water Temperature 90.0°..."
    landmark="Water Temperature" -> "90.0"
    """
    idx = text.find(landmark)
    if idx == -1:
        return None
    chunk = text[idx + len(landmark):idx + len(landmark) + window]
    # walk past anything that isn't part of a number (skip "-", spaces, etc.)
    start = -1
    for i in range(len(chunk)):
        ch = chunk[i]
        if ch.isdigit():
            start = i
            break
    if start == -1:
        return None
    end = start
    for i in range(start, len(chunk)):
        ch = chunk[i]
        if ch.isdigit() or ch == ".":
            end = i + 1
        else:
            break
    return chunk[start:end]


def _fetch_level_and_temp():
    resp = http.get(LEVEL_URL, ttl_seconds=3600)
    if resp["status_code"] != 200 or resp["body"] == "":
        return None, None
    clean = _strip_tags(resp["body"][:_SCAN_CAP])
    level = _extract_number_before(clean, "Feet Below Full")
    temp = _extract_number_after(clean, "Water Temperature")
    return level, temp


def _fetch_forecast():
    resp = http.get(FORECAST_URL, ttl_seconds=3600)
    if resp["status_code"] != 200 or resp["body"] == "":
        return "?"
    body = resp["body"][:_SCAN_CAP]
    idx = body.find("High Rock")
    if idx == -1:
        return "?"
    window = body[idx:idx + 600]
    fidx = window.find("fluctuate_")
    if fidx == -1:
        return "?"
    code_start = fidx + len("fluctuate_")
    if code_start >= len(window):
        return "?"
    code = window[code_start:code_start + 1].upper()
    if code == "F":
        return "FALLING"
    elif code == "R":
        return "RISING"
    elif code == "S":
        return "STEADY"
    else:
        return "?"


def brand(c, ctx):
    c.fill("black")
    icon_w = 20
    icon_h = 20
    icon_x = (c.width - icon_w) // 2
    c.image("lakelife_icon.png", icon_x, 1, w=icon_w, h=icon_h)
    c.text_fit(
        "HIGH ROCK LAKE",
        0,
        23,
        fonts=["5x7", "4x5"],
        color="white",
        align="center",
        maxw=c.width,
    )


def _wave_header(c, title):
    # GDN pages are static renders - the docs are explicit that there's no
    # true animation within a page (see module docstring). This isn't
    # literal motion, just a still "water" treatment: a deep-blue bar with
    # a lighter scalloped band along the bottom edge, so it reads as more
    # than a flat color fill.
    w = c.width
    h = 8
    c.rect(0, 0, w - 1, h - 1, fill="#0a3d91")
    period = 8
    for x in range(w):
        pos = x % period
        depth = pos if pos < period // 2 else period - pos
        y = 5 + (depth // 2)
        c.pixel(x, y, "#3fa9f5")
        if y + 1 < h:
            c.pixel(x, y + 1, "#1e6fc4")
    c.text_center(title, 1, font="5x7", color="white")


def _kv_row(c, y, key, value, key_color="gray", value_color="white", font="4x7"):
    # Hand-rolled instead of c.kv(): c.kv doesn't reserve column space for
    # the key, so a long key (e.g. "BLW FULL") silently overlapped the
    # value with no gap between them. This measures both strings with
    # c.text_width() first, so key and value can never collide - key is
    # pinned to the left edge, value is right-aligned to the right edge,
    # and there's always at least a few px of gap between them given the
    # panel is 64px wide and these labels/values are short.
    c.text(key, 1, y, font=font, color=key_color)
    vw = c.text_width(value, font=font)
    vx = c.width - 1 - vw
    c.text(value, vx, y, font=font, color=value_color)


def water(c, ctx):
    c.fill("black")
    _wave_header(c, "WATER LEVEL")

    level, temp = _fetch_level_and_temp()
    forecast = _fetch_forecast()

    level_str = (level + " FT") if level else "N/A"
    temp_str = (temp + " F") if temp else "N/A"

    if forecast == "RISING":
        forecast_color = "green"
    elif forecast == "FALLING":
        forecast_color = "red"
    elif forecast == "STEADY":
        forecast_color = "gray"
    else:
        forecast_color = "gray"
        forecast = "N/A"

    _kv_row(c, 9, "BLW FL", level_str, value_color="white")
    _kv_row(c, 17, "TREND", forecast, value_color=forecast_color)
    _kv_row(c, 25, "TEMP", temp_str, value_color="amber")

