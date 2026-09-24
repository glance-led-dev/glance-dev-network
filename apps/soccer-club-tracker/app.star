# Soccer Club Tracker
# 128x32 Glance app: any club in any league ESPN covers.
# Pages: current/next match, last result, league table.

SITE = "https://site.api.espn.com/apis/site/v2/sports/soccer/"
WEB = "https://site.web.api.espn.com/apis/site/v2/sports/soccer/all/teams/"
STANDINGS = "https://site.api.espn.com/apis/v2/sports/soccer/"

# ESPN league code -> name shown on the table page.
LEAGUE_NAMES = {
    "eng.1": "PREMIER LEAGUE",
    "eng.2": "CHAMPIONSHIP",
    "esp.1": "LA LIGA",
    "ita.1": "SERIE A",
    "ger.1": "BUNDESLIGA",
    "fra.1": "LIGUE 1",
    "ned.1": "EREDIVISIE",
    "por.1": "PRIMEIRA LIGA",
    "sco.1": "PREMIERSHIP",
    "bel.1": "PRO LEAGUE",
    "tur.1": "SUPER LIG",
    "usa.1": "MLS",
    "mex.1": "LIGA MX",
    "bra.1": "BRASILEIRAO",
    "arg.1": "LIGA PROFESIONAL",
    "jpn.1": "J1 LEAGUE",
    "aus.1": "A-LEAGUE",
    "eng.w.1": "WOMEN'S SUPER LG",
    "usa.nwsl": "NWSL",
}

DEFAULT_TEAM = "England - Liverpool (Premier League)"

# Team setting -> [ESPN league code, ESPN team id]. The league is only a
# starting point: the team's current league is read back from ESPN, so a
# promoted or relegated club keeps working.
TEAMS = {
    "Argentina - Aldosivi (Liga Profesional)": ["arg.1", "9739"],
    "Argentina - Argentinos Juniors (Liga Profesional)": ["arg.1", "3"],
    "Argentina - Atletico Tucuman (Liga Profesional)": ["arg.1", "9785"],
    "Argentina - Banfield (Liga Profesional)": ["arg.1", "235"],
    "Argentina - Barracas Central (Liga Profesional)": ["arg.1", "10060"],
    "Argentina - Belgrano (Cordoba) (Liga Profesional)": ["arg.1", "4"],
    "Argentina - Boca Juniors (Liga Profesional)": ["arg.1", "5"],
    "Argentina - Central Cordoba (Santiago del Estero) (Liga Profesional)": ["arg.1", "11989"],
    "Argentina - Defensa y Justicia (Liga Profesional)": ["arg.1", "8950"],
    "Argentina - Deportivo Riestra (Liga Profesional)": ["arg.1", "17702"],
    "Argentina - Estudiantes de La Plata (Liga Profesional)": ["arg.1", "8"],
    "Argentina - Estudiantes de Rio Cuarto (Liga Profesional)": ["arg.1", "19685"],
    "Argentina - Gimnasia (Mendoza) (Liga Profesional)": ["arg.1", "11972"],
    "Argentina - Gimnasia La Plata (Liga Profesional)": ["arg.1", "9"],
    "Argentina - Huracan (Liga Profesional)": ["arg.1", "10"],
    "Argentina - Independiente (Liga Profesional)": ["arg.1", "11"],
    "Argentina - Independiente Rivadavia (Liga Profesional)": ["arg.1", "9744"],
    "Argentina - Instituto (Cordoba) (Liga Profesional)": ["arg.1", "2975"],
    "Argentina - Lanus (Liga Profesional)": ["arg.1", "12"],
    "Argentina - Newell's Old Boys (Liga Profesional)": ["arg.1", "14"],
    "Argentina - Platense (Liga Profesional)": ["arg.1", "7764"],
    "Argentina - Racing Club (Liga Profesional)": ["arg.1", "15"],
    "Argentina - River Plate (Liga Profesional)": ["arg.1", "16"],
    "Argentina - Rosario Central (Liga Profesional)": ["arg.1", "17"],
    "Argentina - San Lorenzo (Liga Profesional)": ["arg.1", "18"],
    "Argentina - Sarmiento (Junin) (Liga Profesional)": ["arg.1", "10158"],
    "Argentina - Talleres (Cordoba) (Liga Profesional)": ["arg.1", "19"],
    "Argentina - Tigre (Liga Profesional)": ["arg.1", "7767"],
    "Argentina - Union (Santa Fe) (Liga Profesional)": ["arg.1", "20"],
    "Argentina - Velez Sarsfield (Liga Profesional)": ["arg.1", "21"],
    "Australia - Adelaide United (A-League)": ["aus.1", "5321"],
    "Australia - Auckland FC (A-League)": ["aus.1", "22344"],
    "Australia - Brisbane Roar (A-League)": ["aus.1", "5326"],
    "Australia - Central Coast Mariners (A-League)": ["aus.1", "5325"],
    "Australia - Macarthur FC (A-League)": ["aus.1", "19340"],
    "Australia - Melbourne City FC (A-League)": ["aus.1", "11143"],
    "Australia - Melbourne Victory (A-League)": ["aus.1", "5328"],
    "Australia - Newcastle Jets (A-League)": ["aus.1", "5323"],
    "Australia - Perth Glory (A-League)": ["aus.1", "5322"],
    "Australia - Sydney FC (A-League)": ["aus.1", "5327"],
    "Australia - Wellington Phoenix FC (A-League)": ["aus.1", "8352"],
    "Australia - Western Sydney Wanderers (A-League)": ["aus.1", "13696"],
    "Belgium - Anderlecht (Pro League)": ["bel.1", "441"],
    "Belgium - Antwerp (Pro League)": ["bel.1", "17544"],
    "Belgium - Cercle Brugge KSV (Pro League)": ["bel.1", "3610"],
    "Belgium - Club Brugge (Pro League)": ["bel.1", "570"],
    "Belgium - KAA Gent (Pro League)": ["bel.1", "3611"],
    "Belgium - KV Kortrijk (Pro League)": ["bel.1", "5786"],
    "Belgium - KV Mechelen (Pro League)": ["bel.1", "7879"],
    "Belgium - KVC Westerlo (Pro League)": ["bel.1", "606"],
    "Belgium - Lommel SK (Pro League)": ["bel.1", "22269"],
    "Belgium - OH Leuven (Pro League)": ["bel.1", "5579"],
    "Belgium - RAAL La Louviere (Pro League)": ["bel.1", "131235"],
    "Belgium - Racing Genk (Pro League)": ["bel.1", "938"],
    "Belgium - Royal Charleroi SC (Pro League)": ["bel.1", "3616"],
    "Belgium - Sint-Truidense (Pro League)": ["bel.1", "936"],
    "Belgium - Standard Liege (Pro League)": ["bel.1", "559"],
    "Belgium - Union St.-Gilloise (Pro League)": ["bel.1", "5807"],
    "Belgium - Waasland-Beveren (Pro League)": ["bel.1", "13450"],
    "Belgium - Zulte-Waregem (Pro League)": ["bel.1", "4691"],
    "Brazil - Athletico-PR (Brasileirao)": ["bra.1", "3458"],
    "Brazil - Atletico-MG (Brasileirao)": ["bra.1", "7632"],
    "Brazil - Bahia (Brasileirao)": ["bra.1", "9967"],
    "Brazil - Botafogo (Brasileirao)": ["bra.1", "6086"],
    "Brazil - Chapecoense (Brasileirao)": ["bra.1", "9318"],
    "Brazil - Corinthians (Brasileirao)": ["bra.1", "874"],
    "Brazil - Coritiba (Brasileirao)": ["bra.1", "3456"],
    "Brazil - Cruzeiro (Brasileirao)": ["bra.1", "2022"],
    "Brazil - Flamengo (Brasileirao)": ["bra.1", "819"],
    "Brazil - Fluminense (Brasileirao)": ["bra.1", "3445"],
    "Brazil - Gremio (Brasileirao)": ["bra.1", "6273"],
    "Brazil - Internacional (Brasileirao)": ["bra.1", "1936"],
    "Brazil - Mirassol (Brasileirao)": ["bra.1", "9169"],
    "Brazil - Palmeiras (Brasileirao)": ["bra.1", "2029"],
    "Brazil - Red Bull Bragantino (Brasileirao)": ["bra.1", "6079"],
    "Brazil - Remo (Brasileirao)": ["bra.1", "4936"],
    "Brazil - Santos (Brasileirao)": ["bra.1", "2674"],
    "Brazil - Sao Paulo (Brasileirao)": ["bra.1", "2026"],
    "Brazil - Vasco da Gama (Brasileirao)": ["bra.1", "3454"],
    "Brazil - Vitoria (Brasileirao)": ["bra.1", "3457"],
    "England - AFC Bournemouth (Premier League)": ["eng.1", "349"],
    "England - Arsenal (Premier League)": ["eng.1", "359"],
    "England - Aston Villa (Premier League)": ["eng.1", "362"],
    "England - Brentford (Premier League)": ["eng.1", "337"],
    "England - Brighton & Hove Albion (Premier League)": ["eng.1", "331"],
    "England - Chelsea (Premier League)": ["eng.1", "363"],
    "England - Coventry City (Premier League)": ["eng.1", "388"],
    "England - Crystal Palace (Premier League)": ["eng.1", "384"],
    "England - Everton (Premier League)": ["eng.1", "368"],
    "England - Fulham (Premier League)": ["eng.1", "370"],
    "England - Hull City (Premier League)": ["eng.1", "306"],
    "England - Ipswich Town (Premier League)": ["eng.1", "373"],
    "England - Leeds United (Premier League)": ["eng.1", "357"],
    "England - Liverpool (Premier League)": ["eng.1", "364"],
    "England - Manchester City (Premier League)": ["eng.1", "382"],
    "England - Manchester United (Premier League)": ["eng.1", "360"],
    "England - Newcastle United (Premier League)": ["eng.1", "361"],
    "England - Nottingham Forest (Premier League)": ["eng.1", "393"],
    "England - Sunderland (Premier League)": ["eng.1", "366"],
    "England - Tottenham Hotspur (Premier League)": ["eng.1", "367"],
    "England - Birmingham City (Championship)": ["eng.2", "392"],
    "England - Blackburn Rovers (Championship)": ["eng.2", "365"],
    "England - Bolton Wanderers (Championship)": ["eng.2", "358"],
    "England - Bristol City (Championship)": ["eng.2", "333"],
    "England - Burnley (Championship)": ["eng.2", "379"],
    "England - Cardiff City (Championship)": ["eng.2", "347"],
    "England - Charlton Athletic (Championship)": ["eng.2", "372"],
    "England - Derby County (Championship)": ["eng.2", "374"],
    "England - Lincoln City (Championship)": ["eng.2", "314"],
    "England - Middlesbrough (Championship)": ["eng.2", "369"],
    "England - Millwall (Championship)": ["eng.2", "391"],
    "England - Norwich City (Championship)": ["eng.2", "381"],
    "England - Portsmouth (Championship)": ["eng.2", "385"],
    "England - Preston North End (Championship)": ["eng.2", "394"],
    "England - Queens Park Rangers (Championship)": ["eng.2", "334"],
    "England - Sheffield United (Championship)": ["eng.2", "398"],
    "England - Southampton (Championship)": ["eng.2", "376"],
    "England - Stoke City (Championship)": ["eng.2", "336"],
    "England - Swansea City (Championship)": ["eng.2", "318"],
    "England - Watford (Championship)": ["eng.2", "395"],
    "England - West Bromwich Albion (Championship)": ["eng.2", "383"],
    "England - West Ham United (Championship)": ["eng.2", "371"],
    "England - Wolverhampton Wanderers (Championship)": ["eng.2", "380"],
    "England - Wrexham (Championship)": ["eng.2", "352"],
    "England - Arsenal (Women's Super League)": ["eng.w.1", "19973"],
    "England - Aston Villa (Women's Super League)": ["eng.w.1", "20707"],
    "England - Birmingham City (Women's Super League)": ["eng.w.1", "19968"],
    "England - Brighton & Hove Albion (Women's Super League)": ["eng.w.1", "19976"],
    "England - Charlton Athletic (Women's Super League)": ["eng.w.1", "21035"],
    "England - Chelsea (Women's Super League)": ["eng.w.1", "19970"],
    "England - Crystal Palace (Women's Super League)": ["eng.w.1", "21037"],
    "England - Everton (Women's Super League)": ["eng.w.1", "19972"],
    "England - Liverpool (Women's Super League)": ["eng.w.1", "19971"],
    "England - London City Lionesses (Women's Super League)": ["eng.w.1", "21053"],
    "England - Manchester City (Women's Super League)": ["eng.w.1", "19257"],
    "England - Manchester United (Women's Super League)": ["eng.w.1", "20061"],
    "England - Tottenham Hotspur (Women's Super League)": ["eng.w.1", "20062"],
    "England - West Ham United (Women's Super League)": ["eng.w.1", "19975"],
    "France - AJ Auxerre (Ligue 1)": ["fra.1", "172"],
    "France - Angers (Ligue 1)": ["fra.1", "7868"],
    "France - AS Monaco (Ligue 1)": ["fra.1", "174"],
    "France - Brest (Ligue 1)": ["fra.1", "6997"],
    "France - Le Havre AC (Ligue 1)": ["fra.1", "3236"],
    "France - Le Mans (Ligue 1)": ["fra.1", "2697"],
    "France - Lens (Ligue 1)": ["fra.1", "175"],
    "France - Lille (Ligue 1)": ["fra.1", "166"],
    "France - Lorient (Ligue 1)": ["fra.1", "273"],
    "France - Lyon (Ligue 1)": ["fra.1", "167"],
    "France - Marseille (Ligue 1)": ["fra.1", "176"],
    "France - Nice (Ligue 1)": ["fra.1", "2502"],
    "France - Paris FC (Ligue 1)": ["fra.1", "6851"],
    "France - Paris Saint-Germain (Ligue 1)": ["fra.1", "160"],
    "France - Stade Rennais (Ligue 1)": ["fra.1", "169"],
    "France - Strasbourg (Ligue 1)": ["fra.1", "180"],
    "France - Toulouse (Ligue 1)": ["fra.1", "179"],
    "France - Troyes (Ligue 1)": ["fra.1", "170"],
    "Germany - 1. FC Union Berlin (Bundesliga)": ["ger.1", "598"],
    "Germany - Bayer Leverkusen (Bundesliga)": ["ger.1", "131"],
    "Germany - Bayern Munich (Bundesliga)": ["ger.1", "132"],
    "Germany - Borussia Dortmund (Bundesliga)": ["ger.1", "124"],
    "Germany - Borussia Monchengladbach (Bundesliga)": ["ger.1", "268"],
    "Germany - Eintracht Frankfurt (Bundesliga)": ["ger.1", "125"],
    "Germany - FC Augsburg (Bundesliga)": ["ger.1", "3841"],
    "Germany - FC Cologne (Bundesliga)": ["ger.1", "122"],
    "Germany - Hamburg SV (Bundesliga)": ["ger.1", "127"],
    "Germany - Mainz (Bundesliga)": ["ger.1", "2950"],
    "Germany - RB Leipzig (Bundesliga)": ["ger.1", "11420"],
    "Germany - SC Freiburg (Bundesliga)": ["ger.1", "126"],
    "Germany - SC Paderborn 07 (Bundesliga)": ["ger.1", "3307"],
    "Germany - Schalke 04 (Bundesliga)": ["ger.1", "133"],
    "Germany - SV Elversberg (Bundesliga)": ["ger.1", "10388"],
    "Germany - TSG Hoffenheim (Bundesliga)": ["ger.1", "7911"],
    "Germany - VfB Stuttgart (Bundesliga)": ["ger.1", "134"],
    "Germany - Werder Bremen (Bundesliga)": ["ger.1", "137"],
    "Italy - AC Milan (Serie A)": ["ita.1", "103"],
    "Italy - AS Roma (Serie A)": ["ita.1", "104"],
    "Italy - Atalanta (Serie A)": ["ita.1", "105"],
    "Italy - Bologna (Serie A)": ["ita.1", "107"],
    "Italy - Cagliari (Serie A)": ["ita.1", "2925"],
    "Italy - Como (Serie A)": ["ita.1", "2572"],
    "Italy - Fiorentina (Serie A)": ["ita.1", "109"],
    "Italy - Frosinone (Serie A)": ["ita.1", "4057"],
    "Italy - Genoa (Serie A)": ["ita.1", "3263"],
    "Italy - Internazionale (Serie A)": ["ita.1", "110"],
    "Italy - Juventus (Serie A)": ["ita.1", "111"],
    "Italy - Lazio (Serie A)": ["ita.1", "112"],
    "Italy - Lecce (Serie A)": ["ita.1", "113"],
    "Italy - Monza (Serie A)": ["ita.1", "4007"],
    "Italy - Napoli (Serie A)": ["ita.1", "114"],
    "Italy - Parma (Serie A)": ["ita.1", "115"],
    "Italy - Sassuolo (Serie A)": ["ita.1", "3997"],
    "Italy - Torino (Serie A)": ["ita.1", "239"],
    "Italy - Udinese (Serie A)": ["ita.1", "118"],
    "Italy - Venezia (Serie A)": ["ita.1", "17530"],
    "Japan - Avispa Fukuoka (J1 League)": ["jpn.1", "7107"],
    "Japan - Cerezo Osaka (J1 League)": ["jpn.1", "7109"],
    "Japan - Fagiano Okayama (J1 League)": ["jpn.1", "22522"],
    "Japan - FC Tokyo (J1 League)": ["jpn.1", "3384"],
    "Japan - Gamba Osaka (J1 League)": ["jpn.1", "7102"],
    "Japan - JEF United Ichihara-Chiba (J1 League)": ["jpn.1", "7111"],
    "Japan - Kashima Antlers (J1 League)": ["jpn.1", "7115"],
    "Japan - Kashiwa Reysol (J1 League)": ["jpn.1", "7476"],
    "Japan - Kawasaki Frontale (J1 League)": ["jpn.1", "7112"],
    "Japan - Kyoto Sanga (J1 League)": ["jpn.1", "21361"],
    "Japan - Machida Zelvia (J1 League)": ["jpn.1", "22167"],
    "Japan - Mito Hollyhock (J1 League)": ["jpn.1", "131701"],
    "Japan - Nagoya Grampus (J1 League)": ["jpn.1", "7108"],
    "Japan - Sanfrecce Hiroshima (J1 League)": ["jpn.1", "7114"],
    "Japan - Shimizu S-Pulse (J1 League)": ["jpn.1", "7104"],
    "Japan - Tokyo Verdy 1969 (J1 League)": ["jpn.1", "3393"],
    "Japan - Urawa Red Diamonds (J1 League)": ["jpn.1", "3385"],
    "Japan - V-Varen Nagasaki (J1 League)": ["jpn.1", "19001"],
    "Japan - Vissel Kobe (J1 League)": ["jpn.1", "7477"],
    "Japan - Yokohama F. Marinos (J1 League)": ["jpn.1", "7116"],
    "Mexico - America (Liga MX)": ["mex.1", "227"],
    "Mexico - Atlante (Liga MX)": ["mex.1", "226"],
    "Mexico - Atlas (Liga MX)": ["mex.1", "216"],
    "Mexico - Atletico de San Luis (Liga MX)": ["mex.1", "15720"],
    "Mexico - Cruz Azul (Liga MX)": ["mex.1", "218"],
    "Mexico - FC Juarez (Liga MX)": ["mex.1", "17851"],
    "Mexico - Guadalajara (Liga MX)": ["mex.1", "219"],
    "Mexico - Leon (Liga MX)": ["mex.1", "228"],
    "Mexico - Monterrey (Liga MX)": ["mex.1", "220"],
    "Mexico - Necaxa (Liga MX)": ["mex.1", "229"],
    "Mexico - Pachuca (Liga MX)": ["mex.1", "234"],
    "Mexico - Puebla (Liga MX)": ["mex.1", "231"],
    "Mexico - Pumas UNAM (Liga MX)": ["mex.1", "233"],
    "Mexico - Queretaro (Liga MX)": ["mex.1", "222"],
    "Mexico - Santos (Liga MX)": ["mex.1", "225"],
    "Mexico - Tigres UANL (Liga MX)": ["mex.1", "232"],
    "Mexico - Tijuana (Liga MX)": ["mex.1", "10125"],
    "Mexico - Toluca (Liga MX)": ["mex.1", "223"],
    "Netherlands - ADO Den Haag (Eredivisie)": ["ned.1", "2726"],
    "Netherlands - Ajax Amsterdam (Eredivisie)": ["ned.1", "139"],
    "Netherlands - AZ Alkmaar (Eredivisie)": ["ned.1", "140"],
    "Netherlands - Excelsior (Eredivisie)": ["ned.1", "2566"],
    "Netherlands - FC Groningen (Eredivisie)": ["ned.1", "145"],
    "Netherlands - FC Twente (Eredivisie)": ["ned.1", "152"],
    "Netherlands - FC Utrecht (Eredivisie)": ["ned.1", "153"],
    "Netherlands - Feyenoord Rotterdam (Eredivisie)": ["ned.1", "142"],
    "Netherlands - Fortuna Sittard (Eredivisie)": ["ned.1", "143"],
    "Netherlands - Go Ahead Eagles (Eredivisie)": ["ned.1", "3706"],
    "Netherlands - Heerenveen (Eredivisie)": ["ned.1", "146"],
    "Netherlands - NEC Nijmegen (Eredivisie)": ["ned.1", "147"],
    "Netherlands - PEC Zwolle (Eredivisie)": ["ned.1", "2565"],
    "Netherlands - PSV Eindhoven (Eredivisie)": ["ned.1", "148"],
    "Netherlands - SC Cambuur (Eredivisie)": ["ned.1", "3736"],
    "Netherlands - Sparta Rotterdam (Eredivisie)": ["ned.1", "151"],
    "Netherlands - Telstar (Eredivisie)": ["ned.1", "3735"],
    "Netherlands - Willem II (Eredivisie)": ["ned.1", "156"],
    "Portugal - Academico de Viseu (Primeira Liga)": ["por.1", "21607"],
    "Portugal - Alverca (Primeira Liga)": ["por.1", "21613"],
    "Portugal - Arouca (Primeira Liga)": ["por.1", "15784"],
    "Portugal - Benfica (Primeira Liga)": ["por.1", "1929"],
    "Portugal - Braga (Primeira Liga)": ["por.1", "2994"],
    "Portugal - C.D. Nacional (Primeira Liga)": ["por.1", "3472"],
    "Portugal - Casa Pia (Primeira Liga)": ["por.1", "21581"],
    "Portugal - Estoril (Primeira Liga)": ["por.1", "12216"],
    "Portugal - Estrela (Primeira Liga)": ["por.1", "21610"],
    "Portugal - FC Famalicao (Primeira Liga)": ["por.1", "12698"],
    "Portugal - FC Porto (Primeira Liga)": ["por.1", "437"],
    "Portugal - Gil Vicente (Primeira Liga)": ["por.1", "3699"],
    "Portugal - Maritimo (Primeira Liga)": ["por.1", "552"],
    "Portugal - Moreirense (Primeira Liga)": ["por.1", "3696"],
    "Portugal - Rio Ave (Primeira Liga)": ["por.1", "3822"],
    "Portugal - Santa Clara (Primeira Liga)": ["por.1", "12215"],
    "Portugal - Sporting CP (Primeira Liga)": ["por.1", "2250"],
    "Portugal - Vitoria de Guimaraes (Primeira Liga)": ["por.1", "5309"],
    "Scotland - Aberdeen (Premiership)": ["sco.1", "263"],
    "Scotland - Celtic (Premiership)": ["sco.1", "256"],
    "Scotland - Dundee (Premiership)": ["sco.1", "261"],
    "Scotland - Dundee United (Premiership)": ["sco.1", "264"],
    "Scotland - Falkirk (Premiership)": ["sco.1", "254"],
    "Scotland - Heart of Midlothian (Premiership)": ["sco.1", "262"],
    "Scotland - Hibernian (Premiership)": ["sco.1", "258"],
    "Scotland - Kilmarnock (Premiership)": ["sco.1", "260"],
    "Scotland - Motherwell (Premiership)": ["sco.1", "266"],
    "Scotland - Rangers (Premiership)": ["sco.1", "257"],
    "Scotland - St Johnstone (Premiership)": ["sco.1", "267"],
    "Scotland - St Mirren (Premiership)": ["sco.1", "250"],
    "Spain - Alaves (La Liga)": ["esp.1", "96"],
    "Spain - Athletic Club (La Liga)": ["esp.1", "93"],
    "Spain - Atletico Madrid (La Liga)": ["esp.1", "1068"],
    "Spain - Barcelona (La Liga)": ["esp.1", "83"],
    "Spain - Celta Vigo (La Liga)": ["esp.1", "85"],
    "Spain - Deportivo (La Liga)": ["esp.1", "90"],
    "Spain - Elche (La Liga)": ["esp.1", "3751"],
    "Spain - Espanyol (La Liga)": ["esp.1", "88"],
    "Spain - Getafe (La Liga)": ["esp.1", "2922"],
    "Spain - Levante (La Liga)": ["esp.1", "1538"],
    "Spain - Malaga (La Liga)": ["esp.1", "99"],
    "Spain - Osasuna (La Liga)": ["esp.1", "97"],
    "Spain - Racing Santander (La Liga)": ["esp.1", "87"],
    "Spain - Rayo Vallecano (La Liga)": ["esp.1", "101"],
    "Spain - Real Betis (La Liga)": ["esp.1", "244"],
    "Spain - Real Madrid (La Liga)": ["esp.1", "86"],
    "Spain - Real Sociedad (La Liga)": ["esp.1", "89"],
    "Spain - Sevilla (La Liga)": ["esp.1", "243"],
    "Spain - Valencia (La Liga)": ["esp.1", "94"],
    "Spain - Villarreal (La Liga)": ["esp.1", "102"],
    "Turkey - Alanyaspor (Super Lig)": ["tur.1", "9078"],
    "Turkey - Amed SFK (Super Lig)": ["tur.1", "132335"],
    "Turkey - Besiktas (Super Lig)": ["tur.1", "1895"],
    "Turkey - Caykur Rizespor (Super Lig)": ["tur.1", "7656"],
    "Turkey - Corum FK (Super Lig)": ["tur.1", "132334"],
    "Turkey - Erzurum BB (Super Lig)": ["tur.1", "19267"],
    "Turkey - Eyupspor (Super Lig)": ["tur.1", "20729"],
    "Turkey - Fenerbahce (Super Lig)": ["tur.1", "436"],
    "Turkey - Galatasaray (Super Lig)": ["tur.1", "432"],
    "Turkey - Gaziantep FK (Super Lig)": ["tur.1", "20070"],
    "Turkey - Genclerbirligi (Super Lig)": ["tur.1", "996"],
    "Turkey - Goztepe (Super Lig)": ["tur.1", "789"],
    "Turkey - Istanbul Basaksehir (Super Lig)": ["tur.1", "7914"],
    "Turkey - Kasimpasa (Super Lig)": ["tur.1", "6870"],
    "Turkey - Kocaelispor (Super Lig)": ["tur.1", "995"],
    "Turkey - Konyaspor (Super Lig)": ["tur.1", "7648"],
    "Turkey - Samsunspor (Super Lig)": ["tur.1", "11429"],
    "Turkey - Trabzonspor (Super Lig)": ["tur.1", "997"],
    "USA & Canada - Atlanta United FC (MLS)": ["usa.1", "18418"],
    "USA & Canada - Austin FC (MLS)": ["usa.1", "20906"],
    "USA & Canada - CF Montreal (MLS)": ["usa.1", "9720"],
    "USA & Canada - Charlotte FC (MLS)": ["usa.1", "21300"],
    "USA & Canada - Chicago Fire FC (MLS)": ["usa.1", "182"],
    "USA & Canada - Colorado Rapids (MLS)": ["usa.1", "184"],
    "USA & Canada - Columbus Crew (MLS)": ["usa.1", "183"],
    "USA & Canada - D.C. United (MLS)": ["usa.1", "193"],
    "USA & Canada - FC Cincinnati (MLS)": ["usa.1", "18267"],
    "USA & Canada - FC Dallas (MLS)": ["usa.1", "185"],
    "USA & Canada - Houston Dynamo FC (MLS)": ["usa.1", "6077"],
    "USA & Canada - Inter Miami CF (MLS)": ["usa.1", "20232"],
    "USA & Canada - LA Galaxy (MLS)": ["usa.1", "187"],
    "USA & Canada - LAFC (MLS)": ["usa.1", "18966"],
    "USA & Canada - Minnesota United FC (MLS)": ["usa.1", "17362"],
    "USA & Canada - Nashville SC (MLS)": ["usa.1", "18986"],
    "USA & Canada - New England Revolution (MLS)": ["usa.1", "189"],
    "USA & Canada - New York City FC (MLS)": ["usa.1", "17606"],
    "USA & Canada - Orlando City SC (MLS)": ["usa.1", "12011"],
    "USA & Canada - Philadelphia Union (MLS)": ["usa.1", "10739"],
    "USA & Canada - Portland Timbers (MLS)": ["usa.1", "9723"],
    "USA & Canada - Real Salt Lake (MLS)": ["usa.1", "4771"],
    "USA & Canada - Red Bull New York (MLS)": ["usa.1", "190"],
    "USA & Canada - San Diego FC (MLS)": ["usa.1", "22529"],
    "USA & Canada - San Jose Earthquakes (MLS)": ["usa.1", "191"],
    "USA & Canada - Seattle Sounders FC (MLS)": ["usa.1", "9726"],
    "USA & Canada - Sporting Kansas City (MLS)": ["usa.1", "186"],
    "USA & Canada - St. Louis CITY SC (MLS)": ["usa.1", "21812"],
    "USA & Canada - Toronto FC (MLS)": ["usa.1", "7318"],
    "USA & Canada - Vancouver Whitecaps (MLS)": ["usa.1", "9727"],
    "USA & Canada - Angel City FC (NWSL)": ["usa.nwsl", "21422"],
    "USA & Canada - Bay FC (NWSL)": ["usa.nwsl", "22187"],
    "USA & Canada - Boston Legacy FC (NWSL)": ["usa.nwsl", "131562"],
    "USA & Canada - Chicago Stars FC (NWSL)": ["usa.nwsl", "15360"],
    "USA & Canada - Denver Summit FC (NWSL)": ["usa.nwsl", "131563"],
    "USA & Canada - Gotham FC (NWSL)": ["usa.nwsl", "15364"],
    "USA & Canada - Houston Dash (NWSL)": ["usa.nwsl", "17346"],
    "USA & Canada - Kansas City Current (NWSL)": ["usa.nwsl", "20907"],
    "USA & Canada - North Carolina Courage (NWSL)": ["usa.nwsl", "15366"],
    "USA & Canada - Orlando Pride (NWSL)": ["usa.nwsl", "18206"],
    "USA & Canada - Portland Thorns FC (NWSL)": ["usa.nwsl", "15362"],
    "USA & Canada - Racing Louisville FC (NWSL)": ["usa.nwsl", "20905"],
    "USA & Canada - San Diego Wave FC (NWSL)": ["usa.nwsl", "21423"],
    "USA & Canada - Seattle Reign FC (NWSL)": ["usa.nwsl", "15363"],
    "USA & Canada - Utah Royals (NWSL)": ["usa.nwsl", "19141"],
    "USA & Canada - Washington Spirit (NWSL)": ["usa.nwsl", "15365"],
}


# Standard offset in hours and the daylight-saving rule each zone follows.
ZONES = {
    "pacific": [-8, "us"],
    "mountain": [-7, "us"],
    "central": [-6, "us"],
    "eastern": [-5, "us"],
    "alaska": [-9, "us"],
    "hawaii": [-10, ""],
    "utc": [0, ""],
    "uk": [0, "eu"],
    "central_europe": [1, "eu"],
    "eastern_europe": [2, "eu"],
    "turkey": [3, ""],
    "iceland": [0, ""],
}

MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

ACCENTS = {
    "á": "a", "à": "a", "â": "a", "ä": "a", "ã": "a", "å": "a",
    "é": "e", "è": "e", "ê": "e", "ë": "e",
    "í": "i", "ì": "i", "î": "i", "ï": "i",
    "ó": "o", "ò": "o", "ô": "o", "ö": "o", "õ": "o", "ø": "o",
    "ú": "u", "ù": "u", "û": "u", "ü": "u",
    "ñ": "n", "ç": "c", "ş": "s", "ğ": "g", "ı": "i", "ß": "ss",
    "Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U", "Ü": "U", "Ö": "O", "Ñ": "N",
}

GREY = "#8A8A8A"
DIM_CHIP = "#505050"
WIN = "green"
LOSS = "red"
DRAW = "amber"
LIVE = "red"


# ---------- small helpers ----------

def get(obj, key, fallback = None):
    if type(obj) != "dict":
        return fallback
    value = obj.get(key, fallback)
    return fallback if value == None else value

def first(value):
    return value[0] if type(value) == "list" and len(value) > 0 else {}

def fold(text):
    out = ""
    for ch in str(text).elems():
        out += ACCENTS.get(ch, ch)
    return out

def display(text):
    # Panel fonts are ASCII uppercase; fold accents so "Atlético" still draws.
    return fold(text).upper()

def score_text(value):
    if type(value) == "dict":
        value = get(value, "displayValue", get(value, "value", ""))
    if type(value) == "float":
        return str(int(value))
    text = str(value).strip() if value != None else ""
    return text if text != "" and text.isdigit() else "-"

def fit(c, text, font, small, width):
    return font if c.text_width(text, font) <= width else small


# ---------- colors ----------

def hex_brightness(hexcolor):
    h = str(hexcolor).lstrip("#")
    if len(h) != 6:
        return -1
    digits = "0123456789abcdef"
    vals = []
    for i in [0, 2, 4]:
        hi = digits.find(h[i].lower())
        lo = digits.find(h[i + 1].lower())
        if hi < 0 or lo < 0:
            return -1
        vals.append(hi * 16 + lo)
    return (vals[0] * 299 + vals[1] * 587 + vals[2] * 114) // 1000

def on_color(color):
    # Plain text on a filled bar: black on light colors, white on dark ones.
    return "black" if hex_brightness(color) >= 140 else "white"

def team_color(team):
    # ESPN's primary color, unless it is too dark to read on an LED panel.
    for key in ["color", "alternateColor"]:
        value = str(get(team, key, ""))
        b = hex_brightness(value)
        if b >= 45:
            return "#" + value.lstrip("#")
    return DIM_CHIP


# ---------- time ----------

def days_from_civil(y, m, d):
    y = y - 1 if m <= 2 else y
    era = y // 400
    yoe = y - era * 400
    mp = m - 3 if m > 2 else m + 9
    doy = (153 * mp + 2) // 5 + d - 1
    return era * 146097 + yoe * 365 + yoe // 4 - yoe // 100 + doy - 719468

def civil_from_days(z):
    z = z + 719468
    era = z // 146097
    doe = z - era * 146097
    yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    mp = (5 * doy + 2) // 153
    d = doy - (153 * mp + 2) // 5 + 1
    m = mp + 3 if mp < 10 else mp - 9
    y = yoe + era * 400 + (1 if m <= 2 else 0)
    return [y, m, d]

def weekday(days):
    return (days + 4) % 7  # 0 = Sunday

def nth_sunday(y, m, n):
    d1 = days_from_civil(y, m, 1)
    return d1 + (7 - weekday(d1)) % 7 + 7 * (n - 1)

def last_sunday(y, m):
    dn = days_from_civil(y, m + 1, 1) - 1 if m < 12 else days_from_civil(y + 1, 1, 1) - 1
    return dn - weekday(dn)

def utc_minutes(iso):
    # ESPN dates look like 2026-10-11T15:30Z.
    if type(iso) != "string" or len(iso) < 16:
        return None
    digits = iso[0:4] + iso[5:7] + iso[8:10] + iso[11:13] + iso[14:16]
    if not digits.isdigit():
        return None
    days = days_from_civil(int(iso[0:4]), int(iso[5:7]), int(iso[8:10]))
    return days * 1440 + int(iso[11:13]) * 60 + int(iso[14:16])

def offset_minutes(zone, utc):
    info = ZONES.get(zone, ZONES["pacific"])
    std = info[0] * 60
    year = civil_from_days(utc // 1440)[0]
    dst = False
    if info[1] == "us":
        start = nth_sunday(year, 3, 2) * 1440 + 120 - std
        end = nth_sunday(year, 11, 1) * 1440 + 120 - (std + 60)
        dst = utc >= start and utc < end
    elif info[1] == "eu":
        start = last_sunday(year, 3) * 1440 + 60
        end = last_sunday(year, 10) * 1440 + 60
        dst = utc >= start and utc < end
    return std + (60 if dst else 0)

def local_parts(utc, zone):
    local = utc + offset_minutes(zone, utc)
    days = local // 1440
    ymd = civil_from_days(days)
    mins = local % 1440
    return {"days": days, "month": ymd[1], "day": ymd[2], "wd": weekday(days), "hour": mins // 60, "minute": mins % 60}

def clock_text(p):
    h = p["hour"] % 12
    h = 12 if h == 0 else h
    m = p["minute"]
    return str(h) + ":" + ("0" if m < 10 else "") + str(m) + ("PM" if p["hour"] >= 12 else "AM")

def date_text(p):
    return MONTHS[p["month"] - 1] + " " + str(p["day"])


# ---------- data ----------

def team_detail(slug, tid):
    resp = http.get(SITE + slug + "/teams/" + tid, ttl_seconds = 60)
    if resp["status_code"] != 200:
        return None
    team = get(resp["json"], "team", {})
    return team if get(team, "id", "") != "" else None

def load_club(ctx):
    pick = TEAMS.get(ctx.inputs.get("team", DEFAULT_TEAM), TEAMS[DEFAULT_TEAM])
    slug = pick[0]
    team = team_detail(slug, pick[1])
    if team == None:
        return None
    # nextEvent is only filled in under the team's current league.
    current = get(get(team, "defaultLeague", {}), "slug", "")
    if current != "" and current != slug:
        moved = team_detail(current, pick[1])
        if moved != None:
            slug = current
            team = moved
    resp = http.get(SITE + slug + "/teams", ttl_seconds = 86400)
    teams = []
    if resp["status_code"] == 200:
        teams = [get(e, "team", {}) for e in get(first(get(first(get(resp["json"], "sports", [])), "leagues", [])), "teams", [])]
    name = LEAGUE_NAMES.get(slug, display(get(get(team, "defaultLeague", {}), "shortName", "LEAGUE")))
    return {"id": str(team["id"]), "slug": slug, "league": name, "team": team, "teams": teams}

def side(competitor, league_teams):
    team = get(competitor, "team", {})
    tid = str(get(team, "id", ""))
    colored = team
    for t in league_teams:
        if str(get(t, "id", "")) == tid:
            colored = t
    return {
        "id": tid,
        "abbr": display(get(team, "abbreviation", "???"))[:4],
        "color": team_color(colored),
        "score": score_text(get(competitor, "score", "")),
        "home": get(competitor, "homeAway", "") == "home",
    }

def normalize(event, league_teams):
    comp = first(get(event, "competitions", []))
    sides = [side(x, league_teams) for x in get(comp, "competitors", [])]
    if len(sides) != 2:
        return None
    if not sides[0]["home"] and sides[1]["home"]:
        sides = [sides[1], sides[0]]
    status = get(comp, "status", get(event, "status", {}))
    stype = get(status, "type", {})
    return {
        "home": sides[0],
        "away": sides[1],
        "state": get(stype, "state", ""),
        "short": display(get(stype, "shortDetail", "")),
        "clock": display(get(status, "displayClock", "")),
        "utc": utc_minutes(get(event, "date", "")),
        "competition": competition_name(get(event, "league", {})),
    }

def competition_name(league):
    name = display(get(league, "abbreviation", get(league, "shortName", get(league, "name", ""))))
    for prefix in ["UEFA ", "ENGLISH ", "SPANISH ", "ITALIAN ", "GERMAN ", "FRENCH "]:
        if name.startswith(prefix):
            name = name[len(prefix):]
    return name

def last_result(club):
    resp = http.get(WEB + club["id"] + "/schedule", ttl_seconds = 900)
    if resp["status_code"] != 200:
        return None, "offline"
    best = None
    best_date = ""
    for event in get(resp["json"], "events", []):
        comp = first(get(event, "competitions", []))
        if get(get(get(comp, "status", {}), "type", {}), "state", "") != "post":
            continue
        date = get(event, "date", "")
        if date > best_date:
            best = event
            best_date = date
    return best, ""


# ---------- drawing ----------

def chip(c, x, y, s, highlight):
    # A 30x13 scorebug chip in the club's own color.
    c.rect(x, y, x + 29, y + 12, fill = s["color"])
    for px in [[x, y], [x + 29, y], [x, y + 12], [x + 29, y + 12]]:
        c.pixel(px[0], px[1], "black")
    font = fit(c, s["abbr"], "5x7", "4x5", 26)
    c.text_stroke(s["abbr"], x + 15, y + (3 if font == "5x7" else 4), font = font, color = "white", align = "center")
    if highlight:
        c.line(x + 3, y + 14, x + 26, y + 14, "white")

def heading(c, text, color = GREY):
    font = fit(c, text, "4x5", "3x4", 116)
    c.text(text, 64, 1, font = font, color = color, align = "center")

def footer(c, text, color):
    font = fit(c, text, "4x5", "3x4", 116)
    c.text(text, 64, 26, font = font, color = color, align = "center")

def message(c, top, bottom, top_color = "white"):
    c.clear()
    c.text(top, 64, 8, font = fit(c, top, "5x7", "4x5", 116), color = top_color, align = "center")
    c.text(bottom, 64, 20, font = fit(c, bottom, "4x5", "3x4", 116), color = GREY, align = "center")

def offline(c):
    message(c, "NO SCORES DATA", "ESPN UNAVAILABLE", "amber")

def result_of(match, team_id):
    mine = match["home"] if match["home"]["id"] == team_id else match["away"]
    theirs = match["away"] if mine == match["home"] else match["home"]
    if mine["score"] == "-" or theirs["score"] == "-":
        return ["FULL TIME", "white"]
    a = int(mine["score"])
    b = int(theirs["score"])
    if a > b:
        return ["WIN", WIN]
    if a < b:
        return ["LOSS", LOSS]
    return ["DRAW", DRAW]

def draw_fixture(c, match, team_id, center, center_font, bottom, bottom_color):
    heading(c, match["competition"])
    chip(c, 6, 9, match["home"], match["home"]["id"] == team_id)
    chip(c, 92, 9, match["away"], match["away"]["id"] == team_id)
    font = fit(c, center, center_font, "5x7", 52)
    h = 12 if font == center_font and center_font == "scoretext" else 7
    c.text(center, 64, 9 + (13 - h) // 2, font = font, color = "white", align = "center")
    footer(c, bottom, bottom_color)

def score_line(match):
    return match["home"]["score"] + "-" + match["away"]["score"]

# ---------- pages ----------

def match(c, ctx):
    c.clear()
    club = load_club(ctx)
    if club == None:
        offline(c)
        return
    event = first(get(club["team"], "nextEvent", []))
    m = normalize(event, club["teams"]) if event else None
    if m == None:
        message(c, display(get(club["team"], "shortDisplayName", "")), "NO UPCOMING MATCH")
        return
    tid = club["id"]
    zone = ctx.inputs.get("timezone", "pacific")
    if m["state"] == "in":
        detail = m["short"] if m["short"] in ["HT", "FT", "ET", "PENS"] else m["clock"]
        draw_fixture(c, m, tid, score_line(m), "scoretext", "LIVE  " + detail, LIVE)
    elif m["state"] == "post":
        r = result_of(m, tid)
        draw_fixture(c, m, tid, score_line(m), "scoretext", "FULL TIME  " + r[0], r[1])
    elif m["utc"] == None:
        draw_fixture(c, m, tid, "VS", "5x7", "TIME TBD", "white")
    else:
        kick = local_parts(m["utc"], zone)
        today = local_parts(ctx.now.unix // 60, zone)
        gap = kick["days"] - today["days"]
        if gap == 0:
            when = "TODAY"
        elif gap == 1:
            when = "TOMORROW"
        elif gap < 7:
            when = DAYS[kick["wd"]] + " " + date_text(kick)
        else:
            when = date_text(kick) + "  IN " + str(gap) + " DAYS"
        draw_fixture(c, m, tid, clock_text(kick), "5x7", when, "white")

def last_match(c, ctx):
    c.clear()
    club = load_club(ctx)
    if club == None:
        offline(c)
        return
    event, err = last_result(club)
    if err != "":
        offline(c)
        return
    m = normalize(event, club["teams"]) if event else None
    if m == None:
        message(c, display(get(club["team"], "shortDisplayName", "")), "NO RESULTS YET")
        return
    tid = club["id"]
    r = result_of(m, tid)
    when = date_text(local_parts(m["utc"], ctx.inputs.get("timezone", "pacific"))) if m["utc"] != None else ""
    draw_fixture(c, m, tid, score_line(m), "scoretext", r[0] + "  " + when, r[1])

def stat(entry, name):
    for s in get(entry, "stats", []):
        if get(s, "name", "") == name:
            v = get(s, "value", None)
            if type(v) in ["int", "float"]:
                return int(v)
            d = str(get(s, "displayValue", "")).replace("+", "")
            if d.lstrip("-").isdigit():
                return int(d)
    return 0

def ordinal(n):
    if n <= 0:
        return "--"
    suffix = "TH"
    if n % 100 not in [11, 12, 13]:
        suffix = {1: "ST", 2: "ND", 3: "RD"}.get(n % 10, "TH")
    return str(n) + suffix

def table(c, ctx):
    c.clear()
    club = load_club(ctx)
    if club == None:
        offline(c)
        return
    resp = http.get(STANDINGS + club["slug"] + "/standings", ttl_seconds = 1800)
    if resp["status_code"] != 200:
        offline(c)
        return
    tid = club["id"]
    rows = []
    group_name = ""
    for group in get(resp["json"], "children", []):
        entries = get(get(group, "standings", {}), "entries", [])
        if tid in [str(get(get(e, "team", {}), "id", "")) for e in entries]:
            rows = sorted(entries, key = lambda e: stat(e, "rank"))
            group_name = display(get(group, "abbreviation", ""))
    idx = -1
    for i, e in enumerate(rows):
        if str(get(get(e, "team", {}), "id", "")) == tid:
            idx = i
    if idx < 0:
        message(c, club["league"], "NO TABLE YET")
        return

    me = rows[idx]
    color = team_color(club["team"])

    # Left: position hero with points and record.
    title = club["league"]
    if group_name in ["EAST", "WEST"] or group_name.startswith("GROUP"):
        title = title + " " + group_name
    c.text(title, 6, 1, font = fit(c, title, "4x5", "3x4", 58), color = GREY)
    c.text(ordinal(stat(me, "rank")), 6, 9, font = "scoretext", color = "white")
    c.text(str(stat(me, "points")) + " PTS", 6, 26, font = "4x5", color = color)

    # Right: four-row slice of the table around the team.
    start = max(0, min(idx - 1, len(rows) - 4))
    for n in range(4):
        i = start + n
        if i >= len(rows):
            break
        e = rows[i]
        y = 1 + n * 8
        abbr = display(get(get(e, "team", {}), "abbreviation", ""))[:4]
        is_me = i == idx
        rank = str(stat(e, "rank"))
        pts = str(stat(e, "points"))
        if is_me:
            c.rect(66, y - 1, 121, y + 5, fill = color)
        ink = on_color(color) if is_me else "white"
        dim = ink if is_me else GREY
        c.text(rank, 76, y, font = "4x5", color = dim, align = "right")
        c.text(abbr, 80, y, font = "4x5", color = ink)
        c.text(pts, 119, y, font = "4x5", color = dim, align = "right")
