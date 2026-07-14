# Moon Phase (192x32)
#
# Everything here is computed locally: no HTTP, no assets. We take the current
# UTC time, work out where we are in the 29.53-day synodic month, and draw the
# lit part of the disc with the real terminator equation.

SYNODIC = 29.530588853          # days, new moon to new moon
NEW_EPOCH = 947182440           # unix time of a known new moon: 2000-01-06 18:14 UTC
PI = 3.141592653589793
TWO_PI = 6.283185307179586

LIT = "#F7E7C1"                 # warm bone white
CRATER = "#DBC49B"              # slightly dimmer, for texture
DARK = "#23252E"                # the unlit disc, just visible against black
MUTED = "#8AA0C8"

# ---------- tiny math (Starlark has no math module) ----------

def _cos(x):
    # Range-reduce to [-PI, PI], then Taylor series. Plenty accurate for pixels.
    n = int(x / TWO_PI)
    x = x - float(n) * TWO_PI
    if x > PI:
        x = x - TWO_PI
    if x < -PI:
        x = x + TWO_PI
    x2 = x * x
    term = 1.0
    total = 1.0
    for i in range(1, 9):
        term = -term * x2 / float((2 * i - 1) * (2 * i))
        total = total + term
    return total

def _sqrt(v):
    if v <= 0.0:
        return 0.0
    g = v
    for i in range(20):
        g = 0.5 * (g + v / g)
    return g

# ---------- time ----------

def _now_unix(ctx):
    # ctx.now is a time value; grab its epoch seconds however it exposes them.
    u = getattr(ctx.now, "unix", None)
    if u != None:
        return int(u)
    u = getattr(ctx.now, "timestamp", None)
    if u != None:
        return int(u)
    return NEW_EPOCH          # last resort: draw a new moon rather than crash

# ---------- phase ----------

def _phase(ctx):
    # 0.0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter
    cycles = (float(_now_unix(ctx)) - float(NEW_EPOCH)) / 86400.0 / SYNODIC
    p = cycles - float(int(cycles))
    if p < 0.0:
        p = p + 1.0
    return p

def _phase_name(p):
    if p < 0.02 or p >= 0.98:
        return "NEW MOON"
    if p < 0.23:
        return "WAXING CRESCENT"
    if p < 0.27:
        return "FIRST QUARTER"
    if p < 0.48:
        return "WAXING GIBBOUS"
    if p < 0.52:
        return "FULL MOON"
    if p < 0.73:
        return "WANING GIBBOUS"
    if p < 0.77:
        return "LAST QUARTER"
    return "WANING CRESCENT"

def fit_font(c, text, options, maxw):
    for f in options:
        if c.text_width(text, f) <= maxw:
            return f
    return options[len(options) - 1]

# ---------- the disc ----------

def _is_lit(dx, dy, r, t, waxing, south):
    # Half-width of the disc at this row. The terminator is an ellipse whose
    # half-width is t * w, where t = cos(2*pi*phase).
    w = _sqrt(float(r * r - dy * dy))
    x = float(dx)
    if south:
        x = -x                      # southern hemisphere sees it mirrored
    if waxing:
        return x >= t * w           # lit edge sweeps in from the right
    return x <= -t * w              # waning: lit edge retreats to the left

def _draw_moon(c, cx, cy, r, p, south):
    t = _cos(TWO_PI * p)
    waxing = p < 0.5
    rr = r * r

    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx * dx + dy * dy > rr:
                continue
            if _is_lit(dx, dy, r, t, waxing, south):
                c.pixel(cx + dx, cy + dy, LIT)
            else:
                c.pixel(cx + dx, cy + dy, DARK)

    # A few craters, but only where the surface is actually lit.
    for cr in [[-5, -5, 2], [3, 2, 3], [-2, 6, 1], [6, -7, 1], [7, 6, 2]]:
        ox = cr[0]
        oy = cr[1]
        cr_r = cr[2]
        for dy in range(oy - cr_r, oy + cr_r + 1):
            for dx in range(ox - cr_r, ox + cr_r + 1):
                if (dx - ox) * (dx - ox) + (dy - oy) * (dy - oy) > cr_r * cr_r:
                    continue
                if dx * dx + dy * dy > rr:
                    continue
                if _is_lit(dx, dy, r, t, waxing, south):
                    c.pixel(cx + dx, cy + dy, CRATER)

# ---------- page ----------

def moon(c, ctx):
    south = ctx.inputs.get("hemisphere", "Northern").upper() == "SOUTHERN"
    accent = ctx.inputs.get("accent", "#FFB347")

    p = _phase(ctx)
    illum = (1.0 - _cos(TWO_PI * p)) / 2.0
    pct = int(illum * 100.0 + 0.5)

    # Days until the next full moon (full happens at p = 0.5).
    if p < 0.5:
        days_full = (0.5 - p) * SYNODIC
    else:
        days_full = (1.5 - p) * SYNODIC
    d = int(days_full + 0.5)

    if d <= 0:
        full_line = "TONIGHT"
    elif d == 1:
        full_line = "IN 1 DAY"
    else:
        full_line = "IN " + str(d) + " DAYS"

    c.fill("black")

    # The moon itself, hugging the left edge.
    _draw_moon(c, 17, 16, 14, p, south)

    # Phase name across the top of the right side.
    name = _phase_name(p)
    c.text(name, 38, 1, font = fit_font(c, name, ["6x8", "5x7", "4x5"], 150), color = accent)

    # Big percent illuminated.
    pct_s = str(pct) + "%"
    pf = fit_font(c, pct_s, ["10x16", "7x12", "6x8"], 44)
    c.text(pct_s, 38, 10, font = pf, color = "white")
    c.text("LIT", 38 + c.text_width(pct_s, pf) + 4, 19, font = "5x7", color = MUTED)

    # Countdown to the next full moon.
    c.text("NEXT FULL", 120, 10, font = "5x7", color = MUTED)
    c.text(full_line, 120, 19, font = "5x7", color = "white")

    # Where we are in the lunar cycle.
    c.progress_bar(38, 28, 150, 3, int(p * 100.0), color = accent)