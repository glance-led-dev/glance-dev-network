# Jukebox Now Playing — the P$ Jukebox's current song as a two-line SCROLL card.
#
# Reads a small public JSON endpoint served by the jukebox site (it keeps the Home
# Assistant credentials server-side; this app never sees them):
#   {"playing": true, "title": "...", "artist": "...", "startedAt": ms, "idleAt": ms}
# startedAt / idleAt are epoch milliseconds; idleAt == 0 means a live stream (radio).

GOLD = "#FFB300"
DIM_GOLD = "#3a2a00"
LOGO_W = 27                    # P$ JUKEBOX logo block
CYAN = "#5FE6FF"
LEFT = 10                      # safe-zone left edge on 192 wide
RIGHT = 181                    # safe-zone right edge
TX = LEFT + LOGO_W + 6         # text column
TW = RIGHT - TX + 1

DEMO = {
    "playing": True,
    "title": "DON'T STOP BELIEVIN'",
    "artist": "JOURNEY",
    "elapsed": 92,
    "length": 251,
}


def _clip(c, s, fonts, maxw):
    """Largest font that fits; if none, hard-clip with '..' on the smallest."""
    s = str(s).upper()
    for f in fonts:
        if c.text_width(s, f) <= maxw:
            return s, f
    f = fonts[len(fonts) - 1]
    for n in range(len(s), 0, -1):
        t = s[:n].rstrip() + ".."
        if c.text_width(t, f) <= maxw:
            return t, f
    return "..", f


def _mmss(sec):
    sec = int(sec)
    if sec < 0:
        sec = 0
    s = sec % 60
    return str(sec // 60) + ":" + ("0" + str(s) if s < 10 else str(s))


def _icon(c):
    """The P$ JUKEBOX logo: the script P$ (bundled logo.png, traced from the brand
    art) with JUKEBOX in cyan underneath."""
    c.image("logo.png", LEFT, 0)
    c.text("JUKEBOX", LEFT, 27, font = "3x4", color = CYAN)


def _card(c, title, artist, elapsed, length, reserve = 0):
    c.fill("black")
    _icon(c)

    t, tf = _clip(c, title, ["6x8", "5x7", "4x5"], TW - reserve)
    c.text(t, TX, 3, font = tf, color = "white")

    a, af = _clip(c, artist, ["5x7", "4x5"], TW)
    c.text(a, TX, 14, font = af, color = GOLD)

    if length > 0:
        pct = 100.0 * elapsed / length
        if pct > 100.0:
            pct = 100.0
        right = _mmss(length)
        rw = c.text_width(right, "4x5")
        c.text(right, RIGHT - rw + 1, 25, font = "4x5", color = "gray")
        c.text(_mmss(elapsed), TX, 25, font = "4x5", color = "gray")
        lw = c.text_width(_mmss(elapsed), "4x5")
        bx = TX + lw + 4
        bw = RIGHT - rw - 4 - bx
        c.progress_bar(bx, 26, bw, 3, pct, color = GOLD, bg = DIM_GOLD)
    else:
        c.text("LIVE", TX, 25, font = "4x5", color = "red")


def _dark(c):
    # Nothing to show: leave the slot completely dark instead of drawing a card.
    c.fill("black")


def _fetch(ctx):
    ep = ctx.inputs.get("endpoint", "")
    if ep == "":
        return "demo", DEMO
    resp = http.get(
        "https://" + ep,
        params = {"zone": "Bar"},
        ttl_seconds = 15,
    )
    if resp["status_code"] != 200 or resp["json"] == None:
        return "error", None
    return "live", resp["json"]


def now_playing(c, ctx):
    kind, d = _fetch(ctx)
    if kind == "error" or not d.get("playing", False) or str(d.get("title", "")) == "":
        _dark(c)
        return
    if kind == "demo":
        _card(c, d["title"], d["artist"], d["elapsed"], d["length"], 22)
        c.text("DEMO", RIGHT - 15, 3, font = "4x5", color = "red")
        return
    started = float(d.get("startedAt", 0)) / 1000.0
    idle_at = float(d.get("idleAt", 0)) / 1000.0
    length = int(idle_at - started) if idle_at > started else 0
    elapsed = int(ctx.now.unix - started) if started > 0 else 0
    _card(c, d.get("title", ""), d.get("artist", ""), elapsed, length)
