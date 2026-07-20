# Countdown - days remaining until an event. (128x32)
# Uses ctx.now for today's date; the target comes from the `date` input.

MDAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

def is_leap(y):
    return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

def mdays(y, m):
    if m == 2 and is_leap(y):
        return 29
    return MDAYS[m - 1]

def _days_from_civil(y, m, d):
    # Days since 1970-01-01. Subtracting two of these gives an exact day count
    # that accounts for leap years -- the old (year diff * 365) drifted by a day
    # for every Feb 29 between now and the target.
    yy = y - 1 if m <= 2 else y
    era = (yy if yy >= 0 else yy - 399) // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _is_num(s):
    if len(s) == 0:
        return False
    for i in range(len(s)):
        if s[i] < "0" or s[i] > "9":
            return False
    return True

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

def days(c, ctx):
    event = _s(ctx, "event", "EVENT").upper()
    parts = _s(ctx, "date", "2027-01-01").split("-")

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text(event, c.width // 2, 1, font = fit_font(c, event, ["5x7", "4x5"], c.width - 4), color = "white", align = "center")

    # Guard against anything that isn't YYYY-MM-DD so a stray input can't crash.
    ok = len(parts) == 3 and _is_num(parts[0]) and _is_num(parts[1]) and _is_num(parts[2])
    if ok:
        ty = int(parts[0])
        tm = int(parts[1])
        td = int(parts[2])
        # Also reject impossible dates, not just non-numeric ones.
        ok = tm >= 1 and tm <= 12 and td >= 1 and td <= mdays(ty, tm)

    if not ok:
        c.text("SET DATE", c.width // 2, 13, font = "6x8", color = "red", align = "center")
        c.text("YYYY-MM-DD", c.width // 2, 24, font = "4x5", color = "gray", align = "center")
        return

    left = _days_from_civil(ty, tm, td) - _days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    target = MONTHS[tm - 1] + " " + str(td) + " " + str(ty)

    # ----- the two states with no number to show -----
    if left < 0:
        c.text("PASSED", c.width // 2, 12, font = "7x12", color = "gray", align = "center")
        c.text(target, c.width // 2, 26, font = "4x5", color = "#555a66", align = "center")
        return

    if left == 0:
        c.text("TODAY", c.width // 2, 12, font = "10x16", color = "yellow", align = "center")
        return

    # ----- the count -----
    # Closer events read hotter, so the color carries urgency at a glance.
    if left <= 7:
        col = "red"
    elif left <= 30:
        col = "orange"
    else:
        col = "yellow"

    num = str(left)

    # Number on the left, sized to leave room for the label column beside it.
    nfont = fit_font(c, num, ["16x20", "10x16", "7x12"], 78)
    nw = c.text_width(num, nfont)
    c.text(num, 5, 10, font = nfont, color = col)

    # Label column: unit on top, the actual target date under it, both left
    # aligned to the same edge so they read as one block.
    lx = 5 + nw + 6
    lw = c.width - lx - 4

    unit = "DAYS" if left != 1 else "DAY"
    c.text(unit, lx, 11, font = fit_font(c, unit, ["7x12", "6x8", "5x7"], lw), color = "white")
    c.text(target, lx, 25, font = fit_font(c, target, ["4x5", "picopixel"], lw), color = "gray")