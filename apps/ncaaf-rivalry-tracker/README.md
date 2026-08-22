# NCAA College Football Rivalry Tracker – Glance

Display historic college football rivalry series, head-to-head records, rankings, last game outcomes, active winning streaks, and future matchup dates on a wide LED panel.

**Version 1.0** · App ID: `ncaaf-rivalry-tracker`  
**By** [SlaterDen](https://github.com/SlaterDen)

---

## App Settings

| Setting | Required | Description |
|--------|----------|-------------|
| **API Key** | Yes | Your API key from [CollegeFootballData.com](https://collegefootballdata.com/) |
| **Team 1** | Yes | First school name (e.g. `Oklahoma`, `Notre Dame`) |
| **Team 2** | Yes | Second school name (e.g. `Texas`, `Tennessee`) |
| **Custom Title** | No | Optional banner title override. Blank = automatic rivalry name lookup |
| **Team Name Length** | Yes | Choose between **Abbreviations** or **Full Name** (up to 12 characters + series win tally) |

---

## How to Get Your API Key

1. Go to [CollegeFootballData.com](https://collegefootballdata.com/).
2. Create a free account or sign in to access developer tokens.
3. Generate your API key and paste it into the Glance app settings as **API Key**.

The College Football Data API provides free tiers suitable for personal display tracking.

---

## Pages & Layout

| Page | What’s shown |
|------|----------------|
| **Main Series View** | Custom banner title, CFP/AP rankings, split-color series history progress bar with team win totals, team abbreviations or full names, and a 3-section bottom ticker. |
| **First Meeting View** | Dynamic gradient background for teams that have never played before, with scheduled next matchup details. |

### Bottom 3-Section Grid Box Breakdown
* **LAST:** Most recent matchup result and score, color-coded to the winning team.
* **STREAK:** Current active winning streak counter, color-coded to the team holding the streak.
* **NEXT:** Date of the upcoming scheduled matchup.

---

## Data Sources

| Source | Used for |
|--------|----------|
| **College Football Data API** (`api.collegefootballdata.com`) | Historical team matchups, past game records, team directories, colors, and live rankings |
| **GitHub Hosted JSON** (`raw.githubusercontent.com/SlaterDen/ncaaf-rivalries`) | Dynamic mapping of classic rivalry game titles and trophies |

This app is **not** affiliated with the NCAA or CollegeFootballData.com. All sports data remains the property of its respective providers.

---

## Errors & Troubleshooting

| What you see | Likely cause | What to try |
|--------------|--------------|-------------|
| **ADD CFBD API KEY** | Missing API key setting | Enter your College Football Data API key in the app settings |
| **INVALID TEAM INPUT** / **CHECK TEAMS SPELLING** | Misspelled or unrecognized school name | Verify the spelling of Team 1 and Team 2 against official FBS names |
| **NO SERIES DATA** | API returned empty series record | Ensure both teams are valid FBS opponents with a recorded history |
| **API ERROR** | Network issue or invalid key | Check your API key or verify API service status |

---

## Notes

- Panel: Designed for wide LED panels (e.g., **192×32**).
- Caching: Rivalry metadata uses short TTL caching for rapid testing and updates.

---

## Credits

**SlaterDen** · Built for the [Glance Developer Network](https://glance-led.dev).