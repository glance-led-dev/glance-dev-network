# WW1 Facts - a different First World War fact every day.
#
#   headline  the theatre chip, the date, the title, and a timeline bar
#             showing where in the war this day sits
#   scene     drawn artwork for the entry, and what happened, in prose
#   legacy    why it mattered, and one supplementary line
#
# DESIGN. This is a museum placard, not a news panel. The register is the one
# a memorial museum uses: give the date, the place and the scale, name the
# thing plainly, and never decorate a death toll. Several entries here are
# about gas, genocide, famine and the drowning of men in sight of shore.
# They are in because leaving them out would misrepresent the war. They are
# written flat - a number, a place, a date - with no adjective doing work the
# fact can do on its own, and no graphic detail. The hardest entries get the
# quietest artwork: a line of walking figures, a row of grave markers.
#
# The colour is the navigation. Each of the ten theatres owns one hue, and it
# lights the rail at x0..1, the page chip, and the one highlight inside the
# artwork - so a viewer who sees three panels a week learns that steel blue
# means the Eastern Front before they have read a word. Everything else is
# bone white on black with a warm grey for meta, which is the paper-and-ink
# palette a placard actually has.
#
# The artwork is drawn from primitives rather than stored as sprites, because
# at 52x23 a dreadnought needs its funnels two pixels apart and a string-art
# grid cannot be nudged one pixel without retyping the row. 23 scenes cover
# the roster; every one of them draws strictly inside the art box, since the
# renderer clips only at the panel edge and would otherwise spill into the
# prose column beside it.
#
# DATA. The roster is curated and written here - 88 entries, each verified
# against the prose of the linked article rather than against a structured
# field. Live sources were tested and rejected for the dates: Wikidata has no
# inception date for a large share of events of this kind, and several dates
# it does carry describe a predecessor of the thing named. The one live call
# is on `legacy` only, and only for the bottom strip, so the other two pages
# are pure curated data and cannot fail. That call asks Wikipedia's REST
# summary endpoint for the article's one-line `description` - a field that is
# already written to be a single line, which is the only shape that fits a
# 34-character strip. When it is missing, slow, or the host is offline, the
# strip falls back to a curated note and nothing else on the panel changes.
# The curated title is always what is displayed; the endpoint silently
# redirects some titles to a generic article, so its own normalised title is
# never drawn.

# ------------------------------------------------------------------ palette
INK = "#F2EFE4"          # bone white - the paper a placard is printed on
DIM = "#8C8779"          # warm grey - dates, places, meta
FAINT = "#5A5647"        # the quietest readable tone
STRUCT = "#2A2E26"       # dividers, tracks, the timeline gutter
OFFLINE = "#3C4043"      # the rail when there is nothing to show
LIVE = "#78DCFF"         # the strip marker when the line came off the wire

# Artwork tones. Kept deliberately narrow: earth, a mid silhouette, a deep
# shadow and one water blue. The theatre accent is the only colour that
# changes, which is what makes 23 scenes read as one hand.
EARTH = "#3A362B"
BODY = "#8A9080"
DEEP = "#4E5448"
WATER = "#14323E"
NIGHT = "#10161C"

# --------------------------------------------------------------- theatres
# code -> [chip text, accent]. Ten hues, chosen to stay separate through
# RGB565: bronze, gold, steel, alpine green, desert orange, teal, pale sky,
# violet, rose, silver.
THEATRE = {
    "ORIGINS": ["ROAD TO WAR", "#C0873C"],
    "WEST": ["WESTERN FRONT", "#D8B33A"],
    "EAST": ["EASTERN FRONT", "#6FA3E0"],
    "SOUTH": ["ITALY & BALKANS", "#4FC08A"],
    "MIDEAST": ["OTTOMAN FRONTS", "#E8873C"],
    "SEA": ["WAR AT SEA", "#2FB6C8"],
    "AIR": ["WAR IN THE AIR", "#9CC8F5"],
    "GLOBAL": ["BEYOND EUROPE", "#B98CE8"],
    "HOME": ["HOME FRONT", "#E0736E"],
    "END": ["ARMISTICE & AFTER", "#C9D0DC"],
}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

# ------------------------------------------------------------------- layout
SAFE_L = 10              # the scroll safe zone; the rail owns x0..1
SAFE_R = 181
ABX = 10                 # art box, page 2
ABY = 9
ABW = 52
ABH = 23
COLX = 68                # prose column, page 2
COLW = 114

# ============================================================== the artwork
# Every scene is handed the same box (x, y, 52, 23) and the theatre accent,
# and must not draw outside it. Offsets are written as x + n / y + n with
# n < 52 and n < 23 so that stays checkable by eye.

def art_trench(c, x, y, acc):
    """A trench in section: wire, parapet, firestep, duckboards."""
    c.rect(x, y + 9, x + 51, y + 22, fill = EARTH)
    # wire on three pickets, sagging between them
    c.vline(x + 4, y + 2, 7, DEEP)
    c.vline(x + 20, y + 1, 8, DEEP)
    c.vline(x + 36, y + 2, 7, DEEP)
    c.line(x + 4, y + 4, x + 20, y + 3, DEEP)
    c.line(x + 20, y + 3, x + 36, y + 5, DEEP)
    c.line(x + 4, y + 7, x + 20, y + 6, DEEP)
    c.line(x + 20, y + 6, x + 36, y + 8, DEEP)
    c.pixel(x + 12, y + 3, acc)
    c.pixel(x + 28, y + 4, acc)
    c.pixel(x + 44, y + 6, acc)
    # the void of the trench itself, cut out of the earth
    c.rect(x + 12, y + 11, x + 33, y + 22, fill = "black")
    # sandbags on the parapet, staggered so the lip is not a straight edge
    c.round_rect(x + 10, y + 8, x + 15, y + 11, 1, fill = DEEP)
    c.round_rect(x + 16, y + 7, x + 21, y + 10, 1, fill = DEEP)
    c.round_rect(x + 22, y + 8, x + 27, y + 11, 1, fill = DEEP)
    c.round_rect(x + 28, y + 7, x + 33, y + 10, 1, fill = DEEP)
    c.hline(x + 16, y + 6, 6, acc)
    c.hline(x + 28, y + 6, 6, acc)
    # duckboards
    c.hline(x + 13, y + 21, 20, DEEP)
    c.pixel(x + 16, y + 22, DEEP)
    c.pixel(x + 22, y + 22, DEEP)
    c.pixel(x + 28, y + 22, DEEP)
    # one man on the firestep
    c.fill_circle(x + 24, y + 14, 2, BODY)
    c.rect(x + 21, y + 16, x + 27, y + 21, fill = BODY)
    c.line(x + 27, y + 15, x + 33, y + 11, DEEP)

def art_gun(c, x, y, acc):
    """A field gun, breech left, barrel up and right."""
    c.rect(x, y + 18, x + 51, y + 22, fill = EARTH)
    # trail
    c.line(x + 16, y + 16, x + 3, y + 19, BODY)
    c.line(x + 16, y + 17, x + 4, y + 20, BODY)
    # wheel
    c.fill_circle(x + 18, y + 14, 5, DEEP)
    c.circle(x + 18, y + 14, 5, BODY)
    c.line(x + 13, y + 14, x + 23, y + 14, BODY)
    c.line(x + 18, y + 9, x + 18, y + 19, BODY)
    # shield
    c.rect(x + 20, y + 7, x + 23, y + 16, fill = DEEP)
    # barrel, two rules thick, climbing to the right
    c.line(x + 22, y + 11, x + 45, y + 3, BODY)
    c.line(x + 22, y + 13, x + 45, y + 5, BODY)
    c.line(x + 45, y + 3, x + 45, y + 5, BODY)
    # muzzle
    c.pixel(x + 47, y + 3, acc)
    c.pixel(x + 48, y + 2, acc)
    c.pixel(x + 47, y + 5, acc)

def art_tank(c, x, y, acc):
    """A Mark I in profile - the rhomboid is the whole silhouette."""
    c.rect(x, y + 19, x + 51, y + 22, fill = EARTH)
    c.rect(x + 12, y + 6, x + 38, y + 18, fill = DEEP)
    c.fill_triangle(x + 4, y + 14, x + 12, y + 6, x + 12, y + 18, DEEP)
    c.fill_triangle(x + 38, y + 6, x + 47, y + 13, x + 38, y + 18, DEEP)
    # track, drawn as links so it does not read as a plain outline
    c.line(x + 12, y + 5, x + 38, y + 5, BODY)
    c.line(x + 4, y + 14, x + 12, y + 5, BODY)
    c.line(x + 38, y + 5, x + 47, y + 13, BODY)
    c.line(x + 4, y + 15, x + 12, y + 19, BODY)
    c.line(x + 12, y + 19, x + 38, y + 19, BODY)
    c.line(x + 38, y + 19, x + 47, y + 14, BODY)
    c.pixel(x + 18, y + 5, acc)
    c.pixel(x + 26, y + 5, acc)
    c.pixel(x + 34, y + 5, acc)
    c.pixel(x + 22, y + 19, acc)
    c.pixel(x + 32, y + 19, acc)
    # sponson and its gun
    c.rect(x + 20, y + 11, x + 30, y + 17, fill = EARTH)
    c.hline(x + 30, y + 13, 8, BODY)

def art_plane(c, x, y, acc):
    """A biplane, nose left. Wings, struts, roundel, blurred propeller."""
    c.rect(x + 8, y + 9, x + 40, y + 12, fill = DEEP)
    c.fill_triangle(x + 4, y + 10, x + 8, y + 8, x + 8, y + 13, DEEP)
    # upper and lower wing
    c.rect(x + 10, y + 4, x + 38, y + 5, fill = BODY)
    c.rect(x + 12, y + 15, x + 36, y + 16, fill = BODY)
    # struts
    c.vline(x + 14, y + 5, 11, DEEP)
    c.vline(x + 22, y + 5, 11, DEEP)
    c.vline(x + 30, y + 5, 11, DEEP)
    # tail
    c.fill_triangle(x + 40, y + 3, x + 47, y + 11, x + 40, y + 11, DEEP)
    c.rect(x + 40, y + 11, x + 48, y + 12, fill = BODY)
    # propeller disc and hub
    c.vline(x + 2, y + 3, 16, acc)
    c.pixel(x + 3, y + 10, acc)
    # roundel
    c.fill_circle(x + 30, y + 10, 1, acc)

def art_zepp(c, x, y, acc):
    """An airship over rooftops, held in two searchlight beams."""
    c.round_rect(x + 5, y + 2, x + 45, y + 9, 3, fill = DEEP)
    c.round_rect(x + 5, y + 2, x + 45, y + 9, 3, outline = BODY)
    c.hline(x + 10, y + 5, 30, BODY)
    # tail fins
    c.fill_triangle(x + 45, y + 1, x + 50, y + 5, x + 45, y + 5, BODY)
    c.fill_triangle(x + 45, y + 10, x + 50, y + 6, x + 45, y + 6, BODY)
    # gondolas
    c.rect(x + 14, y + 10, x + 18, y + 12, fill = BODY)
    c.rect(x + 30, y + 10, x + 34, y + 12, fill = BODY)
    # searchlights from the ground
    c.line(x + 3, y + 22, x + 16, y + 11, acc)
    c.line(x + 48, y + 22, x + 36, y + 11, acc)
    # rooftops
    c.rect(x, y + 17, x + 51, y + 22, fill = NIGHT)
    c.rect(x + 2, y + 18, x + 9, y + 22, fill = EARTH)
    c.rect(x + 12, y + 16, x + 18, y + 22, fill = EARTH)
    c.fill_triangle(x + 21, y + 13, x + 25, y + 18, x + 17, y + 18, EARTH)
    c.rect(x + 27, y + 18, x + 35, y + 22, fill = EARTH)
    c.rect(x + 38, y + 17, x + 46, y + 22, fill = EARTH)
    c.pixel(x + 14, y + 19, acc)
    c.pixel(x + 30, y + 20, acc)

def art_ship(c, x, y, acc):
    """A dreadnought: turrets fore and aft, two funnels, a tripod mast."""
    c.rect(x, y + 17, x + 51, y + 22, fill = WATER)
    c.hline(x, y + 17, 52, "#245868")
    # hull
    c.rect(x + 3, y + 13, x + 47, y + 16, fill = DEEP)
    c.fill_triangle(x + 47, y + 12, x + 51, y + 16, x + 47, y + 16, DEEP)
    c.hline(x + 3, y + 13, 45, BODY)
    # turrets, barrels level
    c.rect(x + 8, y + 11, x + 14, y + 13, fill = BODY)
    c.hline(x + 2, y + 11, 7, BODY)
    c.rect(x + 34, y + 11, x + 40, y + 13, fill = BODY)
    c.hline(x + 40, y + 11, 7, BODY)
    # bridge and mast
    c.rect(x + 18, y + 8, x + 24, y + 13, fill = BODY)
    c.vline(x + 21, y + 2, 6, BODY)
    c.hline(x + 19, y + 4, 5, BODY)
    # funnels, with smoke trailing astern
    c.rect(x + 26, y + 8, x + 29, y + 13, fill = BODY)
    c.rect(x + 31, y + 8, x + 34, y + 13, fill = BODY)
    c.pixel(x + 27, y + 6, FAINT)
    c.pixel(x + 24, y + 4, FAINT)
    c.pixel(x + 32, y + 6, FAINT)
    c.pixel(x + 29, y + 3, FAINT)
    # bow wave
    c.pixel(x + 49, y + 18, acc)
    c.pixel(x + 46, y + 19, acc)
    c.pixel(x + 5, y + 18, acc)

def art_uboat(c, x, y, acc):
    """A submarine on the surface, periscope up."""
    c.rect(x, y + 15, x + 51, y + 22, fill = WATER)
    c.hline(x, y + 15, 52, "#245868")
    c.round_rect(x + 5, y + 12, x + 46, y + 16, 2, fill = DEEP)
    c.hline(x + 7, y + 12, 38, BODY)
    # conning tower
    c.round_rect(x + 22, y + 6, x + 31, y + 12, 2, fill = DEEP)
    c.hline(x + 24, y + 6, 6, BODY)
    # periscope
    c.vline(x + 28, y + 1, 5, acc)
    c.hline(x + 28, y + 1, 3, acc)
    # deck gun
    c.line(x + 13, y + 11, x + 18, y + 8, BODY)
    c.pixel(x + 12, y + 11, BODY)
    # wake
    c.pixel(x + 3, y + 16, acc)
    c.pixel(x + 48, y + 17, acc)
    c.pixel(x + 44, y + 18, acc)

def art_convoy(c, x, y, acc):
    """Merchantmen in line, an escort ahead of them."""
    c.rect(x, y + 14, x + 51, y + 22, fill = WATER)
    c.hline(x, y + 14, 52, "#245868")
    # three merchantmen, receding
    c.rect(x + 4, y + 10, x + 17, y + 13, fill = DEEP)
    c.rect(x + 9, y + 6, x + 12, y + 10, fill = BODY)
    c.vline(x + 6, y + 6, 4, BODY)
    c.rect(x + 21, y + 11, x + 31, y + 13, fill = DEEP)
    c.rect(x + 25, y + 8, x + 27, y + 11, fill = BODY)
    c.rect(x + 35, y + 12, x + 42, y + 13, fill = DEEP)
    c.rect(x + 38, y + 10, x + 39, y + 12, fill = BODY)
    # escort, small and out in front
    c.rect(x + 45, y + 12, x + 50, y + 13, fill = acc)
    c.pixel(x + 47, y + 11, acc)
    # sea marks
    c.pixel(x + 3, y + 17, "#245868")
    c.pixel(x + 19, y + 19, "#245868")
    c.pixel(x + 33, y + 17, "#245868")
    c.pixel(x + 44, y + 20, "#245868")

def art_boats(c, x, y, acc):
    """Open boats pulling for a beach under a headland."""
    c.rect(x, y, x + 51, y + 13, fill = WATER)
    c.rect(x, y + 14, x + 51, y + 22, fill = "#3A3426")
    c.hline(x, y + 13, 52, "#245868")
    # headland on the right
    c.fill_triangle(x + 38, y + 13, x + 51, y + 1, x + 51, y + 13, NIGHT)
    # three boats, each a shallow hull with men in it
    c.fill_triangle(x + 3, y + 8, x + 15, y + 8, x + 9, y + 11, DEEP)
    c.pixel(x + 6, y + 7, BODY)
    c.pixel(x + 9, y + 6, BODY)
    c.pixel(x + 12, y + 7, BODY)
    c.fill_triangle(x + 18, y + 10, x + 32, y + 10, x + 25, y + 13, DEEP)
    c.pixel(x + 21, y + 9, BODY)
    c.pixel(x + 25, y + 8, BODY)
    c.pixel(x + 29, y + 9, BODY)
    c.fill_triangle(x + 12, y + 15, x + 28, y + 15, x + 20, y + 18, acc)
    c.pixel(x + 16, y + 14, BODY)
    c.pixel(x + 20, y + 13, BODY)
    c.pixel(x + 24, y + 14, BODY)

# The front line as an x offset per row, hand-plotted so it has the kinks a
# real front has rather than the regularity of a computed zigzag.
MAP_FRONT = [27, 26, 25, 24, 26, 28, 27, 26, 25, 27, 29, 28,
             27, 26, 28, 30, 29, 28, 27, 26, 28, 27, 27]

def art_map(c, x, y, acc):
    """A front line on a map, with the ground either side of it shaded.

    The first cut drew the line alone on land filled #10160F, which is black
    to within a couple of values - so a thin diagonal sitting in a 52x23 black
    box read as an empty box rather than as a map, and it was the only scene
    of the 23 that did. Shading the far side darker than the near side is what
    makes the line read as a front between two armies instead of a squiggle."""
    c.rect(x, y, x + 51, y + 22, fill = "#1E2A1C")
    for r in range(23):
        fx = MAP_FRONT[r]
        c.hline(x + fx, y + r, 52 - fx, "#0E1611")
        c.pixel(x + fx, y + r, acc)
    # rivers on the near side
    c.line(x + 6, y + 1, x + 12, y + 9, "#2A5A72")
    c.line(x + 12, y + 9, x + 8, y + 21, "#2A5A72")
    c.line(x + 41, y + 3, x + 37, y + 12, "#2A5A72")
    # towns, one either side of the line
    c.rect(x + 8, y + 4, x + 9, y + 5, fill = INK)
    c.rect(x + 42, y + 18, x + 43, y + 19, fill = INK)
    c.rect(x + 16, y + 18, x + 17, y + 19, fill = DIM)
    # the thrust, reaching the line
    c.hline(x + 15, y + 11, 8, BODY)
    c.hline(x + 15, y + 12, 8, BODY)
    c.fill_triangle(x + 28, y + 11, x + 22, y + 8, x + 22, y + 15, BODY)

def art_mountain(c, x, y, acc):
    """Alpine peaks with snow, a valley floor beneath them."""
    c.fill_triangle(x + 1, y + 22, x + 15, y + 5, x + 29, y + 22, DEEP)
    c.fill_triangle(x + 22, y + 22, x + 36, y + 1, x + 50, y + 22, EARTH)
    c.fill_triangle(x + 36, y + 22, x + 46, y + 9, x + 51, y + 22, DEEP)
    # snow caps
    c.fill_triangle(x + 11, y + 10, x + 15, y + 5, x + 19, y + 10, INK)
    c.fill_triangle(x + 31, y + 7, x + 36, y + 1, x + 41, y + 7, INK)
    # the valley
    c.rect(x, y + 20, x + 51, y + 22, fill = NIGHT)
    c.hline(x, y + 20, 52, acc)
    # a position on the ridge
    c.pixel(x + 24, y + 13, acc)
    c.pixel(x + 26, y + 14, acc)

def art_desert(c, x, y, acc):
    """Dunes, a palm, and a low sun."""
    c.fill_circle(x + 42, y + 5, 4, acc)
    # Both dunes are clamped to the box. They were drawn from x-2 to x+53 so
    # the slopes would run off the edges and read as continuing, which cost
    # two columns of the left safe margin and two of the gutter beside the
    # divider - the renderer clips only at the panel edge, so the overspill
    # landed in the prose column instead of being cut off.
    c.fill_triangle(x, y + 22, x + 16, y + 12, x + 34, y + 22, EARTH)
    c.fill_triangle(x + 22, y + 22, x + 38, y + 15, x + 51, y + 22, DEEP)
    c.rect(x, y + 21, x + 51, y + 22, fill = EARTH)
    # palm: a leaning trunk and five fronds
    c.line(x + 11, y + 20, x + 13, y + 8, BODY)
    c.line(x + 12, y + 20, x + 14, y + 8, BODY)
    c.line(x + 13, y + 8, x + 5, y + 4, BODY)
    c.line(x + 13, y + 8, x + 7, y + 11, BODY)
    c.line(x + 13, y + 8, x + 21, y + 4, BODY)
    c.line(x + 13, y + 8, x + 22, y + 10, BODY)
    c.line(x + 13, y + 8, x + 14, y + 2, BODY)

def art_column(c, x, y, acc):
    """A column of people on a road, walking away from the viewer.

    This is the scene the hardest entries use - a retreat, a deportation, a
    ration queue. It is deliberately the quietest drawing in the set: no
    weapons, no wreckage, just figures and distance."""
    c.rect(x, y + 17, x + 51, y + 22, fill = EARTH)
    c.fill_triangle(x + 2, y + 22, x + 44, y + 9, x + 51, y + 22, "#4A463A")
    # figures, shrinking along the road
    c.fill_circle(x + 8, y + 13, 1, BODY)
    c.rect(x + 7, y + 15, x + 9, y + 21, fill = BODY)
    c.fill_circle(x + 16, y + 13, 1, DEEP)
    c.rect(x + 15, y + 15, x + 17, y + 20, fill = DEEP)
    c.fill_circle(x + 24, y + 12, 1, BODY)
    c.rect(x + 23, y + 14, x + 25, y + 19, fill = BODY)
    c.pixel(x + 31, y + 12, DEEP)
    c.rect(x + 30, y + 13, x + 31, y + 17, fill = DEEP)
    c.pixel(x + 36, y + 12, FAINT)
    c.rect(x + 36, y + 13, x + 36, y + 16, fill = FAINT)
    c.pixel(x + 40, y + 11, FAINT)
    c.pixel(x + 40, y + 12, FAINT)
    c.pixel(x + 40, y + 13, FAINT)
    c.pixel(x + 43, y + 11, FAINT)
    c.pixel(x + 43, y + 12, FAINT)
    # a thin horizon, lit
    c.hline(x + 40, y + 9, 11, acc)

def art_factory(c, x, y, acc):
    """A munitions works: saw-tooth roof, lit windows, two chimneys."""
    c.rect(x, y + 20, x + 51, y + 22, fill = EARTH)
    c.rect(x + 2, y + 11, x + 32, y + 20, fill = DEEP)
    # saw-tooth roof
    c.fill_triangle(x + 2, y + 11, x + 8, y + 6, x + 8, y + 11, BODY)
    c.fill_triangle(x + 12, y + 11, x + 18, y + 6, x + 18, y + 11, BODY)
    c.fill_triangle(x + 22, y + 11, x + 28, y + 6, x + 28, y + 11, BODY)
    # windows, lit on the night shift
    c.rect(x + 5, y + 14, x + 7, y + 16, fill = acc)
    c.rect(x + 11, y + 14, x + 13, y + 16, fill = acc)
    c.rect(x + 17, y + 14, x + 19, y + 16, fill = acc)
    c.rect(x + 23, y + 14, x + 25, y + 16, fill = acc)
    c.rect(x + 8, y + 18, x + 10, y + 19, fill = acc)
    c.rect(x + 20, y + 18, x + 22, y + 19, fill = acc)
    # chimneys and their smoke
    c.rect(x + 36, y + 2, x + 39, y + 20, fill = BODY)
    c.rect(x + 44, y + 7, x + 46, y + 20, fill = DEEP)
    c.pixel(x + 35, y + 1, FAINT)
    c.pixel(x + 32, y + 0, FAINT)
    c.pixel(x + 43, y + 5, FAINT)
    c.pixel(x + 41, y + 3, FAINT)

def art_train(c, x, y, acc):
    """A locomotive and one carriage - mobilisation ran on timetables."""
    # track
    c.hline(x, y + 20, 52, DEEP)
    c.hline(x, y + 22, 52, EARTH)
    c.vline(x + 4, y + 21, 1, DEEP)
    c.vline(x + 14, y + 21, 1, DEEP)
    c.vline(x + 24, y + 21, 1, DEEP)
    c.vline(x + 34, y + 21, 1, DEEP)
    c.vline(x + 44, y + 21, 1, DEEP)
    # boiler, cab, chimney
    c.round_rect(x + 2, y + 10, x + 22, y + 17, 3, fill = DEEP)
    c.rect(x + 22, y + 6, x + 31, y + 17, fill = DEEP)
    c.rect(x + 23, y + 8, x + 26, y + 11, fill = acc)
    c.rect(x + 4, y + 5, x + 8, y + 10, fill = BODY)
    c.hline(x + 3, y + 5, 7, BODY)
    # wheels
    c.fill_circle(x + 7, y + 18, 2, BODY)
    c.fill_circle(x + 15, y + 18, 2, BODY)
    c.fill_circle(x + 27, y + 18, 2, BODY)
    # carriage
    c.rect(x + 34, y + 9, x + 51, y + 17, fill = DEEP)
    c.rect(x + 36, y + 11, x + 38, y + 13, fill = acc)
    c.rect(x + 41, y + 11, x + 43, y + 13, fill = acc)
    c.rect(x + 46, y + 11, x + 48, y + 13, fill = acc)
    c.fill_circle(x + 38, y + 18, 2, BODY)
    c.fill_circle(x + 47, y + 18, 2, BODY)
    # steam
    c.pixel(x + 3, y + 3, FAINT)
    c.pixel(x + 1, y + 1, FAINT)

TICKS = [[0, -8], [4, -7], [7, -4], [8, 0], [7, 4], [4, 7],
         [0, 8], [-4, 7], [-7, 4], [-8, 0], [-7, -4], [-4, -7]]

def art_clock(c, x, y, acc):
    """A clock face at eleven. The hands are the whole point."""
    cx = x + 25
    cy = y + 11
    c.fill_circle(cx, cy, 10, NIGHT)
    c.circle(cx, cy, 10, BODY)
    c.circle(cx, cy, 11, DEEP)
    for t in TICKS:
        c.pixel(cx + t[0], cy + t[1], DEEP)
    c.pixel(cx, cy - 8, acc)
    c.pixel(cx - 4, cy - 7, acc)
    # minute hand straight up, hour hand at eleven
    c.line(cx, cy, cx, cy - 7, INK)
    c.line(cx, cy, cx - 3, cy - 5, acc)
    c.pixel(cx, cy, INK)

def art_ward(c, x, y, acc):
    """A ward of made-up beds. Used for the influenza entries."""
    c.hline(x, y + 21, 52, EARTH)
    c.rect(x, y + 2, x + 51, y + 3, fill = NIGHT)
    # a window on the back wall
    c.rect(x + 20, y + 3, x + 31, y + 9, fill = NIGHT)
    c.rect(x + 20, y + 3, x + 31, y + 9, outline = DEEP)
    c.vline(x + 26, y + 3, 7, DEEP)
    # three beds
    c.rect(x + 1, y + 13, x + 15, y + 17, fill = DEEP)
    c.rect(x + 1, y + 12, x + 5, y + 13, fill = INK)
    c.vline(x + 1, y + 17, 4, BODY)
    c.vline(x + 15, y + 17, 4, BODY)
    c.rect(x + 19, y + 13, x + 33, y + 17, fill = DEEP)
    c.rect(x + 19, y + 12, x + 23, y + 13, fill = INK)
    c.vline(x + 19, y + 17, 4, BODY)
    c.vline(x + 33, y + 17, 4, BODY)
    c.rect(x + 37, y + 13, x + 51, y + 17, fill = DEEP)
    c.rect(x + 37, y + 12, x + 41, y + 13, fill = INK)
    c.vline(x + 37, y + 17, 4, BODY)
    c.vline(x + 50, y + 17, 4, BODY)
    c.hline(x + 1, y + 14, 15, acc)
    c.hline(x + 19, y + 14, 15, acc)
    c.hline(x + 37, y + 14, 15, acc)

def art_paper(c, x, y, acc):
    """A signed document with a wax seal - treaties, notes, ultimatums."""
    c.rect(x + 11, y + 2, x + 40, y + 21, fill = "#7C7768")
    c.fill_triangle(x + 34, y + 2, x + 40, y + 2, x + 40, y + 8, "#57533F")
    c.rect(x + 11, y + 2, x + 40, y + 21, outline = DIM)
    # ruled lines of text
    c.hline(x + 14, y + 6, 20, "#3A382F")
    c.hline(x + 14, y + 9, 23, "#3A382F")
    c.hline(x + 14, y + 12, 18, "#3A382F")
    c.hline(x + 14, y + 15, 21, "#3A382F")
    # a signature
    c.line(x + 15, y + 19, x + 19, y + 17, "#26241E")
    c.line(x + 19, y + 17, x + 23, y + 19, "#26241E")
    c.line(x + 23, y + 19, x + 27, y + 17, "#26241E")
    # seal and ribbon
    c.fill_circle(x + 38, y + 18, 3, acc)
    c.line(x + 37, y + 21, x + 36, y + 22, acc)
    c.line(x + 40, y + 21, x + 41, y + 22, acc)

def art_crosses(c, x, y, acc):
    """Rows of grave markers receding. The memorial scenes use this."""
    c.rect(x, y + 17, x + 51, y + 22, fill = EARTH)
    # back row, tiny
    c.pixel(x + 4, y + 11, FAINT)
    c.pixel(x + 11, y + 11, FAINT)
    c.pixel(x + 18, y + 11, FAINT)
    c.pixel(x + 25, y + 11, FAINT)
    c.pixel(x + 32, y + 11, FAINT)
    c.pixel(x + 39, y + 11, FAINT)
    c.pixel(x + 46, y + 11, FAINT)
    # middle row
    c.vline(x + 7, y + 12, 4, DEEP)
    c.hline(x + 6, y + 13, 3, DEEP)
    c.vline(x + 20, y + 12, 4, DEEP)
    c.hline(x + 19, y + 13, 3, DEEP)
    c.vline(x + 33, y + 12, 4, DEEP)
    c.hline(x + 32, y + 13, 3, DEEP)
    c.vline(x + 46, y + 12, 4, DEEP)
    c.hline(x + 45, y + 13, 3, DEEP)
    # front row, full height
    c.vline(x + 5, y + 15, 7, BODY)
    c.hline(x + 3, y + 17, 5, BODY)
    c.vline(x + 17, y + 15, 7, BODY)
    c.hline(x + 15, y + 17, 5, BODY)
    c.vline(x + 29, y + 15, 7, acc)
    c.hline(x + 27, y + 17, 5, acc)
    c.vline(x + 41, y + 15, 7, BODY)
    c.hline(x + 39, y + 17, 5, BODY)

def art_poppy(c, x, y, acc):
    """A poppy. The red is the subject, so it is the one scene that does not
    take its colour from the theatre accent."""
    c.line(x + 26, y + 11, x + 25, y + 22, "#3E5A34")
    c.line(x + 25, y + 16, x + 20, y + 19, "#3E5A34")
    c.line(x + 20, y + 19, x + 18, y + 17, "#3E5A34")
    c.fill_circle(x + 21, y + 7, 5, "#B81C24")
    c.fill_circle(x + 31, y + 7, 5, "#B81C24")
    c.fill_circle(x + 22, y + 13, 5, "#D8232E")
    c.fill_circle(x + 30, y + 13, 5, "#D8232E")
    c.fill_circle(x + 26, y + 9, 5, "#E8333E")
    c.fill_circle(x + 26, y + 10, 2, "#14100C")
    c.pixel(x + 25, y + 9, acc)
    c.pixel(x + 27, y + 11, acc)

def art_city(c, x, y, acc):
    """A street of tall fronts with a spire - the urban scenes."""
    c.rect(x, y + 21, x + 51, y + 22, fill = EARTH)
    c.rect(x + 1, y + 9, x + 11, y + 21, fill = DEEP)
    c.rect(x + 13, y + 5, x + 22, y + 21, fill = NIGHT)
    c.rect(x + 13, y + 5, x + 22, y + 21, outline = DEEP)
    c.rect(x + 31, y + 11, x + 41, y + 21, fill = DEEP)
    c.rect(x + 43, y + 7, x + 51, y + 21, fill = NIGHT)
    c.rect(x + 43, y + 7, x + 51, y + 21, outline = DEEP)
    # the spire
    c.rect(x + 24, y + 12, x + 29, y + 21, fill = DEEP)
    c.fill_triangle(x + 23, y + 12, x + 26, y + 2, x + 30, y + 12, BODY)
    c.pixel(x + 26, y + 1, acc)
    # lit windows
    c.pixel(x + 4, y + 12, acc)
    c.pixel(x + 8, y + 15, acc)
    c.pixel(x + 16, y + 9, acc)
    c.pixel(x + 19, y + 14, acc)
    c.pixel(x + 16, y + 18, acc)
    c.pixel(x + 34, y + 14, acc)
    c.pixel(x + 38, y + 17, acc)
    c.pixel(x + 46, y + 11, acc)
    c.pixel(x + 49, y + 16, acc)

def art_globe(c, x, y, acc):
    """A globe with a meridian and an equator."""
    cx = x + 25
    cy = y + 11
    c.fill_circle(cx, cy, 11, "#15303C")
    c.circle(cx, cy, 11, BODY)
    c.hline(cx - 11, cy, 23, DEEP)
    c.vline(cx, cy - 11, 23, DEEP)
    # two meridian arcs, four segments each
    c.line(cx, cy - 11, cx - 6, cy - 6, DEEP)
    c.line(cx - 6, cy - 6, cx - 6, cy + 6, DEEP)
    c.line(cx - 6, cy + 6, cx, cy + 11, DEEP)
    c.line(cx, cy - 11, cx + 6, cy - 6, DEEP)
    c.line(cx + 6, cy - 6, cx + 6, cy + 6, DEEP)
    c.line(cx + 6, cy + 6, cx, cy + 11, DEEP)
    # land
    c.rect(cx - 8, cy - 6, cx - 4, cy - 3, fill = acc)
    c.rect(cx - 3, cy - 2, cx + 1, cy + 3, fill = acc)
    c.rect(cx + 3, cy - 7, cx + 7, cy - 4, fill = acc)
    c.rect(cx + 2, cy + 5, cx + 6, cy + 7, fill = acc)

def art_mask(c, x, y, acc):
    """A respirator and its canister."""
    c.round_rect(x + 10, y + 3, x + 33, y + 18, 5, fill = DEEP)
    c.round_rect(x + 10, y + 3, x + 33, y + 18, 5, outline = BODY)
    # eyepieces
    c.fill_circle(x + 17, y + 9, 3, NIGHT)
    c.circle(x + 17, y + 9, 3, acc)
    c.fill_circle(x + 26, y + 9, 3, NIGHT)
    c.circle(x + 26, y + 9, 3, acc)
    # straps
    c.line(x + 10, y + 7, x + 2, y + 5, BODY)
    c.line(x + 10, y + 14, x + 2, y + 16, BODY)
    # hose down to the canister
    c.line(x + 22, y + 18, x + 26, y + 21, BODY)
    c.line(x + 26, y + 21, x + 36, y + 21, BODY)
    c.line(x + 22, y + 19, x + 27, y + 22, BODY)
    c.line(x + 27, y + 22, x + 36, y + 22, BODY)
    c.rect(x + 37, y + 15, x + 46, y + 22, fill = DEEP)
    c.rect(x + 37, y + 15, x + 46, y + 22, outline = BODY)
    c.hline(x + 39, y + 18, 6, acc)

# art key -> the function that draws it
ART = {
    "trench": art_trench, "gun": art_gun, "tank": art_tank, "plane": art_plane,
    "zepp": art_zepp, "ship": art_ship, "uboat": art_uboat, "convoy": art_convoy,
    "boats": art_boats, "map": art_map, "mountain": art_mountain,
    "desert": art_desert, "column": art_column, "factory": art_factory,
    "train": art_train, "clock": art_clock, "ward": art_ward, "paper": art_paper,
    "crosses": art_crosses, "poppy": art_poppy, "city": art_city,
    "globe": art_globe, "mask": art_mask,
}

# ================================================================ the roster
# [theatre, year, month, day, TITLE, PLACE, WHAT, WHY, NOTE, art, wiki title]
#
# TITLE is kept to 17 characters or fewer so the hero lands at 10x16 or 9x12
# rather than dropping to 8x10 - 10x16 fits 15 characters across the safe
# zone, 9x12 fits 17. WHAT is written to 58 characters or fewer (three lines
# of 4x7 in a 114px column) and WHY to 62 (two lines across the full width).
# NOTE is the fallback for the bottom strip and has 34 characters.
#
# Dates are the ones the article prose gives, not an infobox field. Where a
# source disagrees the README says so.
ROSTER = [
    # ---- the road to war
    ["ORIGINS", 1882, 5, 20, "TRIPLE ALLIANCE", "VIENNA, AUSTRIA",
     "GERMANY, AUSTRIA-HUNGARY AND ITALY SIGNED A SECRET PACT.",
     "EUROPE BEGAN SORTING ITSELF INTO TWO ARMED CAMPS.",
     "RENEWED UNTIL ITALY LEFT IN 1915", "paper", "Triple_Alliance_(1882)"],
    ["ORIGINS", 1894, 1, 4, "FRANCE AND RUSSIA", "ST PETERSBURG, RUSSIA",
     "A MILITARY CONVENTION BOUND EACH TO HELP THE OTHER.",
     "GERMANY NOW FACED THE RISK OF A WAR ON TWO FRONTS.",
     "SIGNED 1892, IN FORCE 1894", "map", "Franco-Russian_Alliance"],
    ["ORIGINS", 1898, 3, 26, "THE NAVY LAWS", "BERLIN, GERMANY",
     "GERMANY VOTED TO BUILD A BATTLE FLEET TO RIVAL BRITAIN.",
     "A NAVAL RACE BEGAN THAT BRITAIN TOOK AS A DIRECT THREAT.",
     "FOUR MORE NAVY LAWS FOLLOWED", "ship", "German_Naval_Laws"],
    ["ORIGINS", 1904, 4, 8, "ENTENTE CORDIALE", "LONDON, ENGLAND",
     "BRITAIN AND FRANCE SETTLED THEIR COLONIAL QUARRELS.",
     "NOT AN ALLIANCE, BUT THE END OF BRITISH ISOLATION.",
     "RUSSIA JOINED THE ENTENTE IN 1907", "globe", "Entente_Cordiale"],
    ["ORIGINS", 1906, 2, 10, "DREADNOUGHT", "PORTSMOUTH, ENGLAND",
     "A BRITISH BATTLESHIP MADE EVERY OTHER ONE OBSOLETE.",
     "BOTH NAVIES HAD TO START AGAIN, AND THE RACE SPED UP.",
     "BUILT IN A YEAR AND A DAY", "ship", "HMS_Dreadnought_(1906)"],
    ["ORIGINS", 1908, 10, 6, "BOSNIA ANNEXED", "SARAJEVO, BOSNIA",
     "AUSTRIA-HUNGARY FORMALLY TOOK BOSNIA AND HERZEGOVINA.",
     "IT ENRAGED SERBIA AND SET THE BALKANS ON A SHORT FUSE.",
     "RUSSIA BACKED DOWN, AND REARMED", "city", "Bosnian_crisis"],
    ["ORIGINS", 1912, 10, 8, "THE BALKAN WARS", "THE BALKAN PENINSULA",
     "TWO SHORT WARS REDREW THE MAP AND DOUBLED SERBIA.",
     "AUSTRIA-HUNGARY DECIDED SERBIA HAD GROWN TOO STRONG.",
     "MONTENEGRO FIRED THE FIRST SHOT", "map", "Balkan_Wars"],
    ["ORIGINS", 1914, 6, 28, "SARAJEVO", "SARAJEVO, BOSNIA",
     "ARCHDUKE FRANZ FERDINAND AND HIS WIFE WERE SHOT DEAD.",
     "A LOCAL KILLING PULLED SIX GREAT POWERS INTO A WAR.",
     "THE GUNMAN WAS GAVRILO PRINCIP", "city",
     "Assassination_of_Archduke_Franz_Ferdinand"],
    ["ORIGINS", 1914, 7, 23, "THE ULTIMATUM", "BELGRADE, SERBIA",
     "AUSTRIA-HUNGARY GAVE SERBIA 48 HOURS AND TEN DEMANDS.",
     "SERBIA ACCEPTED NEARLY ALL OF IT. IT WAS NOT ENOUGH.",
     "IT WAS WRITTEN TO BE REFUSED", "paper", "July_Crisis"],
    ["ORIGINS", 1914, 7, 28, "WAR DECLARED", "BAD ISCHL, AUSTRIA",
     "AUSTRIA-HUNGARY DECLARED WAR ON SERBIA BY TELEGRAM.",
     "THE ALLIANCE SYSTEM DID THE REST WITHIN EIGHT DAYS.",
     "BELGRADE WAS SHELLED NEXT DAY", "train",
     "Austro-Hungarian_declaration_of_war_on_Serbia"],

    # ---- the Western Front
    ["WEST", 1914, 8, 4, "BELGIUM INVADED", "LIEGE, BELGIUM",
     "GERMAN ARMIES CROSSED A NEUTRAL BORDER AT DAWN.",
     "BRITAIN DECLARED WAR THAT NIGHT OVER BELGIAN NEUTRALITY.",
     "THE FORTS AT LIEGE HELD 11 DAYS", "map",
     "German_invasion_of_Belgium_(1914)"],
    ["WEST", 1914, 8, 23, "MONS", "MONS, BELGIUM",
     "THE BRITISH EXPEDITIONARY FORCE FOUGHT ITS FIRST BATTLE.",
     "RIFLE FIRE SLOWED THE ADVANCE, THEN THE BEF FELL BACK.",
     "IT RETREATED OVER 250 MILES", "trench", "Battle_of_Mons"],
    ["WEST", 1914, 9, 6, "THE MARNE", "RIVER MARNE, FRANCE",
     "FRENCH AND BRITISH ARMIES TURNED AND COUNTERATTACKED.",
     "THE PLAN FOR A SHORT WAR DIED HERE. DIGGING IN BEGAN.",
     "PARIS TAXIS CARRIED TROOPS UP", "map", "First_Battle_of_the_Marne"],
    ["WEST", 1914, 11, 22, "THE LINE IS DRAWN", "FLANDERS TO THE ALPS",
     "AFTER FIRST YPRES THE TRENCHES RAN UNBROKEN TO SWITZERLAND.",
     "NEITHER SIDE COULD OUTFLANK THE OTHER FOR FOUR YEARS.",
     "ABOUT 440 MILES OF FRONT", "trench", "Western_Front_(World_War_I)"],
    ["WEST", 1914, 12, 25, "CHRISTMAS TRUCE", "FLANDERS, BELGIUM",
     "MEN LEFT THE TRENCHES TO MEET, BURY THE DEAD AND TALK.",
     "IT HAPPENED IN PLACES, NOT EVERYWHERE, AND NEVER AGAIN.",
     "BOTH ARMIES BANNED IT AFTER", "trench", "Christmas_truce"],
    ["WEST", 1915, 4, 22, "GAS AT YPRES", "YPRES, BELGIUM",
     "GERMANY RELEASED 168 TONS OF CHLORINE ALONG FOUR MILES.",
     "THE FIRST MASS USE OF POISON GAS. BOTH SIDES SOON USED IT.",
     "GAS KILLED SOME 90,000 IN ALL", "mask", "Second_Battle_of_Ypres"],
    ["WEST", 1916, 2, 21, "VERDUN BEGINS", "VERDUN, FRANCE",
     "A MILLION SHELLS FELL IN THE OPENING BOMBARDMENT.",
     "THE LONGEST BATTLE OF THE WAR. IT RAN 302 DAYS.",
     "ABOUT 300,000 DIED AT VERDUN", "gun", "Battle_of_Verdun"],
    ["WEST", 1916, 7, 1, "THE SOMME BEGINS", "SOMME, FRANCE",
     "BRITISH AND FRENCH ARMIES ATTACKED AFTER A WEEK OF SHELLS.",
     "THE WORST DAY IN THE HISTORY OF THE BRITISH ARMY.",
     "57,470 BRITISH CASUALTIES DAY 1", "gun", "Battle_of_the_Somme"],
    ["WEST", 1916, 9, 15, "TANKS AT FLERS", "FLERS, FRANCE",
     "FORTY-NINE TANKS SET OUT AND THIRTY-TWO REACHED THE LINE.",
     "THE FIRST TANKS IN BATTLE. SLOW, FEW, AND UNRELIABLE.",
     "TOP SPEED WAS ABOUT 4 MPH", "tank", "Battle_of_Flers-Courcelette"],
    ["WEST", 1917, 4, 9, "VIMY RIDGE", "ARRAS, FRANCE",
     "ALL FOUR CANADIAN DIVISIONS ATTACKED TOGETHER AT DAWN.",
     "THEY TOOK A RIDGE THAT HAD HELD SINCE 1914, IN FOUR DAYS.",
     "3,598 CANADIANS DIED THERE", "map", "Battle_of_Vimy_Ridge"],
    ["WEST", 1917, 4, 16, "THE NIVELLE PLAN", "CHEMIN DES DAMES",
     "FRANCE ATTACKED PROMISING A BREAKTHROUGH IN 48 HOURS.",
     "IT FAILED, AND MUTINIES SPREAD THROUGH THE FRENCH ARMY.",
     "HALF THE DIVISIONS AFFECTED", "trench", "Nivelle_offensive"],
    ["WEST", 1917, 7, 31, "PASSCHENDAELE", "YPRES, BELGIUM",
     "THE THIRD BATTLE OF YPRES OPENED, THEN THE RAIN CAME.",
     "SHELLING WRECKED THE DRAINAGE AND THE GROUND TURNED TO MUD.",
     "THE ADVANCE WAS ABOUT 5 MILES", "trench", "Battle_of_Passchendaele"],
    ["WEST", 1917, 11, 20, "CAMBRAI", "CAMBRAI, FRANCE",
     "SOME 400 TANKS ATTACKED WITHOUT A LONG BOMBARDMENT.",
     "IT SHOWED HOW TANKS, GUNS AND INFANTRY COULD WORK TOGETHER.",
     "CHURCH BELLS RANG IN LONDON", "tank", "Battle_of_Cambrai_(1917)"],
    ["WEST", 1918, 3, 21, "OPERATION MICHAEL", "ST QUENTIN, FRANCE",
     "GERMANY ATTACKED WITH 74 DIVISIONS AND STORMTROOP TACTICS.",
     "THE LINE MOVED 40 MILES. IT WAS THE LAST GERMAN CHANCE.",
     "6,600 GUNS FIRED IN FIVE HOURS", "trench", "Operation_Michael"],
    ["WEST", 1918, 8, 8, "AMIENS", "AMIENS, FRANCE",
     "TANKS, AIRCRAFT AND ARTILLERY OPENED THE ALLIED ADVANCE.",
     "LUDENDORFF CALLED IT THE BLACK DAY OF THE GERMAN ARMY.",
     "THE HUNDRED DAYS BEGAN HERE", "tank", "Battle_of_Amiens_(1918)"],
    ["WEST", 1918, 9, 26, "MEUSE-ARGONNE", "ARGONNE, FRANCE",
     "1.2 MILLION AMERICAN TROOPS ATTACKED ON A 24 MILE FRONT.",
     "THE LARGEST BATTLE IN AMERICAN HISTORY, AND THE LAST.",
     "26,277 AMERICANS DIED THERE", "map", "Meuse-Argonne_offensive"],

    # ---- the Eastern Front
    ["EAST", 1914, 8, 26, "TANNENBERG", "EAST PRUSSIA",
     "GERMANY ENCIRCLED AND DESTROYED THE RUSSIAN SECOND ARMY.",
     "RUSSIA LOST AN ARMY IN FOUR DAYS AND NEVER TOOK PRUSSIA.",
     "ABOUT 92,000 TAKEN PRISONER", "map", "Battle_of_Tannenberg"],
    ["EAST", 1915, 5, 2, "GORLICE-TARNOW", "GALICIA, POLAND",
     "A GERMAN AND AUSTRIAN BLOW BROKE THE RUSSIAN LINE.",
     "RUSSIA WAS DRIVEN BACK 300 MILES IN THE GREAT RETREAT.",
     "700 GUNS ON A 26 MILE FRONT", "gun",
     "Gorlice%E2%80%93Tarn%C3%B3w_offensive"],
    ["EAST", 1915, 8, 5, "WARSAW FALLS", "WARSAW, POLAND",
     "GERMAN TROOPS ENTERED THE CITY AS RUSSIA PULLED EAST.",
     "RUSSIAN POLAND WAS LOST AND THE TSAR TOOK PERSONAL COMMAND.",
     "MILLIONS BECAME REFUGEES", "column", "Great_Retreat_(Russian)"],
    ["EAST", 1916, 6, 4, "THE BRUSILOV PUSH", "GALICIA, UKRAINE",
     "SHORT ACCURATE SHELLING AND WIDE ATTACKS BROKE THE LINE.",
     "THE MOST SUCCESSFUL RUSSIAN OFFENSIVE OF THE WAR.",
     "AUSTRIA-HUNGARY NEVER RECOVERED", "map", "Brusilov_offensive"],
    ["EAST", 1916, 8, 27, "ROMANIA ENTERS", "BUCHAREST, ROMANIA",
     "ROMANIA JOINED THE ALLIES AND INVADED TRANSYLVANIA.",
     "WITHIN FOUR MONTHS ITS CAPITAL AND OILFIELDS WERE LOST.",
     "BUCHAREST FELL ON 6 DECEMBER", "map", "Romania_during_World_War_I"],
    ["EAST", 1917, 3, 8, "REVOLUTION", "PETROGRAD, RUSSIA",
     "BREAD QUEUES AND STRIKES BECAME A RISING IN FIVE DAYS.",
     "THE TSAR ABDICATED ON 15 MARCH, ENDING 300 YEARS OF RULE.",
     "IT BEGAN ON WOMENS DAY", "city", "February_Revolution"],
    ["EAST", 1917, 11, 7, "THE BOLSHEVIKS", "PETROGRAD, RUSSIA",
     "LENINS PARTY SEIZED POWER PROMISING PEACE AND BREAD.",
     "RUSSIA LEFT THE WAR, FREEING GERMAN DIVISIONS FOR THE WEST.",
     "OLD CALENDAR CALLED IT OCTOBER", "city", "October_Revolution"],
    ["EAST", 1918, 3, 3, "BREST-LITOVSK", "BREST, BELARUS",
     "RUSSIA SIGNED AWAY POLAND, THE BALTIC AND UKRAINE.",
     "IT COST RUSSIA A THIRD OF ITS PEOPLE AND MOST OF ITS COAL.",
     "VOIDED BY THE ARMISTICE", "paper", "Treaty_of_Brest-Litovsk"],

    # ---- Italy and the Balkans
    ["SOUTH", 1914, 8, 12, "SERBIA INVADED", "DRINA RIVER, SERBIA",
     "AUSTRIA-HUNGARY CROSSED THE DRINA IN ITS FIRST ATTACK.",
     "SERBIA THREW BACK THREE INVASIONS IN 1914, AT HEAVY COST.",
     "SERBIA HAD 4.5 MILLION PEOPLE", "map",
     "Serbian_campaign"],
    ["SOUTH", 1914, 12, 15, "KOLUBARA", "BELGRADE, SERBIA",
     "SERBIAN TROOPS RETOOK BELGRADE AFTER A COUNTERATTACK.",
     "AUSTRIA-HUNGARY WAS DRIVEN OUT OF SERBIA COMPLETELY.",
     "THE THIRD INVASION OF 1914 FAILED", "map", "Battle_of_Kolubara"],
    ["SOUTH", 1915, 5, 23, "ITALY JOINS", "ROME, ITALY",
     "ITALY LEFT THE TRIPLE ALLIANCE AND ATTACKED AUSTRIA.",
     "A SECOND ALPINE FRONT OPENED, SOME 400 MILES LONG.",
     "PROMISED LAND BY A SECRET PACT", "mountain",
     "Italian_front_(World_War_I)"],
    ["SOUTH", 1915, 6, 23, "THE ISONZO", "ISONZO, SLOVENIA",
     "ITALY ATTACKED ALONG ONE RIVER FOR THE FIRST TIME.",
     "ELEVEN MORE BATTLES FOLLOWED ON THE SAME GROUND.",
     "TWELVE ISONZO BATTLES IN ALL", "mountain", "Battles_of_the_Isonzo"],
    ["SOUTH", 1915, 11, 25, "THE GREAT RETREAT", "THROUGH ALBANIA",
     "THE SERBIAN ARMY AND CIVILIANS WALKED OVER THE MOUNTAINS.",
     "TENS OF THOUSANDS DIED CROSSING THE WINTER MOUNTAINS.",
     "THEY WERE EVACUATED TO CORFU", "column",
     "Great_Retreat_(Serbia)"],
    ["SOUTH", 1917, 10, 24, "CAPORETTO", "KOBARID, SLOVENIA",
     "GAS AND STORMTROOPS BROKE THE ITALIAN LINE IN A DAY.",
     "ITALY FELL BACK 90 MILES TO THE PIAVE AND HELD THERE.",
     "265,000 ITALIANS TAKEN PRISONER", "mountain", "Battle_of_Caporetto"],
    ["SOUTH", 1918, 6, 15, "THE PIAVE", "PIAVE RIVER, ITALY",
     "AUSTRIA-HUNGARY ATTACKED ACROSS THE RIVER AND FAILED.",
     "ITS LAST OFFENSIVE. THE ARMY BEGAN TO COME APART.",
     "THE RIVER ROSE AND CUT BRIDGES", "mountain",
     "Battle_of_the_Piave_River"],
    ["SOUTH", 1918, 9, 15, "VARDAR", "MACEDONIAN FRONT",
     "ALLIED ARMIES BROKE THE BULGARIAN LINE AT DOBRO POLE.",
     "BULGARIA ASKED FOR TERMS TWO WEEKS LATER, THE FIRST TO GO.",
     "THE SALONIKA FRONT HELD 3 YEARS", "map", "Vardar_offensive"],
    ["SOUTH", 1918, 10, 24, "VITTORIO VENETO", "VENETO, ITALY",
     "ITALY ATTACKED ON THE ANNIVERSARY OF CAPORETTO.",
     "AUSTRIA-HUNGARY ASKED FOR AN ARMISTICE WITHIN TEN DAYS.",
     "THE EMPIRE DISSOLVED AS IT FELL", "mountain",
     "Battle_of_Vittorio_Veneto"],

    # ---- the Ottoman fronts
    ["MIDEAST", 1914, 10, 29, "THE OTTOMANS JOIN", "THE BLACK SEA",
     "OTTOMAN AND GERMAN SHIPS SHELLED RUSSIAN PORTS.",
     "THE WAR SPREAD TO THE CAUCASUS, SINAI AND MESOPOTAMIA.",
     "TWO GERMAN SHIPS FLEW A NEW FLAG", "ship",
     "Ottoman_entry_into_World_War_I"],
    ["MIDEAST", 1914, 12, 22, "SARIKAMISH", "CAUCASUS MOUNTAINS",
     "AN OTTOMAN ARMY ATTACKED RUSSIA IN DEEP WINTER SNOW.",
     "MOST OF THE ARMY WAS LOST, MANY OF THEM TO THE COLD.",
     "FOUGHT AT AROUND 2,000 METRES", "mountain", "Battle_of_Sarikamish"],
    ["MIDEAST", 1915, 2, 19, "THE DARDANELLES", "DARDANELLES, TURKEY",
     "ALLIED BATTLESHIPS TRIED TO FORCE THE STRAIT ALONE.",
     "MINES SANK THREE SHIPS ON 18 MARCH AND THE FLEET TURNED BACK.",
     "THE NARROWS ARE 1,500 M WIDE", "ship",
     "Naval_operations_in_the_Dardanelles_campaign"],
    ["MIDEAST", 1915, 4, 24, "ARMENIAN GENOCIDE", "THE OTTOMAN EMPIRE",
     "ARMENIAN LEADERS IN CONSTANTINOPLE WERE ARRESTED.",
     "MASS DEPORTATIONS AND KILLINGS FOLLOWED ACROSS THE EMPIRE.",
     "ABOUT 1 MILLION ARMENIANS DIED", "column", "Armenian_genocide"],
    ["MIDEAST", 1915, 4, 25, "GALLIPOLI", "GALLIPOLI, TURKEY",
     "ALLIED TROOPS LANDED ON A NARROW STRIP OF COAST.",
     "EIGHT MONTHS OF STALEMATE ON GROUND A FEW MILES DEEP.",
     "ANZAC DAY MARKS THE LANDING", "boats", "Gallipoli_campaign"],
    ["MIDEAST", 1916, 1, 9, "LEAVING GALLIPOLI", "GALLIPOLI, TURKEY",
     "THE LAST TROOPS SLIPPED AWAY AT NIGHT WITHOUT A SHOT.",
     "THE EVACUATION WAS THE BEST RUN PART OF THE CAMPAIGN.",
     "ABOUT 130,000 DIED IN ALL", "boats", "Gallipoli_campaign"],
    ["MIDEAST", 1916, 4, 29, "THE SIEGE OF KUT", "KUT, IRAQ",
     "A BRITISH INDIAN GARRISON SURRENDERED AFTER 147 DAYS.",
     "THE WORST BRITISH SURRENDER UNTIL SINGAPORE IN 1942.",
     "13,000 MARCHED INTO CAPTIVITY", "desert", "Siege_of_Kut"],
    ["MIDEAST", 1916, 5, 16, "SYKES-PICOT", "LONDON AND PARIS",
     "BRITAIN AND FRANCE SECRETLY DIVIDED OTTOMAN LANDS.",
     "IT CUT ACROSS WHAT BRITAIN HAD PROMISED THE ARABS.",
     "PUBLISHED BY THE BOLSHEVIKS", "paper", "Sykes-Picot_Agreement"],
    ["MIDEAST", 1916, 6, 10, "THE ARAB REVOLT", "MECCA, ARABIA",
     "SHARIF HUSSEIN ROSE AGAINST OTTOMAN RULE IN THE HEJAZ.",
     "ARAB FORCES TIED DOWN OTTOMAN TROOPS ALONG THE RAILWAY.",
     "BRITAIN PROMISED INDEPENDENCE", "desert", "Arab_Revolt"],
    ["MIDEAST", 1917, 11, 2, "THE BALFOUR NOTE", "LONDON, ENGLAND",
     "BRITAIN BACKED A NATIONAL HOME FOR THE JEWISH PEOPLE.",
     "ITS 67 WORDS SHAPED THE MIDDLE EAST FOR A CENTURY.",
     "A LETTER, NOT A TREATY", "paper", "Balfour_Declaration"],
    ["MIDEAST", 1917, 12, 11, "JERUSALEM", "JERUSALEM",
     "ALLENBY ENTERED THE CITY ON FOOT THROUGH THE JAFFA GATE.",
     "FOUR CENTURIES OF OTTOMAN RULE IN PALESTINE ENDED.",
     "HE WALKED IN OUT OF RESPECT", "desert", "Battle_of_Jerusalem"],
    ["MIDEAST", 1918, 9, 19, "MEGIDDO", "PALESTINE",
     "CAVALRY AND AIRCRAFT BROKE THE OTTOMAN LINE IN A DAY.",
     "THE OTTOMAN ARMIES IN PALESTINE AND SYRIA COLLAPSED.",
     "DAMASCUS FELL ON 1 OCTOBER", "desert", "Battle_of_Megiddo_(1918)"],

    # ---- the war at sea
    ["SEA", 1914, 9, 22, "THREE IN ONE HOUR", "OFF THE DUTCH COAST",
     "ONE SUBMARINE SANK THREE BRITISH CRUISERS IN SUCCESSION.",
     "THE ROYAL NAVY LEARNED WHAT A SUBMARINE COULD DO.",
     "1,459 SAILORS DIED THAT DAY", "uboat",
     "Action_of_22_September_1914"],
    ["SEA", 1914, 11, 1, "CORONEL", "OFF CHILE",
     "A GERMAN SQUADRON SANK TWO BRITISH CRUISERS AT DUSK.",
     "BRITAINS FIRST NAVAL DEFEAT IN OVER A CENTURY.",
     "NO SURVIVORS FROM THE TWO SHIPS", "ship", "Battle_of_Coronel"],
    ["SEA", 1914, 11, 2, "THE BLOCKADE", "THE NORTH SEA",
     "BRITAIN DECLARED THE WHOLE NORTH SEA A WAR ZONE.",
     "THE SLOW STRANGLING OF GERMAN FOOD AND RAW MATERIALS.",
     "IT LASTED PAST THE ARMISTICE", "convoy",
     "Blockade_of_Germany_(1914%E2%80%931919)"],
    ["SEA", 1914, 12, 8, "THE FALKLANDS", "THE SOUTH ATLANTIC",
     "TWO BATTLECRUISERS HUNTED DOWN THE GERMAN SQUADRON.",
     "GERMAN SURFACE RAIDING IN DISTANT SEAS WAS FINISHED.",
     "REVENGE FOR CORONEL IN 5 WEEKS", "ship",
     "Battle_of_the_Falkland_Islands"],
    ["SEA", 1915, 5, 7, "LUSITANIA", "OFF KINSALE, IRELAND",
     "A LINER WAS TORPEDOED AND SANK IN EIGHTEEN MINUTES.",
     "1,198 DIED, 128 OF THEM AMERICAN. US OPINION TURNED.",
     "GERMANY CURBED U-BOATS AFTER", "uboat", "RMS_Lusitania"],
    ["SEA", 1916, 5, 31, "JUTLAND", "THE NORTH SEA",
     "250 SHIPS MET IN THE ONLY GREAT FLEET BATTLE OF THE WAR.",
     "BRITAIN LOST MORE SHIPS, BUT KEPT CONTROL OF THE SEA.",
     "8,645 SAILORS DIED IN A DAY", "ship", "Battle_of_Jutland"],
    ["SEA", 1917, 2, 1, "U-BOATS UNLEASHED", "THE ATLANTIC",
     "GERMANY RESUMED SINKING ANY SHIP WITHOUT WARNING.",
     "IT GAMBLED ON STARVING BRITAIN BEFORE AMERICA COULD ACT.",
     "881,000 TONS SUNK IN APRIL", "uboat",
     "Unrestricted_submarine_warfare"],
    ["SEA", 1917, 5, 10, "THE CONVOY SYSTEM", "GIBRALTAR",
     "MERCHANT SHIPS BEGAN SAILING IN ESCORTED GROUPS.",
     "LOSSES FELL SHARPLY AND THE U-BOAT GAMBLE FAILED.",
     "SINKINGS FELL BY TWO THIRDS", "convoy", "Convoys_in_World_War_I"],
    ["SEA", 1918, 4, 23, "ZEEBRUGGE", "ZEEBRUGGE, BELGIUM",
     "THE ROYAL NAVY TRIED TO BLOCK A U-BOAT BASE AT NIGHT.",
     "THE CHANNEL REOPENED IN DAYS, BUT THE RAID LIFTED MORALE.",
     "EIGHT VICTORIA CROSSES", "boats", "Zeebrugge_Raid"],
    ["SEA", 1919, 6, 21, "SCAPA FLOW", "ORKNEY, SCOTLAND",
     "THE INTERNED GERMAN FLEET OPENED ITS OWN SEACOCKS.",
     "52 OF THE 74 SHIPS WENT DOWN RATHER THAN BE HANDED OVER.",
     "THE CREWS WERE STILL ABOARD", "ship",
     "Scuttling_of_the_German_fleet_at_Scapa_Flow"],

    # ---- the war in the air
    ["AIR", 1914, 10, 5, "FIRST AIR VICTORY", "REIMS, FRANCE",
     "A FRENCH CREW SHOT DOWN A GERMAN AIRCRAFT IN THE AIR.",
     "AIRCRAFT STOPPED BEING SCOUTS AND BECAME WEAPONS.",
     "THE GUNNER USED A HOTCHKISS", "plane", "Aviation_in_World_War_I"],
    ["AIR", 1915, 1, 19, "THE FIRST RAID", "NORFOLK, ENGLAND",
     "TWO ZEPPELINS BOMBED GREAT YARMOUTH AND KINGS LYNN.",
     "CIVILIANS AT HOME WERE NOW IN THE FRONT LINE.",
     "FOUR PEOPLE WERE KILLED", "zepp",
     "German_strategic_bombing_during_World_War_I"],
    ["AIR", 1915, 7, 1, "THE FOKKER SCOURGE", "THE WESTERN FRONT",
     "A GUN SYNCHRONISED TO FIRE THROUGH THE PROPELLER ARRIVED.",
     "FOR SIX MONTHS GERMANY OWNED THE SKY OVER THE FRONT.",
     "FOKKER E.I, ONE MACHINE GUN", "plane", "Fokker_scourge"],
    ["AIR", 1917, 4, 1, "BLOODY APRIL", "ARRAS, FRANCE",
     "THE ROYAL FLYING CORPS LOST 245 AIRCRAFT IN A MONTH.",
     "LIFE EXPECTANCY FOR A NEW PILOT WAS MEASURED IN WEEKS.",
     "PILOTS FLEW WITHOUT PARACHUTES", "plane", "Bloody_April"],
    ["AIR", 1917, 6, 13, "THE GOTHA RAIDS", "LONDON, ENGLAND",
     "FOURTEEN BOMBERS ATTACKED LONDON IN BROAD DAYLIGHT.",
     "162 DIED, INCLUDING 18 CHILDREN AT A SCHOOL IN POPLAR.",
     "BRITAIN BUILT AIR DEFENCES", "zepp",
     "German_strategic_bombing_during_World_War_I"],
    ["AIR", 1918, 4, 1, "THE RAF IS BORN", "LONDON, ENGLAND",
     "BRITAIN MERGED ITS ARMY AND NAVY AIR ARMS INTO ONE.",
     "AN AIR FORCE INDEPENDENT OF BOTH ARMY AND NAVY.",
     "FORMED FROM THE RFC AND RNAS", "plane", "Royal_Air_Force"],
    ["AIR", 1918, 4, 21, "THE RED BARON", "SOMME, FRANCE",
     "MANFRED VON RICHTHOFEN WAS SHOT DOWN AND KILLED.",
     "THE HIGHEST SCORING PILOT OF THE WAR, WITH 80 VICTORIES.",
     "HE WAS BURIED WITH HONOURS", "plane", "Manfred_von_Richthofen"],

    # ---- beyond Europe
    ["GLOBAL", 1914, 8, 30, "SAMOA TAKEN", "APIA, SAMOA",
     "A NEW ZEALAND FORCE OCCUPIED GERMAN SAMOA UNOPPOSED.",
     "THE WAR REACHED THE PACIFIC WITHIN FOUR WEEKS.",
     "NOT A SHOT WAS FIRED", "globe", "Occupation_of_German_Samoa"],
    ["GLOBAL", 1914, 9, 30, "INDIA ARRIVES", "MARSEILLE, FRANCE",
     "THE FIRST INDIAN CORPS TROOPS LANDED IN FRANCE.",
     "OVER A MILLION INDIANS SERVED, ON EVERY ALLIED FRONT.",
     "ABOUT 74,000 INDIANS DIED", "train",
     "Indian_Army_during_World_War_I"],
    ["GLOBAL", 1914, 11, 4, "TANGA", "TANGA, TANZANIA",
     "A BRITISH INDIAN LANDING WAS THROWN BACK IN TWO DAYS.",
     "THE EAST AFRICAN CAMPAIGN RAN FOUR YEARS THROUGH BUSH.",
     "BEES ATTACKED BOTH SIDES", "boats", "Battle_of_Tanga"],
    ["GLOBAL", 1914, 11, 7, "TSINGTAO", "QINGDAO, CHINA",
     "JAPANESE AND BRITISH TROOPS TOOK THE GERMAN PORT.",
     "JAPAN ENTERED THE WAR AND KEPT WHAT IT CAPTURED.",
     "THE SIEGE LASTED TEN WEEKS", "ship", "Siege_of_Tsingtao"],
    ["GLOBAL", 1917, 2, 21, "THE SS MENDI", "THE ENGLISH CHANNEL",
     "A TROOPSHIP CARRYING SOUTH AFRICAN LABOURERS SANK.",
     "616 SOUTH AFRICANS DIED, MOST OF THEM BLACK VOLUNTEERS.",
     "REMEMBERED EVERY FEBRUARY", "convoy", "SS_Mendi"],
    ["GLOBAL", 1917, 4, 6, "AMERICA ENTERS", "WASHINGTON, USA",
     "CONGRESS VOTED FOR WAR AFTER U-BOATS AND A TELEGRAM.",
     "FOUR MILLION WERE MOBILISED AND TWO MILLION SENT OVER.",
     "THE SENATE VOTED 82 TO 6", "city",
     "American_entry_into_World_War_I"],
    ["GLOBAL", 1917, 4, 19, "THE LABOUR CORPS", "THE WESTERN FRONT",
     "THE FIRST CHINESE LABOUR CORPS MEN REACHED FRANCE.",
     "140,000 CHINESE WORKERS DUG, CARRIED AND CLEARED GROUND.",
     "ABOUT 2,000 NEVER WENT HOME", "column", "Chinese_Labour_Corps"],
    ["GLOBAL", 1918, 5, 14, "THE 369TH", "ARGONNE, FRANCE",
     "TWO SENTRIES OF A BLACK AMERICAN REGIMENT HELD OFF A RAID.",
     "THE 369TH SPENT 191 DAYS IN THE LINE, MORE THAN ANY US UNIT.",
     "FRANCE DECORATED THE WHOLE UNIT", "column",
     "369th_Infantry_Regiment_(United_States)"],
    ["GLOBAL", 1918, 11, 25, "THE LAST SURRENDER", "ABERCORN, ZAMBIA",
     "A GERMAN FORCE IN AFRICA LAID DOWN ARMS 14 DAYS LATE.",
     "HE HEARD OF IT ON 14 NOVEMBER AND MARCHED IN TO SURRENDER.",
     "IT HAD NEVER BEEN DEFEATED", "globe", "Paul_von_Lettow-Vorbeck"],

    # ---- the home fronts
    ["HOME", 1915, 5, 14, "THE SHELL CRISIS", "LONDON, ENGLAND",
     "A NEWSPAPER BLAMED A SHELL SHORTAGE FOR A FAILED ATTACK.",
     "IT BROUGHT DOWN A GOVERNMENT AND REMADE BRITISH INDUSTRY.",
     "A MINISTRY OF MUNITIONS FOLLOWED", "gun", "Shell_Crisis_of_1915"],
    ["HOME", 1915, 7, 17, "RIGHT TO SERVE", "LONDON, ENGLAND",
     "SOME 30,000 WOMEN MARCHED TO DEMAND WAR WORK.",
     "BY 1918 NEARLY A MILLION WOMEN WORKED IN MUNITIONS.",
     "ORGANISED BY EMMELINE PANKHURST", "factory",
     "Women_in_World_War_I"],
    ["HOME", 1916, 1, 27, "CONSCRIPTION", "LONDON, ENGLAND",
     "A LAW ENDED VOLUNTARY SERVICE FOR SINGLE MEN 18 TO 41.",
     "IT TOOK EFFECT ON 2 MARCH. 16,000 REGISTERED AS OBJECTORS.",
     "THE LAST GREAT POWER TO CONSCRIPT", "paper",
     "Military_Service_Act_1916"],
    ["HOME", 1916, 4, 24, "THE EASTER RISING", "DUBLIN, IRELAND",
     "REPUBLICANS SEIZED BUILDINGS AND PROCLAIMED A REPUBLIC.",
     "SIX DAYS OF FIGHTING AND THE EXECUTIONS CHANGED IRELAND.",
     "ABOUT 485 DIED, MOST CIVILIANS", "city", "Easter_Rising"],
    ["HOME", 1916, 12, 15, "THE TURNIP WINTER", "GERMANY",
     "A FAILED POTATO HARVEST LEFT TURNIPS AS THE STAPLE.",
     "BLOCKADE AND BAD WEATHER TOGETHER BROUGHT REAL HUNGER.",
     "CIVILIAN DEATHS ROSE SHARPLY", "factory", "Turnip_Winter"],
    ["HOME", 1917, 1, 19, "SILVERTOWN", "LONDON, ENGLAND",
     "A TNT FACTORY EXPLODED IN THE EAST END OF LONDON.",
     "73 PEOPLE DIED AND SOME 70,000 HOMES WERE DAMAGED.",
     "THE BLAST WAS HEARD 100 MILES", "factory", "Silvertown_explosion"],
    ["HOME", 1918, 2, 6, "VOTES FOR WOMEN", "LONDON, ENGLAND",
     "BRITAIN GAVE THE VOTE TO WOMEN OVER 30 WITH PROPERTY.",
     "WAR WORK MADE THE OLD ARGUMENTS AGAINST IT IMPOSSIBLE.",
     "8.5 MILLION WOMEN COULD VOTE", "paper",
     "Representation_of_the_People_Act_1918"],
    ["HOME", 1918, 2, 25, "RATIONING", "LONDON, ENGLAND",
     "MEAT, BUTTER AND MARGARINE WENT ON RATION CARDS.",
     "QUEUES ENDED, AND SHARE-ALIKE RATIONING KEPT BRITAIN FED.",
     "NATIONWIDE BY JULY 1918", "column",
     "Rationing_in_the_United_Kingdom"],
    ["HOME", 1918, 3, 4, "THE FIRST CASES", "KANSAS, USA",
     "AN ARMY COOK REPORTED SICK AT CAMP FUNSTON.",
     "ONE OF THE EARLIEST RECORDED CASES OF THE 1918 FLU.",
     "522 WERE ILL WITHIN A WEEK", "ward", "Spanish_flu"],
    ["HOME", 1918, 9, 28, "THE SECOND WAVE", "PHILADELPHIA, USA",
     "A WAR BOND PARADE DREW 200,000 PEOPLE INTO THE STREETS.",
     "THE CITY RECORDED OVER 12,000 DEATHS IN SIX WEEKS.",
     "AT LEAST 50 MILLION DIED", "ward", "Spanish_flu"],

    # ---- the armistice and after
    ["END", 1918, 9, 29, "BULGARIA QUITS", "SALONICA, GREECE",
     "BULGARIA SIGNED AN ARMISTICE AND LEFT THE WAR.",
     "THE FIRST CENTRAL POWER TO FALL. THE OTHERS FOLLOWED FAST.",
     "IT OPENED THE ROAD TO VIENNA", "paper", "Armistice_of_Salonica"],
    ["END", 1918, 10, 30, "MUDROS", "LEMNOS, GREECE",
     "THE OTTOMAN EMPIRE SIGNED AN ARMISTICE ON A WARSHIP.",
     "SIX CENTURIES OF OTTOMAN RULE BEGAN TO BE DIVIDED UP.",
     "THE STRAITS WERE OPENED", "ship", "Armistice_of_Mudros"],
    ["END", 1918, 11, 3, "VILLA GIUSTI", "PADUA, ITALY",
     "AUSTRIA-HUNGARY SIGNED AN ARMISTICE NEAR PADUA.",
     "THE EMPIRE WAS ALREADY BREAKING INTO NEW NATIONS.",
     "IT TOOK EFFECT ON 4 NOVEMBER", "mountain",
     "Armistice_of_Villa_Giusti"],
    ["END", 1918, 11, 9, "THE KAISER GOES", "BERLIN, GERMANY",
     "REVOLUTION SPREAD FROM THE FLEET AND THE KAISER WENT.",
     "GERMANY BECAME A REPUBLIC TWO DAYS BEFORE THE ARMISTICE.",
     "HE LEFT FOR THE NETHERLANDS", "city",
     "German_revolution_of_1918%E2%80%931919"],
    ["END", 1918, 11, 11, "ARMISTICE", "COMPIEGNE, FRANCE",
     "THE GUNS STOPPED AT 11 IN THE MORNING, PARIS TIME.",
     "FOUR YEARS AND THREE MONTHS OF FIGHTING ENDED.",
     "SIGNED AT 5.10 IN A RAIL CAR", "clock",
     "Armistice_of_11_November_1918"],
    ["END", 1919, 1, 18, "THE PEACE TALKS", "PARIS, FRANCE",
     "THIRTY-TWO NATIONS MET TO SETTLE THE SHAPE OF THE WORLD.",
     "THE DEFEATED WERE NOT INVITED TO NEGOTIATE.",
     "IT RAN FOR OVER A YEAR", "city",
     "Paris_Peace_Conference_(1919%E2%80%931920)"],
    ["END", 1919, 6, 28, "VERSAILLES", "VERSAILLES, FRANCE",
     "GERMANY SIGNED, FIVE YEARS TO THE DAY AFTER SARAJEVO.",
     "IT TOOK LAND, ARMS AND MONEY, AND ASSIGNED THE BLAME.",
     "132 BILLION GOLD MARKS", "paper", "Treaty_of_Versailles"],
    ["END", 1920, 1, 10, "THE LEAGUE", "PARIS, FRANCE",
     "THE LEAGUE OF NATIONS CAME INTO BEING THAT DAY.",
     "THE FIRST TRY AT COLLECTIVE SECURITY. THE US STAYED OUT.",
     "IT HAD 42 FOUNDING MEMBERS", "globe", "League_of_Nations"],
    ["END", 1920, 11, 11, "THE UNKNOWN", "WESTMINSTER ABBEY",
     "AN UNIDENTIFIED SOLDIER WAS BURIED AMONG THE KINGS.",
     "A GRAVE FOR EVERY FAMILY THAT HAD NO GRAVE TO VISIT.",
     "FRANCE DID THE SAME THAT DAY", "crosses", "The_Unknown_Warrior"],
    ["END", 1921, 11, 11, "THE POPPY", "LONDON, ENGLAND",
     "THE FIRST POPPY APPEAL RAISED OVER 106,000 POUNDS.",
     "A FLOWER FROM THE BATTLEFIELDS BECAME THE SIGN OF MEMORY.",
     "INSPIRED BY A POEM OF 1915", "poppy", "Remembrance_poppy"],
    ["END", 1923, 7, 24, "LAUSANNE", "SWITZERLAND",
     "A NEW TREATY REPLACED THE ONE TURKEY HAD REFUSED.",
     "IT DREW THE BORDERS OF MODERN TURKEY AND CLOSED THE WAR.",
     "THE LAST TREATY OF THE WAR", "paper", "Treaty_of_Lausanne"],
    ["END", 1927, 7, 24, "THE MENIN GATE", "YPRES, BELGIUM",
     "A MEMORIAL OPENED CARRYING THE NAMES OF THE MISSING.",
     "54,000 MEN WITH NO KNOWN GRAVE. THE LAST POST SOUNDS NIGHTLY.",
     "IT WAS TOO SMALL FOR ALL NAMES", "crosses", "Menin_Gate"],
]

# =================================================================== text
# Every font on this panel is uppercase only and none of them carries an
# apostrophe or a double quote. History prose is full of both, and the live
# Wikipedia line can carry accents on top of that, so everything drawn goes
# through safe() first. Accented letters are folded to ASCII rather than
# dropped, because "ZEPPELIN OVER KOENIGSBERG" is readable and
# "ZEPPELIN OVER KNIGSBERG" is not.
GLYPHS = " !#$%&()*+,-./0123456789:?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Applied after .upper(), so the needles are uppercase. The quote marks are
# folded to nothing rather than to a space, so BRITAIN'S becomes BRITAINS
# rather than BRITAIN S.
FOLD = [
    ["'", ""], ["’", ""], ["‘", ""], ["`", ""],
    ["\"", ""], ["“", ""], ["”", ""],
    ["À", "A"], ["Á", "A"], ["Â", "A"], ["Ã", "A"],
    ["Ä", "A"], ["Å", "A"], ["Æ", "AE"], ["Ç", "C"],
    ["È", "E"], ["É", "E"], ["Ê", "E"], ["Ë", "E"],
    ["Ì", "I"], ["Í", "I"], ["Î", "I"], ["Ï", "I"],
    ["Ð", "D"], ["Ñ", "N"], ["Ò", "O"], ["Ó", "O"],
    ["Ô", "O"], ["Õ", "O"], ["Ö", "O"], ["Ø", "O"],
    ["Ù", "U"], ["Ú", "U"], ["Û", "U"], ["Ü", "U"],
    ["Ý", "Y"], ["Þ", "TH"], ["ß", "SS"],
    ["Ł", "L"], ["Š", "S"], ["Ž", "Z"], ["Ć", "C"],
    ["Č", "C"], ["Đ", "D"], ["Ğ", "G"], ["İ", "I"],
    ["ı", "I"], ["Ş", "S"], ["Œ", "OE"],
    ["–", "-"], ["—", "-"], ["…", ".."], [" ", " "],
]

def safe(s):
    """Uppercase, fold to ASCII, then keep only glyphs the fonts actually
    have. Anything still unknown becomes a space and the spaces collapse, so
    a stray symbol never leaves a hole mid-word."""
    t = str(s).upper()
    for pair in FOLD:
        t = t.replace(pair[0], pair[1])
    out = ""
    for ch in t.elems():
        if GLYPHS.find(ch) >= 0:
            out += ch
        else:
            out += " "
    return " ".join(out.split())

def clip(c, text, font, maxw):
    """Longest prefix that fits. Nothing in the drawing API clips, and
    text_fit shrinks the font and then draws anyway when even its smallest
    option overflows, so every bounded string ends here."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""

def fit(c, text, fonts, maxw):
    """[font, clipped text] for the largest listed font that fits."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    return [pick, clip(c, text, pick, maxw)]

def wrap(c, text, font, maxw, lines):
    """Greedy word wrap to at most `lines` rows of `maxw`. A row that cannot
    hold even one whole word is hard-clipped rather than allowed to run, and
    a block that loses text ends in '..' so the cut reads as deliberate."""
    words = str(text).split(" ")
    out = []
    cur = ""
    for w in words:
        if len(out) >= lines:
            break
        cand = w if cur == "" else cur + " " + w
        if c.text_width(cand, font) <= maxw:
            cur = cand
        else:
            if cur == "":
                out.append(clip(c, w, font, maxw))
                cur = ""
            else:
                out.append(cur)
                cur = w if c.text_width(w, font) <= maxw else clip(c, w, font, maxw)
    if cur != "" and len(out) < lines:
        out.append(cur)
    # did anything fall off the end?
    used = 0
    for ln in out:
        used += len(ln) + 1
    if used < len(str(text)) and len(out) > 0:
        last = out[len(out) - 1]
        out[len(out) - 1] = clip(c, last, font, maxw - c.text_width("..", font)) + ".."
    return out

# =================================================================== dates
MDAYS = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

def leap(y):
    if y % 400 == 0:
        return True
    if y % 100 == 0:
        return False
    return y % 4 == 0

def day_index(y, m, d):
    """Days since 1 Jan 1914. Only ever called for dates inside the war, so
    the year loop always runs forwards."""
    total = 0
    for yy in range(1914, y):
        total += 366 if leap(yy) else 365
    n = MDAYS[m - 1] + d
    if m > 2 and leap(y):
        n += 1
    return total + n - 1

WAR_FROM = day_index(1914, 7, 28)     # Austria-Hungary declares war on Serbia
WAR_TO = day_index(1918, 11, 11)      # the armistice takes effect
YEAR_TICKS = [1915, 1916, 1917, 1918]

def date_text(e):
    return str(e[3]) + " " + MONTHS[e[2] - 1] + " " + str(e[1])

def year_bucket(y):
    if y < 1914:
        return "BEFORE 1914"
    if y > 1918:
        return "AFTER 1918"
    return str(y)

# ================================================================ selection
def pool(ctx):
    th = ctx.inputs.get("theatre", "ALL FRONTS")
    yr = ctx.inputs.get("year", "ALL YEARS")
    out = []
    for e in ROSTER:
        if th != "ALL FRONTS" and THEATRE[e[0]][0] != th:
            continue
        if yr != "ALL YEARS" and year_bucket(e[1]) != yr:
            continue
        out.append(e)
    return out

def pick(ctx):
    """The house rotation. The year term shifts where the sequence starts so
    the same calendar date does not land on the same entry every year."""
    p = pool(ctx)
    if len(p) == 0:
        return None
    return p[(ctx.now.yday - 1 + ctx.now.year * 3) % len(p)]

# =================================================================== chrome
def rail(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def chip_row(c, e, right_text):
    """The chip row every page shares: the theatre chip on the left in its
    own colour, one piece of meta right-aligned. The right string is measured
    against what the chip actually left behind rather than a hand-picked x,
    because 'ARMISTICE & AFTER' is 85px of chip and
    'ALBANIA AND MONTENEGRO' is 105px of place - together they are 18px wider
    than the safe zone, and they would have drawn through each other."""
    acc = THEATRE[e[0]][1]
    w = c.badge(safe(THEATRE[e[0]][0]), SAFE_L, 0, color = "black", bg = acc,
                font = "4x5")
    avail = SAFE_R - (SAFE_L + w + 4)
    if right_text != "" and avail > 12:
        c.text(clip(c, safe(right_text), "4x5", avail), SAFE_R, 1,
               font = "4x5", color = DIM, align = "right")

def empty_card(c, ctx):
    """Not an error: the viewer asked for a combination the roster does not
    hold, so the panel says which two settings to widen."""
    c.fill("black")
    rail(c, OFFLINE)
    c.badge("NO MATCH", SAFE_L, 0, color = "black", bg = DIM, font = "4x5")
    th = safe(str(ctx.inputs.get("theatre", "ALL FRONTS")))
    yr = safe(str(ctx.inputs.get("year", "ALL YEARS")))
    # A dash, not "IN": two of the year buckets are "BEFORE 1914" and
    # "AFTER 1918", and "WAR IN THE AIR IN BEFORE 1914" is not a sentence.
    c.text(clip(c, th + " - " + yr, "5x7", SAFE_R - SAFE_L), 96, 11,
           font = "5x7", color = "amber", align = "center")
    c.text("NO ENTRY FOR THAT PAIR - WIDEN ONE", 96, 23,
           font = "4x5", color = DIM, align = "center")

# ============================================================ the timeline
def timeline(c, e, acc):
    """Where this day sits in the war, as a bar from the declaration on
    28 July 1914 to the armistice on 11 November 1918.

    Events outside that window get a different strip rather than a marker
    pinned to an end cap: a bar whose marker never moves off the end would
    say 1882 and 1912 sat in the same place, which is worse than not drawing
    one."""
    if e[1] < 1914 or e[1] > 1918:
        before = e[1] < 1914
        if before:
            c.fill_triangle(SAFE_L, 29, SAFE_L + 5, 26, SAFE_L + 5, 31, acc)
            c.text("BEFORE THE WAR", SAFE_L + 8, 27, font = "4x5", color = acc)
        else:
            c.fill_triangle(SAFE_R, 29, SAFE_R - 5, 26, SAFE_R - 5, 31, acc)
            c.text("AFTER THE ARMISTICE", SAFE_R - 8, 27, font = "4x5",
                   color = acc, align = "right")
        side = SAFE_R if before else SAFE_L
        c.text(str(e[1]), side, 27, font = "4x5", color = INK,
               align = "right" if before else "left")
        return

    x0 = SAFE_L + 18       # clear of the "1914" label
    x1 = SAFE_R - 18       # clear of the "1918" label
    span = WAR_TO - WAR_FROM
    c.text("1914", SAFE_L, 27, font = "picopixel", color = FAINT)
    c.text("1918", SAFE_R, 27, font = "picopixel", color = FAINT,
           align = "right")
    c.rect(x0, 28, x1, 30, fill = STRUCT)
    d = day_index(e[1], e[2], e[3]) - WAR_FROM
    if d < 0:
        d = 0
    if d > span:
        d = span
    mx = x0 + (x1 - x0) * d // span
    # year ticks sit above the bar so they never disappear under the fill
    for yt in YEAR_TICKS:
        tx = x0 + (x1 - x0) * (day_index(yt, 1, 1) - WAR_FROM) // span
        c.vline(tx, 26, 1, "#4A4F5C")
    # elapsed run, then the marker on top of it
    if mx > x0:
        c.rect(x0, 28, mx, 30, fill = STRUCT)
    c.rect(x0, 29, mx, 29, fill = FAINT)
    c.vline(mx, 26, 6, acc)
    if mx > x0:
        c.vline(mx - 1, 28, 3, acc)
    if mx < x1:
        c.vline(mx + 1, 28, 3, acc)

# ============================================================== the pages
def headline(c, ctx):
    e = pick(ctx)
    if e == None:
        empty_card(c, ctx)
        return
    acc = THEATRE[e[0]][1]
    c.fill("black")
    rail(c, acc)
    chip_row(c, e, date_text(e))
    c.hline(SAFE_L, 7, SAFE_R - SAFE_L + 1, STRUCT)

    # The hero. 10x16 carries 15 characters across the safe zone and 9x12
    # carries 17, which is why the roster keeps every title to 17 or fewer;
    # the two smaller rungs exist for the four titles that run to 18 or 19.
    ff = fit(c, safe(e[4]), ["10x16", "9x12", "8x10", "6x8"], SAFE_R - SAFE_L + 1)
    fh = {"10x16": 16, "9x12": 12, "8x10": 10, "6x8": 8}[ff[0]]
    c.text(ff[1], 96, 9 + (16 - fh) // 2, font = ff[0], color = INK,
           align = "center")

    timeline(c, e, acc)

def scene(c, ctx):
    e = pick(ctx)
    if e == None:
        empty_card(c, ctx)
        return
    acc = THEATRE[e[0]][1]
    c.fill("black")
    rail(c, acc)
    chip_row(c, e, e[5])

    ART[e[9]](c, ABX, ABY, acc)
    # The rule derives from the art box rather than sitting at a hand-picked
    # 64, so the two cannot drift apart if the box is ever resized: the art
    # ends at ABX + ABW - 1 = 61, and the rule stands two columns clear of it.
    c.vline(ABX + ABW + 2, ABY, ABH, STRUCT)

    # Three rows of 4x7 in a 114px column. 4x7 and 5x7 are the same height,
    # and 4x7 carries 23 characters where 5x7 carries 19 - four characters a
    # row is most of a word at this size, so the prose reads as a sentence
    # rather than as a column of fragments.
    rows = wrap(c, safe(e[6]), "4x7", COLW, 3)
    yy = 9
    for ln in rows:
        c.text(ln, COLX, yy, font = "4x7", color = INK)
        yy += 8

def legacy(c, ctx):
    e = pick(ctx)
    if e == None:
        empty_card(c, ctx)
        return
    acc = THEATRE[e[0]][1]
    c.fill("black")
    rail(c, acc)
    chip_row(c, e, "WHY IT MATTERED")

    rows = wrap(c, safe(e[7]), "4x7", SAFE_R - SAFE_L + 1, 2)
    yy = 9
    for ln in rows:
        c.text(ln, SAFE_L, yy, font = "4x7", color = INK)
        yy += 8

    c.hline(SAFE_L, 25, SAFE_R - SAFE_L + 1, STRUCT)
    # The one live line on the app, and the only text on the panel this app
    # did not write. It is used ONLY if it fits the strip whole.
    #
    # Clipping it is not a cosmetic loss, it is a factual one. Wikipedia
    # describes the Somme as "WWI battle pitting France and Britain against
    # Germany"; cut to the 34 characters this strip holds, that becomes
    # "WWI BATTLE PITTING FRANCE AND BRITAIN", which reads as though France
    # and Britain fought each other. A half-sentence can invert its own
    # meaning, so anything that does not fit is dropped for the curated note,
    # which always fits and is often the better line anyway - "57,470 BRITISH
    # CASUALTIES DAY 1" says more than a genre label ever would.
    avail = SAFE_R - (SAFE_L + 5)
    line = safe(wiki_line(e[10]))
    live = line != "" and c.text_width(line, "4x5") <= avail
    if not live:
        line = safe(e[8])
    c.rect(SAFE_L, 27, SAFE_L + 1, 31, fill = LIVE if live else acc)
    c.text(clip(c, line, "4x5", avail), SAFE_L + 5, 27, font = "4x5", color = DIM)

# ============================================================ the live line
# One request, on one page, cached for a day. The URL is the only thing in
# the cache key that changes, and it changes once a day when the entry does,
# so a panel refreshing on its own schedule hits the cache every time after
# the first. Against a budget of eight uncached requests per render this is
# one, and every other page on the app is drawn without touching the network.
WIKI = "https://en.wikipedia.org/api/rest_v1/page/summary/"
UA = {"User-Agent": "glance-ww1-facts (glance-led.dev)"}

def wiki_line(title):
    """The article's one-line description, or "" if anything at all is off.

    The `description` field is used rather than `extract` because it is
    already written as a single line - "1916 battle of the First World War" -
    and the strip is 34 characters. An extract clipped to 34 characters is a
    fragment, not a fact. A status_code of 0 means the host is offline; any
    non-200 and this returns "" and the panel shows the curated note, which
    is why nothing here is wrapped in a check the caller has to repeat."""
    r = http.get(WIKI + title, headers = UA, ttl_seconds = 86400)
    if type(r) != "dict":
        return ""
    if r.get("status_code", 0) != 200:
        return ""
    j = r.get("json", None)
    if type(j) != "dict":
        return ""
    d = j.get("description", "")
    if type(d) != "string" or d == "":
        return ""
    return d
