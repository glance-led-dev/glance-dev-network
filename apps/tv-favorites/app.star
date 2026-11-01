MONTHS3 = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

DOW3 = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

# Glance allows a limited number of uncached HTTP calls per render:
# 1 for the config file + up to MAX_CHECK TVMaze lookups.
MAX_CHECK = 7

def fetch_config(ctx):
    domain = ctx.inputs.get("configurl", "")
    if not domain:
        return None
    resp = http.get("https://" + domain)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def lookup_channel(channels, network_name):
    for ch in channels:
        if ch["network"].upper() == network_name.upper():
            return ch
    return None

def weekday_from_days(days):
    return DOW3[(days + 3) % 7]

def url_encode(s):
    return s.replace("%", "%25").replace(" ", "+").replace("&", "%26").replace(":", "%3A").replace("'", "%27")

def wrap_text(text, max_chars):
    words = text.split(" ")
    lines = []
    current = ""
    for w in words:
        candidate = current + " " + w if current != "" else w
        if len(candidate) > max_chars:
            if current != "":
                lines.append(current)
            current = w
        else:
            current = candidate
    if current != "":
        lines.append(current)
    return lines

def make_abbr(title, abbr):
    if abbr != "":
        return abbr.upper()
    words = title.upper().split(" ")
    for w in words:
        if w != "THE" and w != "A":
            return w[:3]
    return words[0][:3]

def _days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = yy // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _civil_from_days(z):
    z = z + 719468
    era = (z if z >= 0 else z - 146096) // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    if m <= 2:
        y = y + 1
    return y, m, d

def _nth_sunday_day(year, month, n):
    first = _days_from_civil(year, month, 1)
    wd_first = (first + 3) % 7
    to_sunday = (6 - wd_first) % 7
    return first + to_sunday + (n - 1) * 7

def _et_offset_hours(now):
    today = _days_from_civil(now.year, now.month, now.day)
    dst_start = _nth_sunday_day(now.year, 3, 2)
    dst_end = _nth_sunday_day(now.year, 11, 1)
    return -4 if (today >= dst_start and today < dst_end) else -5

def local_date_str(ctx, user_offset, day_delta):
    local_unix = ctx.now.unix + user_offset * 3600
    local_days = local_unix // 86400 + day_delta
    y, m, d = _civil_from_days(local_days)
    return weekday_from_days(local_days) + " " + MONTHS3[m - 1] + " " + str(d)

def match_time_key(m):
    return m["raw_time"]

def match_diff_key(m):
    return m["diff"]

def shift_time(t, delta_hours):
    if t == "" or len(t) < 5:
        return t
    h = int(t[0:2])
    m = t[3:5]
    h = (h + delta_hours) % 24
    if h < 0:
        h = h + 24
    ap = "AM" if h < 12 else "PM"
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + m + ap

def current_season(ctx):
    m = ctx.now.month
    if m >= 9 and m <= 12:
        return "fall"
    if m >= 1 and m <= 3:
        return "winter"
    if m >= 4 and m <= 6:
        return "spring"
    return "summer"

def season_entries(ctx, entries):
    season = current_season(ctx)
    out = []
    for f in entries:
        if type(f) == "string":
            out.append({"title": f, "abbr": "", "service": ""})
        else:
            tags = f.get("seasons", ["all"])
            if season in tags or "all" in tags:
                out.append({"title": f["title"], "abbr": f.get("abbr", ""), "service": f.get("service", "")})
    return out

def network_name(data):
    net = data.get("network", None)
    if net == None:
        net = data.get("webChannel", None)
    if net == None:
        return ""
    return net.get("name", "")

def find_matches(ctx, config, target_diff, max_check, user_offset):
    channels = config.get("channels", [])
    et_offset = _et_offset_hours(ctx.now)
    delta_hours = user_offset - et_offset

    eastern_unix = ctx.now.unix + et_offset * 3600
    eastern_days = eastern_unix // 86400

    in_season = season_entries(ctx, config.get("favorites", []))

    matches = []
    for i in range(min(len(in_season), max_check)):
        entry = in_season[i]
        title = entry["title"]
        resp = http.get("https://api.tvmaze.com/singlesearch/shows?q=" + url_encode(title) + "&embed=nextepisode", ttl_seconds=3600)
        if resp["status_code"] != 200:
            continue
        data = resp["json"]
        next_ep = data.get("_embedded", {}).get("nextepisode", None)
        if next_ep == None:
            continue
        airdate = next_ep.get("airdate", "")
        if airdate == "":
            continue

        ay = int(airdate[0:4])
        am = int(airdate[5:7])
        ad = int(airdate[8:10])
        diff = _days_from_civil(ay, am, ad) - eastern_days

        is_match = False
        if target_diff == "later":
            is_match = diff >= 2
        else:
            is_match = diff == target_diff

        if is_match:
            net_name = network_name(data)
            ch = lookup_channel(channels, net_name)
            label = ch["num"] + " " + ch["callsign"] if ch != None else net_name.upper()
            raw_time = next_ep.get("airtime", "")
            time_str = shift_time(raw_time, delta_hours)
            days_val = _days_from_civil(ay, am, ad)
            date_str = weekday_from_days(days_val) + " " + MONTHS3[am - 1] + " " + str(ad)
            matches.append({
                "title": title.upper(),
                "abbr": make_abbr(title, entry["abbr"]),
                "ch": label,
                "network": net_name.upper()[:4],
                "time": time_str,
                "date": date_str,
                "diff": diff,
                "raw_time": raw_time,
            })

    return matches

def stream_matches(ctx, config):
    # Shows from the "stream" list whose latest episode aired yesterday (Eastern).
    et_offset = _et_offset_hours(ctx.now)
    eastern_days = (ctx.now.unix + et_offset * 3600) // 86400

    entries = season_entries(ctx, config.get("stream", []))

    out = []
    for i in range(min(len(entries), MAX_CHECK)):
        entry = entries[i]
        title = entry["title"]
        resp = http.get("https://api.tvmaze.com/singlesearch/shows?q=" + url_encode(title) + "&embed=previousepisode", ttl_seconds=3600)
        if resp["status_code"] != 200:
            continue
        data = resp["json"]
        prev = data.get("_embedded", {}).get("previousepisode", None)
        if prev == None:
            continue
        airdate = prev.get("airdate", "")
        if airdate == "":
            continue
        days_val = _days_from_civil(int(airdate[0:4]), int(airdate[5:7]), int(airdate[8:10]))
        if days_val - eastern_days != -1:
            continue
        service = entry["service"]
        if service == "":
            service = network_name(data)
        out.append({
            "title": title.upper(),
            "abbr": make_abbr(title, entry["abbr"]),
            "service": service.upper()[:11],
        })
    return out

def draw_show(c, m):
    lines = wrap_text(m["title"], 12)
    y = 1
    for line in lines[:2]:
        c.text_center(line, y, font="4x5", color="white")
        y += 6
    ch_y = 9 if len(lines) == 1 else 13
    c.text_center(m["ch"], ch_y, font="5x7", color="cyan")
    c.text_center(m["date"], ch_y + 10, font="4x5", color="amber")
    c.text_center(m["time"], ch_y + 17, font="4x5", color="amber")

def draw_nothing(c, day_label, date_str):
    c.text_center("NOTHING", 3, font="6x8", color="gray")
    c.text_center(day_label, 14, font="5x7", color="gray")
    c.text_center(date_str, 24, font="4x5", color="gray")

def draw_multi(c, matches):
    ordered = sorted(matches, key=match_time_key)
    shown = ordered[:3]
    extra = len(ordered) - 3

    c.text_center(shown[0]["date"], 0, font="4x5", color="gray")

    title_x = 1
    time_x = 18
    net_x = 50
    row_h = 6 if extra > 0 else 8

    y = 7
    for m in shown:
        c.text(m["abbr"], title_x, y, font="4x5", color="white")
        c.text(m["time"], time_x, y, font="4x5", color="amber")
        c.text(m["network"], net_x, y, font="4x5", color="cyan")
        y += row_h

    if extra > 0:
        c.text_center("+" + str(extra) + " MORE", 25, font="4x5", color="red")

def draw_stream(c, matches):
    c.text_center("STREAM TODAY", 0, font="4x5", color="gray")

    if len(matches) == 1:
        m = matches[0]
        lines = wrap_text(m["title"], 12)
        y = 8
        for line in lines[:2]:
            c.text_center(line, y, font="4x5", color="white")
            y += 6
        c.text_center(m["service"], y + 3, font="5x7", color="cyan")
        return

    shown = matches[:3]
    extra = len(matches) - 3
    row_h = 6 if extra > 0 else 8

    y = 7
    for m in shown:
        c.text(m["abbr"], 1, y, font="4x5", color="white")
        c.text(m["service"], 18, y, font="4x5", color="cyan")
        y += row_h

    if extra > 0:
        c.text_center("+" + str(extra) + " MORE", 25, font="4x5", color="red")

def draw_demo_tag(c):
    letters = ["D", "E", "M", "O"]
    y = 1
    for ch in letters:
        c.text(ch, 1, y, font="4x5", color="gray")
        y += 8

def today(c, ctx):
    c.clear()
    config = fetch_config(ctx)
    if config == None:
        draw_demo_tag(c)
        fake = {"title": "BIG BROTHER", "ch": "10.1 KFDA", "date": "SUN SEP 20", "time": "7:00PM"}
        draw_show(c, fake)
        return
    offset = int(ctx.inputs.get("utcoffset", -6))
    matches = find_matches(ctx, config, 0, MAX_CHECK, offset)
    if len(matches) == 0:
        draw_nothing(c, "TODAY", local_date_str(ctx, offset, 0))
    elif len(matches) == 1:
        draw_show(c, matches[0])
    else:
        draw_multi(c, matches)

def tomorrow(c, ctx):
    c.clear()
    config = fetch_config(ctx)
    if config == None:
        draw_demo_tag(c)
        fake = {"title": "SURVIVOR", "ch": "10.1 KFDA", "date": "WED SEP 23", "time": "8:00PM"}
        draw_show(c, fake)
        return
    offset = int(ctx.inputs.get("utcoffset", -6))
    matches = find_matches(ctx, config, 1, MAX_CHECK, offset)
    if len(matches) == 0:
        draw_nothing(c, "TOMORROW", local_date_str(ctx, offset, 1))
    elif len(matches) == 1:
        draw_show(c, matches[0])
    else:
        draw_multi(c, matches)

def later(c, ctx):
    c.clear()
    config = fetch_config(ctx)
    if config == None:
        draw_demo_tag(c)
        fake = {"title": "GHOSTS", "ch": "10.1 KFDA", "date": "SEP 27", "time": "9:00PM"}
        draw_show(c, fake)
        return
    offset = int(ctx.inputs.get("utcoffset", -6))
    matches = find_matches(ctx, config, "later", MAX_CHECK, offset)
    if len(matches) == 0:
        c.text_center("NOTHING SOON", 14, font="5x7", color="gray")
        return
    matches = sorted(matches, key=match_diff_key)
    draw_show(c, matches[0])

def stream(c, ctx):
    c.clear()
    config = fetch_config(ctx)
    if config == None:
        draw_demo_tag(c)
        fake = [{"title": "99 TO BEAT", "abbr": "99", "service": "HULU"}]
        draw_stream(c, fake)
        return
    offset = int(ctx.inputs.get("utcoffset", -6))
    matches = stream_matches(ctx, config)
    if len(matches) == 0:
        draw_nothing(c, "TO STREAM", local_date_str(ctx, offset, 0))
    else:
        draw_stream(c, matches)