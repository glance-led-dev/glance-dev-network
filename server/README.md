# Render service

`server/server.py` renders any app in this repo to a PNG:
`/render/<app_id>?page=1&<inputs>`, plus `/healthz` and `/api/apps`.

## Deploy on Render (web service, this repo)
- Root Directory: (leave empty)
- Build Command: `pip install -r requirements.txt`
- Start Command: `gunicorn server.server:app`
- Health Check Path: `/healthz`
- Auto-Deploy: On Commit  (new apps merged to main redeploy automatically)

## Local
    pip install -e .
    python server/server.py     # http://localhost:8000/
