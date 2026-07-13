"""Weather Ticker — a starter GDN app.

Two static pages (192x32): current conditions and a 5-day strip. It runs fully
offline using mock data derived from the zip code, so `gdn preview` works with
no API keys. Swap `get_weather()` for a real request when you deploy.

Edit this file in the Studio or in VS Code — both use the same file. After any
change, the preview re-renders automatically.
"""
from gdn import App

app = App(name="Weather Ticker", width=192)


# --- data (mock; replace with a real API call later) ------------------------
def get_weather(zip_code: str):
    """Deterministic fake weather so the preview changes as you edit inputs."""
    seed = 0
    for ch in str(zip_code):                     # digit-accumulate (matches app.star)
        seed = seed * 10 + (ord(ch) - 48 if "0" <= ch <= "9" else 0)
    temp = 55 + (seed % 40)                       # 55-94 F
    conditions = ["SUNNY", "CLOUDY", "RAIN", "WINDY", "CLEAR"]
    cond = conditions[seed % len(conditions)]
    week = [(50 + (seed * (i + 3)) % 45) for i in range(5)]  # 5 daily highs
    return {"temp": temp, "cond": cond, "hi": temp, "lo": temp - 12, "week": week}


COND_COLOR = {
    "SUNNY": "yellow", "CLEAR": "yellow", "CLOUDY": "gray",
    "RAIN": "blue", "WINDY": "cyan",
}


# --- page 1: current conditions ---------------------------------------------
@app.page("current", title="Current")
def render_current(c, inputs):
    wx = get_weather(inputs["zip"])
    city = str(inputs.get("city", "")).upper()

    c.fill("black")
    # header bar
    c.rect(0, 0, c.width - 1, 8, fill="white")
    c.text(city or "WEATHER", c.width // 2, 1, font="5x7", color="black", align="center")

    # big temperature
    c.text(f"{wx['temp']}", 4, 12, font="16x20", color=COND_COLOR.get(wx["cond"], "white"))
    c.text("F", 40, 12, font="7x12", color="white")

    # condition + hi/lo on the right
    c.text(wx["cond"], c.width - 4, 12, font="7x12", color=COND_COLOR.get(wx["cond"], "white"), align="right")
    c.text(f"H{wx['hi']} L{wx['lo']}", c.width - 4, 24, font="5x7", color="gray", align="right")


# --- page 2: the week -------------------------------------------------------
@app.page("week", title="This Week")
def render_week(c, inputs):
    wx = get_weather(inputs["zip"])
    days = ["MON", "TUE", "WED", "THU", "FRI"]

    c.fill("black")
    c.rect(0, 0, c.width - 1, 8, fill="green")
    c.text("5-DAY", c.width // 2, 1, font="5x7", color="black", align="center")

    col_w = c.width // 5
    for i, (day, hi) in enumerate(zip(days, wx["week"])):
        x = i * col_w + col_w // 2
        c.text(day, x, 11, font="4x5", color="gray", align="center")
        c.text(f"{hi}", x, 19, font="6x8", color="white", align="center")
