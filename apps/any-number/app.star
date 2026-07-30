# any-number: show one value from any public JSON API, big, on a 64x32 panel.
#
# Why this exists: the stock GLANCE app has a fixed catalogue. This app turns
# the panel into a display for ANY number a public API will hand you --
# a home sensor, a build queue depth, a fundraiser total, a subscriber count --
# without writing a new app each time. You configure it from the phone app.
#
# It is deliberately dumb: fetch JSON, walk a dot path, print what you find.

MAX_HOPS = 8  # Starlark has no while loop, so path depth is bounded.


def _s(ctx, key, fallback = ""):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()


def _dig(node, path):
    """Walk a dot path like 'bitcoin.usd' or 'results.0.temp' into parsed JSON.

    Returns (value, None) on success or (None, "reason") on failure. Keeping
    the failure as text means the panel can say WHY it is blank instead of
    just showing a dash, which is the difference between a bug and a hint.
    """
    parts = [p for p in path.split(".") if p != ""]
    if len(parts) == 0:
        return node, None
    if len(parts) > MAX_HOPS:
        return None, "PATH TOO DEEP"

    cur = node
    for part in parts:
        if type(cur) == "dict":
            if part not in cur:
                return None, "NO KEY " + part.upper()
            cur = cur[part]
        elif type(cur) == "list":
            # List hop must be a numeric index.
            if not part.isdigit():
                return None, "NEED INDEX"
            idx = int(part)
            if idx >= len(cur):
                return None, "INDEX " + part
            cur = cur[idx]
        else:
            return None, "DEAD END"
    return cur, None


def _tidy(v):
    """Render a JSON scalar the way a person would write it on a whiteboard."""
    t = type(v)
    if t == "bool":
        return "YES" if v else "NO"
    if t == "int":
        return fmt.commas(v)
    if t == "float":
        # Big numbers do not need cents; small ones do.
        av = math.abs(v)
        if av >= 1000:
            return fmt.commas(int(math.round(v)))
        if av >= 10:
            return str(int(math.round(v * 10)) / 10.0)
        return str(int(math.round(v * 100)) / 100.0)
    if t == "string":
        return v.upper()
    return "?"


def _fetch(ctx):
    url = _s(ctx, "url")
    if url == "":
        return None, "NO URL SET"
    if not url.startswith("http"):
        return None, "BAD URL"

    # ttl_seconds matches the manifest refresh so the panel and the cache agree.
    r = http.get(url, ttl_seconds = 300)

    status = r["status_code"]
    if status == 401 or status == 403:
        return None, "AUTH REQUIRED"
    if status == 404:
        return None, "404 NOT FOUND"
    if status == 429:
        return None, "RATE LIMITED"
    if status != 200:
        return None, "HTTP " + str(status)

    body = r["json"]
    if body == None:
        return None, "NOT JSON"

    return _dig(body, _s(ctx, "path"))


def _problem(c, label, why):
    c.fill("black")
    c.header(label, bg = "red", color = "black", font = "5x7")
    c.text_center(why, 14, font = "4x7", color = "red")
    # "CHECK SETTINGS" measures 67px at 4x5 and gets clipped on a 64px panel.
    # Always run the string through text_width before trusting it to fit.
    c.text_center("CHECK SETUP", 23, font = "4x5", color = "darkgray")


def main(c, ctx):
    label = _s(ctx, "label", "VALUE").upper()
    if label == "":
        label = "VALUE"

    value, why = _fetch(ctx)
    if why != None:
        _problem(c, label, why)
        return

    text = _s(ctx, "prefix") + _tidy(value) + _s(ctx, "suffix")

    c.fill("black")

    # A one-line header keeps the caption legible at 64px without stealing
    # room from the number, which is the part you read from across the room.
    c.header(label, bg = color.dim("green", 35), color = "white", font = "5x7")

    # text_fit steps down through fonts until the string clears the panel,
    # so a 4-digit price and a 7-digit one both stay centred and readable.
    #
    # Font ladder note: 10x14 is deliberately NOT in this list. That font has
    # no "." glyph, so a value like 74.3 silently renders as 743 -- a wrong
    # number, which is worse than a small one. Every font below is punctuation-
    # complete. Run `gdn fonts` and check coverage before adding to this list.
    # Gotcha: align="center" centres the string on the x you pass -- it does NOT
    # centre it inside maxw. Pass x=0 and short values pin to the left edge.
    # maxw only decides which font gets picked.
    c.text_fit(
        text,
        c.width // 2, 12,
        ["10x16", "8x12", "7x12", "5x7", "4x7"],
        color = _s(ctx, "tint", "green"),
        align = "center",
        maxw = c.width,
    )

    # A hairline under the number gives the layout a floor. Without it the
    # digits float and the panel reads as unfinished.
    c.hline(0, 30, c.width, color.dim("green", 20))
