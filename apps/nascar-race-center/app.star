# NASCAR Race Center (192x32)
#
# Cup, O'Reilly or Truck Series, built around each car's own number art.
#
# PAGE 1, THE RACE CARD. During a race: flag, lap, stage and laps to go, stage
# winners, and the leader. After the checkered flag
# and through the end of Monday (or the next day for a midweek race): the winner, the margin, cautions and
# lead changes. During qualifying: the fastest car; after it, the pole and
# speed until the green flag. Otherwise: the next race, its date and local
# start time, TV, qualifying time and last week's winner.
#
# PAGES 2-6, THE FIELD. The Running order setting picks Full field (below),
# Top 20 (4 cars a page), Top 10 (2 a page, big numbers) or the Chase drivers
# (in running order, extras on the last pages); those add the last name,
# spots gained since the start and laps led.
# Full field, 8 cars a page (1 over 2, 3 over 4 ...): position, the
# number as painted on the car, and under the position the gap to the leader
# (1.734 under 10 s, 12.34 under 100 s; -2L laps down; OUT), PIT on pit road,
# then, until 3 green laps after a stop, the tire call of any car that went
# against the grain (2R, 2L - or 4T when most took two), and PEN (or BLK
# for a black flag) in red for 10 laps after NASCAR's lap notes log a
# penalty. Gaps turn
# green when a car has gained spots over the last 3 laps, amber for one spot
# lost, red for more. A green-and-white checkered flag marks each stage win
# (the flag that ends a stage). A stripe down the left
# edge carries the flag color. After the race the winner reads WIN!; during
# and after qualifying the pages show the order with each car's best lap
# (during it, the cars still to run follow as TO GO). On
# off days: the last race's top 8, the Chase, then season leaders (wins,
# top 5s, top 10s) and the points standings past the Chase - before the
# Chase, the drivers just outside the cut and how far behind it they are.
#
# PAGES 7-8, THE CHASE. Live points for the Chase drivers (or the points
# leaders before the Chase), points behind the leader, and during and after a
# race the points each driver has gained in it, in green.
#
# DATA. NASCAR's public feeds (cf.nascar.com), no key: the season race list
# (schedule and UTC session times), the live feed (one session at a time,
# any series), live points, pit stops (tires changed), lap-by-lap positions,
# and the weekend feed (official results, stage results, qualifying).
#
# NUMBER ART. NASCAR's car badges, cropped and shrunk to 15 px (race pages)
# and 13 px (headed pages), dark numbers on a gray plate, bundled as assets
# so no page spends a request on art. A number with no art gets a plain badge.

# Number art: asset file -> [width, height] (built from NASCAR car badges).
ART = {"c15_1.png":[11,15],"c13_1.png":[10,13],"c15_2.png":[20,15],"c13_2.png":[17,13],"c15_3.png":[21,15],"c13_3.png":[18,13],"c15_4.png":[16,15],"c13_4.png":[14,13],"c15_5.png":[19,15],"c13_5.png":[17,13],"c15_6.png":[21,15],"c13_6.png":[18,13],"c15_7.png":[15,15],"c13_7.png":[13,13],"c15_8.png":[17,15],"c13_8.png":[15,13],"c15_9.png":[19,15],"c13_9.png":[16,13],"c15_10.png":[20,15],"c13_10.png":[18,13],"c15_11.png":[21,14],"c13_11.png":[19,13],"c15_12.png":[21,12],"c13_12.png":[20,11],"c15_16.png":[21,15],"c13_16.png":[18,13],"c15_17.png":[21,13],"c13_17.png":[20,12],"c15_19.png":[20,15],"c13_19.png":[18,13],"c15_20.png":[21,15],"c13_20.png":[18,13],"c15_21.png":[19,15],"c13_21.png":[16,13],"c15_22.png":[21,10],"c13_22.png":[20,10],"c15_23.png":[21,11],"c13_23.png":[20,11],"c15_24.png":[21,15],"c13_24.png":[18,13],"c15_33.png":[21,14],"c13_33.png":[19,13],"c15_34.png":[21,13],"c13_34.png":[20,12],"c15_35.png":[21,11],"c13_35.png":[20,11],"c15_36.png":[21,14],"c13_36.png":[20,13],"c15_38.png":[21,12],"c13_38.png":[20,11],"c15_40.png":[21,12],"c13_40.png":[20,12],"c15_41.png":[21,13],"c13_41.png":[20,13],"c15_42.png":[21,13],"c13_42.png":[20,12],"c15_43.png":[21,13],"c13_43.png":[20,12],"c15_44.png":[21,14],"c13_44.png":[19,13],"c15_45.png":[21,11],"c13_45.png":[20,11],"c15_47.png":[20,15],"c13_47.png":[18,13],"c15_48.png":[21,14],"c13_48.png":[19,13],"c15_51.png":[21,13],"c13_51.png":[20,12],"c15_54.png":[21,12],"c13_54.png":[20,12],"c15_60.png":[21,13],"c13_60.png":[20,12],"c15_62.png":[21,14],"c13_62.png":[19,13],"c15_66.png":[21,13],"c13_66.png":[20,12],"c15_67.png":[21,12],"c13_67.png":[20,11],"c15_71.png":[20,15],"c13_71.png":[18,13],"c15_77.png":[21,12],"c13_77.png":[20,12],"c15_78.png":[21,13],"c13_78.png":[20,12],"c15_84.png":[21,13],"c13_84.png":[20,12],"c15_88.png":[21,14],"c13_88.png":[19,13],"c15_91.png":[20,15],"c13_91.png":[18,13],"c15_97.png":[21,14],"c13_97.png":[20,13],"c15_99.png":[21,12],"c13_99.png":[20,11],"o15_0.png":[17,15],"o13_0.png":[14,13],"o15_00.png":[21,11],"o13_00.png":[20,11],"o15_1.png":[15,15],"o13_1.png":[13,13],"o15_2.png":[19,15],"o13_2.png":[17,13],"o15_02.png":[21,11],"o13_02.png":[20,10],"o15_3.png":[21,15],"o13_3.png":[18,13],"o15_4.png":[16,15],"o13_4.png":[14,13],"o15_5.png":[14,15],"o13_5.png":[12,13],"o15_07.png":[21,13],"o13_07.png":[20,12],"o15_7.png":[17,15],"o13_7.png":[15,13],"o15_8.png":[21,15],"o13_8.png":[18,13],"o15_9.png":[20,15],"o13_9.png":[18,13],"o15_17.png":[20,15],"o13_17.png":[17,13],"o15_18.png":[21,15],"o13_18.png":[18,13],"o15_19.png":[19,15],"o13_19.png":[17,13],"o15_20.png":[21,14],"o13_20.png":[19,13],"o15_21.png":[21,14],"o13_21.png":[20,13],"o15_24.png":[21,13],"o13_24.png":[20,12],"o15_25.png":[21,14],"o13_25.png":[20,13],"o15_26.png":[21,13],"o13_26.png":[20,12],"o15_27.png":[21,15],"o13_27.png":[18,13],"o15_28.png":[21,13],"o13_28.png":[20,12],"o15_30.png":[21,13],"o13_30.png":[20,12],"o15_31.png":[21,14],"o13_31.png":[20,13],"o15_32.png":[21,13],"o13_32.png":[20,12],"o15_33.png":[21,14],"o13_33.png":[19,13],"o15_35.png":[21,13],"o13_35.png":[20,12],"o15_38.png":[21,15],"o13_38.png":[18,13],"o15_39.png":[21,14],"o13_39.png":[19,13],"o15_41.png":[21,13],"o13_41.png":[20,13],"o15_42.png":[21,13],"o13_42.png":[20,12],"o15_44.png":[21,14],"o13_44.png":[20,13],"o15_45.png":[21,14],"o13_45.png":[20,13],"o15_47.png":[21,13],"o13_47.png":[20,12],"o15_48.png":[21,14],"o13_48.png":[19,13],"o15_50.png":[21,14],"o13_50.png":[20,13],"o15_51.png":[21,13],"o13_51.png":[20,12],"o15_52.png":[21,14],"o13_52.png":[20,13],"o15_53.png":[21,13],"o13_53.png":[20,12],"o15_54.png":[21,12],"o13_54.png":[20,12],"o15_55.png":[21,12],"o13_55.png":[20,12],"o15_71.png":[18,15],"o13_71.png":[16,13],"o15_74.png":[21,14],"o13_74.png":[19,13],"o15_87.png":[21,11],"o13_87.png":[20,11],"o15_88.png":[21,14],"o13_88.png":[20,13],"o15_91.png":[20,15],"o13_91.png":[17,13],"o15_92.png":[21,14],"o13_92.png":[20,13],"o15_96.png":[21,10],"o13_96.png":[20,10],"o15_99.png":[21,10],"o13_99.png":[20,10],"t15_1.png":[14,15],"t13_1.png":[12,13],"t15_2.png":[16,15],"t13_2.png":[14,13],"t15_4.png":[20,15],"t13_4.png":[18,13],"t15_5.png":[19,15],"t13_5.png":[16,13],"t15_7.png":[14,15],"t13_7.png":[12,13],"t15_9.png":[19,15],"t13_9.png":[17,13],"t15_10.png":[20,15],"t13_10.png":[17,13],"t15_11.png":[21,14],"t13_11.png":[19,13],"t15_12.png":[20,15],"t13_12.png":[17,13],"t15_13.png":[21,14],"t13_13.png":[20,13],"t15_14.png":[20,15],"t13_14.png":[17,13],"t15_15.png":[21,13],"t13_15.png":[20,12],"t15_16.png":[21,15],"t13_16.png":[18,13],"t15_17.png":[21,13],"t13_17.png":[20,12],"t15_18.png":[19,15],"t13_18.png":[16,13],"t15_19.png":[18,15],"t13_19.png":[16,13],"t15_20.png":[21,13],"t13_20.png":[20,12],"t15_22.png":[21,14],"t13_22.png":[20,13],"t15_25.png":[21,13],"t13_25.png":[20,12],"t15_26.png":[21,14],"t13_26.png":[20,13],"t15_27.png":[21,11],"t13_27.png":[20,10],"t15_33.png":[21,14],"t13_33.png":[20,13],"t15_34.png":[21,13],"t13_34.png":[20,12],"t15_38.png":[21,13],"t13_38.png":[20,12],"t15_42.png":[21,13],"t13_42.png":[20,12],"t15_44.png":[21,14],"t13_44.png":[19,13],"t15_45.png":[21,13],"t13_45.png":[20,12],"t15_52.png":[21,15],"t13_52.png":[18,13],"t15_56.png":[21,13],"t13_56.png":[20,12],"t15_62.png":[21,14],"t13_62.png":[19,13],"t15_69.png":[21,12],"t13_69.png":[20,11],"t15_71.png":[21,15],"t13_71.png":[18,13],"t15_72.png":[21,13],"t13_72.png":[20,12],"t15_75.png":[21,15],"t13_75.png":[18,13],"t15_76.png":[21,14],"t13_76.png":[20,13],"t15_77.png":[21,13],"t13_77.png":[20,12],"t15_81.png":[18,15],"t13_81.png":[16,13],"t15_88.png":[21,13],"t13_88.png":[20,12],"t15_90.png":[21,12],"t13_90.png":[20,11],"t15_91.png":[21,14],"t13_91.png":[19,13],"t15_93.png":[21,12],"t13_93.png":[20,11],"t15_95.png":[21,12],"t13_95.png":[20,11],"t15_97.png":[21,15],"t13_97.png":[19,13],"t15_98.png":[21,13],"t13_98.png":[20,12],"t15_99.png":[21,13],"t13_99.png":[20,12],"c24_1.png":[18,24],"c24_12.png":[36,20],"c24_19.png":[32,24],"c24_2.png":[32,24],"c24_20.png":[34,24],"c24_21.png":[30,24],"c24_22.png":[36,18],"c24_23.png":[36,20],"c24_34.png":[36,22],"c24_38.png":[36,21],"c24_4.png":[25,24],"c24_45.png":[36,20],"c24_54.png":[36,21],"c24_6.png":[34,24],"c24_60.png":[36,22],"c24_67.png":[36,21],"c24_7.png":[24,24],"c24_77.png":[36,22],"c24_88.png":[35,24],"c24_9.png":[30,24],"c24_10.png":[32,24],"c24_11.png":[34,24],"c24_16.png":[34,24],"c24_17.png":[36,21],"c24_24.png":[35,24],"c24_3.png":[33,24],"c24_33.png":[36,24],"c24_35.png":[36,19],"c24_36.png":[36,23],"c24_40.png":[36,21],"c24_41.png":[36,23],"c24_42.png":[36,22],"c24_43.png":[36,23],"c24_44.png":[35,24],"c24_47.png":[33,24],"c24_48.png":[35,24],"c24_5.png":[30,24],"c24_51.png":[36,23],"c24_62.png":[35,24],"c24_66.png":[36,22],"c24_71.png":[33,24],"c24_78.png":[36,22],"c24_8.png":[27,24],"c24_84.png":[36,22],"c24_91.png":[32,24],"c24_97.png":[36,23],"c24_99.png":[36,20],"o24_0.png":[27,24],"o24_00.png":[36,20],"o24_02.png":[36,19],"o24_07.png":[36,22],"o24_1.png":[24,24],"o24_17.png":[32,24],"o24_18.png":[34,24],"o24_19.png":[31,24],"o24_2.png":[31,24],"o24_20.png":[36,24],"o24_21.png":[36,24],"o24_24.png":[36,21],"o24_25.png":[36,23],"o24_26.png":[36,21],"o24_27.png":[35,24],"o24_28.png":[36,22],"o24_3.png":[33,24],"o24_30.png":[36,22],"o24_31.png":[36,24],"o24_32.png":[36,22],"o24_33.png":[36,24],"o24_35.png":[36,21],"o24_38.png":[34,24],"o24_39.png":[35,24],"o24_4.png":[26,24],"o24_41.png":[36,23],"o24_42.png":[36,23],"o24_44.png":[36,23],"o24_45.png":[36,23],"o24_47.png":[36,21],"o24_48.png":[35,24],"o24_5.png":[22,24],"o24_50.png":[36,24],"o24_51.png":[36,23],"o24_52.png":[36,24],"o24_53.png":[36,22],"o24_54.png":[36,21],"o24_55.png":[36,21],"o24_7.png":[28,24],"o24_71.png":[31,24],"o24_74.png":[36,24],"o24_8.png":[32,24],"o24_87.png":[36,19],"o24_88.png":[36,23],"o24_9.png":[32,24],"o24_91.png":[32,24],"o24_92.png":[36,24],"o24_96.png":[36,18],"o24_99.png":[36,18],"t24_1.png":[23,24],"t24_10.png":[32,24],"t24_11.png":[35,24],"t24_12.png":[31,24],"t24_13.png":[36,23],"t24_14.png":[31,24],"t24_15.png":[36,22],"t24_16.png":[33,24],"t24_17.png":[36,22],"t24_18.png":[30,24],"t24_19.png":[30,24],"t24_2.png":[26,24],"t24_20.png":[36,23],"t24_22.png":[36,23],"t24_25.png":[36,22],"t24_26.png":[36,24],"t24_27.png":[36,19],"t24_33.png":[36,24],"t24_34.png":[36,23],"t24_38.png":[36,22],"t24_4.png":[33,24],"t24_42.png":[36,23],"t24_44.png":[35,24],"t24_45.png":[36,22],"t24_5.png":[31,24],"t24_52.png":[34,24],"t24_56.png":[36,23],"t24_62.png":[35,24],"t24_69.png":[36,20],"t24_7.png":[24,24],"t24_71.png":[34,24],"t24_72.png":[36,22],"t24_75.png":[33,24],"t24_76.png":[36,24],"t24_77.png":[36,22],"t24_81.png":[29,24],"t24_88.png":[36,22],"t24_9.png":[33,24],"t24_90.png":[36,20],"t24_91.png":[34,24],"t24_93.png":[36,20],"t24_95.png":[36,20],"t24_97.png":[35,24],"t24_98.png":[36,22],"t24_99.png":[36,22],"t24_6.png":[21,24],"t15_6.png":[13,15],"t13_6.png":[11,13],"t24_28.png":[36,20],"t15_28.png":[21,11],"t13_28.png":[20,11],"o24_43.png":[36,23],"o15_43.png":[21,13],"o13_43.png":[20,12]}


FEED = "https://cf.nascar.com/live/feeds/live-feed.json"
CACHER = "https://cf.nascar.com/cacher/"
USER_AGENT = "GDN-NascarRaceCenter (glance-led-panel)"

# dropdown value: [series id, art prefix, short name, Chase size]
# (the Chase is filled purely on points: no win-and-in)
SERIES = {
    "Cup Series": [1, "c", "CUP", 16],
    "O'Reilly Series": [2, "o", "O REILLY", 12],   # the font has no apostrophe
    "Truck Series": [3, "t", "TRUCKS", 10],
}
# dropdown value: [standard UTC offset, observes DST, label]
ZONES = {
    "Eastern": [-5, True, "ET"],
    "Central": [-6, True, "CT"],
    "Mountain": [-7, True, "MT"],
    "Arizona": [-7, False, "AZ"],
    "Pacific": [-8, True, "PT"],
    "Alaska": [-9, True, "AKT"],
    "Hawaii": [-10, False, "HT"],
}

INK = "#F4F7FF"
DIM = "#6E7A94"
GOLD = "#F2C14E"
UP = "#2ECC71"
SLIP = "#F2A33A"
DROP = "#FF4C4C"
CHASE_COLOR = "#FF2BD6"
NIGHT = "#1B2233"

MAKES = {"C": ["#F2C200", "#000000"], "F": ["#1F4FA8", "#FFFFFF"], "T": ["#D71920", "#FFFFFF"]}
FLAGS = {
    1: ["GREEN", "#2ECC71", "#000000"],
    2: ["CAUTION", "#F2C14E", "#000000"],
    3: ["RED", "#FF4C4C", "#FFFFFF"],
    4: ["FINAL", "#FFFFFF", "#000000"],
    5: ["WHITE", "#FFFFFF", "#000000"],
    8: ["PRE-RACE", "#6E7A94", "#000000"],
    9: ["FINAL", "#FFFFFF", "#000000"],
}
TAGS = {"PEN": "#FF4C4C", "BLK": "#FF4C4C", "PIT": GOLD, "4T": INK, "2R": "#7CC4FF", "2L": "#7CC4FF", "1T": "#7CC4FF", "3T": "#7CC4FF"}
# Past winners of the non-points events, shown on their spare pages (from
# NASCAR's weekend feeds; later years are added from the feeds at run time).
PAST = {
    "clash": [[2019, "48", "JIMMIE JOHNSON", "DAYTONA"], [2020, "20", "ERIK JONES", "DAYTONA"],
              [2021, "18", "KYLE BUSCH", "DAYTONA ROAD COURSE"], [2022, "22", "JOEY LOGANO", "THE COLISEUM"],
              [2023, "19", "MARTIN TRUEX JR", "THE COLISEUM"], [2024, "11", "DENNY HAMLIN", "THE COLISEUM"],
              [2025, "9", "CHASE ELLIOTT", "BOWMAN GRAY"], [2026, "60", "RYAN PREECE", "BOWMAN GRAY"]],
    "500": [[2019, "11", "DENNY HAMLIN", "DAYTONA"], [2020, "11", "DENNY HAMLIN", "DAYTONA"],
            [2021, "34", "MICHAEL MCDOWELL", "DAYTONA"], [2022, "2", "AUSTIN CINDRIC", "DAYTONA"],
            [2023, "47", "RICKY STENHOUSE JR", "DAYTONA"], [2024, "24", "WILLIAM BYRON", "DAYTONA"],
            [2025, "24", "WILLIAM BYRON", "DAYTONA"], [2026, "45", "TYLER REDDICK", "DAYTONA"]],
    "allstar": [[2019, "42", "KYLE LARSON", "CHARLOTTE"], [2020, "9", "CHASE ELLIOTT", "BRISTOL"],
                [2021, "5", "KYLE LARSON", "TEXAS"], [2022, "12", "RYAN BLANEY", "TEXAS"],
                [2023, "5", "KYLE LARSON", "NORTH WILKESBORO"], [2024, "22", "JOEY LOGANO", "NORTH WILKESBORO"],
                [2025, "20", "CHRISTOPHER BELL", "NORTH WILKESBORO"], [2026, "11", "DENNY HAMLIN", "DOVER"]],
}
PAST_THROUGH = 2026
PAST_LABEL = {"clash": "CLASH", "500": "DAYTONA 500", "allstar": "ALL-STAR"}
MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DAYS = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
DAY_NAMES = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
TRACK_TAILS = [" INTERNATIONAL RACEWAY", " INTERNATIONAL SPEEDWAY", " MOTOR SPEEDWAY", " SUPERSPEEDWAY", " MOTORSPORTS PARK", " RACEWAY PARK", " RACEWAY", " SPEEDWAY", " RACE TRACK", " INTERNATIONAL", " STADIUM"]
TRACK_NAMES = {"WORLD WIDE TECHNOLOGY": "GATEWAY"}   # the names fans use

CELL_W = 47
LEFT_W = 21           # race pages: position over gap, then the art
ART_GAP = 4           # clear space between the gap text and the number (LEDs bleed)
CHASE_LEFT = 25       # headed pages: rank + gain over the value, then the art
TIRE_GREEN_LAPS = 3   # a tire call stays up until the car has run this many
                      # green-flag laps after its stop (so through a caution
                      # and the restart)
PENALTY_LAPS = 10     # laps a PEN / BLK tag stays up after NASCAR's lap note
PENALTY_WORDS = ["PENALIZED", "PENALTY", "PASS THROUGH", "PASS-THROUGH", "DRIVE THROUGH", "DRIVE-THROUGH", "BLACK FLAG", "BLACK-FLAG"]
# dropdown value: [cars shown (0 = the Chase drivers), cars a page]
FIELD = {"Full field": [40, 8], "Top 20": [20, 4], "Top 10": [10, 2], "Chase drivers": [0, 4]}
ACCENTS = [["\u00c1", "A"], ["\u00c9", "E"], ["\u00cd", "I"], ["\u00d3", "O"], ["\u00da", "U"], ["\u00d1", "N"], ["\u00dc", "U"]]
STAR_W = 5            # a stage-win flag and the space after it
BIG_STAR_W = 8        # the same on the Top 10 cells
MOVE_LAPS = 3         # gain/loss is measured over this many laps

# ---------- small helpers ----------

def get(url, ttl):
    resp = http.get(url, headers = {"User-Agent": USER_AGENT}, ttl_seconds = ttl)
    if resp["status_code"] != 200:
        return None
    return resp["json"]

def pad(n, width):
    s = str(n)
    for _ in range(width):
        if len(s) < width:
            s = "0" + s
    return s

def fit(c, s, fonts, w):
    for f in fonts:
        if c.text_width(s, f) <= w:
            return f
    return fonts[-1]

def clip(c, s, font, w):
    if c.text_width(s, font) <= w:
        return s
    for n in range(len(s) - 1, 0, -1):
        if c.text_width(s[:n], font) <= w:
            return s[:n]
    return ""

def ordinal(n):
    if n % 100 in (11, 12, 13):
        return str(n) + "TH"
    return str(n) + {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")

def fit_text(c, options, w):
    for t in options:
        if c.text_width(t, "4x5") <= w:
            return t
    return options[-1]

def short_track(name):
    t = name.upper()
    for tail in TRACK_TAILS:
        if t.endswith(tail) and len(t) > len(tail):
            t = t[:len(t) - len(tail)]
            break
    return TRACK_NAMES.get(t, t)

def last_name(full):
    # "Tyler Reddick (C)" or "Sammy Smith(i)" -> REDDICK, SMITH; "Ricky
    # Stenhouse Jr." -> STENHOUSE; "Brenden Queen #" (rookie mark) -> QUEEN;
    # accents folded
    s = str(full or "").split("(")[0].replace("#", "").strip().upper()
    for p in ACCENTS:
        s = s.replace(p[0], p[1])
    w = [x for x in s.split(" ") if x != ""]
    for _ in range(3):
        if len(w) > 1 and w[-1].rstrip(".") in ("JR", "SR", "II", "III", "IV"):
            w = w[:-1]
    return w[-1] if len(w) else ""

def num(v):
    # NASCAR's points feed sometimes sends a total as text ("" or "3").
    if type(v) == "int":
        return v
    if type(v) == "float":
        return int(v)
    t = str(v or "").strip()
    return int(t) if t.isdigit() else 0

def make_key(m):
    # "Chv", "Chevrolet", "Frd", "Ford", "Tyt", "Toyota" -> C / F / T
    return str(m or "")[:1].upper()

# ---------- time ----------

def days_from_civil(y, m, d):
    if m <= 2:
        y -= 1
    era = y // 400
    yoe = y - era * 400
    mp = (m + 9) % 12
    doy = (153 * mp + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def civil(days):
    z = days + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    return [yoe + era * 400 + (1 if m <= 2 else 0), m, d]

def weekday(days):
    return (days + 3) % 7      # Monday = 0

def iso_minutes(s):
    # "2026-10-17T21:35:00" -> minutes since 1970 (no zone conversion)
    if s == None or len(s) < 16:
        return None
    return days_from_civil(int(s[0:4]), int(s[5:7]), int(s[8:10])) * 1440 + int(s[11:13]) * 60 + int(s[14:16])

def nth_sunday(y, m, n):
    first = days_from_civil(y, m, 1)
    return first + (6 - weekday(first)) % 7 + 7 * (n - 1)

def utc_offset(zone, utc_min):
    # Minutes to add to UTC for this zone at this moment (US DST rules:
    # 2 AM local on the second Sunday of March to the first Sunday of November).
    std = zone[0] * 60
    if not zone[1]:
        return std
    y = civil(utc_min // 1440)[0]
    start = nth_sunday(y, 3, 2) * 1440 + 120 - std
    end = nth_sunday(y, 11, 1) * 1440 + 120 - (std + 60)
    return std + 60 if utc_min >= start and utc_min < end else std

def et_to_utc(local_min):
    # NASCAR's race_date is Eastern wall-clock time.
    eastern = ZONES["Eastern"]
    guess = local_min + 300
    return local_min - utc_offset(eastern, guess)

def clock(local_min):
    h = (local_min // 60) % 24
    m = local_min % 60
    h12 = h % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ("" if m == 0 else ":" + pad(m, 2)) + (" AM" if h < 12 else " PM")

# ---------- schedule ----------

def race_list(year):
    j = get(CACHER + str(year) + "/race_list_basic.json", 3600)
    return j if type(j) == "dict" else {}

def race_start(r):
    # UTC minutes of the green flag: the schedule's race session when listed,
    # else the Eastern race_date.
    for e in r.get("schedule") or []:
        if e.get("run_type") == 3 and e.get("start_time_utc"):
            return iso_minutes(e["start_time_utc"])
    t = iso_minutes(r.get("race_date"))
    return et_to_utc(t) if t != None else None

def qual_start(r):
    for e in r.get("schedule") or []:
        if e.get("run_type") == 2 and e.get("start_time_utc"):
            return iso_minutes(e["start_time_utc"])
    return None

def season_races(s, year):
    rl = race_list(year).get("series_" + str(s), [])
    out = [r for r in rl if race_start(r) != None]
    return sorted(out, key = lambda r: race_start(r))

# ---------- the model: what to show right now ----------

def model(ctx):
    ser = SERIES.get(str(ctx.inputs.get("series", "Cup Series")), SERIES["Cup Series"])
    zone = ZONES.get(str(ctx.inputs.get("timezone", "Eastern")), ZONES["Eastern"])
    s = ser[0]
    now = ctx.now.unix // 60
    off = utc_offset(zone, now)
    year = ctx.now.year
    races = season_races(s, year)
    done = [r for r in races if r.get("winner_driver_id")]
    ahead = [r for r in races if not r.get("winner_driver_id")]
    cur = races
    if len([r for r in done if r.get("race_type_id", 1) == 1]) == 0:
        # New year, no points race yet (the Clash and Duels don't count): last
        # season stays up (champion, final standings, stats, last race) with
        # the new season's races next.
        before = season_races(s, year - 1)
        bdone = [r for r in before if r.get("winner_driver_id")]
        if len(bdone):
            year -= 1
            races = before
            done = bdone
    if len(ahead) == 0:
        nxt = season_races(s, year + 1)
        ahead = nxt[:1]
    m = {"s": s, "p": ser[1], "name": ser[2], "cut": ser[3], "zone": zone, "off": off, "now": now, "year": year,
         "last": done[-1] if len(done) else None, "next": ahead[0] if len(ahead) else None, "ahead": ahead, "state": "off",
         "chase_races": [r for r in races if num(r.get("playoff_round")) > 0], "done": done}

    lf = get(FEED, 60)
    if type(lf) == "dict" and lf.get("series_id") == s and lf.get("vehicles"):
        rt = lf.get("run_type")
        if rt == 3:
            m["live"] = lf
            m["state"] = "final" if lf.get("flag_state") in (4, 9) else "race"
            m["race"] = [r for r in races + cur if r["race_id"] == lf.get("race_id")]
            m["race"] = m["race"][0] if len(m["race"]) else None
            if m["state"] == "final" and m["race"] != None and not ends_passed(m, m["race"]):
                return m
            if m["state"] == "race":
                return m
        elif rt == 2:
            m["live"] = lf
            m["race"] = m["next"]
            if lf.get("flag_state") in (4, 9):
                # Qualifying is over but the feed hasn't moved on: that's the
                # starting lineup.
                vs = sorted([v for v in lf["vehicles"] if (v.get("best_lap_time") or 0) > 0], key = lambda v: v.get("running_position") or 99)
                m["state"] = "lineup"
                m["unofficial"] = True
                m["qual"] = [{"pos": v.get("running_position"), "num": str(v.get("vehicle_number")), "make": make_key(v.get("vehicle_manufacturer")),
                              "time": v.get("best_lap_time") or 0, "speed": v.get("best_lap_speed") or 0, "name": last_name((v.get("driver") or {}).get("full_name"))} for v in vs]
                if len(m["qual"]) and m["race"] != None:
                    return m
            else:
                m["state"] = "qual"
                return m
    m.pop("live", None)
    last = m["last"]
    if last != None and not ends_passed(m, last):
        m["state"] = "final"
        m["race"] = last
        return m
    nx = m["next"]
    if nx != None:
        wf = get(CACHER + str(civil(race_start(nx) // 1440)[0]) + "/" + str(s) + "/" + str(nx["race_id"]) + "/weekend-feed.json", 600)
        q = qual_results(wf)
        # a lineup only counts in the race's own week (qualifying is never
        # earlier), so stale or early data can't jump the card ahead
        if len(q) and race_start(nx) - now <= 7 * 1440:
            m["state"] = "lineup"
            m["race"] = nx
            m["qual"] = q
            return m
    m["state"] = "off"
    m["race"] = nx
    return m

def ends_passed(m, r):
    # Results stay up from the checkered flag through the end of the next
    # local day, and a weekend race (Thursday-Sunday) through the end of
    # Monday.
    local = race_start(r) + utc_offset(m["zone"], race_start(r))
    day = local // 1440
    wd = weekday(day)
    end = day + 1
    if wd >= 3:
        end = day + 7 - wd
    until = (end + 1) * 1440
    return m["now"] + m["off"] >= until

def weekend(m, r):
    if r == None:
        return None
    y = civil(race_start(r) // 1440)[0]
    return get(CACHER + str(y) + "/" + str(m["s"]) + "/" + str(r["race_id"]) + "/weekend-feed.json", 300)

def weekend_race(wf):
    if type(wf) != "dict":
        return None
    w = wf.get("weekend_race")
    if type(w) == "list":
        return w[0] if len(w) else None
    return w

def qual_results(wf):
    if type(wf) != "dict":
        return []
    for run in wf.get("weekend_runs") or []:
        if run.get("run_type") == 2 and len(run.get("results") or []):
            res = sorted(run["results"], key = lambda x: x.get("finishing_position") or 99)
            return [{"pos": x.get("finishing_position"), "num": str(x.get("car_number")), "make": make_key(x.get("manufacturer")),
                     "time": x.get("best_lap_time") or 0, "speed": x.get("best_lap_speed") or 0, "name": last_name(x.get("driver_name"))} for x in res if (x.get("finishing_position") or 0) > 0]
    return []

def points(m, rid):
    j = get(CACHER + "live/series_" + str(m["s"]) + "/" + str(rid) + "/live-points.json", 120)
    return j if type(j) == "list" else []

# ---------- rows for the field pages ----------

def rows_race(m, finished = False):
    # finished: the final order only - no tire calls, movement or penalties,
    # so their feeds aren't fetched (GDN allows 8 uncached fetches a page)
    lf = m["live"]
    rid = lf["race_id"]
    lap = lf.get("lap_number") or 0
    pits = None if finished else get(CACHER + "live/series_" + str(m["s"]) + "/" + str(rid) + "/live-pit-data.json", 60)
    last_stop = {}
    for p in pits if type(pits) == "list" else []:
        n = str(p.get("vehicle_number"))
        lc = p.get("lap_count") or 0
        if lc > 0 and lc <= lap and (n not in last_stop or lc > last_stop[n].get("lap_count")):
            last_stop[n] = p
    moves = {}
    lt = None if finished else get(CACHER + "live/series_" + str(m["s"]) + "/" + str(rid) + "/lap-times.json", 60)
    green = {}
    for f in (lt.get("flags") or []) if type(lt) == "dict" else []:
        if f.get("FlagState") == 1:
            green[f.get("LapsCompleted")] = True
    for d in (lt.get("laps") or []) if type(lt) == "dict" else []:
        laps = d.get("Laps") or []
        if len(laps) > MOVE_LAPS:
            moves[str(d.get("Number"))] = (laps[-1 - MOVE_LAPS].get("RunningPos") or 0) - (laps[-1].get("RunningPos") or 0)
    stars = stage_stars_live(m, rid, lf)
    pens = penalties(m, rid, lap) if lap > 0 and not finished else {}
    out = []
    # Now and then the feed adds the leader's own clock to the lead lap (1st
    # 4688.396, 2nd 4688.768): the gap is what's over the leader.
    base = max([v.get("delta") or 0 for v in lf["vehicles"] if v.get("running_position") == 1] or [0])
    # Cars with no position (the Clash's heat-race non-qualifiers) aren't in it.
    for v in sorted([v for v in lf["vehicles"] if (v.get("running_position") or 0) > 0], key = lambda v: v.get("running_position")):
        n = str(v.get("vehicle_number"))
        d = v.get("delta") or 0
        if base > 0 and d >= base:
            d -= base
        st = v.get("status")
        # laps led from lap 1 on (the pole sitter is listed as leading lap 0
        # before the green flag)
        led = 0
        for s in v.get("laps_led") or []:
            led += max(0, min(s.get("end_lap") or 0, lap) - max(s.get("start_lap") or 0, 1) + 1)
        r = {"pos": v.get("running_position"), "num": n, "make": make_key(v.get("vehicle_manufacturer")), "move": moves.get(n, 0),
             "stars": stars.get(n, []), "tag": "", "name": last_name((v.get("driver") or {}).get("full_name")),
             "led": led, "start": v.get("starting_position") or 0}
        if lap == 0:
            r["gap"] = ""
        elif st == 3 or st == 6:
            r["gap"] = "OUT"
        elif r["pos"] == 1:
            r["gap"] = "LEAD"
        elif d < 0:
            r["gap"] = "-" + str(int(-d)) + "L"
        else:
            r["gap"] = secs_text(d)
        if st == 2:
            r["tag"] = "PIT"
        elif n in pens:
            r["tag"] = pens[n]
        elif n in last_stop and green_laps_since(green, last_stop[n]["lap_count"], lap) < TIRE_GREEN_LAPS:
            r["tire"] = tire_call(last_stop[n])
        out.append(r)
    # Tire calls only for the cars that went against the grain: when most of
    # the cars with a fresh stop took the same call (usually four), those keep
    # their gap and only the others are tagged. A lone call is always tagged.
    calls = [r["tire"] for r in out if r.get("tire", "") != ""]
    common = ""
    for k in ["4T", "2R", "2L", "3T", "1T"]:
        if len(calls) > 1 and len([x for x in calls if x == k]) * 2 > len(calls):
            common = k
    for r in out:
        if r.get("tire", "") != "" and r["tire"] != common:
            r["tag"] = r["tire"]
    return most_led(out)

def most_led(rows):
    # the most laps led (ties all get it): their LED count shows in gold
    top = max([r.get("led", 0) for r in rows] or [0])
    for r in rows:
        r["most_led"] = top > 0 and r.get("led", 0) == top
    return rows

def penalties(m, rid, lap):
    # {car number: "PEN" or "BLK"} for penalties NASCAR's lap notes logged in
    # the last PENALTY_LAPS laps. A note reads like "#45 penalized for too fast
    # entering pit road": the car numbers before the penalty words in that
    # sentence are the ones penalized.
    y = civil(m["now"] // 1440)[0]
    j = get(CACHER + str(y) + "/" + str(m["s"]) + "/" + str(rid) + "/lap-notes.json", 60)
    out = {}
    if type(j) != "dict":
        return out
    laps = j.get("laps") or {}
    for k in laps:
        if not str(k).isdigit() or lap - int(k) > PENALTY_LAPS or int(k) > lap:
            continue
        for note in laps[k] or []:
            for sentence in str(note.get("Note") or "").upper().split(". "):
                at = -1
                for w in PENALTY_WORDS:
                    i = sentence.find(w)
                    if i >= 0 and (at < 0 or i < at):
                        at = i
                if at < 0:
                    continue
                tag = "BLK" if "BLACK" in sentence else "PEN"
                for word in sentence[:at].replace(",", " ").split(" "):
                    if word.startswith("#") and word[1:].isdigit():
                        out[word[1:]] = tag
    return out

def green_laps_since(green, stop_lap, lap):
    n = 0
    for k in range(stop_lap + 1, lap + 1):
        if green.get(k):
            n += 1
    return n

def tire_call(p):
    t = [p.get("left_front_tire_changed"), p.get("left_rear_tire_changed"), p.get("right_front_tire_changed"), p.get("right_rear_tire_changed")]
    n = len([x for x in t if x])
    if n == 4:
        return "4T"
    if n == 0:
        return ""          # no tires changed: nothing to call
    if n == 2 and t[0] and t[1]:
        return "2L"
    if n == 2 and t[2] and t[3]:
        return "2R"
    return str(n) + "T"

def stage_stars_live(m, rid, lf):
    # Stage wins so far, from live points; only stages that have ended count.
    cur = (lf.get("stage") or {}).get("stage_num") or 1
    out = {}
    for p in points(m, rid):
        for k in range(1, cur):
            if p.get("stage_" + str(k) + "_winner"):
                out.setdefault(str(p.get("car_number")), []).append(k)
    return out

def secs_text(s):
    # 1.734 under 10 s, 12.34 under 100 s, 123.4 beyond: all fit 21 px
    if s < 10:
        n = int(s * 1000 + 0.5)
        return str(n // 1000) + "." + pad(n % 1000, 3)
    if s < 100:
        n = int(s * 100 + 0.5)
        return str(n // 100) + "." + pad(n % 100, 2)
    n = int(s * 10 + 0.5)
    return str(n // 10) + "." + str(n % 10)

def official_results(wr):
    # During race week the results come prefilled with the entry list (every
    # finishing position 0, cautions and lead changes 0) until NASCAR posts
    # the official order a few minutes after the checkered flag.
    res = (wr.get("results") or []) if wr != None else []
    return [x for x in res if (x.get("finishing_position") or 0) > 0]

def rows_final(m):
    # The finished race: official results once posted, else the live feed's
    # final order - the current feed, or the race's archived copy once the
    # live feed has moved on (the weekend feed can go blank after the race).
    wr = weekend_race(weekend(m, m["race"]))
    res = official_results(wr)
    lf = m.get("live")
    if len(res) == 0 and lf == None and m["race"] != None:
        af = get(CACHER + "live/series_" + str(m["s"]) + "/" + str(m["race"]["race_id"]) + "/live-feed.json", 300)
        if type(af) == "dict" and af.get("race_id") == m["race"]["race_id"] and af.get("vehicles"):
            lf = af
    if len(res) == 0 and lf != None:
        rows = rows_race(dict(m, live = lf), True)
        for r in rows:
            r["tag"] = ""
            r["move"] = 0
            if r["gap"] == "LEAD":
                r["gap"] = "WIN!"
        return final_star(m, rows)
    stars = {}
    for sr in (wr.get("stage_results") or []) if wr != None else []:
        for x in sr.get("results") or []:
            if x.get("finishing_position") == 1:
                stars.setdefault(str(x.get("car_number")), []).append(sr.get("stage_number"))
    # The official results sometimes leave a lead-lap car's gap at 0: the
    # race's archived live feed has it. It can also leave diff_laps at 0 for a
    # car laps down (#33 Martinsville 2026: 498 of 500) - laps_completed has it.
    lead = max([num(x.get("laps_completed")) for x in res if x.get("finishing_position") == 1] or [0])

    def laps_down(x):
        d = num(x.get("diff_laps"))
        if d <= 0 and lead > 0 and num(x.get("laps_completed")) > 0:
            d = lead - num(x.get("laps_completed"))
        return int(d) if d > 0 else 0

    fix = {}
    if len([x for x in res if (x.get("finishing_position") or 0) > 1 and not laps_down(x) and not (x.get("diff_time") or 0)]):
        af = get(CACHER + "live/series_" + str(m["s"]) + "/" + str(m["race"]["race_id"]) + "/live-feed.json", 300)
        for v in (af.get("vehicles") or []) if type(af) == "dict" else []:
            if (v.get("delta") or 0) > 0:
                fix[str(v.get("vehicle_number"))] = v["delta"]
    out = []
    for x in sorted([x for x in res if (x.get("finishing_position") or 0) > 0], key = lambda x: x.get("finishing_position")):
        n = str(x.get("car_number"))
        r = {"pos": x.get("finishing_position"), "num": n, "make": make_key(x.get("car_make")), "move": 0, "stars": stars.get(n, []), "tag": "",
             "name": last_name(x.get("driver_fullname")), "led": x.get("laps_led") or 0, "start": x.get("starting_position") or 0}
        if r["pos"] == 1:
            r["gap"] = "WIN!"
        elif str(x.get("finishing_status", "Running")).upper() != "RUNNING":
            r["gap"] = "OUT"
        elif laps_down(x) > 0:
            r["gap"] = "-" + str(laps_down(x)) + "L"
        elif not (x.get("diff_time") or 0) and n in fix:
            r["gap"] = secs_text(fix[n])
        else:
            r["gap"] = secs_text((x.get("diff_time") or 0) / 1000.0)
        out.append(r)
    return final_star(m, out)

def final_star(m, rows):
    # The winner also won the final stage: a flag for it too.
    last = len([k for k in (1, 2, 3, 4) if num((m["race"] or {}).get("stage_" + str(k) + "_laps")) > 0]) or 1
    for r in rows:
        if r["gap"] == "WIN!" and last not in r["stars"]:
            r["stars"] = list(r["stars"]) + [last]
    return most_led(rows)

def rows_qual(m):
    if m["state"] == "qual":
        # timed cars in order, then the ones still to run by car number
        vs = m["live"]["vehicles"]
        timed = sorted([v for v in vs if (v.get("best_lap_time") or 0) > 0], key = lambda v: v.get("running_position") or 99)
        waiting = sorted([v for v in vs if not (v.get("best_lap_time") or 0) > 0], key = lambda v: int(num(v.get("vehicle_number"))))
        q = [{"pos": v.get("running_position"), "num": str(v.get("vehicle_number")), "make": make_key(v.get("vehicle_manufacturer")),
              "time": v.get("best_lap_time") or 0, "name": last_name((v.get("driver") or {}).get("full_name"))} for v in timed]
        q += [{"pos": "", "num": str(v.get("vehicle_number")), "make": make_key(v.get("vehicle_manufacturer")),
               "time": 0, "wait": True, "name": last_name((v.get("driver") or {}).get("full_name"))} for v in waiting]
    else:
        q = m["qual"]
    # "--" for a car without a time; nothing at all when nobody has one
    timed = len([x for x in q if x["time"] > 0]) > 0
    out = []
    for x in q:
        out.append({"pos": x["pos"], "num": x["num"], "make": x["make"], "move": 0, "stars": [], "tag": "", "name": x.get("name", ""),
                    "gap": secs_text(x["time"]) if x["time"] > 0 else ("TO GO" if x.get("wait") else ("--" if timed else "")), "pole": x["pos"] == 1})
    return out

# ---------- number art ----------

def number_art(c, m, num, make, x, y, size):
    key = m["p"] + str(size) + "_" + num + ".png"
    a = ART.get(key)
    if a != None:
        c.image(key, x, y + (size - a[1]) // 2)
        return a[0]
    col = MAKES.get(make, ["#3A4A66", "#FFFFFF"])
    w = c.text_width(num, "6x8") + 4
    c.rect(x, y + 2, x + w - 1, y + size - 3, fill = col[0])
    c.text(num, x + 2, y + (size - 8) // 2, font = "6x8", color = col[1])
    return w

def art_width(m, num, size):
    return ART.get(m["p"] + str(size) + "_" + num + ".png", [20, size])[0]

def star(c, x, y):
    # a stage win: a 4x4 green-and-white checkered flag
    for i in range(4):
        for j in range(4):
            c.pixel(x + i, y + j - 1, "#FFFFFF" if (i + j) % 2 == 0 else UP)

def big_star(c, x, y):
    # the stage-win flag on the Top 10 cells: 6x6, 2x2 squares
    for i in range(3):
        for j in range(3):
            c.rect(x + 2 * i, y + 2 * j, x + 2 * i + 1, y + 2 * j + 1, fill = "#FFFFFF" if (i + j) % 2 == 0 else UP)

def chip(c, x, y, text, bg, fg):
    w = c.text_width(text, "4x5")
    c.rect(x, y - 1, x + w + 3, y + 4, fill = bg)
    c.text(text, x + 2, y, font = "4x5", color = fg)
    return x + w + 4

# ---------- page 1: the race card ----------

def card_block(c, bg, lines):
    # lines: [[text, font, color], ...] centered in the left 48 px
    c.rect(0, 0, 47, 31, fill = bg)
    ys = [3, 14, 21]
    for i in range(len(lines)):
        t = lines[i]
        c.text(t[0], 24, ys[i], font = fit(c, t[0], [t[1], "5x7", "4x5"], 44), color = t[2], align = "center")

def card_middle(c, lines):
    x = 52
    ys = [1, 8, 16, 24]
    for i in range(len(lines)):
        t = lines[i]
        w = (c.width - x - 2) if i == 0 else (144 - x)
        if len(t) > 2:
            w = t[2]     # a line allowed to run under the right column's art
        c.text(clip(c, t[0], "4x5", w), x, ys[i], font = "4x5", color = t[1])

def card_right(c, m, num, label, color):
    if num == None:
        return
    w = art_width(m, num, 15)
    number_art(c, m, num, "", 169 - w // 2, 9, 15)
    c.text(label, 169, 26, font = "4x5", color = color, align = "center")

def race_title(r, lf):
    # The sponsor tail never fits: "BLACK'S TIRE 200 PRESENTED BY ..."
    name = (lf.get("run_name") if lf != None else None) or (r.get("race_name") if r != None else "") or ""
    name = name.upper().split(" PRESENTED BY ")[0].split(" POWERED BY ")[0].strip()
    return "CHAMPIONSHIP RACE" if name.endswith(" SERIES CHAMPIONSHIP RACE") else name

def track_of(r, lf):
    return short_track((lf.get("track_name") if lf != None else None) or (r.get("track_name") if r != None else "") or "")

def local_day(m, utc_min):
    t = utc_min + utc_offset(m["zone"], utc_min)
    return [t, weekday(t // 1440), civil(t // 1440)]

def card(c, ctx):
    m = model(ctx)
    st = m["state"]
    if st == "race":
        live_card(c, m)
    elif st == "final":
        final_card(c, m)
    elif st == "qual":
        qual_card(c, m)
    elif st == "lineup":
        lineup_card(c, m)
    else:
        next_card(c, m)

def live_card(c, m):
    lf = m["live"]
    f = FLAGS.get(lf.get("flag_state"), ["", DIM, "#000000"])
    lap = str(lf.get("lap_number") or 0) + "/" + str(lf.get("laps_in_race") or 0)
    card_block(c, f[1], [[f[0], "6x8", f[2]], ["LAP", "4x5", f[2]], [lap, "5x7b", f[2]]])
    stg = lf.get("stage") or {}
    togo = (stg.get("finish_at_lap") or 0) - (lf.get("lap_number") or 0)
    final_stage = (stg.get("finish_at_lap") or 0) >= (lf.get("laps_in_race") or 0)
    lapn = lf.get("lap_number") or 0
    sched = lf.get("laps_in_race") or 0
    if sched > 0 and lapn > sched:
        line3 = "OVERTIME"          # past the scheduled distance
    elif final_stage and (lf.get("flag_state") == 5 or (lf.get("laps_to_go") or 0) <= 0):
        line3 = "FINAL LAP"
    elif final_stage:
        line3 = str(lf.get("laps_to_go") or 0) + " TO GO"
    else:
        line3 = str(max(togo, 0)) + " TO GO IN STAGE " + str(stg.get("stage_num") or 1)
    stars = stage_stars_live(m, lf["race_id"], lf)
    wins = sorted([[k, n] for n in stars for k in stars[n]])
    line4 = ["S" + "  S".join([str(w[0]) + " #" + w[1] for w in wins]), GOLD] if len(wins) else ["", DIM]
    card_middle(c, [[race_title(m["race"], lf), INK], [track_of(m["race"], lf), DIM], [line3, INK], line4])
    lead = sorted(lf["vehicles"], key = lambda v: v.get("running_position") or 99)[0]
    card_right(c, m, str(lead.get("vehicle_number")), "LEADER", DIM)

def final_card(c, m):
    for y in range(0, 32, 4):
        for x in range(0, 48, 4):
            c.rect(x, y, x + 3, y + 3, fill = "#FFFFFF" if (x // 4 + y // 4) % 2 == 0 else "#202020")
    c.rect(6, 10, 41, 21, fill = "#000000")
    c.text("FINAL", 24, 13, font = "6x8", color = "#FFFFFF", align = "center")
    r = m["race"]
    lf = m.get("live")
    wr = weekend_race(weekend(m, r))
    src = wr if wr != None else (r or {})
    if len(official_results(wr)) == 0 and lf != None:
        # not official yet: the live feed's own counts (they match the
        # official ones), and the margin comes from 2nd place's gap below
        src = {"number_of_cautions": lf.get("number_of_caution_segments"), "number_of_lead_changes": lf.get("number_of_lead_changes")}
    rows = rows_final(m)
    margin = str(src.get("margin_of_victory") or "")
    if margin.startswith("."):
        margin = "0" + margin
    if margin == "" and len(rows) > 1 and rows[1]["gap"][:1].isdigit():
        margin = rows[1]["gap"]
    if margin != "" and not margin.replace(".", "").isdigit():
        # NASCAR writes "Under Caution" or "Caution" when it ends under yellow
        l3 = ["WON UNDER CAUTION", GOLD]
    else:
        l3 = ["WON BY " + margin + " SEC", GOLD] if margin != "" else ["", GOLD]
    cau = src.get("number_of_cautions")
    lc = src.get("number_of_lead_changes")
    finale = r != None and len(m["chase_races"]) > 0 and m["chase_races"][-1]["race_id"] == r["race_id"]
    champ = champion(m) if finale else None
    if champ != None and len(rows) and champ != rows[0]["num"]:
        # The title went to someone other than the race winner.
        l3 = ["#" + rows[0]["num"] + " " + l3[0], GOLD, 104]
    card_middle(c, [[race_title(r, lf), INK], [track_of(r, lf), DIM], l3])
    if cau != None and lc != None:
        # "4 <yellow flag> - 41 LEADS": cautions, then lead changes
        x = 52
        c.text(str(cau), x, 24, font = "4x5", color = DIM)
        x += c.text_width(str(cau), "4x5") + 3
        c.rect(x, 24, x, 28, fill = DIM)
        c.rect(x + 1, 24, x + 4, 26, fill = GOLD)
        c.text("- " + str(lc) + " LEADS", x + 9, 24, font = "4x5", color = DIM)
    if champ != None:
        card_right(c, m, champ, "CHAMPION", GOLD)
    else:
        card_right(c, m, rows[0]["num"] if len(rows) else None, "WINNER", GOLD)

def days_until(m, r):
    # whole local days from today to the race's day
    return local_day(m, race_start(r))[0] // 1440 - (m["now"] + m["off"]) // 1440

def countdown_card(c, m, r):
    # January to a week out: the days to the next season's first event, the
    # Daytona 500 too while the Clash comes first, the champion still on the
    # right.
    d = days_until(m, r)
    kind = event_kind(r)
    short = {"clash": "CLASH", "500": "THE 500"}.get(kind, "OPENER")
    card_block(c, NIGHT, [[str(d), "6x8", GOLD], ["DAY TO" if d == 1 else "DAYS TO", "4x5", INK], [short, "5x7b", INK]])
    t = local_day(m, race_start(r))
    md = MONTHS[t[2][1] - 1] + " " + str(t[2][2])
    l2 = fit_text(c, [track_of(r, None) + " - " + DAYS[t[1]] + " " + md, track_of(r, None) + " - " + md, md], 104)
    l3 = ["", GOLD]
    if kind != "500":
        big = [x for x in m["ahead"] if event_kind(x) == "500"]
        if len(big):
            d5 = days_until(m, big[0])
            l3 = ["DAYTONA 500 IN " + str(d5) + (" DAY" if d5 == 1 else " DAYS"), GOLD, 104]
    tv = str(r.get("television_broadcaster") or "").upper()
    l4 = [clock(t[0] % 1440) + " " + m["zone"][2] + (" ON " + tv if tv != "" else ""), DIM, 104]
    card_middle(c, [[race_title(r, None), INK], [l2, DIM, 104], l3, l4])
    champ = champion(m)
    if champ != None:
        card_right(c, m, champ, "CHAMPION", GOLD)

def next_card(c, m):
    r = m["race"]
    if season_done(m) and r != None and local_day(m, m["now"])[2][0] == local_day(m, race_start(r))[2][0] and days_until(m, r) > 7:
        countdown_card(c, m, r)
        return
    if season_done(m) and (r == None or race_start(r) - m["now"] > 14 * 1440):
        # Off-season: the champion until the next season's first race is two
        # weeks out.
        card_block(c, NIGHT, [["SEASON", "6x8", GOLD], ["", "4x5", INK], ["OVER", "5x7b", INK]])
        nxt = "SEE YOU NEXT SEASON"
        if r != None:
            t = local_day(m, race_start(r))
            nxt = "NEXT: " + track_of(r, None) + " " + MONTHS[t[2][1] - 1] + " " + str(t[2][2])
        champ = champion(m)
        card_middle(c, [[str(m["year"]) + " " + m["name"] + " CHAMPION", GOLD], ["", DIM], [nxt, INK, 104], ["", DIM]])
        if champ != None:
            card_right(c, m, champ, "CHAMPION", GOLD)
        return
    if r == None:
        card_block(c, NIGHT, [["SEASON", "6x8", GOLD], ["", "4x5", INK], ["OVER", "5x7b", INK]])
        card_middle(c, [["NASCAR " + m["name"], INK]])
        return
    t = local_day(m, race_start(r))
    card_block(c, NIGHT, [["NEXT", "6x8", GOLD], [DAY_NAMES[t[1]], "4x5", INK], [MONTHS[t[2][1] - 1] + " " + str(t[2][2]), "5x7b", INK]])
    tv = str(r.get("television_broadcaster") or "").upper()
    l3 = clock(t[0] % 1440) + " " + m["zone"][2] + (" ON " + tv if tv != "" else "")
    q = qual_start(r)
    l4 = ""
    if q != None:
        qt = local_day(m, q)
        l4 = "QUALIFYING " + DAYS[qt[1]] + " " + clock(qt[0] % 1440)
        if len(l4) > 18:
            l4 = "QUAL " + DAYS[qt[1]] + " " + clock(qt[0] % 1440)
    card_middle(c, [[race_title(r, None), INK], [track_of(r, None), DIM], [l3, INK], [l4, DIM]])
    last = m["last"]
    if last != None and last.get("winner_driver_id"):
        w = winner_number(m, last)
        if w != None:
            card_right(c, m, w, "LAST WIN", DIM)

def winner_number(m, r):
    wr = weekend_race(weekend(m, r))
    for x in (wr.get("results") or []) if wr != None else []:
        if x.get("finishing_position") == 1:
            return str(x.get("car_number"))
    return None

def lineup_card(c, m):
    r = m["race"]
    q = m["qual"]
    t = local_day(m, race_start(r))
    card_block(c, GOLD, [["POLE", "6x8", "#000000"], [DAYS[t[1]] + " " + clock(t[0] % 1440), "4x5", "#000000"], [m["zone"][2], "5x7b", "#000000"]])
    pole = q[0]
    spd = pole.get("speed") or 0
    if spd == 0 and pole["time"] == 0:
        # a lineup set without times (the Duels, a rained-out session)
        l3 = ["STARTING LINEUP SET", GOLD]
    else:
        l3 = ["POLE " + secs_text(pole["time"]) + " SEC" if spd == 0 else "POLE " + str(int(spd)) + "." + pad(int(spd * 1000 + 0.5) % 1000, 3) + " MPH", GOLD]
    tv = str(r.get("television_broadcaster") or "").upper()
    if m.get("unofficial"):
        # From the live feed right after the session, before NASCAR posts the
        # official results.
        l4 = ["QUALIFIED (UNOFFICIAL)", SLIP, 108]
    else:
        when = clock(t[0] % 1440) + (" ON " + tv if tv != "" else "")
        l4 = [fit_text(c, ["GREEN FLAG " + when, "GREEN " + when, when], 104), DIM, 104]
    card_middle(c, [[race_title(r, None), INK], [track_of(r, None), DIM], l3, l4])
    card_right(c, m, pole["num"], "POLE", GOLD)

def qual_card(c, m):
    lf = m["live"]
    card_block(c, GOLD, [["QUAL", "6x8", "#000000"], ["", "4x5", "#000000"], ["LIVE", "5x7b", "#000000"]])
    rows = rows_qual(m)
    waiting = len([r for r in rows if r["gap"] == "TO GO"])
    # the race's name: the feed's run name adds "KENNAMETAL POLE QUALIFYING"
    card_middle(c, [[race_title(m["race"], None) or race_title(None, lf), INK], [track_of(m["race"], lf), DIM], [str(len(rows) - waiting) + " CARS ON THE BOARD", INK],
                    [str(waiting) + " STILL TO RUN" if waiting else "", DIM]])
    if len(rows):
        card_right(c, m, rows[0]["num"], "FASTEST", GOLD)

# ---------- pages 2-6: the field ----------

def stripe(c, color):
    c.rect(0, 0, 1, 31, fill = color)

def gap_style(r):
    # [text, color] under the position: a tag (PIT, tires, PEN) or the gap
    if r["tag"] != "":
        return [r["tag"], TAGS.get(r["tag"], INK)]
    g = r["gap"]
    col = INK
    if g == "LEAD" or g == "WIN!" or r.get("pole"):
        col = GOLD
    elif g == "OUT" or g == "--" or g == "TO GO":
        col = DIM
    elif r["move"] > 0:
        col = UP
    elif r["move"] == -1:
        col = SLIP
    elif r["move"] < -1:
        col = DROP
    return [g, col]

def car_cell(c, m, r, x0, y, ax = None, dot = False):
    # a Chase driver's position (or TO GO, still to run in qualifying) in
    # the Chase color
    mark = dot and r.get("chase")
    c.text(str(r["pos"]), x0, y + 1, font = "5x7b", color = CHASE_COLOR if mark else INK)
    sx = x0 + c.text_width(str(r["pos"]), "5x7b") + 2
    for _ in r["stars"]:
        star(c, sx, y + 2)
        sx += STAR_W
    number_art(c, m, r["num"], r["make"], ax if ax != None else x0 + LEFT_W + ART_GAP, y, 15)
    g = gap_style(r)
    c.text(g[0], x0, y + 9, font = "4x5", color = CHASE_COLOR if mark and g[0] == "TO GO" else g[1])

def start_move(c, r, x, y):
    # spots gained (green) or lost (red) since the start
    if not r.get("start") or r["pos"] == "":
        return
    d = r["start"] - r["pos"]
    if d == 0:
        return
    arrow(c, x, y - 1, d > 0, UP if d > 0 else DROP)
    c.text(str(abs(d)), x + 6, y, font = "4x5", color = UP if d > 0 else DROP)

def wide_cell(c, m, r, x0, dot = True):
    # Top 10: two cars a page - big number, name, gap, spots gained, laps led
    aw = art_width(m, r["num"], 24)
    ax = x0 + 92 - aw
    number_art(c, m, r["num"], r["make"], ax, 4, 24)
    # a Chase driver's position (or TO GO) in the Chase color
    mark = dot and r.get("chase")
    c.text(str(r["pos"]), x0, 1, font = "6x8", color = CHASE_COLOR if mark else INK)
    x = x0 + (c.text_width(str(r["pos"]), "6x8") + 3 if r["pos"] != "" else 0)
    room = ax - 3 - x - BIG_STAR_W * len(r["stars"])
    f = fit(c, r["name"], ["5x7b", "4x5"], room)
    c.text(r["name"], x, 1 if f == "5x7b" else 2, font = f, color = INK)
    x += c.text_width(r["name"], f) + 2
    for _ in r["stars"]:
        big_star(c, x, 1)
        x += BIG_STAR_W
    g = gap_style(r)
    c.text(g[0], x0, 11, font = "5x7", color = CHASE_COLOR if mark and g[0] == "TO GO" else g[1])
    # spots gained since the start, then laps led
    start_move(c, r, x0, 23)
    if r.get("led"):
        lx = x0 + 22
        c.text("LED", lx, 23, font = "4x5", color = GOLD if r.get("most_led") else DIM)
        c.text(str(r["led"]), lx + 18, 23, font = "4x5", color = GOLD if r.get("most_led") else INK)

def tall_cell(c, m, r, x0, dot, w = 47):
    # Top 20 / Chase drivers: four cars a page - the field cell over the
    # name, spots gained since the start and laps led. A wider cell (fewer
    # cars on the page) puts the number at its right edge.
    car_cell(c, m, r, x0, 0, x0 + w - 3 - art_width(m, r["num"], 15) if w > 47 else None, dot)
    name = r.get("name", "")
    room = w - 2
    for _ in range(len(name)):
        if c.text_width(name, "4x5") <= room:
            break
        name = name[:-1]
    c.text(name, x0, 18, font = "4x5", color = INK)
    start_move(c, r, x0, 25)
    if r.get("led"):
        c.text("LED " + str(r["led"]), x0 + w - 3, 25, font = "4x5", color = GOLD if r.get("most_led") else DIM, align = "right")

def preseason(m):
    # Qualifying, the lineup or the race itself for a new season's first points
    # race: last season's standings no longer apply, and no one has points yet.
    r = m.get("race")
    return m["state"] in ("qual", "lineup", "race") and r != None and civil(race_start(r) // 1440)[0] > m["year"]

def chase_nums(m):
    if preseason(m):
        return []
    pts = standings(m)
    chase = [p for p in pts if p.get("is_in_chase")]
    return [str(p.get("car_number")) for p in (chase if len(chase) else pts[:m["cut"]])]

def field_mode(ctx):
    return FIELD.get(str(ctx.inputs.get("field", "Full field")), FIELD["Full field"])

def field_page(c, ctx, page, full = False):
    m = model(ctx)
    st = m["state"]
    if st == "off":
        stats_page(c, m, page)
        return
    if st == "race":
        rows = rows_race(m)
        stripe(c, FLAGS.get(m["live"].get("flag_state"), ["", DIM])[1])
    elif st == "final":
        rows = rows_final(m)
        stripe(c, "#FFFFFF")
    else:
        rows = rows_qual(m)
        stripe(c, GOLD)
    mode = [40, 8] if full else field_mode(ctx)
    # full field: the Chase drivers' positions in the Chase color
    qdot = mode[1] == 8 and not full
    if mode[1] != 8 or qdot:
        chase = chase_nums(m)
        for r in rows:
            r["chase"] = r["num"] in chase
        if mode[0] == 0 and len(chase) == 0:
            mode = FIELD["Top 20"]      # no one to follow until the first points are in
    if mode[1] != 8:
        if mode[0] == 0:
            # the Chase drivers in running order, spread evenly over the 5
            # pages with the extras on the last ones (Cup 3-3-3-3-4)
            rows = [r for r in rows if r["chase"]]
            base = len(rows) // 5
            light = 5 - len(rows) % 5      # pages with only `base` cars
            first = page * base + max(0, page - light)
            part = rows[first:first + base + (1 if page >= light else 0)]
        else:
            part = rows[:mode[0]][page * mode[1]:page * mode[1] + mode[1]]
    else:
        part = rows[page * 8:page * 8 + 8]
    if len(part) == 0:
        c.text("THE FIELD ENDS ON THE PAGE BEFORE", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    for i in range(len(part)):
        if mode[1] == 8:
            car_cell(c, m, part[i], 3 + (i // 2) * CELL_W, [0, 16][i % 2], None, qdot)
        elif mode[1] == 2 or len(part) <= 2:
            # Top 10, and any page of the Chase drivers with two cars or fewer
            wide_cell(c, m, part[i], 4 + i * 96, mode[0] != 0)
        else:
            w = max(47, 189 // len(part))
            tall_cell(c, m, part[i], 3 + i * w, mode[0] != 0, w)
    if mode[1] != 8 and len(part) == 2:
        c.rect(97, 2, 97, 29, fill = NIGHT)

# ---------- headed pages: season leaders, the Chase ----------

def headed_cells(c, m, items, cell_w = CELL_W):
    # items: [rank, rank color, small text beside the rank, its color, value, value color, number]
    for i in range(len(items)):
        it = items[i]
        x0 = 2 + (i // 2) * cell_w
        y = [6, 19][i % 2]
        # the number is centered in the room left over, keeping ART_GAP clear
        # pixels before the next column's text (the widest art is 20 px)
        lo = x0 + CHASE_LEFT - 1
        room = cell_w - CHASE_LEFT + 1 - ART_GAP
        ax = lo + max(0, (room - art_width(m, it[6], 13)) // 2)
        c.text(it[0], x0, y, font = "5x7b", color = it[1])
        if it[2] != "":
            mx = x0 + c.text_width(it[0], "5x7b") + 2
            if it[2][0] == "*":
                # a checkered flag for each stage win
                for k in range(len(it[2])):
                    star(c, mx + STAR_W * k, y + 2)
            elif it[2][0] in "UD":
                # places gained (U) or lost (D); the count is dropped when it
                # would run into the number (a 2-digit rank and a 10+ move)
                arrow(c, mx, y + 1, it[2][0] == "U", it[3])
                if mx + 6 + c.text_width(it[2][1:], "4x5") <= ax - 1:
                    c.text(it[2][1:], mx + 6, y + 1, font = "4x5", color = it[3])
            else:
                c.text(it[2], mx, y + 1, font = "4x5", color = it[3])
        c.text(it[4], x0, y + 8, font = "4x5", color = it[5])
        number_art(c, m, it[6], "", ax, y, 13)

def arrow(c, x, y, up, color):
    # 5 px wide, 3 px tall triangle: up for places gained, down for lost
    rows = [[2, 2], [1, 3], [0, 4]] if up else [[0, 4], [1, 3], [2, 2]]
    for i in range(3):
        c.rect(x + rows[i][0], y + 1 + i, x + rows[i][1], y + 1 + i, fill = color)

def header(c, label, color, title, rng):
    x = chip(c, 2, 1, label, color, "#000000") + 4
    c.text(title, x, 1, font = "4x5", color = INK)
    c.text(rng, c.width - 2, 1, font = "4x5", color = DIM, align = "right")

def points_live(m):
    # The race on now scores from the green flag: before it, NASCAR's live
    # points already count the starting order as a running order.
    return m["state"] == "final" or (m["state"] == "race" and (m["live"].get("lap_number") or 0) > 0)

def standings_rid(m):
    # Live points of the race on now, else of the last race run - skipping
    # exhibitions (Clash, Duels, All-Star: race_type_id 2), which score none.
    r = m.get("race")
    if points_live(m) and r != None and r.get("race_type_id", 1) == 1:
        return r["race_id"]
    pr = [d for d in m["done"] if d.get("race_type_id", 1) == 1]
    return pr[-1]["race_id"] if len(pr) else None

def prev_positions(m):
    # {driver id: points position} after the points race before the one the
    # standings come from, for the arrows.
    rid = standings_rid(m)
    cur = [r for r in m["done"] + ([m["race"]] if m.get("race") != None else []) if r["race_id"] == rid]
    out = {}
    if len(cur):
        prev = [r for r in m["done"] if r.get("race_type_id", 1) == 1 and race_start(r) < race_start(cur[0])]
        if len(prev):
            for q in points(m, prev[-1]["race_id"]):
                out[str(q.get("driver_id"))] = num(q.get("points_position"))
    return out

def cut_items(m, pts, inside, count):
    # Before the Chase: the last drivers in (cushion over the first one out,
    # green +) or the first ones out (behind the last one in, amber), with
    # green / red arrows for points places moved since the race before.
    cut = m["cut"]
    part = pts[max(0, cut - count):cut] if inside else pts[cut:cut + count]
    ref = num(pts[cut].get("points")) if inside and len(pts) > cut else (num(pts[cut - 1].get("points")) if len(pts) >= cut else 0)
    was = prev_positions(m)
    items = []
    for p in part:
        pos = num(p.get("points_position"))
        moved = was.get(str(p.get("driver_id")), pos) - pos
        mark = ("U" + str(moved)) if moved > 0 else (("D" + str(-moved)) if moved < 0 else "")
        d = num(p.get("points")) - ref
        val = "TIE" if d == 0 else (("+" if inside else "") + str(d))
        items.append([str(pos), INK, mark, UP if moved > 0 else DROP, val, UP if inside else SLIP, str(p.get("car_number"))])
    rng = (items[0][0] + "-" + items[-1][0]) if len(items) else ""
    return [items, rng]

def standings(m):
    rid = standings_rid(m)
    if rid == None:
        return []
    # A part-timer not entered in this race has a blank car number: give him
    # the number NASCAR's season points feed lists (the last one he raced),
    # and leave him out only if that's blank too.
    out = []
    blank = []
    for p in points(m, rid):
        if not p.get("is_points_eligible", True):
            continue
        if str(p.get("car_number") or "").strip() == "":
            blank.append(p)
        else:
            out.append(p)
    if len(blank):
        sp = get(CACHER + str(m["year"]) + "/" + str(m["s"]) + "/racinginsights-points-feed.json", 3600)
        found = {}
        for q in sp if type(sp) == "list" else []:
            n = str(q.get("car_no") or "").strip()
            if n != "":
                found[str(q.get("driver_id"))] = n
        for p in blank:
            d = str(p.get("driver_id"))
            if d in found:
                out.append(dict(p, car_number = found[d]))
    return sorted(out, key = lambda p: num(p.get("points_position")) or 999)

# ---------- the title: OUT, CHAMP, and at risk (amber) ----------
# Every series scores 55 for a win, 35, 34 ... for 2nd on, 10-1 for the top
# 10 of each stage but the last, and 1 for the fastest lap. So a race is worth
# at most 56 + 10 per scored stage, and at least 0.

def race_max(r):
    stages = len([k for k in (1, 2, 3, 4) if num(r.get("stage_" + str(k) + "_laps")) > 0])
    return 56 + 10 * max(stages - 1, 0)

def chase_left(m, skip_current):
    finished = [r["race_id"] for r in m["done"]]
    rem = [r for r in m["chase_races"] if r["race_id"] not in finished]
    if skip_current and m.get("race") != None:
        rem = [r for r in rem if r["race_id"] != m["race"]["race_id"]]
    return rem

def title_status(chase, rem):
    # {car: "OUT" or "CHAMP"}. OUT: even the most points in every race left,
    # with the leader scoring none, cannot pass the leader (a tie stays
    # alive). CHAMP: the leader is more than that far ahead of everyone. With
    # no races left the leader is the champion.
    out = {}
    if len(chase) == 0:
        return out
    cap = 0
    for r in rem:
        cap += race_max(r)
    ranked = title_order(chase)
    lead = num(ranked[0].get("points"))
    for p in ranked[1:]:
        if len(rem) and num(p.get("points")) + cap < lead:
            out[str(p.get("car_number"))] = "OUT"
    if len(ranked) == 1 or lead - num(ranked[1].get("points")) > cap or (len(rem) == 0 and not tie_unbroken(ranked)):
        out[str(ranked[0].get("car_number"))] = "CHAMP"
    return out

def title_order(ps):
    # Points, then the tiebreaker: most wins (NASCAR goes on to 2nds, 3rds...
    # but those need every race's results - more fetches than GDN allows).
    return sorted(ps, key = lambda p: (-num(p.get("points")), -num(p.get("wins"))))

def tie_unbroken(ranked):
    # the top two level on points AND wins: the app doesn't call it
    return len(ranked) > 1 and num(ranked[0].get("points")) == num(ranked[1].get("points")) and num(ranked[0].get("wins")) == num(ranked[1].get("wins"))

def prior_race(m):
    # The last race finished before the one on now (whose own points are the
    # live ones), for "places moved tonight".
    r = m.get("race")
    if r == None:
        return None
    before = [d for d in m["done"] if d["race_id"] != r["race_id"] and race_start(d) < race_start(r)]
    return before[-1] if len(before) else None

def season_done(m):
    finished = [r["race_id"] for r in m["done"]]
    return len(m["chase_races"]) > 0 and len([r for r in m["chase_races"] if r["race_id"] not in finished]) == 0

def champion(m):
    # The points leader once the last Chase race is in the books.
    pts = title_order([p for p in standings(m) if p.get("is_in_chase")])
    if len(pts) == 0 or tie_unbroken(pts):
        return None
    return str(pts[0].get("car_number"))

STATS = [["wins", "WINS"], ["top_5", "TOP 5S"], ["top_10", "TOP 10S"]]

def stats_page(c, m, page):
    pts = standings(m)
    if len(pts) == 0:
        c.text("SEASON STATS UNAVAILABLE", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    if page < len(STATS):
        key = STATS[page][0]
        ranked = sorted([p for p in pts if num(p.get(key)) > 0], key = lambda p: (-num(p.get(key)), num(p.get("points_position")) or 999))[:8]
        header(c, STATS[page][1], GOLD, str(m["year"]) + " " + m["name"], "")
        if len(ranked) == 0:
            c.text("NONE YET THIS SEASON", 96, 16, font = "4x5", color = DIM, align = "center")
            return
        vals = [num(p.get(key)) for p in ranked]
        # Chase drivers' places in the Chase color
        chase = chase_nums(m)
        items = []
        place = 0
        for i in range(len(ranked)):
            if i == 0 or vals[i] != vals[i - 1]:
                place = i + 1
            tied = len([v for v in vals if v == vals[i]]) > 1
            car = str(ranked[i].get("car_number"))
            items.append([str(vals[i]), GOLD if place == 1 else INK, "", INK, ("T" if tied else "") + ordinal(place),
                          CHASE_COLOR if car in chase else (GOLD if place == 1 else DIM), car])
        headed_cells(c, m, items)
        return
    in_chase = len([p for p in pts if p.get("is_in_chase")])
    first = in_chase or m["cut"]
    part = pts[first:first + 8]
    if in_chase:
        # Past the Chase the reset makes "behind the leader" meaningless, so
        # these show each driver's own total.
        header(c, "POINTS", GOLD, str(m["year"]) + " " + m["name"], str(first + 1) + "-" + str(first + len(part)))
        items = [[str(num(p.get("points_position"))), INK, "", INK, str(num(p.get("points"))), DIM, str(p.get("car_number"))] for p in part]
    else:
        # Before the Chase: points behind the last driver in (the cut line).
        ci = cut_items(m, pts, False, 8)
        items = ci[0]
        header(c, "POINTS", GOLD, "BEHIND " + ordinal(first) + " - THE CUT", ci[1])
    headed_cells(c, m, items)

def event_kind(r):
    n = str((r or {}).get("race_name") or "").upper()
    if "CLASH" in n:
        return "clash"
    if "DAYTONA 500" in n:
        return "500"
    if "ALL-STAR" in n and "OPEN" not in n:
        return "allstar"
    return None

def special_event(m):
    # The Clash, the Duels and the All-Star Race pay no points, so the pages
    # after their (short) field show past winners instead of the Chase: the
    # Clash's own, the Daytona 500's for the Duels, the All-Star Race's own.
    # [kind, field pages]
    r = m.get("race")
    if m["s"] != 1 or m["state"] == "off" or r == None or points_race(r):
        return None
    n = str(r.get("race_name") or "").upper()
    if "CLASH" in n:
        return ["clash", 3]
    if "DUEL" in n:
        return ["500", 3]
    if event_kind(r) == "allstar":
        return ["allstar", 4]
    return None

def past_winners(m, kind, before):
    # Newest first, years before `before`; seasons after the table come from
    # the race lists and that race's weekend feed.
    out = [e for e in PAST[kind] if e[0] < before]
    for y in range(PAST_THROUGH + 1, before):
        for r in season_races(1, y):
            if r.get("winner_driver_id") and event_kind(r) == kind:
                wr = weekend_race(weekend(dict(m, s = 1), r))
                for x in (wr.get("results") or []) if wr != None else []:
                    if x.get("finishing_position") == 1:
                        out.append([y, str(x.get("car_number")), str(x.get("driver_fullname") or "").upper(), track_of(r, None)])
    return sorted(out, key = lambda e: -e[0])

def winners_page(c, m, kind, k):
    ey = civil(race_start(m["race"]) // 1440)[0]
    past = past_winners(m, kind, ey)
    if k >= len(past):
        c.text("NO EARLIER WINNERS", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    e = past[k]
    header(c, PAST_LABEL[kind], GOLD, "PAST WINNERS", str(e[0]))
    w = number_art(c, m, e[1], "", 4, 11, 15)
    x = 4 + max(w, 20) + 6
    font = "6x8"
    for f in ["6x8", "5x7b", "4x5"]:
        font = f
        if c.text_width(e[2], f) <= c.width - x - 2:
            break
    c.text(e[2], x, 10, font = font, color = INK)
    c.text(e[3], x, 22, font = "4x5", color = DIM)

# ---------- the off-season: the champion ----------
# After the last Chase race (and its results) until the next season's first
# points race: the race card (season over), three pages for the champion -
# who, the season in numbers, where they won - then the final standings.

def champ_info(m):
    chase = title_order([p for p in standings(m) if p.get("is_in_chase")])
    if len(chase) < 2:
        return None
    if tie_unbroken(chase):
        return {"unbroken": True}
    ch = chase[0]
    sp = get(CACHER + str(m["year"]) + "/" + str(m["s"]) + "/racinginsights-points-feed.json", 3600)
    feed = {}
    for q in sp if type(sp) == "list" else []:
        if q.get("driver_id") == ch.get("driver_id"):
            feed = q
    first = str(feed.get("driver_first_name") or ch.get("first_name") or "").upper()
    last = str(feed.get("driver_last_name") or ch.get("last_name") or "").upper()
    if feed.get("driver_suffix"):
        last += " " + str(feed["driver_suffix"]).upper()
    if "(" in last:
        last = last[:last.find("(")].strip()   # live points tag names "(C)"
    return {"p": ch, "feed": feed, "first": first, "last": last.replace(" #", ""), "num": str(ch.get("car_number")),
            "margin": num(ch.get("points")) - num(chase[1].get("points")), "second": str(chase[1].get("car_number")), "p2": chase[1]}

def champ_page(c, m, k):
    ci = champ_info(m)
    if ci == None:
        c.text("STANDINGS UNAVAILABLE", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    if ci.get("unbroken"):
        c.text("TIED ON POINTS AND WINS", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    title = str(m["year"]) + " " + m["name"] + " CHAMPION"
    if k == 0:
        # who: number, name, make, the margin
        header(c, "CHAMPION", GOLD, title, "")
        w = number_art(c, m, ci["num"], "", 4, 11, 15)
        x = 4 + max(w, 20) + 6
        c.text(ci["first"], x, 9, font = "4x5", color = INK)
        font = "6x8"
        for f in ["6x8", "5x7b", "4x5"]:
            font = f
            if c.text_width(ci["last"], f) <= 110:
                break
        c.text(ci["last"], x, 16, font = font, color = GOLD)
        make = str(ci["feed"].get("manufacturer") or "").upper()
        c.text(make, c.width - 3, 9, font = "4x5", color = DIM, align = "right")
        if ci["margin"] == 0:
            # level on points: won on the wins tiebreaker
            c.text("TIEBREAK", c.width - 3, 17, font = "5x7b", color = INK, align = "right")
            c.text("WINS " + str(num(ci["p"].get("wins"))) + "-" + str(num(ci["p2"].get("wins"))) + " OVER #" + ci["second"], c.width - 3, 26, font = "4x5", color = DIM, align = "right")
        else:
            c.text("BY " + str(ci["margin"]) + " PTS", c.width - 3, 17, font = "5x7b", color = INK, align = "right")
            c.text("OVER #" + ci["second"], c.width - 3, 26, font = "4x5", color = DIM, align = "right")
    elif k == 1:
        # the season in numbers
        header(c, "CHAMPION", GOLD, "THE SEASON IN NUMBERS", "")
        f = ci["feed"]
        tiles = [[num(ci["p"].get("wins")), "WIN"], [num(ci["p"].get("top_5")), "TOP 5"], [num(ci["p"].get("top_10")), "TOP 10"],
                 [num(ci["p"].get("poles")), "POLE"], [num(f.get("laps_led")), "LAPS LED"],
                 [num(f.get("stage_1_wins")) + num(f.get("stage_2_wins")) + num(f.get("stage_3_wins")), "STAGE WIN"]]
        for t in tiles:
            if t[0] != 1 and not t[1].endswith("LED"):
                t[1] += "S"
        for i in range(len(tiles)):
            x = 3 + (i // 2) * 58
            y = [8, 20][i % 2]
            c.text(str(tiles[i][0]), x, y, font = "5x7b", color = GOLD)
            c.text(tiles[i][1], x + c.text_width(str(tiles[i][0]), "5x7b") + 4, y + 2, font = "4x5", color = INK)
    else:
        # where they won
        did = ci["p"].get("driver_id")
        wins = [r for r in m["done"] if points_race(r) and r.get("winner_driver_id") == did]
        header(c, "CHAMPION", GOLD, str(len(wins)) + (" WIN" if len(wins) == 1 else " WINS") + " IN " + str(m["year"]), "")
        if len(wins) == 0:
            c.text("CHAMPION WITHOUT A WIN", 96, 16, font = "4x5", color = INK, align = "center")
            return
        if len(wins) <= 3:
            # one win a line, with its date
            for i in range(len(wins)):
                t = local_day(m, race_start(wins[i]))
                c.text(track_of(wins[i], None), 3, 8 + 8 * i, font = "5x7b", color = INK)
                c.text(MONTHS[t[2][1] - 1] + " " + str(t[2][2]), c.width - 3, 9 + 8 * i, font = "4x5", color = GOLD, align = "right")
            return
        names = [track_of(r, None) for r in wins]
        # big type when the list fits in 3 lines, small (4 lines) otherwise
        for spec in [["5x7b", 8, 3], ["4x5", 6, 4]]:
            lines = [""]
            for n in names:
                t = n if lines[-1] == "" else lines[-1] + "  " + n
                if c.text_width(t, spec[0]) <= c.width - 6:
                    lines[-1] = t
                else:
                    lines.append(n)
            if len(lines) <= spec[2]:
                break
        for i in range(min(len(lines), spec[2])):
            c.text(lines[i], 3, 8 + spec[1] * i, font = spec[0], color = INK if i % 2 == 0 else GOLD)

def points_list_page(c, m, start):
    # off-season: season points from `start` (0-based), each driver's total
    pts = standings(m)
    part = pts[start:start + 8]
    if len(part) == 0:
        c.text("STANDINGS UNAVAILABLE", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    header(c, "POINTS", GOLD, str(m["year"]) + " " + m["name"], str(start + 1) + "-" + str(start + len(part)))
    headed_cells(c, m, [[str(num(p.get("points_position"))), INK, "", INK, str(num(p.get("points"))), DIM, str(p.get("car_number"))] for p in part])

def results_page(c, m):
    # Off days: the last race's top 8 - official results, or the race's
    # archived live feed.
    r = m["last"]
    rows = rows_final(dict(m, race = r, state = "final")) if r != None else []
    if len(rows) == 0:
        c.text("NO RESULTS YET", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    t = local_day(m, race_start(r))
    header(c, "LAST RACE", GOLD, track_of(r, None) + " " + MONTHS[t[2][1] - 1] + " " + str(t[2][2]), "1-" + str(min(8, len(rows))))
    # Chase drivers' places in the Chase color
    chase = chase_nums(m)
    items = []
    for x in rows[:8]:
        win = x["gap"] == "WIN!"
        items.append([str(x["pos"]), CHASE_COLOR if x["num"] in chase else INK, "*" * len(x["stars"]), GOLD, x["gap"], GOLD if win else DIM, x["num"]])
    headed_cells(c, m, items)

def chase_page(c, ctx, page):
    m = model(ctx)
    pts = standings(m)
    chase = [p for p in pts if p.get("is_in_chase")]
    label = "CHASE" if len(chase) else "POINTS"
    if preseason(m) and not points_live(m):
        header(c, "POINTS", GOLD, str(civil(race_start(m["race"]) // 1440)[0]) + " " + m["name"], "")
        c.text("NO POINTS YET", 96, 11, font = "5x7b", color = INK, align = "center")
        c.text("THE SEASON OPENS AT " + track_of(m["race"], None), 96, 22, font = "4x5", color = DIM, align = "center")
        return
    # Only the Chase drivers (16 Cup, 12 O'Reilly, 10 Trucks); before the
    # Chase, the points leaders.
    order = chase if len(chase) else pts[:m["cut"]]
    # The Chase split evenly over the two pages: 8 + 8 Cup, 6 + 6 O'Reilly,
    # 5 + 5 Trucks, in as many columns as that needs.
    per = min(8, (len(order) + 1) // 2)
    cols = (per + 1) // 2
    part = order[page * per:page * per + per]
    if len(part) == 0:
        c.text(("THE " + label + " FIELD IS ON THE PAGE BEFORE") if len(order) else "STANDINGS UNAVAILABLE", 96, 13, font = "4x5", color = DIM, align = "center")
        return
    live = points_live(m)
    before = {}
    prev = prior_race(m)
    if live and len(chase) and prev != None:
        prior = sorted([p for p in points(m, prev["race_id"]) if p.get("is_in_chase")], key = lambda p: -num(p.get("points")))
        for i in range(len(prior)):
            before[str(prior[i].get("car_number"))] = i + 1
    # Before the Chase: points places moved since the points race before.
    was = prev_positions(m) if len(chase) == 0 else {}
    official = {}
    risk = {}
    if len(chase):
        if m["state"] == "race" and live:
            # Official from the races already run; at risk (points behind in
            # amber) if the race ended now.
            done_pts = [p for p in points(m, m["last"]["race_id"]) if p.get("is_in_chase")] if m["last"] != None else []
            official = title_status(done_pts, chase_left(m, False))
            proj = title_status(chase, chase_left(m, True))
            for k in proj:
                if proj[k] == "OUT" and official.get(k) != "OUT":
                    risk[k] = "RISK"
        else:
            official = title_status(chase, chase_left(m, m["state"] == "final"))
    if m["state"] == "race" and live and points_race(m["race"]):
        title = "LIVE POINTS"
    elif len(chase):
        left = len(chase_left(m, m["state"] == "final"))
        title = "FINAL STANDINGS" if left == 0 else (str(left) + (" RACE LEFT" if left == 1 else " RACES LEFT"))
    else:
        title = str(m["year"]) + " " + m["name"]
    header(c, label, CHASE_COLOR if len(chase) else GOLD, title, str(page * per + 1) + "-" + str(page * per + len(part)))
    lead = num(order[0].get("points"))
    items = []
    for i in range(len(part)):
        p = part[i]
        rank = page * per + i + 1
        in_chase = True
        if len(chase):
            moved = before.get(str(p.get("car_number")), rank) - rank
        else:
            moved = was.get(str(p.get("driver_id")), rank) - rank
        value = str(lead) if rank == 1 else str(num(p.get("points")) - lead)
        vcol = INK if rank == 1 else DIM      # leader white: gold and amber look alike on LEDs
        car = str(p.get("car_number"))
        st = official.get(car, risk.get(car, ""))
        if st == "OUT":
            # keep the number, in red: how far back they are
            vcol = DROP
        elif st == "CHAMP":
            value = "CHAMP"
            vcol = GOLD
        elif st == "RISK":
            # would be OUT if the race ended now: keep the number, in amber
            vcol = SLIP
        mark = ("U" + str(moved)) if moved > 0 else (("D" + str(-moved)) if moved < 0 else "")
        items.append([str(rank), INK if in_chase else DIM, mark, UP if moved > 0 else DROP,
                      value, vcol, car])
    headed_cells(c, m, items, (c.width - 4) // cols)

# ---------- page functions ----------

# Pages 2-8 are slots. In a session (race, qualifying, results) they run the
# field then the Chase; on off days: the last race's top 8, the Chase, the
# season leaders, and the points past the Chase.

def slot(c, ctx, i):
    m = model(ctx)
    if m["state"] == "off" and season_done(m):
        # card, 3 champion pages, the Chase's final standings, points past it
        if i < 3:
            champ_page(c, m, i)
        elif i < 5:
            chase_page(c, ctx, i - 3)
        else:
            first = len([p for p in standings(m) if p.get("is_in_chase")]) or m["cut"]
            points_list_page(c, m, first + 8 * (i - 5))
        return
    if m["state"] == "off":
        if i == 0:
            results_page(c, m)
        elif i < 3:
            chase_page(c, ctx, i - 1)
        else:
            stats_page(c, m, i - 3)
        return
    ev = special_event(m)
    if ev != None:
        if i < ev[1]:
            field_page(c, ctx, i, True)
        else:
            winners_page(c, m, ev[0], i - ev[1])
        return
    if last_stage_squeeze(m) and field_mode(ctx)[1] == 8:
        # Before the Chase, from the final stage on: the field's last page
        # (33-40) gives way so the drivers just outside the cut show too.
        if i < 4:
            field_page(c, ctx, i)
        elif i < 6:
            chase_page(c, ctx, i - 4)
        else:
            stats_page(c, m, len(STATS))
        return
    if i < 5:
        field_page(c, ctx, i)
    else:
        chase_page(c, ctx, i - 5)

def points_race(r):
    # The Clash, the Duels and the All-Star Race (race_type_id 2) pay no points.
    return r != None and r.get("race_type_id", 1) == 1

def last_stage_squeeze(m):
    if m["state"] not in ("race", "final") or not points_race(m.get("race")):
        return False
    if num(m["race"].get("playoff_round")) > 0:
        return False      # a Chase race (the schedule says so: no fetch needed)
    if m["state"] == "final":
        return True
    lf = m["live"]
    return ((lf.get("stage") or {}).get("finish_at_lap") or 0) >= (lf.get("laps_in_race") or 1)

def field1(c, ctx):
    slot(c, ctx, 0)

def field2(c, ctx):
    slot(c, ctx, 1)

def field3(c, ctx):
    slot(c, ctx, 2)

def field4(c, ctx):
    slot(c, ctx, 3)

def field5(c, ctx):
    slot(c, ctx, 4)

def chase1(c, ctx):
    slot(c, ctx, 5)

def chase2(c, ctx):
    slot(c, ctx, 6)
