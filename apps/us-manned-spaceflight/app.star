# mission name -> (launch h, m, s, land h, m, s), UTC. Missing entries
# default to midnight, which rounds the duration to whole days.
MISSION_TIMES = {
    "FREEDOM 7": (14, 34, 13, 14, 49, 35),
    "LIBERTY BELL 7": (12, 20, 36, 12, 36, 13),
    "FRIENDSHIP 7": (14, 47, 39, 19, 43, 2),
    "AURORA 7": (12, 45, 16, 17, 41, 21),
    "SIGMA 7": (12, 15, 12, 21, 28, 22),
    "FAITH 7": (13, 4, 13, 23, 24, 2),
    "GEMINI 3": (14, 24, 0, 19, 16, 31),
    "GEMINI 4": (15, 15, 59, 17, 12, 11),
    "GEMINI 5": (13, 59, 59, 12, 55, 13),
    "GEMINI 7": (19, 30, 3, 14, 5, 4),
    "GEMINI 6": (13, 37, 26, 15, 28, 50),
    "GEMINI 8": (16, 41, 2, 3, 22, 28),
    "GEMINI 9A": (13, 39, 33, 14, 0, 23),
    "GEMINI 10": (22, 20, 26, 21, 7, 5),
    "GEMINI 11": (14, 42, 26, 13, 59, 35),
    "GEMINI 12": (20, 46, 33, 19, 21, 4),
    "APOLLO 7": (15, 2, 45, 11, 11, 48),
    "APOLLO 8": (12, 51, 0, 15, 51, 42),
    "APOLLO 9": (16, 0, 0, 17, 0, 54),
    "APOLLO 10": (16, 49, 0, 16, 52, 23),
    "APOLLO 11": (13, 32, 0, 16, 50, 35),
    "APOLLO 12": (16, 22, 0, 20, 58, 24),
    "APOLLO 13": (19, 13, 0, 18, 7, 41),
    "APOLLO 14": (21, 3, 2, 21, 5, 0),
    "APOLLO 15": (13, 34, 0, 20, 45, 53),
    "APOLLO 16": (17, 54, 0, 19, 45, 5),
    "APOLLO 17": (5, 33, 0, 19, 54, 59),
    "SKYLAB 2": (13, 0, 0, 13, 49, 48),
    "SKYLAB 3": (11, 11, 0, 22, 19, 51),
    "SKYLAB 4": (14, 1, 23, 15, 16, 53),
    "APOLLO-SOYUZ": (19, 50, 0, 21, 18, 24),
    "STS-1": (12, 0, 4, 18, 20, 57),
    "STS-2": (15, 10, 0, 21, 23, 12),
    "STS-3": (16, 0, 0, 16, 4, 45),
    "STS-4": (15, 0, 0, 16, 9, 40),
    "STS-5": (11, 19, 0, 14, 33, 26),
    "STS-6": (18, 30, 0, 18, 53, 42),
    "STS-7": (11, 33, 0, 13, 56, 59),
    "STS-8": (6, 32, 0, 7, 40, 43),
    "STS-9": (16, 0, 0, 23, 47, 24),
    "STS-41-B": (13, 0, 0, 12, 15, 55),
    "STS-41-C": (13, 58, 0, 13, 38, 7),
    "STS-41-D": (12, 41, 50, 13, 37, 54),
    "STS-41-G": (11, 3, 0, 16, 26, 33),
    "STS-51-A": (12, 15, 0, 11, 59, 56),
    "STS-51-C": (19, 50, 0, 21, 23, 23),
    "STS-51-D": (13, 59, 5, 13, 54, 28),
    "STS-51-B": (16, 2, 18, 16, 11, 4),
    "STS-51-G": (11, 33, 0, 13, 11, 52),
    "STS-51-F": (21, 0, 0, 19, 45, 26),
    "STS-51-I": (10, 58, 1, 13, 15, 43),
    "STS-51-J": (15, 15, 30, 17, 0, 8),
    "STS-61-A": (17, 0, 0, 17, 44, 51),
    "STS-61-B": (0, 29, 0, 21, 33, 49),
    "STS-61-C": (11, 55, 0, 13, 58, 51),
    "STS-51-L": (16, 38, 0, 16, 39, 13),
    "STS-26": (15, 37, 0, 16, 37, 11),
    "STS-27": (14, 30, 34, 23, 36, 11),
    "STS-29": (14, 57, 0, 14, 35, 50),
    "STS-30": (18, 46, 59, 19, 43, 26),
    "STS-28": (12, 37, 0, 13, 37, 8),
    "STS-34": (16, 53, 40, 16, 33, 0),
    "STS-33": (0, 23, 30, 0, 30, 18),
    "STS-32": (12, 35, 0, 9, 35, 37),
    "STS-36": (7, 50, 22, 18, 8, 44),
    "STS-31": (12, 33, 51, 13, 49, 57),
    "STS-41": (11, 47, 15, 13, 57, 19),
    "STS-38": (23, 48, 15, 21, 42, 46),
    "STS-35": (6, 49, 1, 5, 54, 9),
    "STS-37": (14, 22, 45, 13, 55, 30),
    "STS-39": (11, 33, 14, 18, 55, 37),
    "STS-40": (13, 24, 51, 15, 39, 11),
    "STS-43": (15, 2, 0, 12, 23, 25),
    "STS-48": (23, 11, 4, 7, 38, 42),
    "STS-44": (23, 44, 0, 22, 34, 43),
    "STS-42": (14, 52, 33, 16, 7, 17),
    "STS-45": (13, 13, 39, 11, 23, 6),
    "STS-49": (23, 40, 0, 20, 57, 39),
    "STS-50": (16, 12, 23, 11, 42, 27),
    "STS-46": (13, 56, 48, 13, 11, 50),
    "STS-47": (14, 23, 0, 12, 53, 24),
    "STS-52": (17, 9, 39, 14, 5, 53),
    "STS-53": (13, 24, 0, 20, 43, 17),
    "STS-54": (13, 59, 30, 13, 37, 47),
    "STS-56": (5, 29, 0, 11, 37, 20),
    "STS-55": (14, 50, 0, 14, 29, 59),
    "STS-57": (13, 7, 22, 12, 52, 16),
    "STS-51": (11, 45, 0, 7, 56, 6),
    "STS-58": (14, 53, 10, 15, 5, 42),
    "STS-61": (9, 27, 0, 5, 25, 33),
    "STS-60": (12, 10, 0, 19, 19, 22),
    "STS-62": (13, 53, 1, 13, 10, 42),
    "STS-59": (11, 5, 0, 16, 54, 30),
    "STS-65": (16, 43, 1, 10, 38, 1),
    "STS-64": (22, 22, 35, 21, 12, 52),
    "STS-68": (11, 16, 1, 17, 2, 9),
    "STS-66": (16, 59, 43, 15, 33, 45),
    "STS-63": (5, 22, 4, 11, 50, 19),
    "STS-67": (6, 38, 13, 21, 47, 1),
    "STS-71": (19, 32, 19, 14, 55, 28),
    "STS-70": (13, 41, 55, 12, 2, 0),
    "STS-69": (15, 9, 0, 11, 38, 56),
    "STS-73": (13, 53, 0, 11, 45, 21),
    "STS-74": (12, 30, 43, 17, 1, 27),
    "STS-72": (9, 41, 0, 7, 41, 41),
    "STS-75": (20, 18, 0, 13, 58, 22),
    "STS-76": (8, 13, 3, 13, 28, 56),
    "STS-77": (10, 30, 0, 11, 9, 18),
    "STS-78": (14, 49, 0, 12, 37, 30),
    "STS-79": (8, 54, 49, 12, 13, 13),
    "STS-80": (19, 55, 47, 11, 49, 4),
    "STS-81": (9, 27, 23, 14, 23, 51),
    "STS-82": (8, 55, 17, 8, 32, 0),
    "STS-83": (19, 20, 32, 18, 33, 11),
    "STS-84": (9, 7, 48, 13, 27, 44),
    "STS-94": (18, 2, 0, 10, 46, 34),
    "STS-85": (14, 41, 0, 11, 9, 7),
    "STS-86": (2, 34, 19, 21, 55, 0),
    "STS-87": (19, 46, 0, 12, 21, 1),
    "STS-89": (2, 48, 15, 22, 36, 0),
    "STS-90": (18, 19, 0, 16, 9, 58),
    "STS-91": (22, 6, 24, 18, 0, 18),
    "STS-95": (19, 19, 34, 17, 4, 0),
    "STS-88": (8, 35, 34, 3, 53, 0),
    "STS-96": (10, 49, 42, 6, 2, 43),
    "STS-93": (4, 31, 0, 3, 20, 35),
    "STS-103": (0, 50, 0, 0, 1, 34),
    "STS-99": (17, 43, 40, 23, 23, 0),
    "STS-101": (10, 11, 10, 6, 20, 19),
    "STS-106": (12, 45, 47, 7, 56, 48),
    "STS-92": (23, 17, 0, 20, 59, 42),
    "STS-97": (3, 6, 0, 23, 4, 20),
    "STS-98": (23, 13, 0, 20, 33, 5),
    "STS-102": (11, 42, 9, 7, 31, 41),
    "STS-100": (18, 40, 42, 16, 11, 56),
    "STS-104": (9, 4, 0, 3, 40, 39),
    "STS-105": (21, 10, 14, 18, 23, 0),
    "STS-108": (22, 19, 28, 17, 56, 13),
    "STS-109": (11, 22, 2, 9, 33, 10),
    "STS-110": (20, 44, 19, 16, 26, 57),
    "STS-111": (21, 22, 49, 17, 58, 45),
    "STS-112": (19, 45, 51, 15, 44, 35),
    "STS-113": (0, 49, 47, 19, 38, 25),
    "STS-107": (15, 39, 0, 13, 59, 32),
    "STS-114": (14, 39, 0, 12, 11, 22),
    "STS-121": (18, 37, 55, 13, 14, 43),
    "STS-115": (15, 14, 55, 10, 21, 30),
    "STS-116": (1, 47, 35, 22, 32, 0),
    "STS-117": (23, 38, 4, 19, 49, 38),
    "STS-118": (22, 36, 42, 16, 33, 20),
    "STS-120": (15, 38, 19, 18, 1, 18),
    "STS-122": (19, 45, 30, 14, 7, 10),
    "STS-123": (6, 28, 14, 0, 40, 41),
    "STS-124": (21, 2, 12, 15, 15, 19),
    "STS-126": (0, 55, 39, 21, 25, 9),
    "STS-119": (23, 43, 44, 19, 13, 0),
    "STS-125": (18, 1, 56, 15, 39, 5),
    "STS-127": (22, 3, 10, 14, 48, 8),
    "STS-128": (3, 59, 0, 0, 53, 55),
    "STS-129": (19, 28, 9, 14, 44, 23),
    "STS-130": (9, 14, 8, 3, 22, 10),
    "STS-131": (10, 21, 22, 13, 8, 35),
    "STS-132": (18, 20, 0, 12, 49, 18),
    "STS-133": (21, 53, 24, 16, 58, 14),
    "STS-134": (12, 56, 28, 6, 35, 0),
    "STS-135": (15, 29, 4, 9, 57, 54),
    # Lands 00:07:27 UTC on April 11 (8:07 PM EDT on the 10th).
    "ARTEMIS II": (22, 35, 12, 0, 7, 27),
    # Never launched: both halves are the time of the fire, so the duration is 0.
    "APOLLO 1": (23, 31, 0, 23, 31, 0),
    # Land time is STS-71's landing (Thagard's actual return), so the duration
    # is his full Mir stay. See LAUNCH_ONLY_NAMES.
    "SOYUZ TM-21": (6, 11, 34, 14, 55, 28),
    "SOYUZ TM-31": (7, 52, 47, 7, 31, 41),
    "SOYUZ TMA-2": (3, 53, 52, 2, 40, 20),
    "SOYUZ TMA-3": (5, 38, 3, 0, 11, 15),
    "SOYUZ TMA-4": (3, 19, 0, 0, 35, 8),
    "SOYUZ TMA-5": (3, 6, 27, 22, 8, 27),
    "SOYUZ TMA-6": (0, 46, 25, 1, 9, 47),
    "SOYUZ TMA-7": (3, 54, 53, 23, 47, 12),
    "SOYUZ TMA-8": (2, 30, 20, 1, 13, 37),
    "SOYUZ TMA-9": (4, 8, 42, 12, 31, 4),
    "SOYUZ TMA-11": (13, 22, 38, 8, 29, 43),
    "SOYUZ TMA-13": (7, 1, 33, 7, 15, 9),
    "SOYUZ TMA-14": (11, 49, 18, 4, 31, 43),
    "SOYUZ TMA-16": (7, 14, 44, 11, 24, 3),
    "SOYUZ TMA-17": (21, 52, 0, 3, 24, 32),
    "SOYUZ TMA-18": (4, 4, 33, 5, 23, 10),
    "SOYUZ TMA-19": (21, 35, 18, 4, 46, 53),
    "SOYUZ TMA-01M": (23, 10, 54, 7, 54, 5),
    "SOYUZ TMA-20": (19, 9, 24, 2, 26, 40),
    "SOYUZ TMA-21": (22, 18, 20, 3, 59, 43),
    "SOYUZ TMA-02M": (20, 12, 44, 2, 24, 50),
    "SOYUZ TMA-22": (4, 14, 3, 11, 45, 35),
    "SOYUZ TMA-03M": (13, 16, 14, 8, 14, 41),
    "SOYUZ TMA-04M": (3, 1, 22, 2, 52, 51),
    "SOYUZ TMA-05M": (2, 40, 3, 1, 53, 20),
    "SOYUZ TMA-06M": (10, 51, 10, 3, 6, 13),
    "SOYUZ TMA-07M": (12, 12, 35, 2, 30, 47),
    "SOYUZ TMA-08M": (20, 43, 20, 2, 58, 28),
    "SOYUZ TMA-09M": (20, 31, 24, 2, 49, 0),
    "SOYUZ TMA-10M": (20, 58, 50, 3, 23, 48),
    "SOYUZ TMA-11M": (4, 14, 15, 1, 58, 6),
    "SOYUZ TMA-12M": (21, 17, 23, 2, 23, 9),
    "SOYUZ TMA-13M": (19, 57, 40, 3, 58, 49),
    "SOYUZ TMA-14M": (20, 24, 59, 2, 7, 40),
    "SOYUZ TMA-15M": (21, 1, 13, 13, 43, 56),
    "SOYUZ TMA-16M": (19, 42, 57, 4, 25, 50),
    "SOYUZ TMA-17M": (21, 2, 44, 13, 12, 30),
    "SOYUZ TMA-19M": (11, 3, 9, 9, 15, 6),
    "SOYUZ TMA-20M": (21, 26, 38, 1, 13, 35),
    "SOYUZ MS-01": (1, 36, 40, 3, 58, 23),
    "SOYUZ MS-02": (8, 5, 14, 11, 20, 21),
    "SOYUZ MS-03": (20, 20, 13, 1, 21, 41),
    "SOYUZ MS-04": (7, 13, 43, 1, 21, 41),
    "SOYUZ MS-05": (15, 41, 12, 8, 37, 47),
    "SOYUZ MS-06": (21, 17, 2, 2, 31, 6),
    "SOYUZ MS-07": (7, 21, 1, 12, 39, 13),
    "SOYUZ MS-08": (17, 44, 23, 11, 44, 38),
    "SOYUZ MS-09": (11, 12, 39, 5, 2, 48),
    "SOYUZ MS-11": (11, 31, 52, 2, 47, 42),
    "SOYUZ MS-12": (19, 14, 8, 10, 59, 21),
    "SOYUZ MS-13": (16, 28, 20, 9, 12, 21),
    "SOYUZ MS-15": (13, 57, 42, 5, 16, 10),
    "SOYUZ MS-16": (8, 5, 6, 2, 54, 6),
    "SOYUZ MS-17": (5, 45, 4, 4, 55, 7),
    "SOYUZ MS-18": (7, 42, 40, 11, 28, 1),
    "SOYUZ MS-22": (13, 54, 49, 11, 17, 5),
    "SOYUZ MS-24": (15, 44, 35, 7, 17, 47),
    "SOYUZ MS-25": (12, 36, 10, 11, 59, 3),
    "SOYUZ MS-26": (16, 23, 12, 1, 20, 33),
    "SOYUZ MS-27": (5, 47, 15, 5, 3, 33),
    "SOYUZ MS-28": (9, 27, 57, 10, 27, 25),
    "SOYUZ MS-29": (14, 47, 43, 14, 47, 43),
    "SPACEX DEMO-2": (19, 22, 45, 18, 47, 47),
    "SPACEX CREW-1": (0, 27, 17, 6, 56, 43),
    "SPACEX CREW-2": (9, 49, 2, 3, 33, 15),
    "SPACEX CREW-3": (2, 3, 30, 4, 43, 23),
    "SPACEX CREW-4": (7, 52, 55, 20, 55, 27),
    "SPACEX CREW-5": (16, 0, 57, 2, 2, 9),
    "SPACEX CREW-6": (5, 34, 14, 4, 17, 23),
    "SPACEX CREW-7": (7, 27, 27, 9, 47, 38),
    "SPACEX CREW-8": (3, 53, 38, 7, 29, 2),
    "STARLINER CFT": (14, 52, 15, 21, 57, 7),
    "SPACEX CREW-9": (17, 17, 21, 21, 57, 7),
    "SPACEX CREW-10": (23, 3, 48, 15, 33, 44),
    "SPACEX CREW-11": (15, 43, 42, 8, 41, 36),
    "SPACEX CREW-12": (10, 15, 55, 10, 15, 55),
    "SOYUZ TMA-1": (0, 49, 47, 2, 4, 25),
    "SOYUZ TMA-18M": (19, 42, 57, 4, 25, 50),
    "SOYUZ MS-19": (7, 42, 40, 11, 28, 1),
    "SOYUZ MS-23": (13, 54, 50, 11, 17, 5),
    "SOYUZ MS-10": (8, 40, 15, 8, 59, 56),
    "INSPIRATION4": (0, 2, 56, 23, 6, 49),
    "AXIOM-1": (15, 17, 12, 17, 6, 23),
    "AXIOM-2": (21, 37, 9, 3, 4, 24),
    "AXIOM-3": (21, 49, 11, 13, 29, 42),
    "POLARIS DAWN": (9, 23, 49, 7, 36, 52),
    "AXIOM-4": (6, 31, 53, 9, 31, 41),
}

# Lunar module touchdown, UTC. Shown in Houston time (CST/CDT).
MOON_LANDING_TIME = {
    "APOLLO 11": (1969, 7, 20, 20, 17, 40),
    "APOLLO 12": (1969, 11, 19, 6, 54, 35),
    "APOLLO 14": (1971, 2, 5, 9, 18, 11),
    "APOLLO 15": (1971, 7, 30, 22, 16, 29),
    "APOLLO 16": (1972, 4, 21, 2, 23, 35),
    "APOLLO 17": (1972, 12, 11, 19, 54, 57),
}

# Moon-landing card pages 3-8. Sources: Wikipedia's list of moonwalks
# (NASA depress-to-repress EVA times), mission infoboxes, NASA sample masses.
#   liftoff: LM ascent-stage liftoff, UTC (y, m, d, h, min, s)
#   evas: each moonwalk in seconds
#   rocks_lb: returned sample mass
#   p8: ("ORBITS", n) or ("CMP_EVA", surname, seconds)
MOON_SURFACE = {
    "APOLLO 11": {"liftoff": (1969, 7, 21, 17, 54, 0), "evas": [9100], "rocks_lb": "47.5", "p8": ("ORBITS", 30)},
    "APOLLO 12": {"liftoff": (1969, 11, 20, 14, 25, 47), "evas": [14163, 13755], "rocks_lb": "75.6", "p8": ("ORBITS", 45)},
    "APOLLO 14": {"liftoff": (1971, 2, 6, 18, 48, 42), "evas": [17270, 16481], "rocks_lb": "94.4", "p8": ("ORBITS", 34)},
    "APOLLO 15": {"liftoff": (1971, 8, 2, 17, 11, 23), "evas": [23562, 25934, 17390], "rocks_lb": "169.1", "p8": ("CMP_EVA", "WORDEN", 2347)},
    "APOLLO 16": {"liftoff": (1972, 4, 24, 1, 25, 47), "evas": [25862, 26589, 20403], "rocks_lb": "209.9", "p8": ("CMP_EVA", "MATTINGLY", 5022)},
    "APOLLO 17": {"liftoff": (1972, 12, 14, 22, 54, 37), "evas": [25913, 27416, 26108], "rocks_lb": "243.4", "p8": ("CMP_EVA", "EVANS", 3944)},
}

# Each moonwalker's boots-on-the-surface time over all EVAs, from the Apollo
# Lunar Surface Journal. Good to the minute. (surname, seconds), CDR first.
MOON_BOOTS = {
    "APOLLO 11": [("ARMSTRONG", 7982), ("ALDRIN", 6108)],
    "APOLLO 12": [("CONRAD", 26425), ("BEAN", 22712)],
    "APOLLO 14": [("SHEPARD", 31664), ("MITCHELL", 30280)],
    "APOLLO 15": [("SCOTT", 62807), ("IRWIN", 59914)],
    "APOLLO 16": [("YOUNG", 69672), ("DUKE", 67809)],
    "APOLLO 17": [("CERNAN", 76131), ("SCHMITT", 74670)],
}

# Official Apollo landing-site names for the MOONLAND sentence.
MOON_LANDING_SITE = {
    "APOLLO 11": "THE SEA OF TRANQUILITY",
    "APOLLO 12": "THE OCEAN OF STORMS",
    "APOLLO 14": "THE FRA MAURO HIGHLANDS",
    "APOLLO 15": "HADLEY-APENNINE",
    "APOLLO 16": "THE DESCARTES HIGHLANDS",
    "APOLLO 17": "THE TAURUS-LITTROW VALLEY",
}

# Missions that never launched: no LAUNCH event, only the LAND-day card.
TRIBUTE_NAMES = ["APOLLO 1"]

# Soyuz flights that only brought an American home: no LAUNCH event. The
# stored launch is the astronaut's real launch, so the duration is their
# true time in space.
LANDING_ONLY_NAMES = ["SOYUZ TMA-1", "SOYUZ TMA-18M", "SOYUZ MS-19", "SOYUZ MS-23"]

# Launch that never reached orbit (booster failure, ballistic landing).
ABORTED_NAMES = ["SOYUZ MS-10"]

# Real launch but no LAND event of its own -- the crew came home on a
# different, separately tracked mission. The stored landing is the
# astronaut's real return, so the duration is their true time in space.
LAUNCH_ONLY_NAMES = ["SOYUZ TM-21", "SOYUZ TM-31", "SOYUZ TMA-16M", "SOYUZ MS-03", "SOYUZ MS-18", "SOYUZ MS-22", "SOYUZ MS-29", "STARLINER CFT", "SPACEX CREW-12"]


# Launched but not yet landed. Also in LAUNCH_ONLY_NAMES; the stored land
# fields repeat the launch, and duration() shows elapsed time. On landing:
# store the real land date/time and remove it from both lists.
IN_FLIGHT_NAMES = ["SOYUZ MS-29", "SPACEX CREW-12"]


# (launch card, landing card) ISS Expedition numbers for the flight's NASA
# astronaut; "" = no card for that kind.
ISS_EXPEDITION = {
    "SOYUZ TM-21": ("18", ""),
    "SOYUZ TM-31": ("1", ""),
    "SOYUZ TMA-2": ("7", "7"),
    "SOYUZ TMA-3": ("8", "8"),
    "SOYUZ TMA-4": ("9", "9"),
    "SOYUZ TMA-5": ("10", "10"),
    "SOYUZ TMA-6": ("11", "11"),
    "SOYUZ TMA-7": ("12", "12"),
    "SOYUZ TMA-8": ("13", "13"),
    "SOYUZ TMA-9": ("14", "14"),
    "SOYUZ TMA-11": ("16", "16"),
    "SOYUZ TMA-13": ("18", "18"),
    "SOYUZ TMA-14": ("19/20", "19/20"),
    "SOYUZ TMA-16": ("21/22", "21/22"),
    "SOYUZ TMA-17": ("22/23", "22/23"),
    "SOYUZ TMA-18": ("23/24", "23/24"),
    "SOYUZ TMA-19": ("24/25", "24/25"),
    "SOYUZ TMA-01M": ("25/26", "25/26"),
    "SOYUZ TMA-20": ("26/27", "26/27"),
    "SOYUZ TMA-21": ("27/28", "27/28"),
    "SOYUZ TMA-02M": ("28/29", "28/29"),
    "SOYUZ TMA-22": ("29/30", "29/30"),
    "SOYUZ TMA-03M": ("30/31", "30/31"),
    "SOYUZ TMA-04M": ("31/32", "31/32"),
    "SOYUZ TMA-05M": ("32/33", "32/33"),
    "SOYUZ TMA-06M": ("33/34", "33/34"),
    "SOYUZ TMA-07M": ("34/35", "34/35"),
    "SOYUZ TMA-08M": ("35/36", "35/36"),
    "SOYUZ TMA-09M": ("36/37", "36/37"),
    "SOYUZ TMA-10M": ("37/38", "37/38"),
    "SOYUZ TMA-11M": ("38/39", "38/39"),
    "SOYUZ TMA-12M": ("39/40", "39/40"),
    "SOYUZ TMA-13M": ("40/41", "40/41"),
    "SOYUZ TMA-14M": ("41/42", "41/42"),
    "SOYUZ TMA-15M": ("42/43", "42/43"),
    "SOYUZ TMA-16M": ("43-46", ""),
    "SOYUZ TMA-17M": ("44/45", "44/45"),
    "SOYUZ TMA-19M": ("46/47", "46/47"),
    "SOYUZ TMA-20M": ("47/48", "47/48"),
    "SOYUZ MS-01": ("48/49", "48/49"),
    "SOYUZ MS-02": ("49/50", "49/50"),
    "SOYUZ MS-03": ("50-52", ""),
    "SOYUZ MS-04": ("51/52", "51/52"),
    "SOYUZ MS-05": ("52/53", "52/53"),
    "SOYUZ MS-06": ("53/54", "53/54"),
    "SOYUZ MS-07": ("54/55", "54/55"),
    "SOYUZ MS-08": ("55/56", "55/56"),
    "SOYUZ MS-09": ("56/57", "56/57"),
    "SOYUZ MS-11": ("58/59", "58/59"),
    "SOYUZ MS-12": ("59/60", "59/60"),
    "SOYUZ MS-13": ("60-62", "59-61"),
    "SOYUZ MS-15": ("61/62", "61/62"),
    "SOYUZ MS-16": ("62/63", "62/63"),
    "SOYUZ MS-17": ("63/64", "63/64"),
    "SOYUZ MS-18": ("64-66", ""),
    "SOYUZ MS-22": ("67-69", ""),
    "SOYUZ MS-24": ("69/70", "69/70"),
    "SOYUZ MS-25": ("70/71", "70/71"),
    "SOYUZ MS-26": ("71/72", "71/72"),
    "SOYUZ MS-27": ("72/73", "72/73"),
    "SOYUZ MS-28": ("73/74", "73/74"),
    "SOYUZ MS-29": ("74/75", ""),
    "SPACEX DEMO-2": ("63", "63"),
    "SPACEX CREW-1": ("64/65", "64/65"),
    "SPACEX CREW-2": ("65/66", "65/66"),
    "SPACEX CREW-3": ("66/67", "66/67"),
    "SPACEX CREW-4": ("67/68", "67/68"),
    "SPACEX CREW-5": ("68", "68"),
    "SPACEX CREW-6": ("68/69", "68/69"),
    "SPACEX CREW-7": ("69/70", "69/70"),
    "SPACEX CREW-8": ("70-72", "70-72"),
    "STARLINER CFT": ("71/72", ""),
    "SPACEX CREW-9": ("72", "72"),
    "SPACEX CREW-10": ("72/73", "72/73"),
    "SPACEX CREW-11": ("73/74", "73/74"),
    "SPACEX CREW-12": ("74/75", ""),
    "SOYUZ TMA-1": ("", "6"),
    "SOYUZ TMA-18M": ("", "43-46"),
    "SOYUZ MS-19": ("", "64-66"),
    "SOYUZ MS-23": ("", "67-69"),
}

# (liftoff to docking, undocking to landing) as H:MM:SS, from spacefacts.de.
ISS_DOCK = {
    "SOYUZ TM-21": ("49:33:52", ""),
    "SOYUZ TM-31": ("49:28:16", ""),
    "SOYUZ TMA-2": ("50:02:28", "3:23:11"),
    "SOYUZ TMA-3": ("49:37:55", "3:19:06"),
    "SOYUZ TMA-4": ("49:42:03", "3:26:46"),
    "SOYUZ TMA-5": ("49:09:05", "3:23:47"),
    "SOYUZ TMA-6": ("49:33:58", "3:20:33"),
    "SOYUZ TMA-7": ("49:32:05", "3:19:18"),
    "SOYUZ TMA-8": ("49:49:06", "3:20:28"),
    "SOYUZ TMA-9": ("49:12:38", "3:19:25"),
    "SOYUZ TMA-11": ("49:27:27", "3:23:16"),
    "SOYUZ TMA-13": ("49:24:41", "3:19:44"),
    "SOYUZ TMA-14": ("49:15:31", "3:24:27"),
    "SOYUZ TMA-16": ("49:20:23", "3:21:00"),
    "SOYUZ TMA-17": ("48:56:00", "3:20:19"),
    "SOYUZ TMA-18": ("49:20:17", "3:20:58"),
    "SOYUZ TMA-19": ("48:45:47", "3:23:40"),
    "SOYUZ TMA-01M": ("48:49:50", "3:26:57"),
    "SOYUZ TMA-20": ("49:02:08", "4:51:23"),
    "SOYUZ TMA-21": ("48:50:53", "3:21:31"),
    "SOYUZ TMA-02M": ("49:05:05", "3:24:33"),
    "SOYUZ TMA-22": ("49:10:05", "3:27:16"),
    "SOYUZ TMA-03M": ("50:03:00", "3:26:58"),
    "SOYUZ TMA-04M": ("49:34:34", "3:43:58"),
    "SOYUZ TMA-05M": ("50:10:59", "3:27:17"),
    "SOYUZ TMA-06M": ("49:38:22", "3:23:20"),
    "SOYUZ TMA-07M": ("49:56:09", "3:22:53"),
    "SOYUZ TMA-08M": ("5:44:56", "3:23:00"),
    "SOYUZ TMA-09M": ("5:39:00", "3:22:29"),
    "SOYUZ TMA-10M": ("5:46:32", "3:21:16"),
    "SOYUZ TMA-11M": ("6:13:37", "3:22:10"),
    "SOYUZ TMA-12M": ("50:36:05", "3:21:39"),
    "SOYUZ TMA-13M": ("5:46:22", "3:27:20"),
    "SOYUZ TMA-14M": ("5:46:30", "3:23:38"),
    "SOYUZ TMA-15M": ("5:47:08", "3:23:51"),
    "SOYUZ TMA-16M": ("5:50:40", "3:22:20"),
    "SOYUZ TMA-17M": ("5:42:23", "3:22:55"),
    "SOYUZ TMA-19M": ("6:30:17", "3:22:33"),
    "SOYUZ TMA-20M": ("5:43:16", "3:22:04"),
    "SOYUZ MS-01": ("50:29:51", "3:23:23"),
    "SOYUZ MS-02": ("49:47:13", "3:22:55"),
    "SOYUZ MS-03": ("49:38:04", "3:23:26"),
    "SOYUZ MS-04": ("6:04:47", "3:23:40"),
    "SOYUZ MS-05": ("6:13:32", "3:23:19"),
    "SOYUZ MS-06": ("5:38:13", "3:22:30"),
    "SOYUZ MS-07": ("49:18:01", "3:22:37"),
    "SOYUZ MS-08": ("49:55:56", "3:47:06"),
    "SOYUZ MS-09": ("49:48:29", "3:22:26"),
    "SOYUZ MS-11": ("6:01:28", "3:22:09"),
    "SOYUZ MS-12": ("5:47:31", "3:21:49"),
    "SOYUZ MS-13": ("6:19:30", "3:21:53"),
    "SOYUZ MS-15": ("5:44:58", "3:22:40"),
    "SOYUZ MS-16": ("6:08:11", "3:21:57"),
    "SOYUZ MS-17": ("3:03:39", "3:21:03"),
    "SOYUZ MS-18": ("3:22:21", "3:21:25"),
    "SOYUZ MS-22": ("3:11:45", "1:48:31"),
    "SOYUZ MS-24": ("3:08:57", "3:22:49"),
    "SOYUZ MS-25": ("50:26:40", "3:22:33"),
    "SOYUZ MS-26": ("3:08:57", "3:22:57"),
    "SOYUZ MS-27": ("3:10:28", "3:21:56"),
    "SOYUZ MS-28": ("3:06:38", "3:24:30"),
    "SOYUZ MS-29": ("3:04:43", ""),
    "SPACEX DEMO-2": ("18:53:15", "19:12:47"),
    "SPACEX CREW-1": ("27:33:43", "6:21:45"),
    "SPACEX CREW-2": ("23:18:53", "8:28:15"),
    "SPACEX CREW-3": ("21:28:30", "23:23:23"),
    "SPACEX CREW-4": ("15:44:54", "4:50:27"),
    "SPACEX CREW-5": ("29:00:03", "18:42:43"),
    "SPACEX CREW-6": ("25:05:46", "17:12:23"),
    "SPACEX CREW-7": ("29:48:33", "18:27:38"),
    "SPACEX CREW-8": ("27:34:22", "34:24:02"),
    "STARLINER CFT": ("26:41:45", ""),
    "SPACEX CREW-9": ("28:12:39", "16:52:07"),
    "SPACEX CREW-10": ("29:00:44", "17:18:44"),
    "SPACEX CREW-11": ("14:43:14", "10:21:36"),
    "SPACEX CREW-12": ("33:59:05", ""),
    "SOYUZ TMA-1": ("", "3:21:25"),
    "SOYUZ TMA-18M": ("", "3:22:02"),
    "SOYUZ MS-19": ("", "4:06:58"),
    "SOYUZ MS-23": ("", "3:22:44"),
    "AXIOM-1": ("21:11:48", "15:56:23"),
    "AXIOM-2": ("15:34:51", "11:59:24"),
    "AXIOM-3": ("36:52:49", "47:09:42"),
    "AXIOM-4": ("27:59:54", "22:16:41"),
}


# Soyuz flights: Baikonur launches, Kazakh landings, Moscow time.
def is_soyuz(name):
    return name.startswith("SOYUZ ")


# NASA Commercial Crew (Crew Dragon, Starliner) plus the private Dragon
# flights. Private flights show capsule and operator on page 6.
def is_commercial(name):
    return name.startswith("SPACEX ") or name == "STARLINER CFT" or name in PRIVATE_SPACECRAFT

# name, launch_year, launch_month, launch_day, land_year, land_month, land_day, "crew, names"
MERCURY_GEMINI_APOLLO_DATA = [
    ("FREEDOM 7", 1961, 5, 5, 1961, 5, 5, "Alan Shepard"),
    ("LIBERTY BELL 7", 1961, 7, 21, 1961, 7, 21, "Gus Grissom"),
    ("FRIENDSHIP 7", 1962, 2, 20, 1962, 2, 20, "John Glenn"),
    ("AURORA 7", 1962, 5, 24, 1962, 5, 24, "Scott Carpenter"),
    ("SIGMA 7", 1962, 10, 3, 1962, 10, 3, "Wally Schirra"),
    ("FAITH 7", 1963, 5, 15, 1963, 5, 16, "Gordon Cooper"),
    ("GEMINI 3", 1965, 3, 23, 1965, 3, 23, "Gus Grissom, John Young"),
    ("GEMINI 4", 1965, 6, 3, 1965, 6, 7, "James McDivitt, Ed White"),
    ("GEMINI 5", 1965, 8, 21, 1965, 8, 29, "Gordon Cooper, Pete Conrad"),
    ("GEMINI 7", 1965, 12, 4, 1965, 12, 18, "Frank Borman, Jim Lovell"),
    ("GEMINI 6", 1965, 12, 15, 1965, 12, 16, "Wally Schirra, Thomas Stafford"),
    ("GEMINI 8", 1966, 3, 16, 1966, 3, 17, "Neil Armstrong, David Scott"),
    ("GEMINI 9A", 1966, 6, 3, 1966, 6, 6, "Thomas Stafford, Gene Cernan"),
    ("GEMINI 10", 1966, 7, 18, 1966, 7, 21, "John Young, Michael Collins"),
    ("GEMINI 11", 1966, 9, 12, 1966, 9, 15, "Pete Conrad, Richard Gordon"),
    ("GEMINI 12", 1966, 11, 11, 1966, 11, 15, "Jim Lovell, Buzz Aldrin"),
    ("APOLLO 7", 1968, 10, 11, 1968, 10, 22, "Wally Schirra, Donn Eisele, Walter Cunningham"),
    ("APOLLO 8", 1968, 12, 21, 1968, 12, 27, "Frank Borman, Jim Lovell, William Anders"),
    ("APOLLO 9", 1969, 3, 3, 1969, 3, 13, "James McDivitt, David Scott, Rusty Schweickart"),
    ("APOLLO 10", 1969, 5, 18, 1969, 5, 26, "Thomas Stafford, John Young, Gene Cernan"),
    ("APOLLO 11", 1969, 7, 16, 1969, 7, 24, "Neil Armstrong, Buzz Aldrin, Michael Collins"),
    ("APOLLO 12", 1969, 11, 14, 1969, 11, 24, "Pete Conrad, Richard Gordon, Alan Bean"),
    ("APOLLO 13", 1970, 4, 11, 1970, 4, 17, "Jim Lovell, Jack Swigert, Fred Haise"),
    ("APOLLO 14", 1971, 1, 31, 1971, 2, 9, "Alan Shepard, Stuart Roosa, Edgar Mitchell"),
    ("APOLLO 15", 1971, 7, 26, 1971, 8, 7, "David Scott, Alfred Worden, James Irwin"),
    ("APOLLO 16", 1972, 4, 16, 1972, 4, 27, "John Young, Ken Mattingly, Charles Duke"),
    ("APOLLO 17", 1972, 12, 7, 1972, 12, 19, "Gene Cernan, Ronald Evans, Harrison Schmitt"),
    ("SKYLAB 2", 1973, 5, 25, 1973, 6, 22, "Pete Conrad, Joseph Kerwin, Paul Weitz"),
    ("SKYLAB 3", 1973, 7, 28, 1973, 9, 25, "Alan Bean, Owen Garriott, Jack Lousma"),
    ("SKYLAB 4", 1973, 11, 16, 1974, 2, 8, "Gerald Carr, Edward Gibson, William Pogue"),
    ("APOLLO-SOYUZ", 1975, 7, 15, 1975, 7, 24, "Thomas Stafford, Vance Brand, Deke Slayton"),
]

# Soyuz flights that carried a NASA astronaut. Crew strings list the full
# flight crew minus tourists. Crew who launched on one vehicle and landed
# on another are tagged in CREW_SWAP. TM-21's land date is STS-71's (see
# MISSION_TIMES).
SOYUZ_DATA = [
    ("SOYUZ TM-21", 1995, 3, 14, 1995, 7, 7, "Vladimir Dezhurov, Gennady Strekalov, Norman Thagard"),
    ("SOYUZ TM-31", 2000, 10, 31, 2001, 3, 21, "Yuri Gidzenko, Sergei Krikalev, William Shepherd"),
    ("SOYUZ TMA-2", 2003, 4, 26, 2003, 10, 28, "Yuri Malenchenko, Edward Lu, Pedro Duque"),
    ("SOYUZ TMA-3", 2003, 10, 18, 2004, 4, 30, "Alexander Kaleri, Michael Foale, Pedro Duque, Andre Kuipers"),
    ("SOYUZ TMA-4", 2004, 4, 19, 2004, 10, 24, "Gennady Padalka, Michael Fincke, Andre Kuipers, Yuri Shargin"),
    ("SOYUZ TMA-5", 2004, 10, 14, 2005, 4, 24, "Salizhan Sharipov, Leroy Chiao, Yuri Shargin, Roberto Vittori"),
    ("SOYUZ TMA-6", 2005, 4, 15, 2005, 10, 11, "Sergei Krikalev, John Phillips, Roberto Vittori"),
    ("SOYUZ TMA-7", 2005, 10, 1, 2006, 4, 8, "Valery Tokarev, William McArthur, Marcos Pontes"),
    ("SOYUZ TMA-8", 2006, 3, 30, 2006, 9, 29, "Pavel Vinogradov, Jeffrey Williams, Marcos Pontes"),
    ("SOYUZ TMA-9", 2006, 9, 18, 2007, 4, 21, "Mikhail Tyurin, Michael Lopez-Alegria"),
    ("SOYUZ TMA-11", 2007, 10, 10, 2008, 4, 19, "Yuri Malenchenko, Peggy Whitson, Sheikh Muszaphar Shukor, Yi So-Yeon"),
    ("SOYUZ TMA-13", 2008, 10, 12, 2009, 4, 8, "Yuri Lonchakov, Michael Fincke"),
    ("SOYUZ TMA-14", 2009, 3, 26, 2009, 10, 11, "Gennady Padalka, Michael Barratt"),
    ("SOYUZ TMA-16", 2009, 9, 30, 2010, 3, 18, "Maksim Surayev, Jeffrey Williams"),
    ("SOYUZ TMA-17", 2009, 12, 20, 2010, 6, 2, "Oleg Kotov, Timothy Creamer, Soichi Noguchi"),
    ("SOYUZ TMA-18", 2010, 4, 2, 2010, 9, 25, "Alexander Skvortsov, Mikhail Kornienko, Tracy Caldwell Dyson"),
    ("SOYUZ TMA-19", 2010, 6, 15, 2010, 11, 26, "Fyodor Yurchikhin, Shannon Walker, Douglas Wheelock"),
    ("SOYUZ TMA-01M", 2010, 10, 7, 2011, 3, 16, "Alexander Kaleri, Oleg Skripochka, Scott Kelly"),
    ("SOYUZ TMA-20", 2010, 12, 15, 2011, 5, 24, "Dmitri Kondratyev, Catherine Coleman, Paolo Nespoli"),
    ("SOYUZ TMA-21", 2011, 4, 4, 2011, 9, 16, "Aleksandr Samokutyaev, Andrei Borisenko, Ronald Garan"),
    ("SOYUZ TMA-02M", 2011, 6, 7, 2011, 11, 22, "Sergey Volkov, Michael Fossum, Satoshi Furukawa"),
    ("SOYUZ TMA-22", 2011, 11, 14, 2012, 4, 27, "Anton Shkaplerov, Anatoli Ivanishin, Daniel Burbank"),
    ("SOYUZ TMA-03M", 2011, 12, 21, 2012, 7, 1, "Oleg Kononenko, Andre Kuipers, Donald Pettit"),
    ("SOYUZ TMA-04M", 2012, 5, 15, 2012, 9, 17, "Gennady Padalka, Sergei Revin, Joseph Acaba"),
    ("SOYUZ TMA-05M", 2012, 7, 15, 2012, 11, 19, "Yuri Malenchenko, Sunita Williams, Akihiko Hoshide"),
    ("SOYUZ TMA-06M", 2012, 10, 23, 2013, 3, 16, "Oleg Novitskiy, Evgeny Tarelkin, Kevin Ford"),
    ("SOYUZ TMA-07M", 2012, 12, 19, 2013, 5, 14, "Roman Romanenko, Chris Hadfield, Thomas Marshburn"),
    ("SOYUZ TMA-08M", 2013, 3, 28, 2013, 9, 11, "Pavel Vinogradov, Alexander Misurkin, Christopher Cassidy"),
    ("SOYUZ TMA-09M", 2013, 5, 28, 2013, 11, 11, "Fyodor Yurchikhin, Karen Nyberg, Luca Parmitano"),
    ("SOYUZ TMA-10M", 2013, 9, 25, 2014, 3, 11, "Oleg Kotov, Sergey Ryazansky, Michael Hopkins"),
    ("SOYUZ TMA-11M", 2013, 11, 7, 2014, 5, 14, "Mikhail Tyurin, Richard Mastracchio, Koichi Wakata"),
    ("SOYUZ TMA-12M", 2014, 3, 25, 2014, 9, 11, "Alexander Skvortsov, Oleg Artemyev, Steven Swanson"),
    ("SOYUZ TMA-13M", 2014, 5, 28, 2014, 11, 10, "Maksim Surayev, Reid Wiseman, Alexander Gerst"),
    ("SOYUZ TMA-14M", 2014, 9, 25, 2015, 3, 12, "Aleksandr Samokutyaev, Yelena Serova, Barry Wilmore"),
    ("SOYUZ TMA-15M", 2014, 11, 23, 2015, 6, 11, "Anton Shkaplerov, Samantha Cristoforetti, Terry Virts"),
    ("SOYUZ TMA-16M", 2015, 3, 27, 2016, 3, 2, "Gennady Padalka, Mikhail Kornienko, Scott Kelly"),
    ("SOYUZ TMA-17M", 2015, 7, 22, 2015, 12, 11, "Oleg Kononenko, Kimiya Yui, Kjell Lindgren"),
    ("SOYUZ TMA-19M", 2015, 12, 15, 2016, 6, 18, "Yuri Malenchenko, Timothy Kopra, Timothy Peake"),
    ("SOYUZ TMA-20M", 2016, 3, 18, 2016, 9, 7, "Aleksey Ovchinin, Oleg Skripochka, Jeffrey Williams"),
    ("SOYUZ MS-01", 2016, 7, 7, 2016, 10, 30, "Anatoli Ivanishin, Takuya Onishi, Kathleen Rubins"),
    ("SOYUZ MS-02", 2016, 10, 19, 2017, 4, 10, "Sergey Ryzhikov, Andrei Borisenko, Shane Kimbrough"),
    ("SOYUZ MS-03", 2016, 11, 17, 2017, 9, 3, "Oleg Novitskiy, Thomas Pesquet, Peggy Whitson"),
    ("SOYUZ MS-04", 2017, 4, 20, 2017, 9, 3, "Fyodor Yurchikhin, Jack Fischer, Peggy Whitson"),
    ("SOYUZ MS-05", 2017, 7, 28, 2017, 12, 14, "Sergey Ryazansky, Paolo Nespoli, Randolph Bresnik"),
    ("SOYUZ MS-06", 2017, 9, 12, 2018, 2, 28, "Alexander Misurkin, Joseph Acaba, Mark Vande Hei"),
    ("SOYUZ MS-07", 2017, 12, 17, 2018, 6, 3, "Anton Shkaplerov, Norishige Kanai, Scott Tingle"),
    ("SOYUZ MS-08", 2018, 3, 21, 2018, 10, 4, "Oleg Artemyev, Richard Arnold, Andrew Feustel"),
    ("SOYUZ MS-09", 2018, 6, 6, 2018, 12, 20, "Sergey Prokopyev, Serena Aunon-Chancellor, Alexander Gerst"),
    ("SOYUZ MS-11", 2018, 12, 3, 2019, 6, 25, "Oleg Kononenko, Anne McClain, David Saint-Jacques"),
    ("SOYUZ MS-12", 2019, 3, 14, 2019, 10, 3, "Aleksey Ovchinin, Nick Hague, Christina Koch, Hazza Al Mansouri"),
    ("SOYUZ MS-13", 2019, 7, 20, 2020, 2, 6, "Alexander Skvortsov, Luca Parmitano, Andrew Morgan, Christina Koch"),
    ("SOYUZ MS-15", 2019, 9, 25, 2020, 4, 17, "Oleg Skripochka, Jessica Meir, Hazza Al Mansouri, Andrew Morgan"),
    ("SOYUZ MS-16", 2020, 4, 9, 2020, 10, 22, "Anatoli Ivanishin, Ivan Vagner, Christopher Cassidy"),
    ("SOYUZ MS-17", 2020, 10, 14, 2021, 4, 17, "Sergey Ryzhikov, Sergey Kud-Sverchkov, Kathleen Rubins"),
    ("SOYUZ MS-18", 2021, 4, 9, 2022, 3, 30, "Oleg Novitsky, Pyotr Dubrov, Mark Vande Hei"),
    ("SOYUZ MS-22", 2022, 9, 21, 2023, 9, 27, "Sergey Prokopyev, Dmitry Petelin, Francisco Rubio"),
    ("SOYUZ MS-24", 2023, 9, 15, 2024, 4, 6, "Oleg Kononenko, Nikolai Chub, Loral O'Hara, Oleg Novitsky"),
    ("SOYUZ MS-25", 2024, 3, 23, 2024, 9, 23, "Oleg Novitsky, Tracy Caldwell Dyson, Oleg Kononenko, Nikolai Chub"),
    ("SOYUZ MS-26", 2024, 9, 11, 2025, 4, 20, "Aleksey Ovchinin, Ivan Vagner, Donald Pettit"),
    ("SOYUZ MS-27", 2025, 4, 8, 2025, 12, 9, "Sergey Ryzhikov, Alexey Zubritsky, Jonny Kim"),
    ("SOYUZ MS-28", 2025, 11, 27, 2026, 7, 26, "Sergey Kud-Sverchkov, Sergey Mikayev, Christopher Williams"),
    ("SOYUZ MS-29", 2026, 7, 14, 2026, 7, 14, "Pyotr Dubrov, Anna Kikina, Anil Menon"),
    ("SOYUZ TMA-1", 2002, 11, 24, 2003, 5, 4, "Nikolai Budarin, Kenneth Bowersox, Donald Pettit"),
    ("SOYUZ TMA-18M", 2015, 3, 27, 2016, 3, 2, "Sergey Volkov, Mikhail Kornienko, Scott Kelly"),
    ("SOYUZ MS-19", 2021, 4, 9, 2022, 3, 30, "Anton Shkaplerov, Pyotr Dubrov, Mark Vande Hei"),
    ("SOYUZ MS-23", 2022, 9, 21, 2023, 9, 27, "Sergey Prokopyev, Dmitry Petelin, Francisco Rubio"),
    ("SOYUZ MS-10", 2018, 10, 11, 2018, 10, 11, "Aleksey Ovchinin, Nick Hague"),
]

SHUTTLE_DATA = [
    ("STS-1", 1981, 4, 12, 1981, 4, 14, "John Young, Robert Crippen"),
    ("STS-2", 1981, 11, 12, 1981, 11, 14, "Joe Engle, Richard Truly"),
    ("STS-3", 1982, 3, 22, 1982, 3, 30, "Jack Lousma, Gordon Fullerton"),
    ("STS-4", 1982, 6, 27, 1982, 7, 4, "Ken Mattingly, Henry Hartsfield"),
    ("STS-5", 1982, 11, 11, 1982, 11, 16, "Vance Brand, Robert Overmyer, William Lenoir, Joseph Allen"),
    ("STS-6", 1983, 4, 4, 1983, 4, 9, "Paul Weitz, Karol Bobko, Story Musgrave, Donald Peterson"),
    ("STS-7", 1983, 6, 18, 1983, 6, 24, "Robert Crippen, Frederick Hauck, John Fabian, Sally Ride, Norman Thagard"),
    ("STS-8", 1983, 8, 30, 1983, 9, 5, "Richard Truly, Daniel Brandenstein, Guion Bluford, Dale Gardner, William Thornton"),
    ("STS-9", 1983, 11, 28, 1983, 12, 8, "John Young, Brewster Shaw, Robert Parker, Owen Garriott, Byron Lichtenberg, Ulf Merbold"),
    ("STS-41-B", 1984, 2, 3, 1984, 2, 11, "Vance Brand, Robert Gibson, Ronald McNair, Robert Stewart, Bruce McCandless"),
    ("STS-41-C", 1984, 4, 6, 1984, 4, 13, "Robert Crippen, Dick Scobee, Terry Hart, James van Hoften, George Nelson"),
    ("STS-41-D", 1984, 8, 30, 1984, 9, 5, "Henry Hartsfield, Michael Coats, Richard Mullane, Steven Hawley, Judith Resnik, Charles Walker"),
    ("STS-41-G", 1984, 10, 5, 1984, 10, 13, "Robert Crippen, Jon McBride, Kathryn Sullivan, Sally Ride, David Leestma, Paul Scully-Power, Marc Garneau"),
    ("STS-51-A", 1984, 11, 8, 1984, 11, 16, "Frederick Hauck, David Walker, Joseph Allen, Anna Fisher, Dale Gardner"),
    ("STS-51-C", 1985, 1, 24, 1985, 1, 27, "Ken Mattingly, Loren Shriver, Ellison Onizuka, James Buchli, Gary Payton"),
    ("STS-51-D", 1985, 4, 12, 1985, 4, 19, "Karol Bobko, Donald Williams, Rhea Seddon, David Griggs, Jeffrey Hoffman, Charles Walker, Jake Garn"),
    ("STS-51-B", 1985, 4, 29, 1985, 5, 6, "Robert Overmyer, Frederick Gregory, Don Lind, Norman Thagard, William Thornton, Lodewijk van den Berg, Taylor Wang"),
    ("STS-51-G", 1985, 6, 17, 1985, 6, 24, "Daniel Brandenstein, John Creighton, Shannon Lucid, Steven Nagel, John Fabian, Patrick Baudry, Sultan bin Salman Al Saud"),
    ("STS-51-F", 1985, 7, 29, 1985, 8, 6, "Gordon Fullerton, Roy Bridges, Karl Henize, Story Musgrave, Anthony England, Loren Acton, John-David Bartoe"),
    ("STS-51-I", 1985, 8, 27, 1985, 9, 3, "Joe Engle, Richard Covey, James van Hoften, John Lounge, William Fisher"),
    ("STS-51-J", 1985, 10, 3, 1985, 10, 7, "Karol Bobko, Ronald Grabe, David Hilmers, Robert Stewart, William Pailes"),
    ("STS-61-A", 1985, 10, 30, 1985, 11, 6, "Henry Hartsfield, Steven Nagel, Bonnie Dunbar, James Buchli, Guion Bluford, Reinhard Furrer, Ernst Messerschmid, Wubbo Ockels"),
    ("STS-61-B", 1985, 11, 27, 1985, 12, 3, "Brewster Shaw, Bryan O'Connor, Jerry Ross, Mary Cleave, Sherwood Spring, Charles Walker, Rodolfo Neri Vela"),
    ("STS-61-C", 1986, 1, 12, 1986, 1, 18, "Robert Gibson, Charles Bolden, George Nelson, Steven Hawley, Franklin Chang-Diaz, Bill Nelson, Robert Cenker"),
    ("STS-51-L", 1986, 1, 28, 1986, 1, 28, "Dick Scobee, Michael Smith, Ellison Onizuka, Judith Resnik, Ronald McNair, Gregory Jarvis, Christa McAuliffe"),
    ("STS-26", 1988, 9, 29, 1988, 10, 3, "Frederick Hauck, Richard Covey, John Lounge, David Hilmers, George Nelson"),
    ("STS-27", 1988, 12, 2, 1988, 12, 6, "Robert Gibson, Guy Gardner, William Shepherd, Jerry Ross, Richard Mullane"),
    ("STS-29", 1989, 3, 13, 1989, 3, 18, "Michael Coats, John Blaha, Robert Springer, James Buchli, James Bagian"),
    ("STS-30", 1989, 5, 4, 1989, 5, 8, "David Walker, Ronald Grabe, Mark Lee, Norman Thagard, Mary Cleave"),
    ("STS-28", 1989, 8, 8, 1989, 8, 13, "Brewster Shaw, Dick Richards, James Adamson, David Leestma, Mark Brown"),
    ("STS-34", 1989, 10, 18, 1989, 10, 23, "Donald Williams, Michael McCulley, Shannon Lucid, Franklin Chang-Diaz, Ellen Baker"),
    ("STS-33", 1989, 11, 23, 1989, 11, 28, "Frederick Gregory, John Blaha, Sonny Carter, Story Musgrave, Kathryn Thornton"),
    ("STS-32", 1990, 1, 9, 1990, 1, 20, "Daniel Brandenstein, James Wetherbee, Bonnie Dunbar, Marsha Ivins, David Low"),
    ("STS-36", 1990, 2, 28, 1990, 3, 4, "John Creighton, John Casper, Pierre Thuot, David Hilmers, Richard Mullane"),
    ("STS-31", 1990, 4, 24, 1990, 4, 29, "Loren Shriver, Charles Bolden, Bruce McCandless, Steven Hawley, Kathryn Sullivan"),
    ("STS-41", 1990, 10, 6, 1990, 10, 10, "Dick Richards, Robert Cabana, Bruce Melnick, William Shepherd, Thomas Akers"),
    ("STS-38", 1990, 11, 15, 1990, 11, 20, "Richard Covey, Frank Culbertson, Carl Meade, Robert Springer, Charles Gemar"),
    ("STS-35", 1990, 12, 2, 1990, 12, 11, "Vance Brand, Guy Gardner, Jeffrey Hoffman, John Lounge, Robert Parker, Samuel Durrance, Ronald Parise"),
    ("STS-37", 1991, 4, 5, 1991, 4, 11, "Steven Nagel, Kenneth Cameron, Linda Godwin, Jerry Ross, Jerome Apt"),
    ("STS-39", 1991, 4, 28, 1991, 5, 6, "Michael Coats, Blaine Hammond, Gregory Harbaugh, Donald McMonagle, Guion Bluford, Charles Veach, Richard Hieb"),
    ("STS-40", 1991, 6, 5, 1991, 6, 14, "Bryan O'Connor, Sidney Gutierrez, James Bagian, Tamara Jernigan, Rhea Seddon, Drew Gaffney, Millie Hughes-Fulford"),
    ("STS-43", 1991, 8, 2, 1991, 8, 11, "John Blaha, Michael Baker, Shannon Lucid, David Low, James Adamson"),
    ("STS-48", 1991, 9, 12, 1991, 9, 18, "John Creighton, Kenneth Reightler, Charles Gemar, James Buchli, Mark Brown"),
    ("STS-44", 1991, 11, 24, 1991, 12, 1, "Frederick Gregory, Terence Henricks, James Voss, Story Musgrave, Mario Runco, Thomas Hennen"),
    ("STS-42", 1992, 1, 22, 1992, 1, 30, "Ronald Grabe, Stephen Oswald, Norman Thagard, William Readdy, David Hilmers, Roberta Bondar, Ulf Merbold"),
    ("STS-45", 1992, 3, 24, 1992, 4, 2, "Charles Bolden, Brian Duffy, Kathryn Sullivan, David Leestma, Michael Foale, Dirk Frimout, Byron Lichtenberg"),
    ("STS-49", 1992, 5, 7, 1992, 5, 16, "Daniel Brandenstein, Kevin Chilton, Richard Hieb, Bruce Melnick, Pierre Thuot, Kathryn Thornton, Thomas Akers"),
    ("STS-50", 1992, 6, 25, 1992, 7, 9, "Dick Richards, Kenneth Bowersox, Bonnie Dunbar, Ellen Baker, Carl Meade, Lawrence DeLucas, Eugene Trinh"),
    ("STS-46", 1992, 7, 31, 1992, 8, 8, "Loren Shriver, Andrew Allen, Claude Nicollier, Marsha Ivins, Jeffrey Hoffman, Franklin Chang-Diaz, Franco Malerba"),
    ("STS-47", 1992, 9, 12, 1992, 9, 20, "Robert Gibson, Curtis Brown, Mark Lee, Jerome Apt, Jan Davis, Mae Jemison, Mamoru Mohri"),
    ("STS-52", 1992, 10, 22, 1992, 11, 1, "James Wetherbee, Michael Baker, Charles Veach, William Shepherd, Tamara Jernigan, Steve MacLean"),
    ("STS-53", 1992, 12, 2, 1992, 12, 9, "David Walker, Robert Cabana, Guion Bluford, Michael Clifford, James Voss"),
    ("STS-54", 1993, 1, 13, 1993, 1, 19, "John Casper, Donald McMonagle, Mario Runco, Gregory Harbaugh, Susan Helms"),
    ("STS-56", 1993, 4, 8, 1993, 4, 17, "Kenneth Cameron, Stephen Oswald, Michael Foale, Kenneth Cockrell, Ellen Ochoa"),
    ("STS-55", 1993, 4, 26, 1993, 5, 6, "Steven Nagel, Terence Henricks, Jerry Ross, Charles Precourt, Bernard Harris, Ulrich Walter, Hans Schlegel"),
    ("STS-57", 1993, 6, 21, 1993, 7, 1, "Ronald Grabe, Brian Duffy, David Low, Nancy Currie-Gregg, Peter Wisoff, Janice Voss"),
    ("STS-51", 1993, 9, 12, 1993, 9, 22, "Frank Culbertson, William Readdy, James Newman, Daniel Bursch, Carl Walz"),
    ("STS-58", 1993, 10, 18, 1993, 11, 1, "John Blaha, Richard Searfoss, Rhea Seddon, William McArthur, David Wolf, Shannon Lucid, Martin Fettman"),
    ("STS-61", 1993, 12, 2, 1993, 12, 13, "Richard Covey, Kenneth Bowersox, Kathryn Thornton, Claude Nicollier, Jeffrey Hoffman, Story Musgrave, Thomas Akers"),
    ("STS-60", 1994, 2, 3, 1994, 2, 11, "Charles Bolden, Kenneth Reightler, Jan Davis, Ronald Sega, Franklin Chang-Diaz, Sergei Krikalev"),
    ("STS-62", 1994, 3, 4, 1994, 3, 18, "John Casper, Andrew Allen, Pierre Thuot, Charles Gemar, Marsha Ivins"),
    ("STS-59", 1994, 4, 9, 1994, 4, 20, "Sidney Gutierrez, Kevin Chilton, Linda Godwin, Jerome Apt, Michael Clifford, Thomas Jones"),
    ("STS-65", 1994, 7, 8, 1994, 7, 23, "Robert Cabana, James Halsell, Richard Hieb, Carl Walz, Leroy Chiao, Donald Thomas, Chiaki Mukai"),
    ("STS-64", 1994, 9, 9, 1994, 9, 20, "Dick Richards, Blaine Hammond, Jerry Linenger, Susan Helms, Carl Meade, Mark Lee"),
    ("STS-68", 1994, 9, 30, 1994, 10, 11, "Michael Baker, Terrence Wilcutt, Steven Smith, Daniel Bursch, Peter Wisoff, Thomas Jones"),
    ("STS-66", 1994, 11, 3, 1994, 11, 14, "Donald McMonagle, Curtis Brown, Ellen Ochoa, Joseph Tanner, Jean-Francois Clervoy, Scott Parazynski"),
    ("STS-63", 1995, 2, 3, 1995, 2, 11, "James Wetherbee, Eileen Collins, Bernard Harris, Michael Foale, Janice Voss, Vladimir Titov"),
    ("STS-67", 1995, 3, 2, 1995, 3, 18, "Stephen Oswald, William Gregory, John Grunsfeld, Wendy Lawrence, Tamara Jernigan, Samuel Durrance, Ronald Parise"),
    ("STS-71", 1995, 6, 27, 1995, 7, 7, "Robert Gibson, Charles Precourt, Ellen Baker, Gregory Harbaugh, Bonnie Dunbar, Anatoly Solovyev, Nikolai Budarin, Gennady Strekalov, Vladimir Dezhurov, Norman Thagard"),
    ("STS-70", 1995, 7, 13, 1995, 7, 22, "Terence Henricks, Kevin Kregel, Nancy Currie, Donald Thomas, Mary Ellen Weber"),
    ("STS-69", 1995, 9, 7, 1995, 9, 18, "David Walker, Kenneth Cockrell, James Voss, James Newman, Michael Gernhardt"),
    ("STS-73", 1995, 10, 20, 1995, 11, 5, "Kenneth Bowersox, Kent Rominger, Kathryn Thornton, Catherine Coleman, Michael Lopez-Alegria, Fred Leslie, Albert Sacco"),
    ("STS-74", 1995, 11, 12, 1995, 11, 20, "Kenneth Cameron, James Halsell, Chris Hadfield, Jerry Ross, William McArthur"),
    ("STS-72", 1996, 1, 11, 1996, 1, 20, "Brian Duffy, Brent Jett, Leroy Chiao, Winston Scott, Koichi Wakata, Daniel Barry"),
    ("STS-75", 1996, 2, 22, 1996, 3, 9, "Andrew Allen, Scott Horowitz, Jeffrey Hoffman, Maurizio Cheli, Claude Nicollier, Franklin Chang-Diaz, Umberto Guidoni"),
    ("STS-76", 1996, 3, 22, 1996, 3, 31, "Kevin Chilton, Richard Searfoss, Ronald Sega, Michael Clifford, Linda Godwin, Shannon Lucid"),
    ("STS-77", 1996, 5, 19, 1996, 5, 29, "John Casper, Curtis Brown, Andrew Thomas, Daniel Bursch, Mario Runco, Marc Garneau"),
    ("STS-78", 1996, 6, 20, 1996, 7, 7, "Terence Henricks, Kevin Kregel, Richard Linnehan, Susan Helms, Charles Brady, Jean-Jacques Favier, Robert Thirsk"),
    ("STS-79", 1996, 9, 16, 1996, 9, 26, "William Readdy, Terrence Wilcutt, Jerome Apt, Thomas Akers, Carl Walz, John Blaha, Shannon Lucid"),
    ("STS-80", 1996, 11, 19, 1996, 12, 7, "Kenneth Cockrell, Kent Rominger, Story Musgrave, Thomas Jones, Tamara Jernigan"),
    ("STS-81", 1997, 1, 12, 1997, 1, 22, "Michael Baker, Brent Jett, Peter Wisoff, John Grunsfeld, Marsha Ivins, Jerry Linenger, John Blaha"),
    ("STS-82", 1997, 2, 11, 1997, 2, 21, "Kenneth Bowersox, Scott Horowitz, Joseph Tanner, Steven Hawley, Gregory Harbaugh, Mark Lee, Steven Smith"),
    ("STS-83", 1997, 4, 4, 1997, 4, 8, "James Halsell, Susan Still, Janice Voss, Michael Gernhardt, Donald Thomas, Roger Crouch, Gregory Linteris"),
    ("STS-84", 1997, 5, 15, 1997, 5, 24, "Charles Precourt, Eileen Collins, Jean-Francois Clervoy, Carlos Noriega, Edward Lu, Yelena Kondakova, Michael Foale, Jerry Linenger"),
    ("STS-94", 1997, 7, 1, 1997, 7, 17, "James Halsell, Susan Still, Janice Voss, Michael Gernhardt, Donald Thomas, Roger Crouch, Gregory Linteris"),
    ("STS-85", 1997, 8, 7, 1997, 8, 19, "Curtis Brown, Kent Rominger, Jan Davis, Robert Curbeam, Stephen Robinson, Bjarni Tryggvason"),
    ("STS-86", 1997, 9, 26, 1997, 10, 6, "James Wetherbee, Michael Bloomfield, Vladimir Titov, Scott Parazynski, Jean-Loup Chretien, Wendy Lawrence, David Wolf, Michael Foale"),
    ("STS-87", 1997, 11, 19, 1997, 12, 5, "Kevin Kregel, Steven Lindsey, Winston Scott, Kalpana Chawla, Takao Doi, Leonid Kadeniuk"),
    ("STS-89", 1998, 1, 23, 1998, 1, 31, "Terrence Wilcutt, Joe Edwards, James Reilly, Michael Anderson, Bonnie Dunbar, Salizhan Sharipov, Andrew Thomas, David Wolf"),
    ("STS-90", 1998, 4, 17, 1998, 5, 3, "Richard Searfoss, Scott Altman, Dafydd Williams, Kathryn Hire, Richard Linnehan, Jay Buckey, James Pawelczyk"),
    ("STS-91", 1998, 6, 2, 1998, 6, 12, "Charles Precourt, Dominic Gorie, Franklin Chang-Diaz, Wendy Lawrence, Janet Kavandi, Valery Ryumin, Andrew Thomas"),
    ("STS-95", 1998, 10, 29, 1998, 11, 7, "Curtis Brown, Steven Lindsey, Pedro Duque, Scott Parazynski, Stephen Robinson, Chiaki Mukai, John Glenn"),
    ("STS-88", 1998, 12, 4, 1998, 12, 16, "Robert Cabana, Frederick Sturckow, Jerry Ross, Nancy Currie, James Newman, Sergei Krikalev"),
    ("STS-96", 1999, 5, 27, 1999, 6, 6, "Kent Rominger, Rick Husband, Daniel Barry, Ellen Ochoa, Tamara Jernigan, Julie Payette, Valeri Tokarev"),
    ("STS-93", 1999, 7, 23, 1999, 7, 28, "Eileen Collins, Jeffrey Ashby, Michel Tognini, Steven Hawley, Catherine Coleman"),
    ("STS-103", 1999, 12, 20, 1999, 12, 28, "Curtis Brown, Scott Kelly, John Grunsfeld, Jean-Francois Clervoy, Michael Foale, Steven Smith, Claude Nicollier"),
    ("STS-99", 2000, 2, 11, 2000, 2, 22, "Kevin Kregel, Dominic Gorie, Gerhard Thiele, Janet Kavandi, Janice Voss, Mamoru Mohri"),
    ("STS-101", 2000, 5, 19, 2000, 5, 29, "James Halsell, Scott Horowitz, Mary Ellen Weber, Jeffrey Williams, James Voss, Susan Helms, Yuri Usachov"),
    ("STS-106", 2000, 9, 8, 2000, 9, 20, "Terrence Wilcutt, Scott Altman, Edward Lu, Richard Mastracchio, Daniel Burbank, Yuri Malenchenko, Boris Morukov"),
    ("STS-92", 2000, 10, 11, 2000, 10, 24, "Brian Duffy, Pamela Melroy, Koichi Wakata, William McArthur, Peter Wisoff, Michael Lopez-Alegria, Leroy Chiao"),
    ("STS-97", 2000, 12, 1, 2000, 12, 11, "Brent Jett, Michael Bloomfield, Joseph Tanner, Marc Garneau, Carlos Noriega"),
    ("STS-98", 2001, 2, 7, 2001, 2, 20, "Kenneth Cockrell, Mark Polansky, Robert Curbeam, Marsha Ivins, Thomas Jones"),
    ("STS-102", 2001, 3, 8, 2001, 3, 21, "James Wetherbee, James Kelly, Andrew Thomas, Paul Richards, Yuri Usachov, James Voss, Susan Helms, William Shepherd, Yuri Gidzenko, Sergei Krikalev"),
    ("STS-100", 2001, 4, 19, 2001, 5, 1, "Kent Rominger, Jeffrey Ashby, Chris Hadfield, John Phillips, Scott Parazynski, Umberto Guidoni, Yury Lonchakov"),
    ("STS-104", 2001, 7, 12, 2001, 7, 25, "Steven Lindsey, Charles Hobaugh, Michael Gernhardt, Janet Kavandi, James Reilly"),
    ("STS-105", 2001, 8, 10, 2001, 8, 22, "Scott Horowitz, Frederick Sturckow, Patrick Forrester, Daniel Barry, Frank Culbertson, Mikhail Tyurin, Vladimir Dezhurov, Yuri Usachov, James Voss, Susan Helms"),
    ("STS-108", 2001, 12, 5, 2001, 12, 17, "Dominic Gorie, Mark Kelly, Linda Godwin, Daniel Tani, Yury Onufriyenko, Carl Walz, Daniel Bursch, Frank Culbertson, Mikhail Tyurin, Vladimir Dezhurov"),
    ("STS-109", 2002, 3, 1, 2002, 3, 12, "Scott Altman, Duane Carey, John Grunsfeld, Nancy Currie, Richard Linnehan, James Newman, Mike Massimino"),
    ("STS-110", 2002, 4, 8, 2002, 4, 19, "Michael Bloomfield, Stephen Frick, Rex Walheim, Ellen Ochoa, Lee Morin, Jerry Ross, Steven Smith"),
    ("STS-111", 2002, 6, 5, 2002, 6, 19, "Kenneth Cockrell, Paul Lockhart, Philippe Perrin, Franklin Chang-Diaz, Valery Korzun, Peggy Whitson, Sergey Treshchov, Yury Onufriyenko, Carl Walz, Daniel Bursch"),
    ("STS-112", 2002, 10, 7, 2002, 10, 18, "Jeffrey Ashby, Pamela Melroy, David Wolf, Sandra Magnus, Piers Sellers, Fyodor Yurchikhin"),
    ("STS-113", 2002, 11, 24, 2002, 12, 7, "James Wetherbee, Paul Lockhart, Michael Lopez-Alegria, John Herrington, Kenneth Bowersox, Nikolai Budarin, Donald Pettit, Valery Korzun, Peggy Whitson, Sergey Treshchov"),
    ("STS-107", 2003, 1, 16, 2003, 2, 1, "Rick Husband, William McCool, David Brown, Kalpana Chawla, Michael Anderson, Laurel Clark, Ilan Ramon"),
    ("STS-114", 2005, 7, 26, 2005, 8, 9, "Eileen Collins, James Kelly, Soichi Noguchi, Stephen Robinson, Andrew Thomas, Wendy Lawrence, Charles Camarda"),
    ("STS-121", 2006, 7, 4, 2006, 7, 17, "Steven Lindsey, Mark Kelly, Michael Fossum, Lisa Nowak, Stephanie Wilson, Piers Sellers, Thomas Reiter"),
    ("STS-115", 2006, 9, 9, 2006, 9, 21, "Brent Jett, Christopher Ferguson, Steve MacLean, Daniel Burbank, Joseph Tanner, Heidemarie Stefanyshyn-Piper"),
    ("STS-116", 2006, 12, 10, 2006, 12, 22, "Mark Polansky, William Oefelein, Nicholas Patrick, Robert Curbeam, Christer Fuglesang, Joan Higginbotham, Sunita Williams, Thomas Reiter"),
    ("STS-117", 2007, 6, 8, 2007, 6, 22, "Frederick Sturckow, Lee Archambault, Patrick Forrester, Steven Swanson, John Olivas, James Reilly, Clayton Anderson, Sunita Williams"),
    ("STS-118", 2007, 8, 8, 2007, 8, 21, "Scott Kelly, Charles Hobaugh, Tracy Caldwell Dyson, Richard Mastracchio, Dafydd Williams, Barbara Morgan, Alvin Drew"),
    ("STS-120", 2007, 10, 23, 2007, 11, 7, "Pamela Melroy, George Zamka, Douglas Wheelock, Stephanie Wilson, Scott Parazynski, Paolo Nespoli, Daniel Tani, Clayton Anderson"),
    ("STS-122", 2008, 2, 7, 2008, 2, 20, "Stephen Frick, Alan Poindexter, Leland Melvin, Rex Walheim, Hans Schlegel, Stanley Love, Leopold Eyharts, Daniel Tani"),
    ("STS-123", 2008, 3, 11, 2008, 3, 27, "Dominic Gorie, Gregory H. Johnson, Robert Behnken, Michael Foreman, Richard Linnehan, Takao Doi, Garrett Reisman, Leopold Eyharts"),
    ("STS-124", 2008, 5, 31, 2008, 6, 14, "Mark Kelly, Kenneth Ham, Karen Nyberg, Ronald Garan, Michael Fossum, Akihiko Hoshide, Gregory Chamitoff, Garrett Reisman"),
    ("STS-126", 2008, 11, 15, 2008, 11, 30, "Christopher Ferguson, Eric Boe, Donald Pettit, Stephen Bowen, Heidemarie Stefanyshyn-Piper, Robert Kimbrough, Sandra Magnus, Gregory Chamitoff"),
    ("STS-119", 2009, 3, 15, 2009, 3, 28, "Lee Archambault, Dominic Antonelli, Joseph Acaba, Steven Swanson, Richard Arnold, John Phillips, Koichi Wakata, Sandra Magnus"),
    ("STS-125", 2009, 5, 11, 2009, 5, 24, "Scott Altman, Gregory C. Johnson, Michael Good, Megan McArthur, John Grunsfeld, Mike Massimino, Andrew Feustel"),
    ("STS-127", 2009, 7, 15, 2009, 7, 31, "Mark Polansky, Douglas Hurley, Christopher Cassidy, Julie Payette, Thomas Marshburn, David Wolf, Timothy Kopra, Koichi Wakata"),
    ("STS-128", 2009, 8, 29, 2009, 9, 12, "Frederick Sturckow, Kevin Ford, Patrick Forrester, Jose Hernandez, John Olivas, Christer Fuglesang, Nicole Stott, Timothy Kopra"),
    ("STS-129", 2009, 11, 16, 2009, 11, 27, "Charles Hobaugh, Barry Wilmore, Leland Melvin, Randolph Bresnik, Michael Foreman, Robert Satcher, Nicole Stott"),
    ("STS-130", 2010, 2, 8, 2010, 2, 22, "George Zamka, Terry Virts, Kathryn Hire, Stephen Robinson, Nicholas Patrick, Robert Behnken"),
    ("STS-131", 2010, 4, 5, 2010, 4, 20, "Alan Poindexter, James Dutton, Richard Mastracchio, Dorothy Metcalf-Lindenburger, Stephanie Wilson, Naoko Yamazaki, Clayton Anderson"),
    ("STS-132", 2010, 5, 14, 2010, 5, 26, "Kenneth Ham, Dominic Antonelli, Garrett Reisman, Michael Good, Stephen Bowen, Piers Sellers"),
    ("STS-133", 2011, 2, 24, 2011, 3, 9, "Steven Lindsey, Eric Boe, Nicole Stott, Alvin Drew, Michael Barratt, Stephen Bowen"),
    ("STS-134", 2011, 5, 16, 2011, 6, 1, "Mark Kelly, Gregory H. Johnson, Michael Fincke, Roberto Vittori, Andrew Feustel, Gregory Chamitoff"),
    ("STS-135", 2011, 7, 8, 2011, 7, 21, "Christopher Ferguson, Douglas Hurley, Sandra Magnus, Rex Walheim"),
]

# Dates are UTC; Artemis II splashed down Apr 10 local, Apr 11 UTC.
ARTEMIS_DATA = [
    ("ARTEMIS II", 2026, 4, 1, 2026, 4, 11, "Reid Wiseman, Victor Glover, Christina Koch, Jeremy Hansen"),
]

# Crew Dragon and Starliner flights to the ISS. Starliner CFT is
# LAUNCH_ONLY: Wilmore and Williams returned on Crew-9, whose splashdown is
# stored as its land time.
COMMERCIAL_DATA = [
    ("SPACEX DEMO-2", 2020, 5, 30, 2020, 8, 2, "Douglas Hurley, Robert Behnken"),
    ("SPACEX CREW-1", 2020, 11, 16, 2021, 5, 2, "Michael Hopkins, Victor Glover, Soichi Noguchi, Shannon Walker"),
    ("SPACEX CREW-2", 2021, 4, 23, 2021, 11, 9, "Shane Kimbrough, Megan McArthur, Akihiko Hoshide, Thomas Pesquet"),
    ("SPACEX CREW-3", 2021, 11, 11, 2022, 5, 6, "Raja Chari, Thomas Marshburn, Kayla Barron, Matthias Maurer"),
    ("SPACEX CREW-4", 2022, 4, 27, 2022, 10, 14, "Kjell Lindgren, Robert Hines, Samantha Cristoforetti, Jessica Watkins"),
    ("SPACEX CREW-5", 2022, 10, 5, 2023, 3, 12, "Nicole Mann, Josh Cassada, Koichi Wakata, Anna Kikina"),
    ("SPACEX CREW-6", 2023, 3, 2, 2023, 9, 4, "Stephen Bowen, Warren Hoburg, Sultan Alneyadi, Andrey Fedyaev"),
    ("SPACEX CREW-7", 2023, 8, 26, 2024, 3, 12, "Jasmin Moghbeli, Andreas Mogensen, Satoshi Furukawa, Konstantin Borisov"),
    ("SPACEX CREW-8", 2024, 3, 4, 2024, 10, 25, "Matthew Dominick, Michael Barratt, Jeanette Epps, Alexander Grebenkin"),
    ("STARLINER CFT", 2024, 6, 5, 2025, 3, 18, "Barry Wilmore, Sunita Williams"),
    ("SPACEX CREW-9", 2024, 9, 28, 2025, 3, 18, "Nick Hague, Aleksandr Gorbunov, Barry Wilmore, Sunita Williams"),
    ("SPACEX CREW-10", 2025, 3, 14, 2025, 8, 9, "Anne McClain, Nichole Ayers, Takuya Onishi, Kirill Peskov"),
    ("SPACEX CREW-11", 2025, 8, 1, 2026, 1, 15, "Zena Cardman, Michael Fincke, Kimiya Yui, Oleg Platonov"),
    ("SPACEX CREW-12", 2026, 2, 13, 2026, 2, 13, "Jessica Meir, Jack Hathaway, Sophie Adenot, Andrey Fedyaev"),
]

# Private orbital flights on Crew Dragon. Suborbital flights are not included.
PRIVATE_DATA = [
    ("INSPIRATION4", 2021, 9, 16, 2021, 9, 18, "Jared Isaacman, Sian Proctor, Hayley Arceneaux, Chris Sembroski"),
    ("AXIOM-1", 2022, 4, 8, 2022, 4, 25, "Michael Lopez-Alegria, Larry Connor, Mark Pathy, Eytan Stibbe"),
    ("AXIOM-2", 2023, 5, 21, 2023, 5, 31, "Peggy Whitson, John Shoffner, Ali AlQarni, Rayyanah Barnawi"),
    ("AXIOM-3", 2024, 1, 18, 2024, 2, 9, "Michael Lopez-Alegria, Walter Villadei, Alper Gezeravci, Marcus Wandt"),
    ("POLARIS DAWN", 2024, 9, 10, 2024, 9, 15, "Jared Isaacman, Scott Poteet, Sarah Gillis, Anna Menon"),
    ("AXIOM-4", 2025, 6, 25, 2025, 7, 15, "Peggy Whitson, Shubhanshu Shukla, Slawosz Uznanski, Tibor Kapu"),
]

PRIVATE_SPACECRAFT = {
    "INSPIRATION4": ("DRAGON RESILIENCE", "SPACEX"),
    "AXIOM-1": ("DRAGON ENDEAVOUR", "AXIOM SPACE"),
    "AXIOM-2": ("DRAGON FREEDOM", "AXIOM SPACE"),
    "AXIOM-3": ("DRAGON FREEDOM", "AXIOM SPACE"),
    "POLARIS DAWN": ("DRAGON RESILIENCE", "SPACEX"),
    "AXIOM-4": ("DRAGON GRACE", "AXIOM SPACE"),
}

# Never flew -- see TRIBUTE_NAMES.
TRIBUTE_DATA = [
    ("APOLLO 1", 1967, 1, 27, 1967, 1, 27, "Gus Grissom, Ed White, Roger Chaffee"),
]

ALL_MISSIONS = MERCURY_GEMINI_APOLLO_DATA + SOYUZ_DATA + SHUTTLE_DATA + ARTEMIS_DATA + COMMERCIAL_DATA + PRIVATE_DATA + TRIBUTE_DATA


def pad_int(n, width):
    s = str(n)
    sign = ""
    if s[0] == "-":
        sign = "-"
        s = s[1:]
    for i in range(width):
        if len(s) >= width:
            break
        s = "0" + s
    return sign + s


# Integer hash, for a shuffle that looks random but every page of a
# render agrees on.
def scramble(x):
    x = x & 0xFFFFFFFF
    x = ((x ^ 61) ^ (x >> 16)) & 0xFFFFFFFF
    x = (x + (x << 3)) & 0xFFFFFFFF
    x = (x ^ (x >> 4)) & 0xFFFFFFFF
    x = (x * 0x27d4eb2d) & 0xFFFFFFFF
    x = (x ^ (x >> 15)) & 0xFFFFFFFF
    return x


def rotation_index(ctx, n):
    # The day's choices in a fresh shuffled order each day, stepping to the
    # next one every hour: it looks random, but on a busy day every event
    # gets its turn before any repeats and none comes up twice in a row.
    # Hourly so it holds whatever refresh the panel uses, up to an hour.
    # The day is counted on Eastern Standard Time, close enough for when
    # the shuffle changes.
    day = (ctx.now.unix - 5 * 3600) // 86400
    order = sorted(range(n), key = lambda k: scramble(day * 4096 + k))
    return order[(ctx.now.unix // 3600) % n]


def days_from_civil(y, m, d):
    yy = (y - 1) if m <= 2 else y
    era = (yy // 400) if yy >= 0 else ((yy - 399) // 400)
    yoe = yy - era * 400
    mm = (m + 9) if m <= 2 else (m - 3)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468


# Inverse of days_from_civil: day count since 1970-01-01 -> (y, m, d).
def civil_from_days(z):
    z += 719468
    era = (z // 146097) if z >= 0 else ((z - 146096) // 146097)
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    y = yoe + era * 400
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = (mp + 3) if mp < 10 else (mp - 9)
    y = (y + 1) if m <= 2 else y
    return y, m, d


def is_leap_year(y):
    return (y % 4 == 0) and (y % 100 != 0 or y % 400 == 0)


def days_in_month(y, m):
    if m == 2:
        return 29 if is_leap_year(y) else 28
    if m in (4, 6, 9, 11):
        return 30
    return 31


# 0=Sunday .. 6=Saturday. days_from_civil(1970, 1, 1) == 0, and Jan 1 1970
# was a Thursday, so weekday 0 (Sunday) is 4 days *before* that epoch day.
def weekday(y, m, d):
    return (days_from_civil(y, m, d) + 4) % 7


# Day-of-month of the n-th Sunday (n = 1..5) in a given month/year.
def nth_sunday(y, m, n):
    count = 0
    for d in range(1, days_in_month(y, m) + 1):
        if weekday(y, m, d) == 0:
            count += 1
            if count == n:
                return d
    return -1


def last_sunday(y, m):
    for d in range(days_in_month(y, m), 0, -1):
        if weekday(y, m, d) == 0:
            return d
    return -1


# US DST rules since 1961:
#  - before 1967 and 1967-1973: last Sunday in April to last Sunday in October
#  - 1974: year-round from Jan 6; 1975: Feb 23 to Oct 26
#  - 1976-1986: last Sunday in April to last Sunday in October
#  - 1987-2006: first Sunday in April to last Sunday in October
#  - 2007+: second Sunday in March to first Sunday in November
# Decides the day only, not the 2 AM changeover.
def msk_permanent_plus4(y, m, d):
    today = days_from_civil(y, m, d)
    return days_from_civil(2011, 3, 27) <= today and today < days_from_civil(2014, 10, 26)


def is_dst(y, m, d, zone):
    # Moscow time:
    #  - 1992-1995: summer time last Sunday in March to last Sunday in September
    #  - 1996-2010: last Sunday in March to last Sunday in October
    #  - 2011-03-27 to 2014-10-26: permanent UTC+4
    #  - after that: permanent UTC+3
    if zone == "MSK":
        today_msk = days_from_civil(y, m, d)
        if y >= 1992 and y <= 1995:
            return days_from_civil(y, 3, last_sunday(y, 3)) <= today_msk and today_msk < days_from_civil(y, 9, last_sunday(y, 9))
        if y >= 1996 and y <= 2010:
            return days_from_civil(y, 3, last_sunday(y, 3)) <= today_msk and today_msk < days_from_civil(y, 10, last_sunday(y, 10))
        return msk_permanent_plus4(y, m, d)
    today = days_from_civil(y, m, d)
    if y < 1967:
        # Before 1967, Florida had no DST; California did (same window as above).
        if zone == "EASTERN":
            return False
        start = days_from_civil(y, 4, last_sunday(y, 4))
        end = days_from_civil(y, 10, last_sunday(y, 10))
        return start <= today and today < end
    if y == 1974:
        start = days_from_civil(1974, 1, 6)
        end = days_from_civil(1974, 10, 27)
        return start <= today and today < end
    if y == 1975:
        start = days_from_civil(1975, 2, 23)
        end = days_from_civil(1975, 10, 26)
        return start <= today and today < end
    if y <= 1986:
        start = days_from_civil(y, 4, last_sunday(y, 4))
        end = days_from_civil(y, 10, last_sunday(y, 10))
        return start <= today and today < end
    if y <= 2006:
        start = days_from_civil(y, 4, nth_sunday(y, 4, 1))
        end = days_from_civil(y, 10, last_sunday(y, 10))
        return start <= today and today < end
    start = days_from_civil(y, 3, nth_sunday(y, 3, 2))
    end = days_from_civil(y, 11, nth_sunday(y, 11, 1))
    return start <= today and today < end


# Standard-time UTC offsets. Eastern: Cape/KSC and Atlantic splashdowns.
# Pacific: Edwards and Pacific splashdowns. Mountain: White Sands. MSK:
# Baikonur.
ZONE_STD_OFFSET = {
    "EASTERN": -5,
    "PACIFIC": -8,
    "MOUNTAIN": -7,
    "MSK": 3,
    "CENTRAL": -6,
}

ZONE_ABBR = {
    "EASTERN": ("EST", "EDT"),
    "PACIFIC": ("PST", "PDT"),
    "MOUNTAIN": ("MST", "MDT"),
    "MSK": ("MSK", "MSD"),
    "CENTRAL": ("CST", "CDT"),
}


# UTC -> local date, time and zone abbreviation. The first pass estimates
# the local day to pick the DST rule; the second applies it.
def utc_to_local(y, m, d, hh, mm, zone):
    std_offset = ZONE_STD_OFFSET[zone]
    day_ord = days_from_civil(y, m, d)

    approx_total = hh * 60 + mm + std_offset * 60
    approx_day = day_ord
    if approx_total < 0:
        approx_total += 24 * 60
        approx_day -= 1
    elif approx_total >= 24 * 60:
        approx_total -= 24 * 60
        approx_day += 1
    ay, am, ad = civil_from_days(approx_day)

    offset = std_offset + (1 if is_dst(ay, am, ad, zone) else 0)
    total = hh * 60 + mm + offset * 60
    final_day = day_ord
    if total < 0:
        total += 24 * 60
        final_day -= 1
    elif total >= 24 * 60:
        total -= 24 * 60
        final_day += 1
    fy, fm, fd = civil_from_days(final_day)
    lh = total // 60
    lmin = total % 60

    std_abbr, dst_abbr = ZONE_ABBR[zone]
    abbr = dst_abbr if is_dst(ay, am, ad, zone) else std_abbr
    if zone == "MSK" and msk_permanent_plus4(ay, am, ad):
        abbr = std_abbr
    return fy, fm, fd, lh, lmin, abbr


def format_clock(hh, mm, ss):
    period = "PM" if hh >= 12 else "AM"
    h12 = hh % 12
    if h12 == 0:
        h12 = 12
    return str(h12) + ":" + pad_int(mm, 2) + ":" + pad_int(ss, 2) + " " + period


# Fatal missions: no "LANDED" label.
END_LABEL_OVERRIDE = {
    "STS-51-L": "LOST",
    "STS-107": "LOST",
    "APOLLO 1": "LOST",
}

# Phase of flight each lost mission was lost in, reported in Eastern time.
LOST_PHASE = {
    "STS-51-L": "ASCENT",
    "STS-107": "REENTRY",
    "APOLLO 1": "A LAUNCH PAD TEST",
}

# Mercury and Gemini launched from Cape Canaveral; everything else here
# from KSC unless noted.
EARLY_CAPE_NAMES = [
    "FREEDOM 7", "LIBERTY BELL 7", "FRIENDSHIP 7", "AURORA 7", "SIGMA 7", "FAITH 7",
    "GEMINI 3", "GEMINI 4", "GEMINI 5", "GEMINI 7", "GEMINI 6", "GEMINI 8",
    "GEMINI 9A", "GEMINI 10", "GEMINI 11", "GEMINI 12",
]

MERCURY_NAMES = ["FREEDOM 7", "LIBERTY BELL 7", "FRIENDSHIP 7", "AURORA 7", "SIGMA 7", "FAITH 7"]

GEMINI_NAMES = [
    "GEMINI 3", "GEMINI 4", "GEMINI 5", "GEMINI 7", "GEMINI 6", "GEMINI 8",
    "GEMINI 9A", "GEMINI 10", "GEMINI 11", "GEMINI 12",
]

# Artemis uses Shuttle-style crew pages but is not in ORBITER, since it
# splashes down instead of landing on a runway.
ARTEMIS_NAMES = ["ARTEMIS II"]

# STS-1 to STS-4: 2-person crews with ejection seats. Pages 5-6 show the
# backup crew and the shared OFT fact.
OFT_NAMES = ["STS-1", "STS-2", "STS-3", "STS-4"]

# STS-4 had no backup crew; page 5 shows this instead.
OFT_NO_BACKUP_FACT = "FIRST CLASSIFIED PAYLOAD"

# Crew positions by program:
#  - Mercury: PLT. Gemini: CP, PLT.
#  - Apollo: CDR, CMP, LMP. Skylab: CDR, SPT, PLT. Apollo-Soyuz: CDR, CMP, DMP.
#  - Shuttle: CDR, PLT, then MS1, MS2... (overrides below).
APOLLO_ROLES = ["CDR", "CMP", "LMP"]
SKYLAB_ROLES = ["CDR", "SPT", "PLT"]
ASTP_ROLES = ["CDR", "CMP", "DMP"]

# Roles that differ from the positional default: Apollo 11's crew is
# stored in Armstrong/Aldrin/Collins order, and Shuttle entries follow
# Wikipedia's "List of Space Shuttle crews". Station crew riding a Shuttle
# up or down only are tagged via CREW_SWAP instead.
CREW_ROLE_OVERRIDE = {
    "APOLLO 11": {
        "Buzz Aldrin": "LMP",
        "Michael Collins": "CMP",
    },
    # Pre-Apollo 7 titles: Command Pilot, Senior Pilot, Pilot.
    "APOLLO 1": {
        "Gus Grissom": "CP",
        "Ed White": "SP",
        "Roger Chaffee": "PLT",
        # Backup crew (see BACKUP_CREW) -- same pre-Apollo 7 title scheme.
        "Wally Schirra": "CP",
        "Donn Eisele": "SP",
        "Walter Cunningham": "PLT",
    },
    "STS-5": {
        "William Lenoir": "MS2",
        "Joseph Allen": "MS1",
    },
    "STS-6": {
        "Story Musgrave": "MS2",
        "Donald Peterson": "MS1",
    },
    "STS-8": {
        "Guion Bluford": "MS2",
        "Dale Gardner": "MS1",
    },
    "STS-9": {
        "Robert Parker": "MS2",
        "Owen Garriott": "MS1",
        "Byron Lichtenberg": "PS2",
        "Ulf Merbold": "PS1",
    },
    "STS-41-B": {
        "Ronald McNair": "MS2",
        "Robert Stewart": "MS3",
        "Bruce McCandless": "MS1",
    },
    "STS-41-C": {
        "Terry Hart": "MS3",
        "George Nelson": "MS1",
    },
    "STS-41-D": {
        "Charles Walker": "PS",
    },
    "STS-41-G": {
        "Paul Scully-Power": "PS2",
        "Marc Garneau": "PS1",
    },
    "STS-51-A": {
        "Joseph Allen": "MS3",
        "Anna Fisher": "MS1",
        "Dale Gardner": "MS2",
    },
    "STS-51-C": {
        # USAF Manned Spaceflight Engineer.
        "Gary Payton": "MSE",
    },
    "STS-51-D": {
        "Charles Walker": "PS1",
        "Jake Garn": "PS2",
    },
    "STS-51-B": {
        "Lodewijk van den Berg": "PS1",
        "Taylor Wang": "PS2",
    },
    "STS-51-G": {
        "Steven Nagel": "MS3",
        "John Fabian": "MS2",
        "Patrick Baudry": "PS1",
        "Sultan bin Salman Al Saud": "PS2",
    },
    "STS-51-F": {
        "Karl Henize": "MS3",
        "Story Musgrave": "MS1",
        "Anthony England": "MS2",
        "Loren Acton": "PS1",
        "John-David Bartoe": "PS2",
    },
    "STS-51-J": {
        "William Pailes": "MSE",
    },
    "STS-61-A": {
        "Reinhard Furrer": "PS1",
        "Ernst Messerschmid": "PS2",
        "Wubbo Ockels": "PS3",
    },
    "STS-61-B": {
        "Charles Walker": "PS2",
        "Rodolfo Neri Vela": "PS1",
    },
    "STS-61-C": {
        "George Nelson": "MS3",
        "Franklin Chang-Diaz": "MS1",
        "Bill Nelson": "PS2",
        "Robert Cenker": "PS1",
    },
    "STS-51-L": {
        "Gregory Jarvis": "PS2",
        "Christa McAuliffe": "PS1",
    },
    "STS-26": {
        "David Hilmers": "MS3",
        "George Nelson": "MS2",
    },
    "STS-27": {
        "William Shepherd": "MS3",
        "Richard Mullane": "MS1",
    },
    "STS-29": {
        "Robert Springer": "MS3",
        "James Bagian": "MS1",
    },
    "STS-30": {
        "Mark Lee": "MS3",
        "Norman Thagard": "MS1",
        "Mary Cleave": "MS2",
    },
    "STS-34": {
        "Shannon Lucid": "MS2",
        "Franklin Chang-Diaz": "MS1",
    },
    "STS-33": {
        "Sonny Carter": "MS2",
        "Story Musgrave": "MS1",
    },
    "STS-32": {
        "Marsha Ivins": "MS3",
        "David Low": "MS2",
    },
    "STS-36": {
        "Pierre Thuot": "MS3",
        "Richard Mullane": "MS1",
    },
    "STS-31": {
        "Bruce McCandless": "MS2",
        "Steven Hawley": "MS1",
    },
    "STS-41": {
        "Bruce Melnick": "MS2",
        "William Shepherd": "MS1",
    },
    "STS-38": {
        "Carl Meade": "MS2",
        "Robert Springer": "MS1",
    },
    "STS-35": {
        "Samuel Durrance": "PS1",
        "Ronald Parise": "PS2",
    },
    "STS-37": {
        "Linda Godwin": "MS3",
        "Jerry Ross": "MS1",
        "Jerome Apt": "MS2",
    },
    "STS-39": {
        "Gregory Harbaugh": "MS2",
        "Donald McMonagle": "MS4",
        "Guion Bluford": "MS1",
        "Charles Veach": "MS5",
        "Richard Hieb": "MS3",
    },
    "STS-40": {
        "Drew Gaffney": "PS1",
        "Millie Hughes-Fulford": "PS2",
    },
    "STS-43": {
        "David Low": "MS3",
        "James Adamson": "MS2",
    },
    "STS-48": {
        "Charles Gemar": "MS2",
        "James Buchli": "MS1",
    },
    "STS-44": {
        "James Voss": "MS3",
        "Story Musgrave": "MS1",
        "Mario Runco": "MS2",
        "Thomas Hennen": "PS",
    },
    "STS-42": {
        "William Readdy": "MS3",
        "David Hilmers": "MS2",
        "Roberta Bondar": "PS1",
        "Ulf Merbold": "PS2",
    },
    "STS-45": {
        "Kathryn Sullivan": "PC",
        "Dirk Frimout": "PS2",
        "Byron Lichtenberg": "PS1",
    },
    "STS-49": {
        "Richard Hieb": "MS3",
        "Bruce Melnick": "MS5",
        "Pierre Thuot": "MS1",
        "Kathryn Thornton": "MS2",
        "Thomas Akers": "MS4",
    },
    "STS-50": {
        "Bonnie Dunbar": "PC",
        "Lawrence DeLucas": "PS1",
        "Eugene Trinh": "PS2",
    },
    "STS-46": {
        "Claude Nicollier": "MS3",
        "Marsha Ivins": "MS4",
        "Jeffrey Hoffman": "MS1",
        "Franklin Chang-Diaz": "MS2",
        "Franco Malerba": "PS",
    },
    "STS-47": {
        "Mark Lee": "PC",
        "Jerome Apt": "MS3",
        "Jan Davis": "MS2",
        "Mamoru Mohri": "PS",
    },
    "STS-52": {
        "Steve MacLean": "PS",
    },
    "STS-53": {
        "Michael Clifford": "MS3",
        "James Voss": "MS2",
    },
    "STS-55": {
        "Ulrich Walter": "PS1",
        "Hans Schlegel": "PS2",
    },
    "STS-57": {
        "David Low": "PC",
    },
    "STS-58": {
        "Rhea Seddon": "PC",
        "Martin Fettman": "PS",
    },
    "STS-61": {
        "Kathryn Thornton": "MS2",
        "Claude Nicollier": "MS3",
        "Jeffrey Hoffman": "MS4",
        "Story Musgrave": "PC",
    },
    "STS-59": {
        "Linda Godwin": "PC",
    },
    "STS-65": {
        "Richard Hieb": "PC",
        "Chiaki Mukai": "PS",
    },
    "STS-68": {
        "Steven Smith": "MS2",
        "Daniel Bursch": "MS3",
        "Peter Wisoff": "MS4",
        "Thomas Jones": "PC",
    },
    "STS-66": {
        "Ellen Ochoa": "PC",
        "Joseph Tanner": "MS3",
        "Jean-Francois Clervoy": "MS4",
        "Scott Parazynski": "MS2",
    },
    "STS-63": {
        "Bernard Harris": "MS3",
        "Michael Foale": "MS1",
        "Janice Voss": "MS2",
    },
    "STS-67": {
        "John Grunsfeld": "MS2",
        "Wendy Lawrence": "MS3",
        "Tamara Jernigan": "PC",
        "Samuel Durrance": "PS2",
        "Ronald Parise": "PS1",
    },
    "STS-71": {
        "Gregory Harbaugh": "MS3",
        "Bonnie Dunbar": "MS2",
    },
    "STS-69": {
        "James Voss": "PC",
    },
    "STS-73": {
        "Kathryn Thornton": "PC",
        "Fred Leslie": "PS1",
        "Albert Sacco": "PS2",
    },
    "STS-74": {
        "Chris Hadfield": "MS3",
        "Jerry Ross": "MS1",
        "William McArthur": "MS2",
    },
    "STS-72": {
        "Winston Scott": "MS3",
        "Koichi Wakata": "MS4",
        "Daniel Barry": "MS2",
    },
    "STS-75": {
        "Umberto Guidoni": "PS",
    },
    "STS-76": {
        "Ronald Sega": "MS3",
        "Linda Godwin": "MS1",
    },
    "STS-77": {
        "Andrew Thomas": "MS4",
        "Daniel Bursch": "MS1",
        "Mario Runco": "MS2",
        "Marc Garneau": "MS3",
    },
    "STS-78": {
        "Richard Linnehan": "MS2",
        "Susan Helms": "MS1",
        "Jean-Jacques Favier": "PS1",
        "Robert Thirsk": "PS2",
    },
    "STS-79": {
        "Jerome Apt": "MS2",
        "Thomas Akers": "MS1",
    },
    "STS-80": {
        "Story Musgrave": "MS3",
        "Tamara Jernigan": "MS1",
    },
    "STS-81": {
        "Peter Wisoff": "MS3",
        "John Grunsfeld": "MS1",
        "Marsha Ivins": "MS2",
    },
    "STS-82": {
        "Joseph Tanner": "MS5",
        "Mark Lee": "MS1",
        "Steven Smith": "MS4",
    },
    "STS-83": {
        "Michael Gernhardt": "MS3",
        "Donald Thomas": "MS2",
        "Roger Crouch": "PS1",
        "Gregory Linteris": "PS2",
    },
    "STS-84": {
        "Jean-Francois Clervoy": "MS3",
        "Carlos Noriega": "MS1",
        "Edward Lu": "MS2",
    },
    "STS-94": {
        "Michael Gernhardt": "MS3",
        "Donald Thomas": "MS2",
        "Roger Crouch": "PS1",
        "Gregory Linteris": "PS2",
    },
    "STS-85": {
        "Robert Curbeam": "MS3",
        "Stephen Robinson": "MS2",
        "Bjarni Tryggvason": "PS",
    },
    "STS-87": {
        "Leonid Kadeniuk": "PS",
    },
    "STS-89": {
        "James Reilly": "MS3",
        "Bonnie Dunbar": "PC",
    },
    "STS-90": {
        "Dafydd Williams": "MS2",
        "Kathryn Hire": "MS3",
        "Richard Linnehan": "MS1",
        "Jay Buckey": "PS1",
        "James Pawelczyk": "PS2",
    },
    "STS-91": {
        "Franklin Chang-Diaz": "MS2",
        "Wendy Lawrence": "MS1",
    },
    "STS-95": {
        "Pedro Duque": "MS3",
        "Stephen Robinson": "PC",
        "Chiaki Mukai": "PS1",
        "John Glenn": "PS2",
    },
    "STS-88": {
        "Jerry Ross": "MS2",
        "Nancy Currie": "MS1",
    },
    "STS-96": {
        "Daniel Barry": "MS3",
        "Ellen Ochoa": "MS1",
        "Tamara Jernigan": "MS2",
    },
    "STS-93": {
        "Michel Tognini": "MS3",
        "Steven Hawley": "MS1",
        "Catherine Coleman": "MS2",
    },
    "STS-103": {
        "John Grunsfeld": "MS3",
        "Jean-Francois Clervoy": "MS5",
        "Michael Foale": "MS2",
        "Steven Smith": "MS1",
        "Claude Nicollier": "MS4",
    },
    "STS-99": {
        "Gerhard Thiele": "MS4",
        "Janet Kavandi": "MS1",
        "Janice Voss": "MS2",
        "Mamoru Mohri": "MS3",
    },
    "STS-106": {
        "Edward Lu": "MS2",
        "Richard Mastracchio": "MS3",
        "Daniel Burbank": "MS1",
    },
    "STS-92": {
        "William McArthur": "MS5",
        "Leroy Chiao": "MS2",
    },
    "STS-97": {
        "Marc Garneau": "MS3",
        "Carlos Noriega": "MS2",
    },
    "STS-98": {
        "Marsha Ivins": "MS3",
        "Thomas Jones": "MS2",
    },
    "STS-100": {
        "John Phillips": "MS3",
        "Scott Parazynski": "MS2",
    },
    "STS-104": {
        "Janet Kavandi": "MS3",
        "James Reilly": "MS2",
    },
    "STS-105": {
        "Patrick Forrester": "MS2",
        "Daniel Barry": "MS1",
    },
    "STS-109": {
        "John Grunsfeld": "PC",
        "Richard Linnehan": "MS4",
        "James Newman": "MS3",
    },
    "STS-110": {
        "Rex Walheim": "MS5",
        "Ellen Ochoa": "MS3",
        "Lee Morin": "MS4",
        "Jerry Ross": "MS1",
        "Steven Smith": "MS2",
    },
    "STS-111": {
        "Philippe Perrin": "MS2",
        "Franklin Chang-Diaz": "MS1",
    },
    "STS-112": {
        "Sandra Magnus": "MS3",
        "Piers Sellers": "MS2",
    },
    "STS-107": {
        "David Brown": "MS2",
        "Kalpana Chawla": "MS3",
        "Michael Anderson": "PC",
        "Ilan Ramon": "PS",
    },
    "STS-121": {
        "Lisa Nowak": "MS3",
        "Stephanie Wilson": "MS4",
        "Piers Sellers": "MS2",
    },
    "STS-115": {
        "Steve MacLean": "MS4",
        "Joseph Tanner": "MS1",
        "Heidemarie Stefanyshyn-Piper": "MS3",
    },
    "STS-120": {
        "Douglas Wheelock": "MS3",
        "Stephanie Wilson": "MS1",
        "Scott Parazynski": "MS2",
    },
    "STS-128": {
        "John Olivas": "MS4",
        "Christer Fuglesang": "MS3",
    },
    # Soyuz TM-21 roles; RC = research cosmonaut (Thagard).
    "SOYUZ TM-21": {
        "Vladimir Dezhurov": "CDR",
        "Gennady Strekalov": "FE",
        "Norman Thagard": "RC",
    },
    # Hurley was spacecraft commander, Behnken joint operations commander.
    "SPACEX DEMO-2": {
        "Douglas Hurley": "CDR",
        "Robert Behnken": "JOC",
    },
    # Crew-9 launched with two empty seats; Gorbunov was the one MS.
    "SPACEX CREW-9": {
        "Aleksandr Gorbunov": "MS",
    },
    # Inspiration4's medical officer (MO).
    "INSPIRATION4": {
        "Hayley Arceneaux": "MO",
        "Chris Sembroski": "MS",
    },
}


def crew_role(mission_name, crew_names, idx):
    person = crew_names[idx]
    override = CREW_ROLE_OVERRIDE.get(mission_name)
    if override != None:
        forced = override.get(person)
        if forced != None:
            return forced

    # Soyuz: first-listed crew member is commander, the rest flight engineers.
    if is_soyuz(mission_name):
        return "CDR" if idx == 0 else "FE"
    if mission_name in MERCURY_NAMES:
        return "PLT"
    if mission_name in GEMINI_NAMES:
        return "CP" if idx == 0 else "PLT"
    if mission_name == "APOLLO-SOYUZ":
        return ASTP_ROLES[idx] if idx < len(ASTP_ROLES) else "CREW"
    if mission_name.startswith("SKYLAB"):
        return SKYLAB_ROLES[idx] if idx < len(SKYLAB_ROLES) else "CREW"
    if mission_name.startswith("APOLLO"):
        return APOLLO_ROLES[idx] if idx < len(APOLLO_ROLES) else "CREW"

    # Shuttle
    if idx == 0:
        return "CDR"
    if idx == 1:
        return "PLT"
    return "MS" + str(idx - 1)


# Shuttle landing site -> (display name, timezone).
LANDING_SITE_INFO = {
    "KSC": ("KENNEDY SPACE CENTER", "EASTERN"),
    "EDW": ("EDWARDS AIR FORCE BASE", "PACIFIC"),
    "WSSH": ("WHITE SANDS SPACE HARBOR", "MOUNTAIN"),
}

# Ocean -> (display name, timezone). Atlantic and Gulf read as Eastern
# (NASA reports them that way), Pacific as Pacific.
OCEAN_INFO = {
    "ATLANTIC": ("THE ATLANTIC OCEAN", "EASTERN"),
    "GULF": ("THE GULF OF MEXICO", "EASTERN"),
    "PACIFIC": ("THE PACIFIC OCEAN", "PACIFIC"),
}

# Actual landing site per Shuttle mission. Lost missions use LOST_PHASE.
SHUTTLE_LANDING_SITE = {
    "STS-1": "EDW",
    "STS-2": "EDW",
    "STS-3": "WSSH",
    "STS-4": "EDW",
    "STS-5": "EDW",
    "STS-6": "EDW",
    "STS-7": "EDW",
    "STS-8": "EDW",
    "STS-9": "EDW",
    "STS-41-B": "KSC",
    "STS-41-C": "EDW",
    "STS-41-D": "EDW",
    "STS-41-G": "KSC",
    "STS-51-A": "KSC",
    "STS-51-C": "KSC",
    "STS-51-D": "KSC",
    "STS-51-B": "EDW",
    "STS-51-G": "EDW",
    "STS-51-F": "EDW",
    "STS-51-I": "EDW",
    "STS-51-J": "EDW",
    "STS-61-A": "EDW",
    "STS-61-B": "EDW",
    "STS-61-C": "EDW",
    "STS-51-L": "LOST",
    "STS-26": "EDW",
    "STS-27": "EDW",
    "STS-29": "EDW",
    "STS-30": "EDW",
    "STS-28": "EDW",
    "STS-34": "EDW",
    "STS-33": "EDW",
    "STS-32": "EDW",
    "STS-36": "EDW",
    "STS-31": "EDW",
    "STS-41": "EDW",
    "STS-38": "KSC",
    "STS-35": "EDW",
    "STS-37": "EDW",
    "STS-39": "KSC",
    "STS-40": "EDW",
    "STS-43": "KSC",
    "STS-48": "EDW",
    "STS-44": "EDW",
    "STS-42": "EDW",
    "STS-45": "KSC",
    "STS-49": "EDW",
    "STS-50": "KSC",
    "STS-46": "KSC",
    "STS-47": "KSC",
    "STS-52": "KSC",
    "STS-53": "EDW",
    "STS-54": "KSC",
    "STS-56": "KSC",
    "STS-55": "EDW",
    "STS-57": "KSC",
    "STS-51": "KSC",
    "STS-58": "EDW",
    "STS-61": "KSC",
    "STS-60": "KSC",
    "STS-62": "KSC",
    "STS-59": "EDW",
    "STS-65": "KSC",
    "STS-64": "EDW",
    "STS-68": "EDW",
    "STS-66": "EDW",
    "STS-63": "KSC",
    "STS-67": "EDW",
    "STS-71": "KSC",
    "STS-70": "KSC",
    "STS-69": "KSC",
    "STS-73": "KSC",
    "STS-74": "KSC",
    "STS-72": "KSC",
    "STS-75": "KSC",
    "STS-76": "EDW",
    "STS-77": "KSC",
    "STS-78": "KSC",
    "STS-79": "KSC",
    "STS-80": "KSC",
    "STS-81": "KSC",
    "STS-82": "KSC",
    "STS-83": "KSC",
    "STS-84": "KSC",
    "STS-94": "KSC",
    "STS-85": "KSC",
    "STS-86": "KSC",
    "STS-87": "KSC",
    "STS-89": "KSC",
    "STS-90": "KSC",
    "STS-91": "KSC",
    "STS-95": "KSC",
    "STS-88": "KSC",
    "STS-96": "KSC",
    "STS-93": "KSC",
    "STS-103": "KSC",
    "STS-99": "KSC",
    "STS-101": "KSC",
    "STS-106": "KSC",
    "STS-92": "EDW",
    "STS-97": "KSC",
    "STS-98": "EDW",
    "STS-102": "KSC",
    "STS-100": "EDW",
    "STS-104": "KSC",
    "STS-105": "EDW",
    "STS-108": "KSC",
    "STS-109": "KSC",
    "STS-110": "EDW",
    "STS-111": "KSC",
    "STS-112": "EDW",
    "STS-113": "KSC",
    "STS-107": "LOST",
    "STS-114": "EDW",
    "STS-121": "KSC",
    "STS-115": "KSC",
    "STS-116": "KSC",
    "STS-117": "KSC",
    "STS-118": "KSC",
    "STS-120": "KSC",
    "STS-122": "KSC",
    "STS-123": "KSC",
    "STS-124": "KSC",
    "STS-126": "KSC",
    "STS-119": "KSC",
    "STS-125": "KSC",
    "STS-127": "KSC",
    "STS-128": "KSC",
    "STS-129": "KSC",
    "STS-130": "KSC",
    "STS-131": "KSC",
    "STS-132": "KSC",
    "STS-133": "KSC",
    "STS-134": "KSC",
    "STS-135": "KSC",
}

# Ocean each capsule splashed down in.
SPLASHDOWN_OCEAN = {
    "FREEDOM 7": "ATLANTIC",
    "LIBERTY BELL 7": "ATLANTIC",
    "FRIENDSHIP 7": "ATLANTIC",
    "AURORA 7": "ATLANTIC",
    "SIGMA 7": "ATLANTIC",
    "FAITH 7": "PACIFIC",
    "GEMINI 3": "ATLANTIC",
    "GEMINI 4": "ATLANTIC",
    "GEMINI 5": "ATLANTIC",
    "GEMINI 7": "ATLANTIC",
    "GEMINI 6": "ATLANTIC",
    "GEMINI 8": "PACIFIC",
    "GEMINI 9A": "ATLANTIC",
    "GEMINI 10": "ATLANTIC",
    "GEMINI 11": "ATLANTIC",
    "GEMINI 12": "ATLANTIC",
    "APOLLO 7": "ATLANTIC",
    "APOLLO 8": "PACIFIC",
    "APOLLO 9": "ATLANTIC",
    "APOLLO 10": "PACIFIC",
    "APOLLO 11": "PACIFIC",
    "APOLLO 12": "PACIFIC",
    "APOLLO 13": "PACIFIC",
    "APOLLO 14": "PACIFIC",
    "APOLLO 15": "PACIFIC",
    "APOLLO 16": "PACIFIC",
    "APOLLO 17": "PACIFIC",
    "SKYLAB 2": "PACIFIC",
    "SKYLAB 3": "PACIFIC",
    "SKYLAB 4": "PACIFIC",
    "APOLLO-SOYUZ": "PACIFIC",
    # Orion: Apollo-style ocean recovery.
    "ARTEMIS II": "PACIFIC",
    "SPACEX DEMO-2": "GULF",
    "SPACEX CREW-1": "GULF",
    "SPACEX CREW-2": "GULF",
    "SPACEX CREW-3": "GULF",
    "SPACEX CREW-4": "ATLANTIC",
    "SPACEX CREW-5": "GULF",
    "SPACEX CREW-6": "ATLANTIC",
    "SPACEX CREW-7": "GULF",
    "SPACEX CREW-8": "GULF",
    "SPACEX CREW-9": "GULF",
    "SPACEX CREW-10": "PACIFIC",
    "SPACEX CREW-11": "PACIFIC",
    "INSPIRATION4": "ATLANTIC",
    "AXIOM-1": "ATLANTIC",
    "AXIOM-2": "GULF",
    "AXIOM-3": "ATLANTIC",
    "POLARIS DAWN": "GULF",
    "AXIOM-4": "PACIFIC",
}

# Orbiter per Shuttle mission. Non-Shuttle missions have no entry, which
# routes them to the ocean-splashdown text.
ORBITER = {
    "STS-1": "COLUMBIA",
    "STS-2": "COLUMBIA",
    "STS-3": "COLUMBIA",
    "STS-4": "COLUMBIA",
    "STS-5": "COLUMBIA",
    "STS-9": "COLUMBIA",
    "STS-61-C": "COLUMBIA",
    "STS-28": "COLUMBIA",
    "STS-32": "COLUMBIA",
    "STS-35": "COLUMBIA",
    "STS-40": "COLUMBIA",
    "STS-50": "COLUMBIA",
    "STS-52": "COLUMBIA",
    "STS-55": "COLUMBIA",
    "STS-58": "COLUMBIA",
    "STS-62": "COLUMBIA",
    "STS-65": "COLUMBIA",
    "STS-73": "COLUMBIA",
    "STS-75": "COLUMBIA",
    "STS-78": "COLUMBIA",
    "STS-80": "COLUMBIA",
    "STS-83": "COLUMBIA",
    "STS-94": "COLUMBIA",
    "STS-87": "COLUMBIA",
    "STS-90": "COLUMBIA",
    "STS-93": "COLUMBIA",
    "STS-109": "COLUMBIA",
    "STS-107": "COLUMBIA",
    "STS-6": "CHALLENGER",
    "STS-7": "CHALLENGER",
    "STS-8": "CHALLENGER",
    "STS-41-B": "CHALLENGER",
    "STS-41-C": "CHALLENGER",
    "STS-41-G": "CHALLENGER",
    "STS-51-B": "CHALLENGER",
    "STS-51-F": "CHALLENGER",
    "STS-61-A": "CHALLENGER",
    "STS-51-L": "CHALLENGER",
    "STS-41-D": "DISCOVERY",
    "STS-51-A": "DISCOVERY",
    "STS-51-C": "DISCOVERY",
    "STS-51-D": "DISCOVERY",
    "STS-51-G": "DISCOVERY",
    "STS-51-I": "DISCOVERY",
    "STS-26": "DISCOVERY",
    "STS-29": "DISCOVERY",
    "STS-33": "DISCOVERY",
    "STS-31": "DISCOVERY",
    "STS-41": "DISCOVERY",
    "STS-39": "DISCOVERY",
    "STS-48": "DISCOVERY",
    "STS-42": "DISCOVERY",
    "STS-53": "DISCOVERY",
    "STS-56": "DISCOVERY",
    "STS-51": "DISCOVERY",
    "STS-60": "DISCOVERY",
    "STS-64": "DISCOVERY",
    "STS-63": "DISCOVERY",
    "STS-70": "DISCOVERY",
    "STS-82": "DISCOVERY",
    "STS-85": "DISCOVERY",
    "STS-91": "DISCOVERY",
    "STS-95": "DISCOVERY",
    "STS-96": "DISCOVERY",
    "STS-103": "DISCOVERY",
    "STS-92": "DISCOVERY",
    "STS-102": "DISCOVERY",
    "STS-105": "DISCOVERY",
    "STS-114": "DISCOVERY",
    "STS-121": "DISCOVERY",
    "STS-116": "DISCOVERY",
    "STS-120": "DISCOVERY",
    "STS-124": "DISCOVERY",
    "STS-119": "DISCOVERY",
    "STS-128": "DISCOVERY",
    "STS-131": "DISCOVERY",
    "STS-133": "DISCOVERY",
    "STS-51-J": "ATLANTIS",
    "STS-61-B": "ATLANTIS",
    "STS-27": "ATLANTIS",
    "STS-30": "ATLANTIS",
    "STS-34": "ATLANTIS",
    "STS-36": "ATLANTIS",
    "STS-38": "ATLANTIS",
    "STS-37": "ATLANTIS",
    "STS-43": "ATLANTIS",
    "STS-44": "ATLANTIS",
    "STS-45": "ATLANTIS",
    "STS-46": "ATLANTIS",
    "STS-66": "ATLANTIS",
    "STS-71": "ATLANTIS",
    "STS-74": "ATLANTIS",
    "STS-76": "ATLANTIS",
    "STS-79": "ATLANTIS",
    "STS-81": "ATLANTIS",
    "STS-84": "ATLANTIS",
    "STS-86": "ATLANTIS",
    "STS-101": "ATLANTIS",
    "STS-106": "ATLANTIS",
    "STS-98": "ATLANTIS",
    "STS-104": "ATLANTIS",
    "STS-110": "ATLANTIS",
    "STS-112": "ATLANTIS",
    "STS-115": "ATLANTIS",
    "STS-117": "ATLANTIS",
    "STS-122": "ATLANTIS",
    "STS-125": "ATLANTIS",
    "STS-129": "ATLANTIS",
    "STS-132": "ATLANTIS",
    "STS-135": "ATLANTIS",
    "STS-49": "ENDEAVOUR",
    "STS-47": "ENDEAVOUR",
    "STS-54": "ENDEAVOUR",
    "STS-57": "ENDEAVOUR",
    "STS-61": "ENDEAVOUR",
    "STS-59": "ENDEAVOUR",
    "STS-68": "ENDEAVOUR",
    "STS-67": "ENDEAVOUR",
    "STS-69": "ENDEAVOUR",
    "STS-72": "ENDEAVOUR",
    "STS-77": "ENDEAVOUR",
    "STS-89": "ENDEAVOUR",
    "STS-88": "ENDEAVOUR",
    "STS-99": "ENDEAVOUR",
    "STS-97": "ENDEAVOUR",
    "STS-100": "ENDEAVOUR",
    "STS-108": "ENDEAVOUR",
    "STS-111": "ENDEAVOUR",
    "STS-113": "ENDEAVOUR",
    "STS-118": "ENDEAVOUR",
    "STS-123": "ENDEAVOUR",
    "STS-126": "ENDEAVOUR",
    "STS-127": "ENDEAVOUR",
    "STS-130": "ENDEAVOUR",
    "STS-134": "ENDEAVOUR",
}

LOST_COLOR = "#FF4444"

# Small labels over patch art; black empty-day pages use #888888.
PATCH_LABEL_COLOR = "#8E9AB0"


# Display name only: "STS-41-B" -> "STS-41B", Gemini in Roman numerals.
# The raw name stays the key everywhere else.
GEMINI_ROMAN = {
    "GEMINI 3": "GEMINI III",
    "GEMINI 4": "GEMINI IV",
    "GEMINI 5": "GEMINI V",
    "GEMINI 6": "GEMINI VI",
    "GEMINI 7": "GEMINI VII",
    "GEMINI 8": "GEMINI VIII",
    "GEMINI 9A": "GEMINI IX-A",
    "GEMINI 10": "GEMINI X",
    "GEMINI 11": "GEMINI XI",
    "GEMINI 12": "GEMINI XII",
}


def display_name(name):
    if name in GEMINI_ROMAN:
        return GEMINI_ROMAN[name]
    if len(name) >= 2 and name[-2] == "-" and name[-1] in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        return name[:-2] + name[-1]
    return name


def parse_crew(crew_str):
    names = []
    for part in crew_str.split(","):
        n = part.strip()
        if n != "":
            names.append(n)
    return names


# Centered text with hand-drawn apostrophes (the fonts have no "'" glyph):
# a 1x2 tick at cap height in its own 3px slot.
def draw_text_apostrophes(c, text, cx, y, font, color):
    parts = text.split("'")
    if len(parts) == 1:
        c.text(text, cx, y, font = font, color = color, align = "center")
        return
    widths = [c.text_width(part, font = font) for part in parts]
    total = 0
    for w in widths:
        total += w
    total += 3 * (len(parts) - 1)
    x = cx - total // 2
    for i in range(len(parts)):
        c.text(parts[i], x, y, font = font, color = color, align = "left")
        x += widths[i]
        if i < len(parts) - 1:
            c.rect(x + 1, y, x + 1, y + 1, fill = color)
            x += 3


# Biggest font in the ladder that fits every string, so multi-line
# messages share one size.
def shared_font(c, texts, fonts, maxw):
    for f in fonts:
        fits = True
        for t in texts:
            if c.text_width(t, font = f) > maxw:
                fits = False
        if fits:
            return f
    return fonts[len(fonts) - 1]


# Line count text_wrapped would produce, without drawing.
def wrapped_line_count(c, text, font, w):
    words = text.split(" ")
    lines, cur = 0, ""
    for word in words:
        cand = word if cur == "" else cur + " " + word
        if cur == "" or c.text_width(cand, font = font) <= w:
            cur = cand
        else:
            lines += 1
            cur = word
    if cur != "":
        lines += 1
    return lines


# Font ladder for wrapped quotes: (font, glyph height).
# 2px between lines: the quotes' commas and apostrophes sit low enough
# that 1px read as touching rows.
WRAPPED_FONT_LADDER = [("5x7", 7), ("4x7", 7), ("4x5", 5)]
WRAPPED_GAP = 2


# Height of page 2/3's top row (mission name left, year right).
HEADER_HEIGHT = 8


# Text with a 1px black outline, readable over any patch color.
def draw_outlined_text(c, text, x, y, font, color, align = "left"):
    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        c.text(text, x + dx, y + dy, font = font, color = "#000000", align = align)
    c.text(text, x, y, font = font, color = color, align = align)


# ------------------------------------------------ layout + spacecraft ----

# DESIGN. Every page is a black ground with the mission's spacecraft drawn
# as crisp pixel art in a left zone, a thin rail in the program's color,
# and the words in the content zone to its right. The craft is the label:
# Mercury, Gemini, Apollo (the lunar module on Moon-landing pages),
# Shuttle, Soyuz, Crew Dragon, Starliner and Orion each read at a glance.
# Empty days keep the grammar: a calendar, the next/last mission's craft,
# or the profiled astronaut's helmet with a visor in their group color.

# Sprite zone x 0-30 (craft centered on x 16), rail at x 31, content zone
# x 35-185: 6px clear of both app edges for the scroll stream.
SPRITE_CX = 16
RAIL_X = 31
L = 35
R = 185
CX = 110
CW = R - L
HALF_W = CW // 2 - 4

PROGRAM_COLOR = {
    "MERCURY": "#c3ccd8",
    "GEMINI": "#4aa3ff",
    "APOLLO": "#ffc43d",
    "SHUTTLE": "#78dcff",
    "SOYUZ": "#62d77a",
    "DRAGON": "#eef1f6",
    "STARLINER": "#5b8cff",
    "ORION": "#ff7a3d",
}

PROGRAM_LABEL = {
    "MERCURY": "PROJECT MERCURY",
    "GEMINI": "PROJECT GEMINI",
    "APOLLO": "APOLLO",
    "SHUTTLE": "SPACE SHUTTLE",
    "SOYUZ": "SOYUZ",
    "DRAGON": "CREW DRAGON",
    "STARLINER": "STARLINER",
    "ORION": "ORION",
}

# Which craft flew a mission. Skylab and Apollo-Soyuz flew Apollo CSMs.
def craft_for(name):
    if name in MERCURY_NAMES:
        return "MERCURY"
    if name in GEMINI_NAMES:
        return "GEMINI"
    if is_soyuz(name):
        return "SOYUZ"
    if ORBITER.get(name) != None:
        return "SHUTTLE"
    if name in ARTEMIS_NAMES:
        return "ORION"
    if name == "STARLINER CFT":
        return "STARLINER"
    if is_commercial(name):
        return "DRAGON"
    return "APOLLO"

def program_color(name):
    return PROGRAM_COLOR[craft_for(name)]

# Craft centered in the left zone, then the rail.
def draw_craft_zone(c, craft, color, legend = None):
    art = CRAFT_ART[craft]
    w = len(art[0])
    h = len(art)
    c.sprite(art, SPRITE_CX - w // 2, (32 - h) // 2, legend = legend if legend != None else CRAFT_LEGEND)
    c.line(RAIL_X, 3, RAIL_X, 28, dim_hex(color, 70))

# Astronaut profile pages: helmet with the visor in the group's color.
def draw_astronaut_zone(c, accent):
    c.fill("#000000")
    legend = dict(CRAFT_LEGEND)
    legend["V"] = accent
    legend["H"] = "#ffffff"
    draw_craft_zone(c, "HELMET", accent, legend)

# Empty day: a calendar in the craft zone.
def draw_no_events_zone(c):
    c.fill("#000000")
    draw_craft_zone(c, "CALENDAR", "#ff5533")

def draw_no_events(c):
    draw_no_events_zone(c)
    c.text("NO US LAUNCHES OR", CX, 8, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
    c.text("LANDINGS ON THIS DATE", CX, 18, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")


# One shared legend so every craft reads as the same hand.
CRAFT_LEGEND = {
    "W": "#eef1f6",
    "S": "#a9b3c1",
    "D": "#5c6676",
    "K": "#353c48",
    "R": "#ff5533",
    "O": "#ff9a2e",
    "Y": "#ffe066",
    "B": "#c08a48",
    "G": "#e9b949",
    "U": "#3f7fe0",
    "N": "#6fbf73",
}

CRAFT_ART = {
    "MERCURY": [
        "..........R..........",
        "..........R..........",
        ".........RRR.........",
        ".........R.R.........",
        ".........RRR.........",
        ".........R.R.........",
        "........RR.RR........",
        "........R...R........",
        "........SSSSS........",
        "........SKKKS........",
        "........SSSSS........",
        ".......DDDDDDD.......",
        ".......DSSSSSD.......",
        ".......DDDDDDD.......",
        "......DSDSDSDSD......",
        ".....DSDSDSDSDSD.....",
        "....DSDSDSDSDSDSD....",
        "...DSDSDSDSDSDSDSD...",
        "..DSDSDSDSDSDSDSDSD..",
        ".DDDDDDDDDDDDDDDDDDD.",
        ".BBBBBBBBBBBBBBBBBBB.",
        "..BBBBBBBBBBBBBBBBB..",
    ],
    "GEMINI": [
        ".........SSS.........",
        "........SDDDS........",
        "........DSSSD........",
        "........DDDDD........",
        ".......DDDDDDD.......",
        ".......DSDDDSD.......",
        "......DDDDDDDDD......",
        "......DDDDDDDDD......",
        ".....DDDDDDDDDDD.....",
        ".....DDDDDDDDDDD.....",
        "....DDDDDDDDDDDDD....",
        "....SSSSSSSSSSSSS....",
        "....WWWWWWWWWWWWW....",
        "...WWWWWWWWWWWWWWW...",
        "...WWWWWWWWWWWWWWW...",
        "..WWWWWWWWWWWWWWWWW..",
        "..WWWWWWWWWWWWWWWWW..",
        ".WWWWWWWWWWWWWWWWWWW.",
        ".WWWWWWWWWWWWWWWWWWW.",
        ".SSSSSSSSSSSSSSSSSSS.",
    ],
    "APOLLO": [
        "..........S..........",
        ".........WWW.........",
        "........WWSWW........",
        ".......WWWSWWW.......",
        "......WWWWSWWWW......",
        ".....WWWWWSWWWWW.....",
        "....WWWWWWSWWWWWW....",
        "...WWWWWWWSWWWWWWW...",
        "...BBBBBBBBBBBBBBB...",
        "...SSSSSSSSSSSSSSS...",
        "..DSSSSSSSSSSSSSSSD..",
        "...SSSSSSSSSSSSSSS...",
        "...SSKSSSSSSSSSKSS...",
        "...SSSSSSSSSSSSSSS...",
        "..DSSSSSSSSSSSSSSSD..",
        "...SSSSSSSSSSSSSSS...",
        "...SSSSSSSSSSSSSSS...",
        "...DDDDDDDDDDDDDDD...",
        ".......DDDDDDD.......",
        "......DKKKKKKKD......",
        ".....DKKKKKKKKKD.....",
    ],
    "LM": [
        "......S.......S......",
        "......S.SSSSS.S......",
        ".....SSSSSSSSSSS.....",
        ".....SWWSSSSSWWS.....",
        "....SSKKSSSSSKKSS....",
        "....SSSSSSSSSSSSS....",
        "....SSSSSSSSSSSSS....",
        "...DDDDDDDDDDDDDDD...",
        "...GGGGGGGGGGGGGGG...",
        "..GGGGBGGGGGGGBGGGG..",
        "..GGGGGGGGGGGGGGGGG..",
        "..GGGGGGGGGGGGGGGGG..",
        "..G.GGGGGGGGGGGGG.G..",
        ".G...GGGG...GGGG...G.",
        ".G........K........G.",
        "G.........K.........G",
        "SS.................SS",
    ],
    "SHUTTLE": [
        "..........D..........",
        ".........DWD.........",
        ".........WWW.........",
        "........WKWKW........",
        "........WWWWW........",
        "........WWWWW........",
        "........WWWWW........",
        "........WWWWW........",
        ".......DWWWWWD.......",
        "......DWWWWWWWD......",
        ".....DWWWWWWWWWD.....",
        "....DWWWWWWWWWWWD....",
        "...DWWWWWWWWWWWWWD...",
        "..DWWWWWWWWWWWWWWWD..",
        ".DWWWWWWWWWWWWWWWWWD.",
        "DDDDDDWWWWWWWWWDDDDDD",
        "......DWWWDWWWD......",
        ".......DWWDWWD.......",
        "........SSSSS........",
        "........O.O.O........",
        "........Y.Y.Y........",
    ],
    "SOYUZ": [
        "..........S..........",
        "........SSSSS........",
        ".......SNNNNNS.......",
        "......SNNNNNNNS......",
        "......SNNNNNNNS......",
        ".......SNNNNNS.......",
        "........SSSSS........",
        ".......NNNNNNN.......",
        "......NNNNNNNNN......",
        ".....NNNNNNNNNNN.....",
        ".....SSSSSSSSSSS.....",
        "UUUU.SSSSSSSSSSS.UUUU",
        "UUUUSSSSSSSSSSSSSUUUU",
        "UUUU.SSSSSSSSSSS.UUUU",
        "UUUU.SSSSSSSSSSS.UUUU",
        "UUUU.SSSSSSSSSSS.UUUU",
        ".....SSSSSSSSSSS.....",
        "......DDDDDDDDD......",
    ],
    "DRAGON": [
        "........SSSSS........",
        ".......SWWWWWS.......",
        "......SWWWWWWWS......",
        "......WWWWWWWWW......",
        ".....WWWWWWWWWWW.....",
        ".....WWKWWWWWKWW.....",
        "....WWWWWWWWWWWWW....",
        "....WWWWWWWWWWWWW....",
        "...WWWWWWWWWWWWWWW...",
        "...WWWWWWWWWWWWWWW...",
        "..WWWWWWWWWWWWWWWWW..",
        "..SSSSSSSSSSSSSSSSS..",
        "..WWWWWWWWKKKKKKKKK..",
        "..WWWWWWWWKUKUKUKUK..",
        "..WWWWWWWWKKKKKKKKK..",
        "..WWWWWWWWKUKUKUKUK..",
        "..WWWWWWWWKKKKKKKKK..",
        "..WWWWWWWWWWWWWWWWW..",
        "..S..............S...",
    ],
    "STARLINER": [
        "........SSSSS........",
        ".......SSSSSSS.......",
        "......SSSSSSSSS......",
        ".....SSSKSSSKSSS.....",
        ".....SSSSSSSSSSS.....",
        "....SSSSSSSSSSSSS....",
        "....UUUUUUUUUUUUU....",
        "...SSSSSSSSSSSSSSS...",
        "...SSSSSSSSSSSSSSS...",
        "..SSSSSSSSSSSSSSSSS..",
        "..DDDDDDDDDDDDDDDDD..",
        "..WWWWWWWWWWWWWWWWW..",
        "..WKWWWKWWWKWWWKWWW..",
        "..WWWWWWWWWWWWWWWWW..",
        "..WWWWWWWWWWWWWWWWW..",
        "...DDDDDDDDDDDDDDD...",
    ],
    "ORION": [
        "........SSSSS........",
        ".......SSSSSSS.......",
        "......SSKSSSKSS......",
        ".....SSSSSSSSSSS.....",
        "....SSSSSSSSSSSSS....",
        "...SSSSSSSSSSSSSSS...",
        "...BBBBBBBBBBBBBBB...",
        "....WWWWWWWWWWWWW....",
        "U...WWWWWWWWWWWWW...U",
        "UU..WWWWWWWWWWWWW..UU",
        ".UUUWWWWWWWWWWWWWUUU.",
        ".UUUWWWWWWWWWWWWWUUU.",
        "UU..WWWWWWWWWWWWW..UU",
        "U...WWWWWWWWWWWWW...U",
        ".....SSSSSSSSSSS.....",
        "......DDDDDDDDD......",
        ".......KKKKKKK.......",
    ],
    "HELMET": [
        ".......WWWWWWW.......",
        ".....WWWWWWWWWWW.....",
        "....WWWWWWWWWWWWW....",
        "...WWWVVVVVVVVVWWW...",
        "..WWWVVVVVVVVVVVWWW..",
        "..WWVVVVVVVVVVVVVWW..",
        ".WWWVVHHVVVVVVVVVWWW.",
        ".WWVVVHVVVVVVVVVVVWW.",
        ".WWVVVVVVVVVVVVVVVWW.",
        ".WWVVVVVVVVVVVVVVVWW.",
        ".WWWVVVVVVVVVVVVVWWW.",
        "..WWWVVVVVVVVVVVWWW..",
        "..WWWWVVVVVVVVVWWWW..",
        "...WWWWWWWWWWWWWWW...",
        "...SSSWWWWWWWWWSSS...",
        "..SSSSSSSSSSSSSSSSS..",
        ".SSDDSSSSSSSSSSSDDSS.",
        ".SSSSSSSSSSSSSSSSSSS.",
    ],
    "CALENDAR": [
        "....K...........K....",
        "...RKRRRRRRRRRRRKRR..",
        "...RRRRRRRRRRRRRRRR..",
        "...RRRRRRRRRRRRRRRR..",
        "...WWWWWWWWWWWWWWWW..",
        "...WWWWWWWWWWWWWWWW..",
        "...WSSWSSWSSWSSWSSW..",
        "...WWWWWWWWWWWWWWWW..",
        "...WSSWSSWSSWSSWSSW..",
        "...WWWWWWWWWWWWWWWW..",
        "...WSSWSSWSSWSSWSSW..",
        "...WWWWWWWWWWWWWWWW..",
        "...WSSWSSWSSWSSWSSW..",
        "...WWWWWWWWWWWWWWWW..",
        "...SSSSSSSSSSSSSSSS..",
    ],
    "SATURN": [
        "....R....",
        "....R....",
        "...WWW...",
        "..WWWWW..",
        "..WKKKW..",
        "..WWWWW..",
        "..WWWWW..",
        ".WWWWWWW.",
        ".KKKKKKK.",
        ".WWWWWWW.",
        ".WWWWWWW.",
        ".WWWWWWW.",
        ".KKKKKKK.",
        ".WWWWWWW.",
        ".WKKWKKW.",
        ".WKKWKKW.",
        ".WWWWWWW.",
        "KWWWWWWWK",
        "K.DDDDD.K",
        "..YYYYY..",
        ".OYYYYYO.",
        ".OOYYYOO.",
        "..OOYOO..",
        "..ROOOR..",
        "...ROR...",
        "....R....",
    ],
    "MOON": [
        "....SSSS....",
        "..SSSSSSWW..",
        ".SSSSDSSSWW.",
        ".SSSSSSSSSW.",
        "SSDSSSSSSSWW",
        "SSSSSSSDSSSW",
        "SSSSSSSSSSSW",
        "SSSSDSSSSSWW",
        ".SSSSSSSSSW.",
        ".SSSSSSSDWW.",
        "..SSSSSSWW..",
        "....SSSS....",
    ],
}

# Fixed starfield for the title, kept clear of the words and the art.
TITLE_STARS = [(7, 3), (26, 6), (6, 24), (27, 27), (38, 4), (44, 27), (152, 3),
               (160, 26), (185, 5), (182, 28), (148, 15), (36, 16)]

# Title: Saturn V climbing on the left, the Moon on the right, the name
# between them. Same left zone and rail as every other page.
def title(c, ctx):
    c.fill("#000000")
    for x, y in TITLE_STARS:
        c.pixel(x, y, "#6f7a8f")
    art = CRAFT_ART["SATURN"]
    c.sprite(art, SPRITE_CX - len(art[0]) // 2, 3, legend = CRAFT_LEGEND)
    c.line(RAIL_X, 3, RAIL_X, 28, dim_hex(PROGRAM_COLOR["APOLLO"], 70))
    moon = CRAFT_ART["MOON"]
    c.sprite(moon, 168, 10, legend = CRAFT_LEGEND)
    tx = (L + 160) // 2
    c.text("TODAY IN", tx, 2, font = "4x5", color = PROGRAM_COLOR["APOLLO"], align = "center")
    c.text("US MANNED", tx, 10, font = "6x8", color = "white", align = "center")
    c.text("SPACE FLIGHT", tx, 21, font = "6x8", color = "white", align = "center")


def draw_wrapped_fit_outlined(c, text, x, y, w, color, avail_h, center = True):
    for i in range(len(WRAPPED_FONT_LADDER)):
        font, fh = WRAPPED_FONT_LADDER[i]
        max_lines = (avail_h + WRAPPED_GAP) // (fh + WRAPPED_GAP)
        n = wrapped_line_count(c, text, font, w)
        if n <= max_lines or i == len(WRAPPED_FONT_LADDER) - 1:
            n = min(n, max_lines)
            if center:
                y = y + (avail_h - (n * (fh + WRAPPED_GAP) - WRAPPED_GAP)) // 2
            c.text_wrapped(text, x, y, w, font = font, color = color, line_gap = WRAPPED_GAP, max_lines = max_lines)
            return


# Timezone a mission's launch reads against.
def launch_zone_for(name):
    if is_soyuz(name):
        return "MSK"
    return "EASTERN"


# Timezone a mission's landing reads against: lost missions Eastern,
# Shuttle by runway, capsules by ocean.
def landing_zone_for(name):
    if END_LABEL_OVERRIDE.get(name) == "LOST":
        return "EASTERN"
    if is_soyuz(name):
        return "MSK"
    if ORBITER.get(name) != None:
        bucket = SHUTTLE_LANDING_SITE.get(name, "KSC")
        return LANDING_SITE_INFO[bucket][1]
    ocean = SPLASHDOWN_OCEAN.get(name, "ATLANTIC")
    return OCEAN_INFO[ocean][1]


# Stored dates are UTC; "today in history" is the local date at the site.
def local_launch_date(mission):
    name, ly, lm, ld, ny, nm, nd, crew = mission
    times = MISSION_TIMES.get(name, (0, 0, 0, 0, 0, 0))
    _, m, d, _, _, _ = utc_to_local(ly, lm, ld, times[0], times[1], launch_zone_for(name))
    return m, d


def local_land_date(mission):
    name, ly, lm, ld, ny, nm, nd, crew = mission
    times = MISSION_TIMES.get(name, (0, 0, 0, 0, 0, 0))
    _, m, d, _, _, _ = utc_to_local(ny, nm, nd, times[3], times[4], landing_zone_for(name))
    return m, d


# Page 2 rotates through events, not missions: LAUNCH, LAND, and MOONLAND
# (if the mission has a moon landing). Missions in TRIBUTE_NAMES get no
# LAUNCH event.
def find_flight_events(today_month, today_day):
    events = []
    for i in range(len(ALL_MISSIONS)):
        mission = ALL_MISSIONS[i]
        name = mission[0]

        if name not in TRIBUTE_NAMES and name not in LANDING_ONLY_NAMES:
            launch_m, launch_d = local_launch_date(mission)
            if launch_m == today_month and launch_d == today_day:
                events.append((mission, "LAUNCH"))

        if name not in LAUNCH_ONLY_NAMES:
            land_m, land_d = local_land_date(mission)
            if land_m == today_month and land_d == today_day:
                events.append((mission, "LAND"))

        moon = MOON_LANDING_TIME.get(name)
        if moon != None:
            moon_y, moon_mo, moon_dy, moon_h, moon_min, moon_sec = moon
            _, local_mo, local_dy, _, _, _ = utc_to_local(moon_y, moon_mo, moon_dy, moon_h, moon_min, "CENTRAL")
            if local_mo == today_month and local_dy == today_day:
                events.append((mission, "MOONLAND"))
    return events


def utc_abs(t):
    y, m, d, h, mi, sec = t
    return days_from_civil(y, m, d) * 86400 + h * 3600 + mi * 60 + sec


# Pages 3-8 for a MOONLAND card; returns True when it drew the page.
def draw_moon_page(c, ctx, page):
    event = current_flight_event(ctx)
    if event == None or event[1] != "MOONLAND":
        return False
    mission = event[0]
    name = mission[0]
    info = MOON_SURFACE.get(name)
    if info == None:
        return False
    # Page 5 falls back to the normal page until MOON_BOOTS has the mission.
    if page == 5 and MOON_BOOTS.get(name) == None:
        return False
    if not draw_patch_background(c, name, "LM"):
        c.fill("#000000")

    if page == 3:
        stay = utc_abs(info["liftoff"]) - utc_abs(MOON_LANDING_TIME[name])
        draw_outlined_text(c, "LM TIME ON THE MOON", CX, 4, "4x5", PATCH_LABEL_COLOR, align = "center")
        draw_duration(c, CX, 13, stay, "amber", num_font = "10x14", num_h = 14)
    elif page == 4:
        n = len(info["evas"])
        total = 0
        for e in info["evas"]:
            total += e
        # "EVA TIME" = NASA's official depress-to-repress clock; page 5's
        # TIME ON THE SURFACE is each man's boots on the ground.
        label = "EVA TIME - " + str(n) + (" EVA" if n == 1 else " EVAS")
        draw_outlined_text(c, label, CX, 4, "4x5", PATCH_LABEL_COLOR, align = "center")
        draw_duration(c, CX, 13, total, "amber", num_font = "10x14", num_h = 14)
    elif page == 5:
        draw_outlined_text(c, "TIME ON THE SURFACE", CX, 2, "4x5", PATCH_LABEL_COLOR, align = "center")
        rows = MOON_BOOTS.get(name, [])
        hms = [str(secs // 3600) + " HRS " + str(secs % 3600 // 60) + " MIN" for _, secs in rows]
        # 'NEIL ARMSTRONG' (83px) beside '2 HRS 13 MIN' (71px) overflows the
        # 150px content zone, so both names step down to one shared face.
        room = CW - 5
        for hm in hms:
            room = min(room, CW - 5 - c.text_width(hm, font = "5x7"))
        who_font = shared_font(c, [moonwalker_name(mission, who) for who, _ in rows], ["5x7", "4x7", "4x5"], room)
        for i in range(len(rows)):
            y = 11 + i * 11
            who_txt, _ = fit_text(c, moonwalker_name(mission, rows[i][0]), [who_font], room)
            draw_outlined_text(c, who_txt, L, y + (1 if who_font == "4x5" else 0), who_font, "white", align = "left")
            draw_outlined_text(c, hms[i], R, y, "5x7", "amber", align = "right")
    elif page == 6:
        draw_outlined_text(c, "MOON ROCKS RETURNED", CX, 4, "4x5", PATCH_LABEL_COLOR, align = "center")
        # "10x14" has no "." glyph -- draw the whole and tenths parts
        # separately with a 2x2 dot (outlined like the digits) between.
        whole, tenths = info["rocks_lb"].split(".")
        ww = c.text_width(whole, font = "10x14")
        tw = c.text_width(tenths, font = "10x14")
        uw = c.text_width("LBS", font = "5x7")
        total = ww + 2 + 2 + 2 + tw + 3 + uw
        x = CX - total // 2
        draw_outlined_text(c, whole, x, 13, "10x14", "amber", align = "left")
        dx = x + ww + 2
        c.rect(dx - 1, 24, dx + 2, 27, fill = "#000000")
        c.rect(dx, 25, dx + 1, 26, fill = "amber")
        draw_outlined_text(c, tenths, dx + 4, 13, "10x14", "amber", align = "left")
        draw_outlined_text(c, "LBS", dx + 4 + tw + 3, 20, "5x7", "amber", align = "left")
    elif page == 7:
        y, mo, d, h, mi, sec = info["liftoff"]
        ly, lmo, ld, lh, lmin, abbr = utc_to_local(y, mo, d, h, mi, "CENTRAL")
        draw_outlined_text(c, "LIFTOFF FROM THE MOON", CX, 2, "4x5", PATCH_LABEL_COLOR, align = "center")
        date_str = MONTH_ABBR[lmo - 1] + " " + str(ld) + ", " + str(ly)
        draw_outlined_text(c, date_str, CX, 10, "5x7", "white", align = "center")
        draw_outlined_text(c, format_clock(lh, lmin, sec) + " " + abbr, CX, 21, "6x8", "amber", align = "center")
    elif page == 8:
        p8 = info["p8"]
        if p8[0] == "ORBITS":
            draw_outlined_text(c, "LUNAR ORBITS", CX, 4, "4x5", PATCH_LABEL_COLOR, align = "center")
            draw_outlined_text(c, str(p8[1]), CX, 13, "10x14", "amber", align = "center")
        else:
            draw_outlined_text(c, "DEEP SPACE EVA - " + moonwalker_name(mission, p8[1]), CX, 4, "4x5", PATCH_LABEL_COLOR, align = "center")
            draw_duration(c, CX, 13, p8[2], "amber", num_font = "10x14", num_h = 14)
    return True


# Nearest day with an event, forward or back, for the NEXT/LAST pages.
# Ties on that day are picked with rotation_index(). Returns (mission, kind,
# days).
def nearest_event(ctx, forward):
    today_z = days_from_civil(ctx.now.year, ctx.now.month, ctx.now.day)
    step = 1 if forward else -1
    for offset in range(1, 367):
        y, m, d = civil_from_days(today_z + step * offset)
        events = find_flight_events(m, d)
        if len(events) > 0:
            idx = rotation_index(ctx, len(events))
            mission, kind = events[idx]
            return mission, kind, offset
    return None, None, 0


def launch_site_for(name):
    if is_soyuz(name):
        return "BAIKONUR"
    if name in EARLY_CAPE_NAMES:
        return "CAPE CANAVERAL"
    # SLC-40 and SLC-41 are at Cape Canaveral, not KSC.
    if is_commercial(name) and LAUNCH_PAD.get(name, "").startswith("SLC"):
        return "CAPE CANAVERAL"
    return "KENNEDY SPACE CENTER"


# Launch pad per mission, and the landing runway for Shuttle missions.
LAUNCH_PAD = {
    "FREEDOM 7": "5",
    "LIBERTY BELL 7": "5",
    "FRIENDSHIP 7": "14",
    "AURORA 7": "14",
    "SIGMA 7": "14",
    "FAITH 7": "14",
    "GEMINI 3": "19",
    "GEMINI 4": "19",
    "GEMINI 5": "19",
    "GEMINI 7": "19",
    "GEMINI 6": "19",
    "GEMINI 8": "19",
    "GEMINI 9A": "19",
    "GEMINI 10": "19",
    "GEMINI 11": "19",
    "GEMINI 12": "19",
    "APOLLO 7": "34",
    "APOLLO 8": "39A",
    "APOLLO 9": "39A",
    "APOLLO 10": "39B",
    "APOLLO 11": "39A",
    "APOLLO 12": "39A",
    "APOLLO 13": "39A",
    "APOLLO 14": "39A",
    "APOLLO 15": "39A",
    "APOLLO 16": "39A",
    "APOLLO 17": "39A",
    "SKYLAB 2": "39B",
    "SKYLAB 3": "39B",
    "SKYLAB 4": "39B",
    "APOLLO-SOYUZ": "39B",
    "STS-1": "39A",
    "STS-2": "39A",
    "STS-3": "39A",
    "STS-4": "39A",
    "STS-5": "39A",
    "STS-6": "39A",
    "STS-7": "39A",
    "STS-8": "39A",
    "STS-9": "39A",
    "STS-41-B": "39A",
    "STS-41-C": "39A",
    "STS-41-D": "39A",
    "STS-41-G": "39A",
    "STS-51-A": "39A",
    "STS-51-C": "39A",
    "STS-51-D": "39A",
    "STS-51-B": "39A",
    "STS-51-G": "39A",
    "STS-51-F": "39A",
    "STS-51-I": "39A",
    "STS-51-J": "39A",
    "STS-61-A": "39A",
    "STS-61-B": "39A",
    "STS-61-C": "39A",
    "STS-51-L": "39B",
    "STS-26": "39B",
    "STS-27": "39B",
    "STS-29": "39B",
    "STS-30": "39B",
    "STS-28": "39B",
    "STS-34": "39B",
    "STS-33": "39B",
    "STS-32": "39A",
    "STS-36": "39A",
    "STS-31": "39B",
    "STS-41": "39B",
    "STS-38": "39A",
    "STS-35": "39B",
    "STS-37": "39B",
    "STS-39": "39A",
    "STS-40": "39B",
    "STS-43": "39A",
    "STS-48": "39A",
    "STS-44": "39A",
    "STS-42": "39A",
    "STS-45": "39A",
    "STS-49": "39B",
    "STS-50": "39A",
    "STS-46": "39B",
    "STS-47": "39B",
    "STS-52": "39B",
    "STS-53": "39A",
    "STS-54": "39B",
    "STS-56": "39B",
    "STS-55": "39A",
    "STS-57": "39B",
    "STS-51": "39B",
    "STS-58": "39B",
    "STS-61": "39B",
    "STS-60": "39A",
    "STS-62": "39B",
    "STS-59": "39A",
    "STS-65": "39A",
    "STS-64": "39B",
    "STS-68": "39A",
    "STS-66": "39B",
    "STS-63": "39B",
    "STS-67": "39A",
    "STS-71": "39A",
    "STS-70": "39B",
    "STS-69": "39A",
    "STS-73": "39B",
    "STS-74": "39A",
    "STS-72": "39B",
    "STS-75": "39B",
    "STS-76": "39B",
    "STS-77": "39B",
    "STS-78": "39B",
    "STS-79": "39A",
    "STS-80": "39B",
    "STS-81": "39B",
    "STS-82": "39A",
    "STS-83": "39A",
    "STS-84": "39A",
    "STS-94": "39A",
    "STS-85": "39A",
    "STS-86": "39A",
    "STS-87": "39B",
    "STS-89": "39A",
    "STS-90": "39B",
    "STS-91": "39A",
    "STS-95": "39B",
    "STS-88": "39A",
    "STS-96": "39B",
    "STS-93": "39B",
    "STS-103": "39B",
    "STS-99": "39A",
    "STS-101": "39A",
    "STS-106": "39B",
    "STS-92": "39A",
    "STS-97": "39B",
    "STS-98": "39A",
    "STS-102": "39B",
    "STS-100": "39A",
    "STS-104": "39B",
    "STS-105": "39A",
    "STS-108": "39B",
    "STS-109": "39A",
    "STS-110": "39B",
    "STS-111": "39A",
    "STS-112": "39B",
    "STS-113": "39A",
    "STS-107": "39A",
    "STS-114": "39B",
    "STS-121": "39B",
    "STS-115": "39B",
    "STS-116": "39B",
    "STS-117": "39A",
    "STS-118": "39A",
    "STS-120": "39A",
    "STS-122": "39A",
    "STS-123": "39A",
    "STS-124": "39A",
    "STS-126": "39A",
    "STS-119": "39A",
    "STS-125": "39A",
    "STS-127": "39A",
    "STS-128": "39A",
    "STS-129": "39A",
    "STS-130": "39A",
    "STS-131": "39A",
    "STS-132": "39A",
    "STS-133": "39A",
    "STS-134": "39A",
    "STS-135": "39A",
    "ARTEMIS II": "39B",
    # Baikonur Site 1/5 ("Gagarin's Start").
    "SOYUZ TM-21": "1",
    "SOYUZ TM-31": "1",
    "SOYUZ TMA-2": "1",
    "SOYUZ TMA-3": "1",
    "SOYUZ TMA-4": "1",
    "SOYUZ TMA-5": "1",
    "SOYUZ TMA-6": "1",
    "SOYUZ TMA-7": "1",
    "SOYUZ TMA-8": "1",
    "SOYUZ TMA-9": "1",
    "SOYUZ TMA-11": "1",
    "SOYUZ TMA-13": "1",
    "SOYUZ TMA-14": "1",
    "SOYUZ TMA-16": "1",
    "SOYUZ TMA-17": "1",
    "SOYUZ TMA-18": "1",
    "SOYUZ TMA-19": "1",
    "SOYUZ TMA-01M": "1",
    "SOYUZ TMA-20": "1",
    "SOYUZ TMA-21": "1",
    "SOYUZ TMA-02M": "1",
    "SOYUZ TMA-22": "1",
    "SOYUZ TMA-03M": "1",
    "SOYUZ TMA-04M": "1",
    "SOYUZ TMA-05M": "1",
    "SOYUZ TMA-06M": "31",
    "SOYUZ TMA-07M": "1",
    "SOYUZ TMA-08M": "1",
    "SOYUZ TMA-09M": "1",
    "SOYUZ TMA-10M": "1",
    "SOYUZ TMA-11M": "1",
    "SOYUZ TMA-12M": "1",
    "SOYUZ TMA-13M": "1",
    "SOYUZ TMA-14M": "1",
    "SOYUZ TMA-15M": "31",
    "SOYUZ TMA-16M": "1",
    "SOYUZ TMA-17M": "1",
    "SOYUZ TMA-19M": "1",
    "SOYUZ TMA-20M": "1",
    "SOYUZ MS-01": "1",
    "SOYUZ MS-02": "31",
    "SOYUZ MS-03": "1",
    "SOYUZ MS-04": "1",
    "SOYUZ MS-05": "1",
    "SOYUZ MS-06": "1",
    "SOYUZ MS-07": "1",
    "SOYUZ MS-08": "1",
    "SOYUZ MS-09": "1",
    "SOYUZ MS-11": "1",
    "SOYUZ MS-12": "1",
    "SOYUZ MS-13": "1",
    "SOYUZ MS-15": "1",
    "SOYUZ MS-16": "31",
    "SOYUZ MS-17": "31",
    "SOYUZ MS-18": "31",
    "SOYUZ MS-22": "31",
    "SOYUZ MS-24": "31",
    "SOYUZ MS-25": "31",
    "SOYUZ MS-26": "31",
    "SOYUZ MS-27": "31",
    "SOYUZ MS-28": "31",
    "SOYUZ MS-29": "31",
    "SPACEX DEMO-2": "39A",
    "SPACEX CREW-1": "39A",
    "SPACEX CREW-2": "39A",
    "SPACEX CREW-3": "39A",
    "SPACEX CREW-4": "39A",
    "SPACEX CREW-5": "39A",
    "SPACEX CREW-6": "39A",
    "SPACEX CREW-7": "39A",
    "SPACEX CREW-8": "39A",
    "STARLINER CFT": "SLC-41",
    "SPACEX CREW-9": "SLC-40",
    "SPACEX CREW-10": "39A",
    "SPACEX CREW-11": "39A",
    "SPACEX CREW-12": "SLC-40",
    "SOYUZ TMA-1": "1",
    "SOYUZ TMA-18M": "1",
    "SOYUZ MS-19": "31",
    "SOYUZ MS-23": "31",
    "SOYUZ MS-10": "1",
    "INSPIRATION4": "39A",
    "AXIOM-1": "39A",
    "AXIOM-2": "39A",
    "AXIOM-3": "39A",
    "POLARIS DAWN": "39A",
    "AXIOM-4": "39A",
}

LANDING_RUNWAY = {
    "STS-1": "23",
    "STS-2": "23",
    "STS-3": "17",
    "STS-4": "22",
    "STS-5": "22",
    "STS-6": "22",
    "STS-7": "15",
    "STS-8": "22",
    "STS-9": "17",
    "STS-41-B": "15",
    "STS-41-C": "17",
    "STS-41-D": "17",
    "STS-41-G": "33",
    "STS-51-A": "15",
    "STS-51-C": "15",
    "STS-51-D": "33",
    "STS-51-B": "17",
    "STS-51-G": "23",
    "STS-51-F": "23",
    "STS-51-I": "23",
    "STS-51-J": "23",
    "STS-61-A": "17",
    "STS-61-B": "22",
    "STS-61-C": "22",
    "STS-26": "17",
    "STS-27": "17",
    "STS-29": "22",
    "STS-30": "22",
    "STS-28": "17",
    "STS-34": "23",
    "STS-33": "04",
    "STS-32": "22",
    "STS-36": "23",
    "STS-31": "22",
    "STS-41": "22",
    "STS-38": "33",
    "STS-35": "22",
    "STS-37": "33",
    "STS-39": "15",
    "STS-40": "22",
    "STS-43": "15",
    "STS-48": "22",
    "STS-44": "05",
    "STS-42": "22",
    "STS-45": "33",
    "STS-49": "22",
    "STS-50": "33",
    "STS-46": "33",
    "STS-47": "33",
    "STS-52": "33",
    "STS-53": "22",
    "STS-54": "33",
    "STS-56": "33",
    "STS-55": "22",
    "STS-57": "33",
    "STS-51": "15",
    "STS-58": "22",
    "STS-61": "33",
    "STS-60": "15",
    "STS-62": "33",
    "STS-59": "22",
    "STS-65": "33",
    "STS-64": "04",
    "STS-68": "22",
    "STS-66": "22",
    "STS-63": "15",
    "STS-67": "22",
    "STS-71": "15",
    "STS-70": "33",
    "STS-69": "33",
    "STS-73": "33",
    "STS-74": "33",
    "STS-72": "15",
    "STS-75": "33",
    "STS-76": "22",
    "STS-77": "33",
    "STS-78": "33",
    "STS-79": "15",
    "STS-80": "33",
    "STS-81": "33",
    "STS-82": "15",
    "STS-83": "33",
    "STS-84": "33",
    "STS-94": "33",
    "STS-85": "33",
    "STS-86": "15",
    "STS-87": "33",
    "STS-89": "15",
    "STS-90": "33",
    "STS-91": "15",
    "STS-95": "33",
    "STS-88": "15",
    "STS-96": "15",
    "STS-93": "33",
    "STS-103": "33",
    "STS-99": "33",
    "STS-101": "15",
    "STS-106": "15",
    "STS-92": "22",
    "STS-97": "15",
    "STS-98": "22",
    "STS-102": "15",
    "STS-100": "22",
    "STS-104": "15",
    "STS-105": "15",
    "STS-108": "15",
    "STS-109": "33",
    "STS-110": "33",
    "STS-111": "22",
    "STS-112": "33",
    "STS-113": "33",
    "STS-114": "22",
    "STS-121": "15",
    "STS-115": "33",
    "STS-116": "15",
    "STS-117": "22",
    "STS-118": "15",
    "STS-120": "33",
    "STS-122": "15",
    "STS-123": "15",
    "STS-124": "15",
    "STS-126": "04",
    "STS-119": "15",
    "STS-125": "22",
    "STS-127": "15",
    "STS-128": "22",
    "STS-129": "33",
    "STS-130": "15",
    "STS-131": "33",
    "STS-132": "33",
    "STS-133": "15",
    "STS-134": "15",
    "STS-135": "15",
}

# 1ST/2ND/3RD/4TH... with the 11/12/13 exception (11TH, not 11ST, etc.).
def ordinal(n):
    if n % 100 in (11, 12, 13):
        suffix = "TH"
    elif n % 10 == 1:
        suffix = "ST"
    elif n % 10 == 2:
        suffix = "ND"
    elif n % 10 == 3:
        suffix = "RD"
    else:
        suffix = "TH"
    return str(n) + suffix

# Which flight this was for its orbiter, counted from SHUTTLE_DATA.
def orbiter_flight_number(name):
    orbiter = ORBITER.get(name)
    if orbiter == None:
        return None
    count = 0
    for m in SHUTTLE_DATA:
        if ORBITER.get(m[0]) == orbiter:
            count += 1
            if m[0] == name:
                return count
    return None


# Year of this event (MOONLAND uses the landing year).
def flight_year(mission, kind):
    name, ly, lm, ld, ny, nm, nd, crew = mission
    if kind == "LAUNCH":
        return ly
    if kind == "MOONLAND":
        return MOON_LANDING_TIME[name][0]
    return ny


def flight_sentence(mission, kind):
    name, ly, lm, ld, ny, nm, nd, crew = mission
    times = MISSION_TIMES.get(name, (0, 0, 0, 0, 0, 0))

    if kind == "LAUNCH":
        lh, lmin, lsec = times[0], times[1], times[2]
        _, _, _, local_h, local_m, abbr = utc_to_local(ly, lm, ld, lh, lmin, launch_zone_for(name))
        site = launch_site_for(name)
        pad = LAUNCH_PAD.get(name)
        if pad != None:
            if pad.startswith("SLC-"):
                site = site + ", SPACE LAUNCH COMPLEX " + pad[4:]
            else:
                site = site + ", PAD " + pad
        clock = format_clock(local_h, local_m, lsec)
        return "LAUNCHED FROM " + site + " AT " + clock + " " + abbr + "."

    if kind == "MOONLAND":
        moon_y, moon_mo, moon_dy, moon_h, moon_min, moon_sec = MOON_LANDING_TIME[name]
        _, _, _, local_h, local_m, abbr = utc_to_local(moon_y, moon_mo, moon_dy, moon_h, moon_min, "CENTRAL")
        clock = format_clock(local_h, local_m, moon_sec)
        lm_name = APOLLO_MODULE_NAMES.get(name, (None, "LUNAR MODULE"))[1]
        site = MOON_LANDING_SITE.get(name, "THE MOON")
        return (lm_name + " LANDED ON THE MOON IN " + site +
                " AT " + clock + " " + abbr + ".")

    nh, nmin, nsec = times[3], times[4], times[5]
    label = END_LABEL_OVERRIDE.get(name, "LANDED")

    if label == "LOST":
        phase = LOST_PHASE.get(name, "FLIGHT")
        _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, "EASTERN")
        clock = format_clock(local_h, local_m, nsec)
        return "LOST DURING " + phase + " AT " + clock + " " + abbr + "."

    if is_soyuz(name):
        _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, "MSK")
        clock = format_clock(local_h, local_m, nsec)
        if name in ABORTED_NAMES:
            return "LAUNCH ABORTED. LANDED IN KAZAKHSTAN AT " + clock + " " + abbr + "."
        return "LANDED IN KAZAKHSTAN AT " + clock + " " + abbr + "."

    if ORBITER.get(name) != None:
        bucket = SHUTTLE_LANDING_SITE.get(name, "KSC")
        site_name, zone = LANDING_SITE_INFO[bucket]
        runway = LANDING_RUNWAY.get(name)
        if runway != None:
            site_name = site_name + ", RUNWAY " + runway
        _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, zone)
        clock = format_clock(local_h, local_m, nsec)
        return "LANDED AT " + site_name + " AT " + clock + " " + abbr + "."

    ocean = SPLASHDOWN_OCEAN.get(name, "ATLANTIC")
    ocean_name, zone = OCEAN_INFO[ocean]
    _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, zone)
    clock = format_clock(local_h, local_m, nsec)
    return "SPLASHED DOWN IN " + ocean_name + " AT " + clock + " " + abbr + "."


def mission_abs_times(mission):
    name, ly, lm, ld, ny, nm, nd, crew = mission
    lh, lmin, lsec, nh, nmin, nsec = MISSION_TIMES.get(name, (0, 0, 0, 0, 0, 0))
    launch_abs = days_from_civil(ly, lm, ld) * 86400 + lh * 3600 + lmin * 60 + lsec
    land_abs = days_from_civil(ny, nm, nd) * 86400 + nh * 3600 + nmin * 60 + nsec
    return launch_abs, land_abs


def mission_duration_seconds(mission):
    launch_abs, land_abs = mission_abs_times(mission)
    diff = land_abs - launch_abs
    return diff if diff > 0 else 0


def duration_groups(total_seconds):
    dd = total_seconds // 86400
    rem = total_seconds % 86400
    hh = rem // 3600
    rem = rem % 3600
    mm = rem // 60
    ss = rem % 60

    show_days = dd > 0
    show_hours = show_days or hh > 0

    # No zero-padding: "9M 5S".
    groups = []
    if show_days:
        groups.append((str(dd), "D"))
    if show_hours:
        groups.append((str(hh), "H"))
    groups.append((str(mm), "M"))
    groups.append((str(ss), "S"))
    return groups


# Width of a D/H/M/S duration at the given fonts and spacing.
def duration_width(c, groups, num_font, label_font, gap, label_gap):
    total_w = 0
    for i in range(len(groups)):
        num_text, letter = groups[i]
        total_w += c.text_width(num_text, font = num_font)
        total_w += label_gap
        total_w += c.text_width(letter, font = label_font)
        if i < len(groups) - 1:
            total_w += gap
    return total_w


def duration(c, ctx):
    if draw_moon_page(c, ctx, 3):
        return
    today_month = ctx.now.month
    today_day = ctx.now.day

    # Same event list the flight and crew pages use, so all pages agree.
    events = find_flight_events(today_month, today_day)

    # Empty day: countdown to the next event. Page 4 shows the last one.
    if len(events) == 0:
        mission, kind, n = nearest_event(ctx, True)
        name = mission[0]
        draw_patch_background(c, name)
        verb = {"LAUNCH": "LAUNCH", "LAND": "LANDING", "MOONLAND": "MOON LANDING"}[kind]
        mission_line = display_name(name).upper() + " " + verb
        days_line = "IN " + str(n) + (" DAY" if n == 1 else " DAYS")
        font = shared_font(c, [mission_line, days_line], ["6x8", "5x7", "4x5"], CW)
        fitted1, _ = fit_text(c, mission_line, [font], CW)
        fitted2, _ = fit_text(c, days_line, [font], CW)
        h = 8 if font == "6x8" else (7 if font == "5x7" else 6)
        label_h = 6
        gap = 2
        c.text("NEXT", CX, 1, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        top = label_h + gap
        y1 = top + (32 - top - (h + gap + h)) // 2
        y2 = y1 + h + gap
        c.text(fitted1, CX, y1, font = font, color = "white", align = "center")
        c.text(fitted2, CX, y2, font = font, color = "amber", align = "center")
        return

    idx = rotation_index(ctx, len(events))
    mission, kind = events[idx]
    name, ly, lm, ld, ny, nm, nd, crew = mission

    land_m, land_d = local_land_date(mission)
    land_is_today = land_m == today_month and land_d == today_day
    is_lost_today = END_LABEL_OVERRIDE.get(name) == "LOST" and land_is_today

    draw_patch_background(c, name)
    total_seconds = mission_duration_seconds(mission)

    # Still in flight (see IN_FLIGHT_NAMES): no landing exists to measure to,
    # so show real elapsed time since liftoff instead.
    in_flight = name in IN_FLIGHT_NAMES
    if in_flight:
        lh, lmin, lsec, _, _, _ = MISSION_TIMES.get(name, (0, 0, 0, 0, 0, 0))
        launch_unix = (days_from_civil(ly, lm, ld) - days_from_civil(1970, 1, 1)) * 86400 + lh * 3600 + lmin * 60 + lsec
        total_seconds = max(0, ctx.now.unix - launch_unix)

    # Apollo 1 never launched: show its legacy instead of a 0 duration.
    if is_lost_today and total_seconds == 0:
        legacy = ("FORCED A CM REDESIGN EVERY LATER APOLLO FLIGHT RELIED ON: A " +
                  "QUICK-RELEASE HATCH, SAFER CABIN AIR, AND LESS FLAMMABLE MATERIAL.")
        draw_wrapped_fit_outlined(c, legacy, L, 1, CW, "white", 31)
        return

    draw_outlined_text(c, display_name(name).upper(), L, 1, "4x5", "white", align = "left")
    # Orbiter name between mission name and year (Shuttle only).
    orbiter = ORBITER.get(name)
    if orbiter != None:
        draw_outlined_text(c, orbiter.upper(), CX, 1, "4x5", "white", align = "center")
    draw_outlined_text(c, str(flight_year(mission, kind)), R, 1, "4x5", "white", align = "right")

    label = "LOST AFTER" if is_lost_today else ("IN SPACE" if in_flight else "DURATION")
    label_color = LOST_COLOR if is_lost_today else PATCH_LABEL_COLOR
    digit_color = LOST_COLOR if is_lost_today else "amber"

    # Shuttle: label left, orbiter flight number right.
    flight_num = orbiter_flight_number(name)
    label_y = HEADER_HEIGHT + 1
    if flight_num != None:
        draw_outlined_text(c, label.upper(), L, label_y, "4x5", label_color, align = "left")
        draw_outlined_text(c, ordinal(flight_num) + " FLIGHT", R, label_y, "4x5", label_color, align = "right")
    else:
        draw_outlined_text(c, label.upper(), CX, label_y, "4x5", label_color, align = "center")

    draw_duration(c, CX, HEADER_HEIGHT + 7, total_seconds, digit_color, num_font = "10x14", num_h = 14)


# Crew who launched and landed on different missions, keyed by mission,
# then by name (spelled as in that crew string). (status, station): "UP" =
# launched on this mission but stayed at the station; "DOWN" = landed on
# this mission after arriving on another.
CREW_SWAP = {
    "STS-71": {
        "Anatoly Solovyev": ("UP", "MIR"),
        "Nikolai Budarin": ("UP", "MIR"),
        "Vladimir Dezhurov": ("DOWN", "MIR"),
        "Gennady Strekalov": ("DOWN", "MIR"),
        "Norman Thagard": ("DOWN", "MIR"),
    },
    "STS-76": {
        "Shannon Lucid": ("UP", "MIR"),
    },
    "STS-79": {
        "John Blaha": ("UP", "MIR"),
        "Shannon Lucid": ("DOWN", "MIR"),
    },
    "STS-81": {
        "Jerry Linenger": ("UP", "MIR"),
        "John Blaha": ("DOWN", "MIR"),
    },
    "STS-84": {
        "Michael Foale": ("UP", "MIR"),
        "Jerry Linenger": ("DOWN", "MIR"),
    },
    "STS-86": {
        "David Wolf": ("UP", "MIR"),
        "Michael Foale": ("DOWN", "MIR"),
    },
    "STS-89": {
        "Andrew Thomas": ("UP", "MIR"),
        "David Wolf": ("DOWN", "MIR"),
    },
    "STS-91": {
        "Andrew Thomas": ("DOWN", "MIR"),
    },
    "STS-102": {
        "Yuri Usachov": ("UP", "ISS"),
        "James Voss": ("UP", "ISS"),
        "Susan Helms": ("UP", "ISS"),
        "William Shepherd": ("DOWN", "ISS"),
        "Yuri Gidzenko": ("DOWN", "ISS"),
        "Sergei Krikalev": ("DOWN", "ISS"),
    },
    "STS-105": {
        "Frank Culbertson": ("UP", "ISS"),
        "Mikhail Tyurin": ("UP", "ISS"),
        "Vladimir Dezhurov": ("UP", "ISS"),
        "Yuri Usachov": ("DOWN", "ISS"),
        "James Voss": ("DOWN", "ISS"),
        "Susan Helms": ("DOWN", "ISS"),
    },
    "STS-108": {
        "Yury Onufriyenko": ("UP", "ISS"),
        "Carl Walz": ("UP", "ISS"),
        "Daniel Bursch": ("UP", "ISS"),
        "Frank Culbertson": ("DOWN", "ISS"),
        "Mikhail Tyurin": ("DOWN", "ISS"),
        "Vladimir Dezhurov": ("DOWN", "ISS"),
    },
    "STS-111": {
        "Valery Korzun": ("UP", "ISS"),
        "Peggy Whitson": ("UP", "ISS"),
        "Sergey Treshchov": ("UP", "ISS"),
        "Yury Onufriyenko": ("DOWN", "ISS"),
        "Carl Walz": ("DOWN", "ISS"),
        "Daniel Bursch": ("DOWN", "ISS"),
    },
    "STS-113": {
        "Kenneth Bowersox": ("UP", "ISS"),
        "Nikolai Budarin": ("UP", "ISS"),
        "Donald Pettit": ("UP", "ISS"),
        "Valery Korzun": ("DOWN", "ISS"),
        "Peggy Whitson": ("DOWN", "ISS"),
        "Sergey Treshchov": ("DOWN", "ISS"),
    },
    "STS-121": {
        "Thomas Reiter": ("UP", "ISS"),
    },
    "STS-116": {
        "Sunita Williams": ("UP", "ISS"),
        "Thomas Reiter": ("DOWN", "ISS"),
    },
    "STS-117": {
        "Clayton Anderson": ("UP", "ISS"),
        "Sunita Williams": ("DOWN", "ISS"),
    },
    "STS-120": {
        "Daniel Tani": ("UP", "ISS"),
        "Clayton Anderson": ("DOWN", "ISS"),
    },
    "STS-122": {
        "Leopold Eyharts": ("UP", "ISS"),
        "Daniel Tani": ("DOWN", "ISS"),
    },
    "STS-123": {
        "Garrett Reisman": ("UP", "ISS"),
        "Leopold Eyharts": ("DOWN", "ISS"),
    },
    "STS-124": {
        "Gregory Chamitoff": ("UP", "ISS"),
        "Garrett Reisman": ("DOWN", "ISS"),
    },
    "STS-126": {
        "Sandra Magnus": ("UP", "ISS"),
        "Gregory Chamitoff": ("DOWN", "ISS"),
    },
    "STS-119": {
        "Koichi Wakata": ("UP", "ISS"),
        "Sandra Magnus": ("DOWN", "ISS"),
    },
    "STS-127": {
        "Timothy Kopra": ("UP", "ISS"),
        "Koichi Wakata": ("DOWN", "ISS"),
    },
    "STS-128": {
        "Nicole Stott": ("UP", "ISS"),
        "Timothy Kopra": ("DOWN", "ISS"),
    },
    "STS-129": {
        "Nicole Stott": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-2": {
        "Pedro Duque": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-3": {
        "Pedro Duque": ("UP", "ISS"),
        "Andre Kuipers": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-4": {
        "Andre Kuipers": ("UP", "ISS"),
        "Yuri Shargin": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-5": {
        "Yuri Shargin": ("UP", "ISS"),
        "Roberto Vittori": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-6": {
        "Roberto Vittori": ("UP", "ISS"),
    },
    "SOYUZ TMA-7": {
        "Marcos Pontes": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-8": {
        "Marcos Pontes": ("UP", "ISS"),
    },
    "SOYUZ TMA-11": {
        "Sheikh Muszaphar Shukor": ("UP", "ISS"),
        "Yi So-Yeon": ("DOWN", "ISS"),
    },
    "SOYUZ MS-04": {
        "Peggy Whitson": ("DOWN", "ISS"),
    },
    "SOYUZ MS-12": {
        "Christina Koch": ("UP", "ISS"),
        "Hazza Al Mansouri": ("DOWN", "ISS"),
    },
    "SOYUZ MS-13": {
        "Andrew Morgan": ("UP", "ISS"),
        "Christina Koch": ("DOWN", "ISS"),
    },
    "SOYUZ MS-15": {
        "Hazza Al Mansouri": ("UP", "ISS"),
        "Andrew Morgan": ("DOWN", "ISS"),
    },
    "SOYUZ MS-24": {
        "Oleg Kononenko": ("UP", "ISS"),
        "Nikolai Chub": ("UP", "ISS"),
        "Oleg Novitsky": ("DOWN", "ISS"),
    },
    "SOYUZ MS-25": {
        "Oleg Novitsky": ("UP", "ISS"),
        "Oleg Kononenko": ("DOWN", "ISS"),
        "Nikolai Chub": ("DOWN", "ISS"),
    },
    "SPACEX CREW-9": {
        "Barry Wilmore": ("DOWN", "ISS"),
        "Sunita Williams": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-1": {
        "Nikolai Budarin": ("DOWN", "ISS"),
        "Kenneth Bowersox": ("DOWN", "ISS"),
        "Donald Pettit": ("DOWN", "ISS"),
    },
    "SOYUZ TMA-18M": {
        "Mikhail Kornienko": ("DOWN", "ISS"),
        "Scott Kelly": ("DOWN", "ISS"),
    },
    "SOYUZ MS-19": {
        "Pyotr Dubrov": ("DOWN", "ISS"),
        "Mark Vande Hei": ("DOWN", "ISS"),
    },
    "SOYUZ MS-23": {
        "Sergey Prokopyev": ("DOWN", "ISS"),
        "Dmitry Petelin": ("DOWN", "ISS"),
        "Francisco Rubio": ("DOWN", "ISS"),
    },
}

STATION_TAG_COLOR = "#00CCFF"

# Two crew per page for the default layout.
CREW_PAGE_SIZE = 2


# Display order by role; unknown roles keep their list position.
ASTP_ROLE_ORDER = {"CDR": 0, "CMP": 1, "DMP": 2}
SKYLAB_ROLE_ORDER = {"CDR": 0, "SPT": 1, "PLT": 2}
APOLLO_ROLE_ORDER = {"CDR": 0, "CMP": 1, "LMP": 2}


def roster_sort_key(mission_name, role, orig_idx):
    if mission_name == "APOLLO-SOYUZ":
        return (ASTP_ROLE_ORDER.get(role, 9), orig_idx)
    if mission_name.startswith("SKYLAB"):
        return (SKYLAB_ROLE_ORDER.get(role, 9), orig_idx)
    if mission_name.startswith("APOLLO"):
        return (APOLLO_ROLE_ORDER.get(role, 9), orig_idx)
    if mission_name in MERCURY_NAMES or mission_name in GEMINI_NAMES:
        return (0, orig_idx)
    # Private flights keep their crew-list (seat) order.
    if mission_name in PRIVATE_SPACECRAFT:
        return (0, orig_idx)

    # Shuttle: CDR, PLT, PC, MS#, then PS/MSE, then no role.
    if role == "CDR":
        return (0, 0)
    if role == "PLT":
        return (1, 0)
    if role == "PC":
        return (2, 0)
    # Before the MS# branch: "MSE" also starts with "MS".
    if role == "MSE":
        return (4, 0)
    if role.startswith("MS"):
        n = int(role[2:]) if len(role) > 2 else 0
        return (3, n)
    if role.startswith("PS"):
        n = int(role[2:]) if len(role) > 2 else 0
        return (4, n)
    if role == "":
        return (5, orig_idx)
    return (6, orig_idx)


# "MILLIE HUGHES-FULFORD" -> "M. HUGHES-FULFORD".
def abbreviate_first_name(name):
    parts = name.split(" ", 1)
    if len(parts) < 2 or parts[0] == "":
        return name
    return parts[0][0] + ". " + parts[1]


# All 3 Apollo/Skylab/ASTP crew on one page, sorted by role.
def draw_trio_crew(c, mission, kind):
    mission_name = mission[0]
    if not draw_patch_background(c, mission_name):
        c.fill("#000000")
    roster = build_applicable_roster(mission, kind)

    n = len(roster)
    block_h = 32 // n
    tier = crew_rows_tier(c, roster)
    for i in range(n):
        person_name, role, tag = roster[i]
        y = i * block_h + (block_h - 6) // 2
        draw_crew_row(c, y, person_name, role, tag, tier)


# Today's crew in display order. On a launch day, skips anyone who only
# landed on this mission; on a landing day, anyone who only launched on it.
# DOWN-only crew get no role, just the TO/FROM tag.
def build_applicable_roster(mission, kind):
    name, ly, lm, ld, ny, nm, nd, crew_str = mission
    all_names = parse_crew(crew_str)
    swap = CREW_SWAP.get(name, {})

    unsorted_roster = []
    for i in range(len(all_names)):
        person = all_names[i]
        info = swap.get(person)
        tag = ""
        role = crew_role(name, all_names, i)
        if info != None:
            status, station = info
            if kind == "LAUNCH" and status == "DOWN":
                continue
            if kind == "LAND" and status == "UP":
                continue
            tag = ("TO " if status == "UP" else "FROM ") + station
            if status == "DOWN":
                role = ""
        unsorted_roster.append((roster_sort_key(name, role, i), person, role, tag))

    sorted_roster = sorted(unsorted_roster)
    roster = []
    for key, person, role, tag in sorted_roster:
        roster.append((person, role, tag))
    return roster


def draw_crew_page(c, ctx, page_index):
    today_month = ctx.now.month
    today_day = ctx.now.day

    events = find_flight_events(today_month, today_day)

    if len(events) == 0:
        draw_no_events(c)
        return

    idx = rotation_index(ctx, len(events))
    mission, kind = events[idx]
    name = mission[0]
    roster = build_applicable_roster(mission, kind)

    start = page_index * CREW_PAGE_SIZE
    if start >= len(roster):
        # Crew doesn't reach this page: the mission's name card instead.
        draw_mission_ident(c, name, flight_year(mission, kind))
        return

    if not draw_patch_background(c, name):
        c.fill("#000000")

    members = roster[start:start + CREW_PAGE_SIZE]
    # A lone crew member gets the full 32px.
    block_h = 32 // len(members)
    for i in range(len(members)):
        person, role, tag = members[i]
        draw_crew_member(c, i * block_h, block_h, person, role, tag)


# Per-page crew counts for Shuttle roster sizes 5-8 (max 3 pages). Sizes 2
# and 4 use the fixed 2-per-page layout. Pages of 2 use the stacked layout,
# pages of 3 compact rows.
SHUTTLE_CREW_PAGE_LAYOUT = {
    5: [2, 3],
    6: [3, 3],
    7: [2, 3, 2],
    8: [2, 3, 3],
}


# Whether this mission/kind's roster reaches a real page 6, without
# drawing. Roster size can differ between launch and landing day.
def shuttle_crew_reaches_page6(mission, kind):
    roster = build_applicable_roster(mission, kind)
    layout = SHUTTLE_CREW_PAGE_LAYOUT.get(len(roster))
    if layout == None:
        return 2 * CREW_PAGE_SIZE < len(roster)
    return 2 < len(layout)


# Returns False when this page is past the roster, so the caller can show
# something else.
def draw_shuttle_crew_page(c, ctx, page_index):
    today_month = ctx.now.month
    today_day = ctx.now.day

    events = find_flight_events(today_month, today_day)

    if len(events) == 0:
        draw_no_events(c)
        return False

    idx = rotation_index(ctx, len(events))
    mission, kind = events[idx]
    name = mission[0]
    roster = build_applicable_roster(mission, kind)

    layout = SHUTTLE_CREW_PAGE_LAYOUT.get(len(roster))
    if layout == None:
        # 2 or 4 crew: fixed 2 per page.
        start = page_index * CREW_PAGE_SIZE
        if start >= len(roster):
            return False
        members = roster[start:start + CREW_PAGE_SIZE]
    else:
        if page_index >= len(layout):
            return False
        start = 0
        for i in range(page_index):
            start += layout[i]
        members = roster[start:start + layout[page_index]]

    if not draw_patch_background(c, name):
        c.fill("#000000")

    # Only the first page uses the stacked layout; later pages use rows.
    is_hero_page = (layout == None) or (page_index == 0)
    tier = crew_rows_tier(c, members)

    for i in range(len(members)):
        person, role, tag = members[i]
        if is_hero_page and len(members) <= 2:
            block_h = 32 // len(members)
            draw_crew_member(c, i * block_h, block_h, person, role, tag)
        else:
            # Rows sit on a fixed 3-row grid so every page lines up.
            block_h = 32 // 3
            y = i * block_h + (block_h - 6) // 2
            draw_crew_row(c, y, person, role, tag, tier)
    return True


# Command/Lunar Module call signs, Apollo 9-17.
APOLLO_MODULE_NAMES = {
    "APOLLO 9": ("GUMDROP", "SPIDER"),
    "APOLLO 10": ("CHARLIE BROWN", "SNOOPY"),
    "APOLLO 11": ("COLUMBIA", "EAGLE"),
    "APOLLO 12": ("YANKEE CLIPPER", "INTREPID"),
    "APOLLO 13": ("ODYSSEY", "AQUARIUS"),
    "APOLLO 14": ("KITTY HAWK", "ANTARES"),
    "APOLLO 15": ("ENDEAVOUR", "FALCON"),
    "APOLLO 16": ("CASPER", "ORION"),
    "APOLLO 17": ("AMERICA", "CHALLENGER"),
}


def current_flight_event(ctx):
    events = find_flight_events(ctx.now.month, ctx.now.day)
    if len(events) == 0:
        return None
    idx = rotation_index(ctx, len(events))
    return events[idx]


# Fixed 5x7 font and positions so every mission's page lines up.
def draw_module_block(c, label_y, name_y, label, name):
    fitted, _ = fit_text(c, name.upper(), ["5x7"], CW)
    draw_outlined_text(c, label, CX, label_y, "4x5", PATCH_LABEL_COLOR, align = "center")
    draw_outlined_text(c, fitted, CX, name_y, "5x7", "white", align = "center")


# Prime recovery ship per splashdown mission.
RECOVERY_SHIP = {
    "FREEDOM 7": "USS Lake Champlain",
    "LIBERTY BELL 7": "USS Randolph",
    "FRIENDSHIP 7": "USS Noa",
    "AURORA 7": "USS Intrepid",
    "SIGMA 7": "USS Kearsarge",
    "FAITH 7": "USS Kearsarge",
    "GEMINI 3": "USS Intrepid",
    "GEMINI 4": "USS Wasp",
    "GEMINI 5": "USS Lake Champlain",
    "GEMINI 7": "USS Wasp",
    "GEMINI 6": "USS Wasp",
    # Emergency Pacific splashdown.
    "GEMINI 8": "USS Leonard F. Mason",
    "GEMINI 9A": "USS Wasp",
    "GEMINI 10": "USS Guadalcanal",
    "GEMINI 11": "USS Guam",
    "GEMINI 12": "USS Wasp",
    "APOLLO 7": "USS Essex",
    "APOLLO 8": "USS Yorktown",
    "APOLLO 9": "USS Guadalcanal",
    "APOLLO 10": "USS Princeton",
    "APOLLO 11": "USS Hornet",
    "APOLLO 12": "USS Hornet",
    "APOLLO 13": "USS Iwo Jima",
    "APOLLO 14": "USS New Orleans",
    "APOLLO 15": "USS Okinawa",
    "APOLLO 16": "USS Ticonderoga",
    "APOLLO 17": "USS Ticonderoga",
    "SKYLAB 2": "USS Ticonderoga",
    "SKYLAB 3": "USS New Orleans",
    "SKYLAB 4": "USS New Orleans",
    "APOLLO-SOYUZ": "USS New Orleans",
    "ARTEMIS II": "USS John P. Murtha",
    "SPACEX DEMO-2": "MV GO Navigator",
    "SPACEX CREW-1": "MV GO Navigator",
    "SPACEX CREW-2": "MV GO Navigator",
    "SPACEX CREW-3": "MV Shannon",
    "SPACEX CREW-4": "MV Megan",
    "SPACEX CREW-5": "MV Shannon",
    "SPACEX CREW-6": "MV Megan",
    "SPACEX CREW-7": "MV Megan",
    "SPACEX CREW-8": "MV Megan",
    "SPACEX CREW-9": "MV Megan",
    "SPACEX CREW-10": "MV Shannon",
    "SPACEX CREW-11": "MV Shannon",
    "INSPIRATION4": "MV GO Searcher",
    "AXIOM-1": "MV Megan",
    "AXIOM-2": "MV Megan",
    "AXIOM-3": "MV Shannon",
    "POLARIS DAWN": "MV Shannon",
    "AXIOM-4": "MV Shannon",
}


# Small label over a larger value, centered in a block.
def draw_fact_block(c, y_top, block_h, label, value, gap = 3, color = "white"):
    fitted, font = fit_text(c, value.upper(), ["6x8", "5x7", "4x5"], CW)
    value_h = 8 if font == "6x8" else (7 if font == "5x7" else 6)
    label_h = 6
    start_y = y_top + (block_h - (label_h + gap + value_h)) // 2
    draw_outlined_text(c, label, CX, start_y, "4x5", PATCH_LABEL_COLOR, align = "center")
    draw_outlined_text(c, fitted, CX, start_y + label_h + gap, font, color, align = "center")


def draw_fact(c, name, label, value):
    if not draw_patch_background(c, name):
        c.fill("#000000")
    draw_fact_block(c, 0, 32, label, value)


# Two facts stacked on one page (NOTABLE_FIRST + NOTABLE_FIRST_2).
def draw_two_facts_stacked(c, name, label1, value1, label2, value2):
    if not draw_patch_background(c, name):
        c.fill("#000000")
    draw_fact_block(c, 0, 16, label1, value1, gap = 2)
    draw_fact_block(c, 16, 16, label2, value2, gap = 2)


# ISS Expedition page: which Expedition(s) the crew joined ("CREW UP") or
# which one their landing closes ("ENDS"). TM-21 reads "MIR EXPEDITION".
def draw_iss_expedition(c, name, kind):
    if name in ABORTED_NAMES:
        # MS-10: abort declared 121.57 s after liftoff.
        if not draw_patch_background(c, name):
            c.fill("#000000")
        draw_outlined_text(c, "ABORTED AFTER LIFTOFF", CX, 5, "4x5", PATCH_LABEL_COLOR, align = "center")
        draw_duration(c, CX, 13, 186, "amber", num_font = "10x14", num_h = 14)
        return True
    exp = ISS_EXPEDITION.get(name)
    if exp == None:
        return False
    value = exp[0] if kind == "LAUNCH" else exp[1]
    if value == "":
        return False
    # Soyuz landing card: the last Expedition, which ends with the undocking.
    tag = "CREW UP"
    if kind == "LAND":
        if is_soyuz(name):
            value = value.replace("/", "-").split("-")[-1]
            tag = "ENDS"
        else:
            # Dragon/Starliner crews return mid-Expedition, so show the full range.
            tag = "CREW HOME"
    if not draw_patch_background(c, name):
        c.fill("#000000")
    label = "MIR EXPEDITION" if name == "SOYUZ TM-21" else "EXPEDITION"
    draw_outlined_text(c, label, CX, 2, "4x5", PATCH_LABEL_COLOR, align = "center")
    # "10x14" has no "/" or "-": draw numbers big and the separator small.
    sep = "/" if "/" in value else "-"
    parts = value.split(sep) if sep in value else [value]
    gap = 3
    sep_w = c.text_width(sep, font = "5x7")
    total_w = 0
    for i in range(len(parts)):
        total_w += c.text_width(parts[i], font = "10x14")
        if i < len(parts) - 1:
            total_w += sep_w + 2 * gap
    x = CX - total_w // 2
    for i in range(len(parts)):
        draw_outlined_text(c, parts[i], x, 9, "10x14", "white", align = "left")
        x += c.text_width(parts[i], font = "10x14")
        if i < len(parts) - 1:
            draw_outlined_text(c, sep, x + gap, 12, "5x7", "#cccccc", align = "left")
            x += sep_w + 2 * gap
    draw_outlined_text(c, tag, CX, 26, "4x5", "amber", align = "center")
    return True


# Docking page: liftoff to docking (launch card) or undocking to landing
# (landing card). Stored as "H:MM:SS" total hours.
def dock_seconds(text):
    parts = text.split(":")
    return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])


def draw_iss_dock(c, name, kind):
    if name in ABORTED_NAMES:
        # MS-10 never reached orbit (93 km apogee).
        draw_fact(c, name, "MAX ALTITUDE", "OVER 90 KM")
        return True
    dock = ISS_DOCK.get(name)
    if dock == None:
        return False
    if kind == "LAUNCH":
        label = "DOCKED AFTER LAUNCH"
        value = dock[0]
    else:
        label = "UNDOCKED BEFORE LANDING"
        value = dock[1]
    if value == "":
        return False
    if not draw_patch_background(c, name):
        c.fill("#000000")
    draw_outlined_text(c, label, CX, 5, "4x5", PATCH_LABEL_COLOR, align = "center")
    draw_duration(c, CX, 13, dock_seconds(value), "amber", num_font = "10x14", num_h = 14)
    return True


# Launch vehicle and/or recovery ship; False if neither is on record.
def draw_vehicle_ship(c, name):
    vehicle = LAUNCH_VEHICLE.get(name)
    ship = RECOVERY_SHIP.get(name)
    if vehicle != None and ship != None:
        draw_two_facts(c, name, vehicle, ship)
        return True
    if vehicle != None:
        draw_fact(c, name, "LAUNCH VEHICLE", vehicle)
        return True
    if ship != None:
        draw_fact(c, name, "RECOVERY SHIP", ship)
        return True
    return False


def draw_big_value(c, cx, y, value):
    parts = value.split(" ")
    num = parts[0]
    unit = " ".join(parts[1:])
    nw = c.text_width(num, font = "10x14")
    uw = c.text_width(unit, font = "4x5") if unit != "" else 0
    total = nw + (2 + uw if unit != "" else 0)
    if total > 60:
        w = c.text_width(value, font = "6x8")
        x = min(max(cx - w // 2, L), R - w)
        draw_outlined_text(c, value, x, y + 4, "6x8", "white", align = "left")
        return
    x = cx - total // 2
    draw_outlined_text(c, num, x, y, "10x14", "amber", align = "left")
    if unit != "":
        draw_outlined_text(c, unit, x + nw + 2, y + 8, "4x5", "amber", align = "left")


# Launch vehicle per mission (not shown for Shuttle).
LAUNCH_VEHICLE = {
    "FREEDOM 7": "REDSTONE",
    "LIBERTY BELL 7": "REDSTONE",
    "FRIENDSHIP 7": "ATLAS",
    "AURORA 7": "ATLAS",
    "SIGMA 7": "ATLAS",
    "FAITH 7": "ATLAS",
    "GEMINI 3": "TITAN II",
    "GEMINI 4": "TITAN II",
    "GEMINI 5": "TITAN II",
    "GEMINI 7": "TITAN II",
    "GEMINI 6": "TITAN II",
    "GEMINI 8": "TITAN II",
    "GEMINI 9A": "TITAN II",
    "GEMINI 10": "TITAN II",
    "GEMINI 11": "TITAN II",
    "GEMINI 12": "TITAN II",
    "APOLLO 7": "SATURN IB",
    "APOLLO 8": "SATURN V",
    "APOLLO 9": "SATURN V",
    "APOLLO 10": "SATURN V",
    "APOLLO 11": "SATURN V",
    "APOLLO 12": "SATURN V",
    "APOLLO 13": "SATURN V",
    "APOLLO 14": "SATURN V",
    "APOLLO 15": "SATURN V",
    "APOLLO 16": "SATURN V",
    "APOLLO 17": "SATURN V",
    "SKYLAB 2": "SATURN IB",
    "SKYLAB 3": "SATURN IB",
    "SKYLAB 4": "SATURN IB",
    "APOLLO-SOYUZ": "SATURN IB",
    # Puts Apollo 1's crew on the trio-crew page.
    "APOLLO 1": "SATURN IB",
    # Shown on page 6 only (see details2).
    "ARTEMIS II": "SPACE LAUNCH SYSTEM",
    "SOYUZ TM-21": "SOYUZ-U2",
    "SOYUZ TM-31": "SOYUZ-U",
    "SOYUZ TMA-2": "SOYUZ-FG",
    "SOYUZ TMA-3": "SOYUZ-FG",
    "SOYUZ TMA-4": "SOYUZ-FG",
    "SOYUZ TMA-5": "SOYUZ-FG",
    "SOYUZ TMA-6": "SOYUZ-FG",
    "SOYUZ TMA-7": "SOYUZ-FG",
    "SOYUZ TMA-8": "SOYUZ-FG",
    "SOYUZ TMA-9": "SOYUZ-FG",
    "SOYUZ TMA-11": "SOYUZ-FG",
    "SOYUZ TMA-13": "SOYUZ-FG",
    "SOYUZ TMA-14": "SOYUZ-FG",
    "SOYUZ TMA-16": "SOYUZ-FG",
    "SOYUZ TMA-17": "SOYUZ-FG",
    "SOYUZ TMA-18": "SOYUZ-FG",
    "SOYUZ TMA-19": "SOYUZ-FG",
    "SOYUZ TMA-01M": "SOYUZ-FG",
    "SOYUZ TMA-20": "SOYUZ-FG",
    "SOYUZ TMA-21": "SOYUZ-FG",
    "SOYUZ TMA-02M": "SOYUZ-FG",
    "SOYUZ TMA-22": "SOYUZ-FG",
    "SOYUZ TMA-03M": "SOYUZ-FG",
    "SOYUZ TMA-04M": "SOYUZ-FG",
    "SOYUZ TMA-05M": "SOYUZ-FG",
    "SOYUZ TMA-06M": "SOYUZ-FG",
    "SOYUZ TMA-07M": "SOYUZ-FG",
    "SOYUZ TMA-08M": "SOYUZ-FG",
    "SOYUZ TMA-09M": "SOYUZ-FG",
    "SOYUZ TMA-10M": "SOYUZ-FG",
    "SOYUZ TMA-11M": "SOYUZ-FG",
    "SOYUZ TMA-12M": "SOYUZ-FG",
    "SOYUZ TMA-13M": "SOYUZ-FG",
    "SOYUZ TMA-14M": "SOYUZ-FG",
    "SOYUZ TMA-15M": "SOYUZ-FG",
    "SOYUZ TMA-16M": "SOYUZ-FG",
    "SOYUZ TMA-17M": "SOYUZ-FG",
    "SOYUZ TMA-19M": "SOYUZ-FG",
    "SOYUZ TMA-20M": "SOYUZ-FG",
    "SOYUZ MS-01": "SOYUZ-FG",
    "SOYUZ MS-02": "SOYUZ-FG",
    "SOYUZ MS-03": "SOYUZ-FG",
    "SOYUZ MS-04": "SOYUZ-FG",
    "SOYUZ MS-05": "SOYUZ-FG",
    "SOYUZ MS-06": "SOYUZ-FG",
    "SOYUZ MS-07": "SOYUZ-FG",
    "SOYUZ MS-08": "SOYUZ-FG",
    "SOYUZ MS-09": "SOYUZ-FG",
    "SOYUZ MS-11": "SOYUZ-FG",
    "SOYUZ MS-12": "SOYUZ-FG",
    "SOYUZ MS-13": "SOYUZ-FG",
    "SOYUZ MS-15": "SOYUZ-FG",
    "SOYUZ MS-16": "SOYUZ-2.1A",
    "SOYUZ MS-17": "SOYUZ-2.1A",
    "SOYUZ MS-18": "SOYUZ-2.1A",
    "SOYUZ MS-22": "SOYUZ-2.1A",
    "SOYUZ MS-24": "SOYUZ-2.1A",
    "SOYUZ MS-25": "SOYUZ-2.1A",
    "SOYUZ MS-26": "SOYUZ-2.1A",
    "SOYUZ MS-27": "SOYUZ-2.1A",
    "SOYUZ MS-28": "SOYUZ-2.1A",
    "SOYUZ MS-29": "SOYUZ-2.1A",
    "SPACEX DEMO-2": "FALCON 9",
    "SPACEX CREW-1": "FALCON 9",
    "SPACEX CREW-2": "FALCON 9",
    "SPACEX CREW-3": "FALCON 9",
    "SPACEX CREW-4": "FALCON 9",
    "SPACEX CREW-5": "FALCON 9",
    "SPACEX CREW-6": "FALCON 9",
    "SPACEX CREW-7": "FALCON 9",
    "SPACEX CREW-8": "FALCON 9",
    "STARLINER CFT": "ATLAS V N22",
    "SPACEX CREW-9": "FALCON 9",
    "SPACEX CREW-10": "FALCON 9",
    "SPACEX CREW-11": "FALCON 9",
    "SPACEX CREW-12": "FALCON 9",
    "SOYUZ TMA-1": "SOYUZ-FG",
    "SOYUZ TMA-18M": "SOYUZ-FG",
    "SOYUZ MS-19": "SOYUZ-2.1A",
    "SOYUZ MS-23": "SOYUZ-2.1A",
    "SOYUZ MS-10": "SOYUZ-FG",
    "INSPIRATION4": "FALCON 9",
    "AXIOM-1": "FALCON 9",
    "AXIOM-2": "FALCON 9",
    "AXIOM-3": "FALCON 9",
    "POLARIS DAWN": "FALCON 9",
    "AXIOM-4": "FALCON 9",
}

# Backup crews. Mercury/Gemini in launch order; Apollo/Skylab/ASTP in
# CDR/CMP/LMP (CDR/SPT/PLT, CDR/CMP/DMP) order to match crew_role().
# Final backup crews as flown: Apollo 9 (Bean replaced C.C. Williams),
# Apollo 13 (Mattingly), Apollo 17 (Young/Roosa/Duke).
BACKUP_CREW = {
    "FREEDOM 7": "John Glenn",
    "LIBERTY BELL 7": "John Glenn",
    "FRIENDSHIP 7": "Scott Carpenter",
    "AURORA 7": "Wally Schirra",
    "SIGMA 7": "Gordon Cooper",
    "FAITH 7": "Alan Shepard",
    "GEMINI 3": "Wally Schirra, Thomas Stafford",
    "GEMINI 4": "Frank Borman, Jim Lovell",
    "GEMINI 5": "Neil Armstrong, Elliot See",
    "GEMINI 7": "Ed White, Michael Collins",
    "GEMINI 6": "Gus Grissom, John Young",
    "GEMINI 8": "Pete Conrad, Richard Gordon",
    "GEMINI 9A": "Jim Lovell, Buzz Aldrin",
    "GEMINI 10": "Alan Bean, C.C. Williams",
    "GEMINI 11": "Neil Armstrong, William Anders",
    "GEMINI 12": "Gordon Cooper, Gene Cernan",
    "APOLLO 7": "Thomas Stafford, John Young, Gene Cernan",
    "APOLLO 8": "Neil Armstrong, Buzz Aldrin, Fred Haise",
    "APOLLO 9": "Pete Conrad, Richard Gordon, Alan Bean",
    "APOLLO 10": "Gordon Cooper, Donn Eisele, Edgar Mitchell",
    "APOLLO 11": "Jim Lovell, Bill Anders, Fred Haise",
    "APOLLO 12": "David Scott, Alfred Worden, James Irwin",
    "APOLLO 13": "John Young, Ken Mattingly, Charles Duke",
    "APOLLO 14": "Gene Cernan, Ronald Evans, Joe Engle",
    "APOLLO 15": "Richard Gordon, Vance Brand, Harrison Schmitt",
    "APOLLO 16": "Fred Haise, Stuart Roosa, Edgar Mitchell",
    "APOLLO 17": "John Young, Stuart Roosa, Charles Duke",
    "SKYLAB 2": "Rusty Schweickart, Story Musgrave, Bruce McCandless",
    "SKYLAB 3": "Vance Brand, William Lenoir, Don Lind",
    "SKYLAB 4": "Vance Brand, William Lenoir, Don Lind",
    "APOLLO-SOYUZ": "Alan Bean, Ronald Evans, Jack Lousma",
    # Apollo 1's backup crew, shown on page 5.
    "APOLLO 1": "Wally Schirra, Donn Eisele, Walter Cunningham",
    # OFT backup crews. Mattingly/Hartsfield backed up both STS-2 and STS-3.
    "STS-1": "Joe Engle, Richard Truly",
    "STS-2": "Ken Mattingly, Henry Hartsfield",
    "STS-3": "Ken Mattingly, Henry Hartsfield",
}

# Orbit count per Mercury/Gemini mission; "SUBORBITAL" for the two hops.
MERCURY_GEMINI_ORBITS = {
    "FREEDOM 7": "SUBORBITAL",
    "LIBERTY BELL 7": "SUBORBITAL",
    "FRIENDSHIP 7": "3",
    "AURORA 7": "3",
    "SIGMA 7": "6",
    "FAITH 7": "22",
    "GEMINI 3": "3",
    "GEMINI 4": "66",
    "GEMINI 5": "120",
    "GEMINI 7": "206",
    "GEMINI 6": "16",
    "GEMINI 8": "6",
    "GEMINI 9A": "47",
    "GEMINI 10": "43",
    "GEMINI 11": "44",
    "GEMINI 12": "59",
}

# Apogee in statute miles (Gemini 10/11: the Agena-boosted peak).
MERCURY_GEMINI_APOGEE = {
    "FREEDOM 7": "116 MI",
    "LIBERTY BELL 7": "118 MI",
    "FRIENDSHIP 7": "154 MI",
    "AURORA 7": "161 MI",
    "SIGMA 7": "177 MI",
    "FAITH 7": "166 MI",
    "GEMINI 3": "140 MI",
    "GEMINI 4": "180 MI",
    "GEMINI 5": "205 MI",
    "GEMINI 7": "189 MI",
    "GEMINI 6": "170 MI",
    "GEMINI 8": "168 MI",
    "GEMINI 9A": "170 MI",
    "GEMINI 10": "475 MI",
    "GEMINI 11": "854 MI",
    "GEMINI 12": "180 MI",
}

# Shuttle orbit count and apogee (statute miles), from each mission's
# Wikipedia infobox, cross-checked with spacefacts.de where missing.
# STS-51-L never reached orbit and has no entry.
SHUTTLE_ORBITS = {
    "STS-1": "36",
    "STS-2": "37",
    "STS-3": "130",
    "STS-4": "113",
    "STS-5": "81",
    "STS-6": "81",
    "STS-7": "97",
    "STS-8": "98",
    "STS-9": "167",
    "STS-41-B": "128",
    "STS-41-C": "108",
    "STS-41-D": "97",
    "STS-41-G": "133",
    "STS-51-A": "127",
    "STS-51-C": "49",
    "STS-51-D": "110",
    "STS-51-B": "111",
    "STS-51-G": "112",
    "STS-51-F": "127",
    "STS-51-I": "112",
    "STS-51-J": "64",
    "STS-61-A": "112",
    "STS-61-B": "109",
    "STS-61-C": "98",
    "STS-26": "64",
    "STS-27": "68",
    "STS-29": "80",
    "STS-30": "65",
    "STS-28": "81",
    "STS-34": "79",
    "STS-33": "79",
    "STS-32": "172",
    "STS-36": "72",
    "STS-31": "80",
    "STS-41": "66",
    "STS-38": "79",
    "STS-35": "144",
    "STS-37": "93",
    "STS-39": "134",
    "STS-40": "146",
    "STS-43": "142",
    "STS-48": "81",
    "STS-44": "110",
    "STS-42": "129",
    "STS-45": "143",
    "STS-49": "141",
    "STS-50": "221",
    "STS-46": "127",
    "STS-47": "126",
    "STS-52": "159",
    "STS-53": "116",
    "STS-54": "96",
    "STS-56": "148",
    "STS-55": "160",
    "STS-57": "155",
    "STS-51": "157",
    "STS-58": "225",
    "STS-61": "163",
    "STS-60": "130",
    "STS-62": "224",
    "STS-59": "183",
    "STS-65": "235",
    "STS-64": "176",
    "STS-68": "182",
    "STS-66": "174",
    "STS-63": "129",
    "STS-67": "262",
    "STS-71": "153",
    "STS-70": "143",
    "STS-69": "171",
    "STS-73": "255",
    "STS-74": "128",
    "STS-72": "142",
    "STS-75": "252",
    "STS-76": "145",
    "STS-77": "161",
    "STS-78": "271",
    "STS-79": "160",
    "STS-80": "279",
    "STS-81": "160",
    "STS-82": "149",
    "STS-83": "63",
    "STS-84": "144",
    "STS-94": "251",
    "STS-85": "185",
    "STS-86": "170",
    "STS-87": "252",
    "STS-89": "139",
    "STS-90": "256",
    "STS-91": "155",
    "STS-95": "134",
    "STS-88": "186",
    "STS-96": "154",
    "STS-93": "80",
    "STS-103": "119",
    "STS-99": "181",
    "STS-101": "155",
    "STS-106": "185",
    "STS-92": "202",
    "STS-97": "171",
    "STS-98": "203",
    "STS-102": "202",
    "STS-100": "186",
    "STS-104": "200",
    "STS-105": "186",
    "STS-108": "186",
    "STS-109": "165",
    "STS-110": "171",
    "STS-111": "217",
    "STS-112": "170",
    "STS-113": "215",
    "STS-107": "255",
    "STS-114": "219",
    "STS-121": "202",
    "STS-115": "188",
    "STS-116": "203",
    "STS-117": "219",
    "STS-118": "201",
    "STS-120": "238",
    "STS-122": "202",
    "STS-123": "250",
    "STS-124": "217",
    "STS-126": "251",
    "STS-119": "202",
    "STS-125": "197",
    "STS-127": "248",
    "STS-128": "219",
    "STS-129": "171",
    "STS-130": "217",
    "STS-131": "238",
    "STS-132": "186",
    "STS-133": "202",
    "STS-134": "249",
    "STS-135": "200",
}

SHUTTLE_APOGEE = {
    "STS-1": "170 MI",
    "STS-2": "144 MI",
    "STS-3": "155 MI",
    "STS-4": "188 MI",
    "STS-5": "197 MI",
    "STS-6": "183 MI",
    "STS-7": "191 MI",
    "STS-8": "221 MI",
    "STS-9": "157 MI",
    "STS-41-B": "197 MI",
    "STS-41-C": "266 MI",
    "STS-41-D": "220 MI",
    "STS-41-G": "243 MI",
    "STS-51-A": "220 MI",
    "STS-51-C": "212 MI",
    "STS-51-D": "281 MI",
    "STS-51-B": "219 MI",
    "STS-51-G": "223 MI",
    "STS-51-F": "200 MI",
    "STS-51-I": "289 MI",
    "STS-51-J": "301 MI",
    "STS-61-A": "206 MI",
    "STS-61-B": "230 MI",
    "STS-61-C": "210 MI",
    "STS-26": "190 MI",
    "STS-27": "278 MI",
    "STS-29": "191 MI",
    "STS-30": "227 MI",
    "STS-28": "190 MI",
    "STS-34": "191 MI",
    "STS-33": "322 MI",
    "STS-32": "224 MI",
    "STS-36": "127 MI",
    "STS-31": "382 MI",
    "STS-41": "191 MI",
    "STS-38": "167 MI",
    "STS-35": "225 MI",
    "STS-37": "287 MI",
    "STS-39": "163 MI",
    "STS-40": "184 MI",
    "STS-43": "190 MI",
    "STS-48": "360 MI",
    "STS-44": "231 MI",
    "STS-42": "191 MI",
    "STS-45": "183 MI",
    "STS-49": "212 MI",
    "STS-50": "192 MI",
    "STS-46": "272 MI",
    "STS-47": "190 MI",
    "STS-52": "188 MI",
    "STS-53": "234 MI",
    "STS-54": "192 MI",
    "STS-56": "186 MI",
    "STS-55": "194 MI",
    "STS-57": "293 MI",
    "STS-51": "191 MI",
    "STS-58": "183 MI",
    "STS-61": "358 MI",
    "STS-60": "218 MI",
    "STS-62": "192 MI",
    "STS-59": "127 MI",
    "STS-65": "189 MI",
    "STS-64": "167 MI",
    "STS-68": "139 MI",
    "STS-66": "190 MI",
    "STS-63": "213 MI",
    "STS-67": "190 MI",
    "STS-71": "213 MI",
    "STS-70": "160 MI",
    "STS-69": "199 MI",
    "STS-73": "150 MI",
    "STS-74": "246 MI",
    "STS-72": "290 MI",
    "STS-75": "200 MI",
    "STS-76": "255 MI",
    "STS-77": "178 MI",
    "STS-78": "162 MI",
    "STS-79": "240 MI",
    "STS-80": "233 MI",
    "STS-81": "244 MI",
    "STS-82": "357 MI",
    "STS-83": "188 MI",
    "STS-84": "244 MI",
    "STS-94": "190 MI",
    "STS-85": "162 MI",
    "STS-86": "237 MI",
    "STS-87": "173 MI",
    "STS-89": "237 MI",
    "STS-90": "170 MI",
    "STS-91": "232 MI",
    "STS-95": "349 MI",
    "STS-88": "249 MI",
    "STS-96": "210 MI",
    "STS-93": "170 MI",
    "STS-103": "378 MI",
    "STS-99": "150 MI",
    "STS-101": "206 MI",
    "STS-106": "240 MI",
    "STS-92": "245 MI",
    "STS-97": "227 MI",
    "STS-98": "235 MI",
    "STS-102": "237 MI",
    "STS-100": "233 MI",
    "STS-104": "240 MI",
    "STS-105": "250 MI",
    "STS-108": "234 MI",
    "STS-109": "359 MI",
    "STS-110": "140 MI",
    "STS-111": "240 MI",
    "STS-112": "252 MI",
    "STS-113": "247 MI",
    "STS-107": "177 MI",
    "STS-114": "221 MI",
    "STS-121": "220 MI",
    "STS-115": "141 MI",
    "STS-116": "222 MI",
    "STS-117": "220 MI",
    "STS-118": "140 MI",
    "STS-120": "214 MI",
    "STS-122": "211 MI",
    "STS-123": "215 MI",
    "STS-124": "204 MI",
    "STS-126": "219 MI",
    "STS-119": "250 MI",
    "STS-125": "359 MI",
    "STS-127": "218 MI",
    "STS-128": "164 MI",
    "STS-129": "221 MI",
    "STS-130": "221 MI",
    "STS-131": "215 MI",
    "STS-132": "223 MI",
    "STS-133": "144 MI",
    "STS-134": "213 MI",
    "STS-135": "239 MI",
}

# (label, value, label, value) for page 7: orbit count and apogee (Apollo 8:
# lunar orbits and apolune), statute miles.
MODULELESS_ORBIT_PAIR = {
    "APOLLO 7": ("ORBITS", "163", "APOGEE", "187 MI"),
    "APOLLO 8": ("MOON ORBITS", "10", "APOLUNE", "70 MI"),
    "SKYLAB 2": ("ORBITS", "404", "APOGEE", "272 MI"),
    "SKYLAB 3": ("ORBITS", "858", "APOGEE", "274 MI"),
    "SKYLAB 4": ("ORBITS", "1214", "APOGEE", "272 MI"),
    "APOLLO-SOYUZ": ("ORBITS", "148", "APOGEE", "144 MI"),
    # Artemis II didn't orbit the Moon: max distance from Earth and closest
    # approach to the Moon instead.
    "ARTEMIS II": ("MAX DIST", "253K MI", "MOON ALT", "4067 MI"),
    "INSPIRATION4": ("ORBITS", "46", "APOGEE", "363 MI"),
    "POLARIS DAWN": ("ORBITS", "75", "APOGEE", "870 MI"),
}

# Orbit count shown alone on page 8 (Apollo/Skylab/ASTP fallback).
ORBIT_FACT = {
    # Lunar missions show lunar orbits, not Earth parking orbits.
    "APOLLO 7": ("ORBITS", "163"),
    "APOLLO 8": ("LUNAR ORBITS", "10"),
    "APOLLO 9": ("ORBITS", "151"),
    "APOLLO 10": ("LUNAR ORBITS", "31"),
    "APOLLO 11": ("LUNAR ORBITS", "30"),
    "APOLLO 12": ("LUNAR ORBITS", "45"),
    # Apollo 13: its record distance from Earth.
    "APOLLO 13": ("APOGEE", "248,655 MI"),
    "APOLLO 14": ("LUNAR ORBITS", "34"),
    "APOLLO 15": ("LUNAR ORBITS", "74"),
    "APOLLO 16": ("LUNAR ORBITS", "64"),
    "APOLLO 17": ("LUNAR ORBITS", "75"),
    "SKYLAB 2": ("ORBITS", "404"),
    "SKYLAB 3": ("ORBITS", "858"),
    "SKYLAB 4": ("ORBITS", "1214"),
    "APOLLO-SOYUZ": ("ORBITS", "148"),
}

# A short, sourced first, record or last per mission. Must fit 124px in 4x5.
NOTABLE_FIRST = {
    "FREEDOM 7": "FIRST AMERICAN IN SPACE",
    # First Mercury capsule with the large centerline window.
    "LIBERTY BELL 7": "FIRST MERCURY WINDOW",
    "FRIENDSHIP 7": "FIRST AMERICAN IN ORBIT",
    # Carpenter's dyed-liquid fluid-physics experiment.
    "AURORA 7": "FIRST MICROGRAVITY TEST",
    # Splashed down within 0.5 mi of USS Kearsarge.
    "SIGMA 7": "LANDED 0.5 MI FROM SHIP",
    "FAITH 7": "FIRST US TV FROM SPACE",
    "GEMINI 3": "FIRST ORBITAL MANEUVER",
    "GEMINI 4": "FIRST US SPACEWALK",
    "GEMINI 5": "8-DAY DURATION RECORD",
    "GEMINI 6": "FIRST SPACE RENDEZVOUS",
    "GEMINI 7": "14-DAY DURATION RECORD",
    "GEMINI 8": "FIRST SPACE DOCKING",
    # Three rendezvous profiles with the ATDA, incl. rendezvous from above.
    "GEMINI 9A": "3 RENDEZVOUS TECHNIQUES",
    "GEMINI 10": "FIRST DOUBLE RENDEZVOUS",
    "GEMINI 11": "SET APOGEE RECORD",
    "GEMINI 12": "LAST GEMINI MISSION",
    "APOLLO 7": "FIRST APOLLO SPACEFLIGHT",
    "APOLLO 8": "FIRST CREWED LUNAR ORBIT",
    "APOLLO 9": "FIRST CREWED LM FLIGHT",
    "APOLLO 10": "SET HUMAN SPEED RECORD",
    "APOLLO 11": "FIRST MOON LANDING",
    "APOLLO 12": "FIRST PRECISION LANDING",
    "APOLLO 13": "FIRST LM LIFEBOAT USE",
    "APOLLO 14": "FIRST GOLF ON THE MOON",
    "APOLLO 15": "FIRST LUNAR ROVER USE",
    # "Big Muley", 26 lb (11.7 kg).
    "APOLLO 16": "LARGEST MOON ROCK RETURNED",
    "APOLLO 17": "LAST APOLLO MOON LANDING",
    "SKYLAB 2": "FIRST US SPACE STATION",
    # NASA: more than 150% of planned science data returned.
    "SKYLAB 3": "150% OF SCIENCE GOALS",
    "SKYLAB 4": "SET US DURATION RECORD",
    "APOLLO-SOYUZ": "FIRST US-SOVIET DOCKING",
    # First new crewed spacecraft to fly its first flight with a crew.
    "STS-1": "FIRST CREWED MAIDEN FLIGHT",
    # First spacecraft to fly to orbit twice.
    "STS-2": "FIRST REUSED SPACECRAFT",
    # Landed on the gypsum surface at White Sands after Edwards flooded.
    "STS-3": "ONLY WHITE SANDS LANDING",
    # Last Orbital Flight Test mission.
    "STS-4": "LAST SHUTTLE TEST FLIGHT",
    # Shuttle entries sourced from each mission's Wikipedia article.
    "STS-5": "FIRST COMSATS DEPLOYED",
    "STS-6": "FIRST SHUTTLE SPACEWALK",
    "STS-7": "FIRST US WOMAN IN SPACE",
    "STS-8": "FIRST BLACK ASTRONAUT",
    "STS-9": "FIRST ESA ASTRONAUT",
    "STS-41-B": "FIRST UNTETHERED EVA",
    "STS-41-C": "FIRST SATELLITE REPAIR",
    "STS-41-D": "FIRST FLIGHT OF DISCOVERY",
    "STS-41-G": "FIRST US WOMAN SPACEWALK",
    "STS-51-A": "FIRST SATELLITE RETRIEVAL",
    "STS-51-C": "100TH HUMAN SPACEFLIGHT",
    "STS-51-D": "FIRST SENATOR IN SPACE",
    "STS-51-B": "OLDEST CREW AGE RECORD",
    "STS-51-G": "FIRST ARAB IN SPACE",
    "STS-51-F": "FIRST FOSSILS IN SPACE",
    "STS-51-I": "SYNCOM SATELLITE RESCUE",
    "STS-51-J": "FLEW 3 DIFFERENT ORBITERS",
    "STS-61-A": "LARGEST SHUTTLE CREW EVER",
    "STS-61-B": "FIRST MEXICAN ASTRONAUT",
    "STS-61-C": "FIRST COSTA RICAN IN SPACE",
    "STS-26": "RETURN TO FLIGHT MISSION",
    "STS-27": "SECOND DOD SHUTTLE FLIGHT",
    "STS-29": "COMPLETED TDRS NETWORK",
    "STS-30": "DEPLOYED MAGELLAN PROBE",
    "STS-28": "SKULL RADIATION STUDY",
    "STS-34": "DEPLOYED GALILEO PROBE",
    "STS-33": "FIRST NIGHT LAUNCH IN '89",
    "STS-32": "RESCUED LDEF FROM DECAY",
    "STS-36": "HIGHEST ORBIT INCLINATION",
    "STS-31": "DEPLOYED HUBBLE TELESCOPE",
    "STS-41": "DEPLOYED ULYSSES SUN PROBE",
    "STS-38": "1ST ATLANTIS KSC LANDING",
    "STS-35": "CARRIED ASTRO OBSERVATORY",
    "STS-37": "EVA FREED STUCK ANTENNA",
    "STS-39": "FIRST OPEN DOD MISSION",
    "STS-40": "FIRST 3-WOMAN CREW",
    "STS-43": "FIRST EMAIL FROM SPACE",
    "STS-48": "DEPLOYED UARS SATELLITE",
    "STS-44": "LAST DRY LAKEBED LANDING",
    "STS-42": "FIRST CANADIAN WOMAN",
    "STS-45": "FIRST BELGIAN IN SPACE",
    "STS-49": "ONLY 3-PERSON EVA EVER",
    "STS-50": "NEW SHUTTLE DURATION MARK",
    "STS-46": "FIRST TETHERED SATELLITE",
    "STS-47": "1ST BLACK WOMAN IN SPACE",
    "STS-52": "CARRIED RODDENBERRY ASHES",
    "STS-53": "LAST MAJOR DOD PAYLOAD",
    "STS-54": "PRACTICED ISS EVA SKILLS",
    "STS-56": "FIRST HAM CONTACT WITH MIR",
    "STS-55": "1ST IV INJECTION IN SPACE",
    "STS-57": "RETRIEVED EURECA",
    "STS-51": "FIRST NIGHT LANDING AT KSC",
    "STS-58": "FIRST PILOT SIM USE",
    "STS-61": "FIRST HUBBLE REPAIR",
    "STS-60": "FIRST RUSSIAN ON SHUTTLE",
    "STS-62": "LOWEST ORBIT TO DATE",
    "STS-59": "FIRST SPACE RADAR LAB",
    "STS-65": "FIRST JAPANESE WOMAN",
    "STS-64": "LAST UNTETHERED EVA",
    "STS-68": "5TH AND FINAL RSLS ABORT",
    "STS-66": "LAST SOLO ATLANTIS FLIGHT",
    "STS-63": "FIRST FEMALE SHUTTLE PILOT",
    "STS-67": "LONGEST ENDEAVOUR FLIGHT",
    "STS-71": "FIRST SHUTTLE-MIR DOCKING",
    "STS-70": "DELAYED BY WOODPECKERS",
    "STS-69": "FIRST EUV MONITOR FLIGHT",
    "STS-73": "FIRST PITCH FROM ORBIT",
    "STS-74": "ADDED MIR DOCKING PORT",
    "STS-72": "FIRST GO GAME IN SPACE",
    "STS-75": "DEPLOYED 12-MILE TETHER",
    "STS-76": "FIRST US SPACEWALK AT MIR",
    "STS-77": "FIRST INFLATABLE ANTENNA",
    "STS-78": "FIRST SLEEP STUDY IN SPACE",
    "STS-79": "FIRST US CREW SWAP AT MIR",
    "STS-80": "LONGEST SHUTTLE MISSION",
    "STS-81": "FIRST SEED-TO-SEED CROP",
    "STS-82": "2ND HUBBLE SERVICE MISSION",
    "STS-83": "UNPRECEDENTED REFLIGHT",
    "STS-84": "FLEW BOTH SHUTTLE & SOYUZ",
    "STS-94": "SAME CREW REFLEW STS-83",
    "STS-85": "FIRST JAPAN ROBOT ARM TEST",
    "STS-86": "FIRST US-RUSSIA EVA",
    "STS-87": "FIRST EVA FROM COLUMBIA",
    "STS-89": "DINOSAUR SKULL FLEW TO MIR",
    "STS-90": "LAST SPACELAB MISSION EVER",
    "STS-91": "LAST SHUTTLE-MIR DOCKING",
    "STS-95": "OLDEST PERSON TO ORBIT",
    "STS-88": "FIRST ISS ASSEMBLY FLIGHT",
    "STS-96": "FIRST SHUTTLE-ISS DOCKING",
    "STS-93": "FIRST FEMALE SHUTTLE CMDR",
    "STS-103": "DISCOVERY LAST SOLO FLIGHT",
    "STS-99": "MOST DETAILED EARTH MAP",
    "STS-101": "FIRST GLASS COCKPIT FLIGHT",
    "STS-106": "FIRST HAM RADIO IN SPACE",
    "STS-92": "100TH SHUTTLE MISSION",
    "STS-97": "DELIVERED ISS SOLAR ARRAYS",
    "STS-98": "DELIVERED DESTINY ISS LAB",
    "STS-102": "FIRST ISS CREW ROTATION",
    "STS-100": "FIRST CANADIAN SPACEWALK",
    "STS-104": "DELIVERED QUEST AIRLOCK",
    "STS-105": "ONLY EARLY-WINDOW LAUNCH",
    "STS-108": "FIRST SHUTTLE AFTER 9/11",
    "STS-109": "INSTALLED HUBBLE ACS",
    "STS-110": "FIRST 7-TIME ASTRONAUT",
    "STS-111": "INSTALLED CANADARM2 BASE",
    "STS-112": "FIRST EXTERNAL TANK CAMERA",
    "STS-113": "NATIVE AMERICAN ASTRONAUT",
    # Ilan Ramon, first Israeli astronaut.
    "STS-107": "FIRST ISRAELI ASTRONAUT",
    # Return to flight after Columbia (STS-26 was after Challenger).
    "STS-114": "COLUMBIA RETURN TO FLIGHT",
    "STS-121": "ONLY JULY 4TH LAUNCH",
    "STS-115": "DELIVERED P3/P4 TRUSS",
    "STS-116": "SWEDEN'S FIRST ASTRONAUT",
    "STS-117": "HEAVIEST SHUTTLE PAYLOAD",
    "STS-118": "FIRST TEACHER IN SPACE",
    "STS-120": "DELIVERED HARMONY MODULE",
    "STS-122": "DELIVERED COLUMBUS MODULE",
    "STS-123": "DELIVERED DEXTRE ROBOT",
    "STS-124": "DELIVERED KIBO LAB MODULE",
    "STS-126": "FEMALE LEAD SPACEWALKER",
    "STS-119": "COMPLETED ISS SOLAR ARRAYS",
    "STS-125": "FINAL HUBBLE SERVICING",
    "STS-127": "13 IN SPACE AT ONCE RECORD",
    "STS-128": "HEAVIEST OBJECT MOVED EVA",
    "STS-129": "LAST SHUTTLE CREW ROTATION",
    "STS-130": "DELIVERED ISS CUPOLA",
    "STS-131": "4 WOMEN IN SPACE AT ONCE",
    "STS-132": "DELIVERED RASSVET MODULE",
    "STS-133": "DISCOVERY'S FINAL FLIGHT",
    "STS-134": "ENDEAVOUR'S FINAL FLIGHT",
    "STS-135": "FINAL SHUTTLE MISSION EVER",
    # ~252,756 mi, beating Apollo 13's 248,655 mi.
    "ARTEMIS II": "FARTHEST HUMANS FROM EARTH",
    "SOYUZ TM-21": "FIRST AMERICAN ON SOYUZ",
    # ISS-era Soyuz entries: firsts and records from NASA and Wikipedia.
    # Duration records appear on launch-only flights (see NOTABLE_LAUNCH_ONLY).
    "SOYUZ TM-31": "FIRST ISS EXPEDITION CREW",
    "SOYUZ TMA-11": "FIRST WOMAN ISS COMMANDER",
    "SOYUZ TMA-16M": "FIRST 1-YEAR ISS MISSION",
    "SOYUZ MS-18": "US RECORD: 355 DAYS",
    "SOYUZ MS-22": "US RECORD: 371 DAYS",
    "SOYUZ TMA-8": "FIRST BRAZILIAN IN SPACE",
    "SOYUZ TMA-17": "FIRST LIVE TWEET IN SPACE",
    "SOYUZ TMA-05M": "FIRST TRIATHLON IN SPACE",
    "SOYUZ TMA-07M": "FIRST CANADIAN ISS CDR",
    "SOYUZ TMA-08M": "FIRST 6-HOUR TRIP TO ISS",
    "SOYUZ TMA-11M": "FIRST TORCH IN OPEN SPACE",
    "SOYUZ TMA-14M": "FIRST RUSSIAN WOMAN ON ISS",
    "SOYUZ TMA-15M": "FIRST WOMAN FROM ITALY",
    "SOYUZ TMA-19M": "FIRST UK ESA ASTRONAUT",
    "SOYUZ TMA-20M": "US CAREER RECORD: 534 DAYS",
    "SOYUZ MS-01": "FIRST SPACE DNA SEQUENCING",
    "SOYUZ MS-03": "US CAREER RECORD: 665 DAYS",
    "SOYUZ MS-09": "FIRST GERMAN ISS COMMANDER",
    "SOYUZ MS-13": "FIRST ITALIAN ISS CDR",
    "SOYUZ MS-15": "FIRST UAE ASTRONAUT",
    "SOYUZ MS-17": "FIRST 3-HOUR TRIP TO ISS",
    # Commercial Crew and private flights.
    "SPACEX DEMO-2": "FIRST COMMERCIAL CREW",
    "SPACEX CREW-1": "FIRST OPERATIONAL MISSION",
    "SPACEX CREW-2": "FIRST REUSED CREW DRAGON",
    "SPACEX CREW-3": "FIRST ROOKIE CDR SINCE '73",
    "SPACEX CREW-5": "FIRST COSMONAUT ON DRAGON",
    "SPACEX CREW-9": "LAUNCHED 2 SEATS EMPTY",
    "SPACEX CREW-11": "EARLY RETURN: MEDICAL",
    "STARLINER CFT": "FIRST CREWED STARLINER",
    "SOYUZ TMA-1": "FIRST SOYUZ TMA FLIGHT",
    "SOYUZ TMA-18M": "1-YEAR ISS MISSION ENDS",
    "SOYUZ MS-19": "US RECORD: 355 DAYS",
    "SOYUZ MS-23": "US RECORD: 371 DAYS",
    "SOYUZ MS-10": "FIRST ABORT SINCE 1983",

    # More Soyuz/Commercial entries, sourced from spacefacts.de, NASA/ESA
    # history pages and mission articles.
    "SOYUZ TMA-2": "FIRST WEDDING IN SPACE",
    "SOYUZ TMA-3": "FIRST BRITISH-BORN ISS CDR",
    "SOYUZ TMA-4": "FIRST US EVA IN ORLAN SUIT",
    "SOYUZ TMA-5": "FIRST VOTE CAST FROM SPACE",
    "SOYUZ TMA-6": "RECORD: MOST TIME IN SPACE",
    "SOYUZ TMA-7": "DEPLOYED FIRST SUITSAT",
    "SOYUZ TMA-9": "US RECORD: 215 DAYS",
    "SOYUZ TMA-13": "US RECORD: CAREER TIME",
    "SOYUZ TMA-14": "FIRST 6-PERSON ISS CREW",
    "SOYUZ TMA-16": "FIRST TRIPLE SOYUZ DOCKING",
    "SOYUZ TMA-19": "100TH ISS MISSION EVER",
    "SOYUZ TMA-01M": "FIRST SOYUZ TMA-M FLIGHT",
    "SOYUZ TMA-20": "FIRST SHUTTLE-DOCK PHOTO",
    "SOYUZ TMA-21": "FIRST SOYUZ EVER NAMED",
    "SOYUZ TMA-02M": "HOSTED FINAL SHUTTLE VISIT",
    "SOYUZ TMA-22": "FIRST POST-SHUTTLE CREW",
    "SOYUZ TMA-03M": "INVENTED ZERO-G COFFEE CUP",
    "SOYUZ TMA-06M": "1ST FROM SITE 31 SINCE '84",
    "SOYUZ TMA-09M": "FIRST TO QUILT IN SPACE",
    "SOYUZ TMA-10M": "OLYMPIC TORCH'S FIRST EVA",
    "SOYUZ TMA-17M": "ATE FIRST SPACE-GROWN CROP",
    "SOYUZ MS-04": "SMALLEST CREW SINCE TMA-2",
    "SOYUZ MS-08": "TIED US EVA RECORD: 10",
    "SOYUZ MS-11": "1ST FLIGHT AFTER MS-10",
    "SOYUZ MS-12": "REFLEW AFTER MS-10 ABORT",
    "SOYUZ MS-16": "FIRST CREWED SOYUZ-2.1A",
    "SOYUZ MS-24": "SET ALL-TIME SPACE RECORD",
    "SOYUZ MS-25": "FIRST 2 WOMEN ON ONE SOYUZ",
    "SOYUZ MS-27": "1ST KOREAN-AMERICAN",
    "SOYUZ MS-29": "1ST SPACEX FLIGHT SURGEON",
    "SPACEX CREW-4": "FIRST BLACK WOMAN ISS CREW",
    "SPACEX CREW-6": "FIRST ARAB SPACEWALK",
    "SPACEX CREW-7": "1ST EUROPEAN DRAGON PILOT",
    "SPACEX CREW-8": "LONGEST DRAGON FLIGHT YET",
    "SPACEX CREW-10": "FREED STARLINER CREW",
    "SPACEX CREW-12": "1ST FRENCH WOMAN SPACEWALK",

    # No "first" for these: a notable event or the astronaut's flight number.
    "SOYUZ TMA-18": "3-EVA AMMONIA PUMP REPAIR",
    "SOYUZ TMA-04M": "ABOARD FOR 1ST DRAGON DOCK",
    "SOYUZ MS-06": "CREW: 2 NASA, 1 ROSCOSMOS",
    "SOYUZ MS-26": "LANDED ON PETTIT'S 70TH",
    "SOYUZ MS-28": "LAUNCHED THANKSGIVING DAY",
    "SOYUZ TMA-12M": "SWANSON'S 3RD FLIGHT",
    "SOYUZ TMA-13M": "WISEMAN'S 1ST FLIGHT",
    "SOYUZ MS-02": "KIMBROUGH'S 2ND FLIGHT",
    "SOYUZ MS-05": "BRESNIK'S 2ND FLIGHT",
    "SOYUZ MS-07": "TINGLE'S 1ST FLIGHT",
    "INSPIRATION4": "FIRST ALL-CIVILIAN CREW",
    "AXIOM-1": "FIRST ALL-PRIVATE ISS CREW",
    "AXIOM-2": "FIRST SAUDI WOMAN IN SPACE",
    "AXIOM-3": "FIRST TURKISH ASTRONAUT",
    "POLARIS DAWN": "FIRST PRIVATE SPACEWALK",
    "AXIOM-4": "FIRST INDIAN ON THE ISS",
}

# Facts about the ride up: shown on the LAUNCH card only.
NOTABLE_LAUNCH_ONLY = ["SOYUZ TMA-8", "SOYUZ TMA-08M", "SOYUZ MS-15", "SOYUZ MS-17"]

# Optional second page-8 fact, stacked under NOTABLE_FIRST.
NOTABLE_FIRST_2 = {
    "GEMINI 3": "FIRST CONTRABAND FOOD",
    # Sally Ride and Kathryn Sullivan, October 1984.
    "STS-41-G": "FIRST 2-WOMAN CREW",
    "POLARIS DAWN": "HIGHEST ORBIT SINCE APOLLO",
}

# Second fact for small-crew (4-6) Shuttle missions: orbits/apogee move to
# page 6, NOTABLE_FIRST to page 7, and this shows on page 8. Always a
# different fact from NOTABLE_FIRST.
NOTABLE_SECOND = {
    "STS-5": "FIRST 4-PERSON CREW",
    "STS-6": "DEPLOYED FIRST TDRS SAT",
    "STS-7": "FIRST 5-PERSON CREW",
    "STS-8": "FIRST SHUTTLE NIGHT LAUNCH",
    "STS-9": "FIRST SPACELAB MISSION",
    "STS-41-B": "FIRST LANDING AT KSC",
    "STS-41-C": "DEPLOYED LDEF SATELLITE",
    "STS-41-D": "DEPLOYED 3 SATELLITES",
    "STS-51-A": "FIRST DUAL RETRIEVAL",
    "STS-51-C": "FIRST DOD-ONLY MISSION",
    "STS-51-I": "DEPLOYED AUSSAT-1",
    "STS-51-J": "FIRST FLIGHT OF ATLANTIS",
    "STS-26": "DEPLOYED TDRS-3 SATELLITE",
    "STS-27": "SURVIVED WORST TILE DAMAGE",
    "STS-29": "FILMED EARTH IN IMAX",
    "STS-30": "FIXED COMPUTER IN ORBIT",
    "STS-28": "COLUMBIA GROUNDED 3 YEARS",
    "STS-34": "6-YEAR TRIP TO JUPITER",
    "STS-33": "THANKSGIVING IN SPACE",
    "STS-32": "LONGEST MISSION TO DATE",
    "STS-36": "DELAYED BY CREW ILLNESS",
    "STS-31": "HIGHEST ORBIT TO DATE",
    "STS-41": "FASTEST PAYLOAD EVER",
    "STS-38": "7TH DEDICATED DOD MISSION",
    "STS-37": "DEPLOYED GAMMA RAY LAB",
    "STS-43": "DEPLOYED TDRS-5 SATELLITE",
    "STS-48": "SET ALTITUDE RECORD",
    "STS-44": "DEPLOYED DSP SATELLITE",
    "STS-52": "DEPLOYED LAGEOS-2",
    "STS-53": "DISCOVERY'S 15TH FLIGHT",
    "STS-54": "DEPLOYED TDRS SATELLITE",
    "STS-56": "FIRST HISPANIC WOMAN",
    "STS-57": "SPACEWALK TESTED ISS TOOLS",
    "STS-51": "FIRST SHUTTLE GPS RECEIVER",
    "STS-60": "100TH GET AWAY SPECIAL",
    "STS-62": "FLEW USMP-2 EXPERIMENTS",
    "STS-59": "RADAR-MAPPED 12% OF EARTH",
    "STS-64": "FIRST SPACEBORNE LIDAR",
    "STS-68": "3D RADAR MAPPED EARTH",
    "STS-66": "ATLAS-3 OZONE RESEARCH",
    "STS-63": "CLOSED TO 37 FT FROM MIR",
    "STS-70": "FASTEST TURNAROUND EVER",
    "STS-69": "NASA'S 100TH CREWED FLIGHT",
    "STS-74": "FIRST CANADIAN ABOARD MIR",
    "STS-72": "RETRIEVED SPACE FLYER UNIT",
    # Small roster on both launch and landing day.
    "STS-76": "DELIVERED LUCID TO MIR",
    "STS-77": "4 RENDEZVOUS IN ONE FLIGHT",
    "STS-79": "SET US DURATION RECORD",
    "STS-80": "DEPLOYED ORFEUS-SPAS II",
    "STS-81": "5TH SHUTTLE-MIR DOCKING",
    "STS-85": "DEPLOYED CRISTA-SPAS II",
    "STS-87": "FIRST INDIAN-BORN WOMAN",
    # Shows on the launch day only (7-person landing roster).
    "STS-91": "FIRST FLIGHT OF AMS-01",
    "STS-88": "DELIVERED UNITY NODE",
    "STS-93": "DEPLOYED CHANDRA X-RAY OBS",
    "STS-99": "DEPLOYED 200-FT RADAR MAST",
    "STS-97": "FIRST VISIT TO CREWED ISS",
    "STS-98": "100TH US SPACEWALK EVER",
    "STS-104": "FIRST EVA VIA QUEST",
    "STS-112": "DELIVERED S1 TRUSS SEGMENT",
    # Shows on the landing day only (7-person launch roster).
    "STS-121": "ISS BACK TO 3-PERSON CREW",
    "STS-115": "RESUMED ISS TRUSS ASSEMBLY",
    # Shows on the launch day only (7-person landing roster).
    "STS-129": "DELIVERED ISS SPARE PARTS",
    "STS-130": "DELIVERED TRANQUILITY",
    "STS-132": "ONLY RUSSIAN MODULE FLOWN",
    "STS-133": "DELIVERED ROBONAUT 2",
    "STS-134": "DELIVERED AMS-02 DETECTOR",
    "STS-135": "SMALLEST CREW SINCE STS-6",
}

# Memorial quotes on the trailing pages, keyed by page (6/7/8): Grissom
# (Apollo 1), Reagan (Challenger), O'Keefe (Columbia). Each page must wrap
# to at most 5 lines of 4x5 at 124px.
MEMORIAL_QUOTE = {
    "APOLLO 1": {
        6: "IF WE DIE, WE WANT PEOPLE TO ACCEPT IT.",
        7: "WE'RE IN A RISKY BUSINESS, AND WE HOPE THAT IF ANYTHING HAPPENS TO US, IT WILL NOT DELAY THE PROGRAM.",
        8: "THE CONQUEST OF SPACE IS WORTH THE RISK OF LIFE. - GUS GRISSOM",
    },
    "STS-51-L": {
        7: "WE WILL NEVER FORGET THEM, NOR THE LAST TIME WE SAW THEM, THIS MORNING, AS THEY PREPARED FOR THEIR JOURNEY AND WAVED GOODBYE",
        8: "AND 'SLIPPED THE SURLY BONDS OF EARTH' TO 'TOUCH THE FACE OF GOD.' - RONALD REAGAN",
    },
    "STS-107": {
        7: "THEY DEDICATED THEIR LIVES TO PUSHING SCIENTIFIC CHALLENGES FOR ALL OF US ON EARTH. THEY DID IT WITH A HAPPY HEART, WILLINGLY,",
        8: "WITH GREAT ENTHUSIASM. THE LOSS OF THIS VALIANT CREW IS SOMETHING WE WILL NEVER BE ABLE TO GET OVER. - SEAN O'KEEFE",
    },
}


# Quote page, on the patch background when the mission has one.
def draw_quote_page(c, name, text):
    if not draw_patch_background(c, name):
        c.fill("#000000")
    draw_wrapped_fit_outlined(c, text, L, 1, CW, "white", 31)


def crew(c, ctx):
    if draw_moon_page(c, ctx, 4):
        return
    # Page 4. Empty day: countback to the last event. Apollo/Skylab/ASTP: all
    # 3 crew on one page. Shuttle and Artemis: draw_shuttle_crew_page.
    event = current_flight_event(ctx)
    if event == None:
        mission, kind, n = nearest_event(ctx, False)
        name = mission[0]
        draw_patch_background(c, name)
        verb = {"LAUNCH": "LAUNCH", "LAND": "LANDING", "MOONLAND": "MOON LANDING"}[kind]
        mission_line = display_name(name).upper() + " " + verb
        days_line = str(n) + (" DAY" if n == 1 else " DAYS") + " AGO"
        font = shared_font(c, [mission_line, days_line], ["6x8", "5x7", "4x5"], CW)
        fitted1, _ = fit_text(c, mission_line, [font], CW)
        fitted2, _ = fit_text(c, days_line, [font], CW)
        h = 8 if font == "6x8" else (7 if font == "5x7" else 6)
        label_h = 6
        gap = 2
        c.text("LAST", CX, 1, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        top = label_h + gap
        y1 = top + (32 - top - (h + gap + h)) // 2
        y2 = y1 + h + gap
        c.text(fitted1, CX, y1, font = font, color = "white", align = "center")
        c.text(fitted2, CX, y2, font = font, color = "amber", align = "center")
        return

    mission, kind = event
    name, ly, lm, ld, ny, nm, nd, crew_str = mission
    if name not in MERCURY_NAMES and name not in GEMINI_NAMES and name not in ARTEMIS_NAMES and LAUNCH_VEHICLE.get(name) != None:
        draw_trio_crew(c, mission, kind)
        return
    if ORBITER.get(name) != None or name in ARTEMIS_NAMES:
        draw_shuttle_crew_page(c, ctx, 0)
        return
    draw_crew_page(c, ctx, 0)


# Astronaut Profile rotation for pages 5-8 on empty days. Missions and
# flight time are computed from ALL_MISSIONS crew strings.
ASTRONAUT_NAMES = [
    "Alan Shepard",
    "Gus Grissom",
    "John Glenn",
    "Scott Carpenter",
    "Wally Schirra",
    "Gordon Cooper",
    "Deke Slayton",
    "Neil Armstrong",
    "Frank Borman",
    "Pete Conrad",
    "Jim Lovell",
    "James McDivitt",
    "Elliot See",
    "Thomas Stafford",
    "Ed White",
    "John Young",
    "Buzz Aldrin",
    "William Anders",
    "Charles Bassett",
    "Alan Bean",
    "Gene Cernan",
    "Roger Chaffee",
    "Michael Collins",
    "Walter Cunningham",
    "Donn Eisele",
    "Theodore Freeman",
    "Richard Gordon",
    "Rusty Schweickart",
    "David Scott",
    "C.C. Williams",
    "Owen Garriott",
    "Edward Gibson",
    "Duane Graveline",
    "Joseph Kerwin",
    "F. Curtis Michel",
    "Harrison Schmitt",
    "Vance Brand",
    "John Bull",
    "Gerald Carr",
    "Charles Duke",
    "Joe Engle",
    "Ronald Evans",
    "Edward Givens",
    "Fred Haise",
    "James Irwin",
    "Don Lind",
    "Jack Lousma",
    "Ken Mattingly",
    "Bruce McCandless",
    "Edgar Mitchell",
    "William Pogue",
    "Stuart Roosa",
    "Jack Swigert",
    "Paul Weitz",
    "Alfred Worden",
    "Joseph Allen",
    "Philip Chapman",
    "Anthony England",
    "Karl Henize",
    "Donald Holmquest",
    "William Lenoir",
    "John Llewellyn",
    "Story Musgrave",
    "Brian O'Leary",
    "Robert Parker",
    "William Thornton",
    "Karol Bobko",
    "Robert Crippen",
    "Gordon Fullerton",
    "Henry Hartsfield",
    "Robert Overmyer",
    "Donald Peterson",
    "Richard Truly",
    "Daniel Brandenstein",
    "Michael Coats",
    "Richard Covey",
    "John Creighton",
    "Robert Gibson",
    "Frederick Gregory",
    "David Griggs",
    "Frederick Hauck",
    "Jon McBride",
    "Steven Nagel",
    "Dick Scobee",
    "Brewster Shaw",
    "Loren Shriver",
    "David Walker",
    "Donald Williams",
    "Guion Bluford",
    "James Buchli",
    "John Fabian",
    "Anna Fisher",
    "Dale Gardner",
    "Terry Hart",
    "Steven Hawley",
    "Jeffrey Hoffman",
    "Shannon Lucid",
    "Ronald McNair",
    "Richard Mullane",
    "George Nelson",
    "Ellison Onizuka",
    "Judith Resnik",
    "Sally Ride",
    "Rhea Seddon",
    "Robert Stewart",
    "Kathryn Sullivan",
    "Norman Thagard",
    "James van Hoften",
    "John Blaha",
    "Charles Bolden",
    "Roy Bridges",
    "Guy Gardner",
    "Ronald Grabe",
    "Bryan O'Connor",
    "Dick Richards",
    "Michael Smith",
    "James Bagian",
    "Franklin Chang-Diaz",
    "Mary Cleave",
    "Bonnie Dunbar",
    "William Fisher",
    "David Hilmers",
    "David Leestma",
    "John Lounge",
    "Jerry Ross",
    "Sherwood Spring",
    "Robert Springer",
    "Kenneth Cameron",
    "John Casper",
    "Frank Culbertson",
    "Sidney Gutierrez",
    "Blaine Hammond",
    "Michael McCulley",
    "James Wetherbee",
    "James Adamson",
    "Ellen Baker",
    "Mark Brown",
    "Sonny Carter",
    "Marsha Ivins",
    "Mark Lee",
    "David Low",
    "William Shepherd",
    "Kathryn Thornton",
    "Charles Veach",
    "Michael Baker",
    "Robert Cabana",
    "Brian Duffy",
    "Terence Henricks",
    "Stephen Oswald",
    "Stephen Thorne",
    "Jerome Apt",
    "Charles Gemar",
    "Linda Godwin",
    "Richard Hieb",
    "Tamara Jernigan",
    "Carl Meade",
    "Pierre Thuot",
    "Andrew Allen",
    "Kenneth Bowersox",
    "Curtis Brown",
    "Kevin Chilton",
    "Donald McMonagle",
    "William Readdy",
    "Kenneth Reightler",
    "Thomas Akers",
    "Jan Davis",
    "Michael Foale",
    "Gregory Harbaugh",
    "Mae Jemison",
    "Bruce Melnick",
    "Mario Runco",
    "James Voss",
    "Kenneth Cockrell",
    "Eileen Collins",
    "William Gregory",
    "James Halsell",
    "Charles Precourt",
    "Richard Searfoss",
    "Terrence Wilcutt",
    "Daniel Bursch",
    "Leroy Chiao",
    "Michael Clifford",
    "Nancy Currie",
    "Bernard Harris",
    "Susan Helms",
    "Thomas Jones",
    "William McArthur",
    "James Newman",
    "Ellen Ochoa",
    "Ronald Sega",
    "Donald Thomas",
    "Janice Voss",
    "Carl Walz",
    "Peter Wisoff",
    "David Wolf",
    "Scott Horowitz",
    "Brent Jett",
    "Kevin Kregel",
    "Kent Rominger",
    "Daniel Barry",
    "Charles Brady",
    "Catherine Coleman",
    "Michael Gernhardt",
    "John Grunsfeld",
    "Wendy Lawrence",
    "Jerry Linenger",
    "Richard Linnehan",
    "Michael Lopez-Alegria",
    "Scott Parazynski",
    "Winston Scott",
    "Steven Smith",
    "Joseph Tanner",
    "Andrew Thomas",
    "Mary Ellen Weber",
    "Marc Garneau",
    "Chris Hadfield",
    "Maurizio Cheli",
    "Jean-Francois Clervoy",
    "Koichi Wakata",
    "Scott Altman",
    "Jeffrey Ashby",
    "Michael Bloomfield",
    "Joe Edwards",
    "Dominic Gorie",
    "Rick Husband",
    "Steven Lindsey",
    "Pamela Melroy",
    "Susan Still",
    "Frederick Sturckow",
    "Michael Anderson",
    "Kalpana Chawla",
    "Robert Curbeam",
    "Kathryn Hire",
    "Janet Kavandi",
    "Edward Lu",
    "Carlos Noriega",
    "James Reilly",
    "Stephen Robinson",
    "Jean-Loup Chretien",
    "Takao Doi",
    "Michel Tognini",
    "Dafydd Williams",
    "Duane Carey",
    "Stephen Frick",
    "Charles Hobaugh",
    "James Kelly",
    "Mark Kelly",
    "Scott Kelly",
    "Paul Lockhart",
    "Christopher Loria",
    "William McCool",
    "Mark Polansky",
    "David Brown",
    "Daniel Burbank",
    "Yvonne Cagle",
    "Fernando Caldeiro",
    "Charles Camarda",
    "Laurel Clark",
    "Michael Fincke",
    "Patrick Forrester",
    "John Herrington",
    "Joan Higginbotham",
    "Sandra Magnus",
    "Mike Massimino",
    "Richard Mastracchio",
    "Lee Morin",
    "Lisa Nowak",
    "Donald Pettit",
    "John Phillips",
    "Paul Richards",
    "Piers Sellers",
    "Heidemarie Stefanyshyn-Piper",
    "Daniel Tani",
    "Rex Walheim",
    "Peggy Whitson",
    "Jeffrey Williams",
    "Stephanie Wilson",
    "Pedro Duque",
    "Christer Fuglesang",
    "Umberto Guidoni",
    "Steve MacLean",
    "Mamoru Mohri",
    "Soichi Noguchi",
    "Julie Payette",
    "Philippe Perrin",
    "Gerhard Thiele",
    "Lee Archambault",
    "Christopher Ferguson",
    "Kenneth Ham",
    "Gregory C. Johnson",
    "Gregory H. Johnson",
    "William Oefelein",
    "Alan Poindexter",
    "George Zamka",
    "Clayton Anderson",
    "Tracy Caldwell Dyson",
    "Gregory Chamitoff",
    "Timothy Creamer",
    "Michael Foreman",
    "Michael Fossum",
    "Stanley Love",
    "Leland Melvin",
    "Barbara Morgan",
    "John Olivas",
    "Nicholas Patrick",
    "Garrett Reisman",
    "Patricia Robertson",
    "Steven Swanson",
    "Douglas Wheelock",
    "Sunita Williams",
    "Neil Woodward",
    "Leopold Eyharts",
    "Paolo Nespoli",
    "Marcos Pontes",
    "Hans Schlegel",
    "Robert Thirsk",
    "Bjarni Tryggvason",
    "Roberto Vittori",
    "Dominic Antonelli",
    "Eric Boe",
    "Kevin Ford",
    "Ronald Garan",
    "Douglas Hurley",
    "Terry Virts",
    "Barry Wilmore",
    "Michael Barratt",
    "Robert Behnken",
    "Stephen Bowen",
    "Alvin Drew",
    "Andrew Feustel",
    "Michael Good",
    "Timothy Kopra",
    "Megan McArthur",
    "Karen Nyberg",
    "Nicole Stott",
    "Randolph Bresnik",
    "James Dutton",
    "Christopher Cassidy",
    "Jose Hernandez",
    "Shane Kimbrough",
    "Thomas Marshburn",
    "Robert Satcher",
    "Shannon Walker",
    "Joseph Acaba",
    "Richard Arnold",
    "Dorothy Metcalf-Lindenburger",
    "Serena Aunon-Chancellor",
    "Jeanette Epps",
    "Jack Fischer",
    "Michael Hopkins",
    "Kjell Lindgren",
    "Kathleen Rubins",
    "Scott Tingle",
    "Mark Vande Hei",
    "Reid Wiseman",
    "Jeremy Hansen",
    "Norishige Kanai",
    "Takuya Onishi",
    "David Saint-Jacques",
    "Kimiya Yui",
    "Josh Cassada",
    "Victor Glover",
    "Nick Hague",
    "Christina Koch",
    "Nicole Mann",
    "Anne McClain",
    "Jessica Meir",
    "Andrew Morgan",
    "Kayla Barron",
    "Zena Cardman",
    "Raja Chari",
    "Matthew Dominick",
    "Robert Hines",
    "Warren Hoburg",
    "Jonny Kim",
    "Robb Kulin",
    "Jasmin Moghbeli",
    "Loral O'Hara",
    "Francisco Rubio",
    "Jessica Watkins",
    "Joshua Kutryk",
    "Jenni Sidey-Gibbons",
    "Nichole Ayers",
    "Marcos Berrios",
    "Christina Birch",
    "Deniz Burnham",
    "Luke Delaney",
    "Andre Douglas",
    "Jack Hathaway",
    "Anil Menon",
    "Christopher Williams",
    "Jessica Wittner",
    "Nora Al Matrooshi",
    "Mohammad Al Mulla",
]

# (group number, group label, status)
ASTRONAUT_PROFILES = {
    "Alan Shepard": (1, "GROUP 1 - THE MERCURY 7", "RETIRED, DECEASED"),
    "Gus Grissom": (1, "GROUP 1 - THE MERCURY 7", "DECEASED"),
    "John Glenn": (1, "GROUP 1 - THE MERCURY 7", "RETIRED, DECEASED"),
    "Scott Carpenter": (1, "GROUP 1 - THE MERCURY 7", "RETIRED, DECEASED"),
    "Wally Schirra": (1, "GROUP 1 - THE MERCURY 7", "RETIRED, DECEASED"),
    "Gordon Cooper": (1, "GROUP 1 - THE MERCURY 7", "RETIRED, DECEASED"),
    "Deke Slayton": (1, "GROUP 1 - THE MERCURY 7", "RETIRED, DECEASED"),
    "Neil Armstrong": (2, "GROUP 2 - THE NEW NINE", "RETIRED, DECEASED"),
    "Frank Borman": (2, "GROUP 2 - THE NEW NINE", "RETIRED, DECEASED"),
    "Pete Conrad": (2, "GROUP 2 - THE NEW NINE", "RETIRED, DECEASED"),
    "Jim Lovell": (2, "GROUP 2 - THE NEW NINE", "RETIRED, DECEASED"),
    "James McDivitt": (2, "GROUP 2 - THE NEW NINE", "RETIRED, DECEASED"),
    "Elliot See": (2, "GROUP 2 - THE NEW NINE", "DECEASED"),
    "Thomas Stafford": (2, "GROUP 2 - THE NEW NINE", "RETIRED, DECEASED"),
    "Ed White": (2, "GROUP 2 - THE NEW NINE", "DECEASED"),
    "John Young": (2, "GROUP 2 - THE NEW NINE", "RETIRED, DECEASED"),
    "Buzz Aldrin": (3, "GROUP 3 - THE FOURTEEN", "RETIRED"),
    "William Anders": (3, "GROUP 3 - THE FOURTEEN", "RETIRED, DECEASED"),
    "Charles Bassett": (3, "GROUP 3 - THE FOURTEEN", "DECEASED"),
    "Alan Bean": (3, "GROUP 3 - THE FOURTEEN", "RETIRED, DECEASED"),
    "Gene Cernan": (3, "GROUP 3 - THE FOURTEEN", "RETIRED, DECEASED"),
    "Roger Chaffee": (3, "GROUP 3 - THE FOURTEEN", "DECEASED"),
    "Michael Collins": (3, "GROUP 3 - THE FOURTEEN", "RETIRED, DECEASED"),
    "Walter Cunningham": (3, "GROUP 3 - THE FOURTEEN", "RETIRED, DECEASED"),
    "Donn Eisele": (3, "GROUP 3 - THE FOURTEEN", "RETIRED, DECEASED"),
    "Theodore Freeman": (3, "GROUP 3 - THE FOURTEEN", "DECEASED"),
    "Richard Gordon": (3, "GROUP 3 - THE FOURTEEN", "RETIRED, DECEASED"),
    "Rusty Schweickart": (3, "GROUP 3 - THE FOURTEEN", "RETIRED"),
    "David Scott": (3, "GROUP 3 - THE FOURTEEN", "RETIRED"),
    "C.C. Williams": (3, "GROUP 3 - THE FOURTEEN", "DECEASED"),
    "Owen Garriott": (4, "GROUP 4 - THE SCIENTISTS", "RETIRED, DECEASED"),
    "Edward Gibson": (4, "GROUP 4 - THE SCIENTISTS", "RETIRED"),
    "Duane Graveline": (4, "GROUP 4 - THE SCIENTISTS", "RETIRED, DECEASED"),
    "Joseph Kerwin": (4, "GROUP 4 - THE SCIENTISTS", "RETIRED"),
    "F. Curtis Michel": (4, "GROUP 4 - THE SCIENTISTS", "RETIRED, DECEASED"),
    "Harrison Schmitt": (4, "GROUP 4 - THE SCIENTISTS", "RETIRED"),
    "Vance Brand": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED"),
    "John Bull": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Gerald Carr": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Charles Duke": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED"),
    "Joe Engle": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Ronald Evans": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Edward Givens": (5, "GROUP 5 - THE ORIGINAL 19", "DECEASED"),
    "Fred Haise": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED"),
    "James Irwin": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Don Lind": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Jack Lousma": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED"),
    "Ken Mattingly": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Bruce McCandless": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Edgar Mitchell": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "William Pogue": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Stuart Roosa": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Jack Swigert": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Paul Weitz": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Alfred Worden": (5, "GROUP 5 - THE ORIGINAL 19", "RETIRED, DECEASED"),
    "Joseph Allen": (6, "GROUP 6 - THE XS-11", "RETIRED"),
    "Philip Chapman": (6, "GROUP 6 - THE XS-11", "RETIRED, DECEASED"),
    "Anthony England": (6, "GROUP 6 - THE XS-11", "RETIRED"),
    "Karl Henize": (6, "GROUP 6 - THE XS-11", "RETIRED, DECEASED"),
    "Donald Holmquest": (6, "GROUP 6 - THE XS-11", "RETIRED"),
    "William Lenoir": (6, "GROUP 6 - THE XS-11", "RETIRED, DECEASED"),
    "John Llewellyn": (6, "GROUP 6 - THE XS-11", "RETIRED, DECEASED"),
    "Story Musgrave": (6, "GROUP 6 - THE XS-11", "RETIRED"),
    "Brian O'Leary": (6, "GROUP 6 - THE XS-11", "RETIRED, DECEASED"),
    "Robert Parker": (6, "GROUP 6 - THE XS-11", "RETIRED"),
    "William Thornton": (6, "GROUP 6 - THE XS-11", "RETIRED, DECEASED"),
    "Karol Bobko": (7, "GROUP 7 - MOL TRANSFERS", "RETIRED, DECEASED"),
    "Robert Crippen": (7, "GROUP 7 - MOL TRANSFERS", "RETIRED"),
    "Gordon Fullerton": (7, "GROUP 7 - MOL TRANSFERS", "RETIRED, DECEASED"),
    "Henry Hartsfield": (7, "GROUP 7 - MOL TRANSFERS", "RETIRED, DECEASED"),
    "Robert Overmyer": (7, "GROUP 7 - MOL TRANSFERS", "RETIRED, DECEASED"),
    "Donald Peterson": (7, "GROUP 7 - MOL TRANSFERS", "RETIRED, DECEASED"),
    "Richard Truly": (7, "GROUP 7 - MOL TRANSFERS", "RETIRED, DECEASED"),
    "Daniel Brandenstein": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Michael Coats": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Richard Covey": (8, "GROUP 8 - TFNG", "RETIRED"),
    "John Creighton": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Robert Gibson": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Frederick Gregory": (8, "GROUP 8 - TFNG", "RETIRED"),
    "David Griggs": (8, "GROUP 8 - TFNG", "DECEASED"),
    "Frederick Hauck": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Jon McBride": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Steven Nagel": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Dick Scobee": (8, "GROUP 8 - TFNG", "DECEASED"),
    "Brewster Shaw": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Loren Shriver": (8, "GROUP 8 - TFNG", "RETIRED"),
    "David Walker": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Donald Williams": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Guion Bluford": (8, "GROUP 8 - TFNG", "RETIRED"),
    "James Buchli": (8, "GROUP 8 - TFNG", "RETIRED"),
    "John Fabian": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Anna Fisher": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Dale Gardner": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Terry Hart": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Steven Hawley": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Jeffrey Hoffman": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Shannon Lucid": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Ronald McNair": (8, "GROUP 8 - TFNG", "DECEASED"),
    "Richard Mullane": (8, "GROUP 8 - TFNG", "RETIRED"),
    "George Nelson": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Ellison Onizuka": (8, "GROUP 8 - TFNG", "DECEASED"),
    "Judith Resnik": (8, "GROUP 8 - TFNG", "DECEASED"),
    "Sally Ride": (8, "GROUP 8 - TFNG", "RETIRED, DECEASED"),
    "Rhea Seddon": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Robert Stewart": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Kathryn Sullivan": (8, "GROUP 8 - TFNG", "RETIRED"),
    "Norman Thagard": (8, "GROUP 8 - TFNG", "RETIRED"),
    "James van Hoften": (8, "GROUP 8 - TFNG", "RETIRED"),
    "John Blaha": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Charles Bolden": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Roy Bridges": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Guy Gardner": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Ronald Grabe": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Bryan O'Connor": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Dick Richards": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Michael Smith": (9, "GROUP 9 - 19+80", "DECEASED"),
    "James Bagian": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Franklin Chang-Diaz": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Mary Cleave": (9, "GROUP 9 - 19+80", "RETIRED, DECEASED"),
    "Bonnie Dunbar": (9, "GROUP 9 - 19+80", "RETIRED"),
    "William Fisher": (9, "GROUP 9 - 19+80", "RETIRED"),
    "David Hilmers": (9, "GROUP 9 - 19+80", "RETIRED"),
    "David Leestma": (9, "GROUP 9 - 19+80", "RETIRED"),
    "John Lounge": (9, "GROUP 9 - 19+80", "RETIRED, DECEASED"),
    "Jerry Ross": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Sherwood Spring": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Robert Springer": (9, "GROUP 9 - 19+80", "RETIRED"),
    "Kenneth Cameron": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "John Casper": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Frank Culbertson": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Sidney Gutierrez": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Blaine Hammond": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Michael McCulley": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "James Wetherbee": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "James Adamson": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Ellen Baker": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Mark Brown": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Sonny Carter": (10, "GROUP 10 - THE MAGGOTS", "DECEASED"),
    "Marsha Ivins": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Mark Lee": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "David Low": (10, "GROUP 10 - THE MAGGOTS", "RETIRED, DECEASED"),
    "William Shepherd": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Kathryn Thornton": (10, "GROUP 10 - THE MAGGOTS", "RETIRED"),
    "Charles Veach": (10, "GROUP 10 - THE MAGGOTS", "DECEASED"),
    "Michael Baker": (11, "GROUP 11", "RETIRED"),
    "Robert Cabana": (11, "GROUP 11", "RETIRED"),
    "Brian Duffy": (11, "GROUP 11", "RETIRED"),
    "Terence Henricks": (11, "GROUP 11", "RETIRED"),
    "Stephen Oswald": (11, "GROUP 11", "RETIRED"),
    "Stephen Thorne": (11, "GROUP 11", "DECEASED"),
    "Jerome Apt": (11, "GROUP 11", "RETIRED"),
    "Charles Gemar": (11, "GROUP 11", "RETIRED"),
    "Linda Godwin": (11, "GROUP 11", "RETIRED"),
    "Richard Hieb": (11, "GROUP 11", "RETIRED"),
    "Tamara Jernigan": (11, "GROUP 11", "RETIRED"),
    "Carl Meade": (11, "GROUP 11", "RETIRED"),
    "Pierre Thuot": (11, "GROUP 11", "RETIRED"),
    "Andrew Allen": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Kenneth Bowersox": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Curtis Brown": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Kevin Chilton": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Donald McMonagle": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "William Readdy": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Kenneth Reightler": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Thomas Akers": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Jan Davis": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Michael Foale": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Gregory Harbaugh": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Mae Jemison": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Bruce Melnick": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Mario Runco": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "James Voss": (12, "GROUP 12 - THE GAFFERS", "RETIRED"),
    "Kenneth Cockrell": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Eileen Collins": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "William Gregory": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "James Halsell": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Charles Precourt": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Richard Searfoss": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED, DECEASED"),
    "Terrence Wilcutt": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Daniel Bursch": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Leroy Chiao": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Michael Clifford": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED, DECEASED"),
    "Nancy Currie": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Bernard Harris": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Susan Helms": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Thomas Jones": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "William McArthur": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "James Newman": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Ellen Ochoa": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Ronald Sega": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Donald Thomas": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Janice Voss": (13, "GROUP 13 - THE HAIRBALLS", "DECEASED"),
    "Carl Walz": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Peter Wisoff": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "David Wolf": (13, "GROUP 13 - THE HAIRBALLS", "RETIRED"),
    "Scott Horowitz": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Brent Jett": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Kevin Kregel": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Kent Rominger": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Daniel Barry": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Charles Brady": (14, "GROUP 14 - THE HOGS", "RETIRED, DECEASED"),
    "Catherine Coleman": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Michael Gernhardt": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "John Grunsfeld": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Wendy Lawrence": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Jerry Linenger": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Richard Linnehan": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Michael Lopez-Alegria": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Scott Parazynski": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Winston Scott": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Steven Smith": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Joseph Tanner": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Andrew Thomas": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Mary Ellen Weber": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Marc Garneau": (14, "GROUP 14 - THE HOGS", "RETIRED, DECEASED"),
    "Chris Hadfield": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Maurizio Cheli": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Jean-Francois Clervoy": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Koichi Wakata": (14, "GROUP 14 - THE HOGS", "RETIRED"),
    "Scott Altman": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Jeffrey Ashby": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Michael Bloomfield": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Joe Edwards": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Dominic Gorie": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Rick Husband": (15, "GROUP 15 - THE FLYING ESCARGOT", "DECEASED"),
    "Steven Lindsey": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Pamela Melroy": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Susan Still": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Frederick Sturckow": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Michael Anderson": (15, "GROUP 15 - THE FLYING ESCARGOT", "DECEASED"),
    "Kalpana Chawla": (15, "GROUP 15 - THE FLYING ESCARGOT", "DECEASED"),
    "Robert Curbeam": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Kathryn Hire": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Janet Kavandi": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Edward Lu": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Carlos Noriega": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "James Reilly": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Stephen Robinson": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Jean-Loup Chretien": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Takao Doi": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Michel Tognini": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Dafydd Williams": (15, "GROUP 15 - THE FLYING ESCARGOT", "RETIRED"),
    "Duane Carey": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Stephen Frick": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Charles Hobaugh": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "James Kelly": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Mark Kelly": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Scott Kelly": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Paul Lockhart": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Christopher Loria": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "William McCool": (16, "GROUP 16 - THE SARDINES", "DECEASED"),
    "Mark Polansky": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "David Brown": (16, "GROUP 16 - THE SARDINES", "DECEASED"),
    "Daniel Burbank": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Yvonne Cagle": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Fernando Caldeiro": (16, "GROUP 16 - THE SARDINES", "DECEASED"),
    "Charles Camarda": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Laurel Clark": (16, "GROUP 16 - THE SARDINES", "DECEASED"),
    "Michael Fincke": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Patrick Forrester": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "John Herrington": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Joan Higginbotham": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Sandra Magnus": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Mike Massimino": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Richard Mastracchio": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Lee Morin": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Lisa Nowak": (16, "GROUP 16 - THE SARDINES", "DISMISSED"),
    "Donald Pettit": (16, "GROUP 16 - THE SARDINES", "ACTIVE"),
    "John Phillips": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Paul Richards": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Piers Sellers": (16, "GROUP 16 - THE SARDINES", "RETIRED, DECEASED"),
    "Heidemarie Stefanyshyn-Piper": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Daniel Tani": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Rex Walheim": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Peggy Whitson": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Jeffrey Williams": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Stephanie Wilson": (16, "GROUP 16 - THE SARDINES", "ACTIVE"),
    "Pedro Duque": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Christer Fuglesang": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Umberto Guidoni": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Steve MacLean": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Mamoru Mohri": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Soichi Noguchi": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Julie Payette": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Philippe Perrin": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Gerhard Thiele": (16, "GROUP 16 - THE SARDINES", "RETIRED"),
    "Lee Archambault": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Christopher Ferguson": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Kenneth Ham": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Gregory C. Johnson": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Gregory H. Johnson": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "William Oefelein": (17, "GROUP 17 - THE PENGUINS", "DISMISSED"),
    "Alan Poindexter": (17, "GROUP 17 - THE PENGUINS", "RETIRED, DECEASED"),
    "George Zamka": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Clayton Anderson": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Tracy Caldwell Dyson": (17, "GROUP 17 - THE PENGUINS", "ACTIVE"),
    "Gregory Chamitoff": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Timothy Creamer": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Michael Foreman": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Michael Fossum": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Stanley Love": (17, "GROUP 17 - THE PENGUINS", "ACTIVE"),
    "Leland Melvin": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Barbara Morgan": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "John Olivas": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Nicholas Patrick": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Garrett Reisman": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Patricia Robertson": (17, "GROUP 17 - THE PENGUINS", "DECEASED"),
    "Steven Swanson": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Douglas Wheelock": (17, "GROUP 17 - THE PENGUINS", "ACTIVE"),
    "Sunita Williams": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Neil Woodward": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Leopold Eyharts": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Paolo Nespoli": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Marcos Pontes": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Hans Schlegel": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Robert Thirsk": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Bjarni Tryggvason": (17, "GROUP 17 - THE PENGUINS", "RETIRED, DECEASED"),
    "Roberto Vittori": (17, "GROUP 17 - THE PENGUINS", "RETIRED"),
    "Dominic Antonelli": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Eric Boe": (18, "GROUP 18 - THE BUGS", "ACTIVE"),
    "Kevin Ford": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Ronald Garan": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Douglas Hurley": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Terry Virts": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Barry Wilmore": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Michael Barratt": (18, "GROUP 18 - THE BUGS", "ACTIVE"),
    "Robert Behnken": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Stephen Bowen": (18, "GROUP 18 - THE BUGS", "ACTIVE"),
    "Alvin Drew": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Andrew Feustel": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Michael Good": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Timothy Kopra": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Megan McArthur": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Karen Nyberg": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Nicole Stott": (18, "GROUP 18 - THE BUGS", "RETIRED"),
    "Randolph Bresnik": (19, "GROUP 19 - THE PEACOCKS", "ACTIVE"),
    "James Dutton": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Christopher Cassidy": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Jose Hernandez": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Shane Kimbrough": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Thomas Marshburn": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Robert Satcher": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Shannon Walker": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Joseph Acaba": (19, "GROUP 19 - THE PEACOCKS", "ACTIVE"),
    "Richard Arnold": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Dorothy Metcalf-Lindenburger": (19, "GROUP 19 - THE PEACOCKS", "RETIRED"),
    "Serena Aunon-Chancellor": (20, "GROUP 20 - THE CHUMPS", "RETIRED"),
    "Jeanette Epps": (20, "GROUP 20 - THE CHUMPS", "RETIRED"),
    "Jack Fischer": (20, "GROUP 20 - THE CHUMPS", "RETIRED"),
    "Michael Hopkins": (20, "GROUP 20 - THE CHUMPS", "RETIRED"),
    "Kjell Lindgren": (20, "GROUP 20 - THE CHUMPS", "ACTIVE"),
    "Kathleen Rubins": (20, "GROUP 20 - THE CHUMPS", "RETIRED"),
    "Scott Tingle": (20, "GROUP 20 - THE CHUMPS", "ACTIVE"),
    "Mark Vande Hei": (20, "GROUP 20 - THE CHUMPS", "ACTIVE"),
    "Reid Wiseman": (20, "GROUP 20 - THE CHUMPS", "RETIRED"),
    "Jeremy Hansen": (20, "GROUP 20 - THE CHUMPS", "RETIRED"),
    "Norishige Kanai": (20, "GROUP 20 - THE CHUMPS", "ACTIVE"),
    "Takuya Onishi": (20, "GROUP 20 - THE CHUMPS", "ACTIVE"),
    "David Saint-Jacques": (20, "GROUP 20 - THE CHUMPS", "ACTIVE"),
    "Kimiya Yui": (20, "GROUP 20 - THE CHUMPS", "ACTIVE"),
    "Josh Cassada": (21, "GROUP 21 - THE 8 BALLS", "RETIRED"),
    "Victor Glover": (21, "GROUP 21 - THE 8 BALLS", "RETIRED"),
    "Nick Hague": (21, "GROUP 21 - THE 8 BALLS", "RETIRED"),
    "Christina Koch": (21, "GROUP 21 - THE 8 BALLS", "ACTIVE"),
    "Nicole Mann": (21, "GROUP 21 - THE 8 BALLS", "ACTIVE"),
    "Anne McClain": (21, "GROUP 21 - THE 8 BALLS", "ACTIVE"),
    "Jessica Meir": (21, "GROUP 21 - THE 8 BALLS", "ACTIVE"),
    "Andrew Morgan": (21, "GROUP 21 - THE 8 BALLS", "RETIRED"),
    "Kayla Barron": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Zena Cardman": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Raja Chari": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Matthew Dominick": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Robert Hines": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Warren Hoburg": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Jonny Kim": (22, "GROUP 22 - THE TURTLES", "RETIRED"),
    "Robb Kulin": (22, "GROUP 22 - THE TURTLES", "RETIRED"),
    "Jasmin Moghbeli": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Loral O'Hara": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Francisco Rubio": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Jessica Watkins": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Joshua Kutryk": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Jenni Sidey-Gibbons": (22, "GROUP 22 - THE TURTLES", "ACTIVE"),
    "Nichole Ayers": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Marcos Berrios": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Christina Birch": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Deniz Burnham": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Luke Delaney": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Andre Douglas": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Jack Hathaway": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Anil Menon": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Christopher Williams": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Jessica Wittner": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Nora Al Matrooshi": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
    "Mohammad Al Mulla": (23, "GROUP 23 - THE FLIES", "ACTIVE"),
}

# One accent color per NASA Astronaut Group.
GROUP_COLORS = {
    1: "#3987e5",
    2: "#d95926",
    3: "#199e70",
    4: "#c98500",
    5: "#d55181",
    6: "#9085e9",
    7: "#e66767",
    8: "#2fae2f",
    9: "#4fc3d9",
    10: "#e0d34f",
    11: "#ff7ad9",
    12: "#a8e64a",
    13: "#ff9f40",
    14: "#8fb8ff",
    15: "#e8a0ff",
    16: "#ff8a65",
    17: "#5ad1c9",
    18: "#f28b82",
    19: "#b39ddb",
    20: "#9ccc65",
    21: "#ffd54f",
    22: "#4dd0e1",
    23: "#f48fb1",
}

# Year each NASA Astronaut Group was selected, shown on the profile card.
GROUP_YEARS = {
    1: 1959, 2: 1962, 3: 1963, 4: 1965, 5: 1966, 6: 1967, 7: 1969, 8: 1978,
    9: 1980, 10: 1984, 11: 1985, 12: 1987, 13: 1990, 14: 1992, 15: 1994, 16: 1996,
    17: 1998, 18: 2000, 19: 2004, 20: 2009,
    21: 2013, 22: 2017, 23: 2021,
}

# (left the astronaut corps, left NASA, died): "YYYY-MM-DD", "YYYY-MM" or
# "YYYY"; "" = none or unknown. Left NASA is "" for internationals and
# people still at NASA. Corps dates from spacefacts.de group tables,
# Wikipedia and NASA bios; death dates from Wikidata.
ASTRONAUT_DATES = {
    "Alan Bean": ("1981-02-26", "1981-06", "2018-05-26"),
    "Alan Shepard": ("1974-07-31", "1974-07-31", "1998-07-21"),
    "Alfred Worden": ("1975-09-01", "1975-09-01", "2020-03-18"),
    "Andrew Allen": ("1997-10-01", "1997-10-01", ""),
    "Andrew Thomas": ("2010-12", "2014-03-01", ""),
    "Anna Fisher": ("2006-06", "2017-04", ""),
    "Anthony England": ("1988-08-31", "1988-08-31", ""),
    "Bernard Harris": ("1996-04-15", "1996-04-15", ""),
    "Blaine Hammond": ("1998-02-23", "1998-02-23", ""),
    "Bonnie Dunbar": ("2005-09-30", "2005-09-30", ""),
    "Brent Jett": ("2007-11", "2013-01", ""),
    "Brewster Shaw": ("1989-10", "1996", ""),
    "Brian Duffy": ("2001-04", "2001-04", ""),
    "Brian O'Leary": ("1968-04-23", "1968-04-23", "2011-07-28"),
    "Bruce McCandless": ("1990-08-31", "1990-08-31", "2017-12-21"),
    "Bruce Melnick": ("1992-07", "1992-07", ""),
    "Bryan O'Connor": ("1991-07-29", "2011-08-31", ""),
    "Buzz Aldrin": ("1971-07-01", "1971-07-01", ""),
    "C.C. Williams": ("", "", "1967-10-05"),
    "Carl Meade": ("1996-02-29", "1996-02-29", ""),
    "Carl Walz": ("2008-12-05", "2008-12-05", ""),
    "Carlos Noriega": ("2005-01", "2005-01", ""),
    "Catherine Coleman": ("2015-07", "2016-12-01", ""),
    "Charles Bassett": ("", "", "1966-02-28"),
    "Charles Bolden": ("1994-06-27", "2017-01-20", ""),
    "Charles Brady": ("2002-08-14", "2002-08-14", "2006-07-23"),
    "Charles Camarda": ("2006-06", "2019", ""),
    "Charles Duke": ("1976-01-01", "1976-01-01", ""),
    "Charles Gemar": ("1996-01", "1998", ""),
    "Charles Hobaugh": ("2011-09-23", "2013-06", ""),
    "Charles Precourt": ("2004", "2004", ""),
    "Charles Veach": ("", "", "1995-10-03"),
    "Chris Hadfield": ("2013-07-03", "", ""),
    "Christopher Loria": ("2005-02", "2005-02", ""),
    "Curtis Brown": ("1999-12-31", "2000-05", ""),
    "Dafydd Williams": ("2008-03-01", "", ""),
    "Dale Gardner": ("1986-10", "1986-10", "2014-02-19"),
    "Daniel Barry": ("2005-04", "2005-04", ""),
    "Daniel Brandenstein": ("1992-10-01", "1992-10-01", ""),
    "Daniel Burbank": ("2018-06-29", "2018-06-29", ""),
    "Daniel Bursch": ("2005-06", "2005-06", ""),
    "Daniel Tani": ("2012-08", "2012-08", ""),
    "David Brown": ("", "", "2003-02-01"),
    "David Griggs": ("", "", "1989-06-17"),
    "David Hilmers": ("1992-10", "1992-10", ""),
    "David Leestma": ("1992-12", "2014-05-30", ""),
    "David Low": ("1996-02-20", "1996-02-20", "2008-03-15"),
    "David Scott": ("1977-10-30", "1977-10-30", ""),
    "David Walker": ("1996-04-15", "1996-04-15", "2001-04-23"),
    "David Wolf": ("2012-12", "2012-12", ""),
    "Dick Richards": ("1995-07", "1995-07", ""),
    "Dick Scobee": ("", "", "1986-01-28"),
    "Dominic Gorie": ("2010-06-04", "2010-06-04", ""),
    "Don Lind": ("1986-04", "1986-04", "2022-08-30"),
    "Donald Holmquest": ("1973-09", "1973-09", ""),
    "Donald Peterson": ("1984-12", "1984-12", "2018-05-27"),
    "Donald Thomas": ("2007-07", "2007-07", ""),
    "Donald Williams": ("1990-03-01", "1990-03-01", "2016-02-23"),
    "Donn Eisele": ("1970-06-01", "1972-06-01", "1987-12-02"),
    "Duane Carey": ("2004-10", "2004-10", ""),
    "Duane Graveline": ("1965-08-18", "1965-08-18", "2016-09-05"),
    "Ed White": ("", "", "1967-01-27"),
    "Edgar Mitchell": ("1972-10-01", "1972-10-01", "2016-02-04"),
    "Edward Gibson": ("1974-12", "1982-10-31", ""),
    "Edward Givens": ("", "", "1967-06-06"),
    "Edward Lu": ("2007-08", "2007-08", ""),
    "Eileen Collins": ("2006-05-01", "2006-05-01", ""),
    "Ellen Baker": ("2011", "2011-12-31", ""),
    "Ellen Ochoa": ("2003-01", "2018-05-25", ""),
    "Elliot See": ("", "", "1966-02-28"),
    "Ellison Onizuka": ("", "", "1986-01-28"),
    "F. Curtis Michel": ("1969-08-18", "1969-08-18", "2015-02-23"),
    "Fernando Caldeiro": ("", "", "2009-10-03"),
    "Frank Borman": ("1970-07-01", "1970-07-01", "2023-11-07"),
    "Frank Culbertson": ("2002-08-24", "2002-08-24", ""),
    "Franklin Chang-Diaz": ("2005-07-08", "2005-07-08", ""),
    "Fred Haise": ("1979-06-29", "1979-06-29", ""),
    "Frederick Gregory": ("1992-04", "2005-10", ""),
    "Frederick Hauck": ("1989-04-03", "1989-04-03", "2025-11-06"),
    "Frederick Sturckow": ("2013-03", "2013-03", ""),
    "Gene Cernan": ("1976-07-01", "1976-07-01", "2017-01-16"),
    "George Nelson": ("1989-06-30", "1989-06-30", ""),
    "Gerald Carr": ("1977-06-25", "1977-06-25", "2020-08-26"),
    "Gerhard Thiele": ("2005-10", "", ""),
    "Gordon Cooper": ("1970-07-31", "1970-07-31", "2004-10-04"),
    "Deke Slayton": ("1982-02-27", "1982-02-27", "1993-06-13"),
    "Gordon Fullerton": ("1986-10", "2007-12-31", "2013-08-21"),
    "Gregory Harbaugh": ("2001-03-30", "2001-03-30", ""),
    "Guion Bluford": ("1993-06-15", "1993-06-15", ""),
    "Gus Grissom": ("", "", "1967-01-27"),
    "Guy Gardner": ("1991-06", "1991-06", ""),
    "Harrison Schmitt": ("1975-08-30", "1975-08-30", ""),
    "Heidemarie Stefanyshyn-Piper": ("2009-07", "2009-07", ""),
    "Henry Hartsfield": ("1988-03", "1998-03", "2014-07-17"),
    "Jack Lousma": ("1983-10-01", "1983-10-01", ""),
    "Jack Swigert": ("1973-04", "1977-08", "1982-12-27"),
    "James Adamson": ("1992-08", "1992-08", ""),
    "James Bagian": ("1995-08", "1995-08", ""),
    "James Buchli": ("1992-09-01", "1992-09-01", ""),
    "James Halsell": ("2006-11", "2006-11", ""),
    "James Irwin": ("1972-07-31", "1972-07-31", "1991-08-08"),
    "James Kelly": ("2010-12", "2010-12", ""),
    "James McDivitt": ("1972-09-01", "1972-09-01", "2022-10-13"),
    "James Newman": ("2008-07", "2008-07", ""),
    "James Reilly": ("2008-05", "2008-05", ""),
    "James Voss": ("2003-06", "2003-06", ""),
    "James Wetherbee": ("2005-01-03", "2005-01-03", ""),
    "James van Hoften": ("1986-08-01", "1986-08-01", ""),
    "Jan Davis": ("1999-06-21", "2005", ""),
    "Janet Kavandi": ("2005", "2019-09", ""),
    "Janice Voss": ("", "", "2012-02-06"),
    "Jean-Francois Clervoy": ("2018-12-01", "", ""),
    "Jean-Loup Chretien": ("1998-07-20", "", ""),
    "Jeffrey Ashby": ("2008-06", "2008-06", ""),
    "Jeffrey Hoffman": ("1997-07", "2001-08", ""),
    "Jeffrey Williams": ("2020-07", "2024-01-14", ""),
    "Jerome Apt": ("1997-05-31", "1997-05-31", ""),
    "Jerry Linenger": ("1998-02-23", "1998-02-23", ""),
    "Jerry Ross": ("2012-01-28", "2012-01-28", ""),
    "Jim Lovell": ("1973-03-01", "1973-03-01", "2025-08-07"),
    "Joan Higginbotham": ("2007-11-30", "2007-11-30", ""),
    "Joe Edwards": ("2000-04-30", "2000-04-30", ""),
    "Joe Engle": ("1986-11-28", "1986-11-28", "2024-07-10"),
    "John Blaha": ("1997-09-26", "1997-09-26", ""),
    "John Bull": ("1968-07-16", "1968-07-16", "2008-08-11"),
    "John Creighton": ("1992-07-15", "1992-07-15", ""),
    "John Fabian": ("1985-12-31", "1985-12-31", "2026-05-21"),
    "John Glenn": ("1964-01-16", "1964-01-16", "2016-12-08"),
    "John Grunsfeld": ("2010-01-04", "2016-04-30", ""),
    "John Herrington": ("2005-09-09", "2005-09-09", ""),
    "John Llewellyn": ("1968-09-06", "1968-09-06", "2013-07-02"),
    "John Lounge": ("1991-06-20", "1991-06-20", "2011-03-01"),
    "John Phillips": ("2011-08", "2011-08", ""),
    "John Young": ("2004-12-31", "2004-12-31", "2018-01-05"),
    "Jon McBride": ("1989-05-12", "1989-05-12", "2024-08-07"),
    "Joseph Allen": ("1985-07-01", "1985-07-01", ""),
    "Joseph Kerwin": ("1987-03-31", "1987-03-31", ""),
    "Joseph Tanner": ("2008-09", "2008-09", ""),
    "Judith Resnik": ("", "", "1986-01-28"),
    "Julie Payette": ("2013-05", "", ""),
    "Kalpana Chawla": ("", "", "2003-02-01"),
    "Karl Henize": ("1986-04", "1986-04", "1993-10-05"),
    "Karol Bobko": ("1989-01-01", "1989-01-01", "2023-08-17"),
    "Kathryn Hire": ("2010-03", "2019-02-28", ""),
    "Kathryn Sullivan": ("1993-06", "1993-06", ""),
    "Kathryn Thornton": ("1996-08-01", "1996-08-01", ""),
    "Ken Mattingly": ("1985-06", "1985-06", "2023-10-31"),
    "Kenneth Bowersox": ("2006-09-30", "2026-03-06", ""),
    "Kenneth Cameron": ("1996-08-05", "2008-12", ""),
    "Kenneth Reightler": ("1995-07", "1995-07", ""),
    "Kent Rominger": ("2006-09-30", "2006-09-30", ""),
    "Kevin Chilton": ("1998-08", "1998-08", ""),
    "Kevin Kregel": ("2002-06-27", "2002-06-27", ""),
    "Koichi Wakata": ("2024-03-31", "", ""),
    "Laurel Clark": ("", "", "2003-02-01"),
    "Lee Morin": ("2002", "2025-12-18", ""),
    "Leroy Chiao": ("2005-10-31", "2005-10-31", ""),
    "Linda Godwin": ("2010-08", "2010-08", ""),
    "Lisa Nowak": ("2007-03-07", "2007-03-07", ""),
    "Loren Shriver": ("1993-05", "2000-03", ""),
    "Mae Jemison": ("1993-03-08", "1993-03-08", ""),
    "Marc Garneau": ("2005-11-28", "", "2025-06-04"),
    "Mario Runco": ("2002-06-27", "2017-12-31", ""),
    "Mark Brown": ("1993-07", "1993-07", ""),
    "Mark Kelly": ("2011-10-01", "2011-10-01", ""),
    "Mark Lee": ("2001-07-01", "2001-07-01", ""),
    "Mark Polansky": ("2012-06-30", "2012-06-30", ""),
    "Marsha Ivins": ("2010-12-31", "2010-12-31", ""),
    "Mary Cleave": ("1991-05", "2007", "2023-11-27"),
    "Mary Ellen Weber": ("2002-12", "2002-12", ""),
    "Maurizio Cheli": ("1996-06-30", "", ""),
    "Michael Anderson": ("", "", "2003-02-01"),
    "Michael Baker": ("2008-01", "2017-01-07", ""),
    "Michael Bloomfield": ("2007-07-13", "2007-07-13", ""),
    "Michael Clifford": ("1997-01-06", "1997-01-06", "2021-12-28"),
    "Michael Coats": ("1991-08-01", "2012-12-31", ""),
    "Michael Collins": ("1970-01", "1970-01", "2021-04-28"),
    "Michael Fincke": ("2026-08-12", "2026-08-12", ""),
    "Michael Foale": ("2013-08-09", "2013-08-09", ""),
    "Michael Gernhardt": ("2001-08", "2022-07-25", ""),
    "Michael Lopez-Alegria": ("2012-03-12", "2012-03-12", ""),
    "Michael McCulley": ("1990-10", "1990-10", ""),
    "Michael Smith": ("", "", "1986-01-28"),
    "Michel Tognini": ("2003-05", "", ""),
    "Mike Massimino": ("2012-03", "2014-07", ""),
    "Nancy Currie": ("2005", "2017-11-02", ""),
    "Neil Armstrong": ("1971-08-01", "1971-08-01", "2012-08-25"),
    "Norman Thagard": ("1996-01-03", "1996-01-03", ""),
    "Owen Garriott": ("1986-08-01", "1986-08-01", "2019-04-15"),
    "Pamela Melroy": ("2009-07", "2009-07", ""),
    "Patrick Forrester": ("2011-08", "2024-06-29", ""),
    "Paul Lockhart": ("2005-01", "2005-01", ""),
    "Paul Richards": ("2002-02", "2002-02", ""),
    "Paul Weitz": ("1988-03", "1994-05", "2017-10-22"),
    "Pedro Duque": ("2018-06-07", "", ""),
    "Peggy Whitson": ("2018-06-15", "2018-06-15", ""),
    "Pete Conrad": ("1974-02-01", "1974-02-01", "1999-07-08"),
    "Peter Wisoff": ("2001-09-21", "2001-09-21", ""),
    "Philip Chapman": ("1972-07", "1972-07", "2021-04-05"),
    "Philippe Perrin": ("2004-05", "", ""),
    "Pierre Thuot": ("1995-06", "1995-06", ""),
    "Piers Sellers": ("2011-06-05", "2011-06-05", "2016-12-23"),
    "Rex Walheim": ("2020-08", "2020-08", ""),
    "Rhea Seddon": ("1997-11", "1997-11", ""),
    "Richard Covey": ("1994-07-01", "1994-07-01", ""),
    "Richard Gordon": ("1972-01-01", "1972-01-01", "2017-11-06"),
    "Richard Hieb": ("1995-04-03", "1995-04-03", ""),
    "Richard Linnehan": ("2010-12", "2025-12", ""),
    "Richard Mastracchio": ("2015-07", "2017-06", ""),
    "Richard Mullane": ("1990-08-01", "1990-08-01", ""),
    "Richard Searfoss": ("1998-12-31", "1998-12-31", "2018-09-29"),
    "Richard Truly": ("1983-10-01", "1992-05", "2024-02-27"),
    "Rick Husband": ("", "", "2003-02-01"),
    "Robert Cabana": ("2004-04", "2023-12-31", ""),
    "Robert Crippen": ("1991-12-31", "1991-12-31", ""),
    "Robert Curbeam": ("2007-12-07", "2007-12-07", ""),
    "Robert Gibson": ("1996-11-15", "1996-11-15", ""),
    "Robert Overmyer": ("1986-06", "1986-06", "1996-03-22"),
    "Robert Parker": ("1993", "2005-08-31", ""),
    "Robert Springer": ("1990-12", "1990-12", ""),
    "Robert Stewart": ("1986-01", "1986-01", ""),
    "Roger Chaffee": ("", "", "1967-01-27"),
    "Ronald Evans": ("1977-03-15", "1977-03-15", "1990-04-07"),
    "Ronald Grabe": ("1994-04-11", "1994-04-11", ""),
    "Ronald McNair": ("", "", "1986-01-28"),
    "Ronald Sega": ("1996-07-01", "1996-07-01", ""),
    "Roy Bridges": ("1986-03", "2005-12", ""),
    "Rusty Schweickart": ("1977", "1977", ""),
    "Sally Ride": ("1987-08-15", "1987-08-15", "2012-07-23"),
    "Sandra Magnus": ("2012-10-21", "2012-10-21", ""),
    "Scott Altman": ("2010-09-03", "2010-09-03", ""),
    "Scott Carpenter": ("1967-08-10", "1967-08-10", "2013-10-10"),
    "Scott Horowitz": ("2004-10", "2004-10", ""),
    "Scott Kelly": ("2016-04-01", "2016-04-01", ""),
    "Scott Parazynski": ("2009-03-24", "2009-03-24", ""),
    "Shannon Lucid": ("2012-01-31", "2012-01-31", ""),
    "Sherwood Spring": ("1988-06", "1988-06", ""),
    "Sidney Gutierrez": ("1994-08-08", "1994-08-08", ""),
    "Soichi Noguchi": ("2022-06-01", "", ""),
    "Sonny Carter": ("", "", "1991-04-05"),
    "Stephen Frick": ("2010-10", "2015-07", ""),
    "Stephen Oswald": ("2000-01-31", "2000-01-31", ""),
    "Stephen Robinson": ("2012-06-30", "2012-06-30", ""),
    "Stephen Thorne": ("", "", "1986-05-24"),
    "Steve MacLean": ("2008-09-01", "", ""),
    "Steven Hawley": ("2008-02-27", "2008-02-27", ""),
    "Steven Lindsey": ("2011-07-15", "2011-07-15", ""),
    "Steven Nagel": ("1995-02-28", "1995-02-28", "2014-08-21"),
    "Steven Smith": ("2005-01", "2017", ""),
    "Story Musgrave": ("1997-09-02", "1997-09-02", ""),
    "Stuart Roosa": ("1976-02-01", "1976-02-01", "1994-12-12"),
    "Susan Helms": ("2002-07-28", "2002-07-28", ""),
    "Susan Still": ("2002-12", "2002-12", ""),
    "Takao Doi": ("2009-09-13", "", ""),
    "Tamara Jernigan": ("2001-09-21", "2001-09-21", ""),
    "Terence Henricks": ("1997-10-31", "1997-10-31", ""),
    "Terrence Wilcutt": ("2005-02", "2020-12-31", ""),
    "Terry Hart": ("1984-06-15", "1984-06-15", ""),
    "Theodore Freeman": ("", "", "1964-10-31"),
    "Thomas Akers": ("1997-08-01", "1997-08-01", ""),
    "Thomas Jones": ("2001-09-07", "2001-09-07", ""),
    "Thomas Stafford": ("1975-11-01", "1975-11-01", "2024-03-18"),
    "Umberto Guidoni": ("2004-06", "", ""),
    "Vance Brand": ("1992-04", "2008-01", ""),
    "Wally Schirra": ("1969-07-01", "1969-07-01", "2007-05-03"),
    "Walter Cunningham": ("1971-08-01", "1971-08-01", "2023-01-03"),
    "Wendy Lawrence": ("2006-06", "2006-06", ""),
    "William Anders": ("1969-09-01", "1969-09-01", "2024-06-07"),
    "William Fisher": ("1991-01-31", "1992", ""),
    "William Gregory": ("1999-07", "1999-07", ""),
    "William Lenoir": ("1984-10", "1992-04", "2010-08-26"),
    "William McArthur": ("2012-01", "2017-07-18", ""),
    "William McCool": ("", "", "2003-02-01"),
    "William Pogue": ("1975-09-01", "1975-09-01", "2014-03-03"),
    "William Readdy": ("2005-10-15", "2005-10-15", ""),
    "William Shepherd": ("2002-08-14", "2002-08-14", ""),
    "William Thornton": ("1994-05-31", "1994-05-31", "2021-01-11"),
    "Winston Scott": ("1999-07-31", "1999-07-31", ""),
    "Lee Archambault": ("2012-02", "2013", ""),
    "Christopher Ferguson": ("2011-12-09", "2011-12-09", ""),
    "Kenneth Ham": ("2012-05-31", "2012-05-31", ""),
    "Gregory C. Johnson": ("2018-08-09", "2018-08-09", ""),
    "Gregory H. Johnson": ("2013-08", "2013-08", ""),
    "William Oefelein": ("2007-06-01", "2007-06-01", ""),
    "Alan Poindexter": ("2010-12", "2010-12", "2012-07-01"),
    "George Zamka": ("2011-08", "2013-03", ""),
    "Clayton Anderson": ("2011-06", "2013-01", ""),
    "Gregory Chamitoff": ("2013-09-30", "2013-09-30", ""),
    "Michael Foreman": ("2010-12", "2015-07-31", ""),
    "Michael Fossum": ("2017-01-07", "2017-01-07", ""),
    "Leland Melvin": ("2010-10", "2014-02", ""),
    "Barbara Morgan": ("2008-08", "2008-08", ""),
    "John Olivas": ("2010-05-25", "2010-05-25", ""),
    "Nicholas Patrick": ("2012-05-31", "2012-05-31", ""),
    "Garrett Reisman": ("2011-03", "2011-03", ""),
    "Patricia Robertson": ("", "", "2001-05-24"),
    "Steven Swanson": ("2015-08-30", "2015-08-30", ""),
    "Sunita Williams": ("2025-12-27", "2025-12-27", ""),
    "Neil Woodward": ("2008-07", "2008-07", ""),
    "Paolo Nespoli": ("2018-11-01", "", ""),
    "Robert Thirsk": ("2012-08-13", "", ""),
    "Bjarni Tryggvason": ("2008-06", "", "2022-04-05"),
    "Dominic Antonelli": ("2015-07-10", "2015-07-10", ""),
    "Kevin Ford": ("2014-01", "2016-01-29", ""),
    "Ronald Garan": ("2012-12", "2014", ""),
    "Douglas Hurley": ("2021-07-16", "2021-07-16", ""),
    "Terry Virts": ("2016-08-23", "2016-08-23", ""),
    "Barry Wilmore": ("2025-07-25", "2025-07-25", ""),
    "Robert Behnken": ("2022-11-11", "2022-11-11", ""),
    "Andrew Feustel": ("2023-07-31", "2023-07-31", ""),
    "Michael Good": ("2012-04", "2019-05-31", ""),
    "Timothy Kopra": ("2018-06-28", "2018-10-01", ""),
    "Megan McArthur": ("2025-08-29", "2025-08-29", ""),
    "Karen Nyberg": ("2018-10", "2020-03-31", ""),
    "Nicole Stott": ("2015-05-31", "2015-05-31", ""),
    "James Dutton": ("2012-06", "2012-06", ""),
    "Christopher Cassidy": ("2021-05-28", "2021-05-28", ""),
    "Jose Hernandez": ("2011-01-14", "2011-01-14", ""),
    "Shane Kimbrough": ("2022-07-31", "2022-07-31", ""),
    "Thomas Marshburn": ("2022-12-31", "2022-12-31", ""),
    "Robert Satcher": ("2011-09-09", "2011-09-09", ""),
    "Shannon Walker": ("2025-07-10", "2025-07-10", ""),
    "Richard Arnold": ("2020-09", "2025", ""),
    "Dorothy Metcalf-Lindenburger": ("2013-04", "2014-06-13", ""),
    "Jeanette Epps": ("2025-05-30", "2025-05-30", ""),
    "Jack Fischer": ("2018-05-31", "2018-05-31", ""),
    "Michael Hopkins": ("2023-05-01", "2023-05-01", ""),
    "Kathleen Rubins": ("2025-07-28", "2025-07-28", ""),
    "Reid Wiseman": ("2026-09-09", "2026-09-09", ""),
    "Jeremy Hansen": ("2026-09", "", ""),
    "John Casper": ("1997", "2006", ""),
    "Donald McMonagle": ("1997-07", "1997-07", ""),
    "Kenneth Cockrell": ("2006-02", "2006-02", ""),
    "Yvonne Cagle": ("2008-06", "2008-06", ""),
    "Christer Fuglesang": ("2017-04-01", "", ""),
    "Hans Schlegel": ("2011-09-01", "", ""),
    "Leopold Eyharts": ("2017-05-01", "", ""),
    "Mamoru Mohri": ("2000-12-31", "", ""),
    "Marcos Pontes": ("2019-01-01", "", ""),
    "Roberto Vittori": ("2016", "", ""),
    "Alvin Drew": ("2013-10", "", ""),
    "Serena Aunon-Chancellor": ("2019-10", "", ""),
    "Timothy Creamer": ("2011-05", "", ""),
    "Josh Cassada": ("2024-10-01", "2024-10-01", ""),
    "Victor Glover": ("2026-09-09", "2026-09-09", ""),
    "Nick Hague": ("2025-12-23", "2025-12-23", ""),
    "Andrew Morgan": ("2026-05-28", "2026-05-28", ""),
    "Jonny Kim": ("2026-08-27", "2026-08-27", ""),
    "Robb Kulin": ("2018-08-31", "2018-08-31", ""),
}

MONTH_ABBR = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]


# "1991-08-01" -> "8/1/1991", "1991-08" -> "8/1991", "1991" -> "1991".
def format_status_date(d):
    parts = d.split("-")
    if len(parts) == 3:
        return str(int(parts[1])) + "/" + str(int(parts[2])) + "/" + parts[0]
    if len(parts) == 2:
        return str(int(parts[1])) + "/" + parts[0]
    return d


# Other spellings of a profile's name in crew strings.
ASTRONAUT_ALIASES = {
    "Shane Kimbrough": ["Robert Kimbrough"],
}


# The spelling this person goes by in this crew list, or None.
def crew_name_for(name, crew):
    if name in crew:
        return name
    for alias in ASTRONAUT_ALIASES.get(name, []):
        if alias in crew:
            return alias
    return None


def astronaut_missions(name):
    found = []
    for i in range(len(ALL_MISSIONS)):
        mission = ALL_MISSIONS[i]
        who = crew_name_for(name, parse_crew(mission[7]))
        if who != None:
            # Flights this person launched on: skip landing-only entries, rides home
            # (CREW_SWAP DOWN) and missions that never launched. Sorted by launch time.
            if mission[0] in LANDING_ONLY_NAMES or mission[0] in TRIBUTE_NAMES:
                continue
            if CREW_SWAP.get(mission[0], {}).get(who, ("", ""))[0] == "DOWN":
                continue
            launch_abs, _ = mission_abs_times(mission)
            found.append((launch_abs, mission[0]))
    return [m for _, m in sorted(found)]


# Total flight time. An UP on one flight and a DOWN on a later one count
# from the UP launch to the DOWN landing; overlapping spans are merged.
# Flights still in space count up to now.
def astronaut_total_seconds(name, now_unix):
    spans = []
    for i in range(len(ALL_MISSIONS)):
        mission = ALL_MISSIONS[i]
        who = crew_name_for(name, parse_crew(mission[7]))
        if who != None:
            a, b = mission_abs_times(mission)
            if mission[0] in IN_FLIGHT_NAMES:
                b = now_unix
            if b < a:
                b = a
            tag = CREW_SWAP.get(mission[0], {}).get(who, ("", ""))[0]
            spans.append((a, b, tag))
    spans = sorted(spans)

    # Each DOWN pairs with the latest unused UP launched before the DOWN
    # vehicle landed. Flags, not -1 sentinels: pre-1970 timestamps are negative.
    ups = []
    for sp in spans:
        if sp[2] == "UP":
            ups.append(sp[0])
    used = {}
    intervals = []
    for sp in spans:
        a, b, tag = sp
        if tag == "UP":
            continue
        if tag == "DOWN":
            best = -1
            for k in range(len(ups)):
                if used.get(k) == None and ups[k] <= b and (best < 0 or ups[k] > ups[best]):
                    best = k
            if best >= 0:
                used[best] = True
                intervals.append((ups[best], b))
            else:
                intervals.append((a, b))
        else:
            intervals.append((a, b))
    intervals = sorted(intervals)

    total = 0
    has_cur = False
    cur_a = 0
    cur_b = 0
    for iv in intervals:
        a, b = iv
        if has_cur and a <= cur_b:
            if b > cur_b:
                cur_b = b
        else:
            if has_cur:
                total += cur_b - cur_a
            has_cur = True
            cur_a = a
            cur_b = b
    if has_cur:
        total += cur_b - cur_a
    return total


# MISSIONS page font ladder: (font, line pitch).
PROFILE_MISSION_LADDER = [("6x8", 10), ("5x7", 9), ("4x7", 8), ("4x5", 6)]


# Greedy line fill that treats each mission name as one unbreakable unit.
def mission_lines(c, names, font, maxw):
    lines = []
    cur = ""
    for n in names:
        trial = n if cur == "" else cur + ", " + n
        if cur != "" and c.text_width(trial, font = font) > maxw:
            lines.append(cur + ",")
            cur = n
        else:
            cur = trial
    if cur != "":
        lines.append(cur)
    return lines


# This minute's astronaut; the same on pages 5-8.
def pick_astronaut(ctx):
    idx = rotation_index(ctx, len(ASTRONAUT_NAMES))
    return ASTRONAUT_NAMES[idx]


def details1(c, ctx):
    if draw_moon_page(c, ctx, 5):
        return
    # Page 5. Empty day: Astronaut Profile card (pages 6-8 show the same
    # astronaut). Mercury/Gemini and module-less Apollo/Skylab/ASTP: launch
    # vehicle + recovery ship. Apollo 9-17: CM/LM call signs. STS-1 to STS-4:
    # backup crew.
    event = current_flight_event(ctx)
    if event == None:
        name = pick_astronaut(ctx)
        group_num, group, status = ASTRONAUT_PROFILES[name]
        accent = GROUP_COLORS[group_num]
        draw_astronaut_zone(c, accent)
        c.text("ASTRONAUT PROFILE", CX, 1, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        fitted, font = fit_text(c, name.upper(), ["6x8", "5x7", "4x5", "3x7"], CW)
        draw_text_apostrophes(c, fitted, CX, 8, font, "white")
        # Selection year set into the divider.
        sel = "SELECTED " + str(GROUP_YEARS[group_num])
        sw = c.text_width(sel, font = "4x5")
        c.line(L, 20, CX - sw // 2 - 4, 20, accent)
        c.line(CX + sw // 2 + 4, 20, R, 20, accent)
        c.text(sel, CX, 18, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        # 4x5 first; the longest nicknames fall back to 3x7.
        gfitted, gfont = fit_text(c, group, ["4x5", "3x7", "3x4"], CW)
        # Anchored to the bottom by the chosen font's height.
        gh = 7 if gfont == "3x7" else (4 if gfont == "3x4" else 5)
        c.text(gfitted, CX, 31 - gh, font = gfont, color = accent, align = "center")
        return
    if event != None:
        mission, kind = event
        name, ly, lm, ld, ny, nm, nd, crew_str = mission
        if len(parse_crew(crew_str)) <= 2:
            if draw_vehicle_ship(c, name):
                return
        if name not in MERCURY_NAMES and name not in GEMINI_NAMES and name not in ARTEMIS_NAMES and LAUNCH_VEHICLE.get(name) != None:
            modules = APOLLO_MODULE_NAMES.get(name)
            if modules != None:
                draw_module_names(c, name, modules[0], modules[1])
                return
            # Apollo 1: backup crew here; pages 6-8 hold the Grissom quote.
            if name == "APOLLO 1":
                backup_str = BACKUP_CREW.get(name)
                if backup_str != None:
                    draw_backup_crew(c, name, backup_str)
                    return
            if draw_vehicle_ship(c, name):
                return
            draw_mission_ident(c, name, flight_year(mission, kind))
            return
        if name in OFT_NAMES:
            backup_str = BACKUP_CREW.get(name)
            if backup_str != None:
                draw_backup_crew(c, name, backup_str)
            else:
                draw_fact(c, name, "ALSO NOTABLE", OFT_NO_BACKUP_FACT)
            return
        if ORBITER.get(name) != None or name in ARTEMIS_NAMES:
            draw_shuttle_crew_page(c, ctx, 1)
            return
    draw_crew_page(c, ctx, 1)


def details2(c, ctx):
    if draw_moon_page(c, ctx, 6):
        return
    # Page 6. Empty day: the profile's missions. Apollo 9-17: vehicle + ship.
    # Module-less Apollo/Skylab/ASTP: backup crew. Mercury/Gemini: orbits +
    # apogee. Shuttle: 3rd crew page, or orbits + apogee for small crews.
    # STS-1 to STS-4: OFT fact.
    event = current_flight_event(ctx)
    if event == None:
        name = pick_astronaut(ctx)
        group_num, _, _ = ASTRONAUT_PROFILES[name]
        accent = GROUP_COLORS[group_num]
        missions = astronaut_missions(name)
        draw_astronaut_zone(c, accent)
        c.text("MISSIONS (" + str(len(missions)) + ")", CX, 1, font = "4x5", color = accent, align = "center")
        if len(missions) == 0:
            # Died before their first flight.
            c.text("NEVER FLEW", CX, 15, font = "6x8", color = "white", align = "center")
        else:
            # Biggest font that fits, centered below the label; wraps on whole names.
            names = [display_name(m).upper() for m in missions]
            area_top = 8
            area_h = 26 - area_top
            font, h = PROFILE_MISSION_LADDER[len(PROFILE_MISSION_LADDER) - 1]
            lines = mission_lines(c, names, font, CW)
            for f, fh in PROFILE_MISSION_LADDER:
                ls = mission_lines(c, names, f, CW)
                if len(ls) * fh <= area_h:
                    font, h, lines = f, fh, ls
                    break
            y = area_top + (area_h - len(lines) * h) // 2
            for k in range(len(lines)):
                c.text(lines[k], CX, y + k * h, font = font, color = "white", align = "center")
            draw_flight_timeline(c, missions, accent)
        return
    if event != None:
        mission, kind = event
        name, ly, lm, ld, ny, nm, nd, crew_str = mission
        craft = PRIVATE_SPACECRAFT.get(name)
        if craft != None:
            draw_label_pairs(c, name, "SPACECRAFT", craft[0], "OPERATED BY", craft[1])
            return
        if (is_soyuz(name) or is_commercial(name)) and draw_iss_expedition(c, name, kind):
            return
        if APOLLO_MODULE_NAMES.get(name) != None:
            if draw_vehicle_ship(c, name):
                return
        elif name in ARTEMIS_NAMES:
            if draw_vehicle_ship(c, name):
                return
        elif name != "APOLLO 1" and name not in MERCURY_NAMES and name not in GEMINI_NAMES and LAUNCH_VEHICLE.get(name) != None:
            backup_str = BACKUP_CREW.get(name)
            if backup_str != None:
                draw_backup_crew(c, name, backup_str)
                return
        orbits = MERCURY_GEMINI_ORBITS.get(name)
        apogee = MERCURY_GEMINI_APOGEE.get(name)
        if orbits != None and apogee != None:
            draw_two_facts_lr(c, name, "ORBITS", orbits, "APOGEE", apogee)
            return
        if name in OFT_NAMES:
            draw_oft_facts(c, name)
            return
        if ORBITER.get(name) != None or name in ARTEMIS_NAMES:
            if draw_shuttle_crew_page(c, ctx, 2):
                return
            # Small crew: orbits + apogee move up from page 7.
            orbits = SHUTTLE_ORBITS.get(name)
            apogee = SHUTTLE_APOGEE.get(name)
            if orbits != None and apogee != None:
                draw_two_facts_lr(c, name, "ORBITS", orbits, "APOGEE", apogee)
                return
        quote = MEMORIAL_QUOTE.get(name, {}).get(6)
        if quote != None:
            draw_quote_page(c, name, quote)
            return
    draw_crew_page(c, ctx, 2)


def details3(c, ctx):
    if draw_moon_page(c, ctx, 7):
        return
    # Page 7. Empty day: the profile's status. Mercury/Gemini and Apollo 9-17:
    # backup crew. Module-less Apollo/Skylab/ASTP: orbits + apogee. Shuttle:
    # orbits + apogee (big crew) or NOTABLE_FIRST (small crew).
    event = current_flight_event(ctx)
    if event == None:
        name = pick_astronaut(ctx)
        draw_astronaut_status(c, name)
        return
    if event != None:
        mission, kind = event
        name = mission[0]
        if (is_soyuz(name) or is_commercial(name)) and draw_iss_dock(c, name, kind):
            return
        if name in MERCURY_NAMES or name in GEMINI_NAMES:
            backup_str = BACKUP_CREW.get(name)
            if backup_str != None:
                draw_backup_crew(c, name, backup_str)
                return
        elif APOLLO_MODULE_NAMES.get(name) != None:
            backup_str = BACKUP_CREW.get(name)
            if backup_str != None:
                draw_backup_crew(c, name, backup_str)
                return
        elif ORBITER.get(name) != None and (name in OFT_NAMES or shuttle_crew_reaches_page6(mission, kind)):
            # OFT missions keep orbits + apogee here.
            orbits = SHUTTLE_ORBITS.get(name)
            apogee = SHUTTLE_APOGEE.get(name)
            # STS-107: on its loss day the memorial quote takes this page.
            has_land_quote = kind == "LAND" and MEMORIAL_QUOTE.get(name, {}).get(7) != None
            if orbits != None and apogee != None and not has_land_quote:
                draw_two_facts_lr(c, name, "ORBITS", orbits, "APOGEE", apogee)
                return
        elif ORBITER.get(name) != None:
            # Small crew: NOTABLE_FIRST moves down from page 8.
            first = NOTABLE_FIRST.get(name)
            if first != None:
                draw_fact(c, name, "NOTABLE FIRST", first)
                return
        pair = MODULELESS_ORBIT_PAIR.get(name)
        if pair != None:
            label1, value1, label2, value2 = pair
            draw_two_facts_lr(c, name, label1, value1, label2, value2)
            return
        # STS-107's quote shows on its loss day only.
        quote = MEMORIAL_QUOTE.get(name, {}).get(7)
        if quote != None and (kind == "LAND" or name != "STS-107"):
            draw_quote_page(c, name, quote)
            return
        draw_mission_ident(c, name, flight_year(mission, kind))
        return


# Launch-to-landing time for one crew member; a ride home (CREW_SWAP DOWN)
# counts from the flight they launched on.
def trip_seconds(mission, who):
    launch_abs, land_abs = mission_abs_times(mission)
    if CREW_SWAP.get(mission[0], {}).get(who, ("", ""))[0] == "DOWN":
        best = None
        for m in ALL_MISSIONS:
            if who in parse_crew(m[7]) and CREW_SWAP.get(m[0], {}).get(who, ("", ""))[0] == "UP":
                a, _ = mission_abs_times(m)
                if a <= land_abs and (best == None or a > best):
                    best = a
        if best != None:
            launch_abs = best
    return land_abs - launch_abs


def details4(c, ctx):
    if draw_moon_page(c, ctx, 8):
        return
    # Page 8. Empty day: the profile's flight time. Otherwise NOTABLE_FIRST
    # (or NOTABLE_SECOND for small Shuttle crews), then ORBIT_FACT.
    event = current_flight_event(ctx)
    if event == None:
        name = pick_astronaut(ctx)
        group_num, _, _ = ASTRONAUT_PROFILES[name]
        total = astronaut_total_seconds(name, ctx.now.unix)
        draw_astronaut_zone(c, GROUP_COLORS[group_num])
        c.text("FLIGHT TIME", CX, 2, font = "4x5", color = GROUP_COLORS[group_num], align = "center")
        if len(astronaut_missions(name)) == 0:
            c.text("NEVER FLEW", CX, 15, font = "6x8", color = "#c3c6ca", align = "center")
        else:
            draw_duration(c, CX, 10, total, "amber", num_font = "10x14", num_h = 14)
        return
    if event != None:
        mission, kind = event
        name = mission[0]
        # STS-107: on its loss day the memorial quote takes this page.
        has_land_quote = kind == "LAND" and MEMORIAL_QUOTE.get(name, {}).get(8) != None
        # OFT missions aren't part of the small-crew shuffle.
        if ORBITER.get(name) != None and name not in OFT_NAMES and not shuttle_crew_reaches_page6(mission, kind):
            second = NOTABLE_SECOND.get(name)
            if second != None and not has_land_quote:
                draw_fact(c, name, "ALSO NOTABLE", second)
                return
        else:
            first = NOTABLE_FIRST.get(name)
            if first != None and not has_land_quote and not (kind == "LAND" and name in NOTABLE_LAUNCH_ONLY):
                second = NOTABLE_FIRST_2.get(name)
                if second != None:
                    draw_two_facts_stacked(c, name, "NOTABLE FIRST", first, "ALSO NOTABLE", second)
                else:
                    draw_fact(c, name, "NOTABLE FIRST", first)
                return
            fact = ORBIT_FACT.get(name)
            if fact != None:
                label, value = fact
                draw_fact(c, name, label, value)
                return
        # Soyuz landings whose notable is launch-only: each American's time in space.
        if kind == "LAND" and name in NOTABLE_LAUNCH_ONLY:
            draw_land_flight_times(c, mission)
            return
        # STS-107's quote shows on its loss day only.
        quote = MEMORIAL_QUOTE.get(name, {}).get(8)
        if quote != None and (kind == "LAND" or name != "STS-107"):
            draw_quote_page(c, name, quote)
            return
        draw_mission_ident(c, name, flight_year(mission, kind))
        return


# ------------------------------------------------- 192-wide overrides ----

# The wider regular 5x5 face (same 5px capitals as 4x5) goes ahead of 4x5
# whenever the text only uses characters it can draw.
WIDE_OK = " $%+-.:ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

def wide_ok(text):
    for i in range(len(text)):
        if WIDE_OK.find(text[i]) < 0:
            return False
    return True

def fit_text(c, text, fonts, maxw):
    if maxw < 4:
        return "", fonts[len(fonts) - 1]
    if "4x5" in fonts and "5x5" not in fonts and wide_ok(text):
        k = fonts.index("4x5")
        fonts = fonts[:k] + ["5x5"] + fonts[k:]
    for i in range(len(fonts)):
        f = fonts[i]
        if c.text_width(text, font = f) <= maxw:
            return text, f
    f = fonts[len(fonts) - 1]
    for i in range(len(text), 0, -1):
        t = text[:i] + ".."
        if c.text_width(t, font = f) <= maxw:
            return t, f
    return "", f

# "#rrggbb" scaled to pct percent brightness.
def dim_hex(col, pct):
    r = int(col[1:3], 16) * pct // 100
    g = int(col[3:5], 16) * pct // 100
    b = int(col[5:7], 16) * pct // 100
    digits = "0123456789abcdef"
    out = "#"
    for v in [r, g, b]:
        out += digits[v // 16] + digits[v % 16]
    return out

# Every event page: black ground, the mission's spacecraft in the left
# zone and a rail in its program color. Returns True so the old
# "if not draw_patch_background(...)" fallbacks stay valid.
def draw_patch_background(c, name, craft = None):
    c.fill("#000000")
    draw_craft_zone(c, craft if craft != None else craft_for(name), program_color(name))
    return True

# Pages with nothing else to say about a mission: its name big, the
# program (and orbiter) under it.
def draw_mission_ident(c, name, year):
    draw_patch_background(c, name)
    shown, font = fit_text(c, display_name(name).upper(), ["10x14", "6x8", "5x7"], CW)
    h = FONT_HEIGHTS.get(font, 14 if font == "10x14" else 8)
    sub = PROGRAM_LABEL[craft_for(name)]
    orbiter = ORBITER.get(name)
    if orbiter != None:
        sub = orbiter.upper()
    sub = sub + "  " + str(year)
    sub, sf = fit_text(c, sub, ["5x7", "4x5"], CW)
    top = (32 - (h + 3 + 7)) // 2
    c.text(shown, CX, top, font = font, color = "white", align = "center")
    c.text(sub, CX, top + h + 3, font = sf, color = program_color(name), align = "center")

# Crew role codes spelled out (the codes still drive sorting everywhere else).
ROLE_NAMES = {
    "CDR": "COMMANDER", "PLT": "PILOT", "CP": "COMMAND PILOT", "SP": "SENIOR PILOT",
    "CMP": "COMMAND MODULE PILOT", "LMP": "LUNAR MODULE PILOT", "SPT": "SCIENCE PILOT",
    "DMP": "DOCKING MODULE PILOT", "MS": "MISSION SPECIALIST", "MS1": "MISSION SPECIALIST 1",
    "MS2": "MISSION SPECIALIST 2", "MS3": "MISSION SPECIALIST 3", "MS4": "MISSION SPECIALIST 4",
    "MS5": "MISSION SPECIALIST 5", "PS": "PAYLOAD SPECIALIST", "PS1": "PAYLOAD SPECIALIST 1",
    "PS2": "PAYLOAD SPECIALIST 2", "PS3": "PAYLOAD SPECIALIST 3", "PC": "PAYLOAD COMMANDER",
    "MSE": "SPACEFLIGHT ENGINEER", "FE": "FLIGHT ENGINEER", "RC": "RESEARCH COSMONAUT",
    "JOC": "JOINT OPERATIONS COMMANDER", "MO": "MEDICAL OFFICER",
}
TAG_NAMES = {"BU": "BACKUP"}

# Width of a role/tag pair as drawn ("ROLE - TAG").
def role_tag_width(c, role, tag):
    t = role + (" - " if role != "" and tag != "" else "") + tag
    return c.text_width(t, font = "4x5") if t != "" else 0

# flights they launched on, e.g. a ride home).
def flight_label(person, mission_name):
    if mission_name == "":
        return ""
    ms = astronaut_missions(person)
    for k in range(len(ms)):
        if ms[k] == mission_name:
            return "1ST FLIGHT" if k == 0 else ordinal(k + 1) + " FLIGHT"
    return ""

# Shorter spelled-out roles for crew rows that can't fit the full title.
ROLE_MID_SWAPS = [("MISSION SPECIALIST", "SPECIALIST"), ("PAYLOAD SPECIALIST", "PAYLOAD SPEC"),
                  ("COMMAND MODULE", "CM"), ("LUNAR MODULE", "LM"), ("DOCKING MODULE", "DM"),
                  ("JOINT OPERATIONS COMMANDER", "JOINT OPS CDR"), ("SPACEFLIGHT ENGINEER", "SPACEFLT ENGINEER"),
                  ("RESEARCH COSMONAUT", "RESEARCHER"), ("PAYLOAD COMMANDER", "PAYLOAD CDR")]

def role_mid(role):
    t = ROLE_NAMES.get(role, role)
    for a, b in ROLE_MID_SWAPS:
        t = t.replace(a, b)
    return t

# The role form every row on a page can share, so one page never mixes
# "MISSION SPECIALIST 2" with "MS1": 0 = full, 1 = shortened, 2 = codes.
def crew_rows_tier(c, rows):
    for tier in [0, 1]:
        fits = True
        for name, role, tag in rows:
            r = ROLE_NAMES.get(role, role) if tier == 0 else role_mid(role)
            # 4x5 is the narrowest face draw_crew_row will step down to.
            if c.text_width(name.upper(), font = "4x5") + 6 + role_tag_width(c, r, TAG_NAMES.get(tag, tag)) > CW:
                fits = False
        if fits:
            return tier
    return 2

# Compact crew row (three to a page): name left, role spelled out on the
# right. The name drops to the narrower face before the role falls back to
# its short code.
def draw_crew_row(c, y, name, role, tag, tier = 0):
    display_name = name.upper()
    full_role = ROLE_NAMES.get(role, role)
    full_tag = TAG_NAMES.get(tag, tag)
    fonts = ["5x5", "4x5"] if wide_ok(display_name) else ["4x5"]
    choice = None
    forms = [(role, full_tag), (role, tag)]
    if tier == 0:
        forms = [(full_role, full_tag)] + forms
    elif tier == 1:
        forms = [(role_mid(role), full_tag)] + forms
    for r, t in forms:
        for nf in fonts:
            if c.text_width(display_name, font = nf) + 6 + role_tag_width(c, r, t) <= CW:
                choice = (r, t, nf)
                break
        if choice != None:
            break
    if choice == None:
        nf = "4x5"
        budget = CW - role_tag_width(c, role, tag) - 4
        abbreviated = abbreviate_first_name(display_name)
        if c.text_width(abbreviated, font = "4x5") <= budget:
            display_name = abbreviated
        else:
            display_name, _ = fit_text(c, abbreviated, ["4x5"], budget)
        choice = (role, tag, nf)
    r, t, nf = choice
    draw_outlined_text(c, display_name, L, y, nf, "white", align = "left")
    x = R - role_tag_width(c, r, t)
    if r != "":
        draw_outlined_text(c, r, x, y, "4x5", "amber", align = "left")
        x += c.text_width(r, font = "4x5")
    if t != "":
        piece = (" - " + t) if r != "" else t
        draw_outlined_text(c, piece, x, y, "4x5", STATION_TAG_COLOR, align = "left")

# Backup crew page. Two or fewer: stacked, tagged BACKUP. Three: a BACKUP
# CREW title and untagged rows, so every role can be spelled out.
def draw_backup_crew(c, mission_name, backup_str):
    if not draw_patch_background(c, mission_name):
        c.fill("#000000")
    names = parse_crew(backup_str)
    n = len(names)
    if n <= 2:
        block_h = 32 // n
        for i in range(n):
            draw_crew_member(c, i * block_h, block_h, names[i], crew_role(mission_name, names, i), "BACKUP")
        return
    draw_outlined_text(c, "BACKUP CREW", CX, 1, "4x5", STATION_TAG_COLOR, align = "center")
    rows = [(names[i], crew_role(mission_name, names, i), "") for i in range(n)]
    tier = crew_rows_tier(c, rows)
    for i in range(n):
        draw_crew_row(c, 9 + i * 8, names[i], rows[i][1], "", tier)

# Stacked crew member: big name, then the role (+ tag) spelled out.
def draw_crew_member(c, y_top, block_h, full_name, role, tag):
    fitted, font = fit_text(c, full_name.upper(), ["5x7", "4x5"], CW)
    name_h = 7 if font == "5x7" else 6
    role_h = 6
    gap = 2
    start_y = y_top + (block_h - (name_h + gap + role_h)) // 2
    draw_outlined_text(c, fitted, CX, start_y, font, "white", align = "center")
    role_y = start_y + name_h + gap
    pieces = []
    for r, t in [(ROLE_NAMES.get(role, role), TAG_NAMES.get(tag, tag)), (role, tag)]:
        pieces = []
        if r != "":
            pieces.append((r, "amber"))
        if t != "":
            pieces.append(((" - " if r != "" else "") + t, STATION_TAG_COLOR))
        w = 0
        for piece_text, _ in pieces:
            w += c.text_width(piece_text, font = "4x5")
        if w <= CW:
            break
    if len(pieces) == 0:
        return
    total_w = 0
    for t, _ in pieces:
        total_w += c.text_width(t, font = "4x5")
    x = CX - total_w // 2
    for t, col in pieces:
        draw_outlined_text(c, t, x, role_y, "4x5", col, align = "left")
        x += c.text_width(t, font = "4x5")

# A moonwalker's full name from the mission's crew list ("ALDRIN" -> "BUZZ ALDRIN").
def moonwalker_name(mission, surname):
    for p in parse_crew(mission[7]):
        parts = p.upper().split(" ")
        if parts[len(parts) - 1] == surname:
            return p.upper()
    return surname

# Career strip under the mission list: 1959-2026, one mark per flight year.
def draw_flight_timeline(c, missions, accent):
    y = 28
    x0 = L + 19
    x1 = R - 19
    c.text("1959", L, y - 1, font = "picopixel", color = "#6a6f78", align = "left")
    c.text("2026", R, y - 1, font = "picopixel", color = "#6a6f78", align = "right")
    c.rect(x0, y + 1, x1, y + 1, fill = "#2a2e36")
    years = {}
    for m in ALL_MISSIONS:
        if m[0] in missions:
            years[m[1]] = 1
    for yr in years:
        x = x0 + (yr - 1959) * (x1 - x0) // (2026 - 1959)
        c.rect(x - 1, y, x + 1, y + 2, fill = accent)

# STATUS page: each label/date pair sits together in the middle.
def draw_astronaut_status(c, name):
    group_num, _, status = ASTRONAUT_PROFILES[name]
    corps, nasa, died = ASTRONAUT_DATES.get(name, ("", "", ""))
    draw_astronaut_zone(c, GROUP_COLORS[group_num])
    if status == "ACTIVE":
        c.text("STATUS", CX, 1, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        c.text("ACTIVE", CX, 14, font = "6x8", color = "#3ee08f", align = "center")
        return
    if status == "DECEASED":
        c.text("STATUS", CX, 1, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        c.text("DECEASED", CX, 10, font = "6x8", color = "#c3c6ca", align = "center")
        if died != "":
            c.text(format_status_date(died), CX, 22, font = "5x7", color = "white", align = "center")
        return
    rows = []
    if status == "DISMISSED":
        rows.append(("DISMISSED", corps, "#ffbe4d"))
    elif nasa != "" and nasa == corps:
        rows.append(("RETIRED", corps, "#5aaeff"))
    else:
        rows.append(("LEFT CORPS", corps, "#5aaeff"))
        if nasa != "":
            rows.append(("LEFT NASA", nasa, "#b4d4ff"))
    if "DECEASED" in status:
        rows.append(("DIED", died, "#c3c6ca"))
    if len(rows) < 3:
        c.text("STATUS", CX, 1, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
    top = 2 if len(rows) == 3 else (10 if len(rows) == 2 else 14)
    step = 11 if len(rows) == 3 else 10
    for i in range(len(rows)):
        label, date, color = rows[i]
        y = top + i * step
        c.text(label, CX - 4, y, font = "5x7", color = color, align = "right")
        c.text(format_status_date(date) if date != "" else "UNKNOWN", CX + 4, y, font = "5x7", color = "white" if date != "" else "#888888", align = "left")


# ------------------------------------------ orbit inclination (192) ----

# Orbital inclination in degrees, from each mission's Wikipedia infobox.
# Missions without one (suborbital hops, etc.) keep the two-number page.
INCLINATION = {
    "APOLLO 7": "31.6",
    "APOLLO 8": "32.1",
    "APOLLO-SOYUZ": "51.8",
    "ARTEMIS II": "28.5",
    "AURORA 7": "32.5",
    "FAITH 7": "32.5",
    "FRIENDSHIP 7": "32.5",
    "GEMINI 10": "28.8",
    "GEMINI 11": "28.8",
    "GEMINI 12": "28.8",
    "GEMINI 3": "32.6",
    "GEMINI 4": "32.5",
    "GEMINI 5": "32.5",
    "GEMINI 6": "28.9",
    "GEMINI 7": "28.9",
    "GEMINI 8": "28.9",
    "GEMINI 9A": "28.8",
    "SIGMA 7": "32.5",
    "SKYLAB 2": "50.0",
    "SKYLAB 3": "50.0",
    "SKYLAB 4": "50.0",
    "STS-1": "40.3",
    "STS-100": "51.5",
    "STS-101": "51.5",
    "STS-102": "51.5",
    "STS-103": "28.4",
    "STS-104": "51.6",
    "STS-105": "51.6",
    "STS-106": "51.6",
    "STS-107": "39.0",
    "STS-108": "51.6",
    "STS-109": "28.5",
    "STS-110": "51.6",
    "STS-111": "51.6",
    "STS-112": "51.6",
    "STS-113": "51.6",
    "STS-114": "51.6",
    "STS-115": "51.6",
    "STS-116": "51.6",
    "STS-117": "51.6",
    "STS-118": "51.6",
    "STS-119": "51.6",
    "STS-120": "51.6",
    "STS-121": "51.6",
    "STS-122": "51.6",
    "STS-123": "51.6",
    "STS-124": "51.6",
    "STS-125": "28.5",
    "STS-126": "51.6",
    "STS-127": "51.6",
    "STS-128": "51.6",
    "STS-129": "51.6",
    "STS-130": "51.6",
    "STS-131": "51.6",
    "STS-132": "51.6",
    "STS-133": "51.6",
    "STS-134": "51.6",
    "STS-135": "51.6",
    "STS-2": "38.0",
    "STS-26": "28.4",
    "STS-27": "57.0",
    "STS-28": "57.0",
    "STS-29": "28.4",
    "STS-3": "38.0",
    "STS-30": "28.4",
    "STS-31": "28.4",
    "STS-32": "28.4",
    "STS-33": "28.4",
    "STS-34": "34.3",
    "STS-35": "28.5",
    "STS-36": "62.0",
    "STS-37": "28.4",
    "STS-38": "28.4",
    "STS-39": "57.0",
    "STS-4": "28.5",
    "STS-40": "39.0",
    "STS-41": "28.4",
    "STS-41-B": "28.5",
    "STS-41-C": "28.5",
    "STS-41-D": "28.5",
    "STS-41-G": "57.0",
    "STS-42": "57.0",
    "STS-43": "28.5",
    "STS-44": "28.4",
    "STS-45": "57.0",
    "STS-46": "28.5",
    "STS-47": "57.0",
    "STS-48": "57.0",
    "STS-49": "28.3",
    "STS-5": "28.5",
    "STS-50": "28.5",
    "STS-51": "28.4",
    "STS-51-A": "28.4",
    "STS-51-B": "57.0",
    "STS-51-C": "28.4",
    "STS-51-D": "28.4",
    "STS-51-F": "49.5",
    "STS-51-G": "28.4",
    "STS-51-I": "28.4",
    "STS-51-J": "28.5",
    "STS-52": "28.4",
    "STS-53": "57.0",
    "STS-54": "28.4",
    "STS-55": "28.4",
    "STS-56": "57.0",
    "STS-57": "28.4",
    "STS-58": "39.0",
    "STS-59": "57.0",
    "STS-6": "28.5",
    "STS-60": "56.4",
    "STS-61": "28.4",
    "STS-61-A": "57.0",
    "STS-61-B": "28.4",
    "STS-61-C": "28.4",
    "STS-62": "39.0",
    "STS-63": "51.6",
    "STS-64": "56.9",
    "STS-65": "28.4",
    "STS-66": "57.0",
    "STS-67": "28.4",
    "STS-68": "57.0",
    "STS-69": "28.4",
    "STS-7": "28.3",
    "STS-70": "28.4",
    "STS-71": "51.6",
    "STS-72": "28.4",
    "STS-73": "39.0",
    "STS-74": "51.6",
    "STS-75": "28.4",
    "STS-76": "51.6",
    "STS-77": "39.0",
    "STS-78": "39.0",
    "STS-79": "51.6",
    "STS-8": "28.5",
    "STS-80": "28.4",
    "STS-81": "51.6",
    "STS-82": "28.5",
    "STS-83": "28.4",
    "STS-84": "51.7",
    "STS-85": "57.0",
    "STS-86": "51.6",
    "STS-87": "28.4",
    "STS-88": "51.6",
    "STS-89": "51.6",
    "STS-9": "57.0",
    "STS-90": "39.0",
    "STS-91": "51.7",
    "STS-92": "51.6",
    "STS-93": "28.4",
    "STS-94": "28.4",
    "STS-95": "28.4",
    "STS-96": "51.6",
    "STS-97": "51.6",
    "STS-98": "51.6",
    "STS-99": "57.0",
}

# A big amber value centered at cx (smaller white type when it won't fit).
def draw_big_value_w(c, cx, y, value, maxw):
    parts = value.split(" ")
    num = parts[0]
    unit = " ".join(parts[1:])
    nw = c.text_width(num, font = "10x14")
    uw = c.text_width(unit, font = "4x5") if unit != "" else 0
    total = nw + (2 + uw if unit != "" else 0)
    if total > maxw:
        w = c.text_width(value, font = "6x8")
        draw_outlined_text(c, value, cx - w // 2, y + 4, "6x8", "white", align = "left")
        return
    x = cx - total // 2
    draw_outlined_text(c, num, x, y, "10x14", "amber", align = "left")
    if unit != "":
        draw_outlined_text(c, unit, x + nw + 2, y + 8, "4x5", "amber", align = "left")

# "51.6" drawn big with a hand-made decimal point and degree ring (10x14 has
# neither glyph), centered at cx.
def draw_degrees(c, cx, y, value):
    whole, tenths = value.split(".")
    ww = c.text_width(whole, font = "10x14")
    tw = c.text_width(tenths, font = "10x14")
    total = ww + 6 + tw + 6
    x = cx - total // 2
    draw_outlined_text(c, whole, x, y, "10x14", "amber", align = "left")
    dx = x + ww + 2
    c.rect(dx - 1, y + 11, dx + 2, y + 14, fill = "#000000")
    c.rect(dx, y + 12, dx + 1, y + 13, fill = "amber")
    tx = dx + 4
    draw_outlined_text(c, tenths, tx, y, "10x14", "amber", align = "left")
    rx = tx + tw + 2
    c.rect(rx - 1, y - 1, rx + 3, y + 3, fill = "#000000")
    c.rect(rx, y, rx + 2, y + 2, fill = "amber")
    c.pixel(rx + 1, y + 1, "#000000")

# Orbit facts: two side by side, or three with the orbit's inclination when
# the mission has one (Earth orbits only - lunar pages keep their pair).
def draw_two_facts_lr(c, name, label1, value1, label2, value2):
    if not draw_patch_background(c, name):
        c.fill("#000000")
    inc = INCLINATION.get(name) if label1 == "ORBITS" else None
    if inc == None:
        draw_outlined_text(c, label1, L + CW // 4, 3, "4x5", PATCH_LABEL_COLOR, align = "center")
        draw_big_value_w(c, L + CW // 4, 12, value1, CW // 2 - 4)
        draw_outlined_text(c, label2, L + 3 * CW // 4, 3, "4x5", PATCH_LABEL_COLOR, align = "center")
        draw_big_value_w(c, L + 3 * CW // 4, 12, value2, CW // 2 - 4)
        return
    draw_outlined_text(c, label1, L + CW // 6, 3, "4x5", PATCH_LABEL_COLOR, align = "center")
    draw_big_value_w(c, L + CW // 6, 12, value1, CW // 3 - 2)
    draw_outlined_text(c, label2, CX, 3, "4x5", PATCH_LABEL_COLOR, align = "center")
    draw_big_value_w(c, CX, 12, value2, CW // 3 - 2)
    draw_outlined_text(c, "INCLINATION", L + 5 * CW // 6, 3, "4x5", PATCH_LABEL_COLOR, align = "center")
    draw_degrees(c, L + 5 * CW // 6, 12, inc)


# ------------------------------------------ page 2 + duration (192) ----

# Duration units spelled out ("12 DAYS 21 HRS 20 MIN 5 SEC"); the single
# letters are kept as a fallback if a duration ever won't fit.
def duration_groups_words(total_seconds):
    groups = duration_groups(total_seconds)
    out = []
    for num, letter in groups:
        one = num == "1"
        if letter == "D":
            out.append((num, "DAY" if one else "DAYS"))
        elif letter == "H":
            out.append((num, "HR" if one else "HRS"))
        elif letter == "M":
            out.append((num, "MIN"))
        else:
            out.append((num, "SEC"))
    return out

def draw_duration(c, cx, y, total_seconds, color, num_font = "6x8", num_h = 8):
    label_font = "5x7"
    label_h = 7
    groups = None
    total_w = 0
    gap = 4
    label_gap = 2
    # Letters at a normal gap beat words squeezed together: "42DAYS0HRS"
    # at a 2px gap read as one word in the 150px content zone.
    words = duration_groups_words(total_seconds)
    letters = duration_groups(total_seconds)
    for gs, g, lg in [(words, 6, 2), (words, 4, 2), (letters, 6, 2), (letters, 4, 2), (letters, 2, 1)]:
        total_w = duration_width(c, gs, num_font, label_font, g, lg)
        if total_w <= CW:
            groups, gap, label_gap = gs, g, lg
            break
    if groups == None:
        groups = duration_groups(total_seconds)
        gap, label_gap = 1, 1
        total_w = duration_width(c, groups, num_font, label_font, gap, label_gap)
    x = cx - total_w // 2
    label_y = y + (num_h - label_h)
    for i in range(len(groups)):
        num_text, word = groups[i]
        draw_outlined_text(c, num_text, x, y, num_font, color, align = "left")
        x += c.text_width(num_text, font = num_font)
        x += label_gap
        draw_outlined_text(c, word, x, label_y, label_font, color, align = "left")
        x += c.text_width(word, font = label_font)
        if i < len(groups) - 1:
            x += gap

# The page-2 sentence as three centered lines: what happened / where (gold)
# / pad or runway and the local time.
def flight_lines(mission, kind):
    name, ly, lm, ld, ny, nm, nd, crew = mission
    times = MISSION_TIMES.get(name, (0, 0, 0, 0, 0, 0))
    if kind == "LAUNCH":
        _, _, _, local_h, local_m, abbr = utc_to_local(ly, lm, ld, times[0], times[1], launch_zone_for(name))
        clock = format_clock(local_h, local_m, times[2]) + " " + abbr
        site = launch_site_for(name)
        pad = LAUNCH_PAD.get(name)
        where = ""
        if pad != None:
            where = ("SPACE LAUNCH COMPLEX " + pad[4:]) if pad.startswith("SLC-") else ("PAD " + pad)
        lead = "LAUNCHED FROM THE" if site == "KENNEDY SPACE CENTER" else "LAUNCHED FROM"
        return lead, site, (where + " AT " + clock) if where != "" else "AT " + clock
    if kind == "MOONLAND":
        moon_y, moon_mo, moon_dy, moon_h, moon_min, moon_sec = MOON_LANDING_TIME[name]
        _, _, _, local_h, local_m, abbr = utc_to_local(moon_y, moon_mo, moon_dy, moon_h, moon_min, "CENTRAL")
        lm_name = APOLLO_MODULE_NAMES.get(name, (None, "LUNAR MODULE"))[1]
        site = MOON_LANDING_SITE.get(name, "THE MOON")
        return lm_name + " LANDED ON THE MOON IN", site, "AT " + format_clock(local_h, local_m, moon_sec) + " " + abbr
    nh, nmin, nsec = times[3], times[4], times[5]
    if END_LABEL_OVERRIDE.get(name, "LANDED") == "LOST":
        _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, "EASTERN")
        return "LOST DURING", LOST_PHASE.get(name, "FLIGHT"), "AT " + format_clock(local_h, local_m, nsec) + " " + abbr
    if is_soyuz(name):
        _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, "MSK")
        lead = "LAUNCH ABORTED - LANDED IN" if name in ABORTED_NAMES else "LANDED IN"
        return lead, "KAZAKHSTAN", "AT " + format_clock(local_h, local_m, nsec) + " " + abbr
    if ORBITER.get(name) != None:
        bucket = SHUTTLE_LANDING_SITE.get(name, "KSC")
        site_name, zone = LANDING_SITE_INFO[bucket]
        runway = LANDING_RUNWAY.get(name)
        _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, zone)
        clock = format_clock(local_h, local_m, nsec) + " " + abbr
        lead = "LANDED AT THE" if site_name == "KENNEDY SPACE CENTER" else "LANDED AT"
        return lead, site_name, ("RUNWAY " + runway + " AT " + clock) if runway != None else "AT " + clock
    ocean_name, zone = OCEAN_INFO[SPLASHDOWN_OCEAN.get(name, "ATLANTIC")]
    _, _, _, local_h, local_m, abbr = utc_to_local(ny, nm, nd, nh, nmin, zone)
    return "SPLASHED DOWN IN", ocean_name, "AT " + format_clock(local_h, local_m, nsec) + " " + abbr

def flight(c, ctx):
    events = find_flight_events(ctx.now.month, ctx.now.day)
    if len(events) == 0:
        draw_no_events_zone(c)
        months = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
        c.text("ON THIS DATE", CX, 2, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        c.text(months[ctx.now.month - 1] + " " + str(ctx.now.day), CX, 10, font = "6x8", color = "white", align = "center")
        c.text("NO US LAUNCHES OR LANDINGS", CX, 23, font = "4x5", color = PATCH_LABEL_COLOR, align = "center")
        return
    mission, kind = events[rotation_index(ctx, len(events))]
    name = mission[0]
    draw_patch_background(c, name, "LM" if kind == "MOONLAND" else None)
    draw_outlined_text(c, display_name(name).upper(), L, 1, "4x5", "white", align = "left")
    orbiter = ORBITER.get(name)
    if orbiter != None:
        draw_outlined_text(c, orbiter.upper(), CX, 1, "4x5", "white", align = "center")
    draw_outlined_text(c, str(flight_year(mission, kind)), R, 1, "4x5", "white", align = "right")
    land_m, land_d = local_land_date(mission)
    lost = END_LABEL_OVERRIDE.get(name) == "LOST" and land_m == ctx.now.month and land_d == ctx.now.day
    text_color = LOST_COLOR if lost else "white"
    lead, place, detail = flight_lines(mission, kind)
    # One size for the two outer lines so they read as a pair.
    side_font = "4x5"
    for f in ["5x7", "4x5"]:
        if c.text_width(lead, font = f) <= CW and c.text_width(detail, font = f) <= CW:
            side_font = f
            break
    rows = [(lead, side_font, text_color), (place, "", LOST_COLOR if lost else "amber"), (detail, side_font, text_color)]
    # Rows at 8/16/24: a 7px face on the last row ends at y30, off the edge.
    y = 8
    for text, f, col in rows:
        if f == "":
            text, f = fit_text(c, text, ["5x7", "4x5", "picopixel"], CW)
        elif c.text_width(text, font = f) > CW:
            text, f = fit_text(c, text, [f, "picopixel"], CW)
        draw_outlined_text(c, text, CX, y, f, col, align = "center")
        y += 8

# Days and hours in words, right-aligned ("12 DAYS 5 HRS").
def draw_dh_right(c, right_x, y, secs):
    d = secs // 86400
    h = (secs % 86400) // 3600
    parts = [(str(d), "DAY" if d == 1 else "DAYS"), (str(h), "HR" if h == 1 else "HRS")]
    w = duration_width(c, parts, "6x8", "5x7", 4, 2)
    x = right_x - w
    for i in range(len(parts)):
        num, word = parts[i]
        draw_outlined_text(c, num, x, y, "6x8", "amber", align = "left")
        x += c.text_width(num, font = "6x8") + 2
        draw_outlined_text(c, word, x, y + 1, "5x7", "amber", align = "left")
        x += c.text_width(word, font = "5x7") + 4

# Landing-day TIME IN SPACE: full names when they fit beside the time.
def draw_land_flight_times(c, mission):
    if not draw_patch_background(c, mission[0]):
        c.fill("#000000")
    people = [r[0] for r in build_applicable_roster(mission, "LAND") if r[0] in ASTRONAUT_PROFILES]
    draw_outlined_text(c, "TIME IN SPACE", CX, 1, "4x5", PATCH_LABEL_COLOR, align = "center")
    if len(people) == 1:
        draw_outlined_text(c, people[0].upper(), CX, 10, "5x7", "white", align = "center")
        draw_duration(c, CX, 21, trip_seconds(mission, people[0]), "amber")
        return
    for i in range(len(people)):
        y = 10 + i * 11
        full = people[i].upper()
        room = CW - 92
        shown, f = fit_text(c, full, ["6x8", "5x7"], room)
        if shown.endswith(".."):
            shown, f = fit_text(c, full.split(" ")[-1], ["6x8", "5x7"], room)
        draw_outlined_text(c, shown, L, y + (1 if f == "5x7" else 0), f, "white", align = "left")
        draw_dh_right(c, R, y, trip_seconds(mission, people[i]))


# ----------------------------------------- side-by-side fact pairs (192) ----

# Greedy word wrap into lines no wider than w.
def wrap_words(c, text, font, w):
    lines = []
    cur = ""
    for word in text.split(" "):
        trial = word if cur == "" else cur + " " + word
        if cur != "" and c.text_width(trial, font = font) > w:
            lines.append(cur)
            cur = word
        else:
            cur = trial
    if cur != "":
        lines.append(cur)
    return lines

# Two label/value facts side by side, each in its own half. Both values use
# the biggest font that fits them in at most two lines.
def draw_side_by_side(c, name, label1, value1, label2, value2):
    if not draw_patch_background(c, name):
        c.fill("#000000")
    values = [value1.upper(), value2.upper()]
    font = "4x5"
    for f in ["6x8", "5x7", "4x5"]:
        ok = True
        for v in values:
            ls = wrap_words(c, v, f, HALF_W)
            if len(ls) > 2:
                ok = False
            for l in ls:
                if c.text_width(l, font = f) > HALF_W:
                    ok = False
        if ok:
            font = f
            break
    h = FONT_HEIGHTS.get(font, 7)
    for cx, label, v in [(L + CW // 4, label1, values[0]), (L + 3 * CW // 4, label2, values[1])]:
        draw_outlined_text(c, label, cx, 3, "4x5", PATCH_LABEL_COLOR, align = "center")
        lines = wrap_words(c, v, font, HALF_W)
        if len(lines) > 2:
            lines = lines[:2]
        top = 11 + (21 - (len(lines) * (h + 2) - 2)) // 2
        for k in range(len(lines)):
            t, f2 = fit_text(c, lines[k], [font, "4x5", "picopixel"], HALF_W)
            draw_outlined_text(c, t, cx, top + k * (h + 2), f2, "white", align = "center")

FONT_HEIGHTS = {"6x8": 8, "5x7": 7, "4x5": 5, "5x5": 5, "picopixel": 5}

def draw_two_facts(c, name, vehicle, ship):
    draw_side_by_side(c, name, "LAUNCH VEHICLE", vehicle, "RECOVERY SHIP", ship)

def draw_module_names(c, mission_name, cm_name, lm_name):
    draw_side_by_side(c, mission_name, "COMMAND MODULE", cm_name, "LUNAR MODULE", lm_name)

def draw_label_pairs(c, name, label1, value1, label2, value2):
    draw_side_by_side(c, name, label1, value1, label2, value2)

def draw_oft_facts(c, name):
    draw_side_by_side(c, name, "MISSION TYPE", "ORBITAL FLIGHT TEST", "CREW ESCAPE", "EJECTION SEATS")
