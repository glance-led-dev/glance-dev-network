# GDN render service

A tiny Flask app that renders any app in `../apps` to a PNG.

- `GET /render/<app_id>?page=1&<inputs>` -> a PNG of that page
- `GET /api/apps` -> the app catalog with descriptors
- `GET /healthz` -> liveness probe

Run locally from the repo root:

```bash
python server/server.py           # http://localhost:8000/
```

On Render (start command):

```bash
gunicorn server.server:app
```

## Per-IP rate limiting

Each `/render` call spawns a sandboxed subprocess, so a flood from one IP can tie up
the worker pool. `/render` is rate limited per client IP (an in-process sliding window;
health checks and `/api/apps` are not limited). The client IP is read from
`X-Forwarded-For` via a one-hop `ProxyFix`, so it works behind Render's proxy and can't
be spoofed with extra header entries.

Tune it with environment variables (set them on the host; no code redeploy needed):

| Env var | Default | Meaning |
|---|---|---|
| `RATE_LIMIT` | `120` | Max `/render` requests per IP per window. Set `0` to disable. |
| `RATE_WINDOW` | `60` | Window length in seconds. |
| `RATE_ALLOWLIST` | *(empty)* | Comma-separated IPs that skip the limit, e.g. your own backend that fetches renders on users' behalf. |

Over the limit returns `429` with a `Retry-After` header; allowed responses carry
`X-RateLimit-Limit` and `X-RateLimit-Remaining`.

> With a single gunicorn worker the count is exact. With N workers each keeps its own
> counter, so the effective limit is about N x `RATE_LIMIT` (still a hard ceiling). For a
> single global limit across many workers/instances, back it with Redis.
