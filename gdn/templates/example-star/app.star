# Weather Ticker — a GDN Starlark app (192x32, 2 pages).
#
# Starlark is a small, safe subset of Python. You draw with `c` (mirrors the GDN
# Canvas) and read the install's config from `ctx.inputs`. Each page in the
# manifest maps to a function `def <page>(c, ctx)`.
#
# This runs fully offline using mock data derived from the zip code, so preview
# works with no API keys. (Real http.get arrives in a later phase.)

COND_COLOR = {
    "SUNNY": "yellow", "CLEAR": "yellow", "CLOUDY": "gray",
    "RAIN": "blue", "WINDY": "cyan",
}
DIGITS = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4,
          "5": 5, "6": 6, "7": 7, "8": 8, "9": 9}

def get_weather(zip):
    """Deterministic mock so the preview changes as you edit the zip."""
    seed = 0
    for i in range(len(zip)):
        seed = seed * 10 + DIGITS.get(zip[i], 0)
    temp = 55 + seed % 40
    conds = ["SUNNY", "CLOUDY", "RAIN", "WINDY", "CLEAR"]
    return {
        "temp": temp, "cond": conds[seed % len(conds)],
        "hi": temp, "lo": temp - 12,
        "week": [50 + (seed * (i + 3)) % 45 for i in range(5)],
    }

def current(c, ctx):
    wx = get_weather(ctx.inputs["zip"])
    city = ctx.inputs.get("city", "").upper()

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "white")
    c.text(city or "WEATHER", c.width // 2, 1, font = "5x7", color = "black", align = "center")

    col = COND_COLOR.get(wx["cond"], "white")
    c.text(str(wx["temp"]), 4, 12, font = "16x20", color = col)
    c.text("F", 40, 12, font = "7x12", color = "white")

    c.text(wx["cond"], c.width - 4, 12, font = "7x12", color = col, align = "right")
    c.text("H%d L%d" % (wx["hi"], wx["lo"]), c.width - 4, 24, font = "5x7",
           color = "gray", align = "right")

def week(c, ctx):
    wx = get_weather(ctx.inputs["zip"])
    days = ["MON", "TUE", "WED", "THU", "FRI"]

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "green")
    c.text("5-DAY", c.width // 2, 1, font = "5x7", color = "black", align = "center")

    col_w = c.width // 5
    for i in range(5):
        x = i * col_w + col_w // 2
        c.text(days[i], x, 11, font = "4x5", color = "gray", align = "center")
        c.text(str(wx["week"][i]), x, 19, font = "6x8", color = "white", align = "center")
