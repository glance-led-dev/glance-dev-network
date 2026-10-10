# Military DTG Clock
#
# DESIGN. Army black and gold. LOCAL: the 24-hour time is the gold hero on
# the left; on the right a gold tab carries the military zone letter the way
# it's written in a DTG (R for Eastern standard, Q for Eastern daylight...),
# its phonetic name under it, and the date. ZULU: the same hero in UTC with
# the full date-time group written out beneath it (DDHHMMZ MON YY), and a
# HOME column so a deployed soldier always knows what time it is for family.
# A clock needs no title; the letter tab is the identity.
#
# No network: zones and daylight saving resolve here, so it can't go dark.

BG = "#000000"
GOLD = "#FFC72C"
DIMGOLD = "#6B5310"
LABEL = "#8C8C8C"
RULE = "#3A2D08"

DOW = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
MON = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
       "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# zone -> [standard offset in minutes east of UTC, daylight-saving rule]
ZONES = {
    "EASTERN": [-300, "US"], "CENTRAL": [-360, "US"], "MOUNTAIN": [-420, "US"],
    "ARIZONA": [-420, ""], "PACIFIC": [-480, "US"], "ALASKA": [-540, "US"],
    "HAWAII": [-600, ""], "EUROPE": [60, "EU"], "KUWAIT": [180, ""],
    "KOREA": [540, ""], "JAPAN": [540, ""], "GUAM": [600, ""],
}

# Whole-hour UTC offset -> [military zone letter, phonetic name]. J (local
# time) is never a fixed offset, so it isn't here.
LETTERS = {
    0: ["Z", "ZULU"], 1: ["A", "ALPHA"], 2: ["B", "BRAVO"], 3: ["C", "CHARLIE"],
    4: ["D", "DELTA"], 5: ["E", "ECHO"], 6: ["F", "FOXTROT"], 7: ["G", "GOLF"],
    8: ["H", "HOTEL"], 9: ["I", "INDIA"], 10: ["K", "KILO"], 11: ["L", "LIMA"],
    12: ["M", "MIKE"], -1: ["N", "NOVEMBER"], -2: ["O", "OSCAR"],
    -3: ["P", "PAPA"], -4: ["Q", "QUEBEC"], -5: ["R", "ROMEO"],
    -6: ["S", "SIERRA"], -7: ["T", "TANGO"], -8: ["U", "UNIFORM"],
    -9: ["V", "VICTOR"], -10: ["W", "WHISKEY"], -11: ["X", "XRAY"],
    -12: ["Y", "YANKEE"],
}


def dfc(y, m, d):
    """Days since the Unix epoch (Howard Hinnant's algorithm)."""
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


def civil(z):
    """[y, m, d] for a day number (inverse of dfc)."""
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [y + 1 if m <= 2 else y, m, d]


def wday(z):
    """0 = Sunday. 1970-01-01 was a Thursday."""
    return (z + 4) % 7


def nth_sunday(y, m, n):
    """Day number of the nth Sunday of a month (n = -1 for the last)."""
    if n < 0:
        nxt = dfc(y + 1, 1, 1) if m == 12 else dfc(y, m + 1, 1)
        return nxt - 1 - wday(nxt - 1)
    first = dfc(y, m, 1)
    return first + (7 - wday(first)) % 7 + 7 * (n - 1)


def zone_name(ctx, key):
    z = str(ctx.inputs.get(key, "EASTERN")).strip().upper()
    return z if z in ZONES else "EASTERN"


def offset_min(zone, unix):
    z = ZONES[zone]
    std = z[0]
    mins = unix // 60
    y = civil(unix // 86400)[0]
    if z[1] == "US":
        # 2nd Sunday of March 02:00 local -> 1st Sunday of November 02:00.
        start = nth_sunday(y, 3, 2) * 1440 + 120 - std
        end = nth_sunday(y, 11, 1) * 1440 + 120 - std - 60
        if mins >= start and mins < end:
            return std + 60
    elif z[1] == "EU":
        # Last Sunday of March 01:00 UTC -> last Sunday of October 01:00 UTC.
        start = nth_sunday(y, 3, -1) * 1440 + 60
        end = nth_sunday(y, 10, -1) * 1440 + 60
        if mins >= start and mins < end:
            return std + 60
    return std


def wall(unix, off):
    """Clock fields for a UTC instant shifted by `off` minutes."""
    t = unix + off * 60
    day = t // 86400
    secs = t % 86400
    ymd = civil(day)
    return {"y": ymd[0], "m": ymd[1], "d": ymd[2], "dow": wday(day),
            "hh": secs // 3600, "mm": (secs % 3600) // 60}


def hhmm(t):
    return fmt.pad(t["hh"]) + fmt.pad(t["mm"])


def dtg(t, letter):
    """Date-time group: DDHHMM + zone letter + MON + YY, e.g. 091830Z OCT 26."""
    return fmt.pad(t["d"]) + hhmm(t) + letter + " " + MON[t["m"] - 1] + " " + \
        fmt.pad(t["y"] % 100)


def hero(c, text):
    """The 24-hour time, 16x24 gold, centred in the left column x 6..72.
    '2359' is the widest at 67px, so the column is exactly that."""
    x = 6 + (67 - c.text_width(text, "16x24")) // 2
    c.text(text, x, 2, font = "16x24", color = GOLD)


def local(c, ctx):
    zone = zone_name(ctx, "timezone")
    off = offset_min(zone, ctx.now.unix)
    t = wall(ctx.now.unix, off)
    let = LETTERS.get(off // 60, ["J", "JULIETT"])

    c.fill(BG)
    hero(c, hhmm(t))
    c.text("HRS", 39, 27, font = "4x5", color = LABEL, align = "center")
    c.vline(74, 3, 28, RULE)

    # Right column x 76..121; the date row (46px, 'WED 30 DEC') sets it. The tab is a gold block wearing the
    # zone letter in black, centred on the column; NOVEMBER (39px) is the
    # widest phonetic name and still fits under it.
    mid = 99
    # 9x12_bold: 10x14 drew the letter as a hollow outline on the gold.
    c.rect(mid - 8, 1, mid + 8, 16, fill = GOLD)
    c.text(let[0], mid + 1, 3, font = "9x12_bold", color = "black", align = "center")
    c.text(let[1], mid, 19, font = "4x5", color = GOLD, align = "center")
    c.text("%s %s %s" % (DOW[t["dow"]], fmt.pad(t["d"]), MON[t["m"] - 1]),
           mid, 26, font = "4x5", color = LABEL, align = "center")


def zulu(c, ctx):
    z = wall(ctx.now.unix, 0)
    home = zone_name(ctx, "home")
    h = wall(ctx.now.unix, offset_min(home, ctx.now.unix))

    c.fill(BG)
    hero(c, hhmm(z))
    # The DTG line under the hero: '092359Z OCT 26' is 56px in 4x5, inside
    # the 67px hero column. The Z is the hero's label, so it carries it.
    c.text(dtg(z, "Z"), 39, 27, font = "4x5", color = "white", align = "center")
    c.vline(74, 3, 28, RULE)

    # HOME column x 76..121: label, the home wall clock in white, zone name.
    mid = 99
    c.text("HOME", mid, 2, font = "4x5", color = DIMGOLD, align = "center")
    c.text(hhmm(h), mid, 10, font = "8x12", color = "white", align = "center")
    c.text(home, mid, 26, font = "4x5", color = LABEL, align = "center")
