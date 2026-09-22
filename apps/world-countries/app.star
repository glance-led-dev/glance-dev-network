# World Countries - one UN member state at a time. (192x32)
#
#   [flag]  NAME
#           CONTINENT                      POWER RANK #12
#           LANG  VIETNAMESE
#           POP 89.7M                      AREA 331K KM2
#
# Countries: the 193 UN member states, and only those. Power rank: the U.S.
# News 2026 overall power ranking, as reproduced by World Population Review
# (https://worldpopulationreview.com/country-rankings/most-powerful-countries).
# That index ranks 100 countries. The other 93 are shown as NOT IN TOP 100.
#
# Nothing is fetched. The table is built into DATA from ChatGPT generated
# spreadsheet, the flags are PNGs in assets/ named by ISO code, and the country
# on screen is a pure function of the clock, so two panels side by side agree.

INK = "#08090D"          # near-black ground
NAME = "#F4F7FF"         # the country name
LABEL = "#6E7A94"        # POWER RANK, LANG, POP, AREA
VALUE = "#C9CCD8"        # the facts themselves
RANK = "#F0B44D"         # the rank number

# Each continent in its own colour, so the second row reads at a glance. A
# two-continent country takes the colour of the first one named.
CONTINENT_COLORS = {
    "AFRICA": "#F2BE45",
    "ASIA": "#FF5A5A",
    "EUROPE": "#44CEF6",
    "NORTH AMERICA": "#AFDD22",
    "SOUTH AMERICA": "#25F8CB",
    "OCEANIA": "#CCA4E3",
}

EDGER = 185              # 6 px clear at the right edge
FLAG_X = 6               # the flag box: 40 px wide, flags centred in it
FLAG_W = 40
TEXT_X = 50              # the text column runs from here to EDGER: 136 px
ROW_NAME = 0
ROW_CONT = 9
ROW_LANG = 17
ROW_FACTS = 25
GAP = 4                  # between a label and its value

# HOLD matches `refresh`. The app is stateless, so the country advances with
# the wall clock; a HOLD shorter than the render interval would only skip.
HOLD = 60

HEXCHARS = "0123456789ABCDEF"

# [display name, ISO 3166 code, continent, [languages], population, area km2,
#  power rank, flag width, flag height]. Population and area are pre-rounded
# to three significant figures (1.41B, 331K). Rank 0 means the country is not
# in the top-100 index. Flag width and height are as drawn, worked out from
# each PNG when DATA was built.
DATA = [
    ["AFGHANISTAN", "AF", "ASIA", ["PUSHTO", "UZBEK", "TURKMEN"], "26M", "652K", 0, 40, 27],
    ["ALBANIA", "AL", "EUROPE", ["ALBANIAN"], "2.9M", "28.7K", 96, 40, 29],
    ["ALGERIA", "DZ", "AFRICA", ["ARABIC"], "38.7M", "2.38M", 79, 40, 27],
    ["ANDORRA", "AD", "EUROPE", ["CATALAN"], "79K", "468", 0, 40, 28],
    ["ANGOLA", "AO", "AFRICA", ["PORTUGUESE"], "24.4M", "1.25M", 76, 40, 27],
    ["ANTIGUA AND BARBUDA", "AG", "NORTH AMERICA", ["ENGLISH"], "86.3K", "442", 0, 40, 27],
    ["ARGENTINA", "AR", "SOUTH AMERICA", ["SPANISH", "GUARANI"], "42.7M", "2.78M", 44, 40, 25],
    ["ARMENIA", "AM", "ASIA", ["ARMENIAN", "RUSSIAN"], "3.01M", "29.7K", 80, 40, 20],
    ["AUSTRALIA", "AU", "OCEANIA", ["ENGLISH"], "23.7M", "7.69M", 27, 40, 20],
    ["AUSTRIA", "AT", "EUROPE", ["GERMAN"], "8.53M", "83.9K", 30, 40, 27],
    ["AZERBAIJAN", "AZ", "ASIA/EUROPE", ["AZERBAIJANI", "ARMENIAN"], "9.55M", "86.6K", 0, 40, 20],
    ["BAHAMAS", "BS", "NORTH AMERICA", ["ENGLISH"], "319K", "13.9K", 0, 40, 20],
    ["BAHRAIN", "BH", "ASIA", ["ARABIC"], "1.32M", "765", 97, 40, 24],
    ["BANGLADESH", "BD", "ASIA", ["BENGALI"], "157M", "148K", 49, 40, 24],
    ["BARBADOS", "BB", "NORTH AMERICA", ["ENGLISH"], "285K", "430", 0, 40, 27],
    ["BELARUS", "BY", "EUROPE", ["BELARUSIAN", "RUSSIAN"], "9.48M", "208K", 57, 40, 20],
    ["BELGIUM", "BE", "EUROPE", ["DUTCH", "FRENCH", "GERMAN"], "11.2M", "30.5K", 26, 34, 30],
    ["BELIZE", "BZ", "NORTH AMERICA", ["ENGLISH", "SPANISH"], "350K", "23K", 0, 40, 24],
    ["BENIN", "BJ", "AFRICA", ["FRENCH"], "9.99M", "113K", 0, 40, 27],
    ["BHUTAN", "BT", "ASIA", ["DZONGKHA"], "755K", "38.4K", 0, 40, 27],
    ["BOLIVIA", "BO", "SOUTH AMERICA", ["SPANISH", "AYMARA", "QUECHUA"], "10M", "1.1M", 0, 40, 27],
    ["BOSNIA AND HERZEGOVINA", "BA", "EUROPE", ["BOSNIAN", "CROATIAN", "SERBIAN"], "3.79M", "51.2K", 84, 40, 20],
    ["BOTSWANA", "BW", "AFRICA", ["ENGLISH", "TSWANA"], "2.02M", "582K", 0, 40, 27],
    ["BRAZIL", "BR", "SOUTH AMERICA", ["PORTUGUESE"], "204M", "8.52M", 17, 40, 28],
    ["BRUNEI", "BN", "ASIA", ["MALAY"], "393K", "5.76K", 0, 40, 20],
    ["BULGARIA", "BG", "EUROPE", ["BULGARIAN"], "7.25M", "111K", 53, 40, 24],
    ["BURKINA FASO", "BF", "AFRICA", ["FRENCH", "FULAH"], "17.3M", "273K", 0, 40, 27],
    ["BURUNDI", "BI", "AFRICA", ["FRENCH", "RUNDI"], "9.53M", "27.8K", 0, 40, 24],
    ["CABO VERDE", "CV", "AFRICA", ["PORTUGUESE"], "518K", "4.03K", 0, 40, 24],
    ["CAMBODIA", "KH", "ASIA", ["KHMER"], "15.2M", "181K", 69, 40, 26],
    ["CAMEROON", "CM", "AFRICA", ["ENGLISH", "FRENCH"], "20.4M", "475K", 0, 40, 27],
    ["CANADA", "CA", "NORTH AMERICA", ["ENGLISH", "FRENCH"], "35.5M", "9.98M", 13, 40, 20],
    ["CENTRAL AFRICAN REPUBLIC", "CF", "AFRICA", ["FRENCH", "SANGO"], "4.71M", "623K", 0, 40, 27],
    ["CHAD", "TD", "AFRICA", ["FRENCH", "ARABIC"], "13.2M", "1.28M", 0, 40, 27],
    ["CHILE", "CL", "SOUTH AMERICA", ["SPANISH"], "17.8M", "756K", 50, 40, 27],
    ["CHINA", "CN", "ASIA", ["CHINESE"], "1.37B", "9.64M", 1, 40, 27],
    ["COLOMBIA", "CO", "SOUTH AMERICA", ["SPANISH"], "47.9M", "1.14M", 41, 40, 27],
    ["COMOROS", "KM", "AFRICA", ["ARABIC", "FRENCH"], "764K", "1.86K", 0, 40, 24],
    ["CONGO", "CG", "AFRICA", ["FRENCH", "LINGALA"], "4.56M", "342K", 0, 40, 27],
    ["COSTA RICA", "CR", "NORTH AMERICA", ["SPANISH"], "4.71M", "51.1K", 58, 40, 24],
    ["COTE D'IVOIRE", "CI", "AFRICA", ["FRENCH"], "23.8M", "322K", 0, 40, 27],
    ["CROATIA", "HR", "EUROPE", ["CROATIAN"], "4.27M", "56.6K", 62, 40, 20],
    ["CUBA", "CU", "NORTH AMERICA", ["SPANISH"], "11.2M", "110K", 0, 40, 20],
    ["CYPRUS", "CY", "EUROPE", ["MODERN GREEK", "TURKISH", "ARMENIAN"], "858K", "9.25K", 92, 40, 27],
    ["CZECHIA", "CZ", "EUROPE", ["CZECH"], "10.9M", "78.9K", 28, 40, 27],
    ["NORTH KOREA", "KP", "ASIA", ["KOREAN"], "25M", "121K", 0, 40, 20],
    ["DR CONGO", "CD", "AFRICA", ["FRENCH", "LINGALA", "KONGO", "SWAHILI", "LUBA-KATANGA"], "69.4M", "2.34M", 0, 40, 30],
    ["DENMARK", "DK", "EUROPE", ["DANISH"], "5.66M", "43.1K", 36, 40, 30],
    ["DJIBOUTI", "DJ", "AFRICA", ["FRENCH", "ARABIC"], "886K", "23.2K", 0, 40, 27],
    ["DOMINICA", "DM", "NORTH AMERICA", ["ENGLISH"], "71.3K", "751", 0, 40, 20],
    ["DOMINICAN REPUBLIC", "DO", "NORTH AMERICA", ["SPANISH"], "10.4M", "48.7K", 63, 40, 27],
    ["ECUADOR", "EC", "SOUTH AMERICA", ["SPANISH"], "15.9M", "277K", 73, 40, 27],
    ["EGYPT", "EG", "AFRICA/ASIA", ["ARABIC"], "87.7M", "1M", 35, 40, 27],
    ["EL SALVADOR", "SV", "NORTH AMERICA", ["SPANISH"], "6.4M", "21K", 87, 40, 23],
    ["EQUATORIAL GUINEA", "GQ", "AFRICA", ["SPANISH", "FRENCH"], "1.43M", "28.1K", 0, 40, 27],
    ["ERITREA", "ER", "AFRICA", ["TIGRINYA", "ARABIC", "ENGLISH"], "6.54M", "118K", 0, 40, 20],
    ["ESTONIA", "EE", "EUROPE", ["ESTONIAN"], "1.32M", "45.2K", 75, 40, 25],
    ["ESWATINI", "SZ", "AFRICA", ["ENGLISH", "SWATI"], "1.11M", "17.4K", 0, 40, 27],
    ["ETHIOPIA", "ET", "AFRICA", ["AMHARIC"], "88M", "1.1M", 86, 40, 20],
    ["FIJI", "FJ", "OCEANIA", ["ENGLISH", "FIJIAN", "HINDI", "URDU"], "859K", "18.3K", 0, 40, 20],
    ["FINLAND", "FI", "EUROPE", ["FINNISH", "SWEDISH"], "5.47M", "338K", 48, 40, 24],
    ["FRANCE", "FR", "EUROPE", ["FRENCH"], "66.1M", "641K", 7, 40, 27],
    ["GABON", "GA", "AFRICA", ["FRENCH"], "1.71M", "268K", 0, 40, 30],
    ["GAMBIA", "GM", "AFRICA", ["ENGLISH"], "1.88M", "11.3K", 0, 40, 27],
    ["GEORGIA", "GE", "ASIA/EUROPE", ["GEORGIAN"], "4.49M", "69.7K", 91, 40, 27],
    ["GERMANY", "DE", "EUROPE", ["GERMAN"], "80.8M", "357K", 4, 40, 24],
    ["GHANA", "GH", "AFRICA", ["ENGLISH"], "27M", "239K", 88, 40, 27],
    ["GREECE", "GR", "EUROPE", ["MODERN GREEK"], "11M", "132K", 47, 40, 27],
    ["GRENADA", "GD", "NORTH AMERICA", ["ENGLISH"], "103K", "344", 0, 40, 24],
    ["GUATEMALA", "GT", "NORTH AMERICA", ["SPANISH"], "15.8M", "109K", 67, 40, 25],
    ["GUINEA", "GN", "AFRICA", ["FRENCH", "FULAH"], "10.6M", "246K", 0, 40, 27],
    ["GUINEA-BISSAU", "GW", "AFRICA", ["PORTUGUESE"], "1.75M", "36.1K", 0, 40, 20],
    ["GUYANA", "GY", "SOUTH AMERICA", ["ENGLISH"], "785K", "215K", 0, 40, 24],
    ["HAITI", "HT", "NORTH AMERICA", ["FRENCH", "HAITIAN"], "10.7M", "27.8K", 0, 40, 24],
    ["HONDURAS", "HN", "NORTH AMERICA", ["SPANISH"], "8.73M", "112K", 0, 40, 20],
    ["HUNGARY", "HU", "EUROPE", ["HUNGARIAN"], "9.88M", "93K", 33, 40, 20],
    ["ICELAND", "IS", "EUROPE", ["ICELANDIC"], "328K", "103K", 90, 40, 29],
    ["INDIA", "IN", "ASIA", ["HINDI", "ENGLISH"], "1.26B", "3.29M", 3, 40, 27],
    ["INDONESIA", "ID", "ASIA", ["INDONESIAN"], "252M", "1.9M", 16, 40, 27],
    ["IRAN", "IR", "ASIA", ["PERSIAN"], "78M", "1.65M", 46, 40, 23],
    ["IRAQ", "IQ", "ASIA", ["ARABIC", "KURDISH"], "36M", "438K", 99, 40, 27],
    ["IRELAND", "IE", "EUROPE", ["IRISH", "ENGLISH"], "6.38M", "70.3K", 25, 40, 20],
    ["ISRAEL", "IL", "ASIA", ["HEBREW", "ARABIC"], "8.27M", "20.8K", 32, 40, 29],
    ["ITALY", "IT", "EUROPE", ["ITALIAN"], "60.8M", "301K", 10, 40, 27],
    ["JAMAICA", "JM", "NORTH AMERICA", ["ENGLISH"], "2.72M", "11K", 0, 40, 20],
    ["JAPAN", "JP", "ASIA", ["JAPANESE"], "127M", "378K", 5, 40, 27],
    ["JORDAN", "JO", "ASIA", ["ARABIC"], "6.67M", "89.3K", 83, 40, 20],
    ["KAZAKHSTAN", "KZ", "ASIA/EUROPE", ["KAZAKH", "RUSSIAN"], "17.4M", "2.72M", 34, 40, 20],
    ["KENYA", "KE", "AFRICA", ["ENGLISH", "SWAHILI"], "41.8M", "580K", 77, 40, 27],
    ["KIRIBATI", "KI", "OCEANIA", ["ENGLISH"], "106K", "811", 0, 40, 20],
    ["KUWAIT", "KW", "ASIA", ["ARABIC"], "3.27M", "17.8K", 68, 40, 20],
    ["KYRGYZSTAN", "KG", "ASIA", ["KIRGHIZ", "RUSSIAN"], "5.78M", "200K", 0, 40, 24],
    ["LAOS", "LA", "ASIA", ["LAO"], "6.69M", "237K", 89, 40, 27],
    ["LATVIA", "LV", "EUROPE", ["LATVIAN"], "1.99M", "64.6K", 74, 40, 20],
    ["LEBANON", "LB", "ASIA", ["ARABIC", "FRENCH"], "4.1M", "10.5K", 93, 40, 27],
    ["LESOTHO", "LS", "AFRICA", ["ENGLISH", "SOUTHERN SOTHO"], "2.1M", "30.4K", 0, 40, 27],
    ["LIBERIA", "LR", "AFRICA", ["ENGLISH"], "4.4M", "111K", 0, 40, 21],
    ["LIBYA", "LY", "AFRICA", ["ARABIC"], "6.25M", "1.76M", 0, 40, 20],
    ["LIECHTENSTEIN", "LI", "EUROPE", ["GERMAN"], "37.1K", "160", 0, 40, 24],
    ["LITHUANIA", "LT", "EUROPE", ["LITHUANIAN"], "2.93M", "65.3K", 56, 40, 24],
    ["LUXEMBOURG", "LU", "EUROPE", ["FRENCH", "GERMAN", "LUXEMBOURGISH"], "550K", "2.59K", 78, 40, 24],
    ["MADAGASCAR", "MG", "AFRICA", ["FRENCH", "MALAGASY"], "21.8M", "587K", 0, 40, 27],
    ["MALAWI", "MW", "AFRICA", ["ENGLISH", "CHICHEWA"], "15.8M", "118K", 0, 40, 27],
    ["MALAYSIA", "MY", "ASIA", ["MALAY"], "30.4M", "331K", 14, 40, 20],
    ["MALDIVES", "MV", "ASIA", ["DIVEHI"], "341K", "300", 0, 40, 27],
    ["MALI", "ML", "AFRICA", ["FRENCH"], "15.8M", "1.24M", 0, 40, 27],
    ["MALTA", "MT", "EUROPE", ["MALTESE", "ENGLISH"], "416K", "316", 85, 40, 27],
    ["MARSHALL ISLANDS", "MH", "OCEANIA", ["ENGLISH", "MARSHALLESE"], "56.1K", "181", 0, 40, 21],
    ["MAURITANIA", "MR", "AFRICA", ["ARABIC"], "3.55M", "1.03M", 0, 40, 27],
    ["MAURITIUS", "MU", "AFRICA", ["ENGLISH"], "1.26M", "2.04K", 0, 40, 27],
    ["MEXICO", "MX", "NORTH AMERICA", ["SPANISH"], "120M", "1.96M", 9, 40, 23],
    ["MICRONESIA", "FM", "OCEANIA", ["ENGLISH"], "101K", "702", 0, 40, 21],
    ["MONACO", "MC", "EUROPE", ["FRENCH"], "37K", "2.02", 0, 38, 30],
    ["MONGOLIA", "MN", "ASIA", ["MONGOLIAN"], "2.99M", "1.56M", 94, 40, 20],
    ["MONTENEGRO", "ME", "EUROPE", ["MONTENEGRIN"], "623K", "13.8K", 0, 40, 20],
    ["MOROCCO", "MA", "AFRICA", ["ARABIC"], "33.5M", "447K", 52, 40, 27],
    ["MOZAMBIQUE", "MZ", "AFRICA", ["PORTUGUESE"], "25M", "802K", 0, 40, 27],
    ["MYANMAR", "MM", "ASIA", ["BURMESE"], "51.5M", "677K", 66, 40, 27],
    ["NAMIBIA", "NA", "AFRICA", ["ENGLISH", "AFRIKAANS"], "2.11M", "826K", 0, 40, 27],
    ["NAURU", "NR", "OCEANIA", ["ENGLISH", "NAURU"], "10.1K", "21", 0, 40, 20],
    ["NEPAL", "NP", "ASIA", ["NEPALI"], "27.6M", "147K", 0, 24, 30],
    ["NETHERLANDS", "NL", "EUROPE", ["DUTCH"], "16.9M", "41.9K", 15, 40, 27],
    ["NEW ZEALAND", "NZ", "OCEANIA", ["ENGLISH", "MAORI"], "4.55M", "270K", 59, 40, 20],
    ["NICARAGUA", "NI", "NORTH AMERICA", ["SPANISH"], "6.13M", "130K", 0, 40, 24],
    ["NIGER", "NE", "AFRICA", ["FRENCH"], "17.1M", "1.27M", 0, 35, 30],
    ["NIGERIA", "NG", "AFRICA", ["ENGLISH"], "179M", "924K", 54, 40, 20],
    ["NORTH MACEDONIA", "MK", "EUROPE", ["MACEDONIAN"], "2.14M", "25.7K", 0, 40, 20],
    ["NORWAY", "NO", "EUROPE", ["NORWEGIAN"], "5.16M", "324K", 39, 40, 29],
    ["OMAN", "OM", "ASIA", ["ARABIC"], "4.09M", "310K", 70, 40, 23],
    ["PAKISTAN", "PK", "ASIA", ["ENGLISH", "URDU"], "188M", "882K", 42, 40, 27],
    ["PALAU", "PW", "OCEANIA", ["ENGLISH"], "20.9K", "459", 0, 40, 25],
    ["PANAMA", "PA", "NORTH AMERICA", ["SPANISH"], "3.71M", "75.4K", 98, 40, 27],
    ["PAPUA NEW GUINEA", "PG", "OCEANIA", ["ENGLISH"], "7.4M", "463K", 0, 40, 30],
    ["PARAGUAY", "PY", "SOUTH AMERICA", ["SPANISH", "GUARANI"], "6.89M", "407K", 81, 40, 22],
    ["PERU", "PE", "SOUTH AMERICA", ["SPANISH"], "30.8M", "1.29M", 55, 40, 27],
    ["PHILIPPINES", "PH", "ASIA", ["ENGLISH"], "101M", "342K", 24, 40, 20],
    ["POLAND", "PL", "EUROPE", ["POLISH"], "38.5M", "313K", 22, 40, 25],
    ["PORTUGAL", "PT", "EUROPE", ["PORTUGUESE"], "10.5M", "92.1K", 43, 40, 27],
    ["QATAR", "QA", "ASIA", ["ARABIC"], "2.27M", "11.6K", 64, 40, 16],
    ["SOUTH KOREA", "KR", "ASIA", ["KOREAN"], "50.4M", "100K", 6, 40, 27],
    ["MOLDOVA", "MD", "EUROPE", ["ROMANIAN"], "3.56M", "33.8K", 0, 40, 20],
    ["ROMANIA", "RO", "EUROPE", ["ROMANIAN"], "19.9M", "238K", 31, 40, 27],
    ["RUSSIA", "RU", "EUROPE/ASIA", ["RUSSIAN"], "146M", "17.1M", 11, 40, 27],
    ["RWANDA", "RW", "AFRICA", ["KINYARWANDA", "ENGLISH", "FRENCH"], "11M", "26.3K", 0, 40, 27],
    ["SAINT KITTS AND NEVIS", "KN", "NORTH AMERICA", ["ENGLISH"], "55K", "261", 0, 40, 27],
    ["SAINT LUCIA", "LC", "NORTH AMERICA", ["ENGLISH"], "184K", "616", 0, 40, 20],
    ["ST VINCENT AND THE GRENADINES", "VC", "NORTH AMERICA", ["ENGLISH"], "109K", "389", 0, 40, 27],
    ["SAMOA", "WS", "OCEANIA", ["SAMOAN", "ENGLISH"], "188K", "2.84K", 0, 40, 20],
    ["SAN MARINO", "SM", "EUROPE", ["ITALIAN"], "32.7K", "61", 0, 40, 30],
    ["SAO TOME AND PRINCIPE", "ST", "AFRICA", ["PORTUGUESE"], "187K", "964", 0, 40, 20],
    ["SAUDI ARABIA", "SA", "ASIA", ["ARABIC"], "30.8M", "2.15M", 40, 40, 27],
    ["SENEGAL", "SN", "AFRICA", ["FRENCH"], "13.5M", "197K", 0, 40, 27],
    ["SERBIA", "RS", "EUROPE", ["SERBIAN"], "7.19M", "49K", 61, 40, 27],
    ["SEYCHELLES", "SC", "AFRICA", ["FRENCH", "ENGLISH"], "89.9K", "452", 100, 40, 20],
    ["SIERRA LEONE", "SL", "AFRICA", ["ENGLISH"], "6.21M", "71.7K", 0, 40, 27],
    ["SINGAPORE", "SG", "ASIA", ["ENGLISH", "MALAY", "TAMIL", "CHINESE"], "5.47M", "710", 20, 40, 27],
    ["SLOVAKIA", "SK", "EUROPE", ["SLOVAK"], "5.42M", "49K", 45, 40, 27],
    ["SLOVENIA", "SI", "EUROPE", ["SLOVENIAN"], "2.06M", "20.3K", 60, 40, 20],
    ["SOLOMON ISLANDS", "SB", "OCEANIA", ["ENGLISH"], "581K", "28.9K", 0, 40, 20],
    ["SOMALIA", "SO", "AFRICA", ["SOMALI", "ARABIC"], "10.8M", "638K", 0, 40, 27],
    ["SOUTH AFRICA", "ZA", "AFRICA", ["AFRIKAANS", "ENGLISH", "ET AL."], "54M", "1.22M", 38, 40, 27],
    ["SOUTH SUDAN", "SS", "AFRICA", ["ENGLISH"], "11.4M", "620K", 0, 40, 20],
    ["SPAIN", "ES", "EUROPE", ["SPANISH"], "46.5M", "506K", 19, 40, 27],
    ["SRI LANKA", "LK", "ASIA", ["SINHALA", "TAMIL"], "20.3M", "65.6K", 72, 40, 20],
    ["SUDAN", "SD", "AFRICA", ["ARABIC", "ENGLISH"], "37.3M", "1.89M", 0, 40, 20],
    ["SURINAME", "SR", "SOUTH AMERICA", ["DUTCH"], "534K", "164K", 0, 40, 27],
    ["SWEDEN", "SE", "EUROPE", ["SWEDISH"], "9.74M", "450K", 29, 40, 25],
    ["SWITZERLAND", "CH", "EUROPE", ["GERMAN", "FRENCH", "ITALIAN"], "8.18M", "41.3K", 23, 30, 30],
    ["SYRIA", "SY", "ASIA", ["ARABIC"], "23M", "185K", 0, 40, 27],
    ["TAJIKISTAN", "TJ", "ASIA", ["TAJIK", "RUSSIAN"], "8.16M", "143K", 0, 40, 20],
    ["THAILAND", "TH", "ASIA", ["THAI"], "64.9M", "513K", 18, 40, 27],
    ["TIMOR-LESTE", "TL", "ASIA", ["PORTUGUESE"], "1.17M", "14.9K", 0, 40, 20],
    ["TOGO", "TG", "AFRICA", ["FRENCH"], "6.99M", "56.8K", 0, 40, 25],
    ["TONGA", "TO", "OCEANIA", ["ENGLISH", "TONGA"], "103K", "747", 0, 40, 20],
    ["TRINIDAD AND TOBAGO", "TT", "NORTH AMERICA", ["ENGLISH"], "1.33M", "5.13K", 0, 40, 24],
    ["TUNISIA", "TN", "AFRICA", ["ARABIC"], "11M", "164K", 65, 40, 27],
    ["TURKIYE", "TR", "ASIA/EUROPE", ["TURKISH"], "76.7M", "784K", 21, 40, 27],
    ["TURKMENISTAN", "TM", "ASIA", ["TURKMEN", "RUSSIAN"], "5.84M", "488K", 0, 40, 27],
    ["TUVALU", "TV", "OCEANIA", ["ENGLISH"], "11.3K", "26", 0, 40, 20],
    ["UGANDA", "UG", "AFRICA", ["ENGLISH", "SWAHILI"], "34.9M", "242K", 0, 40, 27],
    ["UKRAINE", "UA", "EUROPE", ["UKRAINIAN"], "43M", "604K", 51, 40, 27],
    ["UNITED ARAB EMIRATES", "AE", "ASIA", ["ARABIC"], "9.45M", "83.6K", 37, 40, 20],
    ["UNITED KINGDOM", "GB", "EUROPE", ["ENGLISH"], "64.1M", "243K", 8, 40, 20],
    ["TANZANIA", "TZ", "AFRICA", ["SWAHILI", "ENGLISH"], "47.4M", "945K", 0, 40, 27],
    ["UNITED STATES", "US", "NORTH AMERICA", ["ENGLISH"], "319M", "9.63M", 2, 40, 21],
    ["URUGUAY", "UY", "SOUTH AMERICA", ["SPANISH"], "3.4M", "181K", 82, 40, 27],
    ["UZBEKISTAN", "UZ", "ASIA", ["UZBEK", "RUSSIAN"], "30.5M", "447K", 71, 40, 20],
    ["VANUATU", "VU", "OCEANIA", ["BISLAMA", "ENGLISH", "FRENCH"], "265K", "12.2K", 0, 40, 24],
    ["VENEZUELA", "VE", "SOUTH AMERICA", ["SPANISH"], "30.2M", "916K", 0, 40, 27],
    ["VIETNAM", "VN", "ASIA", ["VIETNAMESE"], "89.7M", "331K", 12, 40, 27],
    ["YEMEN", "YE", "ASIA", ["ARABIC"], "26M", "528K", 0, 40, 27],
    ["ZAMBIA", "ZM", "AFRICA", ["ENGLISH"], "15M", "753K", 0, 40, 27],
    ["ZIMBABWE", "ZW", "AFRICA", ["ENGLISH", "SHONA", "NORTH NDEBELE"], "13.1M", "391K", 95, 40, 20],
]


def mix(n):
    """A 32-bit avalanche hash (the Murmur3 finaliser).

    Starlark has no random module, so the pick comes from hashing the step
    number. Consecutive steps are exactly the input this gets, and a plain
    LCG would walk the table in visible strides; this keeps them uncorrelated.
    """
    x = n % 4294967296
    x = ((x ^ (x >> 16)) * 2246822507) % 4294967296
    x = ((x ^ (x >> 13)) * 3266489909) % 4294967296
    return x ^ (x >> 16)


def pick(ctx):
    """The country for this minute, never the same one two minutes running."""
    code = str(ctx.inputs.get("_country", "")).strip().upper()
    if code != "":
        for row in DATA:
            if row[1] == code:
                return row
    n = len(DATA)
    step = ctx.now.unix // HOLD
    i = mix(step) % n
    if i == mix(step - 1) % n:
        i = (i + 1) % n
    return DATA[i]


def width_of(c, text, font):
    """c.text_width, counting each apostrophe as the 2 px draw_text gives it."""
    return c.text_width(text.replace("'", ""), font) + 2 * text.count("'")


def draw_text(c, text, x, y, font, color):
    """c.text, except that apostrophes are drawn.

    Not one bundled font has an apostrophe, and a missing glyph draws as
    nothing: COTE D'IVOIRE would reach the panel as COTE DIVOIRE. The tick is
    a 1x2 bar at cap height.
    """
    parts = text.split("'")
    for i in range(len(parts)):
        if i > 0:
            c.rect(x, y, x, y + 1, fill = color)
            x += 2
        c.text(parts[i], x, y, font = font, color = color)
        x += c.text_width(parts[i], font)
    return x


def clip(c, text, font, maxw):
    if c.text_width(text, font) <= maxw:
        return text
    for k in range(len(text), 0, -1):
        if c.text_width(text[:k].rstrip(), font) <= maxw:
            return text[:k].rstrip()
    return ""


def flag(c, code, w, h):
    """The country's flag from assets/, centred in the flag box.

    Nearly every flag is drawn 1:1 at its own proportions, 40 px wide and 16
    to 30 px tall. c.image resizes by nearest neighbour, which drops whole rows
    and columns and would break thin stripes and small stars, so scaling is
    kept for the five flags too tall for the panel -- Monaco, Niger, Belgium,
    Switzerland and Nepal. Those are shrunk to 30 px tall, and all five are
    simple enough shapes to come through intact.
    """
    c.image(code.lower() + ".png", FLAG_X + (FLAG_W - w) // 2, (c.height - h) // 2,
            w = w, h = h)


def name_row(c, name):
    """5x7 where it fits the text column, 4x5 (baseline-aligned) where not."""
    maxw = EDGER - TEXT_X + 1
    if width_of(c, name, "5x7") <= maxw:
        draw_text(c, name, TEXT_X, ROW_NAME, "5x7", NAME)
    else:
        draw_text(c, name, TEXT_X, ROW_NAME + 2, "4x5", NAME)


def continent_row(c, continent, rank):
    color = CONTINENT_COLORS.get(continent.split("/")[0], VALUE)
    c.text(continent, TEXT_X, ROW_CONT, font = "4x5", color = color)
    if rank > 0:
        num = "#" + str(rank)
        nw = c.text_width(num, "4x5")
        c.text(num, EDGER + 1 - nw, ROW_CONT, font = "4x5", color = RANK)
        lw = c.text_width("POWER RANK", "4x5")
        c.text("POWER RANK", EDGER + 1 - nw - GAP - lw, ROW_CONT, font = "4x5",
               color = LABEL)
    else:
        w = c.text_width("NOT IN TOP 100", "4x5")
        c.text("NOT IN TOP 100", EDGER + 1 - w, ROW_CONT, font = "4x5", color = LABEL)


def languages(c, langs, maxw):
    """As many languages as fit, then +N for the rest."""
    for k in range(len(langs), 0, -1):
        s = ", ".join(langs[:k])
        if k < len(langs):
            s += " +" + str(len(langs) - k)
        if c.text_width(s, "4x5") <= maxw:
            return s
    return clip(c, langs[0], "4x5", maxw)


def language_row(c, langs):
    c.text("LANG", TEXT_X, ROW_LANG, font = "4x5", color = LABEL)
    x = TEXT_X + c.text_width("LANG", "4x5") + GAP
    c.text(languages(c, langs, EDGER - x + 1), x, ROW_LANG, font = "4x5", color = VALUE)


def facts_row(c, pop, area):
    """POP on the left; AREA with a raised 2 on KM, right-aligned."""
    c.text("POP", TEXT_X, ROW_FACTS, font = "4x5", color = LABEL)
    c.text(pop, TEXT_X + c.text_width("POP", "4x5") + GAP, ROW_FACTS, font = "4x5",
           color = VALUE)

    sq = c.text_width("2", "3x4")
    unit = c.text_width("KM", "4x5")
    vw = c.text_width(area, "4x5")
    x = EDGER + 1 - sq - 1 - unit - 3 - vw
    lw = c.text_width("AREA", "4x5")
    c.text("AREA", x - GAP - lw, ROW_FACTS, font = "4x5", color = LABEL)
    c.text(area, x, ROW_FACTS, font = "4x5", color = VALUE)
    x += vw + 3
    c.text("KM", x, ROW_FACTS, font = "4x5", color = LABEL)
    c.text("2", x + unit + 1, ROW_FACTS - 1, font = "3x4", color = LABEL)


def country(c, ctx):
    c.fill(INK)
    row = pick(ctx)
    flag(c, row[1], row[7], row[8])
    name_row(c, row[0])
    continent_row(c, row[2], row[6])
    language_row(c, row[3])
    facts_row(c, row[4], row[5])
