# Word color and top-line color per team are lifted from team colors so dark
# navies still read on an LED panel.
TEAMS = {
    "Anaheim Ducks": {"logo": "assets/ana.png", "w": 34, "h": 30, "word": "DUCKS", "color": "#F47A38", "top": "#B9975B"},
    "Boston Bruins": {"logo": "assets/bos.png", "w": 30, "h": 30, "word": "BRUINS", "color": "#FFB81C", "top": "#FFFFFF"},
    "Buffalo Sabres": {"logo": "assets/buf.png", "w": 30, "h": 30, "word": "SABRES", "color": "#FFB81C", "top": "#3B7BE0"},
    "Calgary Flames": {"logo": "assets/cgy.png", "w": 35, "h": 30, "word": "FLAMES", "color": "#E8202E", "top": "#F1BE48"},
    "Carolina Hurricanes": {"logo": "assets/car.png", "w": 36, "h": 22, "word": "CANES", "color": "#E8173A", "top": "#FFFFFF"},
    "Chicago Blackhawks": {"logo": "assets/chi.png", "alt": "assets/chi_feather.png", "w": 34, "h": 30, "word": "HAWKS", "color": "#CF0A2C", "top": "#FFFFFF"},
    "Colorado Avalanche": {"logo": "assets/col.png", "w": 36, "h": 30, "word": "AVS", "color": "#C8284A", "top": "#6F9FD8"},
    "Columbus Blue Jackets": {"logo": "assets/cbj.png", "w": 34, "h": 30, "word": "JACKETS", "color": "#E41A2F", "top": "#3C6EC8"},
    "Dallas Stars": {"logo": "assets/dal.png", "w": 36, "h": 30, "word": "STARS", "color": "#00A651", "top": "#C0C6C9"},
    "Detroit Red Wings": {"logo": "assets/det.png", "w": 36, "h": 27, "word": "WINGS", "color": "#E41A2F", "top": "#FFFFFF"},
    "Edmonton Oilers": {"logo": "assets/edm.png", "w": 30, "h": 30, "word": "OILERS", "color": "#FF4C00", "top": "#3C6FD0"},
    "Florida Panthers": {"logo": "assets/fla.png", "w": 27, "h": 30, "word": "PANTHERS", "color": "#E41A2F", "top": "#C8A86B"},
    "Los Angeles Kings": {"logo": "assets/la.png", "w": 36, "h": 23, "word": "KINGS", "color": "#C0C6C9", "top": "#FFFFFF"},
    "Minnesota Wild": {"logo": "assets/min.png", "w": 36, "h": 23, "word": "WILD", "color": "#1F9A55", "top": "#EAAA00"},
    "Montreal Canadiens": {"logo": "assets/mtl.png", "w": 36, "h": 25, "word": "HABS", "color": "#E0243E", "top": "#3C6FD0"},
    "Nashville Predators": {"logo": "assets/nsh.png", "w": 36, "h": 21, "word": "PREDS", "color": "#FFB81C", "top": "#FFFFFF"},
    "New Jersey Devils": {"logo": "assets/nj.png", "w": 29, "h": 30, "word": "DEVILS", "color": "#E41A2F", "top": "#FFFFFF"},
    "New York Islanders": {"logo": "assets/nyi.png", "w": 31, "h": 30, "word": "ISLES", "color": "#F47D30", "top": "#3C7BD0"},
    "New York Rangers": {"logo": "assets/nyr.png", "w": 31, "h": 30, "word": "RANGERS", "color": "#3C6FE0", "top": "#E41A2F"},
    "Ottawa Senators": {"logo": "assets/ott.png", "w": 36, "h": 29, "word": "SENS", "color": "#E4002B", "top": "#C8A040"},
    "Philadelphia Flyers": {"logo": "assets/phi.png", "w": 36, "h": 25, "word": "FLYERS", "color": "#F74902", "top": "#FFFFFF"},
    "Pittsburgh Penguins": {"logo": "assets/pit.png", "w": 31, "h": 30, "word": "PENS", "color": "#FCB514", "top": "#FFFFFF"},
    "San Jose Sharks": {"logo": "assets/sj.png", "w": 36, "h": 30, "word": "SHARKS", "color": "#00A3B2", "top": "#EA7200"},
    "Seattle Kraken": {"logo": "assets/sea.png", "w": 24, "h": 30, "word": "KRAKEN", "color": "#99D9D9", "top": "#68A2B9"},
    "St. Louis Blues": {"logo": "assets/stl.png", "w": 36, "h": 28, "word": "BLUES", "color": "#3C6FE0", "top": "#FCB514"},
    "Tampa Bay Lightning": {"logo": "assets/tb.png", "w": 32, "h": 30, "word": "BOLTS", "color": "#3C6FE0", "top": "#FFFFFF"},
    "Toronto Maple Leafs": {"logo": "assets/tor.png", "w": 27, "h": 30, "word": "LEAFS", "color": "#3C6FE0", "top": "#FFFFFF"},
    "Utah Mammoth": {"logo": "assets/utah.png", "w": 36, "h": 27, "word": "MAMMOTH", "color": "#6CACE4", "top": "#FFFFFF"},
    "Vancouver Canucks": {"logo": "assets/van.png", "w": 31, "h": 30, "word": "CANUCKS", "color": "#3C6FE0", "top": "#00A651"},
    "Vegas Golden Knights": {"logo": "assets/vgk.png", "w": 22, "h": 30, "word": "KNIGHTS", "color": "#C8A86B", "top": "#FFFFFF"},
    "Washington Capitals": {"logo": "assets/wsh.png", "w": 36, "h": 23, "word": "CAPS", "color": "#E41A2F", "top": "#3C6FD0"},
    "Winnipeg Jets": {"logo": "assets/wpg.png", "w": 30, "h": 30, "word": "JETS", "color": "#3C7BD0", "top": "#FFFFFF"},
}

DEFAULT = "Chicago Blackhawks"
LOGO_W = 36

def main(c, ctx):
    t = TEAMS.get(ctx.inputs.get("team", DEFAULT), TEAMS[DEFAULT])
    c.fill("black")

    # Logos centered in a 36px slot at each edge of the 10..181 safe zone.
    left = 10 + (LOGO_W - t["w"]) // 2
    c.image(t["logo"], left, (32 - t["h"]) // 2)
    if "alt" in t:
        c.image(t["alt"], 181 - 26 + 1, 0)
    else:
        c.image(t["logo"], 181 - LOGO_W + 1 + (LOGO_W - t["w"]) // 2, (32 - t["h"]) // 2)

    cx = 96
    word = t["word"]
    if len(word) <= 5:
        top_y, word_y, font = 2, 11, "16x20_bold"
    else:
        top_y, word_y, font = 4, 14, "10x16_bold"

    # No font has an apostrophe, so it's drawn as two pixels.
    x = cx - 23
    c.text("LET", x, top_y, font = "5x7b", color = t["top"])
    c.pixel(x + 20, top_y, t["top"])
    c.pixel(x + 20, top_y + 1, t["top"])
    c.text("S GO", x + 22, top_y, font = "5x7b", color = t["top"])
    c.text(word, cx, word_y, font = font, color = t["color"], align = "center")
