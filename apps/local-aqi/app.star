# Local AQI — US Air Quality Index + health guidance for a zip. (128x32, 2 pages)
#
# Offline mock data derived from the zip. Swap `data()` for a real AQI feed later.

DIGITS = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4,
          "5": 5, "6": 6, "7": 7, "8": 8, "9": 9}
POLL = ["PM2.5", "OZONE", "PM10", "NO2"]

def seed_of(zip):
    s = 0
    for i in range(len(zip)):
        s = s * 10 + DIGITS.get(zip[i], 0)
    return s

def category(aqi):
    # (label, color, icon, advice) by EPA AQI band
    if aqi <= 50:
        return "GOOD", "green", "leaf.png", "AIR IS CLEAN"
    if aqi <= 100:
        return "MODERATE", "yellow", "leaf.png", "OK FOR MOST"
    if aqi <= 150:
        return "USG", "orange", "mask.png", "SENSITIVE: CARE"
    if aqi <= 200:
        return "UNHEALTHY", "red", "mask.png", "LIMIT TIME OUT"
    if aqi <= 300:
        return "VERY BAD", "magenta", "mask.png", "AVOID OUTDOORS"
    return "HAZARD", "red", "mask.png", "STAY INDOORS"

def data(zip):
    s = seed_of(zip)
    aqi = s % 260
    label, color, icon, advice = category(aqi)
    return {"aqi": aqi, "cat": label, "color": color, "icon": icon,
            "advice": advice, "poll": POLL[s % 4]}

def now(c, ctx):
    d = data(ctx.inputs["zip"])
    city = ctx.inputs.get("city", "").upper()

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = d["color"])
    c.text(city or "AIR QUALITY", c.width // 2, 1, font = "5x7", color = "black", align = "center")

    c.text(str(d["aqi"]), 4, 11, font = "16x20", color = d["color"])
    c.text(d["cat"], c.width - 4, 12, font = "6x8", color = d["color"], align = "right")
    c.text("US AQI", c.width - 4, 24, font = "4x5", color = "gray", align = "right")

def health(c, ctx):
    d = data(ctx.inputs["zip"])

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text("HEALTH", c.width // 2, 1, font = "5x7", color = "white", align = "center")

    c.image(d["icon"], 3, 11, w = 13, h = 13)            # leaf when clean, mask when not
    c.text("MAIN " + d["poll"], 20, 11, font = "4x5", color = "cyan")
    c.text(d["advice"], 20, 20, font = "4x5", color = "white")
