# Steam Friends
#
# The Steam Web API. Friend list and player summaries are two calls,
# and the summaries endpoint takes up to a hundred ids at once, so
# this stays well inside the eight-request budget.
#
# Your profile and friend list must be public for the API to return
# anything, which is the usual reason this comes back empty.



NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do.

    text_fit alone was not enough here: when even its smallest option
    overflows it still draws, which ran these messages off a 64 panel."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands — a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws — which is how a station name ended up running
    straight through the readout beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def fitwords(c, text, font, maxw):
    """Longest run of WHOLE words that fits maxw.

    clip() cuts at the pixel and leaves things like "SCHOOL PI" or
    "PAINTED B", which read as a rendering fault rather than an
    abbreviation. This stops at a word boundary instead, and only falls back
    to a hard cut when a single word cannot fit on its own."""
    t = str(text).strip()
    if c.text_width(t, font) <= maxw:
        return t
    parts = t.split(" ")
    out = ""
    for w in parts:
        trial = w if out == "" else out + " " + w
        if c.text_width(trial, font) > maxw:
            break
        out = trial
    if out != "":
        return out
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


DEMO = "DEMO"


def is_demo(ctx):
    """True when the key is the literal DEMO opt-in.

    Catalog previews are rendered with this so they show the real layout
    carrying representative values. A panel with no key configured still gets
    the plain error screen — this never fires by accident."""
    return str(ctx.inputs.get("apikey", "")).strip().upper() == DEMO


def demo_badge(c):
    """A single corner marker. A SAMPLE word across the top-right covered real
    content in half these apps, which defeats the point of the preview."""
    c.rect(c.width - 5, c.height - 5, c.width - 1, c.height - 1,
           fill = "#3A3F52")
    c.text("S", c.width - 2, c.height - 5, font = "3x4", color = "#D8DEF0",
           align = "right")


STEAM_SAMPLE = {"status_code": 200, "json": {"response": {"players": [
    {"personaname": "Ash", "personastate": 1, "gameextrainfo": "Factorio"},
    {"personaname": "Jordan", "personastate": 1, "gameextrainfo": "Deep Rock"},
    {"personaname": "Sam", "personastate": 3}]}}}

STATES = {1: "ONLINE", 2: "BUSY", 3: "AWAY", 4: "SNOOZE"}


def friends(c, ctx):
    key = str(ctx.inputs.get("apikey", "")).strip()
    sid = str(ctx.inputs.get("steamid", "")).strip()
    demo = is_demo(ctx)
    if not demo and (key == "" or sid == ""):
        nodata(c, "NOT CONFIGURED", "SET KEY AND ID")
        return

    if demo:
        r = STEAM_SAMPLE
    else:
        fl = http.get("https://api.steampowered.com/ISteamUser/GetFriendList/v0001/",
                      params = {"key": key, "steamid": sid, "relationship": "friend"},
                      ttl_seconds = 3600)
        if fl["status_code"] == 401 or fl["status_code"] == 403:
            nodata(c, "BAD KEY", "CHECK KEY")
            return
        if fl["status_code"] != 200 or not fl["json"]:
            nodata(c, "NO STEAM DATA", "NO CONNECTION")
            return
        ids = []
        for f in fl["json"].get("friendslist", {}).get("friends", []):
            if len(ids) < 40:
                ids.append(str(f.get("steamid", "")))
        if len(ids) == 0:
            nodata(c, "NO FRIENDS", "PROFILE PRIVATE?")
            return
        r = http.get("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/",
                     params = {"key": key, "steamids": ",".join(ids)},
                     ttl_seconds = 300)
        if r["status_code"] != 200 or not r["json"]:
            nodata(c, "NO STEAM DATA", "NO CONNECTION")
            return

    players = r["json"].get("response", {}).get("players", [])
    online = []
    for p in players:
        if int(p.get("personastate", 0) or 0) > 0:
            online.append(p)

    c.fill("#06080E")
    sz = 24 if c.width >= 128 else 16
    c.image("PAD.png", 11 if c.width >= 128 else 1, (c.height - sz) // 2,
            w = sz, h = sz)

    if len(online) == 0:
        c.text("NOBODY ONLINE", c.width - 16, 12,
               font = "6x8" if c.width >= 128 else "4x5", color = "#5E6A88",
               align = "right")
        if demo:
            demo_badge(c)
        return

    show = 3 if c.width >= 128 else 2
    if show > len(online):
        show = len(online)
    x0 = 38 if c.width >= 128 else 19
    lh = c.height // show

    for i in range(show):
        p = online[i]
        y = i * lh + (lh - 7) // 2
        nm = str(p.get("personaname", "")).upper()
        game = str(p.get("gameextrainfo", "") or "")
        if game != "":
            tag = game.upper()
            col = "#6FE38A"
        else:
            tag = STATES.get(int(p.get("personastate", 1) or 1), "ONLINE")
            col = "#6E7A98"
        if c.width >= 128:
            # Game names stay 4x5; a bare status (AWAY, ONLINE) gets 6x8 so
            # the state reads at a glance. Both right-aligned 13px off the
            # edge, with the name yielding the space.
            tfont = "4x5" if game != "" else "6x8"
            ty = y + 1 if game != "" else y - 1
            tag_t = clip(c, tag, tfont, 76)
            tw = c.text_width(tag_t, tfont) + 4
            c.text(tag_t, c.width - 13, ty, font = tfont, color = col,
                   align = "right")
            c.text(clip(c, nm, "5x7", c.width - 13 - x0 - tw), x0, y,
                   font = "5x7", color = "#DCE4F4")
        else:
            # Showing only names left the app without its own data. The tag
            # goes underneath rather than beside — 45px will not hold both.
            c.text(fitwords(c, nm, "4x5", c.width - x0 - 2), x0, i * lh + 1,
                   font = "4x5", color = "#DCE4F4")
            c.text(fitwords(c, tag, "4x5", c.width - x0 - 8), x0, i * lh + 8,
                   font = "4x5", color = col)
    if demo:
        demo_badge(c)
