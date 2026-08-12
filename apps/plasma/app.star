# Plasma Field — three different fields, one per page.
#
# Each page is a static frame; the panel rotates through them, so one app gives
# you three distinct looks in your chosen palette. Two engine limits shape the
# implementation:
#
#   1. A page may emit at most 4096 draw ops and no single bitmap may hold more
#      than 4096 cells, while a 192x32 panel is 6144 pixels. So the frame is
#      built as rows of palette-index characters, handed to c.sprite (one bitmap
#      per colour), and chunked across the width to stay under the cell cap.
#   2. Every math.sin() crosses the Starlark/host boundary, so calling it per
#      pixel would be far too slow. A 64-entry sine table is built once and
#      indexed with integer phases after that.

LEVELS = "0123456789ABCDEF"      # sprite treats "." and " " as holes, so avoid them
STEPS = 64                       # sine table resolution

PALETTES = {
    "SUNSET": [[12, 4, 40], [92, 16, 92], [214, 52, 84], [255, 138, 40], [255, 240, 190]],
    "OCEAN": [[3, 10, 38], [10, 56, 110], [16, 132, 160], [86, 216, 214], [232, 252, 255]],
    "TOXIC": [[4, 14, 6], [16, 74, 24], [58, 156, 32], [154, 220, 46], [242, 255, 190]],
    "CANDY": [[26, 8, 46], [120, 30, 130], [226, 74, 168], [255, 152, 200], [255, 236, 246]],
    "MONO": [[6, 6, 10], [70, 70, 84], [150, 150, 164], [220, 220, 232], [255, 255, 255]],
}


def ramp(anchors, n):
    """Spread a short list of anchor colours into n evenly blended shades."""
    out = []
    segs = len(anchors) - 1
    for i in range(n):
        t = i * segs / (n - 1.0)
        k = int(t)
        if k >= segs:
            k = segs - 1
        f = t - k
        a = anchors[k]
        b = anchors[k + 1]
        out.append([int(a[0] + (b[0] - a[0]) * f),
                    int(a[1] + (b[1] - a[1]) * f),
                    int(a[2] + (b[2] - a[2]) * f)])
    return out


def sine_table():
    t = []
    for i in range(STEPS):
        t.append(math.sin(2.0 * math.pi * i / STEPS))
    return t


def draw_grid(c, rows, legend):
    """Emit a full-panel index grid, chunked so no bitmap exceeds 4096 cells."""
    step = 4096 // c.height
    for x0 in range(0, c.width, step):
        chunk = []
        for r in rows:
            chunk.append(r[x0:x0 + step])
        c.sprite(chunk, x0, 0, legend = legend)


def setup(ctx):
    """Palette legend, sine table, and a phase that drifts with the clock."""
    name = ctx.inputs.get("palette", "SUNSET")
    shades = ramp(PALETTES.get(name, PALETTES["SUNSET"]), 16)
    legend = {}
    for i in range(16):
        legend[LEVELS[i]] = shades[i]
    return [legend, sine_table(), (ctx.now.unix // 60) % STEPS]


def paint(c, legend, cell):
    """Walk the panel, asking `cell` for a -3..3 field value at each pixel."""
    rows = []
    for y in range(c.height):
        line = []
        for x in range(c.width):
            v = cell(x, y)
            line.append(LEVELS[int((v + 3.0) * 15.0 / 6.0)])
        rows.append("".join(line))
    draw_grid(c, rows, legend)


def waves(c, ctx):
    """Three interfering linear waves — the classic demoscene plasma."""
    cfg = setup(ctx)
    s = cfg[1]
    t = cfg[2]

    def cell(x, y):
        return (s[(x * 3 + t) % STEPS]
                + s[(y * 5 + t * 2) % STEPS]
                + s[((x + y) * 2 + t) % STEPS])

    paint(c, cfg[0], cell)


def rings(c, ctx):
    """Concentric rings radiating from two offset centres."""
    cfg = setup(ctx)
    s = cfg[1]
    t = cfg[2]
    ax = c.width // 3
    ay = c.height // 2
    bx = c.width - c.width // 4
    by = c.height // 3

    def cell(x, y):
        d1 = (x - ax) * (x - ax) + (y - ay) * (y - ay)
        d2 = (x - bx) * (x - bx) + (y - by) * (y - by)
        r1 = int(math.sqrt(d1))
        r2 = int(math.sqrt(d2))
        return (s[(r1 * 4 + t) % STEPS]
                + s[(r2 * 5 - t) % STEPS]
                + s[((r1 + r2) * 2 + t) % STEPS])

    paint(c, cfg[0], cell)


def weave(c, ctx):
    """A tight diagonal moire, so the three pages never look alike."""
    cfg = setup(ctx)
    s = cfg[1]
    t = cfg[2]

    def cell(x, y):
        return (s[(x * 7 + y * 3 + t) % STEPS]
                + s[(x * 3 - y * 7 - t) % STEPS]
                + s[(y * 9 + t * 3) % STEPS])

    paint(c, cfg[0], cell)
