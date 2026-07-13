# Ported from the official tidbyt/pixlet Location schema example (docs/schema/location/example.star).
#
# ORIGINAL Pixlet render code:
#   return render.Root(child = render.Marquee(width = 64,
#       child = render.Text("tz: %s" % timezone)))
# with a schema.Location picker whose JSON carries a "timezone" field.
#
# `gdn translate` converted the schema field to a manifest input and flagged the
# Marquee/Root/Text widgets + the load() imports. Hand-finished for GDN (static
# 64x32): the marquee became a two-line static label, and the Location picker
# became a plain timezone string input. See docs/PIXLET_COMPATIBILITY.md.

def main(c, ctx):
    tz = ctx.inputs.get("tz", "America/New_York")
    parts = tz.split("/")
    # Bitmap fonts are UPPERCASE-only, so always .upper() display text.
    region = parts[0].upper()
    city = parts[-1].replace("_", " ").upper()

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "green")
    c.text("TIMEZONE", c.width // 2, 1, font = "4x5", color = "black", align = "center")
    c.text(region, c.width // 2, 12, font = "4x5", color = "gray", align = "center")
    # shrink the font if the city is too wide for the panel
    city_font = "5x7" if c.text_width(city, "5x7") <= c.width - 2 else "4x5"
    c.text(city, c.width // 2, 20, font = city_font, color = "white", align = "center")
