# Fortnite Player Tracker

Lifetime Fortnite Battle Royale leaderboards for up to 8 players. Five
pages, one per stat — WINS, K/D, WIN RATE, KILLS, TOP 10S — with everyone
ranked highest to lowest. Only 4 rows fit legibly at once, so each
leaderboard swaps between ranks 1-4 and 5-8 once per refresh.

Every name field starts blank: install it and you get an "ADD NAMES" prompt
until you fill in your own roster. 8 players is a hard ceiling, not a
preference — ranking needs one fortnite-api.com lookup per player, and GDN
caps an app at 8 API calls per render.

## Getting an API key

Stats come from [fortnite-api.com](https://fortnite-api.com), and its stats
endpoint requires a free key.

1. Go to **[dash.fortnite-api.com/account](https://dash.fortnite-api.com/account)**
   and click **Login with Discord**. This is the only sign-in method — there's
   no email/password option.
2. Once signed in, go to **Apps** and click **Create App**. Give it any name.
3. Copy the key it generates and paste it into this app's **Fortnite-API.com
   key** setting in Glance.

Leave the key blank and the app runs fine on clearly-labeled **DEMO** data
until you add one.

### If Discord's login or phone verification gives you trouble

- The Discord login button doing nothing usually means a popup blocker or an
  ad-blocking extension (uBlock Origin, Brave Shields, etc.) is killing the
  OAuth redirect — allowlist `dash.fortnite-api.com` and `discord.com`, or try
  an incognito window with extensions off.
- If Discord asks you to verify a phone number and rejects it as **"invalid
  phone number,"** check that the country-code dropdown next to the field
  actually matches your number, and use a real mobile number — Discord does
  not accept VOIP numbers (Google Voice, TextNow, Skype) or landlines for
  verification.

## Inputs

| Input | What it is |
|---|---|
| Fortnite-API.com key | Your key from the dashboard above. Optional — blank runs demo data. |
| Player 1–8 — Epic name | Exact Epic display names, case-sensitive. All default blank; leave any blank to drop that slot from every leaderboard. |

Platform is fixed to Epic (PC/mobile) account lookups. If a name doesn't
resolve, that player still shows on the board with `--` instead of a value,
so a typo is visible rather than silently dropped.
