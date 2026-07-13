# Local Fires — wildfire risk + nearest active fire for a US zip. (128x32, 2 pages)
#
# Uses offline mock data derived from the zip, so preview needs no API. Swap
# `data()` for a real feed (e.g. via GDN's http) when you deploy.

DIGITS = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4,
          "5": 5, "6": 6, "7": 7, "8": 8, "9": 9}

RISK = [("LOW", "green"), ("MODERATE", "yellow"), ("HIGH", "orange"), ("EXTREME", "red")]
NAMES = ["CEDAR", "RIDGE", "CANYON", "MESA", "PINE", "OAK", "VALLEY", "SUMMIT"]

def seed_of(zip):
    s = 0
    for i in range(len(zip)):
        s = s * 10 + DIGITS.get(zip[i], 0)
    return s

def data(zip):
    s = seed_of(zip)
    ri = s % 4
    return {
        "risk": RISK[ri][0], "color": RISK[ri][1],
        "active": s % 6,
        "name": NAMES[s % len(NAMES)],
        "dist": 3 + s % 40,
        "acres": (1 + s % 60) * 100,
        "contain": (s * 7) % 101,
    }

def status(c, ctx):
    d = data(ctx.inputs["zip"])
    city = ctx.inputs.get("city", "").upper()

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "red")
    c.text(city or "FIRE WATCH", c.width // 2, 1, font = "5x7", color = "white", align = "center")

    c.image("flame.png", 3, 10, w = 13, h = 16)          # custom icon from this folder

    c.text("RISK", 22, 10, font = "4x5", color = "gray")
    c.text(d["risk"], 22, 17, font = "7x12", color = d["color"])

    c.text(str(d["active"]) + " ACTIVE", c.width - 3, 11, font = "4x5", color = "orange", align = "right")
    c.text("NEARBY", c.width - 3, 24, font = "4x5", color = "gray", align = "right")

def nearest(c, ctx):
    d = data(ctx.inputs["zip"])

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "orange")
    c.text("NEAREST FIRE", c.width // 2, 1, font = "5x7", color = "black", align = "center")

    c.text(d["name"] + " FIRE", 3, 11, font = "5x7", color = "orange")
    c.text(str(d["dist"]) + " MI", 3, 21, font = "5x7", color = "white")
    c.text(str(d["acres"]) + " AC", 44, 21, font = "5x7", color = "gray")
    c.text("CONTAINED", c.width - 3, 11, font = "4x5", color = "gray", align = "right")
    c.text(str(d["contain"]) + "%", c.width - 3, 20, font = "6x8", color = "green", align = "right")
