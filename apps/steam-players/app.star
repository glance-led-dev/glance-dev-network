# Steam Players — live counts + store glanceables (192x32).
#
# Data (no API key):
#   Players — ISteamUserStats/GetNumberOfCurrentPlayers
#   Name / price / F2P / genre / year — Store appdetails
#   Review % — Store appreviews summary
#
# Settings: type AppIDs into AppID 1–4 (none / blank = unused). One page only —
# a single AppID never pads the playlist with empty frames. Multiple AppIDs
# rotate on each refresh. Optional slots default to "none" so mobile can save
# without filling every field.
#
# Bitmap fonts are UPPERCASE ONLY.

PLAYERS_URL = "https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/"
STORE_URL = "https://store.steampowered.com/api/appdetails"
REVIEWS_URL = "https://store.steampowered.com/appreviews/"

# Optional shortcuts if someone types a name instead of an AppID.
ALIASES = {
    "CS2": "730",
    "CSGO": "730",
    "DOTA": "570",
    "DOTA2": "570",
    "TF2": "440",
    "GTA5": "271590",
    "GTAV": "271590",
    "ELDEN": "1245620",
    "ELDENRING": "1245620",
    "RUST": "252490",
    "PUBG": "578080",
    "APEX": "1172470",
    "VALHEIM": "892970",
    "HELLDIVERS": "553850",
    "HELLDIVERS2": "553850",
    "BG3": "1086940",
    "CYBERPUNK": "1091500",
    "WARFRAME": "230410",
    "DESTINY2": "1085660",
    "STARDEW": "413150",
    "HADES": "1145360",
    "PALWORLD": "1623730",
}

KNOWN_NAMES = {
    "730": "COUNTER-STRIKE 2",
    "570": "DOTA 2",
    "440": "TEAM FORTRESS 2",
    "271590": "GRAND THEFT AUTO V",
    "1245620": "ELDEN RING",
    "252490": "RUST",
    "578080": "PUBG",
    "1172470": "APEX LEGENDS",
    "892970": "VALHEIM",
    "553850": "HELLDIVERS 2",
    "1086940": "BALDURS GATE 3",
    "1091500": "CYBERPUNK 2077",
    "230410": "WARFRAME",
    "1085660": "DESTINY 2",
    "413150": "STARDEW VALLEY",
    "1145360": "HADES",
    "1623730": "PALWORLD",
}

STEAM_BLUE = "#66C0F4"
STEAM_DIM = "#4B619B"
OK_GREEN = "#3DDC82"
PRICE_GOLD = "#FFE566"
REVIEW_TEAL = "#5EEAD4"
REVIEW_NEG = "#FF6B6B"
WARN = "#FFB84D"
MUTED = "#8B9BB0"
MAX_GAMES = 4
ROTATE_EVERY = 120


def normalize_token(raw):
    t = str(raw).upper().strip()
    cleaned = ""
    for i in range(len(t)):
        ch = t[i]
        if ch >= "A" and ch <= "Z":
            cleaned += ch
        elif ch >= "0" and ch <= "9":
            cleaned += ch
    return cleaned


def resolve_appid(token):
    raw = str(token).strip()
    if raw == "":
        return None
    key = normalize_token(raw)
    if key == "" or key == "NONE" or key == "OFF":
        return None
    if key in ALIASES:
        return ALIASES[key]
    digits = True
    for i in range(len(raw)):
        ch = raw[i]
        if ch < "0" or ch > "9":
            digits = False
            break
    if not digits:
        return None
    n = raw
    for _ in range(8):
        if len(n) > 1 and n[0] == "0":
            n = n[1:]
        else:
            break
    if n == "" or n == "0":
        return None
    return n


def games_list(ctx):
    out = []
    seen = {}
    for key in ["game1", "game2", "game3", "game4"]:
        default = "730" if key == "game1" else "none"
        raw = ctx.inputs.get(key, default)
        if raw == None:
            raw = default
        appid = resolve_appid(raw)
        if appid == None or appid in seen:
            continue
        seen[appid] = True
        out.append(appid)

    # Legacy free-text favorites / custom from older builds.
    if len(out) == 0:
        for key in ["favorites", "custom"]:
            legacy = ctx.inputs.get(key, None)
            if legacy == None or str(legacy).strip() == "":
                continue
            for part in str(legacy).split(","):
                appid = resolve_appid(part)
                if appid == None or appid in seen:
                    continue
                seen[appid] = True
                out.append(appid)

    if len(out) == 0:
        out.append("730")
    if len(out) > MAX_GAMES:
        out = out[0:MAX_GAMES]
    return out


def active_slot(ctx, picks):
    total = len(picks)
    if total <= 1:
        return 0
    return (ctx.now.unix // ROTATE_EVERY) % total


def format_count(n):
    if n >= 1000000:
        whole = n // 1000000
        frac = (n % 1000000) // 100000
        if frac == 0:
            return str(whole) + "M"
        return str(whole) + "." + str(frac) + "M"
    if n >= 10000:
        return str(n // 1000) + "K"
    if n >= 1000:
        whole = n // 1000
        frac = (n % 1000) // 100
        if frac == 0:
            return str(whole) + "K"
        return str(whole) + "." + str(frac) + "K"
    return str(n)


def format_price(price):
    if price == None:
        return None
    discount = price.get("discount_percent", 0)
    if discount == None:
        discount = 0
    discount = int(discount)
    final = price.get("final", None)
    if final == None:
        return None
    dollars = int(final) // 100
    cents = int(final) % 100
    if cents == 0:
        tag = "$" + str(dollars)
    else:
        c = str(cents)
        if len(c) == 1:
            c = "0" + c
        tag = "$" + str(dollars) + "." + c
    if discount > 0:
        return tag + " -" + str(discount) + "%"
    return tag


def release_year(date_str):
    if date_str == None:
        return None
    t = str(date_str).strip()
    if len(t) < 4:
        return None
    year = t[len(t) - 4:len(t)]
    for i in range(4):
        ch = year[i]
        if ch < "0" or ch > "9":
            return None
    return year


def pick_genre(genres):
    if genres == None:
        return None
    for g in genres:
        desc = g.get("description", None)
        if desc == None:
            continue
        label = str(desc).upper().strip()
        if label == "" or label == "FREE TO PLAY" or label == "FREE-TO-PLAY":
            continue
        return label
    return None


def led_text(raw):
    # Bitmap fonts are A–Z / digits / basic punct only.
    t = str(raw).upper()
    out = ""
    for i in range(len(t)):
        ch = t[i]
        if ch >= "A" and ch <= "Z":
            out += ch
        elif ch >= "0" and ch <= "9":
            out += ch
        elif ch in " $%-+.,:#/'":
            out += ch
        elif ch == "&":
            out += "AND"
        else:
            # Collapse other junk to a single space.
            if len(out) == 0 or out[len(out) - 1] != " ":
                out += " "
    # Trim edges / squeeze double spaces.
    cleaned = ""
    for i in range(len(out)):
        ch = out[i]
        if ch == " " and (cleaned == "" or cleaned[len(cleaned) - 1] == " "):
            continue
        cleaned += ch
    for _ in range(4):
        if cleaned != "" and cleaned[len(cleaned) - 1] == " ":
            cleaned = cleaned[0:len(cleaned) - 1]
        else:
            break
    return cleaned


def fit_clip(c, text, maxw, fonts):
    # Prefer keeping the longest prefix that fits (avoid "OUTBRK"-style word chops).
    t = led_text(text)
    if t == "":
        return [fonts[len(fonts) - 1], ""]
    for font in fonts:
        if c.text_width(t, font) <= maxw:
            return [font, t]
    font = fonts[len(fonts) - 1]
    out = ""
    for i in range(len(t)):
        trial = out + t[i]
        if c.text_width(trial, font) > maxw:
            break
        out = trial
    # If we end mid-word with room for "..", leave a clean cut.
    if len(out) > 3 and out[len(out) - 1] != " ":
        trim = out
        for _ in range(8):
            if trim == "" or trim[len(trim) - 1] == " ":
                break
            if c.text_width(trim + "..", font) <= maxw:
                return [font, trim + ".."]
            trim = trim[0:len(trim) - 1]
    return [font, out]


def fetch_players(appid):
    r = http.get(
        PLAYERS_URL,
        headers = {
            "User-Agent": "(glance-steam-players, reyos86@github)",
            "Accept": "application/json",
        },
        params = {"appid": appid},
        ttl_seconds = 180,
    )
    if r["status_code"] != 200:
        return None
    j = r["json"]
    if j == None:
        return None
    resp = j.get("response", None)
    if resp == None or resp.get("result", 0) != 1:
        return None
    count = resp.get("player_count", None)
    if count == None:
        return None
    return int(count)


def fetch_store(appid):
    r = http.get(
        STORE_URL,
        headers = {
            "User-Agent": "(glance-steam-players, reyos86@github)",
            "Accept": "application/json",
        },
        params = {
            "appids": appid,
            "cc": "us",
            "filters": "basic,price_overview,genres,release_date",
        },
        ttl_seconds = 86400,
    )
    info = {
        "name": None,
        "is_free": False,
        "price": None,
        "genre": None,
        "year": None,
    }
    if r["status_code"] != 200:
        return info
    j = r["json"]
    if j == None:
        return info
    entry = j.get(appid, None)
    if entry == None or entry.get("success", False) != True:
        return info
    data = entry.get("data", None)
    if data == None:
        return info

    name = data.get("name", None)
    if name != None and str(name).strip() != "":
        info["name"] = led_text(name)

    info["is_free"] = data.get("is_free", False) == True
    info["price"] = format_price(data.get("price_overview", None))
    genre = pick_genre(data.get("genres", None))
    if genre != None:
        info["genre"] = led_text(genre)

    rel = data.get("release_date", None)
    if rel != None:
        info["year"] = release_year(rel.get("date", None))
    return info


def fetch_review_pct(appid):
    r = http.get(
        REVIEWS_URL + appid,
        headers = {
            "User-Agent": "(glance-steam-players, reyos86@github)",
            "Accept": "application/json",
        },
        params = {
            "json": "1",
            "purchase_type": "all",
            "num_per_page": "0",
            "language": "all",
        },
        ttl_seconds = 86400,
    )
    if r["status_code"] != 200:
        return None
    j = r["json"]
    if j == None:
        return None
    summary = j.get("query_summary", None)
    if summary == None:
        return None
    total = summary.get("total_reviews", 0)
    pos = summary.get("total_positive", 0)
    if total == None or pos == None:
        return None
    total = int(total)
    pos = int(pos)
    if total <= 0:
        return None
    return (pos * 100) // total


def game_name(appid, store_name):
    if store_name != None and store_name != "":
        return store_name
    if appid in KNOWN_NAMES:
        return KNOWN_NAMES[appid]
    return "APP " + appid


def review_chip(pct):
    # Steam-ish bands: positive / mixed / negative.
    if pct >= 70:
        return [str(pct) + "% POS", REVIEW_TEAL]
    if pct < 40:
        return [str(pct) + "% NEG", REVIEW_NEG]
    return [str(pct) + "% MIX", WARN]


def meta_chips(store, review_pct):
    chips = []
    if review_pct != None:
        chips.append(review_chip(review_pct))
    if store["is_free"]:
        chips.append(["F2P", PRICE_GOLD])
    elif store["price"] != None:
        chips.append([store["price"], PRICE_GOLD])
    if store["genre"] != None:
        chips.append([store["genre"], MUTED])
    if store["year"] != None:
        chips.append([store["year"], STEAM_DIM])
    return chips


def pack_chips(c, chips, maxw, font):
    out = []
    used = 0
    gap = 5
    for chip in chips:
        w = c.text_width(chip[0], font)
        need = w if used == 0 else used + gap + w
        if need > maxw:
            continue
        out.append(chip)
        used = need
    return out


def games(c, ctx):
    """Every AppID that is set, at once.

    The app used to have a single page that rotated between the configured
    games on a two-minute timer, so somebody who filled in four slots saw one
    arbitrary game and no sign of the other three -- and which one it was
    depended on the wall clock. This page answers "how are my games doing"
    without waiting, and DETAIL still gives each of them the full card.

    Only the player count is fetched here: one request per game, so four games
    cost four of the eight requests an app gets per render. Pulling the store
    and review data for all four as well would blow that limit and the page
    would fail outright."""
    picks = games_list(ctx)
    n = len(picks)
    c.fill("#0B141C")
    if n == 0:
        c.text("NO APPIDS SET", c.width // 2, 8, font = "5x7", color = WARN,
               align = "center")
        c.text("ADD ONE FROM A STORE URL", c.width // 2, 19, font = "4x5",
               color = MUTED, align = "center")
        return

    # Four rows of eight fill the panel exactly; fewer are centred so two games
    # do not sit in the top half with dead space under them.
    rows = n if n < 4 else 4
    top = (32 - rows * 8) // 2 + 1
    for i in range(rows):
        appid = picks[i]
        y = top + i * 8
        count = fetch_players(appid)
        if count != None:
            num = format_count(count)
            cw = c.text_width(num, "4x7")
            c.text(num, c.width - 2, y, font = "4x7", color = OK_GREEN,
                   align = "right")
        else:
            # One game the API would not answer for is not a broken panel: the
            # row says so and the others still report.
            num = "--"
            cw = c.text_width(num, "4x7")
            c.text(num, c.width - 2, y, font = "4x7", color = WARN,
                   align = "right")
        name = game_name(appid, None)
        if name == None or str(name).strip() == "":
            name = appid
        # fit_clip returns [font, text], not a string. Drawing the pair
        # straight out printed "'47', 'COUNTER-STRIKE 2'" across the row.
        fitted = fit_clip(c, name, c.width - 8 - cw, ["4x7", "4x5"])
        c.text(fitted[1], 2, y, font = fitted[0], color = STEAM_BLUE)

def detail(c, ctx):
    picks = games_list(ctx)
    total = len(picks)
    slot = active_slot(ctx, picks)
    appid = picks[slot]

    store = fetch_store(appid)
    name = game_name(appid, store["name"])
    count = fetch_players(appid)
    review_pct = fetch_review_pct(appid)

    c.fill("#0B141C")

    # Row 1 — brand left, genre/year in the open mid, player count right.
    c.text("STEAM", 2, 1, font = "5x7", color = STEAM_BLUE)
    left_edge = 2 + c.text_width("STEAM", "5x7") + 5
    if total > 1:
        slot_tag = "#" + str(slot + 1) + "/" + str(total)
        c.text(slot_tag, left_edge, 2, font = "4x5", color = STEAM_DIM)
        left_edge = left_edge + c.text_width(slot_tag, "4x5") + 5

    right_edge = c.width - 2
    if count != None:
        num = format_count(count)
        play = "PLAYING"
        play_w = c.text_width(play, "4x5")
        c.text(play, right_edge, 2, font = "4x5", color = STEAM_DIM, align = "right")
        c.text(num, right_edge - play_w - 3, 1, font = "6x8", color = OK_GREEN, align = "right")
        right_edge = right_edge - play_w - 3 - c.text_width(num, "6x8") - 6
    else:
        c.text("OFFLINE", right_edge, 2, font = "4x5", color = WARN, align = "right")
        right_edge = right_edge - c.text_width("OFFLINE", "4x5") - 6

    header_left = []
    if store["genre"] != None:
        header_left.append([store["genre"], MUTED])
    if store["year"] != None:
        header_left.append([store["year"], STEAM_DIM])
    fitted_header = []
    lx = left_edge
    for chip in header_left:
        w = c.text_width(chip[0], "5x7")
        if lx + w > right_edge - 4:
            break
        c.text(chip[0], lx, 1, font = "5x7", color = chip[1])
        fitted_header.append(chip[0])
        lx += w + 5

    c.line(0, 10, c.width - 1, 10, "#1B2838")

    # Row 2 — title left, review + price right (fills the open upper area).
    right_chips = []
    if review_pct != None:
        right_chips.append(review_chip(review_pct))
    if store["is_free"]:
        right_chips.append(["F2P", PRICE_GOLD])
    elif store["price"] != None:
        right_chips.append([store["price"], PRICE_GOLD])

    right_w = 0
    gap = 5
    for i in range(len(right_chips)):
        right_w += c.text_width(right_chips[i][0], "5x7")
        if i > 0:
            right_w += gap

    title_max = c.width - 6
    if right_w > 0:
        title_max = c.width - 4 - right_w - 8
    if title_max < 60:
        title_max = c.width - 4
        right_chips = []

    fitted = fit_clip(c, name, title_max, ["5x7", "4x5"])
    c.text(fitted[1], 2, 13, font = fitted[0], color = "white")

    rx = c.width - 2
    for i in range(len(right_chips) - 1, -1, -1):
        label = right_chips[i][0]
        color = right_chips[i][1]
        c.text(label, rx, 13, font = "5x7", color = color, align = "right")
        rx = rx - c.text_width(label, "5x7") - gap

    # Row 3 — leftover facts only (no AppID filler).
    bottom = []
    if store["genre"] != None and store["genre"] not in fitted_header:
        bottom.append([store["genre"], MUTED])
    if store["year"] != None and store["year"] not in fitted_header:
        bottom.append([store["year"], STEAM_DIM])
    shown_right = []
    for chip in right_chips:
        shown_right.append(chip[0])
    if review_pct != None and review_chip(review_pct)[0] not in shown_right:
        bottom = [review_chip(review_pct)] + bottom
    if store["is_free"] and "F2P" not in shown_right:
        bottom = [["F2P", PRICE_GOLD]] + bottom
    elif store["price"] != None and store["price"] not in shown_right:
        bottom = [[store["price"], PRICE_GOLD]] + bottom

    if len(bottom) > 0:
        shown = pack_chips(c, bottom, c.width - 4, "5x7")
        chip_font = "5x7"
        if len(shown) == 0:
            shown = pack_chips(c, bottom, c.width - 4, "4x5")
            chip_font = "4x5"
        x = 2
        for chip in shown:
            c.text(chip[0], x, 24, font = chip_font, color = chip[1])
            x += c.text_width(chip[0], chip_font) + 6
