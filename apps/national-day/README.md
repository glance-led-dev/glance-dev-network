# National Day

A Glance Scroll app for **unofficial United States national days** — the American observances you see on National Day Calendar (National Blueberry Popsicle Day, National Donut Day, and so on).

This is **not**:

- US federal holidays (Independence Day, Thanksgiving)
- other countries' national days
- UN / "World … Day" observances

One name is on the panel at a time. If several US days share the date, they rotate.

![National Day catalog preview](preview/preview.png)

Native panel:

![National Day panel](preview/today.png)

## Preview

```powershell
pip install -e .
gdn studio apps/national-day
```

Or:

```powershell
gdn preview apps/national-day
gdn validate apps/national-day
```

If `gdn` is not on your PATH, use `python -m gdn` instead.

## Setting

| Setting | Default | Notes |
|---------|---------|--------|
| **Timezone** | US CENTRAL | Picks which US calendar date is "today". US zones follow daylight saving. |

Panel size is **192×32**. Refresh is **900 seconds**; the featured name rotates through today's US days.

## Sources

The list is the same kind of US "national day" calendar as [sattelbergerp/national-day-list](https://github.com/sattelbergerp/national-day-list) (a scraper of [nationaldaycalendar.com](https://nationaldaycalendar.com/)). That site is tried first; if it is unreachable or stale, the app falls back to [Checkiday](https://www.checkiday.com)'s public RSS and keeps names that look like US national days.
