# What Is My IP (128x32) — shows your public IP address.

def ip(c, ctx):
    r = http.get("https://api.ipify.org", params = {"format": "json"}, ttl_seconds = 0)

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill = "blue")
    c.text_center("IP ADDRESS", 1, font = "5x7", color = "white")

    if r["status_code"] != 200 or r["json"] == None:
        c.text_center("NO RESPONSE", 13, font = "6x8", color = "red")
        c.text_center("CODE " + str(r["status_code"]), 24, font = "4x5", color = "gray")
        return

    addr = str(r["json"].get("ip", "?"))
    font = "6x8" if len(addr) <= 15 else "5x7"
    c.text_center(addr, 14, font = font, color = "green")
