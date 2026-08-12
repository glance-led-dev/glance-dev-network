# MBTA Tracker Scroll -- live upcoming-train board for one MBTA station (subway
# or commuter rail, picked in Settings). Queries the public MBTA V3 API
# (api-v3.mbta.com) directly each render; no companion server needed.
#
# Stations with both subway and Commuter Rail service (Back Bay, Braintree,
# Forest Hills, JFK/UMass, Malden Center, North Station, Oak Grove, Porter,
# Quincy Center, Ruggles, South Station) appear twice in the picker, once per
# mode, sharing the same physical stop ID but queried with a different
# route_type filter -- MBTA scopes predictions by mode, not by station.
#
# STATIONS is generated from the live MBTA API (stops per subway/CR route),
# not hand-typed, so every id below is a real MBTA parent-station stop id.

STATIONS = {
    "Abington": {"id": "place-PB-0194", "mode": "cr", "color": "#80276C", "route": None},
    "Airport": {"id": "place-aport", "mode": "subway", "color": "#003DA5", "route": None},
    "Alewife": {"id": "place-alfcl", "mode": "subway", "color": "#DA291C", "route": None},
    "Allston Street": {"id": "place-alsgr", "mode": "subway", "color": "#00843D", "route": None},
    "Amory Street": {"id": "place-amory", "mode": "subway", "color": "#00843D", "route": None},
    "Anderson/Woburn": {"id": "place-NHRML-0127", "mode": "cr", "color": "#80276C", "route": None},
    "Andover": {"id": "place-WR-0228", "mode": "cr", "color": "#80276C", "route": None},
    "Andrew": {"id": "place-andrw", "mode": "subway", "color": "#DA291C", "route": None},
    "Aquarium": {"id": "place-aqucl", "mode": "subway", "color": "#003DA5", "route": None},
    "Arlington": {"id": "place-armnl", "mode": "subway", "color": "#00843D", "route": None},
    "Ashland": {"id": "place-WML-0252", "mode": "cr", "color": "#80276C", "route": None},
    "Ashmont (Mattapan Line)": {"id": "place-asmnl", "mode": "subway", "color": "#DA291C", "route": "Mattapan"},
    "Ashmont (Red Line)": {"id": "place-asmnl", "mode": "subway", "color": "#DA291C", "route": "Red"},
    "Assembly": {"id": "place-astao", "mode": "subway", "color": "#ED8B00", "route": None},
    "Attleboro": {"id": "place-NEC-1969", "mode": "cr", "color": "#80276C", "route": None},
    "Auburndale": {"id": "place-WML-0102", "mode": "cr", "color": "#80276C", "route": None},
    "Ayer": {"id": "place-FR-0361", "mode": "cr", "color": "#80276C", "route": None},
    "Babcock Street": {"id": "place-babck", "mode": "subway", "color": "#00843D", "route": None},
    "Back Bay (CR)": {"id": "place-bbsta", "mode": "cr", "color": "#80276C", "route": None},
    "Back Bay (Orange Line)": {"id": "place-bbsta", "mode": "subway", "color": "#ED8B00", "route": None},
    "Back of the Hill": {"id": "place-bckhl", "mode": "subway", "color": "#00843D", "route": None},
    "Ball Square": {"id": "place-balsq", "mode": "subway", "color": "#00843D", "route": None},
    "Ballardvale": {"id": "place-WR-0205", "mode": "cr", "color": "#80276C", "route": None},
    "Beachmont": {"id": "place-bmmnl", "mode": "subway", "color": "#003DA5", "route": None},
    "Beaconsfield": {"id": "place-bcnfd", "mode": "subway", "color": "#00843D", "route": None},
    "Bellevue": {"id": "place-NB-0072", "mode": "cr", "color": "#80276C", "route": None},
    "Belmont": {"id": "place-FR-0064", "mode": "cr", "color": "#80276C", "route": None},
    "Beverly": {"id": "place-ER-0183", "mode": "cr", "color": "#80276C", "route": None},
    "Beverly Farms": {"id": "place-GB-0229", "mode": "cr", "color": "#80276C", "route": None},
    "Blandford Street": {"id": "place-bland", "mode": "subway", "color": "#00843D", "route": None},
    "Blue Hill Avenue": {"id": "place-DB-2222", "mode": "cr", "color": "#80276C", "route": None},
    "Boston College": {"id": "place-lake", "mode": "subway", "color": "#00843D", "route": None},
    "Boston Landing": {"id": "place-WML-0035", "mode": "cr", "color": "#80276C", "route": None},
    "Bowdoin": {"id": "place-bomnl", "mode": "subway", "color": "#003DA5", "route": None},
    "Boylston": {"id": "place-boyls", "mode": "subway", "color": "#00843D", "route": None},
    "Bradford": {"id": "place-WR-0325", "mode": "cr", "color": "#80276C", "route": None},
    "Braintree (CR)": {"id": "place-brntn", "mode": "cr", "color": "#80276C", "route": None},
    "Braintree (Red Line)": {"id": "place-brntn", "mode": "subway", "color": "#DA291C", "route": None},
    "Brandeis/Roberts": {"id": "place-FR-0115", "mode": "cr", "color": "#80276C", "route": None},
    "Brandon Hall": {"id": "place-bndhl", "mode": "subway", "color": "#00843D", "route": None},
    "Bridgewater": {"id": "place-MM-0277", "mode": "cr", "color": "#80276C", "route": None},
    "Brigham Circle": {"id": "place-brmnl", "mode": "subway", "color": "#00843D", "route": None},
    "Broadway": {"id": "place-brdwy", "mode": "subway", "color": "#DA291C", "route": None},
    "Brockton": {"id": "place-MM-0200", "mode": "cr", "color": "#80276C", "route": None},
    "Brookline Hills": {"id": "place-brkhl", "mode": "subway", "color": "#00843D", "route": None},
    "Brookline Village": {"id": "place-bvmnl", "mode": "subway", "color": "#00843D", "route": None},
    "BU Central": {"id": "place-bucen", "mode": "subway", "color": "#00843D", "route": None},
    "BU East": {"id": "place-buest", "mode": "subway", "color": "#00843D", "route": None},
    "Butler": {"id": "place-butlr", "mode": "subway", "color": "#DA291C", "route": None},
    "Campello": {"id": "place-MM-0219", "mode": "cr", "color": "#80276C", "route": None},
    "Canton Center": {"id": "place-SB-0156", "mode": "cr", "color": "#80276C", "route": None},
    "Canton Junction": {"id": "place-NEC-2139", "mode": "cr", "color": "#80276C", "route": None},
    "Capen Street": {"id": "place-capst", "mode": "subway", "color": "#DA291C", "route": None},
    "Cedar Grove": {"id": "place-cedgr", "mode": "subway", "color": "#DA291C", "route": None},
    "Central": {"id": "place-cntsq", "mode": "subway", "color": "#DA291C", "route": None},
    "Central Avenue": {"id": "place-cenav", "mode": "subway", "color": "#DA291C", "route": None},
    "Charles/MGH": {"id": "place-chmnl", "mode": "subway", "color": "#DA291C", "route": None},
    "Chelsea": {"id": "place-chels", "mode": "cr", "color": "#80276C", "route": None},
    "Chestnut Hill": {"id": "place-chhil", "mode": "subway", "color": "#00843D", "route": None},
    "Chestnut Hill Ave": {"id": "place-chill", "mode": "subway", "color": "#00843D", "route": None},
    "Chinatown": {"id": "place-chncl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Chiswick Road": {"id": "place-chswk", "mode": "subway", "color": "#00843D", "route": None},
    "Church Street": {"id": "place-NBM-0523", "mode": "cr", "color": "#80276C", "route": None},
    "Cleveland Circle": {"id": "place-clmnl", "mode": "subway", "color": "#00843D", "route": None},
    "Cohasset": {"id": "place-GRB-0199", "mode": "cr", "color": "#80276C", "route": None},
    "Community College": {"id": "place-ccmnl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Concord": {"id": "place-FR-0201", "mode": "cr", "color": "#80276C", "route": None},
    "Coolidge Corner": {"id": "place-cool", "mode": "subway", "color": "#00843D", "route": None},
    "Copley": {"id": "place-coecl", "mode": "subway", "color": "#00843D", "route": None},
    "Davis": {"id": "place-davis", "mode": "subway", "color": "#DA291C", "route": None},
    "Dean Road": {"id": "place-denrd", "mode": "subway", "color": "#00843D", "route": None},
    "Dedham Corporate": {"id": "place-FB-0118", "mode": "cr", "color": "#80276C", "route": None},
    "Downtown Crossing (Orange Line)": {"id": "place-dwnxg", "mode": "subway", "color": "#ED8B00", "route": "Orange"},
    "Downtown Crossing (Red Line)": {"id": "place-dwnxg", "mode": "subway", "color": "#DA291C", "route": "Red"},
    "East Somerville": {"id": "place-esomr", "mode": "subway", "color": "#00843D", "route": None},
    "East Taunton": {"id": "place-NBM-0374", "mode": "cr", "color": "#80276C", "route": None},
    "East Weymouth": {"id": "place-GRB-0146", "mode": "cr", "color": "#80276C", "route": None},
    "Eliot": {"id": "place-eliot", "mode": "subway", "color": "#00843D", "route": None},
    "Endicott": {"id": "place-FB-0109", "mode": "cr", "color": "#80276C", "route": None},
    "Englewood Avenue": {"id": "place-engav", "mode": "subway", "color": "#00843D", "route": None},
    "Fairbanks Street": {"id": "place-fbkst", "mode": "subway", "color": "#00843D", "route": None},
    "Fairmount": {"id": "place-DB-2205", "mode": "cr", "color": "#80276C", "route": None},
    "Fall River Depot": {"id": "place-FRS-0109", "mode": "cr", "color": "#80276C", "route": None},
    "Fenway": {"id": "place-fenwy", "mode": "subway", "color": "#00843D", "route": None},
    "Fenwood Road": {"id": "place-fenwd", "mode": "subway", "color": "#00843D", "route": None},
    "Fields Corner": {"id": "place-fldcr", "mode": "subway", "color": "#DA291C", "route": None},
    "Fitchburg": {"id": "place-FR-0494", "mode": "cr", "color": "#80276C", "route": None},
    "Forest Hills (CR)": {"id": "place-forhl", "mode": "cr", "color": "#80276C", "route": None},
    "Forest Hills (Orange Line)": {"id": "place-forhl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Forge Park/495": {"id": "place-FB-0303", "mode": "cr", "color": "#80276C", "route": None},
    "Four Corners": {"id": "place-DB-2249", "mode": "cr", "color": "#80276C", "route": None},
    "Foxboro": {"id": "place-FS-0049", "mode": "cr", "color": "#80276C", "route": None},
    "Framingham": {"id": "place-WML-0214", "mode": "cr", "color": "#80276C", "route": None},
    "Franklin": {"id": "place-FB-0275", "mode": "cr", "color": "#80276C", "route": None},
    "Freetown": {"id": "place-FRS-0054", "mode": "cr", "color": "#80276C", "route": None},
    "Gilman Square": {"id": "place-gilmn", "mode": "subway", "color": "#00843D", "route": None},
    "Gloucester": {"id": "place-GB-0316", "mode": "cr", "color": "#80276C", "route": None},
    "Government Center (Blue Line)": {"id": "place-gover", "mode": "subway", "color": "#003DA5", "route": "Blue"},
    "Government Center (Green Line)": {"id": "place-gover", "mode": "subway", "color": "#00843D", "route": "Green-B,Green-C,Green-D,Green-E"},
    "Grafton": {"id": "place-WML-0364", "mode": "cr", "color": "#80276C", "route": None},
    "Green Street": {"id": "place-grnst", "mode": "subway", "color": "#ED8B00", "route": None},
    "Greenbush": {"id": "place-GRB-0276", "mode": "cr", "color": "#80276C", "route": None},
    "Greenwood": {"id": "place-WR-0085", "mode": "cr", "color": "#80276C", "route": None},
    "Griggs Street": {"id": "place-grigg", "mode": "subway", "color": "#00843D", "route": None},
    "Halifax": {"id": "place-PB-0281", "mode": "cr", "color": "#80276C", "route": None},
    "Hamilton/Wenham": {"id": "place-ER-0227", "mode": "cr", "color": "#80276C", "route": None},
    "Hanson": {"id": "place-PB-0245", "mode": "cr", "color": "#80276C", "route": None},
    "Harvard": {"id": "place-harsq", "mode": "subway", "color": "#DA291C", "route": None},
    "Harvard Avenue": {"id": "place-harvd", "mode": "subway", "color": "#00843D", "route": None},
    "Haverhill": {"id": "place-WR-0329", "mode": "cr", "color": "#80276C", "route": None},
    "Hawes Street": {"id": "place-hwsst", "mode": "subway", "color": "#00843D", "route": None},
    "Haymarket (Green Line)": {"id": "place-haecl", "mode": "subway", "color": "#00843D", "route": "Green-B,Green-C,Green-D,Green-E"},
    "Haymarket (Orange Line)": {"id": "place-haecl", "mode": "subway", "color": "#ED8B00", "route": "Orange"},
    "Heath Street": {"id": "place-hsmnl", "mode": "subway", "color": "#00843D", "route": None},
    "Hersey": {"id": "place-NB-0109", "mode": "cr", "color": "#80276C", "route": None},
    "Highland": {"id": "place-NB-0076", "mode": "cr", "color": "#80276C", "route": None},
    "Holbrook/Randolph": {"id": "place-MM-0150", "mode": "cr", "color": "#80276C", "route": None},
    "Hyde Park": {"id": "place-NEC-2203", "mode": "cr", "color": "#80276C", "route": None},
    "Hynes": {"id": "place-hymnl", "mode": "subway", "color": "#00843D", "route": None},
    "Ipswich": {"id": "place-ER-0276", "mode": "cr", "color": "#80276C", "route": None},
    "Islington": {"id": "place-FB-0125", "mode": "cr", "color": "#80276C", "route": None},
    "Jackson Square": {"id": "place-jaksn", "mode": "subway", "color": "#ED8B00", "route": None},
    "JFK/UMass (CR)": {"id": "place-jfk", "mode": "cr", "color": "#80276C", "route": None},
    "JFK/UMass (Red Line)": {"id": "place-jfk", "mode": "subway", "color": "#DA291C", "route": None},
    "Kendal Green": {"id": "place-FR-0132", "mode": "cr", "color": "#80276C", "route": None},
    "Kendall/MIT": {"id": "place-knncl", "mode": "subway", "color": "#DA291C", "route": None},
    "Kenmore": {"id": "place-kencl", "mode": "subway", "color": "#00843D", "route": None},
    "Kent Street": {"id": "place-kntst", "mode": "subway", "color": "#00843D", "route": None},
    "Kingston": {"id": "place-KB-0351", "mode": "cr", "color": "#80276C", "route": None},
    "Lansdowne": {"id": "place-WML-0025", "mode": "cr", "color": "#80276C", "route": None},
    "Lawrence": {"id": "place-WR-0264", "mode": "cr", "color": "#80276C", "route": None},
    "Lechmere": {"id": "place-lech", "mode": "subway", "color": "#00843D", "route": None},
    "Lincoln": {"id": "place-FR-0167", "mode": "cr", "color": "#80276C", "route": None},
    "Littleton": {"id": "place-FR-0301", "mode": "cr", "color": "#80276C", "route": None},
    "Longwood": {"id": "place-longw", "mode": "subway", "color": "#00843D", "route": None},
    "Longwood Medical": {"id": "place-lngmd", "mode": "subway", "color": "#00843D", "route": None},
    "Lowell": {"id": "place-NHRML-0254", "mode": "cr", "color": "#80276C", "route": None},
    "Lynn Interim": {"id": "place-ER-0117", "mode": "cr", "color": "#80276C", "route": None},
    "Magoun Square": {"id": "place-mgngl", "mode": "subway", "color": "#00843D", "route": None},
    "Malden Center (CR)": {"id": "place-mlmnl", "mode": "cr", "color": "#80276C", "route": None},
    "Malden Center (Orange Line)": {"id": "place-mlmnl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Manchester": {"id": "place-GB-0254", "mode": "cr", "color": "#80276C", "route": None},
    "Mansfield": {"id": "place-NEC-2040", "mode": "cr", "color": "#80276C", "route": None},
    "Mass Ave": {"id": "place-masta", "mode": "subway", "color": "#ED8B00", "route": None},
    "Mattapan": {"id": "place-matt", "mode": "subway", "color": "#DA291C", "route": None},
    "Maverick": {"id": "place-mvbcl", "mode": "subway", "color": "#003DA5", "route": None},
    "Medford/Tufts": {"id": "place-mdftf", "mode": "subway", "color": "#00843D", "route": None},
    "Melrose Highlands": {"id": "place-WR-0075", "mode": "cr", "color": "#80276C", "route": None},
    "Melrose/Cedar Park": {"id": "place-WR-0067", "mode": "cr", "color": "#80276C", "route": None},
    "MFA": {"id": "place-mfa", "mode": "subway", "color": "#00843D", "route": None},
    "Middleborough": {"id": "place-MBS-0350", "mode": "cr", "color": "#80276C", "route": None},
    "Milton": {"id": "place-miltt", "mode": "subway", "color": "#DA291C", "route": None},
    "Mission Park": {"id": "place-mispk", "mode": "subway", "color": "#00843D", "route": None},
    "Montello": {"id": "place-MM-0186", "mode": "cr", "color": "#80276C", "route": None},
    "Montserrat": {"id": "place-GB-0198", "mode": "cr", "color": "#80276C", "route": None},
    "Morton Street": {"id": "place-DB-2230", "mode": "cr", "color": "#80276C", "route": None},
    "N.Station (CR)": {"id": "place-north", "mode": "cr", "color": "#80276C", "route": None},
    "N.Station (Green Line)": {"id": "place-north", "mode": "subway", "color": "#00843D", "route": "Green-B,Green-C,Green-D,Green-E"},
    "N.Station (Orange Line)": {"id": "place-north", "mode": "subway", "color": "#ED8B00", "route": "Orange"},
    "Nantasket Junction": {"id": "place-GRB-0183", "mode": "cr", "color": "#80276C", "route": None},
    "Natick Center": {"id": "place-WML-0177", "mode": "cr", "color": "#80276C", "route": None},
    "Needham Center": {"id": "place-NB-0127", "mode": "cr", "color": "#80276C", "route": None},
    "Needham Heights": {"id": "place-NB-0137", "mode": "cr", "color": "#80276C", "route": None},
    "Needham Junction": {"id": "place-NB-0120", "mode": "cr", "color": "#80276C", "route": None},
    "New Bedford": {"id": "place-NBM-0546", "mode": "cr", "color": "#80276C", "route": None},
    "Newburyport": {"id": "place-ER-0362", "mode": "cr", "color": "#80276C", "route": None},
    "Newmarket": {"id": "place-DB-2265", "mode": "cr", "color": "#80276C", "route": None},
    "Newton Centre": {"id": "place-newto", "mode": "subway", "color": "#00843D", "route": None},
    "Newton Highlands": {"id": "place-newtn", "mode": "subway", "color": "#00843D", "route": None},
    "Newtonville": {"id": "place-WML-0081", "mode": "cr", "color": "#80276C", "route": None},
    "Norfolk": {"id": "place-FB-0230", "mode": "cr", "color": "#80276C", "route": None},
    "North Beverly": {"id": "place-ER-0208", "mode": "cr", "color": "#80276C", "route": None},
    "North Billerica": {"id": "place-NHRML-0218", "mode": "cr", "color": "#80276C", "route": None},
    "North Leominster": {"id": "place-FR-0451", "mode": "cr", "color": "#80276C", "route": None},
    "North Quincy": {"id": "place-nqncy", "mode": "subway", "color": "#DA291C", "route": None},
    "North Scituate": {"id": "place-GRB-0233", "mode": "cr", "color": "#80276C", "route": None},
    "North Wilmington": {"id": "place-WR-0163", "mode": "cr", "color": "#80276C", "route": None},
    "Northeastern": {"id": "place-nuniv", "mode": "subway", "color": "#00843D", "route": None},
    "Norwood Central": {"id": "place-FB-0148", "mode": "cr", "color": "#80276C", "route": None},
    "Norwood Depot": {"id": "place-FB-0143", "mode": "cr", "color": "#80276C", "route": None},
    "Oak Grove (CR)": {"id": "place-ogmnl", "mode": "cr", "color": "#80276C", "route": None},
    "Oak Grove (Orange Line)": {"id": "place-ogmnl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Orient Heights": {"id": "place-orhte", "mode": "subway", "color": "#003DA5", "route": None},
    "Packard's Corner": {"id": "place-brico", "mode": "subway", "color": "#00843D", "route": None},
    "Park Street (Green Line)": {"id": "place-pktrm", "mode": "subway", "color": "#00843D", "route": "Green-B,Green-C,Green-D,Green-E"},
    "Park Street (Red Line)": {"id": "place-pktrm", "mode": "subway", "color": "#DA291C", "route": "Red"},
    "Pawtucket": {"id": "place-NEC-1891", "mode": "cr", "color": "#80276C", "route": None},
    "Porter (CR)": {"id": "place-portr", "mode": "cr", "color": "#80276C", "route": None},
    "Porter (Red Line)": {"id": "place-portr", "mode": "subway", "color": "#DA291C", "route": None},
    "Providence": {"id": "place-NEC-1851", "mode": "cr", "color": "#80276C", "route": None},
    "Prudential": {"id": "place-prmnl", "mode": "subway", "color": "#00843D", "route": None},
    "Quincy Adams": {"id": "place-qamnl", "mode": "subway", "color": "#DA291C", "route": None},
    "Quincy Center (CR)": {"id": "place-qnctr", "mode": "cr", "color": "#80276C", "route": None},
    "Quincy Center (Red Line)": {"id": "place-qnctr", "mode": "subway", "color": "#DA291C", "route": None},
    "Reading": {"id": "place-WR-0120", "mode": "cr", "color": "#80276C", "route": None},
    "Readville": {"id": "place-DB-0095", "mode": "cr", "color": "#80276C", "route": None},
    "Reservoir": {"id": "place-rsmnl", "mode": "subway", "color": "#00843D", "route": None},
    "Revere Beach": {"id": "place-rbmnl", "mode": "subway", "color": "#003DA5", "route": None},
    "River Works": {"id": "place-ER-0099", "mode": "cr", "color": "#80276C", "route": None},
    "Riverside": {"id": "place-river", "mode": "subway", "color": "#00843D", "route": None},
    "Riverway": {"id": "place-rvrwy", "mode": "subway", "color": "#00843D", "route": None},
    "Rockport": {"id": "place-GB-0353", "mode": "cr", "color": "#80276C", "route": None},
    "Roslindale Village": {"id": "place-NB-0064", "mode": "cr", "color": "#80276C", "route": None},
    "Route 128": {"id": "place-NEC-2173", "mode": "cr", "color": "#80276C", "route": None},
    "Rowley": {"id": "place-ER-0312", "mode": "cr", "color": "#80276C", "route": None},
    "Roxbury Crossing": {"id": "place-rcmnl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Ruggles (CR)": {"id": "place-rugg", "mode": "cr", "color": "#80276C", "route": None},
    "Ruggles (Orange Line)": {"id": "place-rugg", "mode": "subway", "color": "#ED8B00", "route": None},
    "S.Station (CR)": {"id": "place-sstat", "mode": "cr", "color": "#80276C", "route": None},
    "S.Station (Red Line)": {"id": "place-sstat", "mode": "subway", "color": "#DA291C", "route": None},
    "Saint Paul Street": {"id": "place-stpul", "mode": "subway", "color": "#00843D", "route": None},
    "Salem": {"id": "place-ER-0168", "mode": "cr", "color": "#80276C", "route": None},
    "Savin Hill": {"id": "place-shmnl", "mode": "subway", "color": "#DA291C", "route": None},
    "Science Park": {"id": "place-spmnl", "mode": "subway", "color": "#00843D", "route": None},
    "Sharon": {"id": "place-NEC-2108", "mode": "cr", "color": "#80276C", "route": None},
    "Shawmut": {"id": "place-smmnl", "mode": "subway", "color": "#DA291C", "route": None},
    "Shirley": {"id": "place-FR-0394", "mode": "cr", "color": "#80276C", "route": None},
    "Silver Hill": {"id": "place-FR-0147", "mode": "cr", "color": "#80276C", "route": None},
    "South Acton": {"id": "place-FR-0253", "mode": "cr", "color": "#80276C", "route": None},
    "South Attleboro": {"id": "place-NEC-1919", "mode": "cr", "color": "#80276C", "route": None},
    "South Street": {"id": "place-sougr", "mode": "subway", "color": "#00843D", "route": None},
    "South Weymouth": {"id": "place-PB-0158", "mode": "cr", "color": "#80276C", "route": None},
    "Southborough": {"id": "place-WML-0274", "mode": "cr", "color": "#80276C", "route": None},
    "St Mary's": {"id": "place-smary", "mode": "subway", "color": "#00843D", "route": None},
    "State (Blue Line)": {"id": "place-state", "mode": "subway", "color": "#003DA5", "route": "Blue"},
    "State (Orange Line)": {"id": "place-state", "mode": "subway", "color": "#ED8B00", "route": "Orange"},
    "Stony Brook": {"id": "place-sbmnl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Stoughton": {"id": "place-SB-0189", "mode": "cr", "color": "#80276C", "route": None},
    "Suffolk Downs": {"id": "place-sdmnl", "mode": "subway", "color": "#003DA5", "route": None},
    "Sullivan Square": {"id": "place-sull", "mode": "subway", "color": "#ED8B00", "route": None},
    "Summit Avenue": {"id": "place-sumav", "mode": "subway", "color": "#00843D", "route": None},
    "Sutherland Road": {"id": "place-sthld", "mode": "subway", "color": "#00843D", "route": None},
    "Swampscott": {"id": "place-ER-0128", "mode": "cr", "color": "#80276C", "route": None},
    "Symphony": {"id": "place-symcl", "mode": "subway", "color": "#00843D", "route": None},
    "Talbot Avenue": {"id": "place-DB-2240", "mode": "cr", "color": "#80276C", "route": None},
    "Tappan Street": {"id": "place-tapst", "mode": "subway", "color": "#00843D", "route": None},
    "TF Green Airport": {"id": "place-NEC-1768", "mode": "cr", "color": "#80276C", "route": None},
    "Tufts Medical": {"id": "place-tumnl", "mode": "subway", "color": "#ED8B00", "route": None},
    "Union Square": {"id": "place-unsqu", "mode": "subway", "color": "#00843D", "route": None},
    "Uphams Corner": {"id": "place-DB-2258", "mode": "cr", "color": "#80276C", "route": None},
    "Valley Road": {"id": "place-valrd", "mode": "subway", "color": "#DA291C", "route": None},
    "Waban": {"id": "place-waban", "mode": "subway", "color": "#00843D", "route": None},
    "Wachusett": {"id": "place-FR-3338", "mode": "cr", "color": "#80276C", "route": None},
    "Wakefield": {"id": "place-WR-0099", "mode": "cr", "color": "#80276C", "route": None},
    "Walpole": {"id": "place-FB-0191", "mode": "cr", "color": "#80276C", "route": None},
    "Waltham": {"id": "place-FR-0098", "mode": "cr", "color": "#80276C", "route": None},
    "Warren Street": {"id": "place-wrnst", "mode": "subway", "color": "#00843D", "route": None},
    "Washington Square": {"id": "place-bcnwa", "mode": "subway", "color": "#00843D", "route": None},
    "Washington Street": {"id": "place-wascm", "mode": "subway", "color": "#00843D", "route": None},
    "Waverley": {"id": "place-FR-0074", "mode": "cr", "color": "#80276C", "route": None},
    "Wedgemere": {"id": "place-NHRML-0073", "mode": "cr", "color": "#80276C", "route": None},
    "Wellesley Farms": {"id": "place-WML-0125", "mode": "cr", "color": "#80276C", "route": None},
    "Wellesley Hills": {"id": "place-WML-0135", "mode": "cr", "color": "#80276C", "route": None},
    "Wellesley Square": {"id": "place-WML-0147", "mode": "cr", "color": "#80276C", "route": None},
    "Wellington": {"id": "place-welln", "mode": "subway", "color": "#ED8B00", "route": None},
    "West Concord": {"id": "place-FR-0219", "mode": "cr", "color": "#80276C", "route": None},
    "West Gloucester": {"id": "place-GB-0296", "mode": "cr", "color": "#80276C", "route": None},
    "West Hingham": {"id": "place-GRB-0162", "mode": "cr", "color": "#80276C", "route": None},
    "West Medford": {"id": "place-NHRML-0055", "mode": "cr", "color": "#80276C", "route": None},
    "West Natick": {"id": "place-WML-0199", "mode": "cr", "color": "#80276C", "route": None},
    "West Newton": {"id": "place-WML-0091", "mode": "cr", "color": "#80276C", "route": None},
    "West Roxbury": {"id": "place-NB-0080", "mode": "cr", "color": "#80276C", "route": None},
    "Westborough": {"id": "place-WML-0340", "mode": "cr", "color": "#80276C", "route": None},
    "Weymouth Landing": {"id": "place-GRB-0118", "mode": "cr", "color": "#80276C", "route": None},
    "Whitman": {"id": "place-PB-0212", "mode": "cr", "color": "#80276C", "route": None},
    "Wickford Junction": {"id": "place-NEC-1659", "mode": "cr", "color": "#80276C", "route": None},
    "Wilmington": {"id": "place-NHRML-0152", "mode": "cr", "color": "#80276C", "route": None},
    "Winchester Center": {"id": "place-NHRML-0078", "mode": "cr", "color": "#80276C", "route": None},
    "Windsor Gardens": {"id": "place-FB-0166", "mode": "cr", "color": "#80276C", "route": None},
    "Wollaston": {"id": "place-wlsta", "mode": "subway", "color": "#DA291C", "route": None},
    "Wonderland": {"id": "place-wondl", "mode": "subway", "color": "#003DA5", "route": None},
    "Wood Island": {"id": "place-wimnl", "mode": "subway", "color": "#003DA5", "route": None},
    "Woodland": {"id": "place-woodl", "mode": "subway", "color": "#00843D", "route": None},
    "Worcester": {"id": "place-WML-0442", "mode": "cr", "color": "#80276C", "route": None},
    "Wyoming Hill": {"id": "place-WR-0062", "mode": "cr", "color": "#80276C", "route": None},
}

# ---------- date math ----------
# MBTA timestamps are ISO8601 WITH an explicit UTC offset, e.g.
# "2026-08-06T15:37:26-04:00". ctx.now.unix is UTC seconds, so converting the
# string ourselves (civil date -> days since epoch, days-from-civil algorithm)
# needs no timezone/DST lookup at all: the offset is already in the string.

def _days_from_civil(y, m, d):
    yy = y - 1 if m <= 2 else y
    era = yy // 400
    yoe = yy - era * 400
    mm = m + (-3 if m > 2 else 9)
    doy = (153 * mm + 2) // 5 + d - 1
    doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468

def _epoch_from_iso(s):
    if s == None or len(s) < 25:
        return None
    y = int(s[0:4])
    mo = int(s[5:7])
    d = int(s[8:10])
    h = int(s[11:13])
    mi = int(s[14:16])
    se = int(s[17:19])
    sign = 1 if s[19] == "+" else -1
    oh = int(s[20:22])
    om = int(s[23:25])
    days = _days_from_civil(y, mo, d)
    local_secs = days * 86400 + h * 3600 + mi * 60 + se
    offset_secs = sign * (oh * 3600 + om * 60)
    return local_secs - offset_secs

# ---------- Eastern-time wall clock (header display only) ----------
# ctx.now is UTC. US DST: 2nd Sunday of March -> 1st Sunday of November. Epoch
# day 0 (1970-01-01) was a Thursday, so (days + 3) % 7 gives weekday (0=Mon).

def _pad2(n):
    s = str(int(n))
    return s if len(s) >= 2 else "0" + s

def _nth_sunday_day(year, month, n):
    first = _days_from_civil(year, month, 1)
    wd_first = (first + 3) % 7
    to_sunday = (6 - wd_first) % 7
    return first + to_sunday + (n - 1) * 7

def _et_offset_hours(now):
    today = _days_from_civil(now.year, now.month, now.day)
    dst_start = _nth_sunday_day(now.year, 3, 2)
    dst_end = _nth_sunday_day(now.year, 11, 1)
    return -4 if (today >= dst_start and today < dst_end) else -5

def _clock_str(now):
    local_unix = now.unix + _et_offset_hours(now) * 3600
    secs_in_day = local_unix % 86400
    hh = secs_in_day // 3600
    mm = (secs_in_day % 3600) // 60
    h12 = hh % 12
    if h12 == 0:
        h12 = 12
    ampm = "AM" if hh < 12 else "PM"
    return str(h12) + ":" + _pad2(mm) + " " + ampm

# ---------- small draw helper ----------
# Picks the biggest font from `fonts` that fits `maxw`; if even the smallest
# still overflows, truncates with a trailing ".." so nothing ever runs off
# the panel (long CR station names, multi-line overlap tags, etc.).

def _fit_text(c, text, fonts, maxw):
    if maxw < 4:
        return "", fonts[len(fonts) - 1]
    for f in fonts:
        if c.text_width(text, f) <= maxw:
            return text, f
    f = fonts[len(fonts) - 1]
    for i in range(len(text), 0, -1):
        t = text[:i] + ".."
        if c.text_width(t, f) <= maxw:
            return t, f
    return "", f

def _base_name(station):
    # The picker needs "Park Street (Red Line)" / "Back Bay (CR)" to keep
    # entries distinct, but the panel header just shows the station name --
    # the badge color already carries which line/mode is being displayed.
    idx = station.find(" (")
    if idx == -1:
        return station
    return station[:idx]

def _pred_key(p):
    return p["eff"]

def _is_boarding(status):
    # MBTA's own live vehicle-status text, when present: "Stopped at station"
    # for subway/CR-in-platform, "Now boarding" for CR at the originating
    # terminal. Anything else (None, "Stopped N stops away", ...) isn't.
    if status == None:
        return False
    s = status.lower()
    return "board" in s or "stopped at station" in s

# ---------- fetch + parse ----------
# Same live countdown-to-arrival ("ARR" / "N MIN") for both subway and
# commuter rail predictions -- there's no meaningful public timetable display
# for turn-up-and-go subway service, and a countdown reads fine for CR too.

def fetch(ctx, station):
    st = STATIONS.get(station, None)
    if st == None:
        return {"ok": False, "title": "BAD STATION", "sub": "PICK ONE IN SETTINGS", "color": "#666666"}

    apikey = ctx.inputs.get("apikey", "")
    headers = {}
    if apikey:
        headers["x-api-key"] = apikey

    is_cr = st["mode"] == "cr"
    route = st.get("route", None)

    # Most stations serve one line (or one line + CR, already disambiguated by
    # mode), so filter[route_type] is enough. A handful of transfer stations
    # (Park Street, Downtown Crossing, Ashmont, State, Haymarket, North
    # Station, Government Center) serve two subway lines that share a
    # route_type, so those get a dropdown entry per line, filtered precisely
    # by filter[route] instead.
    params = {
        "filter[stop]": st["id"],
        "include": "trip,route",
        "sort": "arrival_time",
        "page[limit]": "10",
    }
    if route != None:
        params["filter[route]"] = route
    else:
        params["filter[route_type]"] = "2" if is_cr else "0,1"

    resp = http.get(
        "https://api-v3.mbta.com/predictions",
        headers = headers,
        params = params,
        ttl_seconds = 20,
    )

    status = resp["status_code"]
    if status == 0:
        return {"ok": False, "title": "API OFFLINE", "sub": "CHECK CONNECTION", "color": st["color"]}
    if status == 429:
        return {"ok": False, "title": "RATE LIMITED", "sub": "ADD API KEY IN SETTINGS", "color": st["color"]}
    if status != 200:
        return {"ok": False, "title": "API ERROR", "sub": "CODE " + str(status), "color": st["color"]}

    body = resp["json"]
    if body == None or "data" not in body:
        return {"ok": False, "title": "NO DATA", "sub": "EMPTY RESPONSE", "color": st["color"]}

    trips_by_id = {}
    routes_by_id = {}
    for inc in body.get("included", []):
        t = inc.get("type", "")
        if t == "trip":
            trips_by_id[inc["id"]] = inc.get("attributes", {})
        elif t == "route":
            routes_by_id[inc["id"]] = inc.get("attributes", {})

    raw = []
    for p in body.get("data", []):
        a = p.get("attributes", {})
        arr_eff = _epoch_from_iso(a.get("arrival_time", None))
        dep_eff = _epoch_from_iso(a.get("departure_time", None))
        eff = arr_eff if arr_eff != None else dep_eff
        if eff == None:
            continue

        # Boarding = MBTA says so directly (rare -- mostly termini/majors), OR
        # simpler and far more reliable: "now" falls between this stop's own
        # arrival and departure times, which by definition means the train is
        # sitting right there. Works at every station, not just the ones MBTA
        # bothers to set a status string for.
        time_boarding = (arr_eff != None and dep_eff != None
                         and arr_eff <= ctx.now.unix and ctx.now.unix < dep_eff)
        boarding = time_boarding or _is_boarding(a.get("status", None))

        mins = (eff - ctx.now.unix) // 60
        if mins < -1 and not boarding:
            # already left -- MBTA sometimes keeps a stale prediction briefly.
            # A boarding train is the exception: it can sit at the platform
            # for a few minutes, well past its original arrival_time, and is
            # still very much the train you want to see.
            continue

        rel = p.get("relationships", {})
        route_id = rel.get("route", {}).get("data", {}).get("id", None)
        trip_id = rel.get("trip", {}).get("data", {}).get("id", None)
        route_attrs = routes_by_id.get(route_id, {})
        trip_attrs = trips_by_id.get(trip_id, {})

        dest = trip_attrs.get("headsign", None)
        if dest == None or dest == "":
            dirs = route_attrs.get("direction_destinations", None)
            did = a.get("direction_id", None)
            if dirs != None and did != None and did < len(dirs):
                dest = dirs[did]
            else:
                dest = "--"

        raw.append({
            "eff": eff, "mins": max(mins, 0), "dest": str(dest).upper(),
            "boarding": boarding,
        })
        if len(raw) >= 6:
            break

    raw = sorted(raw, key = _pred_key)

    rows = []
    for r in raw[:2]:
        mins = r["mins"]
        if r["boarding"]:
            stxt = "BRD"
        elif mins <= 0:
            stxt = "ARR"
        else:
            stxt = str(mins) + " MIN"
        rows.append({"dest": r["dest"], "status": stxt, "scolor": st["color"]})

    return {"ok": True, "color": st["color"], "rows": rows}


# ---------- page ----------
# 64x32 is half the width of the scroll version, so this drops the header
# clock (no room for it next to a station name) and shrinks the "T" badge --
# everything else (station picked, colors, countdown logic) is identical.

def main(c, ctx):
    station = ctx.inputs.get("station", "Park Street (Red Line)")
    if station == None or station == "":
        station = "Park Street (Red Line)"

    c.fill("black")

    d = fetch(ctx, station)
    badge_color = d.get("color", "#666666")

    c.fill_circle(4, 4, 4, badge_color)
    c.text("T", 5, 2, font = "4x5", color = "white", align = "center")

    name_maxw = c.width - 10 - 2
    name_txt, name_font = _fit_text(c, _base_name(station).upper(), ["5x7", "4x5"], name_maxw)
    c.text(name_txt, 9, 1, font = name_font, color = badge_color)

    if not d["ok"]:
        # 64px is too narrow for these messages on one line -- wrap instead of
        # letting them run off the panel like a single text_center would.
        n = c.text_wrapped(d["title"], 2, 10, c.width - 4, font = "4x5",
                           color = "orange", align = "center", line_gap = 1, max_lines = 2)
        sub_y = 10 + n * 7
        c.text_wrapped(d["sub"], 2, sub_y, c.width - 4, font = "4x5",
                       color = "gray", align = "center", line_gap = 1, max_lines = 2)
        return

    rows = d["rows"]
    if len(rows) == 0:
        c.text_center("NO TRAINS", 16, font = "5x7", color = "gray")
        return

    y = 11
    for r in rows:
        stxt = "ARR" if r["status"] == "ARR" else r["status"].replace(" MIN", "M")
        status_w = c.text_width(stxt, "5x7")
        dest_maxw = c.width - 2 - status_w - 3
        dest_txt, dest_font = _fit_text(c, r["dest"], ["5x7", "4x5"], dest_maxw)
        c.text(dest_txt, 2, y, font = dest_font, color = "white")
        c.text(stxt, c.width - 1, y, font = "5x7", color = r["scolor"], align = "right")
        y += 10
