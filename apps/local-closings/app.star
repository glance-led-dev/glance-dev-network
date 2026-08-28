# Local Closings — school / business / organization closings on a 192x32 panel.
#
# Family adapters (technology, not ownership). Not a universal HTML scraper:
#   Gray GSync JSON / NewsTicker XML  — Gray, Allen Media, and other GSync pages
#   TownNews / BLOX XML               — KOAM and other /app/closings/*.xml pages
#   Nexstar WP + PSG iframe           — KSN, Four States Homepage, similar WP sites
#   NBC O&O WordPress                 — NBCDFW and other nbc-station school-closings pages
#   Scripps Brightspot / FlashAlert   — KOAA module--closings; KATU FlashAlert iframe
#   WorldNow orgname HTML             — FOX O&O media.foxtv.com iframes; Sinclair ftptransfer
#   TEGNA closings module             — WFAA / KHOU / KARE closings__* HTML
#   Hearst closingsData               — KMBC / WISN / WCVB embedded payload
#   CBS News school-closings feed     — NewsTicker or BLOX XML from data-school-closings-options
#   Cox Arc closing-list              — WSB / WPXI / KIRO school-closings widget
#   Arc SchoolClosings widget         — 9&10 News weather-school-closings JSON
#
# Visible HTML tables are often empty until JS runs. Glance cannot run that JS,
# so each adapter follows the small public feed the page itself loads.
#
# Starlark has no HTML/XML module and no regex. Tags and JSON keys are read
# with string finds / dict.get. Frames are still images.

HEADERS = {
    "User-Agent": "GlanceLocalClosings/1.0 (GDN; closings display)",
    "Accept": "application/json, application/xml, text/xml, text/html;q=0.9, */*;q=0.8",
}

TTL = 300
WANT = 5
SCAN = 40
GSYNC_PATH = "/pf/api/v3/content/fetch/gsync-closings"
ARC_SCHOOL_PATH = "/pf/api/v3/content/fetch/weather-school-closings"

BG = "#050814"
BG2 = "#243556"
TITLE = "#F4F7FF"
DIM = "#6E7A94"
MUTED = "#C2CCE4"
RED = "#FF3B3B"
AMBER = "#FFC43A"
GREEN = "#3EEB8A"
CYAN = "#5EE1FF"
FAIL = "#E8B04A"
INK = "#071018"

NAME_KEYS = [
    "name", "organization", "organizationName", "organization_name",
    "ORGANIZATION_NAME1", "orgName", "title", "forcedOrganizationName",
    "FORCED_ORGANIZATION_NAME", "organizationName1", "org", "Name1", "name1",
]
STATUS_KEYS = [
    "status", "completeStatus", "COMPLETE_STATUS", "statusName",
    "STATUS_NAME1", "statusText", "forcedStatusName", "FORCED_STATUS_NAME",
    "altStatusText", "ALT_STATUS_TEXT", "statusName1", "closingStatus",
    "notice",
]
DETAIL_KEYS = [
    "detail", "comments", "comment", "COMMENTS_LINE1", "description",
    "notes", "altStatusText", "commentsLine1",
]
ZIP_KEYS = ["zipcode", "zipCode", "ZIPCODE", "zip", "postalCode"]
TYPE_KEYS = [
    "type", "category", "CATEGORY_NAME1", "categoryName", "orgType", "EntityType",
    "entitytype",
]

ICON_WARN = """
...#...
..#.#..
..#.#..
.#...#.
.#.#.#.
#.....#
#######
"""

ICON_SCHOOL = """
..###..
.#####.
#.....#
#######
#.#.#.#
#.#.#.#
#######
"""

ICON_CHECK = """
........#
.......##
#.....##.
.#...##..
..#.##...
...##....
...#.....
.........
"""

ICON_X = """
#.......#
.#.....#.
..#...#..
...#.#...
....#....
...#.#...
..#...#..
.#.....#.
#.......#
"""

ICON_CLOCK = """
...###...
..#...#..
.#..#..#.
.#..##.#.
.#.....#.
..#...#..
...###...
.........
"""


def _s(ctx, key, fallback):
    v = ctx.inputs.get(key, fallback)
    if v == None:
        return fallback
    return str(v).strip()


def collapse_ws(s):
    t = str(s).replace("\n", " ").replace("\r", " ").replace("\t", " ")
    for _ in range(40):
        if t.find("  ") < 0:
            break
        t = t.replace("  ", " ")
    return t.strip()


def digits_only(s):
    out = ""
    t = str(s)
    for i in range(len(t)):
        if t[i].isdigit():
            out = out + t[i]
    return out


def zip_label(raw):
    d = digits_only(raw)
    if len(d) >= 5:
        return d[:5]
    return d


def decode(s):
    out = str(s)
    out = out.replace("<![CDATA[", "").replace("]]>", "")
    out = out.replace("&amp;", "&").replace("&#39;", "'").replace("&apos;", "'")
    out = out.replace("&quot;", "\"").replace("&lt;", "<").replace("&gt;", ">")
    out = out.replace("&nbsp;", " ").replace("&#039;", "'")
    return collapse_ws(out)


def strip_tags(s):
    out = ""
    i = 0
    n = len(s)
    for _ in range(n + 1):
        if i >= n:
            break
        lt = s.find("<", i)
        if lt < 0:
            out = out + s[i:]
            break
        out = out + s[i:lt]
        gt = s.find(">", lt)
        if gt < 0:
            break
        i = gt + 1
    return out


def xml_text(body, tag):
    close = "</" + tag + ">"
    open1 = "<" + tag + ">"
    start = body.find(open1)
    if start >= 0:
        start = start + len(open1)
    else:
        open2 = "<" + tag + " "
        p = body.find(open2)
        if p < 0:
            return ""
        gt = body.find(">", p)
        if gt < 0:
            return ""
        start = gt + 1
    end = body.find(close, start)
    if end < 0:
        return ""
    return decode(strip_tags(body[start:end]))


def origin_of(url):
    u = collapse_ws(url)
    if u == "":
        return ""
    scheme = "https"
    rest = u
    if u.find("://") >= 0:
        if u.find("http://") == 0:
            scheme = "http"
        rest = u[u.find("://") + 3:]
    slash = rest.find("/")
    host = rest if slash < 0 else rest[:slash]
    if host == "" or host.find(".") < 0:
        return ""
    return scheme + "://" + host


def host_label(url):
    origin = origin_of(url)
    if origin == "":
        return ""
    host = origin
    if host.find("://") >= 0:
        host = host[host.find("://") + 3:]
    if host.find("www.") == 0:
        host = host[4:]
    return host.upper()


def looks_like_gsync(html):
    h = str(html)
    if h.find("gsync-closings") >= 0:
        return True
    if h.find("GSync/ClosingsDetailed") >= 0:
        return True
    if h.find("gsync-closings-detailed") >= 0:
        return True
    return False


def looks_like_newsticker(html):
    h = str(html)
    if h.find("newsticker/closings") >= 0:
        return True
    if h.find("<NUM_CLOSINGS>") >= 0:
        return True
    if h.find("<RECORD>") >= 0 and h.find("ORGANIZATION_NAME") >= 0:
        return True
    return False


def newsticker_xml_from_html(html):
    h = str(html)
    key = "newsticker_url\":\""
    p = h.find(key)
    if p < 0:
        key = "newsticker_url\":\"'"
        p = h.find("webpubcontent.gray.tv/")
        if p < 0:
            return ""
        rest = h[p:]
        end = rest.find("\"")
        if end < 0:
            end = rest.find("'")
        if end < 0:
            return ""
        url = "https://" + rest[:end]
        url = url.replace(".html", ".xml")
        return url
    rest = h[p + len(key):]
    end = rest.find("\"")
    if end < 0:
        return ""
    url = rest[:end].replace("\\/", "/")
    if url.find(".html") >= 0:
        url = url.replace(".html", ".xml")
    return url


def last_slug(url):
    u = collapse_ws(url)
    q = u.find("?")
    if q >= 0:
        u = u[:q]
    for _ in range(8):
        if u == "" or u[len(u) - 1] != "/":
            break
        u = u[:len(u) - 1]
    slash = -1
    for i in range(len(u)):
        if u[i] == "/":
            slash = i
    if slash < 0:
        return ""
    return u[slash + 1:]


def looks_like_closings_url(url):
    u = str(url).upper()
    return u.find("CLOSING") >= 0


def looks_like_townnews(html):
    h = str(html)
    if h.find("/app/closings/") >= 0:
        return True
    if h.find("getElementsByTagName(\"Closing\")") >= 0:
        return True
    if h.find("getElementsByTagName('Closing')") >= 0:
        return True
    if h.find("townnews") >= 0 and h.find("closings") >= 0:
        return True
    if h.find("bloximages") >= 0 and h.find("closings") >= 0:
        return True
    return False


def looks_like_nexstar(html):
    h = str(html)
    if h.find("nexstardigital.net") >= 0:
        return True
    if h.find("closings-page") >= 0 or h.find("closingsPage") >= 0:
        return True
    if h.find("No closings to report") >= 0:
        return True
    if h.find("wp-json/lakana") >= 0:
        return True
    if h.find("wp-json/nexstar") >= 0:
        return True
    if h.find("data-component=\"closingsPage\"") >= 0:
        return True
    return False


def looks_like_nbc(html):
    h = str(html)
    if h.find("article-content--wrap closings") >= 0:
        return True
    if h.find("closings--inactive") >= 0 or h.find("closings--active") >= 0:
        return True
    if h.find("schoolClosingTabs") >= 0:
        return True
    if h.find("nbc-school-closings") >= 0:
        return True
    if h.find("school-closings-alert") >= 0:
        return True
    if h.find("closings__listings") >= 0:
        return True
    return False


def looks_like_scripps(html):
    h = str(html)
    if h.find("module--closings") >= 0:
        return True
    if h.find("There are currently no active closings or delays") >= 0:
        return True
    return False


def looks_like_flashalert(html):
    h = str(html)
    if h.find("cwcReportContainer") >= 0:
        return True
    if h.find("flashalertnewswire.net") >= 0:
        return True
    if h.find("No information reported") >= 0 and h.find("cwcReport") >= 0:
        return True
    return False


def is_boilerplate(text):
    u = collapse_ws(str(text)).upper()
    if u.find("NO CLOSINGS TO REPORT") >= 0:
        return True
    if u.find("MOST RECENT CLOSINGS") >= 0:
        return True
    if u.find("ACTIVE CLOSURES") >= 0:
        return True
    if u.find("JUMP TO") >= 0:
        return True
    if u == "CLOSINGS & DELAYS" or u == "CLOSINGS AND DELAYS":
        return True
    if u.find("SCHOOL'S OPEN") >= 0 or u.find("SCHOOLS OPEN") >= 0:
        return True
    if u.find("FORECAST: SCHOOL") >= 0:
        return True
    if u.find("NO ACTIVE CLOSINGS") >= 0:
        return True
    if u.find("NO INFORMATION REPORTED") >= 0:
        return True
    if u.find("NO DELAYS OR CLOSINGS") >= 0:
        return True
    if u.find("NO CLOSINGS OR DELAYS") >= 0:
        return True
    if u.find("THERE ARE NO ACTIVE RECORDS") >= 0:
        return True
    if u.find("NO CLOSINGS REPORTED") >= 0:
        return True
    if u.find("THERE ARE CURRENTLY NO CLOSINGS") >= 0:
        return True
    if u.find("NO RESULTS FOUND") >= 0:
        return True
    if u.find("NO ACTIVE RECORDS AT THIS TIME") >= 0:
        return True
    return False


def split_name_status(text):
    t = collapse_ws(text)
    seps = [" - ", " – ", ": ", " — "]
    for sep in seps:
        p = t.find(sep)
        if p > 0:
            return t[:p], t[p + len(sep):]
    return t, ""


def html_attr(tag, name):
    keys = [name + "=\"", name + "='"]
    for key in keys:
        p = tag.find(key)
        if p < 0:
            continue
        rest = tag[p + len(key):]
        quote = "\""
        if key[len(key) - 1] == "'":
            quote = "'"
        end = rest.find(quote)
        if end < 0:
            continue
        return rest[:end].replace("\\/", "/").replace("&amp;", "&")
    return ""


def nexstar_iframe_src(html):
    h = str(html)
    p = 0
    for _ in range(25):
        i = h.find("<iframe", p)
        if i < 0:
            i = h.find("<IFRAME", p)
        if i < 0:
            break
        gt = h.find(">", i)
        if gt < 0:
            break
        src = html_attr(h[i:gt], "src")
        p = gt + 1
        if src.find("nexstardigital.net") >= 0:
            return src
    k = h.find("https://media.psg.nexstardigital.net/")
    if k < 0:
        k = h.find("http://media.psg.nexstardigital.net/")
    if k < 0:
        return ""
    rest = h[k:]
    end = len(rest)
    for ch in ["\"", "'", " ", "<", ">"]:
        e = rest.find(ch)
        if e >= 0 and e < end:
            end = e
    return rest[:end]


def abs_url(src, page_url):
    s = collapse_ws(src)
    if s == "":
        return ""
    if s.find("://") >= 0:
        return s
    origin = origin_of(page_url)
    if s.find("/") == 0:
        return origin + s
    return origin + "/" + s


def townnews_xml_urls(html, origin):
    urls = []
    generic = origin + "/app/closings/closings.xml"
    rest = str(html)
    needle = "/app/closings/"
    for _ in range(16):
        p = rest.find(needle)
        if p < 0:
            break
        chunk = rest[p:]
        rest = rest[p + len(needle):]
        end = chunk.find(".xml")
        if end < 0:
            continue
        path = chunk[:end + 4]
        bad = False
        for ch in [" ", "\"", "'", "<", ">", "\n", "\r"]:
            if path.find(ch) >= 0:
                bad = True
        if bad:
            continue
        url = origin + path
        exists = False
        for prev in urls:
            if prev == url:
                exists = True
        if exists == False:
            urls.append(url)
    ordered = []
    for url in urls:
        if url != generic:
            ordered.append(url)
    for url in urls:
        if url == generic:
            ordered.append(url)
    return ordered


def extract_class_text(html, classname):
    out = []
    needles = [
        "class=\"" + classname + "\"",
        "class=\"" + classname + " ",
        "class='" + classname + "'",
        "class='" + classname + " ",
        "CLASS=\"" + classname + "\"",
        "CLASS=\"" + classname + " ",
        "CLASS='" + classname + "'",
        "CLASS='" + classname + " ",
    ]
    h = str(html)
    for needle in needles:
        rest = h
        for _ in range(40):
            if len(out) >= SCAN:
                return out
            p = rest.find(needle)
            if p < 0:
                break
            gt = rest.find(">", p)
            if gt < 0:
                break
            inner = rest[gt + 1:]
            end = inner.find("</")
            rest = rest[gt + 1:]
            if end < 0:
                continue
            text = decode(strip_tags(inner[:end]))
            if text == "" or is_boilerplate(text):
                continue
            exists = False
            for prev in out:
                if prev == text:
                    exists = True
            if exists == False:
                out.append(text)
    return out


def extract_tag_texts(html, tag):
    out = []
    rest = str(html)
    open1 = "<" + tag
    close = "</" + tag + ">"
    for _ in range(40):
        if len(out) >= SCAN:
            break
        p = rest.find(open1)
        if p < 0:
            break
        gt = rest.find(">", p)
        if gt < 0:
            break
        rest = rest[gt + 1:]
        end = rest.find(close)
        if end < 0:
            break
        text = decode(strip_tags(rest[:end]))
        rest = rest[end + len(close):]
        if text == "" or is_boilerplate(text):
            continue
        out.append(text)
    return out


def append_named_row(rows, name, status):
    if is_boilerplate(name):
        return
    u = collapse_ws(name).upper()
    if u == "SCHOOLS" or u == "BUSINESSES" or u == "CHURCHES":
        return
    if u == "GOVERNMENT" or u == "DAYCARES" or u == "ORGANIZATIONS" or u == "COLLEGES":
        return
    row = normalize_row({
        "name": name,
        "status": status,
    })
    if row != None:
        rows.append(row)


def parse_townnews_xml(body):
    raw = str(body)
    if raw.find("<File") < 0 and raw.find("<Closing") < 0:
        return None
    rows = []
    rest = raw
    for _ in range(40):
        if len(rows) >= SCAN:
            break
        a = rest.find("<Closing")
        if a < 0:
            break
        rest = rest[a + 8:]
        end = rest.find("</Closing>")
        if end < 0:
            break
        block = rest[:end]
        rest = rest[end + 10:]
        name = xml_text(block, "Name1")
        if name == "":
            name = xml_text(block, "Name")
        status = xml_text(block, "Status")
        if status == "":
            status = xml_text(block, "Status1")
        typ = xml_text(block, "EntityType")
        row = normalize_row({
            "name": name,
            "status": status,
            "type": typ,
        })
        if row != None:
            rows.append(row)
    if rows != []:
        return {"kind": "ok", "rows": rows}
    if raw.find("<File") >= 0:
        return {"kind": "empty", "rows": []}
    return {"kind": "unparseable", "rows": []}


def parse_nexstar_html(html):
    h = str(html)
    if h.find("No closings to report") >= 0:
        return {"kind": "empty", "rows": []}

    rows = []
    for text in extract_class_text(h, "closing_row"):
        name, status = split_name_status(text)
        append_named_row(rows, name, status)
        if len(rows) >= SCAN:
            break

    if rows == []:
        names = extract_class_text(h, "closings-list__name")
        stats = extract_class_text(h, "closings-list__status")
        for i in range(len(names)):
            status = ""
            if i < len(stats):
                status = stats[i]
            append_named_row(rows, names[i], status)
            if len(rows) >= SCAN:
                break

    if rows == []:
        p = h.find("closings-list")
        if p >= 0:
            section = h[p:]
            if len(section) > 20000:
                section = section[:20000]
            names = extract_tag_texts(section, "h3")
            details = extract_tag_texts(section, "p")
            for i in range(len(names)):
                status = ""
                if i < len(details):
                    status = details[i]
                append_named_row(rows, names[i], status)
                if len(rows) >= SCAN:
                    break

    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}

    if h.find("closings-page") >= 0 or h.find("closingsPage") >= 0:
        if h.find("Most recent closings and delays are listed here") >= 0:
            return {"kind": "empty", "rows": []}
        if h.find("closings-nav__item--empty") >= 0:
            return {"kind": "empty", "rows": []}
        return {"kind": "unparseable", "rows": []}

    if h.find("closing_header") >= 0 or h.find("KSN Weather Closings") >= 0:
        return {"kind": "unparseable", "rows": []}
    return None


def wp_rendered(data):
    page = None
    if type(data) == "list":
        if len(data) == 0:
            return ""
        page = data[0]
    elif type(data) == "dict":
        page = data
    else:
        return ""
    if type(page) != "dict":
        return ""
    content = page.get("content", None)
    if type(content) == "dict":
        rendered = content.get("rendered", "")
        if rendered == None:
            return ""
        return str(rendered)
    if type(content) == "string":
        return content
    return ""


def fetch_townnews(origin, html):
    urls = townnews_xml_urls(html, origin)
    if urls == []:
        parsed = parse_townnews_xml(html)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}
    xml_url = urls[0]
    x = http_get(xml_url)
    if x["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    parsed = parse_townnews_xml(x["body"])
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def fetch_nexstar_wp(url):
    origin = origin_of(url)
    slug = last_slug(url)
    if origin == "" or slug == "":
        return None
    api = origin + "/wp-json/wp/v2/pages?slug=" + slug
    g = http_get(api)
    if g["status_code"] != 200:
        return None
    html = wp_rendered(g["json"])
    if html == "":
        return None
    src = nexstar_iframe_src(html)
    if src != "":
        x = http_get(abs_url(src, url))
        if x["status_code"] == 200:
            parsed = parse_nexstar_html(x["body"])
            if parsed != None:
                return parsed
            return {"kind": "unparseable", "rows": []}
    parsed = parse_nexstar_html(html)
    if parsed != None:
        return parsed
    if looks_like_nexstar(html):
        return {"kind": "unparseable", "rows": []}
    return None


def fetch_nexstar(url, html):
    src = nexstar_iframe_src(html)
    if src != "":
        x = http_get(abs_url(src, url))
        if x["status_code"] == 200:
            parsed = parse_nexstar_html(x["body"])
            if parsed != None:
                return parsed
            return {"kind": "unparseable", "rows": []}
    parsed = parse_nexstar_html(html)
    if parsed != None:
        return parsed
    wp = fetch_nexstar_wp(url)
    if wp != None:
        return wp
    return {"kind": "unparseable", "rows": []}


def parse_nbc_json(data):
    if type(data) == "dict":
        if "sites" in data or "network_feature_flags" in data:
            return None
        for key in ["closings", "listings", "items", "data", "organizations", "results"]:
            if key in data:
                return parse_nbc_json(data[key])
        row = normalize_row(data)
        if row != None:
            return {"kind": "ok", "rows": [row]}
        return None
    if type(data) != "list":
        return None
    if len(data) == 0:
        return {"kind": "empty", "rows": []}
    rows = []
    for item in data:
        if type(item) != "dict":
            continue
        row = normalize_row(item)
        if row != None:
            rows.append(row)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows}
    return {"kind": "unparseable", "rows": []}


def parse_nbc_html(html):
    h = str(html)
    if h.find("closings--inactive") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    orgs = extract_class_text(h, "listing__org")
    notices = extract_class_text(h, "listing__notice")
    for i in range(len(orgs)):
        status = ""
        if i < len(notices):
            status = notices[i]
        append_named_row(rows, orgs[i], status)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("closings--active") >= 0:
        return None
    if h.find("closings__listings") >= 0:
        return {"kind": "empty", "rows": []}
    if h.find("article-content--wrap closings") >= 0:
        return {"kind": "empty", "rows": []}
    return None


def fetch_nbc_json(url):
    origin = origin_of(url)
    if origin == "":
        return None
    g = http_get(origin + "/wp-json/nbc/v1/school-closings")
    if g["status_code"] != 200:
        return None
    return parse_nbc_json(g["json"])


def fetch_nbc(url, html):
    parsed = parse_nbc_html(html)
    if parsed != None and parsed.get("kind") != "unparseable":
        return parsed
    jparsed = fetch_nbc_json(url)
    if jparsed != None:
        return jparsed
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def html_section(html, marker, maxn):
    p = str(html).find(marker)
    if p < 0:
        return ""
    rest = str(html)[p:]
    if len(rest) > maxn:
        return rest[:maxn]
    return rest


def parse_scripps_html(html):
    h = str(html)
    section = html_section(h, "module--closings", 40000)
    if section == "":
        if h.find("There are currently no active closings or delays") >= 0:
            return {"kind": "empty", "rows": []}
        return None
    if section.find("There are currently no active closings or delays") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    names = extract_class_text(section, "text--primary")
    stats = extract_class_text(section, "text--secondary")
    for i in range(len(names)):
        status = ""
        if i < len(stats):
            status = stats[i]
        append_named_row(rows, names[i], status)
        if len(rows) >= SCAN:
            break
    if rows == []:
        for text in extract_class_text(section, "closing"):
            name, status = split_name_status(text)
            append_named_row(rows, name, status)
            if len(rows) >= SCAN:
                break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    return {"kind": "empty", "rows": []}


def parse_flashalert_html(html):
    h = str(html)
    if h.find("No information reported") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    for text in extract_class_text(h, "cwcReport"):
        if is_boilerplate(text):
            continue
        name, status = split_name_status(text)
        append_named_row(rows, name, status)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("cwcReportContainer") >= 0:
        return {"kind": "empty", "rows": []}
    return None


def take_url_at(h, start):
    rest = str(h)[start:]
    rest = rest.replace("\\/", "/")
    rest = rest.replace("\\u002F", "/")
    if rest.find("https://") != 0 and rest.find("http://") != 0:
        return ""
    end = len(rest)
    for ch in ["\"", "'", " ", "<", ">", "}", "]", "\n", "\r", "\\"]:
        e = rest.find(ch)
        if e >= 0 and e < end:
            end = e
    url = rest[:end]
    if url.find("http") != 0:
        return ""
    return url


def url_near_needle(html, needle):
    h = str(html)
    p = h.find(needle)
    if p < 0:
        return ""
    idx = p
    for _ in range(180):
        if idx < 0:
            break
        if h[idx:idx + 4] == "http":
            return take_url_at(h, idx)
        idx = idx - 1
    return ""


def ftptransfer_path(html):
    h = str(html)
    needle = "/resources/ftptransfer/"
    rest = h
    for _ in range(16):
        p = rest.find(needle)
        if p < 0:
            return ""
        chunk = rest[p:]
        rest = rest[p + len(needle):]
        end = -1
        e1 = chunk.find(".html")
        e2 = chunk.find(".htm")
        if e1 >= 0 and e1 < 180:
            end = e1 + 5
        elif e2 >= 0 and e2 < 180:
            end = e2 + 4
        if end < 0:
            continue
        path = chunk[:end]
        if path.find("closing") < 0:
            continue
        bad = False
        for ch in [" ", "\"", "'", "<", ">", "\n", "\r", "\\"]:
            if path.find(ch) >= 0:
                bad = True
        if bad:
            continue
        return path
    return ""


def flashalert_src(html):
    u = url_near_needle(html, "flashalertnewswire.net")
    if u == "":
        u = url_near_needle(html, "cwc-closures.php")
    return u


def worldnow_src(html, page_url):
    foxtv = url_near_needle(html, "media.foxtv.com")
    if foxtv.find("/closings") >= 0 or foxtv.find("closings.") >= 0:
        return foxtv
    path = ftptransfer_path(html)
    if path != "":
        return abs_url(path, page_url)
    return ""


def cbs_feed_src(html):
    u = url_near_needle(html, "Integrations/SchoolClosings")
    if u != "":
        return u
    u = url_near_needle(html, "Integrations\\/SchoolClosings")
    if u != "":
        return u
    return url_near_needle(html, "SchoolClosings")


def looks_like_worldnow(html):
    h = str(html)
    if h.find("CLASS=\"orgname\"") >= 0 or h.find("class=\"orgname\"") >= 0:
        return True
    if h.find("There are no active records at this time") >= 0:
        return True
    if h.find("THERE ARE CURRENTLY NO CLOSINGS OR CANCELLATIONS") >= 0:
        return True
    if h.find("No Closings Reported") >= 0 and h.find("Last Updated") >= 0:
        return True
    if h.find("media.foxtv.com") >= 0 and h.find("/closings") >= 0:
        return True
    if ftptransfer_path(h) != "":
        return True
    return False


def looks_like_tegna(html):
    h = str(html)
    if h.find("closings__error") >= 0:
        return True
    if h.find("closings__list") >= 0 or h.find("closings__item") >= 0:
        return True
    if h.find("closings__title") >= 0:
        return True
    return False


def looks_like_hearst(html):
    h = str(html)
    if h.find("closingsData") >= 0:
        return True
    if h.find("No closings or delays at this time") >= 0:
        return True
    return False


def looks_like_cbs(html):
    h = str(html)
    if h.find("data-component=\"school-closings\"") >= 0:
        return True
    if h.find("data-school-closings-options") >= 0:
        return True
    if h.find("Integrations/SchoolClosings") >= 0:
        return True
    return False


def looks_like_cox(html):
    h = str(html)
    if h.find("class=\"closing-list") >= 0:
        return True
    if h.find("class='closing-list") >= 0:
        return True
    return False


def looks_like_arc_school(html):
    h = str(html)
    if h.find("weather-school-closings") >= 0:
        return True
    if h.find("SchoolClosings/default") >= 0:
        return True
    if h.find("class=\"school-closings\"") >= 0:
        return True
    if h.find("class='school-closings'") >= 0:
        return True
    return False


def arc_school_empty_copy(html):
    h = str(html)
    if h.find("No active school closings at this time") >= 0:
        return True
    if h.find("No active school closings") >= 0:
        return True
    return False


def worldnow_empty_copy(html):
    h = str(html)
    if h.find("There are no active records at this time") >= 0:
        return True
    if h.find("No Closings Reported") >= 0:
        return True
    if h.find("THERE ARE CURRENTLY NO CLOSINGS OR CANCELLATIONS") >= 0:
        return True
    if h.find("THERE ARE CURRENTLY NO CLOSINGS") >= 0:
        return True
    return False


def parse_worldnow_html(html):
    h = str(html)
    if worldnow_empty_copy(h):
        return {"kind": "empty", "rows": []}
    rows = []
    names = extract_class_text(h, "orgname")
    stats = extract_class_text(h, "status")
    for i in range(len(names)):
        status = ""
        if i < len(stats):
            status = stats[i]
        append_named_row(rows, names[i], status)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("CLASS=\"orgname\"") >= 0 or h.find("class=\"orgname\"") >= 0:
        return {"kind": "empty", "rows": []}
    if looks_like_worldnow(h):
        return {"kind": "unparseable", "rows": []}
    return None


def parse_tegna_html(html):
    h = str(html)
    if h.find("No delays or closings") >= 0:
        return {"kind": "empty", "rows": []}
    if h.find("closings__error") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    names = extract_class_text(h, "closings__title")
    stats = extract_class_text(h, "closings__body")
    for i in range(len(names)):
        status = ""
        if i < len(stats):
            status = stats[i]
        append_named_row(rows, names[i], status)
        if len(rows) >= SCAN:
            break
    if rows == []:
        for text in extract_class_text(h, "closings__item"):
            name, status = split_name_status(text)
            append_named_row(rows, name, status)
            if len(rows) >= SCAN:
                break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    if h.find("closings__list") >= 0:
        return {"kind": "empty", "rows": []}
    return {"kind": "unparseable", "rows": []}


def jsonish_field(block, key):
    needles = [
        "\"" + key + "\":\"",
        "\\\"" + key + "\\\":\\\"",
    ]
    for needle in needles:
        p = str(block).find(needle)
        if p < 0:
            continue
        rest = str(block)[p + len(needle):]
        end = len(rest)
        e1 = rest.find("\\\"")
        e2 = rest.find("\"")
        if e1 >= 0 and e1 < end:
            end = e1
        if e2 >= 0 and e2 < end:
            end = e2
        val = decode(rest[:end])
        if val != "":
            return val
    return ""


def hearst_array_populated(window):
    w = str(window)
    if w.find("closings\\\":[{") >= 0:
        return True
    if w.find("\"closings\":[{") >= 0:
        return True
    if w.find("closings\":[{") >= 0:
        return True
    return False


def parse_hearst_objects(window):
    w = str(window)
    start = w.find("[{")
    if start < 0:
        start = w.find("[ {")
    if start < 0:
        return []
    rest = w[start:]
    rows = []
    for _ in range(40):
        if len(rows) >= SCAN:
            break
        a = rest.find("{")
        if a < 0:
            break
        rest = rest[a + 1:]
        end = rest.find("}")
        if end < 0:
            break
        block = rest[:end]
        rest = rest[end + 1:]
        name = jsonish_field(block, "name")
        if name == "":
            name = jsonish_field(block, "title")
        if name == "":
            name = jsonish_field(block, "organization")
        if name == "":
            name = jsonish_field(block, "organizationName")
        if name == "":
            name = jsonish_field(block, "orgName")
        status = jsonish_field(block, "status")
        if status == "":
            status = jsonish_field(block, "closingStatus")
        if status == "":
            status = jsonish_field(block, "statusText")
        if status == "":
            status = jsonish_field(block, "notice")
        append_named_row(rows, name, status)
    return rows


def parse_hearst_html(html):
    h = str(html)
    p = h.find("closingsData")
    if p >= 0:
        window = h[p:]
        if len(window) > 80000:
            window = window[:80000]
        if hearst_array_populated(window):
            rows = parse_hearst_objects(window)
            if rows != []:
                return {"kind": "ok", "rows": rows[:SCAN]}
            return {"kind": "unparseable", "rows": []}
        return {"kind": "empty", "rows": []}
    if h.find("No closings or delays at this time") >= 0:
        return {"kind": "empty", "rows": []}
    return None


def parse_cox_html(html):
    h = str(html)
    section = html_section(h, "closing-list", 40000)
    if section == "":
        return None
    if section.find("No results found") >= 0:
        return {"kind": "empty", "rows": []}
    rows = []
    names = extract_class_text(section, "closing-name")
    stats = extract_class_text(section, "closing-status")
    if names == []:
        names = extract_class_text(section, "closing-list__name")
        stats = extract_class_text(section, "closing-list__status")
    for i in range(len(names)):
        status = ""
        if i < len(stats):
            status = stats[i]
        append_named_row(rows, names[i], status)
        if len(rows) >= SCAN:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    return {"kind": "unparseable", "rows": []}


def parse_arc_school_json(data):
    if type(data) != "dict":
        return None
    if "organizations" in data or "totalResults" in data:
        return None
    closing = data.get("closing", None)
    if closing == None:
        if "lastUpdated" in data:
            return {"kind": "empty", "rows": []}
        return None
    if type(closing) != "list":
        return None
    rows = []
    for item in closing:
        if type(item) != "dict":
            continue
        code = str(item.get("statuscode", ""))
        if code == "0":
            continue
        row = normalize_row({
            "name": item.get("name1", ""),
            "status": item.get("status", ""),
            "type": item.get("entitytype", ""),
        })
        if row != None:
            rows.append(row)
        if len(rows) >= SCAN:
            break
    if rows == []:
        return {"kind": "empty", "rows": []}
    return {"kind": "ok", "rows": rows[:SCAN]}


def parse_arc_school_html(html):
    h = str(html)
    section = html_section(h, "class=\"school-closings\"", 50000)
    if section == "":
        section = html_section(h, "class='school-closings'", 50000)
    if section == "":
        if arc_school_empty_copy(h):
            return {"kind": "empty", "rows": []}
        return None
    if arc_school_empty_copy(section):
        return {"kind": "empty", "rows": []}
    rows = []
    rest = section
    for _ in range(SCAN):
        p = rest.find("class=\"school\"")
        if p < 0:
            p = rest.find("class='school'")
        if p < 0:
            break
        rest = rest[p + 12:]
        nxt = rest.find("class=\"school\"")
        alt = rest.find("class='school'")
        if nxt < 0 or (alt >= 0 and alt < nxt):
            nxt = alt
        block = rest[:nxt] if nxt >= 0 else rest[:1500]
        names = extract_class_text(block, "name")
        stats = extract_class_text(block, "status")
        kinds = extract_class_text(block, "entity-type")
        name = ""
        if names != []:
            name = names[0]
        if kinds != [] and name != "":
            name = collapse_ws(name.replace(kinds[0], ""))
        status = ""
        if stats != []:
            status = stats[0]
        append_named_row(rows, name, status)
        if nxt < 0:
            break
    if rows != []:
        return {"kind": "ok", "rows": rows[:SCAN]}
    return {"kind": "unparseable", "rows": []}


def fetch_arc_school(origin, html):
    if arc_school_empty_copy(html):
        return {"kind": "empty", "rows": []}
    api = origin + ARC_SCHOOL_PATH
    g = http_get(api)
    if g["status_code"] == 200:
        parsed = parse_arc_school_json(g["json"])
        if parsed != None:
            return parsed
    parsed = parse_arc_school_html(html)
    if parsed != None:
        return parsed
    if g["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    return {"kind": "unparseable", "rows": []}


def fetch_flashalert(url, html):
    src = flashalert_src(html)
    if src == "":
        parsed = parse_flashalert_html(html)
        if parsed != None:
            return parsed
        return None
    x = http_get(abs_url(src, url))
    if x["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    parsed = parse_flashalert_html(x["body"])
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def fetch_worldnow(url, html):
    src = worldnow_src(html, url)
    if src == "":
        parsed = parse_worldnow_html(html)
        if parsed != None:
            return parsed
        return None
    x = http_get(src)
    if x["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    parsed = parse_worldnow_html(x["body"])
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def fetch_cbs(html):
    feed = cbs_feed_src(html)
    if feed == "":
        return {"kind": "unparseable", "rows": []}
    if feed.find("emergencyclosingcenter.com") >= 0:
        return {"kind": "unsupported", "rows": []}
    x = http_get(feed)
    if x["status_code"] != 200:
        return {"kind": "unavailable", "rows": []}
    parsed = parse_newsticker_xml(x["body"])
    if parsed != None:
        return parsed
    parsed = parse_townnews_xml(x["body"])
    if parsed != None:
        return parsed
    return {"kind": "unparseable", "rows": []}


def http_get(url):
    if url == "":
        return {"status_code": 0, "body": "", "json": None}
    return http.get(url, headers = HEADERS, ttl_seconds = TTL)


def first_str(obj, keys):
    if type(obj) != "dict":
        return ""
    for k in keys:
        if k not in obj or obj[k] == None:
            continue
        v = obj[k]
        t = type(v)
        if t == "string" or t == "int" or t == "float":
            s = decode(str(v))
            if s != "":
                return s
        elif t == "dict":
            inner = first_str(v, [
                "name", "name1", "text", "value", "label", "title",
                "forced", "completeStatus", "status",
            ])
            if inner != "":
                return inner
        elif t == "list" and len(v) > 0:
            item = v[0]
            if type(item) == "string" or type(item) == "int":
                s = decode(str(item))
                if s != "":
                    return s
            elif type(item) == "dict":
                inner = first_str(item, [
                    "name", "name1", "text", "value", "label", "title",
                ])
                if inner != "":
                    return inner
    return ""


def status_kind(status):
    u = str(status).upper()
    if u.find("CLOSED") >= 0 or u.find("CANCEL") >= 0:
        return "closed"
    if u.find("REMOTE") >= 0:
        return "remote"
    if u.find("DELAY") >= 0 or u.find("LATE") >= 0 or u.find("DISMISS") >= 0:
        return "delay"
    return "other"


def status_color(kind):
    if kind == "closed":
        return RED
    if kind == "delay":
        return AMBER
    if kind == "remote":
        return CYAN
    return AMBER


def is_open_status(st):
    u = str(st).upper()
    if u == "OPEN" or u == "OPENED" or u == "NORMAL" or u == "NO CHANGE":
        return True
    if u.find("AS USUAL") >= 0 or u.find("NO DELAY") >= 0:
        return True
    if u.find("NO CLOS") >= 0:
        return True
    return False


def normalize_status(raw):
    u = collapse_ws(str(raw)).upper()
    u = u.replace("HOURS", "HR").replace("HOUR", "HR").replace("HRS", "HR")
    u = u.replace(".", "")
    u = collapse_ws(u)
    if u == "":
        return ""
    if u.find("REMOTE") >= 0 or u.find("VIRTUAL") >= 0 or u.find("E-LEARN") >= 0 or u.find("E LEARN") >= 0:
        return "REMOTE LEARNING"
    if u.find("EARLY DISMISS") >= 0 or u.find("EARLY RELEASE") >= 0 or u.find("CLOSING EARLY") >= 0:
        return "EARLY DISMISSAL"
    if u.find("OPENING LATE") >= 0 or u.find("LATE START") >= 0 or u.find("STARTS LATE") >= 0:
        return "OPENING LATE"
    if u.find("CANCEL") >= 0:
        return "CANCELLED"
    if u.find("2 HR") >= 0 or u.find("2HR") >= 0 or u.find("TWO HR") >= 0:
        return "2 HR DELAY"
    if u.find("1 HR") >= 0 or u.find("1HR") >= 0 or u.find("ONE HR") >= 0:
        return "1 HR DELAY"
    if u.find("3 HR") >= 0 or u.find("3HR") >= 0:
        return "3 HR DELAY"
    if u.find("DELAY") >= 0:
        if u.find("HR DELAY") >= 0:
            return u
        return "DELAY"
    if u.find("CLOSED") >= 0 or u == "CLOSE" or u.find("CLOSING") >= 0:
        return "CLOSED"
    return u


def normalize_row(obj):
    name = first_str(obj, NAME_KEYS).upper()
    status = normalize_status(first_str(obj, STATUS_KEYS))
    detail = first_str(obj, DETAIL_KEYS).upper()
    z = zip_label(first_str(obj, ZIP_KEYS))
    if name == "":
        return None
    if is_open_status(status):
        return None
    if status == "":
        typ = first_str(obj, TYPE_KEYS).upper()
        if typ != "":
            status = typ
        else:
            status = "REPORTED"
    if detail == status:
        detail = ""
    return {
        "name": name,
        "status": status,
        "detail": detail,
        "zip": z,
        "kind": status_kind(status),
        "matched": False,
    }


def parse_gsync_json(data):
    if type(data) != "dict":
        return None
    has_total = "totalResults" in data
    has_orgs = "organizations" in data
    has_export = "exportType" in data
    if not has_total and not has_orgs and not has_export:
        return None
    orgs = data.get("organizations", [])
    rows = []
    if type(orgs) == "list":
        for item in orgs:
            row = normalize_row(item)
            if row != None:
                rows.append(row)
            if len(rows) >= SCAN:
                break
    total = data.get("totalResults", None)
    n = 0
    if total != None:
        n = int(digits_only(str(total)) or "0")
    if rows == [] and (has_total or has_orgs):
        if n == 0 or (has_orgs and type(orgs) == "list" and len(orgs) == 0):
            return {"kind": "empty", "rows": []}
        return {"kind": "unparseable", "rows": []}
    return {"kind": "ok", "rows": rows}


def parse_newsticker_xml(body):
    raw = str(body)
    start = raw.find("<DATA>")
    section = raw[start:] if start >= 0 else raw
    if section.find("<NUM_CLOSINGS>") < 0 and section.find("<RECORD") < 0:
        return None
    num = xml_text(section, "NUM_CLOSINGS")
    n = int(digits_only(num) or "0")
    rows = []
    rest = section
    for _ in range(40):
        if len(rows) >= SCAN:
            break
        a = rest.find("<RECORD")
        if a < 0:
            break
        rest = rest[a + 7:]
        end = rest.find("</RECORD>")
        if end < 0:
            break
        block = rest[:end]
        rest = rest[end + 9:]
        name = xml_text(block, "ORGANIZATION_NAME1")
        if name == "":
            name = xml_text(block, "FORCED_ORGANIZATION_NAME")
        if name == "":
            name = xml_text(block, "ALT_ORGANIZATION_NAME")
        status = xml_text(block, "COMPLETE_STATUS")
        if status == "":
            status = xml_text(block, "STATUS_NAME1")
        if status == "":
            status = xml_text(block, "FORCED_STATUS_NAME")
        if status == "":
            status = xml_text(block, "ALT_STATUS_TEXT")
        detail = xml_text(block, "COMMENTS_LINE1")
        z = xml_text(block, "ZIPCODE")
        row = normalize_row({
            "name": name,
            "status": status,
            "detail": detail,
            "zipcode": z,
        })
        if row != None:
            rows.append(row)
    if rows == []:
        if n == 0:
            return {"kind": "empty", "rows": []}
        return {"kind": "unparseable", "rows": []}
    return {"kind": "ok", "rows": rows}


def school_query(raw):
    q = collapse_ws(str(raw)).upper()
    if len(q) < 3:
        return ""
    if q == "SCHOOL" or q == "SCHOOLS" or q == "THE" or q == "AND":
        return ""
    if q == "COUNTY" or q == "PUBLIC" or q == "CLOSED" or q == "CLOSINGS":
        return ""
    if q == "DELAY" or q == "DELAYS" or q == "DISTRICT":
        return ""
    return q


def school_match_score(query, name):
    q = school_query(query)
    n = collapse_ws(str(name)).upper()
    if q == "" or n == "":
        return 0
    if q == n:
        return 3
    if n.find(q) == 0:
        return 2
    if q.find(n) == 0 and len(n) >= 3:
        return 2
    if n.find(q) >= 0:
        return 1
    if q.find(n) >= 0 and len(n) >= 5:
        return 1
    return 0


def with_match(row, matched):
    return {
        "name": row.get("name", ""),
        "status": row.get("status", ""),
        "detail": row.get("detail", ""),
        "zip": row.get("zip", ""),
        "kind": row.get("kind", "other"),
        "matched": matched,
    }


def prefer_school(rows, query):
    if rows == []:
        return rows
    q = school_query(query)
    if q == "":
        out = []
        for r in rows:
            out.append(with_match(r, False))
            if len(out) >= WANT:
                break
        return out
    exact = []
    prefix = []
    contains = []
    rest = []
    for r in rows:
        score = school_match_score(q, r.get("name", ""))
        item = with_match(r, score > 0)
        if score == 3:
            exact.append(item)
        elif score == 2:
            prefix.append(item)
        elif score == 1:
            contains.append(item)
        else:
            rest.append(item)
    out = exact + prefix + contains + rest
    if len(out) > WANT:
        out = out[:WANT]
    return out


def fetch_source(url):
    u = collapse_ws(url)
    if u.find("://") < 0 and u.find(".") >= 0:
        u = "https://" + u
    if u.find("https://") != 0 and u.find("http://") != 0:
        return {"kind": "unsupported", "rows": []}

    if u.find("gsync-closings") >= 0:
        r = http_get(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_gsync_json(r["json"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("/app/closings/") >= 0 and u.find(".xml") >= 0:
        r = http_get(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_townnews_xml(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("closings.xml") >= 0 or u.find("newsticker/closings") >= 0:
        xml_url = u.replace(".html", ".xml")
        r = http_get(xml_url)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_newsticker_xml(r["body"])
        if parsed != None:
            return parsed
        parsed = parse_townnews_xml(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("flashalertnewswire.net") >= 0:
        r = http_get(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_flashalert_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("media.foxtv.com") >= 0 and u.find("closing") >= 0:
        r = http_get(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_worldnow_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("/resources/ftptransfer/") >= 0 and u.find("closing") >= 0:
        r = http_get(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_worldnow_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if u.find("weather-school-closings") >= 0:
        r = http_get(u)
        if r["status_code"] != 200:
            return {"kind": "unavailable", "rows": []}
        parsed = parse_arc_school_json(r["json"])
        if parsed != None:
            return parsed
        parsed = parse_arc_school_html(r["body"])
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    r = http_get(u)
    if r["status_code"] != 200:
        if looks_like_closings_url(u):
            wp = fetch_nexstar_wp(u)
            if wp != None:
                return wp
        return {"kind": "unavailable", "rows": []}

    parsed = parse_gsync_json(r["json"])
    if parsed != None:
        return parsed
    parsed = parse_newsticker_xml(r["body"])
    if parsed != None:
        return parsed
    parsed = parse_townnews_xml(r["body"])
    if parsed != None:
        return parsed

    body = r["body"]
    if looks_like_gsync(body):
        api = origin_of(u) + GSYNC_PATH
        g = http_get(api)
        if g["status_code"] == 200:
            parsed = parse_gsync_json(g["json"])
            if parsed != None:
                return parsed
            return {"kind": "unparseable", "rows": []}
        return {"kind": "unavailable", "rows": []}

    if looks_like_newsticker(body):
        xml_url = newsticker_xml_from_html(body)
        if xml_url == "" and u.find(".html") >= 0:
            xml_url = u.replace(".html", ".xml")
        if xml_url != "":
            x = http_get(xml_url)
            if x["status_code"] == 200:
                parsed = parse_newsticker_xml(x["body"])
                if parsed != None:
                    return parsed
        parsed = parse_newsticker_xml(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if looks_like_townnews(body):
        return fetch_townnews(origin_of(u), body)

    if looks_like_nexstar(body) or nexstar_iframe_src(body) != "":
        return fetch_nexstar(u, body)

    if looks_like_nbc(body):
        return fetch_nbc(u, body)

    if looks_like_scripps(body):
        parsed = parse_scripps_html(body)
        if parsed != None:
            return parsed

    if flashalert_src(body) != "" or looks_like_flashalert(body):
        parsed = fetch_flashalert(u, body)
        if parsed != None:
            return parsed

    if worldnow_src(body, u) != "" or looks_like_worldnow(body):
        parsed = fetch_worldnow(u, body)
        if parsed != None:
            return parsed

    if looks_like_tegna(body):
        parsed = parse_tegna_html(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if looks_like_hearst(body):
        parsed = parse_hearst_html(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if looks_like_cbs(body):
        return fetch_cbs(body)

    if looks_like_cox(body):
        parsed = parse_cox_html(body)
        if parsed != None:
            return parsed
        return {"kind": "unparseable", "rows": []}

    if looks_like_arc_school(body):
        return fetch_arc_school(origin_of(u), body)

    if looks_like_closings_url(u):
        wp = fetch_nexstar_wp(u)
        if wp != None:
            return wp

    return {"kind": "unsupported", "rows": []}


def load_state(ctx):
    school = school_query(_s(ctx, "school", ""))
    url = _s(ctx, "closingsurl", "")
    if url == "":
        return {"kind": "missing", "school": school, "rows": [], "url": ""}
    got = fetch_source(url)
    rows = prefer_school(got.get("rows", []), school)
    kind = got.get("kind", "unavailable")
    if kind == "ok" and rows == []:
        kind = "empty"
    return {
        "kind": kind,
        "school": school,
        "rows": rows,
        "url": url,
    }


def clip_line(c, text, font, maxw):
    t = str(text)
    if c.text_width(t, font) <= maxw:
        return t
    for k in range(len(t), 0, -1):
        cand = t[:k] + ".."
        if c.text_width(cand, font) <= maxw:
            return cand
    return ""


def wrap_words(c, text, font, maxw):
    words = str(text).upper().split(" ")
    lines = []
    cur = ""
    for w in words:
        if w == "":
            continue
        trial = w if cur == "" else cur + " " + w
        if c.text_width(trial, font) <= maxw:
            cur = trial
        else:
            if cur != "":
                lines.append(cur)
            if c.text_width(w, font) <= maxw:
                cur = w
            else:
                lines.append(clip_line(c, w, font, maxw))
                cur = ""
    if cur != "":
        lines.append(cur)
    return lines


def fit_name(c, text, maxw, max_lines):
    raw = str(text).upper()
    one = ["6x8", "5x7", "4x5"]
    for font in one:
        if c.text_width(raw, font) <= maxw:
            return [raw], font
    wrap_fonts = ["4x5"]
    for font in wrap_fonts:
        lines = wrap_words(c, raw, font, maxw)
        if lines != [] and len(lines) <= max_lines:
            ok = True
            for ln in lines:
                if c.text_width(ln, font) > maxw:
                    ok = False
            if ok:
                return lines, font
    font = "4x5"
    lines = wrap_words(c, raw, font, maxw)
    if lines == []:
        return [clip_line(c, raw, font, maxw)], font
    n = max_lines
    if n > len(lines):
        n = len(lines)
    out = []
    for i in range(n):
        line = lines[i]
        line = clip_line(c, line, font, maxw)
        out.append(line)
    return out, font


def closed_count(rows):
    n = 0
    for r in rows:
        if r.get("kind", "") == "closed":
            n = n + 1
    return n


def draw_chrome(c, col):
    c.gradient_rect(0, 0, c.width - 1, c.height - 1, BG, BG2, horizontal = False)
    c.gradient_rect(0, 0, 52, c.height - 1, color.dim(col, 32), BG, horizontal = True)
    c.rect(0, 0, 2, c.height - 1, fill = col)
    c.rect(0, 0, c.width - 1, 0, fill = col)
    c.rect(0, c.height - 1, c.width - 1, c.height - 1, fill = color.dim(col, 55))
    c.pixel(c.width - 1, 4, color.dim(col, 60))
    c.pixel(c.width - 1, 16, color.dim(col, 60))
    c.pixel(c.width - 1, 27, color.dim(col, 60))


def draw_brand(c, col, icon_art):
    c.sprite(icon_art, 6, 2, color = col)
    c.text("LOCAL CLOSINGS", 16, 2, font = "5x7", color = TITLE)


def draw_status_pill(c, status, col, x, y):
    t = str(status).upper()
    font = "6x8"
    if c.text_width(t, font) > 130:
        font = "5x7"
    tw = c.text_width(t, font)
    c.round_rect(x, y, x + tw + 6, y + 9, 2, fill = col)
    c.text(t, x + 3, y + 1, font = font, color = INK)
    return tw + 6


def draw_dots(c, rows, x, y):
    i = 0
    for r in rows:
        if i >= WANT:
            break
        c.status_dot(x + i * 7, y, status_color(r.get("kind", "other")))
        i = i + 1


def compact_school(name):
    t = collapse_ws(str(name)).upper()
    pairs = [
        ["HIGH SCHOOL", "HS"],
        ["MIDDLE SCHOOL", "MS"],
        ["ELEMENTARY SCHOOL", "ES"],
        ["JUNIOR HIGH", "JR HI"],
        ["COMMUNITY SCHOOLS", "COMM SCH"],
        ["PUBLIC SCHOOLS", "PUB SCH"],
        ["SCHOOL DISTRICT", "DIST"],
        ["ELEMENTARY", "ELEM"],
        ["COMMUNITY", "COMM"],
        ["TOWNSHIP", "TWP"],
        ["COUNTY", "CO"],
        ["SCHOOLS", "SCH"],
        ["SCHOOL", "SCH"],
        ["DISTRICT", "DIST"],
    ]
    for pair in pairs:
        t = t.replace(pair[0], pair[1])
    return collapse_ws(t)


def draw_school(c, school, col):
    q = collapse_ws(str(school)).upper()
    if q == "":
        return
    maxw = 90
    font = "4x5"
    label = q
    if c.text_width(label, font) > maxw:
        label = compact_school(q)
    if c.text_width(label, font) > maxw:
        label = clip_line(c, label, font, maxw)
    if label == "":
        return
    c.text(label, c.width - 4, 3, font = font, color = col, align = "right")


def draw_fail(c, title, sub, col):
    draw_chrome(c, col)
    c.sprite(ICON_WARN, 6, 2, color = col)
    c.text("LOCAL CLOSINGS", 16, 2, font = "5x7", color = TITLE)
    c.badge("ALERT", c.width - 32, 2, color = INK, bg = col, font = "4x5", pad = 1)
    t = title.upper()
    s = sub.upper()
    if c.text_width(t, "10x14") <= 176:
        c.text(t, 6, 10, font = "10x14", color = col)
    else:
        c.text_fit(t, 6, 12, ["6x8", "5x7"], color = col, maxw = 176)
    c.text_fit(s, 6, 25, ["5x7", "4x5"], color = MUTED, maxw = 176)


def draw_empty(c, st):
    draw_chrome(c, GREEN)
    draw_brand(c, GREEN, ICON_CHECK)
    school = st.get("school", "")
    if school != "":
        draw_school(c, school, MUTED)
    else:
        c.badge("CLEAR", c.width - 32, 2, color = INK, bg = GREEN, font = "4x5", pad = 1)
    c.text("NO REPORTED", 6, 10, font = "10x14", color = GREEN)
    c.text("CLOSINGS", 6, 25, font = "4x5", color = color.dim(GREEN, 70))
    i = 0
    for _ in range(5):
        c.status_dot(c.width - 8 - (4 - i) * 7, 27, color.dim(GREEN, 28))
        i = i + 1


def draw_empty_item(c, st, idx):
    draw_chrome(c, GREEN)
    draw_brand(c, GREEN, ICON_CHECK)
    draw_school(c, st.get("school", ""), MUTED)
    if st.get("school", "") == "":
        c.badge("CLEAR", c.width - 32, 2, color = INK, bg = GREEN, font = "4x5", pad = 1)
    host = host_label(st.get("url", ""))
    if host == "":
        host = "CONFIGURED SOURCE"
    c.text_fit(host, 6, 12, ["6x8", "5x7", "4x5"], color = MUTED, maxw = 176)
    c.text("NO REPORTED CLOSINGS", 6, 23, font = "5x7", color = GREEN)


def draw_missing(c, st):
    draw_fail(c, "SET CLOSINGS", "WEBSITE URL", FAIL)


def draw_unavailable(c, st):
    draw_fail(c, "SOURCE", "UNAVAILABLE", FAIL)


def draw_unsupported(c, st):
    draw_fail(c, "SOURCE NOT", "SUPPORTED", FAIL)


def draw_unparseable(c, st):
    draw_fail(c, "SOURCE NOT", "SUPPORTED", FAIL)


def draw_board_ok(c, st):
    rows = st["rows"]
    n = len(rows)
    n_closed = closed_count(rows)
    col = RED if n_closed > 0 else AMBER
    draw_chrome(c, col)
    draw_brand(c, col, ICON_SCHOOL)
    draw_school(c, st.get("school", ""), MUTED)

    headline = str(n) + " REPORTED"
    if n == 1:
        headline = "1 REPORTED"
    c.text(headline, 6, 10, font = "10x14", color = col)

    foot = "CLOSINGS"
    n_match = 0
    for r in rows:
        if r.get("matched", False):
            n_match = n_match + 1
    if n_match > 0:
        foot = "YOUR SCHOOL FIRST"
    elif n_closed > 0:
        foot = str(n_closed) + " CLOSED"
    c.text(foot, 6, 26, font = "4x5", color = MUTED)
    draw_dots(c, rows, c.width - 8 - n * 7, 28)


def draw_item(c, st, idx):
    kind = st["kind"]
    if kind == "missing":
        draw_missing(c, st)
        return
    if kind == "unavailable":
        draw_unavailable(c, st)
        return
    if kind == "unsupported":
        draw_unsupported(c, st)
        return
    if kind == "unparseable":
        draw_unparseable(c, st)
        return
    if kind == "empty" or st["rows"] == []:
        draw_empty_item(c, st, idx)
        return

    rows = st["rows"]
    if idx >= len(rows):
        draw_chrome(c, DIM)
        draw_brand(c, DIM, ICON_SCHOOL)
        c.text("NO LISTING " + str(idx + 1), 6, 13, font = "6x8", color = FAIL)
        c.text("SOURCE HAS " + str(len(rows)), 6, 24, font = "5x7", color = DIM)
        return

    row = rows[idx]
    col = status_color(row["kind"])
    draw_chrome(c, col)
    c.sprite(ICON_SCHOOL, 6, 2, color = col)

    maxw = 148
    lines, font = fit_name(c, row["name"], maxw, 2)
    x = 16
    y = 2
    lh = 8
    if font == "5x7":
        lh = 8
    elif font == "4x5":
        lh = 7
    elif font == "6x8":
        lh = 9
    for i in range(len(lines)):
        c.text(lines[i], x, y + i * lh, font = font, color = TITLE)

    mark = str(idx + 1) + "/" + str(len(rows))
    c.text(mark, c.width - 4, 2, font = "4x5", color = DIM, align = "right")

    draw_status_pill(c, row["status"], col, 6, 15)

    if row.get("matched", False) == False:
        if row.get("kind", "") == "closed":
            c.sprite(ICON_X, c.width - 16, 11, color = color.dim(col, 70))
        elif row.get("kind", "") == "delay":
            c.sprite(ICON_CLOCK, c.width - 16, 11, color = color.dim(col, 70))

    foot = row.get("detail", "")
    if foot != "":
        max_foot = 176
        if row.get("matched", False):
            max_foot = 110
        c.text(clip_line(c, foot, "4x5", max_foot), 6, 26, font = "4x5", color = MUTED)
    if row.get("matched", False):
        c.badge("YOUR SCHOOL", c.width - 58, 23, color = INK, bg = CYAN, font = "4x5", pad = 1)


def board(c, ctx):
    st = load_state(ctx)
    kind = st["kind"]
    if kind == "missing":
        draw_missing(c, st)
        return
    if kind == "unavailable":
        draw_unavailable(c, st)
        return
    if kind == "unsupported":
        draw_unsupported(c, st)
        return
    if kind == "unparseable":
        draw_unparseable(c, st)
        return
    if kind == "empty" or st["rows"] == []:
        draw_empty(c, st)
        return
    draw_board_ok(c, st)


def one(c, ctx):
    draw_item(c, load_state(ctx), 0)


def two(c, ctx):
    draw_item(c, load_state(ctx), 1)


def three(c, ctx):
    draw_item(c, load_state(ctx), 2)


def four(c, ctx):
    draw_item(c, load_state(ctx), 3)


def five(c, ctx):
    draw_item(c, load_state(ctx), 4)
