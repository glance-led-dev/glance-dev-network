# Background is the team's main color; WIN flips to black on the light ones.
# Columbus and Vancouver sit on red/green because their logos vanish on navy.
TEAMS = {
    "Anaheim Ducks": {"logo": "assets/ana.png", "w": 34, "h": 30, "bg": "#F47A38", "win": "#000000"},
    "Boston Bruins": {"logo": "assets/bos.png", "w": 30, "h": 30, "bg": "#FFB81C", "win": "#000000"},
    "Buffalo Sabres": {"logo": "assets/buf.png", "w": 30, "h": 30, "bg": "#003087", "win": "#FFFFFF"},
    "Calgary Flames": {"logo": "assets/cgy.png", "w": 35, "h": 30, "bg": "#C8102E", "win": "#FFFFFF"},
    "Carolina Hurricanes": {"logo": "assets/car.png", "w": 36, "h": 22, "bg": "#CC0000", "win": "#FFFFFF"},
    "Chicago Blackhawks": {"logo": "assets/chi.png", "w": 34, "h": 30, "bg": "#CF0A2C", "win": "#FFFFFF"},
    "Colorado Avalanche": {"logo": "assets/col.png", "w": 36, "h": 30, "bg": "#6F263D", "win": "#FFFFFF"},
    "Columbus Blue Jackets": {"logo": "assets/cbj.png", "w": 34, "h": 30, "bg": "#CE1126", "win": "#FFFFFF"},
    "Dallas Stars": {"logo": "assets/dal.png", "w": 36, "h": 30, "bg": "#006847", "win": "#FFFFFF"},
    "Detroit Red Wings": {"logo": "assets/det.png", "w": 36, "h": 27, "bg": "#CE1126", "win": "#FFFFFF"},
    "Edmonton Oilers": {"logo": "assets/edm.png", "w": 30, "h": 30, "bg": "#041E42", "win": "#FF4C00"},
    "Florida Panthers": {"logo": "assets/fla.png", "w": 27, "h": 30, "bg": "#C8102E", "win": "#FFFFFF"},
    "Los Angeles Kings": {"logo": "assets/la.png", "w": 36, "h": 23, "bg": "#111111", "win": "#FFFFFF"},
    "Minnesota Wild": {"logo": "assets/min.png", "w": 36, "h": 23, "bg": "#154734", "win": "#FFFFFF"},
    "Montreal Canadiens": {"logo": "assets/mtl.png", "w": 36, "h": 25, "bg": "#AF1E2D", "win": "#FFFFFF"},
    "Nashville Predators": {"logo": "assets/nsh.png", "w": 36, "h": 21, "bg": "#FFB81C", "win": "#000000"},
    "New Jersey Devils": {"logo": "assets/nj.png", "w": 29, "h": 30, "bg": "#CE1126", "win": "#FFFFFF"},
    "New York Islanders": {"logo": "assets/nyi.png", "w": 31, "h": 30, "bg": "#00539B", "win": "#FFFFFF"},
    "New York Rangers": {"logo": "assets/nyr.png", "w": 31, "h": 30, "bg": "#0038A8", "win": "#FFFFFF"},
    "Ottawa Senators": {"logo": "assets/ott.png", "w": 36, "h": 29, "bg": "#C52032", "win": "#FFFFFF"},
    "Philadelphia Flyers": {"logo": "assets/phi.png", "w": 36, "h": 25, "bg": "#F74902", "win": "#000000"},
    "Pittsburgh Penguins": {"logo": "assets/pit.png", "w": 31, "h": 30, "bg": "#FCB514", "win": "#000000"},
    "San Jose Sharks": {"logo": "assets/sj.png", "w": 36, "h": 30, "bg": "#006D75", "win": "#FFFFFF"},
    "Seattle Kraken": {"logo": "assets/sea.png", "w": 24, "h": 30, "bg": "#001628", "win": "#99D9D9"},
    "St. Louis Blues": {"logo": "assets/stl.png", "w": 36, "h": 28, "bg": "#002F87", "win": "#FFFFFF"},
    "Tampa Bay Lightning": {"logo": "assets/tb.png", "w": 32, "h": 30, "bg": "#002868", "win": "#FFFFFF"},
    "Toronto Maple Leafs": {"logo": "assets/tor.png", "w": 27, "h": 30, "bg": "#00205B", "win": "#FFFFFF"},
    "Utah Mammoth": {"logo": "assets/utah.png", "w": 36, "h": 27, "bg": "#6CACE4", "win": "#000000"},
    "Vancouver Canucks": {"logo": "assets/van.png", "w": 31, "h": 30, "bg": "#00843D", "win": "#FFFFFF"},
    "Vegas Golden Knights": {"logo": "assets/vgk.png", "w": 22, "h": 30, "bg": "#B4975A", "win": "#000000"},
    "Washington Capitals": {"logo": "assets/wsh.png", "w": 36, "h": 29, "bg": "#C8102E", "win": "#FFFFFF"},
    "Winnipeg Jets": {"logo": "assets/wpg.png", "w": 30, "h": 30, "bg": "#041E42", "win": "#FFFFFF"},
}

DEFAULT = "Chicago Blackhawks"

# Five logos and four WINs on an 87px beat, like the original Blackhawks banner.
LOGO_X = [18, 105, 192, 279, 366]
WIN_X = [62, 149, 236, 323]

def main(c, ctx):
    t = TEAMS.get(ctx.inputs.get("team", DEFAULT), TEAMS[DEFAULT])
    c.fill(t["bg"])
    for cx in LOGO_X:
        c.image(t["logo"], cx - t["w"] // 2, (32 - t["h"]) // 2)
    for cx in WIN_X:
        c.text("WIN", cx, 4, font = "16x24_bold", color = t["win"], align = "center")
