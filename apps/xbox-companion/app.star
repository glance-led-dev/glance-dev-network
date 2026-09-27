# DESIGN: Xbox identity and artwork first; charcoal tiles, green status accents,
# readable white type. Still frames for the GDN renderer, no fake animation knobs.
# The backend converts permitted artwork into bounded 26x26 pixel grids. This
# keeps private remote image URLs and all Microsoft credentials off the panel.
GREEN = "#7ED321"
WHITE = "#F1F4EE"
DIM = "#A3B19E"

def obj(value):
    return value if type(value) == "dict" else {}

def text(value, fallback = ""):
    return value if type(value) == "string" else fallback

def endpoint_url(value):
    if type(value) != "string":
        return ""
    value = value.strip()
    if value.startswith("https://"):
        return value
    # Colons terminate the device's settings descriptor. Accept host/path here
    # and add the HTTPS scheme only after the settings reach the renderer.
    if not value or ":" in value or any([x in value for x in [" ", "\t", "\r", "\n", "\\", "@", "#"]]):
        return ""
    host = value.split("/")[0].split("?")[0]
    if "." not in host or host.startswith(".") or host.endswith("."):
        return ""
    if any([x not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-." for x in host.elems()]):
        return ""
    if any([not label or label.startswith("-") or label.endswith("-") for label in host.split(".")]):
        return ""
    return "https://" + value

def clip(c, value, font, width):
    value = text(value).upper()[:160]
    if c.text_width(value, font) <= width:
        return value
    for n in range(len(value), -1, -1):
        cut = value[:n] + ".."
        if c.text_width(cut, font) <= width:
            return cut
    return ""

def score(value):
    value = str(value) if type(value) in ["int", "string"] else ""
    if not value or len(value) > 10:
        return "--"
    for ch in value.elems():
        if ch not in "0123456789":
            return "--"
    out = ""
    for i in range(len(value)):
        if i > 0 and (len(value) - i) % 3 == 0:
            out += ","
        out += value[i]
    return out

def base(c):
    c.fill("#000000")
    c.rect(9, 1, 182, 30, fill = "#10160F")
    c.line(42, 3, 42, 28, "#31402C")

def artwork(c, grid, enabled):
    valid = enabled and type(grid) == "list" and len(grid) == 26
    if valid:
        for row in grid:
            if type(row) != "list" or len(row) != 26:
                valid = False
        if valid:
            for row in grid:
                for color in row:
                    if type(color) != "string" or len(color) != 7 or color[0] != "#":
                        valid = False
                    elif color[1:].lower().strip("0123456789abcdef"):
                        valid = False
    if valid:
        for y in range(26):
            for x in range(26):
                c.pixel(11+x, 3+y, grid[y][x])
    else:
        c.image("xbox-symbol.png", 11, 3)

def label(c, value, right = ""):
    c.text(clip(c, value, "4x5", 96), 47, 3, font = "4x5", color = GREEN)
    c.text(clip(c, right, "4x5", 35), 178, 3, font = "4x5", color = WHITE, align = "right")

def message(c, head, sub):
    base(c)
    artwork(c, [], False)
    c.text("XBOX", 47, 3, font = "4x5", color = GREEN)
    c.text(clip(c, head, "5x7", 132), 47, 12, font = "5x7", color = WHITE)
    c.text(clip(c, sub, "4x5", 132), 47, 23, font = "4x5", color = DIM)

def profile(c, data, ctx, isdemo):
    p = obj(data.get("profile"))
    presence = obj(data.get("presence"))
    base(c)
    artwork(c, p.get("art"), ctx.inputs.get("showpic", True))
    c.image("xbox-small.png", 168, 3)
    c.text(clip(c, p.get("gamertag", "PLAYER"), "7x12", 116), 47, 4, font = "7x12", color = WHITE)
    status = text(presence.get("state"), "unknown").upper()
    status = status if status in ["ONLINE", "OFFLINE", "AWAY"] else "UNKNOWN"
    c.fill_circle(49, 24, 2, GREEN if status == "ONLINE" else "#879180")
    c.text(status, 55, 22, font = "4x5", color = DIM)
    if ctx.inputs.get("showscore", True):
        c.text(clip(c, score(p.get("score"))+" G", "5x7", 78), 179, 21, font = "5x7", color = WHITE, align = "right")
    if isdemo:
        c.text("DEMO", 11, 23, font = "4x5", color = WHITE)

def playing(c, data, ctx, isdemo):
    p = obj(data.get("presence"))
    title = text(p.get("title"))
    if not ctx.inputs.get("showgame", True):
        profile(c, data, ctx, isdemo)
        return
    current = bool(title) and text(p.get("state")).lower() in ["online", "away"]
    if not current:
        p = obj(data.get("lastplayed"))
        title = text(p.get("title"))
    if not title:
        message(c, "LAST PLAYED", "GAME HISTORY NOT AVAILABLE")
        return
    base(c)
    artwork(c, p.get("art"), ctx.inputs.get("showart", True))
    label(c, "NOW PLAYING" if current else "LAST PLAYED", "DEMO" if isdemo else "XBOX")
    c.text(clip(c, title, "6x8", 132), 47, 12, font = "6x8", color = WHITE)
    sub = (text(p.get("rich")) or text(p.get("device")) or "PLAYING") if current else text(p.get("date"), "DATE NOT AVAILABLE")
    c.text(clip(c, sub, "4x5", 132), 47, 24, font = "4x5", color = DIM)

def achievement(c, data, ctx, isdemo):
    items = data.get("achievements", [])
    if not ctx.inputs.get("showachievements", True):
        profile(c, data, ctx, isdemo)
        return
    if type(items) != "list" or not items:
        message(c, "NO RECENT UNLOCKS", "DEMO" if isdemo else "READY FOR YOUR NEXT GAME")
        return
    a = obj(items[0])
    base(c)
    artwork(c, a.get("art"), ctx.inputs.get("showart", True))
    points = score(a.get("score"))
    right = ("+"+points+"G") if ctx.inputs.get("showscore", True) and points != "--" else ""
    label(c, "RECENT UNLOCK", right)
    c.text(clip(c, a.get("name"), "6x8", 132), 47, 12, font = "6x8", color = WHITE)
    c.text(clip(c, a.get("game"), "4x5", 108 if isdemo else 132), 47, 24, font = "4x5", color = DIM)
    if isdemo:
        c.text("DEMO",179,24,font="4x5",color=GREEN,align="right")

def gamerscore(c, data, ctx, isdemo):
    if not ctx.inputs.get("showscore", True):
        profile(c, data, ctx, isdemo)
        return
    base(c)
    artwork(c, [], False)
    c.text("GAMERSCORE", 47, 3, font = "4x5", color = GREEN)
    c.text(clip(c, obj(data.get("profile")).get("gamertag", "PLAYER"), "4x5", 79), 179, 3, font = "4x5", color = WHITE, align = "right")
    if isdemo:
        c.text("DEMO", 11, 23, font = "4x5", color = WHITE)
    value = score(obj(data.get("profile")).get("score"))
    font = "10x16" if c.text_width(value+" G", "10x16") <= 132 else "7x12"
    c.text(clip(c, value+" G",font,132),47,12,font=font,color=WHITE)

def activity(c, data, ctx, isdemo, friends = False):
    if friends and not ctx.inputs.get("showfriends", False) and not isdemo:
        message(c, "FRIEND ACTIVITY OFF", "ENABLE FRIENDS IN SETTINGS")
        return
    feed = obj(data.get("friends" if friends else "activity"))
    if feed.get("state") != "ready":
        message(c, "FRIENDS UNAVAILABLE" if friends else "ACTIVITY UNAVAILABLE", "PRIVACY OR SERVICE LIMIT")
        return
    items = feed.get("items", [])
    if type(items) != "list" or not items:
        message(c, "NO SHARED ACTIVITY" if friends else "NO RECENT ACTIVITY", "DEMO" if isdemo else "CHECK BACK AFTER PLAYING")
        return
    # Rotate on refresh, without inventing unsupported frame animation.
    a = obj(items[(ctx.now.unix // 60) % len(items)])
    base(c)
    artwork(c, a.get("art"), ctx.inputs.get("showpic" if friends else "showart", True))
    label(c, "FRIEND ACTIVITY" if friends else text(obj(data.get("profile")).get("gamertag"), "PLAYER"))
    c.image("xbox-small.png", 168, 3)
    if isdemo:
        c.text("DEMO", 11, 23, font = "4x5", color = WHITE)
    c.text(clip(c, a.get("name"), "6x8", 116), 47, 12, font = "6x8", color = WHITE)
    c.text(clip(c, text(a.get("detail"), "ACTIVITY NOT SHARED").replace("RECENT ACHIEVEMENT ACTIVITY", "RECENT ACTIVITY"), "4x5", 132), 47, 24, font = "4x5", color = DIM)

def demo_data(mode, now):
    return {"schema":1, "updated":now-1000 if mode == "Stale" else now,
        "state":"reconnect" if mode == "Reconnect" else "unavailable" if mode == "Service Error" else "ready",
        "profile":{"gamertag":"AN EXTREMELY LONG PLAYER NAME" if mode == "Long Names" else "PLAYER ONE", "score":84720},
        "presence":{"state":"offline" if mode == "Offline" else "online", "title":"A VERY LONG GAME NAME THAT MUST FIT" if mode == "Long Names" else "FORZA HORIZON" if mode == "Playing" else "", "rich":"EXPLORING THE OPEN ROAD"},
        "activity":{"state":"ready", "items":[{"name":"FORZA HORIZON", "detail":"RECENT ACTIVITY"}]},
        "lastplayed":{"title":"FORZA HORIZON", "date":"SEP 25, 2026"},
        "friends":{"state":"unavailable" if mode == "Friends Unavailable" else "ready", "items":[] if mode == "Friends Empty" else [{"name":"PLAYER TWO", "detail":"PLAYING HALO INFINITE"}]},
        "achievements":[] if mode == "Empty" else [{"name":"ROAD WARRIOR", "score":50, "game":"FORZA HORIZON"}]}

def main(c, ctx):
    mode = ctx.inputs.get("demo", "Live")
    isdemo = mode != "Live"
    if isdemo:
        data = demo_data(mode, ctx.now.unix)
    else:
        endpoint = text(ctx.inputs.get("endpoint", "")).strip()
        key = text(ctx.inputs.get("readkey", "")).strip()
        if not endpoint or not key:
            message(c,"CONNECT ACCOUNT","ADD STATUS HOST + DEVICE KEY")
            return
        endpoint = endpoint_url(endpoint)
        if not endpoint:
            message(c,"CHECK STATUS HOST","ENTER HOST/PATH ONLY")
            return
        response = http.get(endpoint, headers={"Authorization":"Bearer "+key}, ttl_seconds=60)
        status = response.get("status_code",0)
        if status in [401,403]:
            message(c,"RECONNECT ACCOUNT","CHECK YOUR DEVICE KEY")
            return
        if status != 200:
            message(c,"SERVICE UNAVAILABLE","TRY AGAIN LATER")
            return
        data = obj(response.get("json"))
    if data.get("schema") != 1:
        message(c,"NO XBOX DATA","CHECK COMPANION SERVICE")
        return
    state = data.get("state", "unavailable")
    if state != "ready":
        message(c,"RECONNECT ACCOUNT" if state == "reconnect" else "SERVICE UNAVAILABLE","DEMO" if isdemo else "OPEN YOUR COMPANION")
        return
    updated = data.get("updated",0)
    if type(updated) != "int" or ctx.now.unix-updated > 300 or updated > ctx.now.unix+60:
        message(c,"LAST UPDATE IS OLD","DEMO" if isdemo else "CHECK COMPANION CONNECTION")
        return
    view = ctx.inputs.get("viewmode","Auto")
    if isdemo:
        view = "Now Playing" if mode == "Playing" else "Recent Achievement" if mode in ["Achievement","Empty"] else "Gamerscore" if mode == "Score" else "Profile"
        if mode == "Last Played":
            view = "Now Playing"
        elif mode == "Activity":
            view = "Recent Activity"
        elif mode in ["Friends", "Friends Empty", "Friends Unavailable"]:
            view = "Friend Activity"
    if view == "Auto":
        view = "Now Playing" if text(obj(data.get("presence")).get("title")) and ctx.inputs.get("showgame",True) else "Profile"
    if view == "Recent Activity":
        activity(c,data,ctx,isdemo)
    elif view == "Friend Activity":
        activity(c,data,ctx,isdemo,True)
    elif view == "Now Playing":
        playing(c,data,ctx,isdemo)
    elif view == "Recent Achievement":
        achievement(c,data,ctx,isdemo)
    elif view == "Gamerscore":
        gamerscore(c,data,ctx,isdemo)
    else:
        profile(c,data,ctx,isdemo)
