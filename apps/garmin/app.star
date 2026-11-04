def garmin_cycling(c, ctx):
    # ==========================================
    # HEADER: Left-Justified Garmin Branding
    # ==========================================
    c.text("LAST RIDE", 1, 0, font="4x5", color="#11A9ED", align="left")
    c.line(0, 6, 63, 6, "#222222")

    api_key = ctx.inputs.get("apikey", "")
    
    dist_str = "15.2"
    time_str = "1H 24M"
    elev_str = "^850FT"

    if api_key:
        url = "https://personal.connectapi.garmin.com/activitylist-service/activities/search/activities?limit=15"
        headers = {"Authorization": "Bearer " + api_key}
        
        # ttl_seconds=300 ensures both pages share the exact same cached API response
        resp = http.get(url, headers=headers, ttl_seconds=300)

        if resp["status_code"] == 200:
            data = resp["json"]
            activities = data if type(data) == "list" else data.get("activities", [])
                
            cycling_act = None
            for act in activities:
                act_type = act.get("activityType", {})
                type_key = act_type.get("typeKey", "") if type(act_type) == "dict" else (act_type if type(act_type) == "string" else "")
                
                if "cycling" in type_key.lower() or "biking" in type_key.lower() or "ride" in type_key.lower():
                    cycling_act = act
                    break
                    
            if not cycling_act and len(activities) > 0:
                cycling_act = activities[0] 
                
            if cycling_act:
                dist_m = float(cycling_act.get("distance") or 0.0)
                time_s = int(cycling_act.get("duration") or 0)
                elev_m = float(cycling_act.get("elevationGain") or 0.0)

                dist_mi = dist_m / 1609.34
                elev_ft = elev_m * 3.28084
                
                dist_str = "%.1f" % dist_mi
                
                hours = time_s // 3600
                mins = (time_s % 3600) // 60
                time_str = "%dH%dM" % (hours, mins) if hours > 0 else "%dM" % mins
                elev_str = "^%dFT" % int(elev_ft)
        else:
            c.text("ERR", 45, 0, font="4x5", color="red")
    else:
        c.text("NO KEY", 36, 0, font="4x5", color="red")

    # ==========================================
    # LEFT SIDE: Detailed Accurate Bicycle
    # ==========================================
    # Wheels (Radius 5 circles centered at Y=24)
    c.circle(7, 24, 5, "gray")
    c.circle(21, 24, 5, "gray")
    
    # Wheel Hubs
    c.pixel(7, 24, "skyblue")
    c.pixel(21, 24, "skyblue")
    
    # Diamond Frame Geometry 
    # (Bottom bracket at 14,24 | Head tube at 18,14 | Seat cluster at 11,14)
    c.line(7, 24, 14, 24, "white")   # Chainstay
    c.line(7, 24, 11, 14, "white")   # Seatstay
    c.line(14, 24, 11, 14, "white")  # Seattube
    c.line(14, 24, 18, 14, "white")  # Downtube
    c.line(11, 14, 18, 14, "white")  # Toptube
    c.line(21, 24, 18, 14, "white")  # Fork
    
    # Saddle (Seat)
    c.line(9, 13, 13, 13, "white")
    c.pixel(11, 14, "white")         # Seatpost
    
    # Handlebars & Stem
    c.line(18, 14, 19, 12, "white")  # Stem
    c.line(18, 12, 22, 12, "white")  # Handlebars
    
    # Crank & Pedal
    c.pixel(14, 24, "white")         # Bottom bracket / crank center
#    c.line(14, 24, 16, 27, "white")  # Crank arm & pedal

    # ==========================================
    # RIGHT SIDE: Ride Metrics
    # ==========================================
    c.line(28, 7, 28, 31, "#222222") 
    stat_x = 29

    c.text(dist_str, stat_x, 8, font="5x7", color="white", align="left")
    dist_w = c.text_width(dist_str, "5x7")
    c.text("MI", stat_x + dist_w + 1, 10, font="4x5", color="gray", align="left")
    c.text(time_str, stat_x, 17, font="4x5", color="skyblue", align="left")
    c.text(elev_str, stat_x, 26, font="4x5", color="amber", align="left")

def garmin_strength(c, ctx):
    # ==========================================
    # HEADER: Left-Justified Garmin Branding
    # ==========================================
    c.text("LAST LIFT", 1, 0, font="4x5", color="#11A9ED", align="left")
    c.line(0, 6, 63, 6, "#222222")

    api_key = ctx.inputs.get("apikey", "")
    
    hero_val = "45"
    hero_unit = "MIN"
    vol_str = "15.4K LB"
    cal_str = "320 CAL"

    if api_key:
        url = "https://personal.connectapi.garmin.com/activitylist-service/activities/search/activities?limit=15"
        headers = {"Authorization": "Bearer " + api_key}
        
        # Hits the cache from the cycling page, preventing double API requests
        resp = http.get(url, headers=headers, ttl_seconds=300)

        if resp["status_code"] == 200:
            data = resp["json"]
            activities = data if type(data) == "list" else data.get("activities", [])
                
            strength_act = None
            for act in activities:
                act_type = act.get("activityType", {})
                type_key = act_type.get("typeKey", "") if type(act_type) == "dict" else (act_type if type(act_type) == "string" else "")
                
                if "strength" in type_key.lower() or "weight" in type_key.lower() or "fitness_equipment" in type_key.lower():
                    strength_act = act
                    break
                    
            if not strength_act and len(activities) > 0:
                strength_act = activities[0] 
                
            if strength_act:
                time_s = int(strength_act.get("duration") or 0)
                hours = time_s // 3600
                mins = (time_s % 3600) // 60
                
                if hours > 0:
                    hero_val = "%dH%d" % (hours, mins)
                    hero_unit = "M"
                else:
                    hero_val = "%d" % mins
                    hero_unit = "MIN"

                vol_kg = float(strength_act.get("totalWork") or strength_act.get("volume") or 0.0)
                vol_lb = vol_kg * 2.20462
                vol_str = "%.1fK LB" % (vol_lb / 1000.0) if vol_lb > 1000 else "%d LB" % int(vol_lb)

                cals = int(strength_act.get("calories") or strength_act.get("activeCalories") or 0)
                cal_str = "%d CAL" % cals
        else:
            c.text("ERR", 45, 0, font="4x5", color="red")
    else:
        c.text("NO KEY", 36, 0, font="4x5", color="red")

    # ==========================================
    # LEFT SIDE: Detailed Loaded Barbell
    # ==========================================
    # 1. Main Bar Shaft (Center axis Y=19)
    c.line(1, 19, 26, 19, "#DDDDDD")
    
    # Knurling (Grip texture on the main shaft)
    c.pixel(11, 19, "#888888")
    c.pixel(13, 19, "#888888")
    c.pixel(14, 19, "#888888")
    c.pixel(16, 19, "#888888")

    # 2. Inner Collars
    c.line(8, 17, 8, 21, "white")
    c.pixel(8, 17, "gray") # Shading edge
    c.pixel(8, 21, "gray")
    
    c.line(19, 17, 19, 21, "white")
    c.pixel(19, 17, "gray")
    c.pixel(19, 21, "gray")

    # 3. Large 45lb Pates (Layered colors create a 3D isometric look)
    # Left 45
    c.line(5, 12, 5, 27, "gray")      # Face highlight
    c.line(6, 12, 6, 27, "#555555")   # Plate thickness
    c.line(7, 12, 7, 27, "#222222")   # Deep shadow edge
    # Right 45
    c.line(20, 12, 20, 27, "#222222") 
    c.line(21, 12, 21, 27, "#555555") 
    c.line(22, 12, 22, 27, "gray")    

    # 4. Medium 25lb Plates
    # Left 25
    c.line(3, 15, 3, 24, "gray")
    c.line(4, 15, 4, 24, "#222222")
    # Right 25
    c.line(23, 15, 23, 24, "#222222")
    c.line(24, 15, 24, 24, "gray")

    # 5. Small 10lb Plates
    # Left 10
    c.line(1, 17, 1, 22, "gray")
    c.line(2, 17, 2, 22, "#222222")
    # Right 10
    c.line(25, 17, 25, 22, "#222222")
    c.line(26, 17, 26, 22, "gray")

    # ==========================================
    # RIGHT SIDE: Workout Metrics
    # ==========================================
    c.line(28, 7, 28, 31, "#222222") 
    stat_x = 30

    c.text(hero_val, stat_x, 8, font="5x7", color="white", align="left")
    hero_w = c.text_width(hero_val, "5x7")
    c.text(hero_unit, stat_x + hero_w + 1, 10, font="4x5", color="gray", align="left")
    c.text(vol_str, stat_x, 18, font="4x5", color="skyblue", align="left")
    c.text(cal_str, stat_x, 26, font="4x5", color="amber", align="left")