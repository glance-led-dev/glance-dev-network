# Bird Sightings
#
# eBird's notable-observations feed, which lists the unusual birds
# other birders have reported in your region — not the everyday
# ones, the ones worth going to look at.
#
# The token goes in an X-eBirdApiToken header rather than a query
# parameter, which is easy to get wrong.



NODATA_FONTS = ["10x16", "6x8", "5x7", "4x5"]


def _fit_clip(c, text, fonts, maxw):
    """[font, text] for the largest font that fits, clipping if none do.

    text_fit alone was not enough here: when even its smallest option
    overflows it still draws, which ran these messages off a 64 panel."""
    pick = fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            pick = f
            break
    t = text
    if c.text_width(t, pick) > maxw:
        for k in range(len(t), 0, -1):
            if c.text_width(t[:k], pick) <= maxw:
                t = t[:k]
                break
    return [pick, t]


def nodata(c, title, sub):
    """Shown whenever a feed is unreachable or a key is missing.

    Every network app needs one: the publish-time validator renders each page
    with the network disabled, and a panel on a wall must say something
    sensible rather than going blank.

    The two lines get explicit, non-overlapping bands — a 16px title centred
    on the panel ran straight through the line beneath it.
    Wide:   4-19 title | 22-28 detail
    Narrow: 5-12 title | 18-22 detail
    """
    c.fill("#0B0C12")
    maxw = c.width - 6
    if c.width >= 128:
        t = _fit_clip(c, title, NODATA_FONTS, maxw)
        c.text(t[1], c.width // 2, 4, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["5x7", "4x5"], maxw)
        c.text(d[1], c.width // 2, 22, font = d[0], color = "#6A7090",
               align = "center")
    else:
        t = _fit_clip(c, title, ["6x8", "5x7", "4x5"], maxw)
        c.text(t[1], c.width // 2, 5, font = t[0], color = "#E8B04A",
               align = "center")
        d = _fit_clip(c, sub, ["4x5"], maxw)
        c.text(d[1], c.width // 2, 18, font = d[0], color = "#6A7090",
               align = "center")


def clip(c, text, font, maxw):
    """Longest prefix of `text` that fits maxw in `font`.

    text_fit shrinks the font instead, and when even its smallest option
    overflows it still draws — which is how a station name ended up running
    straight through the readout beside it."""
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


def fitwords(c, text, font, maxw):
    """Longest run of WHOLE words that fits maxw.

    clip() cuts at the pixel and leaves things like "SCHOOL PI" or
    "PAINTED B", which read as a rendering fault rather than an
    abbreviation. This stops at a word boundary instead, and only falls back
    to a hard cut when a single word cannot fit on its own."""
    t = str(text).strip()
    if c.text_width(t, font) <= maxw:
        return t
    parts = t.split(" ")
    out = ""
    for w in parts:
        trial = w if out == "" else out + " " + w
        if c.text_width(trial, font) > maxw:
            break
        out = trial
    if out != "":
        return out
    for k in range(len(t), 0, -1):
        if c.text_width(t[:k], font) <= maxw:
            return t[:k]
    return ""


DEMO = "DEMO"


REGIONS = {
    "ALABAMA": "US-AL",
    "ALASKA": "US-AK",
    "ARIZONA": "US-AZ",
    "ARKANSAS": "US-AR",
    "CALIFORNIA": "US-CA",
    "COLORADO": "US-CO",
    "CONNECTICUT": "US-CT",
    "DELAWARE": "US-DE",
    "DISTRICT OF COLUMBIA": "US-DC",
    "FLORIDA": "US-FL",
    "GEORGIA": "US-GA",
    "HAWAII": "US-HI",
    "IDAHO": "US-ID",
    "ILLINOIS": "US-IL",
    "INDIANA": "US-IN",
    "IOWA": "US-IA",
    "KANSAS": "US-KS",
    "KENTUCKY": "US-KY",
    "LOUISIANA": "US-LA",
    "MAINE": "US-ME",
    "MARYLAND": "US-MD",
    "MASSACHUSETTS": "US-MA",
    "MICHIGAN": "US-MI",
    "MINNESOTA": "US-MN",
    "MISSISSIPPI": "US-MS",
    "MISSOURI": "US-MO",
    "MONTANA": "US-MT",
    "NEBRASKA": "US-NE",
    "NEVADA": "US-NV",
    "NEW HAMPSHIRE": "US-NH",
    "NEW JERSEY": "US-NJ",
    "NEW MEXICO": "US-NM",
    "NEW YORK": "US-NY",
    "NORTH CAROLINA": "US-NC",
    "NORTH DAKOTA": "US-ND",
    "OHIO": "US-OH",
    "OKLAHOMA": "US-OK",
    "OREGON": "US-OR",
    "PENNSYLVANIA": "US-PA",
    "RHODE ISLAND": "US-RI",
    "SOUTH CAROLINA": "US-SC",
    "SOUTH DAKOTA": "US-SD",
    "TENNESSEE": "US-TN",
    "TEXAS": "US-TX",
    "UTAH": "US-UT",
    "VERMONT": "US-VT",
    "VIRGINIA": "US-VA",
    "WASHINGTON": "US-WA",
    "WEST VIRGINIA": "US-WV",
    "WISCONSIN": "US-WI",
    "WYOMING": "US-WY",
    "PUERTO RICO": "US-PR",
    "US VIRGIN ISLANDS": "US-VI",
}


def resolve_region(ctx):
    """eBird region code for the picked state.

    The setting used to be the code itself -- "US-NY", or a county code like
    "US-CA-037" -- which you had to go and look up. The dropdown carries state
    names and this maps them back.

    A county code typed under the old free-text field is not a known name, so
    it falls through unchanged and still works.
    """
    v = str(ctx.inputs.get("region", "")).strip().upper()
    if v in REGIONS:
        return REGIONS[v]
    return v


def is_demo(ctx):
    """True when the key is the literal DEMO opt-in.

    Catalog previews are rendered with this so they show the real layout
    carrying representative values. A panel with no key configured still gets
    the plain error screen — this never fires by accident."""
    return str(ctx.inputs.get("apikey", "")).strip().upper() == DEMO


def demo_badge(c):
    """A single corner marker. A SAMPLE word across the top-right covered real
    content in half these apps, which defeats the point of the preview."""
    c.rect(c.width - 5, c.height - 5, c.width - 1, c.height - 1,
           fill = "#3A3F52")
    c.text("S", c.width - 2, c.height - 5, font = "3x4", color = "#D8DEF0",
           align = "right")


EBIRD_SAMPLE = {"status_code": 200, "json": [
    {"comName": "Painted Bunting", "locName": "Prospect Park", "howMany": 1},
    {"comName": "Snowy Owl", "locName": "Jones Beach", "howMany": 2},
    {"comName": "Roseate Spoonbill", "locName": "Jamaica Bay", "howMany": 1}]}


def sightings(c, ctx):
    token = str(ctx.inputs.get("apikey", "")).strip()
    region = resolve_region(ctx)
    if not is_demo(ctx) and (token == "" or region == ""):
        nodata(c, "NOT CONFIGURED", "SET TOKEN")
        return

    r = EBIRD_SAMPLE if is_demo(ctx) else http.get(
        "https://api.ebird.org/v2/data/obs/" + region + "/recent/notable",
        params = {"maxResults": "5"},
        headers = {"X-eBirdApiToken": token}, ttl_seconds = 3600)
    if r["status_code"] == 403 or r["status_code"] == 401:
        nodata(c, "BAD TOKEN", "CHECK TOKEN")
        return
    if r["status_code"] != 200 or r["json"] == None:
        nodata(c, "NO SIGHTINGS", "NO CONNECTION")
        return

    rows = r["json"]
    if len(rows) == 0:
        c.fill("#07120A")
        c.text("NOTHING NOTABLE", c.width // 2, c.height // 2 - 4,
               font = "6x8" if c.width >= 128 else "4x5", color = "#4E8E68",
               align = "center")
        return

    # Black ground per the design guidelines: full-bleed gradients merge into
    # the neighboring apps in the scroll, and black is the cheapest contrast.
    c.fill("black")
    sz = 24 if c.width >= 128 else 16
    c.image("BIRD.png", 1, (c.height - sz) // 2, w = sz, h = sz)

    show = 3 if c.width >= 128 else 2
    if show > len(rows):
        show = len(rows)
    x0 = 28 if c.width >= 128 else 19
    lh = c.height // show

    for i in range(show):
        y = i * lh + (lh - 7) // 2
        name = str(rows[i].get("comName", "")).upper()
        if c.width >= 128:
            loc = str(rows[i].get("locName", "")).upper()
            shortloc = fitwords(c, loc, "4x5", 58)
            lw = c.text_width(shortloc, "4x5") + 8
            c.text(shortloc, c.width - 8, y + 1, font = "4x5",
                   color = "#6E9C7E", align = "right")
            c.text(fitwords(c, name, "5x7", c.width - x0 - lw - 6), x0, y,
                   font = "5x7", color = "#DCF0E0")
        else:
            c.text(fitwords(c, name, "4x5", c.width - x0 - 2), x0, y,
                   font = "4x5", color = "#DCF0E0")
    if is_demo(ctx):
        demo_badge(c)
