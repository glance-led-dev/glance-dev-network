# Ported from the tidbyt/community "Chemical Elements" app
# (apps/chemicalelements/chemical_elements.star).
#
# ORIGINAL Pixlet: a 118-element data table; main() picks one element (one per
# day-of-year, or random) and renders a periodic-table "cell" — a colored border
# render.Box column with the atomic number, symbol, and mass stacked, next to a
# render.Marquee of scrolling commentary.
#
# `gdn translate` converted the two schema.Dropdowns and flagged random.* +
# time.* + load() and the Row/Column/Box/Marquee/Text widgets. Hand-finished for
# GDN (static 64x32): the ELEMENT DATA TABLE ports verbatim (a 17-element subset
# with the app's own category Colors); random is replaced with the app's
# deterministic "one per day-of-year" pick using ctx.now.yday; the marquee
# commentary became a static periodic-cell card. UPPERCASE-only fonts.

# (symbol, atomic number, name, atomic mass, category, category color) — real
# rows from the original app's `elements` table.
ELEMENTS = [
    ("H", 1, "Hydrogen", 1.008, "Nonmetal", "#aec6cf"),
    ("He", 2, "Helium", 4.003, "Noble Gas", "#bf00ff"),
    ("Li", 3, "Lithium", 6.941, "Alkali Metal", "#ff0000"),
    ("C", 6, "Carbon", 12.011, "Nonmetal", "#aec6cf"),
    ("N", 7, "Nitrogen", 14.007, "Nonmetal", "#aec6cf"),
    ("O", 8, "Oxygen", 15.999, "Nonmetal", "#aec6cf"),
    ("Ne", 10, "Neon", 20.18, "Noble Gas", "#bf00ff"),
    ("Na", 11, "Sodium", 22.99, "Alkali Metal", "#ff0000"),
    ("Al", 13, "Aluminum", 26.982, "Basic Metal", "#008000"),
    ("Si", 14, "Silicon", 28.085, "Metalloid", "#006f86"),
    ("Fe", 26, "Iron", 55.845, "Transition Metal", "#ffffbf"),
    ("Cu", 29, "Copper", 63.546, "Transition Metal", "#ffffbf"),
    ("Ag", 47, "Silver", 107.87, "Transition Metal", "#ffffbf"),
    ("Au", 79, "Gold", 196.97, "Transition Metal", "#ffffbf"),
    ("Hg", 80, "Mercury", 200.59, "Transition Metal", "#ffffbf"),
    ("Pb", 82, "Lead", 207.2, "Basic Metal", "#008000"),
    ("U", 92, "Uranium", 238.03, "Actinoid", "#013220"),
]

# Some category colors in the table are near-black (e.g. Actinoid #013220).
# Scale so the brightest channel is at least 170 — keeps the category hue but
# stays readable on a black panel.
def readable(hexstr):
    r = int(hexstr[1:3], 16)
    g = int(hexstr[3:5], 16)
    b = int(hexstr[5:7], 16)
    m = max(r, g, b, 1)
    if m < 170:
        f = 170.0 / m
        r = min(255, int(r * f))
        g = min(255, int(g * f))
        b = min(255, int(b * f))
    return (r, g, b)

def main(c, ctx):
    sym, num, name, mass, typ, color = ELEMENTS[(ctx.now.yday - 1) % len(ELEMENTS)]
    accent = readable(color)

    c.fill("black")
    # category accent bar along the top
    c.rect(0, 0, c.width - 1, 1, fill = accent)
    # big element symbol on the left
    c.text(sym.upper(), 2, 3, font = "16x20", color = accent)
    # atomic number + mass stacked on the right
    c.text("NO", 40, 3, font = "4x5", color = "gray")
    c.text(str(num), c.width - 1, 3, font = "5x7", color = "white", align = "right")
    c.text("MASS", 40, 13, font = "4x5", color = "gray")
    c.text(str(mass), c.width - 1, 19, font = "4x5", color = "white", align = "right")
    # element name across the bottom (shrink if it will not fit)
    nm = name.upper()
    nf = "5x7" if c.text_width(nm, "5x7") <= c.width - 2 else "4x5"
    c.text(nm, c.width // 2, 25, font = nf, color = accent, align = "center")
