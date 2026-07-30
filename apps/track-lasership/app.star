TRACKING_URL = "https://t.lasership.com/Track/"


MONTHS = [
    "",
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
]


def _draw_message(c, line1, line2, color):
    c.fill("black")

    c.text(
        str(line1).upper(),
        32,
        7,
        font = "5x7",
        color = color,
        align = "center",
    )

    c.text(
        str(line2).upper(),
        32,
        18,
        font = "5x7",
        color = color,
        align = "center",
    )


def _format_date(date_text):
    # Expected format: 2026-07-30
    if date_text == None or len(date_text) < 10:
        return "UNKNOWN"

    month = int(date_text[5:7])
    day = int(date_text[8:10])

    if month < 1 or month > 12:
        return "UNKNOWN"

    return MONTHS[month] + " " + str(day)


def _shorten_event(event_text):
    if event_text == None or event_text == "":
        return "NO EVENT"

    text = str(event_text).upper()
    replacements = [
        ["OUT FOR DELIVERY", "OUT FOR DEL."],
        ["DELIVERED", "DELIVERED"],
        ["LOADED ONTO VEHICLE", "LOADED"],
        ["ARRIVED AT FINAL SERVICING FACILITY", "AT LOCAL FAC."],
        ["ARRIVED AT FACILITY", "AT FACILITY"],
        ["LABEL CREATED", "LABEL MADE"],
        ["ORIGIN SCAN", "ORIGIN SCAN"],
        ["PACKAGE RECEIVED", "RECEIVED"],
        ["DELIVERY ATTEMPTED", "ATTEMPTED"],
        ["IN TRANSIT", "IN TRANSIT"],
    ]

    for replacement in replacements:
        if text == replacement[0]:
            text = replacement[1]
            break

    # A 4x5 font fits about 15 characters across 64 pixels.
    if len(text) > 15:
        text = text[:15]

    return text


def tracking(c, ctx):
    c.fill("black")
    
    tracking_number = str(
        ctx.inputs.get("trackingnumber", "")
    ).strip()
    
    if tracking_number == "None":
        _draw_message(
            c,
            "ENTER",
            "TRACKING",
            "amber",
        )
        return

    url = TRACKING_URL + tracking_number + "/json"

    response = http.get(
        url,
        headers = {
            "Accept": "application/json",
        },
        ttl_seconds = 300,
    )

    if response["status_code"] != 200:
        _draw_message(
            c,
            "API ERROR",
            str(response["status_code"]),
            "red",
        )
        return

    data = response["json"]

    estimated_date = data.get("EstimatedDeliveryDate", "")
    events = data.get("Events", [])

    delivery_date = _format_date(estimated_date)
    event_text = "NO EVENTS"

    if len(events) > 0:
        newest_event = events[0]

        event_text = newest_event.get(
            "EventShortText",
            newest_event.get(
                "EventLabel",
                newest_event.get("EventType", "NO EVENT"),
            ),
        )

        event_text = _shorten_event(event_text)

    # Top heading
    c.text(
        "DELIVERY ETA",
        32,
        0,
        font = "4x5",
        color = "green",
        align = "center",
    )

    # Large estimated delivery date
    c.text(
        delivery_date.upper(),
        32,
        8,
        font = "8x12",
        color = "amber",
        align = "center",
    )

    # Latest tracking event
    c.text(
        event_text.upper(),
        32,
        26,
        font = "4x5",
        color = "white",
        align = "center",
    )