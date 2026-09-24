# Three static 192x32 pages. All content stays inside x=10..181.
# Public API subscriber counts are rounded by YouTube, not exact Studio counts.
# No credentials in source, frames, messages, or request URLs.
RED = "#FF3636"
DIM = "#A4AFBD"
CYAN = "#50E3CE"
TTL = 300
BASE = "https://www.googleapis.com/youtube/v3/"

def obj(value):
    return value if type(value) == "dict" else {}

def number(value):
    s = str(value).strip()
    if s == "" or len(s) > 18:
        return None
    for ch in s.elems():
        if ch < "0" or ch > "9":
            return None
    return int(s)

def clean(value):
    s = str(value).upper().replace("’", "'").replace("–", "-").replace("—", "-").replace("…", "...")
    out = ""
    for ch in s.elems():
        out += ch if ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !?.,:-/()&+%#@" else " "
    return " ".join(out.split())

def clip(c, text, width, font = "5x7"):
    s = clean(text)
    if c.text_width(s, font) <= width:
        return s
    for n in range(len(s), 0, -1):
        if c.text_width(s[:n] + "...", font) <= width:
            return s[:n] + "..."
    return ""

def compact(n):
    if n == None:
        return "--"
    if n < 1000:
        return str(n)
    for divisor, suffix in [[1000000000000, "T"], [1000000000, "B"], [1000000, "M"], [1000, "K"]]:
        if n >= divisor:
            tenth = n * 10 // divisor
            return str(tenth // 10) + ("." + str(tenth % 10) if tenth % 10 else "") + suffix
    return str(n)

def count(c, n, width, font):
    exact = "--" if n == None else fmt.commas(n)
    return exact if c.text_width(exact, font) <= width else clip(c, compact(n), width, font)

def error(head, hint):
    return {"error": head, "hint": hint}

def request(endpoint, params, key):
    # A header avoids leaking the key into URLs / URL logs.
    r = http.get(BASE + endpoint, params = params, headers = {"X-Goog-Api-Key": key}, ttl_seconds = TTL)
    status = r.get("status_code", 0)
    if status == 0 or status >= 500:
        return error("YOUTUBE UNAVAILABLE", "RETRY IN 5 MIN")
    if status == 403 or status == 429:
        return error("API ACCESS / QUOTA", "CHECK KEY OR RETRY LATER")
    if status != 200:
        return error("YOUTUBE REQUEST FAILED", "CHECK API KEY AND CHANNEL")
    data = r.get("json")
    if type(data) != "dict" or type(data.get("items")) != "list":
        return error("YOUTUBE DATA UNAVAILABLE", "RETRY IN 5 MIN")
    return data

def channel_data(ctx):
    key = str(ctx.inputs.get("apikey", "")).strip()
    if key == "":
        return {"demo": True, "name": "RETRO RANGER", "subs": 1420, "views": 224000, "videos": 187, "uploads": ""}
    ident = str(ctx.inputs.get("channelid", "")).strip()
    if ident == "":
        return error("SET YOUR CHANNEL", "ENTER CHANNEL ID OR @HANDLE")
    params = {"part": "snippet,statistics,contentDetails", "maxResults": 1}
    if ident.startswith("@") and len(ident) > 1:
        params["forHandle"] = ident
    elif ident.startswith("UC") and len(ident) == 24:
        for ch in ident.elems():
            if ch not in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-":
                return error("INVALID CHANNEL ID", "USE UC ID OR @HANDLE")
        params["id"] = ident
    else:
        return error("INVALID CHANNEL ID", "USE UC ID OR @HANDLE")
    data = request("channels", params, key)
    if "error" in data:
        return data
    if len(data["items"]) == 0:
        return error("CHANNEL NOT FOUND", "CHECK CHANNEL ID OR HANDLE")
    item = obj(data["items"][0])
    stats = obj(item.get("statistics"))
    return {
        "demo": False,
        "name": obj(item.get("snippet")).get("title", "YOUTUBE CHANNEL"),
        "subs": None if stats.get("hiddenSubscriberCount", False) else number(stats.get("subscriberCount")),
        "views": number(stats.get("viewCount")),
        "videos": number(stats.get("videoCount")),
        "uploads": obj(obj(item.get("contentDetails")).get("relatedPlaylists")).get("uploads", ""),
    }

def latest_data(ctx, d):
    if d["demo"]:
        return {"title": "FROM BROKEN TO BASIC", "views": 842, "likes": 37}
    if not d["uploads"]:
        return error("NO PUBLIC UPLOADS", "YOUR NEXT VIDEO GOES HERE")
    key = str(ctx.inputs.get("apikey", "")).strip()
    p = request("playlistItems", {"part": "contentDetails", "playlistId": d["uploads"], "maxResults": 5}, key)
    if "error" in p:
        return p
    ids = []
    for item in p["items"]:
        vid = obj(obj(item).get("contentDetails")).get("videoId", "")
        if type(vid) == "string" and vid != "":
            ids.append(vid)
    if not ids:
        return error("NO PUBLIC UPLOADS", "YOUR NEXT VIDEO GOES HERE")
    v = request("videos", {"part": "snippet,statistics,status", "id": ",".join(ids)}, key)
    if "error" in v:
        return v
    # Preserve upload-playlist order; skip unavailable/private entries.
    for vid in ids:
        for item in v["items"]:
            item = obj(item)
            if item.get("id") == vid and obj(item.get("status")).get("privacyStatus", "public") == "public":
                stats = obj(item.get("statistics"))
                return {"title": obj(item.get("snippet")).get("title", "UNTITLED VIDEO"), "views": number(stats.get("viewCount")), "likes": number(stats.get("likeCount"))}
    return error("NO PUBLIC UPLOADS", "YOUR NEXT VIDEO GOES HERE")

def header(c, label, demo = False):
    c.fill("black")
    c.round_rect(10, 1, 22, 8, 2, fill = RED)
    c.fill_triangle(14, 2, 14, 6, 18, 4, "white")
    c.text(clip(c, label, 128 if demo else 154, "4x5"), 27, 2, font = "4x5", color = DIM)
    if demo:
        c.text("DEMO", 181, 2, font = "4x5", color = "amber", align = "right")

def message(c, d):
    header(c, "RETRO RANGER / YOUTUBE")
    c.text(clip(c, d["error"], 172), 10, 12, color = "amber")
    c.text(clip(c, d["hint"], 172, "4x5"), 10, 25, font = "4x5", color = DIM)

def channel(c, ctx):
    d = channel_data(ctx)
    if "error" in d:
        message(c, d)
        return
    header(c, d["name"], d["demo"])
    c.text(count(c, d["subs"], 80, "10x16"), 10, 10, font = "10x16", color = "white")
    c.text("SUBSCRIBERS", 10, 27, font = "4x5", color = RED)
    c.line(94, 12, 94, 30, "#30343B")
    c.text("VIEWS", 102, 12, font = "4x5", color = DIM)
    c.text(count(c, d["views"], 52, "5x7"), 181, 10, color = "white", align = "right")
    c.text("VIDEOS", 102, 25, font = "4x5", color = DIM)
    c.text(count(c, d["videos"], 46, "5x7"), 181, 23, color = "white", align = "right")

def title_lines(c, title):
    title = clean(title)
    words = title.split()
    first = ""
    used = 0
    for word in words:
        candidate = (first + " " + word).strip()
        if c.text_width(candidate, "5x7") > 172:
            break
        first = candidate
        used += 1
    if used == 0:
        # Break an oversized single word so neither line clips the panel.
        for n in range(len(title), 0, -1):
            if c.text_width(title[:n], "5x7") <= 172:
                return [title[:n], clip(c, title[n:], 172)]
    return [first, clip(c, " ".join(words[used:]), 172)]

def latest(c, ctx):
    d = channel_data(ctx)
    if "error" in d:
        message(c, d)
        return
    v = latest_data(ctx, d)
    if "error" in v:
        message(c, v)
        return
    header(c, "LATEST VIDEO", d["demo"])
    lines = title_lines(c, v["title"])
    c.text(lines[0], 10, 10, color = "white")
    c.text(lines[1], 10, 18, color = "white")
    c.text(clip(c, compact(v["views"]) + " VIEWS", 82, "4x5"), 10, 27, font = "4x5", color = DIM)
    c.text(clip(c, compact(v["likes"]) + " LIKES", 82, "4x5"), 181, 27, font = "4x5", color = RED, align = "right")

def goal(c, ctx):
    d = channel_data(ctx)
    if "error" in d:
        message(c, d)
        return
    target = number(str(ctx.inputs.get("subscribergoal", "1500")).replace(",", ""))
    if target == None or target <= 0 or target > 999999999999:
        message(c, error("SET A SUBSCRIBER GOAL", "USE A POSITIVE WHOLE NUMBER"))
        return
    if d["subs"] == None:
        message(c, error("SUB COUNT UNAVAILABLE", "GOAL NEEDS PUBLIC SUB COUNT"))
        return
    hit = d["subs"] >= target
    header(c, "SUB GOAL REACHED!" if hit else "SUBSCRIBER GOAL", d["demo"])
    c.text(count(c, d["subs"], 80, "10x16"), 10, 10, font = "10x16", color = "white")
    target_text = "OF " + count(c, target, 58, "4x5") + " SUBS"
    c.text(clip(c, target_text, 82, "4x5"), 181, 11, font = "4x5", color = DIM, align = "right")
    pct10 = min(1000, d["subs"] * 1000 // target)
    pct = str(pct10 // 10) + ("." + str(pct10 % 10) if pct10 % 10 else "") + "%"
    c.text(pct, 181, 20, font = "4x5", color = CYAN if hit else RED, align = "right")
    c.rect(10, 27, 181, 30, fill = "#262C34")
    width = min(172, d["subs"] * 172 // target)
    if width > 0:
        c.rect(10, 27, 10 + width - 1, 30, fill = CYAN if hit else RED)
