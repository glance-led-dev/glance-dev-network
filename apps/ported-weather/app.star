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
# Row = place side by side). The data/logic ported unchanged.
# See docs/PIXLET_COMPATIBILITY.md.

def main(c, ctx):
    city = ctx.inputs.get("city", "NYC").upper()
    units = ctx.inputs.get("units", "metric")
    temp = "22C" if units == "metric" else "72F"

    c.fill("black")
    c.text("WEATHER", c.width // 2, 1, font = "5x7", color = "green", align = "center")
    c.text(city, c.width // 2, 11, font = "5x7", color = "white", align = "center")
    c.text(temp, c.width // 2, 21, font = "7x12", color = "yellow", align = "center")
