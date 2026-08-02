# NASCAR Companion — live Cup / Xfinity / Trucks race board (192x32).
# Data from NASCAR's public Content Feed CDN (cf.nascar.com). Car badges are
# bundled assets; flag icons and checkered chrome ship with the app.

SERIES_IDS = {
    "CUP": 1,
    "XFINITY": 2,
    "TRUCKS": 3,
}

SERIES_SHORT = {
    "CUP": "CUP",
    "XFINITY": "XFY",
    "TRUCKS": "TRK",
}

FLAG_LABEL = {
    1: "GREEN",
    2: "YELLOW",
    3: "RED",
    4: "WHITE",
    5: "CHECKER",
    8: "WARMUP",
    9: "FINISH",
}

FLAG_ASSET = {
    1: "flag-green.png",
    2: "flag-yellow.png",
    3: "flag-red.png",
    4: "flag-white.png",
    5: "flag-checkered.png",
    8: "flag-blue.png",
    9: "flag-checkered.png",
}

FLAG_COLOR = {
    1: "#22C55E",
    2: "#FACC15",
    3: "#EF4444",
    4: "#F8FAFC",
    # Checkered / official finish — light silver (not purple).
    5: "#E2E8F0",
    8: "#38BDF8",
    9: "#E2E8F0",
}

# Approximate OEM accents (CF uses Tyt / Frd / Chv).
MFG_COLOR = {
    "TYT": "#E10600",
    "TOYOTA": "#E10600",
    "FRD": "#003478",
    "FORD": "#003478",
    "CHV": "#D4A017",
    "CHEVY": "#D4A017",
    "CHEVROLET": "#D4A017",
}

MONTHS = ["", "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
          "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

COLORS = {
    "bg": "#07090D",
    "panel": "#141A22",
    "rail": "#1C2430",
    "line": "#2A3544",
    "text": "#F4F7FB",
    "muted": "#8B9BB0",
    "accent": "#FF6A00",
    "accent2": "#FFD166",
    "error": "#FF5D73",
}


def safe_input(ctx, key, fallback):
    value = ctx.inputs.get(key, fallback)
    if value == None or value == "":
        return fallback
    return value


def clean_name(raw):
    name = str(raw).strip()
    if len(name) > 0 and name[0] == "*":
        name = name[1:].strip()
    cleaned = ""
    for i in range(len(name)):
        if name[i] == "(":
            break
        cleaned += name[i]
    name = cleaned.strip()
    parts = name.split(" ")
    if len(parts) == 0:
        return "?"
    return parts[len(parts) - 1].upper()


def short_track(name):
    text = str(name).upper()
    text = text.replace(" INTERNATIONAL SPEEDWAY", "")
    text = text.replace(" MOTOR SPEEDWAY", "")
    text = text.replace(" RACEWAY", "")
    text = text.replace(" SPEEDWAY", "")
    text = text.replace(" SUPER SPEEDWAY", "")
    text = text.replace(" SUPERSPEEDWAY", "")
    if len(text) > 16:
        text = text[:16]
    return text


def short_race(name, limit = 20):
    text = str(name).upper()
    text = text.replace(" PRESENTED BY PPG", "")
    text = text.replace(" PRESENTED BY ", " ")
    text = text.replace(" POWERED BY ETHANOL", "")
    text = text.replace(" POWERED BY ", " ")
    text = text.replace(" AVAILABLE AT WALMART", "")
    text = text.replace(" AVAILABLE AT ", " ")
    text = text.replace("  ", " ").strip()
    if len(text) > limit:
        text = text[:limit].strip()
    return text


def format_gap(delta, position):
    if position == 1 or delta == None:
        return "LEAD"
    value = float(delta)
    if value < 0:
        value = -value
    if value >= 100:
        return "+" + str(int(value + 0.5))
    if value >= 10:
        tenths = int(value * 10 + 0.5)
        return "+" + str(tenths // 10) + "." + str(tenths % 10)
    hundredths = int(value * 100 + 0.5)
    whole = hundredths // 100
    frac = hundredths % 100
    frac_s = str(frac)
    if frac < 10:
        frac_s = "0" + frac_s
    return "+" + str(whole) + "." + frac_s


def format_date(value):
    text = str(value)
    if len(text) < 10:
        return text.upper()
    month = int(text[5:7])
    day = int(text[8:10])
    label = MONTHS[month] if month >= 1 and month <= 12 else text[5:7]
    return label + " " + str(day)


def flag_label(state):
    return FLAG_LABEL.get(state, "FLAG")


def flag_color(state):
    return FLAG_COLOR.get(state, COLORS["muted"])


def flag_asset(state):
    return FLAG_ASSET.get(state, "flag-checkered.png")


def draw_flag_icon(c, state, x, y):
    # Literal asset names so `gdn check` can see them; mirrors FLAG_ASSET.
    if state == 1:
        c.image("flag-green.png", x, y, w = 10, h = 10)
    elif state == 2:
        c.image("flag-yellow.png", x, y, w = 10, h = 10)
    elif state == 3:
        c.image("flag-red.png", x, y, w = 10, h = 10)
    elif state == 4:
        c.image("flag-white.png", x, y, w = 10, h = 10)
    elif state == 8:
        c.image("flag-blue.png", x, y, w = 10, h = 10)
    else:
        c.image("flag-checkered.png", x, y, w = 10, h = 10)


def mfg_color(code):
    return MFG_COLOR.get(str(code).upper(), COLORS["accent"])


def http_json(url, ttl):
    response = http.get(url, ttl_seconds = ttl)
    status = response["status_code"]
    if status != 200:
        return {"ok": False, "status": status}
    data = response["json"]
    if data == None:
        return {"ok": False, "status": status}
    return {"ok": True, "status": status, "data": data}


def series_key(name):
    return "series_" + str(SERIES_IDS.get(str(name).upper(), 1))


def pick_races(schedule, series_name, mode):
    key = series_key(series_name)
    races = schedule.get(key, [])
    unfinished = []
    finished = []
    for race in races:
        winner = race.get("winner_driver_id", 0)
        if winner == None or winner == 0 or winner == "":
            unfinished.append(race)
        else:
            finished.append(race)

    mode = str(mode).upper()
    if mode == "LAST RACE" or mode == "PREVIOUS RACE":
        if len(finished) == 0:
            return None, "NO FINISHED RACE"
        return finished[len(finished) - 1], "LAST"
    if len(unfinished) > 0:
        return unfinished[0], "LIVE"
    if len(finished) > 0:
        return finished[len(finished) - 1], "LAST"
    return None, "NO RACES"


def vehicle_rows(feed):
    vehicles = feed.get("vehicles", [])
    rows = []
    for car in vehicles:
        driver = car.get("driver", {})
        rows.append({
            "pos": int(car.get("running_position", 0)),
            "num": str(car.get("vehicle_number", "?")),
            "name": clean_name(driver.get("last_name", driver.get("full_name", "?"))),
            "delta": car.get("delta", 0),
            "status": int(car.get("status", 0)),
            "laps": int(car.get("laps_completed", 0)),
            "mfg": str(car.get("vehicle_manufacturer", "")),
        })
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            if rows[j]["pos"] > rows[j + 1]["pos"]:
                tmp = rows[j]
                rows[j] = rows[j + 1]
                rows[j + 1] = tmp
    return rows


def upcoming_state(series, race, status_code):
    return {
        "ok": True,
        "live": False,
        "source": "NEXT",
        "series": series,
        "race_name": short_race(race.get("race_name", "RACE"), 22),
        "track_name": short_track(race.get("track_name", "")),
        "laps_in_race": int(race.get("scheduled_laps", 0)),
        "lap_number": 0,
        "flag_state": 0,
        "stage_num": 0,
        "stage_end": 0,
        "stage1": int(race.get("stage_1_laps", 0)),
        "stage2": int(race.get("stage_2_laps", 0)),
        "stage3": int(race.get("stage_3_laps", 0)),
        "cautions": 0,
        "caution_laps": 0,
        "lead_changes": 0,
        "rows": [],
        "race_date": format_date(race.get("race_date", race.get("date_scheduled", ""))),
        "status_note": "UNLOCKS NEAR GREEN",
        "http_status": status_code,
    }


def live_state(series, source, race, feed):
    stage = feed.get("stage", {})
    return {
        "ok": True,
        "live": True,
        "source": source,
        "series": series,
        "race_name": short_race(feed.get("run_name", race.get("race_name", "RACE")), 22),
        "track_name": short_track(feed.get("track_name", race.get("track_name", ""))),
        "laps_in_race": int(feed.get("laps_in_race", race.get("scheduled_laps", 0))),
        "lap_number": int(feed.get("lap_number", 0)),
        "flag_state": int(feed.get("flag_state", 0)),
        "stage_num": int(stage.get("stage_num", 0)),
        "stage_end": int(stage.get("finish_at_lap", 0)),
        "stage1": int(race.get("stage_1_laps", 0)),
        "stage2": int(race.get("stage_2_laps", 0)),
        "stage3": int(race.get("stage_3_laps", 0)),
        "cautions": int(feed.get("number_of_caution_segments", 0)),
        "caution_laps": int(feed.get("number_of_caution_laps", 0)),
        "lead_changes": int(feed.get("number_of_lead_changes", 0)),
        "rows": vehicle_rows(feed),
        "race_date": format_date(race.get("race_date", "")),
        "status_note": "",
        "http_status": 200,
    }


def draw_error(c, title, sub):
    c.fill(COLORS["bg"])
    c.rect(0, 0, c.width - 1, 9, fill = COLORS["panel"])
    c.image("checkered.png", 2, 1, w = 14, h = 8)
    c.text("NASCAR", 20, 2, font = "5x7", color = COLORS["accent"])
    c.text(title, 4, 14, font = "6x8", color = COLORS["error"])
    c.text(sub, 4, 24, font = "4x5", color = COLORS["muted"])


def draw_chrome(c, state, title, right = ""):
    c.rect(0, 0, c.width - 1, 9, fill = COLORS["panel"])
    c.image("checkered.png", 2, 1, w = 14, h = 8)
    if state["live"] and state["flag_state"] > 0:
        draw_flag_icon(c, state["flag_state"], 18, 0)
        c.text(title, 30, 2, font = "5x7", color = COLORS["text"])
    else:
        c.text(title, 20, 2, font = "5x7", color = COLORS["accent"])
    if right != "":
        c.text(right, c.width - 3, 2, font = "5x7", color = COLORS["muted"], align = "right")
    accent = flag_color(state["flag_state"]) if state["live"] else COLORS["accent"]
    c.rect(0, 10, c.width - 1, 10, fill = accent)


def plate_label(num):
    label = str(num)
    if len(label) > 2:
        label = label[:2]
    return label


def draw_number_plate(c, x, y, num, mfg):
    # Small crisp plate for dense rows (live board). Downloaded car-number
    # photos turn to mush at this size on an LED grid — a flat colored plate
    # with the bitmap font reads far cleaner.
    bg = mfg_color(mfg)
    label = plate_label(num)
    tw = c.text_width(label, "4x5")
    w = tw + 4
    if w < 11:
        w = 11
    c.rect(x, y, x + w - 1, y + 6, fill = bg)
    c.rect(x, y, x + w - 1, y, fill = "#FFFFFF")
    c.text(label, x + w // 2, y + 1, font = "4x5", color = "#FFFFFF", align = "center")
    return w


def draw_car_badge(c, x, y, num, mfg, size = 11):
    # Real CF car badges when bundled; colored plate fallback otherwise.
    n = str(num)
    s = int(size)
    if n == "1":
        c.image("car-1.png", x, y, w = s, h = s)
        return s
    if n == "10":
        c.image("car-10.png", x, y, w = s, h = s)
        return s
    if n == "11":
        c.image("car-11.png", x, y, w = s, h = s)
        return s
    if n == "12":
        c.image("car-12.png", x, y, w = s, h = s)
        return s
    if n == "16":
        c.image("car-16.png", x, y, w = s, h = s)
        return s
    if n == "17":
        c.image("car-17.png", x, y, w = s, h = s)
        return s
    if n == "19":
        c.image("car-19.png", x, y, w = s, h = s)
        return s
    if n == "2":
        c.image("car-2.png", x, y, w = s, h = s)
        return s
    if n == "20":
        c.image("car-20.png", x, y, w = s, h = s)
        return s
    if n == "21":
        c.image("car-21.png", x, y, w = s, h = s)
        return s
    if n == "22":
        c.image("car-22.png", x, y, w = s, h = s)
        return s
    if n == "23":
        c.image("car-23.png", x, y, w = s, h = s)
        return s
    if n == "24":
        c.image("car-24.png", x, y, w = s, h = s)
        return s
    if n == "3":
        c.image("car-3.png", x, y, w = s, h = s)
        return s
    if n == "33":
        c.image("car-33.png", x, y, w = s, h = s)
        return s
    if n == "34":
        c.image("car-34.png", x, y, w = s, h = s)
        return s
    if n == "35":
        c.image("car-35.png", x, y, w = s, h = s)
        return s
    if n == "38":
        c.image("car-38.png", x, y, w = s, h = s)
        return s
    if n == "4":
        c.image("car-4.png", x, y, w = s, h = s)
        return s
    if n == "41":
        c.image("car-41.png", x, y, w = s, h = s)
        return s
    if n == "42":
        c.image("car-42.png", x, y, w = s, h = s)
        return s
    if n == "43":
        c.image("car-43.png", x, y, w = s, h = s)
        return s
    if n == "45":
        c.image("car-45.png", x, y, w = s, h = s)
        return s
    if n == "47":
        c.image("car-47.png", x, y, w = s, h = s)
        return s
    if n == "48":
        c.image("car-48.png", x, y, w = s, h = s)
        return s
    if n == "5":
        c.image("car-5.png", x, y, w = s, h = s)
        return s
    if n == "51":
        c.image("car-51.png", x, y, w = s, h = s)
        return s
    if n == "54":
        c.image("car-54.png", x, y, w = s, h = s)
        return s
    if n == "6":
        c.image("car-6.png", x, y, w = s, h = s)
        return s
    if n == "60":
        c.image("car-60.png", x, y, w = s, h = s)
        return s
    if n == "62":
        c.image("car-62.png", x, y, w = s, h = s)
        return s
    if n == "67":
        c.image("car-67.png", x, y, w = s, h = s)
        return s
    if n == "7":
        c.image("car-7.png", x, y, w = s, h = s)
        return s
    if n == "71":
        c.image("car-71.png", x, y, w = s, h = s)
        return s
    if n == "77":
        c.image("car-77.png", x, y, w = s, h = s)
        return s
    if n == "78":
        c.image("car-78.png", x, y, w = s, h = s)
        return s
    if n == "88":
        c.image("car-88.png", x, y, w = s, h = s)
        return s
    if n == "9":
        c.image("car-9.png", x, y, w = s, h = s)
        return s
    if n == "97":
        c.image("car-97.png", x, y, w = s, h = s)
        return s
    return draw_number_plate(c, x, y + 1, n, mfg)


def draw_car_badge_small(c, x, y, num, mfg, size = 10):
    # Dimmed/softened variant for the dense "upcoming" live board — the
    # full-brightness badge art has a stark white outline that pops too hard
    # at 10px. These pre-blended "-sm" assets tone that down.
    n = str(num)
    s = int(size)
    if n == "1":
        c.image("car-1-sm.png", x, y, w = s, h = s)
        return s
    if n == "10":
        c.image("car-10-sm.png", x, y, w = s, h = s)
        return s
    if n == "11":
        c.image("car-11-sm.png", x, y, w = s, h = s)
        return s
    if n == "12":
        c.image("car-12-sm.png", x, y, w = s, h = s)
        return s
    if n == "16":
        c.image("car-16-sm.png", x, y, w = s, h = s)
        return s
    if n == "17":
        c.image("car-17-sm.png", x, y, w = s, h = s)
        return s
    if n == "19":
        c.image("car-19-sm.png", x, y, w = s, h = s)
        return s
    if n == "2":
        c.image("car-2-sm.png", x, y, w = s, h = s)
        return s
    if n == "20":
        c.image("car-20-sm.png", x, y, w = s, h = s)
        return s
    if n == "21":
        c.image("car-21-sm.png", x, y, w = s, h = s)
        return s
    if n == "22":
        c.image("car-22-sm.png", x, y, w = s, h = s)
        return s
    if n == "23":
        c.image("car-23-sm.png", x, y, w = s, h = s)
        return s
    if n == "24":
        c.image("car-24-sm.png", x, y, w = s, h = s)
        return s
    if n == "3":
        c.image("car-3-sm.png", x, y, w = s, h = s)
        return s
    if n == "33":
        c.image("car-33-sm.png", x, y, w = s, h = s)
        return s
    if n == "34":
        c.image("car-34-sm.png", x, y, w = s, h = s)
        return s
    if n == "35":
        c.image("car-35-sm.png", x, y, w = s, h = s)
        return s
    if n == "38":
        c.image("car-38-sm.png", x, y, w = s, h = s)
        return s
    if n == "4":
        c.image("car-4-sm.png", x, y, w = s, h = s)
        return s
    if n == "41":
        c.image("car-41-sm.png", x, y, w = s, h = s)
        return s
    if n == "42":
        c.image("car-42-sm.png", x, y, w = s, h = s)
        return s
    if n == "43":
        c.image("car-43-sm.png", x, y, w = s, h = s)
        return s
    if n == "45":
        c.image("car-45-sm.png", x, y, w = s, h = s)
        return s
    if n == "47":
        c.image("car-47-sm.png", x, y, w = s, h = s)
        return s
    if n == "48":
        c.image("car-48-sm.png", x, y, w = s, h = s)
        return s
    if n == "5":
        c.image("car-5-sm.png", x, y, w = s, h = s)
        return s
    if n == "51":
        c.image("car-51-sm.png", x, y, w = s, h = s)
        return s
    if n == "54":
        c.image("car-54-sm.png", x, y, w = s, h = s)
        return s
    if n == "6":
        c.image("car-6-sm.png", x, y, w = s, h = s)
        return s
    if n == "60":
        c.image("car-60-sm.png", x, y, w = s, h = s)
        return s
    if n == "62":
        c.image("car-62-sm.png", x, y, w = s, h = s)
        return s
    if n == "67":
        c.image("car-67-sm.png", x, y, w = s, h = s)
        return s
    if n == "7":
        c.image("car-7-sm.png", x, y, w = s, h = s)
        return s
    if n == "71":
        c.image("car-71-sm.png", x, y, w = s, h = s)
        return s
    if n == "77":
        c.image("car-77-sm.png", x, y, w = s, h = s)
        return s
    if n == "78":
        c.image("car-78-sm.png", x, y, w = s, h = s)
        return s
    if n == "88":
        c.image("car-88-sm.png", x, y, w = s, h = s)
        return s
    if n == "9":
        c.image("car-9-sm.png", x, y, w = s, h = s)
        return s
    if n == "97":
        c.image("car-97-sm.png", x, y, w = s, h = s)
        return s
    return draw_number_plate(c, x, y + 1, n, mfg)


def fetch_schedule(ctx):
    series = str(safe_input(ctx, "series", "CUP")).upper()
    year = ctx.now.year
    schedule_resp = http_json(
        "https://cf.nascar.com/cacher/" + str(year) + "/race_list_basic.json",
        3600,
    )
    if not schedule_resp["ok"]:
        return None, series, {
            "ok": False,
            "title": "SCHEDULE ERROR",
            "sub": "CF " + str(schedule_resp["status"]),
        }
    return schedule_resp["data"], series, None


def fetch_upcoming(ctx):
    # Next unfinished race; morphs to live board once the CF feed unlocks.
    schedule, series, err = fetch_schedule(ctx)
    if err != None:
        return err
    race, source = pick_races(schedule, series, "AUTO")
    if race == None:
        return {"ok": False, "title": "NO RACE", "sub": str(source)}
    series_id = int(race.get("series_id", SERIES_IDS.get(series, 1)))
    race_id = int(race.get("race_id", 0))
    live_url = (
        "https://cf.nascar.com/cacher/live/series_"
        + str(series_id)
        + "/"
        + str(race_id)
        + "/live-feed.json"
    )
    live = http_json(live_url, 45)
    if live["ok"]:
        state = live_state(series, "LIVE", race, live["data"])
        if state["flag_state"] in [0, 8]:
            state["status_note"] = "GREEN SOON"
        else:
            state["status_note"] = "LIVE NOW"
        return state
    return upcoming_state(series, race, live["status"])


def fetch_previous(ctx):
    # Most recent finished race — badges / final board.
    schedule, series, err = fetch_schedule(ctx)
    if err != None:
        return err
    race, source = pick_races(schedule, series, "PREVIOUS RACE")
    if race == None:
        return {"ok": False, "title": "NO RACE", "sub": str(source)}
    series_id = int(race.get("series_id", SERIES_IDS.get(series, 1)))
    race_id = int(race.get("race_id", 0))
    live_url = (
        "https://cf.nascar.com/cacher/live/series_"
        + str(series_id)
        + "/"
        + str(race_id)
        + "/live-feed.json"
    )
    live = http_json(live_url, 300)
    if not live["ok"]:
        return {
            "ok": False,
            "title": "NO RESULTS",
            "sub": "CF " + str(live["status"]),
        }
    return live_state(series, "LAST", race, live["data"])


def fetch_active(ctx):
    # Live feed for the next race if unlocked; otherwise previous-race results.
    schedule, series, err = fetch_schedule(ctx)
    if err != None:
        return err
    nxt, _ = pick_races(schedule, series, "AUTO")
    if nxt != None:
        series_id = int(nxt.get("series_id", SERIES_IDS.get(series, 1)))
        race_id = int(nxt.get("race_id", 0))
        live_url = (
            "https://cf.nascar.com/cacher/live/series_"
            + str(series_id)
            + "/"
            + str(race_id)
            + "/live-feed.json"
        )
        live = http_json(live_url, 45)
        if live["ok"]:
            return live_state(series, "LIVE", nxt, live["data"])
    return fetch_previous(ctx)


def upcoming(c, ctx):
    # Page 1: next-race card between events; morphs into a live board once
    # the CF feed is up and the race is underway.
    state = fetch_upcoming(ctx)
    c.fill(COLORS["bg"])
    if not state["ok"]:
        draw_error(c, state["title"], state["sub"])
        return

    series = SERIES_SHORT.get(state["series"], "CUP")

    # Still waiting on the calendar / pre-green warmup with no lap yet.
    racing = False
    if state["live"]:
        fs = state["flag_state"]
        if state["lap_number"] > 0:
            racing = True
        elif fs == 1 or fs == 2 or fs == 3 or fs == 4 or fs == 5 or fs == 9:
            racing = True

    if not racing:
        draw_chrome(c, state, series + " NEXT", state["race_date"])
        c.text(state["race_name"], 4, 13, font = "6x8", color = COLORS["text"])
        bottom = state["track_name"]
        if state["laps_in_race"] > 0:
            bottom += "  " + str(state["laps_in_race"]) + "L"
        c.text(bottom, 4, 24, font = "4x5", color = COLORS["muted"])
        note = state["status_note"]
        if note == "":
            note = "WAITING FOR GREEN"
        c.text(note, c.width - 3, 24, font = "4x5", color = COLORS["accent2"], align = "right")
        return

    # ---- Live board: top 6 with car badges, no gap times ----
    title = series + " " + flag_label(state["flag_state"])
    lap = str(state["lap_number"]) + "/" + str(state["laps_in_race"])
    draw_chrome(c, state, title, lap)

    rows = state["rows"]
    if len(rows) == 0:
        c.text("WAITING ON FIELD", 4, 18, font = "5x7", color = COLORS["muted"])
        return

    # Three-column grid, no gap times, so up to 6 places fit with real badges:
    # POS + car badge + name per cell, 2 rows tall x 3 columns wide.
    show = 6
    if show > len(rows):
        show = len(rows)
    col_w = c.width // 3
    badge = 10
    for i in range(show):
        row = rows[i]
        col = i % 3
        line = i // 3
        x = 2 + col * col_w
        y = 11 + line * 10
        c.text(str(row["pos"]), x, y + 3, font = "4x5", color = COLORS["muted"])
        badge_x = x + 8
        draw_car_badge_small(c, badge_x, y, row["num"], row["mfg"], badge)
        name = row["name"]
        name_x = badge_x + badge + 2
        max_w = col_w - (name_x - x) - 2
        for _ in range(12):
            if c.text_width(name, "5x7") <= max_w or len(name) <= 3:
                break
            name = name[:len(name) - 1]
        name_color = COLORS["accent2"] if row["pos"] == 1 else COLORS["text"]
        c.text(name, name_x, y + 2, font = "5x7", color = name_color)


def results(c, ctx):
    # Page 2: previous race top finishers with crisp number plates.
    state = fetch_previous(ctx)
    c.fill(COLORS["bg"])
    if not state["ok"]:
        draw_error(c, state["title"], state["sub"])
        return

    series = SERIES_SHORT.get(state["series"], "CUP")
    title = short_race(state["race_name"], 14)

    rows = state["rows"]
    show = 6
    if show > len(rows):
        show = len(rows)

    # Explicit "LAST RACE" tag — this page always shows the most recently
    # *finished* race (pick_races only looks at winner_driver_id), so during
    # a live event it won't ever show today's in-progress race. Spelling
    # that out avoids confusion when it's mixed into the page rotation
    # alongside the live board.
    header = series + " LAST RACE"
    draw_chrome(c, state, header, title)
    if show == 0:
        c.text("NO RESULTS", 4, 18, font = "5x7", color = COLORS["muted"])
        return

    slot = c.width // show
    badge = 16
    for i in range(show):
        row = rows[i]
        left = i * slot
        cx = left + slot // 2
        badge_x = cx - badge // 2
        if badge_x < left + 1:
            badge_x = left + 1
        c.text(str(row["pos"]), left + 1, 15, font = "4x5", color = COLORS["accent2"])
        draw_car_badge(c, badge_x, 11, row["num"], row["mfg"], badge)
        name = row["name"]
        if len(name) > 6:
            name = name[:6]
        c.text(name, cx, 27, font = "4x5", color = COLORS["text"], align = "center")


def race(c, ctx):
    # Page 3: lap progress bar + stage/flag callout + cautions & lead changes.
    state = fetch_active(ctx)
    c.fill(COLORS["bg"])
    if not state["ok"]:
        draw_error(c, state["title"], state["sub"])
        return

    lap_now = state["lap_number"]
    total = state["laps_in_race"]
    togo = total - lap_now if total > 0 else 0
    if togo < 0:
        togo = 0
    finished = togo <= 0 or state["flag_state"] == 5 or state["flag_state"] == 9
    lap_str = str(lap_now) + "/" + str(total) if total > 0 else str(lap_now)
    draw_chrome(c, state, short_race(state["race_name"], 16), lap_str)

    # Progress bar follows live flag color; finished races use checkered silver
    # so STAGE N doesn't inherit an old "finish purple" accent.
    if finished:
        bar_color = FLAG_COLOR[5]
    elif state["live"]:
        bar_color = flag_color(state["flag_state"])
    else:
        bar_color = COLORS["accent"]

    # Lap progress bar with stage-boundary tick marks.
    bar_x0 = 4
    bar_x1 = c.width - 5
    bar_y = 12
    bar_h = 4
    c.rect(bar_x0, bar_y, bar_x1, bar_y + bar_h - 1, fill = COLORS["rail"])
    if total > 0:
        frac = float(lap_now) / float(total)
        if frac > 1:
            frac = 1.0
        if frac < 0:
            frac = 0.0
        fill_w = int(float(bar_x1 - bar_x0) * frac)
        if fill_w > 0:
            c.rect(bar_x0, bar_y, bar_x0 + fill_w, bar_y + bar_h - 1, fill = bar_color)
        for boundary in [state["stage1"], state["stage1"] + state["stage2"]]:
            if boundary > 0 and boundary < total:
                tick_x = bar_x0 + int(float(bar_x1 - bar_x0) * (float(boundary) / float(total)))
                c.rect(tick_x, bar_y - 1, tick_x, bar_y + bar_h, fill = COLORS["text"])

    # Stage stays neutral white; FINISH gets the gold callout on the right.
    label = flag_label(state["flag_state"])
    if state["stage_num"] > 0:
        label = "STAGE " + str(state["stage_num"])
    label_color = COLORS["text"] if finished else bar_color
    c.text(label, 4, 18, font = "6x8", color = label_color)

    if total > 0 and lap_now > 0:
        if finished:
            c.text("FINISH", c.width - 3, 19, font = "5x7", color = COLORS["accent2"], align = "right")
        else:
            c.text(str(togo) + " TO GO", c.width - 3, 19, font = "5x7", color = COLORS["accent2"], align = "right")
    else:
        c.text(state["track_name"], c.width - 3, 19, font = "4x5", color = COLORS["muted"], align = "right")

    # Cautions + lead changes, spelled out with a small flag icon.
    c.image("flag-yellow.png", 4, 26, w = 6, h = 6)
    c.text(str(state["cautions"]) + " CAUTIONS", 12, 27, font = "4x5", color = COLORS["text"])
    c.text(str(state["lead_changes"]) + " LEAD CHANGES", c.width - 3, 27, font = "4x5", color = COLORS["muted"], align = "right")


def parse_lap_notes(data):
    notes = []
    laps = data.get("laps", {})
    if laps == None:
        return notes
    for lap_key in laps:
        items = laps[lap_key]
        if items == None:
            continue
        for item in items:
            text = item.get("Note", "")
            if text == None or str(text).strip() == "":
                continue
            notes.append({
                "lap": int(lap_key),
                "text": str(text).upper(),
                "flag": int(item.get("FlagState", 0)),
            })
    # Sort by lap ascending (Starlark-friendly bubble).
    n = len(notes)
    for i in range(n):
        for j in range(n - 1 - i):
            if notes[j]["lap"] > notes[j + 1]["lap"]:
                tmp = notes[j]
                notes[j] = notes[j + 1]
                notes[j + 1] = tmp
    return notes


def parse_flag_comments(data):
    notes = []
    if data == None:
        return notes
    # Flag feed is a list of events.
    for item in data:
        text = item.get("comment", "")
        if text == None or str(text).strip() == "":
            continue
        notes.append({
            "lap": int(item.get("lap_number", 0)),
            "text": str(text).upper(),
            "flag": int(item.get("flag_state", 0)),
        })
    return notes


def fetch_updates(ctx):
    # Race ticker notes from CF lap-notes (rich) + live-flag comments (fallback).
    schedule, series, err = fetch_schedule(ctx)
    if err != None:
        return err

    race = None
    source = "PREV"
    upcoming_race, _ = pick_races(schedule, series, "AUTO")
    if upcoming_race != None:
        series_id = int(upcoming_race.get("series_id", SERIES_IDS.get(series, 1)))
        race_id = int(upcoming_race.get("race_id", 0))
        live_url = (
            "https://cf.nascar.com/cacher/live/series_"
            + str(series_id)
            + "/"
            + str(race_id)
            + "/live-feed.json"
        )
        live = http_json(live_url, 45)
        if live["ok"]:
            race = upcoming_race
            source = "LIVE"
    if race == None:
        race, _ = pick_races(schedule, series, "PREVIOUS RACE")
        source = "PREV"
    if race == None:
        return {"ok": False, "title": "NO RACE", "sub": "NO UPDATES"}

    year = int(race.get("race_season", ctx.now.year))
    series_id = int(race.get("series_id", SERIES_IDS.get(series, 1)))
    race_id = int(race.get("race_id", 0))

    notes = []
    notes_url = (
        "https://cf.nascar.com/cacher/"
        + str(year)
        + "/"
        + str(series_id)
        + "/"
        + str(race_id)
        + "/lap-notes.json"
    )
    notes_resp = http_json(notes_url, 60)
    if notes_resp["ok"]:
        notes = parse_lap_notes(notes_resp["data"])

    # Live flag comments fill gaps when lap-notes aren't published yet.
    if len(notes) == 0 or source == "LIVE":
        flag_url = (
            "https://cf.nascar.com/cacher/live/series_"
            + str(series_id)
            + "/"
            + str(race_id)
            + "/live-flag-data.json"
        )
        flag_resp = http_json(flag_url, 45)
        if flag_resp["ok"]:
            flag_notes = parse_flag_comments(flag_resp["data"])
            # Prefer lap-notes when present; otherwise use flag comments.
            if len(notes) == 0:
                notes = flag_notes

    return {
        "ok": True,
        "source": source,
        "series": series,
        "race_name": short_race(race.get("race_name", "RACE"), 14),
        "live": source == "LIVE",
        "flag_state": 0,
        "notes": notes,
    }


def updates(c, ctx):
    # Page 4: latest race ticker ("#5 INCIDENT TURN 3", wrecks, stage ends).
    state = fetch_updates(ctx)
    c.fill(COLORS["bg"])
    if not state["ok"]:
        draw_error(c, state["title"], state["sub"])
        return

    series = SERIES_SHORT.get(state["series"], "CUP")
    notes = state["notes"]
    if len(notes) == 0:
        draw_chrome(c, state, series + " UPDATES", state["race_name"])
        c.text("NO UPDATES YET", 4, 16, font = "5x7", color = COLORS["muted"])
        c.text("CHECK BACK NEAR GREEN", 4, 24, font = "4x5", color = COLORS["accent2"])
        return

    # Rotate through the last few notes each minute so the panel isn't static
    # between races; during a race refresh still lands on near-latest.
    recent = notes
    if len(notes) > 6:
        recent = notes[len(notes) - 6:len(notes)]
    idx = ctx.now.unix // 60
    idx = idx % len(recent)
    note = recent[idx]

    header = series + " L" + str(note["lap"])
    draw_chrome(c, state, header, state["race_name"])

    # Accent by flag state on the note itself.
    col = COLORS["text"]
    fs = note["flag"]
    if fs == 2:
        col = FLAG_COLOR[2]
    elif fs == 3:
        col = FLAG_COLOR[3]
    elif fs == 4 or fs == 5 or fs == 9:
        col = COLORS["accent2"]

    c.text_wrapped(
        note["text"],
        3,
        13,
        c.width - 6,
        font = "4x5",
        color = col,
        line_gap = 1,
        max_lines = 3,
    )
