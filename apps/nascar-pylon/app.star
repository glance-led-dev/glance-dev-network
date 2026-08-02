# NASCAR Scoring Pylon — full-field running order on a wide Glance panel
# (384x32). Data from NASCAR's public Content Feed CDN (cf.nascar.com).

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

FLAG_COLOR = {
    1: "#22C55E",
    2: "#FACC15",
    3: "#EF4444",
    4: "#F8FAFC",
    # Checkered / official finish — charcoal, not purple.
    5: "#1A1A1A",
    8: "#38BDF8",
    9: "#1A1A1A",
}

# Flags that render on a bright background and need dark header text.
BRIGHT_FLAGS = [1, 2, 4]

# CF live-feed vehicle status (rNascar23 / timing):
#   1 = on track, 2 = in pits, 3 = retired/DNF, 6 = garage.
STATUS_ON_TRACK = 1
STATUS_IN_PITS = 2
STATUS_RETIRED = 3
STATUS_GARAGE = 6

COLORS = {
    "bg": "#000000",
    "panel": "#0A0D12",
    "text": "#F4F7FB",
    "muted": "#4B5563",
    "accent2": "#FFD166",
    "up": "#22C55E",
    "down": "#EF4444",
    "out": "#FF2020",
    "dvp": "#F97316",
    "pit": "#3B82F6",
    # Garage / over-the-wall repair, not yet scored as DNF.
    "repair": "#FACC15",
    # Fastest last-lap time (F1-style purple).
    "fastest": "#C084FC",
    # Off the lead lap — readable, but clearly secondary to full-bright leaders.
    "lapped": "#5C6674",
    # Soft amber lead-lap cut (quieter than bright caution yellow).
    "lead_line": "#8A6A2A",
    "error": "#FF5D73",
    "dark": "#0B0D10",
}


def safe_input(ctx, key, fallback):
    value = ctx.inputs.get(key, fallback)
    if value == None or value == "":
        return fallback
    return value


def series_key(name):
    return "series_" + str(SERIES_IDS.get(str(name).upper(), 1))


def zero_pad2(n):
    s = str(n)
    if len(s) < 2:
        s = "0" + s
    return s


def flag_color(state):
    return FLAG_COLOR.get(state, COLORS["muted"])


def header_text_color(state):
    if state in BRIGHT_FLAGS:
        return COLORS["dark"]
    return COLORS["text"]


def http_json(url, ttl):
    response = http.get(url, ttl_seconds = ttl)
    status = response["status_code"]
    if status != 200:
        return {"ok": False, "status": status}
    data = response["json"]
    if data == None:
        return {"ok": False, "status": status}
    return {"ok": True, "status": status, "data": data}


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
    if mode == "PREVIOUS RACE":
        if len(finished) == 0:
            return None, "NO FINISHED RACE"
        return finished[len(finished) - 1], "LAST"
    if len(unfinished) > 0:
        return unfinished[0], "LIVE"
    if len(finished) > 0:
        return finished[len(finished) - 1], "LAST"
    return None, "NO RACES"


def recent_pit(car, race_lap):
    # True if this car pitted within the last five leader laps.
    pits = car.get("pit_stops", [])
    if pits == None:
        return False
    for pit in pits:
        pit_lap = int(pit.get("pit_in_leader_lap", 0))
        if pit_lap <= 0:
            continue
        age = race_lap - pit_lap
        if age >= 0 and age <= 5:
            return True
    return False


def position_delta(car):
    # Glance apps can't persist the prior refresh, so approximate "moved
    # since last update" with the short-window differential when present,
    # otherwise overall start-vs-run gain/loss.
    short = car.get("position_differential_last_10_percent", 0)
    if short == None:
        short = 0
    short = int(short)
    if short != 0:
        return short
    start = int(car.get("starting_position", 0))
    run = int(car.get("running_position", 0))
    if start <= 0 or run <= 0:
        return 0
    return start - run


def is_retired(status):
    return status == STATUS_RETIRED


def is_repairing(status, on_track):
    # Yellow marker: in the garage, or off-track / being worked on, but not
    # yet official DNF. Normal short pit stops stay status 1 (blue pit tick);
    # status 2 (in pits) alone is too noisy for every stop, so garage +
    # off-track-not-retired is the repair signal.
    if is_retired(status):
        return False
    if status == STATUS_GARAGE:
        return True
    if not on_track:
        return True
    return False


def fastest_last_lap_num(vehicles):
    # Lowest last_lap_time among cars still on track. Ignores retired / garage
    # cars and zero/missing times (warmup / no lap yet).
    best_num = ""
    best_t = 0.0
    found = False
    for car in vehicles:
        status = int(car.get("status", 1))
        if is_retired(status) or is_repairing(status, bool(car.get("is_on_track", True))):
            continue
        if status != STATUS_ON_TRACK and status != STATUS_IN_PITS:
            continue
        raw = car.get("last_lap_time", 0)
        if raw == None:
            continue
        t = float(raw)
        if t <= 0:
            continue
        if not found or t < best_t:
            found = True
            best_t = t
            best_num = str(car.get("vehicle_number", ""))
    return best_num


def vehicle_rows(feed):
    vehicles = feed.get("vehicles", [])
    race_lap = int(feed.get("lap_number", 0))
    fastest_num = fastest_last_lap_num(vehicles)
    rows = []
    for car in vehicles:
        status = int(car.get("status", 1))
        on_track = bool(car.get("is_on_track", True))
        num = str(car.get("vehicle_number", "?"))
        out = is_retired(status)
        repair = is_repairing(status, on_track)
        rows.append({
            "pos": int(car.get("running_position", 0)),
            "num": num,
            "laps": int(car.get("laps_completed", 0)),
            "out": out,
            "repair": repair,
            "dvp": bool(car.get("is_on_dvp", False)),
            "pit": recent_pit(car, race_lap),
            "fastest": num == fastest_num and fastest_num != "",
            "delta": position_delta(car),
        })
    n = len(rows)
    for i in range(n):
        for j in range(n - 1 - i):
            if rows[j]["pos"] > rows[j + 1]["pos"]:
                tmp = rows[j]
                rows[j] = rows[j + 1]
                rows[j + 1] = tmp
    return rows


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


def stage_for_lap(lap_number, stage1, stage2, total):
    if stage1 > 0 and lap_number <= stage1:
        return 1
    if stage2 > 0 and lap_number <= stage1 + stage2:
        return 2
    return 3


def build_state(series, race, feed):
    stage = feed.get("stage", {})
    stage1 = int(race.get("stage_1_laps", 0))
    stage2 = int(race.get("stage_2_laps", 0))
    stage3 = int(race.get("stage_3_laps", 0))
    stage_num = int(stage.get("stage_num", 0))
    if stage_num <= 0:
        stage_num = stage_for_lap(
            int(feed.get("lap_number", 0)),
            stage1,
            stage2,
            int(feed.get("laps_in_race", race.get("scheduled_laps", 0))),
        )
    return {
        "ok": True,
        "series": series,
        "flag_state": int(feed.get("flag_state", 0)),
        "lap_number": int(feed.get("lap_number", 0)),
        "laps_in_race": int(feed.get("laps_in_race", race.get("scheduled_laps", 0))),
        "stage_num": stage_num,
        "stage1": stage1,
        "stage2": stage2,
        "stage3": stage3,
        "rows": vehicle_rows(feed),
    }


def fetch_previous(ctx):
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
        return {"ok": False, "title": "NO RESULTS", "sub": "CF " + str(live["status"])}
    return build_state(series, race, live["data"])


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
        live = http_json(live_url, 30)
        if live["ok"]:
            return build_state(series, nxt, live["data"])
    return fetch_previous(ctx)


def draw_error(c, title, sub):
    c.fill(COLORS["bg"])
    c.text(title, 2, 12, font = "5x7", color = COLORS["error"])
    c.text(sub, 2, 22, font = "4x5", color = COLORS["muted"])


def car_number_color(row, on_lead):
    # Out / garage-repair cars stay dim — colored squares carry that signal.
    if row["out"] or row["repair"]:
        return COLORS["muted"]
    # Off the lead lap: quiet grey instead of a yellow divider line.
    if not on_lead:
        return COLORS["lapped"]
    # Green/red for recent position gain/loss (see position_delta).
    if row["delta"] > 0:
        return COLORS["up"]
    if row["delta"] < 0:
        return COLORS["down"]
    if row["pos"] == 1:
        return COLORS["accent2"]
    return COLORS["text"]


def draw_status_dots(c, x, y, row):
    # Status ticks right of the car number:
    #   RED 2x2    = out / DNF (retired)
    #   YELLOW 2x2 = garage / over-wall repair, not DNF yet
    #   ORANGE     = Damaged Vehicle Policy
    #   BLUE       = pit stop within the last 5 laps
    #   PURPLE     = fastest last-lap time of anyone still running
    dx = x
    if row["out"]:
        c.rect(dx, y + 1, dx + 1, y + 2, fill = COLORS["out"])
        dx += 3
    if row["repair"] and not row["out"]:
        c.rect(dx, y + 1, dx + 1, y + 2, fill = COLORS["repair"])
        dx += 3
    if row["dvp"]:
        c.rect(dx, y + 1, dx, y + 2, fill = COLORS["dvp"])
        dx += 2
    if row["pit"] and not row["out"] and not row["repair"]:
        # Skip pit ticks when out/repairing — those squares matter more.
        c.rect(dx, y + 1, dx, y + 2, fill = COLORS["pit"])
        dx += 2
    if row["fastest"] and not row["out"] and not row["repair"]:
        c.rect(dx, y + 1, dx + 1, y + 2, fill = COLORS["fastest"])
        dx += 3
    return dx


def pylon(c, ctx):
    # Full running order in columns: highlighted top-5, then the rest of the
    # field wrapping 5-per-column with status ticks and a soft lead-lap cut.
    state = fetch_active(ctx)
    c.fill(COLORS["bg"])
    if not state["ok"]:
        draw_error(c, state["title"], state["sub"])
        return

    flag = state["flag_state"]
    total = state["laps_in_race"]
    lap_now = state["lap_number"]
    togo = total - lap_now
    if togo < 0:
        togo = 0

    rows = state["rows"]
    if len(rows) == 0:
        c.text("NO FIELD", 4, 12, font = "4x5", color = COLORS["muted"])
        return

    leader_laps = rows[0]["laps"]

    # Header: centered series + stage + laps-to-go (or FINISHED).
    finished = togo <= 0 or flag == 5 or flag == 9
    header_w = 42
    if finished:
        header_bg = FLAG_COLOR[9]
        text_col = COLORS["text"]
    else:
        header_bg = flag_color(flag) if flag > 0 else COLORS["panel"]
        text_col = header_text_color(flag) if flag > 0 else COLORS["text"]
    series = SERIES_SHORT.get(state["series"], state["series"])
    stage_num = state.get("stage_num", 0)
    stage_txt = "STAGE " + str(stage_num) if stage_num > 0 else "STAGE"
    c.rect(0, 0, header_w - 1, c.height - 1, fill = header_bg)
    c.text(series, header_w // 2, 1, font = "4x5", color = text_col, align = "center")
    if finished:
        c.text("FINISHED", header_w // 2, 14, font = "4x5", color = text_col, align = "center")
    else:
        c.text(stage_txt, header_w // 2, 8, font = "4x5", color = text_col, align = "center")
        c.text(str(togo), header_w // 2, 16, font = "6x8", color = text_col, align = "center")
        c.text("TO GO", header_w // 2, 26, font = "4x5", color = text_col, align = "center")
    c.rect(header_w, 0, header_w, c.height - 1, fill = COLORS["text"])

    col_x0 = header_w + 3
    row_h = 6
    rows_per_col = 5

    # Room for pos + number + up to 3 status dots.
    min_col_w = 30
    max_cols = (c.width - col_x0) // min_col_w
    max_rows = max_cols * rows_per_col
    n = len(rows)
    if n > max_rows:
        n = max_rows

    needed_cols = (n + rows_per_col - 1) // rows_per_col
    if needed_cols < 1:
        needed_cols = 1
    col_w = (c.width - col_x0) // needed_cols
    if col_w > 56:
        col_w = 56

    # First car a lap+ down — soft amber cut drawn on that car exactly
    # (not snapped to the column boundary).
    first_lapped = -1
    for i in range(n):
        if rows[i]["laps"] < leader_laps:
            first_lapped = i
            break

    for i in range(n):
        col = i // rows_per_col
        r = i % rows_per_col
        x = col_x0 + col * col_w
        y = 1 + r * row_h
        row = rows[i]
        on_lead = row["laps"] >= leader_laps

        if col == 0:
            # Static top-5 segment gets a highlighted backing panel.
            if r == 0:
                c.rect(x - 2, 0, x + col_w - 3, c.height - 1, fill = COLORS["panel"])

        if col > 0 and r == 0:
            c.rect(x - 2, 0, x - 2, c.height - 1, fill = COLORS["muted"])

        if i == first_lapped:
            c.rect(x - 2, y - 1, x + col_w - 4, y - 1, fill = COLORS["lead_line"])
            c.rect(x - 2, y - 1, x - 1, c.height - 1, fill = COLORS["lead_line"])
        elif first_lapped >= 0 and i > first_lapped and col == (first_lapped // rows_per_col):
            c.rect(x - 2, y, x - 1, y + 4, fill = COLORS["lead_line"])

        c.text(zero_pad2(row["pos"]), x, y, font = "4x5", color = COLORS["muted"])
        color = car_number_color(row, on_lead)
        c.text(row["num"], x + 11, y, font = "4x5", color = color)

        num_w = c.text_width(row["num"], "4x5")
        draw_status_dots(c, x + 11 + num_w + 2, y, row)
