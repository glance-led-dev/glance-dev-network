# Commute / 192x32. All artwork is drawn at native pixel resolution.
WHITE = "#F2F6FF"
GRAY = "#A9B9CE"
GREEN = "#55F3A6"
AMBER = "#FFC54A"
RED = "#FF5964"
BLUE = "#4BAAFF"

def hazard_color(level):
    return {"attention":"#FFE15A","warning":"#FF933D","severe":"#FF3D4F"}.get(level,WHITE)

def hazard(c,x,y,level):
    if level not in ["attention","warning","severe"]:
        return
    color=hazard_color(level)
    for yy in range(7):
        half=(yy*4)//6
        c.line(x+4-half,y+yy,x+4+half,y+yy,color)
    c.line(x+4,y+2,x+4,y+3,"black")
    c.pixel(x+4,y+5,"black")

def alert_hazard(alert):
    if alert.get("severity") in ["Extreme","Severe"]:
        return "severe"
    if alert.get("severity") == "Moderate":
        return "warning"
    return "attention"

def obj(v):
    return v if type(v) == "dict" else {}

def clean(v):
    return " ".join("".join([ch if ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :+-/().'%" else " " for ch in str(v).upper().elems()]).split())

def clip(c, s, width, font = "4x5"):
    s = clean(s)
    if c.text_width(s, font) <= width:
        return s
    for n in range(len(s), -1, -1):
        if c.text_width(s[:n] + "..", font) <= width:
            return s[:n] + ".."
    return ""

def txt(c, s, x, y, width, font = "4x5", color = WHITE):
    c.text(clip(c, s, width, font), x, y, font = font, color = color)

def centered(c, s, x, y, width, font = "4x5", color = WHITE):
    value = clip(c, s, width, font)
    c.text(value, x + (width - c.text_width(value, font)) // 2, y, font = font, color = color)

def pavement(c):
    # A perspective road gives the app its identity without eating text space.
    for y in range(23, 32):
        half = 3 + (y - 23)
        c.line(23 - half, y, 23 + half, y, "#222D3D")
        c.pixel(23 - half, y, GRAY)
        c.pixel(23 + half, y, GRAY)
    for y in [24, 25, 28, 29, 30]:
        c.pixel(23, y, AMBER)

def starbucks(c):
    c.image("assets/starbucks.png",10,4)
    # Clear iced-coffee cup, green straw, pale ice cubes and dark coffee.
    c.line(42,1,42,11,"#00A862")
    c.line(42,1,47,1,"#00A862")
    c.rect(35,9,49,11,fill="#E0F7FF")
    c.rect(36,12,48,21,fill="#CA9464",outline="#B7DBE7")
    c.rect(37,22,47,27,fill="#895331",outline="#B7DBE7")
    c.line(38,28,46,28,"#B7DBE7")
    c.rect(38,13,40,15,fill="#DCF3F6")
    c.rect(43,14,46,16,fill="#DCF3F6")
    c.rect(40,18,43,20,fill="#DCF3F6")

def sign(c, road):
    kind = road.get("kind", "road")
    number = clean(road.get("number", ""))
    if kind == "interstate":
        # White outline, red crown and curved blue Interstate shield.
        for y in range(2, 22):
            inset = 0 if y < 15 else (y - 14) // 2
            c.line(11 + inset, y, 35 - inset, y, WHITE)
            if y > 2 and y < 21:
                c.line(12 + inset, y, 34 - inset, y, "#D82D42" if y <= 8 else "#0757BA")
        centered(c, "I", 13, 3, 21, color = WHITE)
        centered(c, number, 13, 11, 21, "5x7")
    elif kind == "state":
        # Ohio-style white state silhouette; SR explicitly identifies route type.
        c.rect(12, 3, 34, 19, fill = WHITE)
        c.line(12, 2, 18, 4, WHITE)
        c.line(29, 4, 35, 1, WHITE)
        c.line(12, 19, 26, 22, WHITE)
        centered(c, "SR", 13, 4, 21, color = "black")
        centered(c, number, 13, 12, 21, "5x7", "black")
    elif kind == "us":
        for y in range(2, 22):
            inset = 0 if y < 15 else (y - 14) // 2
            c.line(11 + inset, y, 35 - inset, y, WHITE)
        centered(c, "US", 13, 3, 21, color = "black")
        centered(c, number, 13, 11, 21, "5x7", "black")
    else:
        c.rect(11, 3, 35, 19, fill = "#064D35", outline = WHITE)
        c.line(23, 8, 23, 16, WHITE)
        c.line(19, 11, 23, 7, WHITE)
        c.line(27, 11, 23, 7, WHITE)
        c.rect(22, 20, 24, 22, fill = GRAY)
    pavement(c)

def weather_icon(c, kind, x, y):
    if kind in ["sun", "partly"]:
        c.fill_circle(x + 5, y + 5, 3, "#FFD14B")
        for dx, dy in [[5,0],[5,10],[0,5],[10,5],[1,1],[9,1],[1,9],[9,9]]:
            c.pixel(x+dx,y+dy,"#FFD14B")
    if kind in ["cloud", "partly", "rain", "snow", "storm"]:
        c.fill_circle(x + 5, y + 5, 3, "#C2D5EA")
        c.fill_circle(x + 9, y + 6, 3, "#C2D5EA")
        c.rect(x+2,y+6,x+11,y+8,fill="#C2D5EA")
    if kind == "rain":
        for dx in [3,7,11]:
            c.line(x+dx,y+10,x+dx-1,y+12,BLUE)
    elif kind == "snow":
        for dx in [3,9]:
            c.line(x+dx-1,y+11,x+dx+1,y+11,WHITE)
            c.line(x+dx,y+10,x+dx,y+12,WHITE)
    elif kind == "storm":
        c.line(x+7,y+9,x+4,y+11,AMBER)
        c.line(x+4,y+11,x+8,y+11,AMBER)
        c.line(x+8,y+11,x+5,y+13,AMBER)
    elif kind == "moon":
        c.fill_circle(x+6,y+6,5,"#DADCF5")
        c.fill_circle(x+9,y+3,5,"black")
    elif kind == "fog":
        for yy in [3,6,9]:
            c.line(x+1,y+yy,x+11,y+yy,GRAY)
    elif kind == "unknown":
        c.text("?",x+4,y+3,font="5x7",color=GRAY)

def warning_sign(c, kind, color):
    for y in range(2, 25):
        half = min(y-2,24-y)
        c.line(23-half,y,23+half,y,color)
    if kind == "construction":
        c.fill_circle(23,9,2,"black")
        c.line(23,12,19,17,"black")
        c.line(23,12,28,16,"black")
        c.line(21,15,25,20,"black")
        c.line(27,15,29,20,"black")
    else:
        c.rect(22,8,24,15,fill="black")
        c.rect(22,18,24,19,fill="black")
    c.line(21,25,21,31,GRAY)
    c.line(25,25,25,31,GRAY)

def message(c, title, detail, color = AMBER):
    c.fill("black")
    warning_sign(c,"warning",color)
    txt(c,"COMMUTE",43,1,136,color=GRAY)
    txt(c,title,43,10,136,"5x7",color)
    txt(c,detail,43,24,136)

def demo_data(s, now):
    road = {"kind":"interstate","number":"675","label":"I-675"}
    if s == "Local road":
        road = {"kind":"road","number":"","label":"WILMINGTON PIKE"}
    elif s == "State route":
        road = {"kind":"state","number":"725","label":"SR-725"}
    elif s == "US route":
        road = {"kind":"us","number":"35","label":"US-35"}
    direct = {"road":road,"minutes":24,"normalMinutes":21,"delayMinutes":3,"arrival":"7:48A","leaveBy":"7:36A","late":False}
    stop = {"road":road,"minutes":34,"normalMinutes":31,"delayMinutes":3,"arrival":"7:58A","leaveBy":"7:26A","late":False,"stopMinutes":5}
    weather = {"kind":"sun","temperatureF":68,"description":"SUNNY","basis":"OBSERVATION","location":"NEAR START"}
    kinds = {"Rain":"rain","Storm warning":"storm","Snow advisory":"snow","Clouds":"cloud","Night":"moon","Fog":"fog"}
    weather["kind"] = kinds.get(s,"sun")
    weather["description"] = {"rain":"RAIN","storm":"THUNDERSTORM","snow":"SNOW","cloud":"CLOUDY","moon":"CLEAR NIGHT","fog":"FOG","sun":"SUNNY"}.get(weather["kind"])
    alerts = []
    scenarios = {"Storm warning":["TORNADO WARNING","TAKE SHELTER NOW","weather","Extreme"],"Snow advisory":["SNOW LEVEL 2","DEMO COUNTY ADVISORY","snowlevel","Severe"],"Construction":["CONSTRUCTION","LANE RESTRICTIONS","construction","Minor"],"Accident":["ACCIDENT","RIGHT LANE BLOCKED","incident","Moderate"],"Road closed":["ROAD CLOSED","USE ALTERNATE ROUTE","closure","Severe"]}
    scenarios["Warning traffic outage"]=scenarios["Storm warning"]
    scenarios["Dangerous slowdown"]=["DANGEROUS SLOWDOWN","15 MPH / USUAL 65 MPH","slowdown","Severe"]
    if s in scenarios:
        a=scenarios[s]
        alerts=[{"title":a[0],"detail":a[1],"road":"I-675 N","kind":a[2],"severity":a[3],"scope":"ROUTE AREA","source":"DEMO","expires":None}]
        if s == "Snow advisory":
            alerts[0]["road"]="DEMO COUNTY"
    source = {"state":"ok"}
    d = {"schema":1,"state":"ok","updatedAt":now,"stale":False,"demo":True,"label":"WORK","checkedTime":"7:24A","stopName":"STARBUCKS","stopEnabled":True,"stopState":"ok","direct":direct,"stop":stop,"addedMinutes":10,"weather":weather,"sources":{"weatherAlerts":source,"roads":source,"county":source},"alerts":{"direct":alerts,"stop":alerts},"alternatives":[{"road":{"label":"WILMINGTON PIKE"},"minutes":28}],"arriveBy":"08:00"}
    if s == "Warning traffic outage":
        d["stale"]=True
        d["state"]="unavailable"
    if s == "Stop too late":
        stop["late"] = True
    elif s == "Leave now":
        direct["leaveAt"]=now+30
    elif s == "Late":
        direct["leaveAt"]=now-480
    elif s == "Long names":
        road["label"] = "A VERY LONG LOCAL HIGHWAY NAME"
        road["kind"] = "road"
        d["stopName"] = "NEIGHBORHOOD COFFEE SHOP"
    elif s == "Heavy traffic":
        direct["minutes"] = 124
        direct["delayMinutes"] = 103
    elif s == "Stale":
        d["updatedAt"] = now-600
        d["stale"] = True
    elif s == "Feed unavailable":
        d["sources"]["roads"] = {"state":"unavailable"}
        d["sources"]["weatherAlerts"] = {"state":"unavailable"}
        d["sources"]["county"] = {"state":"unavailable"}
        d["weather"]["kind"] = "unknown"
        d["weather"]["description"] = "WEATHER UNAVAILABLE"
        d["weather"]["temperatureF"] = None
    elif s == "No stop":
        d["stop"] = None
        d["stopEnabled"] = False
        d["stopState"] = "disabled"
    elif s == "Stop unavailable":
        d["stop"] = None
        d["stopState"] = "unavailable"
    wx={"state":"ok","temperatureLowF":66,"temperatureHighF":68,"visibilityMiles":10,"description":weather["description"],"kind":weather["kind"],"observedAt":now-300,"road":None,"ohgoState":"ok","nwsState":"ok","sensors":[]}
    if s in ["Rain","Fog"]:
        wx["visibilityMiles"]=2 if s == "Rain" else 0.25
    if s == "Winter roads":
        wx.update({"temperatureLowF":28,"temperatureHighF":31,"visibilityMiles":0.5,"description":"LIGHT SNOW","kind":"snow","road":{"temperatureF":29,"status":"ICE","location":"I-675 SENSOR","observedAt":now-300}})
    if s == "Sensors missing":
        wx["ohgoState"]="unavailable"
    if s == "Visibility missing":
        wx["visibilityMiles"]=None
    if s in ["Weather stale","Feed unavailable"]:
        wx.update({"state":"unavailable","temperatureLowF":None,"temperatureHighF":None,"visibilityMiles":None,"description":"WEATHER UNKNOWN","kind":"unknown","observedAt":None,"ohgoState":"unavailable"})
    wx["visibilityHazard"]="attention" if s == "Rain" else "severe" if s == "Fog" else "warning" if s == "Winter roads" else "none"
    wx["conditionHazard"]="attention" if s in ["Fog","Winter roads"] else "none"
    if wx.get("road"):
        wx["road"]["hazard"]="severe"
    d["routeWeather"]={"direct":wx,"stop":wx}
    return d

def fetch_data(ctx):
    scenario = ctx.inputs.get("demo", "Live")
    if scenario != "Live":
        d=demo_data(scenario,ctx.now.unix)
        selected=ctx.inputs.get("arrivetime","Configured")
        if selected in ["08:15","08:30"]:
            d["arriveBy"]=selected
            d["direct"]["leaveBy"]="7:51A" if selected == "08:15" else "8:06A"
            if d.get("stop"):
                d["stop"]["leaveBy"]="7:41A" if selected == "08:15" else "7:56A"
        extra=900 if selected == "08:15" else 1800 if selected == "08:30" else 0
        d["direct"]["leaveAt"]=d["direct"].get("leaveAt",ctx.now.unix+(36-d["direct"]["minutes"])*60)+extra
        if d.get("stop"):
            d["stop"]["leaveAt"]=ctx.now.unix-120+extra if scenario == "Stop too late" else d["direct"]["leaveAt"]-600
        d["recommendation"]={"kind":"faster","minutes":4,"otherRoad":"WILMINGTON PIKE"}
        return d
    url = ctx.inputs.get("endpoint", "").strip()
    key = ctx.inputs.get("readkey", "").strip()
    if not url or not key:
        return {"error":"SETUP REQUIRED","detail":"ADD STATUS URL + KEY"}
    if not url.startswith("https://") or "?" in url or "#" in url:
        return {"error":"INVALID URL","detail":"USE HTTPS STATUS URL"}
    r = http.get(url,headers={"Authorization":"Bearer "+key},params={"arriveby":ctx.inputs.get("arrivetime","Configured")},ttl_seconds=30)
    if r["status_code"] != 200:
        return {"error":"NO LIVE DATA","detail":"CHECK WORKER + KEY"}
    d = obj(r.get("json"))
    if d.get("schema") != 1 or type(d.get("updatedAt")) not in ["int","float"]:
        return {"error":"INVALID DATA","detail":"CHECK COMMUTE WORKER"}
    return d

def valid_route(r):
    return type(r) == "dict" and type(r.get("minutes")) in ["int","float"] and r.get("minutes") >= 0 and type(r.get("road")) == "dict"

def get_data(c,ctx,weather_page = False):
    d = fetch_data(ctx)
    if d.get("error"):
        message(c,d["error"],d.get("detail","CHECK SETUP"))
        return None
    if d.get("state") == "setup":
        message(c,"SETUP REQUIRED",d.get("message","CHECK WORKER"))
        return None
    age = ctx.now.unix-d.get("updatedAt",0)
    which="stop" if ctx.inputs.get("trip","Direct") == "Stopover" else "direct"
    alert=current_alert(d,ctx,which)
    if alert.get("kind") == "weather" and alert.get("severity") in ["Extreme","Severe"] and obj(obj(d.get("sources")).get("weatherAlerts")).get("state") in ["ok","partial"]:
        message(c,alert.get("title","NWS WARNING"),alert.get("detail","CHECK NWS ALERT"),RED)
        c.rect(43,0,181,6,fill="black")
        txt(c,"DEMO WARNING" if d.get("demo") else "NWS / ROUTE WARNING",43,1,136,color=RED)
        return None
    if not weather_page and (d.get("stale") or age > 180 or age < -30 or d.get("state") != "ok"):
        c.fill("black")
        txt(c,"DEMO / TRAFFIC STALE" if d.get("demo") else "TRAFFIC STALE",11,1,170,"5x7",GRAY)
        txt(c,"CHECK NAVIGATION",11,12,170,"5x7",WHITE)
        txt(c,"LAST CHECK "+d.get("checkedTime","--"),11,24,170,"5x7",GRAY)
        return None
    if not valid_route(d.get("direct")):
        message(c,"NO ROUTE DATA","CHECK LOCATIONS")
        return None
    return d

def current_alert(d,ctx,trip):
    alerts = obj(d.get("alerts")).get(trip,[])
    return obj(alerts[0]) if type(alerts) == "list" and alerts else {}

def countdown(r,now,short = False):
    deadline=obj(r).get("leaveAt")
    if type(deadline) not in ["int","float"]:
        return "BY "+obj(r).get("leaveBy","--")
    seconds=deadline-now
    if seconds < 0:
        return "TOO LATE" if short else str(int((-seconds+59)//60))+" MIN LATE"
    if seconds < 60:
        return "LEAVE NOW"
    return ("IN " if short else "LEAVE IN ")+str(int(seconds//60))+"M"

def mini_sign(c,road):
    kind=road.get("kind","road")
    if kind in ["interstate","us","state"]:
        c.rect(11,0,34,13,fill=WHITE)
        if kind == "interstate":
            c.rect(12,1,33,3,fill="#D82D42")
            c.rect(12,4,33,12,fill="#0757BA")
        centered(c,road.get("number",""),12,5,22,"5x7",WHITE if kind == "interstate" else "black")
    else:
        c.rect(11,0,34,13,fill="#075539",outline=WHITE)
        c.line(17,7,28,7,WHITE)
        c.line(25,4,28,7,WHITE)
        c.line(25,10,28,7,WHITE)

def small_coffee(c,branded):
    if branded:
        c.image("assets/starbucks.png",10,16,w=16,h=16)
    c.line(31,16,31,23,"#00A862")
    c.line(31,16,35,16,"#00A862")
    c.rect(28,21,36,23,fill="#DCEFF2")
    c.rect(29,24,35,29,fill="#B57D4C",outline="#DCEFF2")
    c.rect(30,24,31,25,fill=WHITE)
    c.rect(33,25,34,26,fill=WHITE)

def impact(alert):
    detail=clean(alert.get("detail",""))
    for text in ["RIGHT LANE BLOCKED","LEFT LANE BLOCKED","RIGHT LANE CLOSED","LEFT LANE CLOSED","ALL LANES CLOSED","LANE RESTRICTIONS"]:
        if text in detail:
            return text.replace("RIGHT","R").replace("LEFT","L")
    if alert.get("kind") == "slowdown":
        return "SUDDEN SLOWDOWN"
    if alert.get("kind") == "delay":
        return detail.split("/")[0].replace(" SEGMENT","")
    return alert.get("title","ROAD REPORT")

def draw_departure(c,ctx,d):
    which="stop" if ctx.inputs.get("trip","Direct") == "Stopover" else "direct"
    r=obj(d.get(which))
    if not valid_route(r):
        r=d["direct"]
        which="direct"
    c.fill("black")
    mini_sign(c,obj(r.get("road")))
    headline=countdown(r,ctx.now.unix)
    late=obj(r).get("leaveAt",ctx.now.unix)<ctx.now.unix
    color=RED if late else AMBER if headline == "LEAVE NOW" else GREEN
    txt(c,headline,41,0,110,"7x12" if c.text_width(headline,"7x12") <= 110 else "5x7",color)
    # DEMO is compact and visibly separate from all departure information.
    if d.get("demo"):
        txt(c,"DEMO",155,0,26,color=AMBER)
    road=obj(r.get("road")).get("label","ROUTE")
    line=road+" "+str(r.get("minutes","--"))+"M"
    rec=obj(d.get("recommendation"))
    if which == "direct" and not d.get("comparisonPartial") and rec.get("kind") == "faster":
        full=line+" / "+str(rec.get("minutes"))+"M FASTER"
        if c.text_width(full,"5x7") <= 140:
            line=full
    txt(c,line,41,14,140,"5x7",WHITE)
    stop=obj(d.get("stop"))
    if d.get("stopEnabled"):
        small_coffee(c,"STARBUCKS" in clean(d.get("stopName","")))
        if which == "direct":
            footer=d.get("stopName","STOP")+": "+(countdown(stop,ctx.now.unix,True) if valid_route(stop) else "UNKNOWN")
            footer_color=RED if stop.get("leaveAt",ctx.now.unix)<ctx.now.unix else AMBER
        else:
            footer="DIRECT: "+countdown(d["direct"],ctx.now.unix,True)
            footer_color=GRAY
        txt(c,footer,41,25,140,"5x7",footer_color)
    else:
        weather_icon(c,obj(d.get("weather")).get("kind","unknown"),12,17)
        txt(c,"BY "+r.get("leaveBy","--")+" / ARR "+d.get("arriveBy","--"),41,25,140,"5x7",GRAY)
    alert=current_alert(d,ctx,which)
    if alert:
        c.rect(41,13,181,21,fill="black")
        hazard(c,42,14,alert_hazard(alert))
        txt(c,"NEAR: "+impact(alert) if alert.get("source") == "OHGO" or alert.get("kind") in ["incident","construction","closure","slowdown","delay"] else impact(alert),54,14,127,"5x7",hazard_color(alert_hazard(alert)))
    # A tiny weather glyph is secondary; no feed error takes over this screen.
    if d.get("stopEnabled"):
        kind=obj(d.get("weather")).get("kind","unknown")
        if kind != "unknown":
            # Only use spare room on the hero row, never over the countdown.
            if not d.get("demo"):
                weather_icon(c,kind,169,0)
            elif c.text_width(line,"5x7") <= 125 and c.text_width(footer,"5x7") <= 125 and not alert:
                weather_icon(c,kind,169,18)

def draw_routes(c,ctx,d):
    c.fill("black")
    r=d["direct"]
    rec=obj(d.get("recommendation"))
    label="COMPARISON PARTIAL" if d.get("comparisonPartial") else (str(rec.get("minutes"))+" MIN FASTER" if rec.get("kind") == "faster" else "SIMILAR TRAVEL TIMES" if rec.get("kind") == "similar" else "RECOMMENDED ROUTE")
    txt(c,label,11,0,140 if d.get("demo") else 170,"5x7",GREEN)
    if d.get("demo"):
        txt(c,"DEMO",155,0,26,color=AMBER)
    txt(c,r["road"]["label"]+" "+str(r["minutes"])+"M",11,12,170,"5x7",WHITE)
    alternatives=d.get("alternatives",[])
    other=obj(alternatives[0]) if alternatives else {}
    txt(c,"ALT "+obj(other.get("road")).get("label","")+" "+str(other.get("minutes",""))+"M" if other else "NO ALTERNATE RETURNED",11,24,170,"5x7",GRAY)

def draw_conditions(c,ctx,d):
    which="stop" if ctx.inputs.get("trip","Direct") == "Stopover" else "direct"
    alert=current_alert(d,ctx,which)
    c.fill("black")
    if alert:
        color=RED if alert.get("kind") in ["weather","snowlevel"] and alert.get("severity") in ["Extreme","Severe"] else AMBER
        txt(c,("NEAR " if alert.get("source") == "OHGO" or alert.get("kind") in ["incident","construction","closure","slowdown","delay"] else "")+(alert.get("road") or alert.get("scope","ROUTE AREA")),11,0,140 if d.get("demo") else 170,"5x7",GRAY)
        hazard(c,11,12,alert_hazard(alert))
        txt(c,impact(alert),23,12,158,"5x7",hazard_color(alert_hazard(alert)))
        detail=alert.get("location") or alert.get("detail","CHECK ADVISORY")
        if clean(detail).replace("RIGHT","R").replace("LEFT","L") == impact(alert):
            detail=alert.get("title","ROAD REPORT")
        txt(c,detail,11,24,170,"5x7",WHITE)
    else:
        weather=obj(d.get("weather"))
        weather_icon(c,weather.get("kind","unknown"),12,5)
        txt(c,weather.get("description","WEATHER UNKNOWN"),31,0,120 if d.get("demo") else 150,"5x7",WHITE)
        temp=weather.get("temperatureF")
        txt(c,(str(temp)+"F / " if temp != None else "")+"NEAR START",31,12,150,"5x7",GRAY)
        sources=obj(d.get("sources"))
        missing=[name for key,name in [["weatherAlerts","WX ALERTS"],["roads","ROAD FEED"]] if obj(sources.get(key)).get("state") not in ["ok","disabled"]]
        txt(c,missing[0]+" UNKNOWN" if missing else "NO REPORTED ALERTS",11,24,170,"5x7",GRAY)
    if d.get("demo"):
        txt(c,"DEMO",155,0,26,color=AMBER)

def main(c,ctx):
    d=get_data(c,ctx)
    if d == None:
        return
    mode=ctx.inputs.get("viewmode","Departure")
    if mode == "Routes":
        draw_routes(c,ctx,d)
    elif mode == "Conditions":
        draw_conditions(c,ctx,d)
    else:
        draw_departure(c,ctx,d)

def weather_art(c,kind):
    c.rect(10,0,37,31,fill="#091A29")
    if kind in ["sun","partly"]:
        c.fill_circle(23,12,7,"#EBA62B")
        c.fill_circle(22,11,5,"#FFE573")
        for a,b,x,y in [[23,1,23,3],[23,21,23,23],[12,12,14,12],[32,12,34,12],[15,4,17,6],[29,18,31,20],[15,20,17,18],[29,6,31,4]]:
            c.line(a,b,x,y,"#FFD14B")
    if kind in ["cloud","partly","rain","snow","storm"]:
        c.fill_circle(21,10,6,"#829FBD")
        c.fill_circle(28,13,6,"#829FBD")
        c.rect(14,12,33,16,fill="#829FBD")
        c.fill_circle(20,8,5,"#E0F0FF")
        c.fill_circle(27,11,5,"#C1D9EE")
        c.rect(14,11,32,14,fill="#C1D9EE")
    if kind == "rain":
        for x in [17,24,31]:
            c.line(x,18,x-2,22,BLUE)
            c.pixel(x-2,23,"#A5DDFF")
    elif kind == "snow":
        for x,y in [[17,20],[29,21]]:
            c.line(x-2,y,x+2,y,"#CFF5FF")
            c.line(x,y-2,x,y+2,"#CFF5FF")
            c.pixel(x-1,y-1,WHITE)
            c.pixel(x+1,y+1,WHITE)
    elif kind == "storm":
        c.line(24,16,20,21,AMBER)
        c.line(20,21,25,20,AMBER)
        c.line(25,20,22,25,AMBER)
    elif kind == "fog":
        for y,left,right in [[6,14,30],[11,12,34],[16,15,33],[21,12,29]]:
            c.line(left,y,right,y,"#A9C6DA")
            c.line(left+2,y+1,right-2,y+1,"#5A7D96")
    elif kind == "moon":
        c.fill_circle(23,12,9,"#DCE9FF")
        c.fill_circle(28,8,8,"#091A29")
        c.pixel(14,4,WHITE)
        c.pixel(32,21,WHITE)
    elif kind == "unknown":
        centered(c,"?",11,5,25,"10x16",GRAY)

def routeweather(c,ctx):
    d=get_data(c,ctx,True)
    if d == None:
        return
    which="stop" if ctx.inputs.get("trip","Direct") == "Stopover" else "direct"
    w=obj(obj(d.get("routeWeather")).get(which))
    c.fill("black")
    weather_art(c,w.get("kind","unknown"))
    badge="DEMO" if d.get("demo") else str(max(0,int((ctx.now.unix-w["observedAt"])//60)))+"M" if w.get("observedAt") != None else "--"
    centered(c,badge,11,27,26,color=AMBER if d.get("demo") else GRAY)
    txt(c,"TEMP ALONG ROUTE",43,0,80,color=BLUE)
    txt(c,"VISIBILITY",131,0,50,color=BLUE)
    c.line(124,7,124,21,"#263D51")
    if w.get("state","unavailable") == "unavailable":
        c.rect(41,0,181,31,fill="black")
        txt(c,"ROUTE WEATHER",43,0,138,"5x7",BLUE)
        txt(c,"READINGS UNAVAILABLE",43,12,138,"5x7",GRAY)
        txt(c,"NO FRESH ROUTE OBS",43,25,138,"4x5",GRAY)
        return
    lo=w.get("temperatureLowF")
    hi=w.get("temperatureHighF")
    temp="--" if lo == None else str(lo)+("-"+str(hi) if hi != lo else "")
    v=w.get("visibilityMiles")
    visibility="--" if v == None else str(int(v)) if v == int(v) else str(int(v*10)/10) if v >= 1 else str(int(v*100)/100)
    tempfont="10x16" if c.text_width(temp,"10x16") <= 65 else "7x12" if c.text_width(temp,"7x12") <= 65 else "5x7"
    txt(c,temp,43,7,65,tempfont,WHITE)
    # Panel fonts omit the degree glyph; draw a small raised ring explicitly.
    unit_x=43+c.text_width(temp,tempfont)+2
    c.rect(unit_x,8,unit_x+3,11,outline=WHITE)
    c.text("F",unit_x+6,9,font="5x7",color=WHITE)
    vis_level=w.get("visibilityHazard","none") if v != None else "none"
    vis_x=140 if vis_level != "none" else 131
    vis_width=181-vis_x-10
    vis_font="10x16" if c.text_width(visibility,"10x16") <= vis_width else "7x12" if c.text_width(visibility,"7x12") <= vis_width else "5x7"
    if vis_level != "none":
        hazard(c,128,12,vis_level)
    vis_color=hazard_color(vis_level) if vis_level != "none" else WHITE if v != None else GRAY
    txt(c,visibility,vis_x,7,vis_width,vis_font,vis_color)
    txt(c,"MI",vis_x+c.text_width(visibility,vis_font)+2,16,9,"4x5",vis_color)
    road=obj(w.get("road"))
    if road:
        value=road.get("temperatureF")
        c.rect(41,24,181,31,fill="#332614")
        level=road.get("hazard","none")
        hazard(c,43,25,level)
        x=55 if level != "none" else 43
        txt(c,"PAVEMENT: "+(str(int(value))+"F " if value != None else "--F ")+road.get("status","UNKNOWN"),x,25,181-x,"5x7",hazard_color(level))
        # The weather condition remains separately marked beside its illustration
        # when the pavement strip occupies the text footer.
        if w.get("conditionHazard","none") != "none":
            c.rect(28,0,37,7,fill="#091A29")
            hazard(c,28,0,w.get("conditionHazard"))
    else:
        text=w.get("description","CONDITIONS UNKNOWN")
        if w.get("ohgoState") not in ["ok","disabled"]:
            text+=" / RWIS N/A"
        c.rect(41,24,181,31,fill="#102737")
        level=w.get("conditionHazard","none")
        hazard(c,43,25,level)
        x=55 if level != "none" else 43
        txt(c,text,x,25,181-x,"5x7",hazard_color(level) if level != "none" else WHITE if w.get("ohgoState") in ["ok","disabled"] else GRAY)
