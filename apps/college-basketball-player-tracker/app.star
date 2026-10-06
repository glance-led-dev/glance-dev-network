# Team Tracker (NCAAB)
# Seven compact live-stat pages: the five starters, then the top two bench scorers.

INK = "#F4F7FF"
DIM = "#738096"
LINE = "#263241"
LIVE = "#49D17D"
WARN = "#FFB347"
RED = "#FF4D5A"
DARK_LOSER = "#545B66"
ILLINOIS_PANEL = "#24344A"
ILLINOIS_BORDER = "#0B1424"

LEAGUES = {
    "MEN": "mens-college-basketball",
}

JERSEY = [
    "...SSSSSS..........SSSSSS...",
    "...SPPPPS..........SPPPPS...",
    "..SPPPPPS..........SPPPPPS..",
    "..SPPPPPPS........SPPPPPPS..",
    "..SPPPPPPS........SPPPPPPS..",
    ".SPPPPPPPPS......SPPPPPPPPS.",
    ".SPPPPPPPPPS....SPPPPPPPPPS.",
    "SPPPPPPPPPPPSSSSPPPPPPPPPPPS",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DLPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "DPPPPPPPPPPPPPPPPPPPPPPPPPPD",
    "SSSSSSSSSSSSSSSSSSSSSSSSSSSS",
    "WWWWWWWWWWWWWWWWWWWWWWWWWWWW",
    "SSSSSSSSSSSSSSSSSSSSSSSSSSSS",
    ".DDDDDDDDDDDDDDDDDDDDDDDDDD.",
]

# Editable 20x20 jersey artwork used by the player pages.
# P = team primary color, D = dark team outline, W = white trim, . = transparent.
NATIVE_JERSEY_20 = [
    "....................",
    "....DDDD....DDDD....",
    "....DPPPD..DPPPD....",
    "....DPPPD..DPPPD....",
    "....DPPPD..DPPPD....",
    "....DPPPD..DPPPD....",
    "...DDPPPWDDWPPPDD...",
    "...DPPPPPWWPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DPPPPPPPPPPPPD...",
    "...DDDDDDDDDDDDDD...",
]

DIGITS = {
    "0": [".XXXX.", "XXXXXX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX."],
    "1": ["..XX..", ".XXX..", "XXXX..", "..XX..", "..XX..", "..XX..", "..XX..", "..XX..", "..XX..", "XXXXXX", "XXXXXX"],
    "2": [".XXXX.", "XXXXXX", "XX..XX", "....XX", "...XXX", "..XXX.", ".XXX..", "XXX...", "XX....", "XXXXXX", "XXXXXX"],
    "3": [".XXXX.", "XXXXXX", "XX..XX", "....XX", "..XXX.", "..XXX.", "....XX", "....XX", "XX..XX", "XXXXXX", ".XXXX."],
    "4": ["...XX.", "..XXX.", ".XXXX.", "XX.XX.", "XX.XX.", "XXXXXX", "XXXXXX", "...XX.", "...XX.", "...XX.", "...XX."],
    "5": ["XXXXXX", "XXXXXX", "XX....", "XX....", "XXXXX.", "XXXXXX", "....XX", "....XX", "XX..XX", "XXXXXX", ".XXXX."],
    "6": [".XXXX.", "XXXXXX", "XX....", "XX....", "XXXXX.", "XXXXXX", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX."],
    "7": ["XXXXXX", "XXXXXX", "....XX", "....XX", "...XX.", "...XX.", "..XX..", "..XX..", "..XX..", "..XX..", "..XX.."],
    "8": [".XXXX.", "XXXXXX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX.", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXX."],
    "9": [".XXXX.", "XXXXXX", "XX..XX", "XX..XX", "XX..XX", "XXXXXX", ".XXXXX", "....XX", "....XX", "XXXXXX", ".XXXX."],
}

def clean(value, fallback = ""):
    text = str(value if value != None else "").strip()
    return text if text != "" else fallback

def upper(value, fallback = ""):
    return clean(value, fallback).upper()

def hex_color(value, fallback):
    text = clean(value).replace("#", "")
    return "#" + text if len(text) == 6 else fallback

HEX = {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15}
HEX_CHARS = "0123456789ABCDEF"

def channel(text, offset):
    value = upper(text).replace("#", "")
    if len(value) != 6:
        return 0
    return HEX.get(value[offset], 0) * 16 + HEX.get(value[offset + 1], 0)

def rgb_hex(red, green, blue):
    return "#" + HEX_CHARS[red // 16] + HEX_CHARS[red % 16] + HEX_CHARS[green // 16] + HEX_CHARS[green % 16] + HEX_CHARS[blue // 16] + HEX_CHARS[blue % 16]

def darker_team_color(team):
    primary = hex_color(team.get("color"), "#263241")
    alternate = hex_color(team.get("alternateColor"), "#263241")
    candidates = []
    for color_value in [primary, alternate]:
        red = channel(color_value, 0)
        green = channel(color_value, 2)
        blue = channel(color_value, 4)
        brightness = red + green + blue
        orange_or_yellow = red > 150 and green > 65 and blue < 120
        white_or_bright = brightness > 480
        if not orange_or_yellow and not white_or_bright:
            candidates.append(color_value)
    if len(candidates) == 0:
        return ILLINOIS_PANEL
    chosen = candidates[0]
    chosen_sum = channel(chosen, 0) + channel(chosen, 2) + channel(chosen, 4)
    for candidate in candidates[1:]:
        candidate_sum = channel(candidate, 0) + channel(candidate, 2) + channel(candidate, 4)
        if candidate_sum < chosen_sum:
            chosen = candidate
            chosen_sum = candidate_sum
    return chosen

def team_tint(team_color, base_color):
    return rgb_hex(
        (channel(team_color, 0) + channel(base_color, 0) * 2) // 3,
        (channel(team_color, 2) + channel(base_color, 2) * 2) // 3,
        (channel(team_color, 4) + channel(base_color, 4) * 2) // 3,
    )

def dark_fill(color_value):
    return rgb_hex(channel(color_value, 0) // 5, channel(color_value, 2) // 5, channel(color_value, 4) // 5)

def color_brightness(color_value):
    return (channel(color_value, 0) * 299 + channel(color_value, 2) * 587 + channel(color_value, 4) * 114) // 1000

def readable_team_accent(team, background):
    # Keep the official primary hue whenever it reads clearly. Very dark team
    # colors are lifted toward white for tiny LED text without changing the
    # darker school-color background, dividers, border, or jersey treatment.
    if str(team.get("id")) == "57":
        return hex_color(team.get("alternateColor"), "#FA4616")
    primary = hex_color(team.get("color"), "#738096")
    difference = color_brightness(primary) - color_brightness(background)
    if difference < 0:
        difference = -difference
    if difference >= 120:
        return primary
    alternate = hex_color(team.get("alternateColor"), "#738096")
    alternate_difference = color_brightness(alternate) - color_brightness(background)
    if alternate_difference < 0:
        alternate_difference = -alternate_difference
    alternate_channels = [channel(alternate, 0), channel(alternate, 2), channel(alternate, 4)]
    alternate_max = max(alternate_channels)
    alternate_min = min(alternate_channels)
    # Use a real school secondary when it is both readable and visibly colored.
    # Neutral white/gray alternates are skipped so the page retains team identity.
    if alternate_difference >= 120 and alternate_max - alternate_min >= 40:
        return alternate
    return rgb_hex(
        (channel(primary, 0) + 255 * 3) // 4,
        (channel(primary, 2) + 255 * 3) // 4,
        (channel(primary, 4) + 255 * 3) // 4,
    )

def official_team_accent(team, background):
    # Team abbreviations must use an exact official color, never a generated
    # tint. Pick whichever of the primary or secondary reads best on the page.
    primary = hex_color(team.get("color"), INK)
    alternate = hex_color(team.get("alternateColor"), INK)
    background_brightness = color_brightness(background)
    primary_contrast = abs(color_brightness(primary) - background_brightness)
    alternate_contrast = abs(color_brightness(alternate) - background_brightness)
    return alternate if alternate_contrast > primary_contrast else primary

def get_json(url, ttl):
    response = http.get(url, ttl_seconds = ttl)
    if response.get("status_code", 0) != 200:
        return None
    return response.get("json")

def resolve_team(league, query):
    wanted = upper(query, "ILLINOIS")
    data = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/teams?limit=500" % league, 86400)
    if data == None:
        return None
    teams = (((data.get("sports") or [{}])[0].get("leagues") or [{}])[0].get("teams") or [])
    partial = None
    for wrapped in teams:
        team = wrapped.get("team") or {}
        names = [upper(team.get("displayName")), upper(team.get("location")), upper(team.get("shortDisplayName")), upper(team.get("nickname")), upper(team.get("abbreviation"))]
        if wanted in names:
            return team
        if partial == None:
            for name in names:
                if wanted in name:
                    partial = team
    return partial

def find_event(league, team_id):
    data = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/scoreboard" % league, 45)
    if data == None:
        return None
    for event in data.get("events", []):
        competition = (event.get("competitions") or [{}])[0]
        for competitor in competition.get("competitors", []):
            if str((competitor.get("team") or {}).get("id")) == team_id:
                return str(event.get("id"))
    return None

def stat_map(table):
    result = {}
    labels = table.get("labels", [])
    for index in range(len(labels)):
        result[str(labels[index]).upper()] = index
    return result

def stat_value(row, indexes, key, fallback = "0"):
    index = indexes.get(key)
    values = row.get("stats", [])
    if index == None or index >= len(values):
        return fallback
    return clean(values[index], fallback)

def average_value(categories, key, fallback = "0.0"):
    for category in categories:
        for item in category.get("stats", []):
            if item.get("name") == key:
                return clean(item.get("displayValue"), fallback)
    return fallback

def tenths(value):
    text = clean(value, "0").split(".")
    whole = int(text[0]) if text[0].isdigit() else 0
    decimal = int(text[1][0]) if len(text) > 1 and len(text[1]) > 0 and text[1][0].isdigit() else 0
    return whole * 10 + decimal

def athlete_position(athlete):
    position = athlete.get("position") or {}
    return upper(position.get("abbreviation") or position.get("name"))

def athlete_height(athlete):
    # ESPN normally supplies displayHeight (for example 6' 6\"). Compact it
    # for the 128-pixel header so it reads cleanly beside the player name.
    height = upper(athlete.get("displayHeight") or athlete.get("height"))
    return height.replace("' ", "'").replace("\"", "").replace(" ", "")

def athlete_bio(athlete):
    position = athlete_position(athlete)
    height = athlete_height(athlete)
    if position != "" and height != "":
        return position + " " + height
    return position if position != "" else height

def athlete_weight(athlete):
    weight = upper(athlete.get("displayWeight") or athlete.get("weight"))
    return weight.replace("POUNDS", "").replace("LBS", "").replace("LB", "").strip()

def athlete_year(athlete):
    experience = athlete.get("experience") or {}
    value = upper(experience.get("abbreviation") or experience.get("displayValue") or athlete.get("class"))
    classes = {
        "FRESHMAN": "FR",
        "SOPHOMORE": "SO",
        "JUNIOR": "JR",
        "SENIOR": "SR",
        "GRADUATE": "GR",
        "GRADUATE STUDENT": "GR",
    }
    return classes.get(value, value)

def athlete_extra_bio(athlete):
    return athlete_year(athlete)

def season_data(league, team):
    team_id = str(team.get("id"))
    roster = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/teams/%s/roster" % (league, team_id), 21600)
    if roster == None:
        return {"error": "ROSTER OFFLINE"}
    roster_info = {}
    for athlete in (roster.get("athletes") or []):
        athlete_id = str(athlete.get("id"))
        roster_info[athlete_id] = {
            "name": upper(athlete.get("shortName") or athlete.get("displayName") or athlete.get("fullName"), "PLAYER"),
            "jersey": clean(athlete.get("jersey"), "0"),
            "bio": athlete_bio(athlete),
            "extra_bio": athlete_extra_bio(athlete),
        }
    slug = clean(team.get("slug"), team_id)
    page_url = "https://www.espn.com/%s/team/stats/_/id/%s/%s" % (league, team_id, slug)
    response = http.get(page_url, headers = {"User-Agent": "Mozilla/5.0 (compatible; Glance College Basketball Tracker)"}, ttl_seconds = 21600)
    if response.get("status_code", 0) != 200:
        return {"error": "AVERAGES OFFLINE"}
    body = clean(response.get("body"))
    marker = "window['__espnfitt__']="
    if marker not in body:
        return {"error": "AVERAGES NOT POSTED"}
    payload = body.split(marker, 1)[1].split(";</script>", 1)[0]
    document = json.decode(payload)
    rows = (((((document.get("page") or {}).get("content") or {}).get("stats") or {}).get("playerStats") or [[]])[0])
    players = []
    players_with_stats = []
    for row in rows:
        athlete = row.get("athlete") or {}
        athlete_id = clean(athlete.get("uid")).split("~a:")[-1]
        # The ESPN averages page can retain last season's departed players while
        # the roster endpoint has already rolled forward. Only join rows whose
        # athlete ID is still on the selected team's current roster.
        if athlete_id not in roster_info:
            continue
        players_with_stats.append(athlete_id)
        values = {}
        for item in ((row.get("statGroups") or {}).get("stats") or []):
            values[item.get("name")] = clean(item.get("displayValue"), "0.0")
        players.append({
            "id": athlete_id,
            "name": upper(athlete.get("shortName") or athlete.get("name"), "PLAYER"),
            "jersey": roster_info.get(athlete_id, {}).get("jersey", ""),
            "bio": roster_info.get(athlete_id, {}).get("bio", ""),
            "extra_bio": roster_info.get(athlete_id, {}).get("extra_bio", ""),
            "starter": False,
            "min": values.get("avgMinutes", "0.0"),
            "pts": values.get("avgPoints", "0.0"),
            "reb": values.get("avgRebounds", "0.0"),
            "ast": values.get("avgAssists", "0.0"),
            "stl": values.get("avgSteals", "0.0"),
            "blk": values.get("avgBlocks", "0.0"),
            "fg": values.get("fieldGoalPct", "-")
        })
    # Before the first game, ESPN often publishes averages for only a handful
    # of returning players. Keep the seven-page rotation complete by adding
    # the remaining current-roster players with zero averages until they have
    # a season stat row of their own.
    for athlete_id in roster_info:
        if athlete_id in players_with_stats:
            continue
        info = roster_info[athlete_id]
        players.append({
            "id": athlete_id,
            "name": info.get("name", "PLAYER"),
            "jersey": info.get("jersey", ""),
            "bio": info.get("bio", ""),
            "extra_bio": info.get("extra_bio", ""),
            "starter": False,
            "min": "0.0",
            "pts": "0.0",
            "reb": "0.0",
            "ast": "0.0",
            "stl": "0.0",
            "blk": "0.0",
            "fg": "-",
        })
    return {"players": players, "team": team, "opponent": {}, "team_score": "", "opponent_score": "", "state": "AVG", "detail": "SEASON AVERAGES", "mode": "AVERAGES"}

def game_data(ctx):
    league = LEAGUES.get(upper(ctx.inputs.get("league"), "MEN"), LEAGUES["MEN"])
    selected_team = resolve_team(league, ctx.inputs.get("team"))
    if selected_team == None:
        return {"error": "SCHOOL NOT FOUND"}
    team_id = str(selected_team.get("id"))
    event_id = upper(ctx.inputs.get("event"), "AUTO")
    if event_id == "AUTO":
        event_id = find_event(league, team_id)
    if event_id == None:
        return season_data(league, selected_team)
    data = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/summary?event=%s" % (league, event_id), 30)
    if data == None:
        return {"error": "GAME DATA OFFLINE"}

    competition = ((data.get("header") or {}).get("competitions") or [{}])[0]
    team = None
    opponent = None
    for competitor in competition.get("competitors", []):
        if str((competitor.get("team") or {}).get("id")) == team_id:
            team = competitor
        else:
            opponent = competitor
    if team == None:
        return {"error": "TEAM NOT IN GAME"}

    # ESPN's box-score athletes often omit position, height, class, and even
    # jersey number. Join the current roster so live/final pages retain the
    # same complete player header shown on season-average pages.
    roster_info = {}
    roster = get_json("https://site.api.espn.com/apis/site/v2/sports/basketball/%s/teams/%s/roster" % (league, team_id), 21600)
    if roster != None:
        for roster_athlete in (roster.get("athletes") or []):
            roster_id = str(roster_athlete.get("id"))
            roster_info[roster_id] = {
                "jersey": clean(roster_athlete.get("jersey"), ""),
                "bio": athlete_bio(roster_athlete),
                "extra_bio": athlete_extra_bio(roster_athlete),
            }

    table = None
    for group in (data.get("boxscore") or {}).get("players", []):
        if str((group.get("team") or {}).get("id")) == team_id:
            tables = group.get("statistics") or []
            if len(tables) > 0:
                table = tables[0]
    if table == None:
        return {"error": "STATS NOT POSTED"}

    indexes = stat_map(table)
    players = []
    for row in table.get("athletes", []):
        athlete = row.get("athlete") or {}
        athlete_id = str(athlete.get("id"))
        roster_athlete = roster_info.get(athlete_id, {})
        minutes = stat_value(row, indexes, "MIN", "0")
        if row.get("didNotPlay", False) or minutes == "0" or minutes == "0:00" or minutes == "--":
            continue
        players.append({
            "id": athlete_id,
            "name": upper(athlete.get("shortName") or athlete.get("displayName"), "PLAYER"),
            "jersey": clean(athlete.get("jersey"), roster_athlete.get("jersey", "")),
            "bio": athlete_bio(athlete) or roster_athlete.get("bio", ""),
            "extra_bio": athlete_extra_bio(athlete) or roster_athlete.get("extra_bio", ""),
            "starter": row.get("starter", False) == True,
            "min": minutes,
            "pts": stat_value(row, indexes, "PTS"),
            "reb": stat_value(row, indexes, "REB"),
            "ast": stat_value(row, indexes, "AST"),
            "stl": stat_value(row, indexes, "STL"),
            "blk": stat_value(row, indexes, "BLK"),
            "fg": stat_value(row, indexes, "FG", "-")
        })

    status = competition.get("status") or {}
    status_type = status.get("type") or {}
    state = upper(status_type.get("state"), "PRE")
    detail = upper(status_type.get("shortDetail") or status_type.get("detail"), "SCHEDULED")
    return {
        "players": players,
        "team": team.get("team") or {},
        "opponent": (opponent or {}).get("team") or {},
        "team_score": clean(team.get("score"), "0"),
        "opponent_score": clean((opponent or {}).get("score"), "0"),
        "state": state,
        "detail": detail,
        "period": int(status.get("period") or 0),
        "clock": clean(status.get("displayClock")),
        "mode": "GAME",
    }

def points_value(item):
    text = clean(item.get("pts"), "0")
    return tenths(text)

def lineup(game):
    players = game.get("players", [])
    if game.get("mode") == "GAME":
        starters = []
        bench = []
        for item in players:
            if item.get("starter", False):
                starters.append(item)
            else:
                bench.append(item)
        if len(starters) >= 5:
            ordered = starters[:5]
            selected = []
            for slot in range(2):
                best = None
                for item in bench:
                    if item["id"] in selected:
                        continue
                    if best == None or points_value(item) > points_value(best):
                        best = item
                if best != None:
                    ordered.append(best)
                    selected.append(best["id"])
            # The seven selected players are displayed in scoring order, while
            # selection itself remains the five starters plus two bench leaders.
            ranked = []
            ranked_ids = []
            for slot in range(len(ordered)):
                best = None
                for item in ordered:
                    if item["id"] in ranked_ids:
                        continue
                    if best == None or points_value(item) > points_value(best):
                        best = item
                if best != None:
                    ranked.append(best)
                    ranked_ids.append(best["id"])
            return ranked
    ordered = []
    selected = []
    for slot in range(7):
        best = None
        for item in players:
            if item["id"] in selected:
                continue
            if best == None or points_value(item) > points_value(best):
                best = item
        if best != None:
            ordered.append(best)
            selected.append(best["id"])
    return ordered

def draw_jersey(c, x, y, primary, shade, trim, number):
    palette = {"P": primary, "D": shade, "L": primary, "S": trim, "W": INK}
    # Layer the compressed artwork so the 18px body cannot overwrite its own
    # dark edge or bright trim when multiple source pixels land on one pixel.
    for layer in [["P", "L"], ["D"], ["S", "W"]]:
        for row in range(len(JERSEY)):
            for column in range(len(JERSEY[row])):
                pixel = JERSEY[row][column]
                if pixel in layer:
                    c.pixel(x + (column * 3) // 5, y + (row * 3) // 5, palette.get(pixel, primary))
    digits = clean(number)[-2:]
    if digits != "":
        center_x = x + 8 if len(digits) > 1 else x + 9
        number_y = y + 7
        c.text(digits, center_x - 1, number_y, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x + 1, number_y, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x, number_y - 1, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x, number_y + 1, font = "4x5", color = shade, align = "center")
        c.text(digits, center_x, number_y, font = "4x5", color = INK, align = "center")

def draw_small_number(c, number, center_x, y, shade):
    digits = clean(number)[-2:]
    if digits == "":
        return
    if len(digits) > 1:
        center_x -= 1
    # Use the native eight-direction stroke so diagonal corners are complete
    # and the small jersey number reads as one clean outlined glyph.
    c.text_stroke(digits, center_x, y, font = "4x5", color = INK, stroke = shade, thickness = 1, align = "center")

def draw_native_jersey(c, x, y, primary, shade, background, number):
    palette = {"P": primary, "D": shade, "W": INK}
    for row in range(len(NATIVE_JERSEY_20)):
        for column in range(len(NATIVE_JERSEY_20[row])):
            pixel = NATIVE_JERSEY_20[row][column]
            if pixel != ".":
                c.pixel(x + column, y + row, palette[pixel])
    draw_small_number(c, number, x + 10, y + 10, shade)

def draw_minimal_jersey(c, x, y, primary, shade, background, number):
    # Same basketball-tank silhouette without bright trim details.
    c.rect(x + 3, y + 6, x + 14, y + 17, fill = shade)
    c.rect(x + 4, y + 1, x + 7, y + 8, fill = shade)
    c.rect(x + 10, y + 1, x + 13, y + 8, fill = shade)
    c.rect(x + 4, y + 7, x + 13, y + 16, fill = primary)
    c.rect(x + 5, y + 2, x + 6, y + 7, fill = primary)
    c.rect(x + 11, y + 2, x + 12, y + 7, fill = primary)
    c.pixel(x + 7, y + 2, background)
    c.pixel(x + 10, y + 2, background)
    c.pixel(x + 8, y + 3, background)
    c.pixel(x + 9, y + 3, background)
    draw_small_number(c, number, x + 9, y + 9, shade)

def draw_number_badge(c, x, y, primary, shade, number):
    c.round_rect(x + 2, y + 1, x + 16, y + 17, 3, fill = primary, outline = shade)
    draw_small_number(c, number, x + 9, y + 7, shade)

def fit(c, text, x, y, width, font, color_value):
    value = upper(text)
    fitted = value
    for size in range(len(value), 0, -1):
        candidate = value[:size]
        if c.text_width(candidate, font) <= width:
            fitted = candidate
            break
    c.text(fitted, x, y, font = font, color = color_value)
    return c.text_width(fitted, font)

def compact_bio_width(c, bio):
    if "'" not in bio:
        return c.text_width(bio, "picopixel")
    parts = bio.split("'", 1)
    return c.text_width(parts[0], "picopixel") + 3 + c.text_width(parts[1], "picopixel")

def draw_compact_bio(c, bio, x, y, color_value):
    if "'" not in bio:
        c.text(bio, x, y, font = "picopixel", color = color_value)
        return
    # picopixel has no visible apostrophe glyph, so reserve two pixels and
    # draw the height mark directly between the feet and inches digits.
    parts = bio.split("'", 1)
    left_width = c.text_width(parts[0], "picopixel")
    c.text(parts[0], x, y, font = "picopixel", color = color_value)
    mark_x = x + left_width + 1
    c.pixel(mark_x, y, color_value)
    c.pixel(mark_x, y + 1, color_value)
    c.text(parts[1], mark_x + 2, y, font = "picopixel", color = color_value)

def error_page(c, message):
    c.fill("black")
    c.rect(0, 0, 127, 31, outline = LINE)
    c.text("COLLEGE HOOPS", 64, 5, font = "5x7", color = WARN, align = "center")
    c.text(message, 64, 18, font = "4x5", color = DIM, align = "center")

def score_number(value):
    text = clean(value, "0")
    return int(text) if text.isdigit() else 0

def draw_team_logo(c, team, x, y, line_color):
    team_id = str(team.get("id"))
    if team_id != "":
        c.image(team_id + ".png", x, y, w = 11, h = 9)
        return
    abbreviation = upper(team.get("abbreviation"), "T")[:2]
    c.rect(x, y, x + 10, y + 8, fill = dark_fill(line_color), outline = line_color)
    c.text(abbreviation, x + 5, y + 2, font = "3x4", color = INK, align = "center")

def draw_stat(c, label, value, x, label_y, value_y, value_font, value_color):
    c.text(label, x, label_y, font = "3x4", color = DIM)
    if clean(value) != "":
        c.text(clean(value), x, value_y, font = value_font, color = value_color)

def player_page(c, ctx, page_index, force_average = False, preview_game = False, mark_style = "native"):
    if force_average:
        selected_team = resolve_team(LEAGUES["MEN"], ctx.inputs.get("team"))
        game = season_data(LEAGUES["MEN"], selected_team) if selected_team != None else {"error": "SCHOOL NOT FOUND"}
    else:
        game = game_data(ctx)
    if preview_game and game.get("error") == None and game.get("mode") == "AVERAGES":
        game["mode"] = "GAME"
        game["opponent"] = {"abbreviation": "OPP"}
        game["team_score"] = "58"
        game["opponent_score"] = "52"
        game["state"] = "IN"
        game["period"] = 1
        game["clock"] = "8:42"
    if game.get("error") != None:
        error_page(c, game["error"])
        return
    players = lineup(game)
    if page_index >= len(players):
        error_page(c, "LINEUP NOT POSTED")
        return
    athlete = players[page_index]

    team = game["team"]
    primary = hex_color(team.get("color"), "#1F5AA6")
    safe_team_color = darker_team_color(team)
    line_color = team_tint(safe_team_color, ILLINOIS_BORDER)
    background = team_tint(safe_team_color, ILLINOIS_PANEL)
    if str(team.get("id")) == "356":
        line_color = ILLINOIS_BORDER
        background = ILLINOIS_PANEL
    if str(team.get("id")) == "2305":
        # Kansas needs a visibly blue panel rather than a nearly neutral navy.
        line_color = team_tint(primary, ILLINOIS_BORDER)
        background = rgb_hex(
            (channel(primary, 0) + channel(ILLINOIS_PANEL, 0)) // 2,
            (channel(primary, 2) + channel(ILLINOIS_PANEL, 2)) // 2,
            (channel(primary, 4) + channel(ILLINOIS_PANEL, 4)) // 2,
        )
    accent = readable_team_accent(team, background)
    if str(team.get("id")) == "356":
        accent = primary
    # vline's third argument is its pixel length, not its ending y coordinate.
    divider_height = 20 if game.get("mode") == "AVERAGES" else 15
    c.fill(background)
    c.rect(0, 0, 127, 31, outline = line_color)
    # The featured PTS box keeps its full-height borders on both sides.
    c.vline(17, 11, 20, line_color)
    c.vline(47, 11, 20, line_color)
    # Keep points in the wide feature box and divide the remaining stat area evenly.
    c.vline(67, 11, divider_height, line_color)
    c.vline(87, 11, divider_height, line_color)
    c.vline(107, 11, divider_height, line_color)
    if mark_style == "badge":
        draw_number_badge(c, 4, 12, primary, line_color, athlete["jersey"])
    elif mark_style == "minimal":
        draw_minimal_jersey(c, 4, 12, primary, line_color, background, athlete["jersey"])
    else:
        draw_native_jersey(c, -1, 11, primary, line_color, background, athlete["jersey"])
    bio = clean(athlete.get("bio"))
    bio_width = compact_bio_width(c, bio) if bio != "" else 0
    # Keep the name on its original baseline. Height and position sit beside
    # it in the same compact font used by the stat-category labels.
    name_width = 111 if bio == "" else 107 - bio_width
    rendered_name_width = fit(c, athlete["name"], 2, 2, name_width, "5x7", INK)
    if bio != "":
        bio_x = 2 + rendered_name_width + 6
        draw_compact_bio(c, bio, bio_x, 4, accent)
        extra_bio = clean(athlete.get("extra_bio"))
        extra_x = bio_x + bio_width + 4
        available_extra_width = 114 - extra_x
        if extra_bio != "" and c.text_width(extra_bio, "picopixel") <= available_extra_width:
            c.text(extra_bio, extra_x, 4, font = "picopixel", color = accent)
    draw_team_logo(c, team, 115, 1, line_color)
    c.hline(1, 10, 126, line_color)

    # Match the compact rank/rating labels from the Illinois Team Page.
    c.text("PTS", 32, 12, font = "picopixel", color = accent, align = "center")
    c.text("REB", 57, 12, font = "picopixel", color = accent, align = "center")
    c.text("AST", 77, 12, font = "picopixel", color = accent, align = "center")
    c.text("STL", 97, 12, font = "picopixel", color = accent, align = "center")
    c.text("BLK", 117, 12, font = "picopixel", color = accent, align = "center")

    if game.get("mode") == "AVERAGES":
        stat_values = {
            "pts": clean(athlete.get("pts"), "0.0"),
            "reb": clean(athlete.get("reb"), "0.0"),
            "ast": clean(athlete.get("ast"), "0.0"),
            "stl": clean(athlete.get("stl"), "0.0"),
            "blk": clean(athlete.get("blk"), "0.0"),
        }
        pts_y = 19
        pts_font = "6x8"
        secondary_y = 21
    else:
        stat_values = {
            "pts": clean(athlete.get("pts"), "0"),
            "reb": clean(athlete.get("reb"), "0"),
            "ast": clean(athlete.get("ast"), "0"),
            "stl": clean(athlete.get("stl"), "0"),
            "blk": clean(athlete.get("blk"), "0"),
        }
        pts_y = 20
        pts_font = "7x12"
        secondary_y = 19
    c.text(stat_values["pts"], 32, pts_y, font = pts_font, color = INK, align = "center")
    c.text(stat_values["reb"], 57, secondary_y, font = "4x5", color = INK, align = "center")
    c.text(stat_values["ast"], 77, secondary_y, font = "4x5", color = INK, align = "center")
    c.text(stat_values["stl"], 97, secondary_y, font = "4x5", color = INK, align = "center")
    c.text(stat_values["blk"], 117, secondary_y, font = "4x5", color = INK, align = "center")

    if game.get("mode") == "AVERAGES":
        return

    # Separate the live/final score strip from the stat grid above it.
    c.hline(48, 25, 126, line_color)

    team_abbr = upper(game["team"].get("abbreviation"), "TEAM")[:3]
    opponent_abbr = upper(game["opponent"].get("abbreviation"), "OPP")[:3]
    team_abbr_color = official_team_accent(game["team"], background)
    opponent_abbr_color = official_team_accent(game["opponent"], background)
    if game["state"] == "IN":
        team_score_color = INK
        opponent_score_color = INK
        status_color = LIVE
        period = int(game.get("period") or 0)
        period_label = "1H" if period == 1 else "2H" if period == 2 else "OT" if period > 2 else "LIVE"
        short_status = clean(game.get("clock"))
        status_font = "picopixel"
        status_x = 126
    elif game["state"] == "POST":
        team_total = score_number(game["team_score"])
        opponent_total = score_number(game["opponent_score"])
        team_score_color = LIVE if team_total > opponent_total else DARK_LOSER if team_total < opponent_total else DIM
        opponent_score_color = LIVE if opponent_total > team_total else DARK_LOSER if opponent_total < team_total else DIM
        status_color = RED
        short_status = "FINAL"
        status_font = "3x4"
        status_x = 126
    else:
        team_score_color = DIM
        opponent_score_color = DIM
        status_color = WARN
        short_status = "NEXT"
        status_font = "3x4"
        status_x = 126
    c.text(team_abbr, 50, 26, font = "picopixel", color = team_abbr_color)
    c.text(game["team_score"], 63, 26, font = "picopixel", color = team_score_color)
    c.text(opponent_abbr, 74, 26, font = "picopixel", color = opponent_abbr_color)
    c.text(game["opponent_score"], 87, 26, font = "picopixel", color = opponent_score_color)
    if game["state"] == "IN":
        c.text(period_label, 98, 26, font = "picopixel", color = status_color)
    c.text(short_status, status_x, 26, font = status_font, color = status_color, align = "right")

def player_1(c, ctx):
    player_page(c, ctx, 0, False, False, "native")

def player_2(c, ctx):
    player_page(c, ctx, 1, False, False, "native")

def player_3(c, ctx):
    player_page(c, ctx, 2, False, False, "native")

def player_4(c, ctx):
    player_page(c, ctx, 3, False, False, "native")

def player_5(c, ctx):
    player_page(c, ctx, 4, False, False, "native")

def player_6(c, ctx):
    player_page(c, ctx, 5, False, False, "native")

def player_7(c, ctx):
    player_page(c, ctx, 6, False, False, "native")
