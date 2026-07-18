# What Is My IP (128x32)
#
# Diagnostic app. Makes one http.get to an IP-echo service and renders the egress
# IP the request came from. On a host that routes app traffic through a proxy pool,
# this shows a PROXY ip; a direct fetch shows the host's own ip. Compare it against
# your render host's ip and your proxy ips to confirm outbound proxying is in effect.
# (Starlark can't read env vars, so the app can't know GDN_P itself — you compare
# the ip by eye.)

def ip(c, ctx):
    r = http.get("https://api.ipify.org", params = {"format": "json"}, ttl_seconds = 0)

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text_center("EGRESS IP", 1, font = "5x7", color = "white")

    if r["status_code"] != 200 or r["json"] == None:
        c.text_center("NO RESPONSE", 13, font = "6x8", color = "red")
        c.text_center("CODE " + str(r["status_code"]), 24, font = "4x5", color = "gray")
        return

    addr = str(r["json"].get("ip", "?"))
    font = "6x8" if len(addr) <= 15 else "5x7"
    c.text_center(addr, 14, font = font, color = "green")
