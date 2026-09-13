# Feed format

Prediction Market Ticker fetches the configured URL once per render without the HTTP client's default five-minute cache. The endpoint should return HTTP 200 with `Content-Type: application/json`. Use HTTPS for a new hosted feed. Version 2 enables local filtering, rotation and game context; older feeds still render their first row.

## Example

The example below uses fictional odds. A copy is included as [example-feed.json](example-feed.json); serve that file from a reachable URL to preview the display without connecting an account.

```json
{
  "ok": true,
  "count": 1,
  "rows": [
    {
      "label": "ATL +10.5",
      "team": {"league": "NFL", "code": "ATL"},
      "market_team": {"league": "NFL", "code": "PIT"},
      "market_kind": "spread",
      "line": 10.5,
      "side": "NO",
      "side_label": "SPREAD",
      "pct": 61,
      "delta": -6,
      "settled": false
    }
  ]
}
```

## Response fields

| Field | Type | Meaning |
|---|---|---|
| `ok` | Boolean | Use `true` for a successful feed. `false` displays FEED ERROR. Omission is accepted for older feeds. |
| `rows` | Array of objects | An empty list displays NO OPEN MARKETS. Version 2 sorts and filters all rows. |
| `version` | Integer, optional | Set to 2 for matchup/score layout and app selection controls. Omission preserves the legacy layout. |
| `fetched_at` | Integer, optional | Unix seconds of the successful odds fetch. Older than 120 seconds displays STALE FEED. |
| `count` | Integer, optional | Informational total. The display calculates its counter from filtered rows. |
| `error` | String, optional | Provider diagnostics. Not displayed on the panel. |

## Row fields

| Field | Type | Meaning |
|---|---|---|
| `label` | String | Short market label. Aim for ten characters or fewer; the app reduces the font or shortens longer labels. |
| `ticker` | String | Required unique stable market ID for version 2 sorting and selection. |
| `matchup` | Array or null | Exactly two `{league, code}` objects in display order. Do not assume home/away order. Independent of the held `team`. |
| `game` | Object or null | Score snapshot described below. Null means unavailable or not uniquely matched. |
| `team` | Object or null | The team to display, e.g. `{ "league": "NFL", "code": "ATL" }`. For spreads this is the effective held team, including the opponent for NO. Use null to disable a logo. |
| `market_team` | Object or null, optional | The original named team in the market. Informational; distinct from the effective held team. |
| `opponent` | Object or null, optional | The opponent of the displayed team when known. |
| `market_kind` | String, optional | `spread`, `total` or `binary`. A spread with a numeric line and a supported team icon uses the large-line layout. |
| `line` | Number or null, optional | Signed effective spread, e.g. `10.5` for ATL +10.5 or `-10.5` for PIT −10.5. Totals can supply their threshold. |
| `custom_label` | String or null, optional | Preserved custom label for diagnostics. The app does not display it. |
| `side` | String | Short held-side label, normally YES or NO. |
| `side_label` | String, optional | Display label that takes precedence over `side`, such as OVER or UNDER. Keep it short, ideally seven characters or fewer. |
| `pct` | Integer or null | Held-side probability from 0 to 100, already rounded. Null or omission displays `--%` with no probability bar. |
| `delta` | Integer or null | Change in percentage points from your chosen reference, preferably the previous close. Positive = green, negative = red. Zero, null or omission = white and no change text. Keep the value within −100 to 100. |
| `settled` | Boolean | True displays SETTLED unless a status label is supplied. Omission is treated as false. |
| `status_label` | String or null, optional | Short status overriding the held-side footer: CLOSED, PENDING, WON, LOST, SETTLED or PAUSED. |

All rows must be objects and numeric values must be numbers, not formatted strings. The app clamps numeric probabilities to 0–100, but providers should send valid values. Labels are displayed in uppercase.

## Team matching

Use league `NFL` or `CFB`; `NCAA` and `NCAAF` are also accepted for college football. Codes and aliases are defined in `TEAM_ICONS` and `TEAM_ALIASES` in `app.star`. See [ASSET-SOURCES.md](ASSET-SOURCES.md) for canonical feed keys and the roster.

For example, NFL `PIT` is Pittsburgh Steelers; CFB `PITT` or `PIT` is Pitt Panthers. CFB `MIZZ` / `MIZ` map to Missouri and `TAMU` / `TXAM` map to Texas A&M.

`team` describes the effective displayed selection. For a recognized football spread, NO on PIT winning by more than 10.5 becomes ATL +10.5 when the event matchup is ATL–PIT. Keep `side: "NO"` and the original NO-side probability: switching the displayed team must not complement the probability a second time. Preserve PIT in `market_team` for context. Other binary market types do not automatically switch teams.

Resolve the opponent from reliable matchup data. If the event format or threshold is unsupported, leave `line` null, use an explicit YES/NO label and omit a misleading logo. Kalshi NO subtitles can repeat the YES wording, so do not rely on the subtitle alone. The server only translates recognized spread series with supported greater-than thresholds. Integer football scoring permits an equivalent half-point line for a strict whole-number threshold.

Older feeds can supply top-level `league` and `team_code`, or omit metadata and rely on the first word of `label` (after an optional NOT). Only unambiguous labels match automatically. The League for older feeds setting resolves missing league information; explicit league metadata always wins. An explicit `team: null` prevents all fallback logo matching.

## Rotation and errors

Version 2 sorts rows by ticker and selects `floor(unix_seconds / (60 * minutes_per_position)) % filtered_count`, or the configured pin. No persistent state or faster device refresh is required. The bundled server still rotates its response for older apps; version 2 apps sort it again before selecting. The connector paginates the portfolio and includes every nonzero holding, removing the previous six-row cap.

Older feeds must return the desired market at `rows[0]` and rotate on the server. A static older JSON file keeps showing its first row.

## Game snapshot

```json
{"id":"espn-game-id","state":"in","phase":"Q3 8:42","period":3,"clock":"8:42","scores":[21,10],"source":"ESPN","fetched_at":1789322400,"stale":false}
```

`scores` must align with `matchup`, not the YES/NO selection. Scores are numbers or null; pregame scores are null. `state` is `pre`, `in` or `post`. `phase` is a short display string such as PREGAME, Q3 8:42, HALF, OT1 8:42, FINAL, DELAY or POSTP. `fetched_at` records when the scoreboard was fetched, never when an old snapshot was reused. A failed refresh sets `stale: true`; snapshots older than 120 seconds also display STALE SCORE. The app never extrapolates the clock.

The connector matches both teams within the football league and event-date scoreboard. Known unambiguous ticker pairs use the bundled catalog; other pairs require corroborating Kalshi event subtitles. Ambiguous or unsupported formats return null context. ESPN scoreboards are public, unofficial integration endpoints and may change; requests are deduplicated by league/date, cached for 60 seconds and have a 1.8-second timeout. Scoreboard failure does not fail the odds feed. No Kalshi credentials or position IDs are sent to ESPN.

The JSON endpoint carries these new fields. The separate legacy PNG endpoint retains its original drawing layout.

On an upstream failure, return `{"ok": false, "rows": []}`. An empty successful feed is different: `{"ok": true, "rows": []}` means there are no markets to display. Prefer a short generic error field without credentials or sensitive upstream response details.
