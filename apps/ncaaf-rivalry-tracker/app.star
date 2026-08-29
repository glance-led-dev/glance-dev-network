def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()

def _norm(name):
    return str(name).strip().lower()

def _abbr(name, teams_map):
    if not name:
        return "TEAM"
    
    name_str = str(name)
    n = _norm(name_str)
    
    if n in teams_map and teams_map[n].get("abbreviation"):
        return teams_map[n]["abbreviation"].upper()
    
    if len(name_str) <= 4:
        return name_str.upper()
        
    parts = name_str.upper().split()
    if len(parts) >= 2:
        return (parts[0][:3] + parts[1][:1]).upper()
        
    return name_str[:4].upper()

def _color(team_name, teams_map, role):
    if not team_name:
        return "darkgray" if role != "secondary" else "white"
    n = _norm(str(team_name))
    if n in teams_map:
        col = teams_map[n].get(role)
        if col and col.startswith("#"):
            return col
    return "white" if role == "secondary" else "darkgray"

def season_year(ctx):
    """The football season a date belongs to.

    The season spans August to January, so January and February still belong to
    the year before. Hardcoding it meant the app silently queried a finished
    season the moment the calendar rolled over."""
    if ctx.now.month <= 2:
        return ctx.now.year - 1
    return ctx.now.year

def get_rivalry_titles():
    url = "https://raw.githubusercontent.com/SlaterDen/ncaaf-rivalries/refs/heads/main/rivalries.json"
    # A hand-maintained title list that changes a few times a season; a 10s TTL
    # (left over from testing) re-fetched it on every render of every panel.
    res = http.get(url, ttl_seconds=86400)
    
    if res["status_code"] == 200 and res["json"] != None:
        return res["json"]
    
    # Fallback dictionary if the network fetch fails
    return {
        "oklahoma|texas": "RED RIVER RIVALRY",
        "michigan|ohio state": "THE GAME"
    }

def rivalry_title(t1, t2):
    a = _norm(t1)
    b = _norm(t2)
    key = (a + "|" + b) if a < b else (b + "|" + a)
    titles_map = get_rivalry_titles()
    return titles_map.get(key, None)

def cfbd_get(path, params, apikey):
    return http.get(
        "https://api.collegefootballdata.com" + path,
        headers={"Authorization": "Bearer " + apikey},
        params=params,
        ttl_seconds=86400,
    )

def _safe_int(val):
    if val == None:
        return None
    s = str(val).strip()
    if s.isdigit():
        return int(s)
    return None

def _parse_date(dt_str):
    if dt_str == None or len(str(dt_str)) < 10:
        return None
    parts = str(dt_str).split("T")[0].split("-")
    if len(parts) == 3:
        m_map = {"01":"JAN","02":"FEB","03":"MAR","04":"APR","05":"MAY","06":"JUN","07":"JUL","08":"AUG","09":"SEP","10":"OCT","11":"NOV","12":"DEC"}
        month_str = m_map.get(parts[1], parts[1])
        return month_str + " " + parts[2]
    return None

def main(c, ctx):
    c.fill("black")

    apikey = _s(ctx, "apikey", "")
    user_t1 = _s(ctx, "team1", "Oklahoma")
    user_t2 = _s(ctx, "team2", "Texas")
    custom_title = _s(ctx, "customtitle", "")
    name_mode = _s(ctx, "teamnamelength", "Abbreviations")

    if not apikey:
        c.text_center("ADD CFBD API KEY".upper(), 8, font="5x7", color="red")
        c.text_center("COLLEGEFOOTBALLDATA.COM", 20, font="4x5", color="gray")
        return

    # Fetch dynamic FBS team directory for validation, colors, and abbreviations
    teams_r = cfbd_get("/teams/fbs", {}, apikey)
    teams_map = {}
    if teams_r["status_code"] == 200 and teams_r["json"] != None:
        for t in teams_r["json"]:
            school = t.get("school", "")
            if school:
                teams_map[_norm(school)] = {
                    "abbreviation": t.get("abbreviation"),
                    "color": t.get("color"),
                    "alt_color": t.get("alt_color")
                }

    # Validate that both user input teams exist in the FBS directory
    t1_norm = _norm(user_t1)
    t2_norm = _norm(user_t2)
    
    if len(teams_map) > 0 and (t1_norm not in teams_map or t2_norm not in teams_map):
        c.rect(0, 0, c.width - 1, 9, fill="#800000")
        c.text_center("INVALID TEAM INPUT", 1, font="6x8", color="white")
        c.text_center("CHECK TEAMS SPELLING", 14, font="5x7", color="yellow")
        return

    # Fetch dynamic rankings (CFP preferred, AP fallback)
    rankings_map = {}
    year = season_year(ctx)
    rank_r = cfbd_get("/rankings", {"year": year}, apikey)
    if rank_r["status_code"] == 200 and rank_r["json"] != None:
        weeks_data = rank_r["json"]
        if len(weeks_data) > 0:
            latest_week = weeks_data[len(weeks_data) - 1]
            polls = latest_week.get("polls", [])
            
            ap_polls = []
            cfp_polls = []
            for p in polls:
                p_type = _norm(p.get("poll", ""))
                if "playoff" in p_type or "cfp" in p_type:
                    cfp_polls = p.get("ranks", [])
                elif "ap" in p_type or "associated press" in p_type:
                    ap_polls = p.get("ranks", [])
            
            active_ranks = cfp_polls if len(cfp_polls) > 0 else ap_polls
            for item in active_ranks:
                school_name = item.get("school", "")
                rk = item.get("rank")
                if school_name and rk:
                    rankings_map[_norm(school_name)] = int(rk)

    r = cfbd_get("/teams/matchup", {
        "team1": user_t1,
        "team2": user_t2,
    }, apikey)

    if r["status_code"] != 200:
        c.text_center("API ERROR".upper(), 8, font="5x7", color="red")
        c.text_center(str(r["status_code"]).upper(), 20, font="4x5", color="gray")
        return

    data = r["json"]
    if data == None:
        c.text_center("NO SERIES DATA".upper(), 12, font="5x7", color="amber")
        return

    api_t1 = data.get("team1", user_t1)
    raw_w1 = int(data.get("team1Wins", 0) or 0)
    raw_w2 = int(data.get("team2Wins", 0) or 0)
    ties = int(data.get("ties", 0) or 0)

    if _norm(user_t1) == _norm(api_t1):
        team1 = user_t1
        team2 = user_t2
        w1 = raw_w1
        w2 = raw_w2
    else:
        team1 = user_t2
        team2 = user_t1
        w1 = raw_w2
        w2 = raw_w1

    total = w1 + w2 + ties
    a1 = _abbr(team1, teams_map)
    a2 = _abbr(team2, teams_map)

    r1_val = rankings_map.get(_norm(team1))
    r2_val = rankings_map.get(_norm(team2))

    if custom_title:
        title = custom_title.upper()
    else:
        title = rivalry_title(user_t1, user_t2)
        if title == None:
            title = "TEAM SERIES HISTORY"
        else:
            title = title.upper()

    games = data.get("games", [])
    if games == None:
        games = []

    past_games = []
    next_matchup_date = None

    for g in games:
        s1 = g.get("team1Score")
        s2 = g.get("team2Score")
        if s1 == None or s2 == None:
            s1 = g.get("homeScore")
            s2 = g.get("awayScore")
            
        if s1 != None and s2 != None:
            past_games.append(g)
        else:
            dt = _parse_date(g.get("startDate"))
            if dt != None:
                next_matchup_date = dt

    if next_matchup_date == None:
        sched_r = cfbd_get("/games", {
            "year": year,
            "team": team1,
        }, apikey)
        if sched_r["status_code"] == 200 and sched_r["json"] != None:
            for sg in sched_r["json"]:
                h = _norm(sg.get("homeTeam", ""))
                a = _norm(sg.get("awayTeam", ""))
                t2_norm = _norm(team2)
                if t2_norm in h or t2_norm in a:
                    hs = sg.get("home_points")
                    as_ = sg.get("away_points")
                    if hs == None and as_ == None:
                        dt = _parse_date(sg.get("startDate"))
                        if dt != None:
                            next_matchup_date = dt
                            break

    if next_matchup_date == None:
        next_matchup_date = "TBD"

    past_games = sorted(past_games, key=lambda g: g.get("season", 0), reverse=True)

    # The bitmap fonts are ASCII: an em dash has no glyph and draws as nothing.
    last_game_str = "-"
    streak_who = ""
    streak_len = 0

    if len(past_games) > 0:
        g0 = past_games[0]
        s1 = _safe_int(g0.get("team1Score"))
        s2 = _safe_int(g0.get("team2Score"))
        if s1 == None or s2 == None:
            s1 = _safe_int(g0.get("homeScore"))
            s2 = _safe_int(g0.get("awayScore"))

        if s1 != None and s2 != None:
            g_team1 = _norm(g0.get("team1", g0.get("homeTeam", "")))
            if _norm(team1) in g_team1 or g_team1 in _norm(team1):
                score_t1, score_t2 = s1, s2
            else:
                score_t1, score_t2 = s2, s1

            if score_t1 > score_t2:
                last_game_str = a1 + " " + str(score_t1) + "-" + str(score_t2)
            elif score_t2 > score_t1:
                last_game_str = a2 + " " + str(score_t2) + "-" + str(score_t1)
            else:
                last_game_str = "TIE " + str(score_t1) + "-" + str(score_t2)

        winner = None
        t1n = _norm(team1)

        for g in past_games:
            hs = _safe_int(g.get("homeScore"))
            as_ = _safe_int(g.get("awayScore"))
            if hs == None or as_ == None:
                hs = _safe_int(g.get("team1Score"))
                as_ = _safe_int(g.get("team2Score"))
                if hs == None or as_ == None:
                    break
                ht = _norm(g.get("team1", g.get("homeTeam", "")))
                at = _norm(g.get("team2", g.get("awayTeam", "")))
            else:
                ht = _norm(g.get("homeTeam", ""))
                at = _norm(g.get("awayTeam", ""))

            if hs > as_:
                w = ht
            elif as_ > hs:
                w = at
            else:
                break

            if winner == None:
                winner = w
            if w != winner:
                break

            streak_len += 1

        if streak_len > 0 and winner != None:
            if t1n in winner or winner in t1n:
                streak_who = a1
            else:
                streak_who = a2

    bar_y0 = 10
    bar_y1 = 21

    if total > 0:
        # ----- STANDARD SERIES LAYOUT -----
        c.rect(0, 0, c.width - 1, 9, fill="#4D8064")
        c.text_center(title, 1, font="6x8", color="white")

        bg1 = _color(team1, teams_map, "color")
        bg2 = _color(team2, teams_map, "color")
        bar_w = c.width

        w1_px = int(bar_w * float(w1) / float(total) + 0.5)
        ties_px = int(bar_w * float(ties) / float(total) + 0.5)

        if w1_px < 0: w1_px = 0
        if ties_px < 0: ties_px = 0

        curr_x = 0
        if w1_px > 0:
            c.rect(curr_x, bar_y0, curr_x + w1_px - 1, bar_y1, fill=bg1)
            curr_x += w1_px
        if ties_px > 0:
            c.rect(curr_x, bar_y0, curr_x + ties_px - 1, bar_y1, fill="gray")
            curr_x += ties_px

        w2_px = bar_w - curr_x
        if w2_px > 0:
            c.rect(curr_x, bar_y0, curr_x + w2_px - 1, bar_y1, fill=bg2)

        # Name mode check (Abbreviations vs Full Name limited to 12 chars + win number)
        if name_mode == "Full Name":
            t1_trimmed = team1.upper()
            if len(t1_trimmed) > 12:
                t1_trimmed = t1_trimmed[:12]
            t2_trimmed = team2.upper()
            if len(t2_trimmed) > 12:
                t2_trimmed = t2_trimmed[:12]

            left_main = t1_trimmed + " " + str(w1)
            right_main = str(w2) + " " + t2_trimmed
            main_font = "5x7"
            text_y = 12
        else:
            left_main = (a1 + " " + str(w1)).upper()
            right_main = (str(w2) + " " + a2).upper()
            main_font = "7x10"
            text_y = 11

        left_x = 12 if r1_val != None else 4
        right_x_offset = 12 if r2_val != None else 4

        c.text(left_main, left_x, text_y, font=main_font, color="white")
        c.text(right_main, c.width - right_x_offset, text_y, font=main_font, color="white", align="right")

        if r1_val != None:
            c.text(str(r1_val), 1, text_y, font="4x5", color="white")
        if r2_val != None:
            c.text(str(r2_val), c.width - 2, text_y, font="4x5", color="white", align="right")

        c.rect(0, 22, c.width - 1, 22, fill="gray")

        # ----- 3-SECTION BOTTOM GRID (LAST | STREAK | NEXT) -----
        bg_last = _color(team1, teams_map, "color")
        if len(past_games) > 0:
            g0 = past_games[0]
            s1_g0 = _safe_int(g0.get("team1Score", g0.get("homeScore")))
            s2_g0 = _safe_int(g0.get("team2Score", g0.get("awayScore")))
            if s1_g0 != None and s2_g0 != None:
                g_t1 = _norm(g0.get("team1", g0.get("homeTeam", "")))
                if s1_g0 > s2_g0:
                    bg_last = _color(team1 if _norm(team1) in g_t1 else team2, teams_map, "color")
                elif s2_g0 > s1_g0:
                    bg_last = _color(team2 if _norm(team1) in g_t1 else team1, teams_map, "color")

        bg_streak = "gray"
        if streak_len > 0:
            if streak_who == a1:
                bg_streak = _color(team1, teams_map, "color")
            elif streak_who == a2:
                bg_streak = _color(team2, teams_map, "color")

        c.rect(0, 23, 80, 31, fill=bg_last)
        c.rect(80, 23, 80, 31, fill="gray")
        c.rect(81, 23, 114, 31, fill=bg_streak)
        c.rect(114, 23, 114, 31, fill="gray")
        c.rect(115, 23, c.width - 1, 31, fill="#1c1c1c")

        last_str = "LAST: " + last_game_str.upper()
        streak_str = (streak_who + ":" + str(streak_len)).upper() if streak_len > 0 else "STR: -"
        next_str = "NEXT: " + next_matchup_date.upper()

        c.text(last_str, 3, 24, font="4x7", color="white")
        c.text(streak_str, 83, 24, font="4x7", color="white")
        c.text(next_str, 118, 24, font="4x7", color="white")

    else:
        # ----- FIRST MEETING LAYOUT -----
        c.rect(0, 0, c.width - 1, 9, fill="#4D8064")
        c.text_center("FIRST ALL-TIME MEETING", 1, font="6x8", color="white")

        c1_hex = _color(team1, teams_map, "color")
        c2_hex = _color(team2, teams_map, "color")
        c.gradient_rect(0, bar_y0, c.width - 1, 32, c1_hex, c2_hex)

        if name_mode == "Full Name":
            t1_trimmed = team1.upper()
            if len(t1_trimmed) > 12:
                t1_trimmed = t1_trimmed[:12]
            t2_trimmed = team2.upper()
            if len(t2_trimmed) > 12:
                t2_trimmed = t2_trimmed[:12]

            left_main = t1_trimmed
            right_main = t2_trimmed
            main_font = "5x7"
            text_y = 12
        else:
            left_main = team1.upper()
            right_main = team2.upper()
            main_font = "6x8"
            text_y = 11

        left_x = 12 if r1_val != None else 4
        right_x_offset = 12 if r2_val != None else 4

        c.text(left_main, left_x, text_y, font=main_font, color="white")
        c.text(right_main, c.width - right_x_offset, text_y, font=main_font, color="white", align="right")

        if r1_val != None:
            c.text(str(r1_val), 1, text_y, font="4x5", color="white")
        if r2_val != None:
            c.text(str(r2_val), c.width - 2, text_y, font="4x5", color="white", align="right")

        line = "NEXT: " + next_matchup_date.upper()
        c.text_center(line, 22, font="6x8", color="white")