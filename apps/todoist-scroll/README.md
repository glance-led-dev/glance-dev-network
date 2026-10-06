# Todoist

What is due today, and how far behind you are.

Pages: `today`, `tasks`

## Setting it up

1. In Todoist go to **Settings → Integrations → Developer**.
2. Copy the **API token**. This is a personal token, not an OAuth app.
3. Paste it into **Todoist API token**.
4. Set your **Time zone** so "today" and "overdue" mean your today.

## Settings

| setting | what it is |
|---|---|
| **Todoist API token** *(credential)* | Your personal API token, not an OAuth app. In Todoist: Settings > Integrations > Developer > API token. Leave blank to see the app running on sample tasks. |
| **UTC offset** | Hours from UTC where you are, so "today" and "overdue" mean your today. |

## Notes

- Leave the token blank to see the app running on sample tasks.
- Overdue and due-today are shown as separate numbers on purpose, because they are separate feelings.

---

Settings ride a colon-separated render descriptor, so **a value containing `:` is cut
at the first colon before the app sees it** — which is why URLs are entered without
their scheme, or split into parts. See [CONTRIBUTING.md](../../CONTRIBUTING.md).
