# ROCKET COUNTDOWN DISPLAY
# Live Cape Canaveral launch tracker
# 192x32 LED DISPLAY


API_URL = "https://ll.thespacedevs.com/2.3.0/launches/upcoming/?limit=50"


GO_WINDOW_SECONDS = 86400

# Keep launched mission displayed for 1 hour
POST_LAUNCH_BUFFER = 3600


# Leave blank for live API status.
# Test values:
# GO, HOLD, SCRUB, DELAY, SCHEDULED, LAUNCHED, OFFLINE

TEST_STATUS = ""



def pad2(value):

    text = str(value)

    if len(text) < 2:
        return "0" + text

    return text



def days_before_month(year, month):

    month_days = [
        0,
        31,
        59,
        90,
        120,
        151,
        181,
        212,
        243,
        273,
        304,
        334
    ]

    days = month_days[month - 1]

    if month > 2 and year % 4 == 0:
        days += 1

    return days



def iso_to_unix(date):

    year = int(date[0:4])
    month = int(date[5:7])
    day = int(date[8:10])

    hour = int(date[11:13])
    minute = int(date[14:16])
    second = int(date[17:19])


    days = (year - 1970) * 365

    days += (year - 1969) // 4

    days += days_before_month(
        year,
        month
    )

    days += day - 1


    return (
        days * 86400
        + hour * 3600
        + minute * 60
        + second
    )



def short_company(name):

    upper = name.upper()


    if "SPACEX" in upper:
        return "SPACEX"


    if "BLUE ORIGIN" in upper:
        return "BLUE"


    if "UNITED LAUNCH ALLIANCE" in upper:
        return "ULA"


    if "ROCKET LAB" in upper:
        return "ROCKET"


    if "NORTHROP" in upper:
        return "NORTHROP"


    if "ARIANESPACE" in upper:
        return "ARIANE"


    return name[:8].upper()



def short_rocket(name):

    upper = name.upper()


    if "FALCON HEAVY" in upper:
        return "FH"


    if "FALCON 9" in upper:
        return "F9"


    if "NEW GLENN" in upper:
        return "NG"


    if "VULCAN" in upper:
        return "VULCAN"


    if "ATLAS" in upper:
        return "ATLAS"


    return name[:6].upper()



def short_mission(name):

    lower = name.lower()


    if "starlink" in lower:
        return "STARLINK"


    if "dragon" in lower:
        return "DRAGON"


    if "crew" in lower:
        return "CREW"


    return name[:12].upper()



def short_pad(name):

    upper = name.upper()


    if "39A" in upper:
        return "LC-39A"


    if "40" in upper:
        return "LC-40"


    if "41" in upper:
        return "SLC-41"


    return name[:8].upper()



def get_trajectory(launch):

    text = ""


    if launch["mission"]:

        text = (
            launch["mission"]["name"]
            .lower()
        )


    if "starlink" in text:
        return "LEO 53.2"


    if "iss" in text:
        return "LEO 51.6"


    if "moon" in text:
        return "LUNAR"


    if "mars" in text:
        return "MARS"


    return "ORBIT"



def get_cape_launch(ctx):

    response = http.get(
        API_URL,
        ttl_seconds=600
    )


    if response["status_code"] != 200:

        return {
            "error": "NO DATA"
        }



    launches = response["json"]["results"]


    for launch in launches:


        if not launch["pad"]:
            continue



        location = (
            launch["pad"]
            ["location"]
            ["name"]
            .lower()
        )



        if (
            "cape canaveral" not in location
            and "kennedy" not in location
        ):
            continue



        launch_time = iso_to_unix(
            launch["net"]
        )



        # Keep launch visible for 1 hour after liftoff

        if launch_time + POST_LAUNCH_BUFFER < ctx.now.unix:

            continue



        return {
            "launch": launch
        }



    return {
        "error": "NO DATA"
    }

def build_display_data(ctx):

    result = get_cape_launch(ctx)


    if "error" in result:

        return {
            "provider": "",
            "rocket": "ROCKET",
            "mission": "NO DATA",
            "pad": "",
            "trajectory": "",
            "status": "OFFLINE",
            "countdown": "--"
        }



    launch = result["launch"]



    provider = "UNKNOWN"


    if launch["launch_service_provider"]:

        provider = short_company(
            launch["launch_service_provider"]["name"]
        )



    rocket = "ROCKET"


    if launch["rocket"]:

        config = (
            launch["rocket"]
            ["configuration"]
        )


        if config:

            rocket = short_rocket(
                config["full_name"]
            )



    mission = "LAUNCH"


    if launch["mission"]:

        mission = short_mission(
            launch["mission"]["name"]
        )



    pad = short_pad(
        launch["pad"]["name"]
    )



    trajectory = get_trajectory(
        launch
    )



    launch_time = iso_to_unix(
        launch["net"]
    )



    elapsed = ctx.now.unix - launch_time


    launched = False


    if elapsed >= 0:

        launched = True



    if launched:


        hours = elapsed // 3600


        minutes = (
            elapsed % 3600
        ) // 60


        seconds = elapsed % 60



        countdown = (
            "T+"
            + pad2(hours)
            + ":"
            + pad2(minutes)
            + ":"
            + pad2(seconds)
        )



    else:


        remaining = launch_time - ctx.now.unix



        days = remaining // 86400


        hours = (
            remaining % 86400
        ) // 3600


        minutes = (
            remaining % 3600
        ) // 60


        seconds = remaining % 60



        if days > 0:


            countdown = (
                "T-"
                + pad2(days)
                + ":"
                + pad2(hours)
                + ":"
                + pad2(minutes)
            )


        else:


            countdown = (
                "T-"
                + pad2(hours)
                + ":"
                + pad2(minutes)
                + ":"
                + pad2(seconds)
            )



    status = "SCHEDULED"



    if launched:

        status = "LAUNCHED"



    else:


        state = ""


        if launch["status"]:

            state = (
                launch["status"]
                ["name"]
                .lower()
            )



        if "scrub" in state:

            status = "SCRUB"



        elif "hold" in state:

            status = "HOLD"



        elif "delay" in state:

            status = "DELAY"



        elif (
            "go" in state
            and launch_time - ctx.now.unix <= GO_WINDOW_SECONDS
        ):

            status = "GO"



    if TEST_STATUS != "":

        status = TEST_STATUS



    return {
        "provider": provider,
        "rocket": rocket,
        "mission": mission,
        "pad": pad,
        "trajectory": trajectory,
        "status": status,
        "countdown": countdown
    }




def get_status_color(status):


    if status == "SCRUB":

        return "red"



    if status == "OFFLINE":

        return "red"



    if status == "HOLD":

        return "yellow"



    if status == "DELAY":

        return "yellow"



    if status == "LAUNCHED":

        return "blue"



    return "green"





def draw_header(c, data):

    if data["status"] == "OFFLINE":

        return


    header = (
        data["rocket"]
        + " "
        + data["mission"]
        + " | "
        + data["provider"]
    )


    c.text_center(
        header,
        1,
        font="5x7",
        color="white"
    )



    c.text_center(
        header,
        1,
        font="5x7",
        color="white"
    )





def draw_countdown(c, data):


    c.text_center(
        data["countdown"],
        12,
        font="6x8",
        color="yellow"
    )





def main(c, ctx):


    data = build_display_data(ctx)



    c.fill("black")



    draw_header(
        c,
        data
    )



    draw_countdown(
        c,
        data
    )



    # Flip bottom information every 20 seconds


    page = (
        ctx.now.unix // 20
    ) % 2



    if data["status"] == "OFFLINE":


        bottom = "NO DATA"



    elif page == 0:


        bottom = (
            data["pad"]
            + "     "
            + data["status"]
        )



    else:


        bottom = (
            data["trajectory"]
            + "     "
            + data["status"]
        )



    c.text_center(
        bottom,
        24,
        font="5x7",
        color=get_status_color(
            data["status"]
        )
    )