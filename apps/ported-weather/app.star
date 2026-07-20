# Ported from a Pixlet/tronbyt app.
#
# The ORIGINAL Pixlet code was:
#
#   def main(config):
#       city = config.str("city", "NYC")
#       units = config.get("units") or "metric"
#       return render.Root(child = render.Column(children = [
#           render.Text(content = "WEATHER", color = "#0f0"),
#           render.Marquee(width = 64, child = render.Text(content = city)),
#           render.Row(children = [render.Text("72"), render.Text("F")]),
#       ]))
#
# `gdn translate` converted the schema -> manifest inputs and flagged the render
# widgets. Then the render.Root(Column[...]) WIDGET TREE was hand-finished into
# explicit c.* draw calls below (Column = stack vertically; Marquee = static text;
# Row = place side by side). The layout ported unchanged; the hardcoded "72"
# is now a live reading from Open-Meteo, which needs no API key.
# See docs/PIXLET_COMPATIBILITY.md.

def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _lookup(city):
    # City name -> lat/lon. Names rarely change, so cache for a day.
    r = http.get(
        "https://geocoding-api.open-meteo.com/v1/search",
        params = {"name": city, "count": "1", "format": "json"},
        ttl_seconds = 86400,
    )
    if r["status_code"] != 200:
        return None

    hits = r["json"].get("results", [])
    if not hits:
        return None

    h = hits[0]
    return [h["latitude"], h["longitude"], h["name"]]

def main(c, ctx):
    city = _s(ctx, "city", "NYC")
    units = _s(ctx, "units", "metric")

    imperial = units == "imperial"
    unit_char = "F" if imperial else "C"

    c.fill("black")
    c.text("WEATHER", c.width // 2, 1, font = "5x7", color = "green", align = "center")

    loc = _lookup(city)
    if loc == None:
        c.text(city.upper(), c.width // 2, 11, font = "5x7", color = "white", align = "center")
        c.text("NOT FOUND", c.width // 2, 22, font = "5x7", color = "orange", align = "center")
        return

    r = http.get(
        "https://api.open-meteo.com/v1/forecast",
        params = {
            "latitude": str(loc[0]),
            "longitude": str(loc[1]),
            "current": "temperature_2m",
            "temperature_unit": "fahrenheit" if imperial else "celsius",
        },
        ttl_seconds = 900,
    )

    # ALWAYS check status_code before touching the json
    if r["status_code"] != 200:
        c.text(loc[2].upper(), c.width // 2, 11, font = "5x7", color = "white", align = "center")
        c.text("NO DATA", c.width // 2, 22, font = "5x7", color = "orange", align = "center")
        return

    t = r["json"].get("current", {}).get("temperature_2m", None)
    if t == None:
        c.text(loc[2].upper(), c.width // 2, 11, font = "5x7", color = "white", align = "center")
        c.text("NO DATA", c.width // 2, 22, font = "5x7", color = "orange", align = "center")
        return

    temp = str(int(float(t) + 0.5)) + unit_char

    c.text(loc[2].upper(), c.width // 2, 11, font = "5x7", color = "white", align = "center")
    c.text(temp, c.width // 2, 21, font = "7x12", color = "yellow", align = "center")