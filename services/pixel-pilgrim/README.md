# Pixel Pilgrim service

This is the shared route state for Pixel Pilgrim. A request to
`/v1/journey?zip=10001` registers that ZIP as an anonymous city stop and returns
the current, previous, next, and requesting cities plus the arrival estimate.

The raw ZIP is resolved once and is not stored. The database keeps an HMAC token,
city, state, creation time, and last-seen time. Stops that have not checked in for
30 days are skipped. The pilgrim advances every six hours.

## Run locally

```powershell
$env:PILGRIM_HASH_KEY = "replace-with-a-long-random-secret"
$env:PILGRIM_DB = "pixel-pilgrim.db"
..\..\.venv\Scripts\python.exe app.py
```

The service listens on `http://127.0.0.1:8781`. Test it with:

```text
http://127.0.0.1:8781/v1/journey?zip=10001
```

Run the offline tests from this folder:

```powershell
..\..\.venv\Scripts\python.exe -m unittest -v test_app.py
```

For production, set a permanent `PILGRIM_HASH_KEY`, put the SQLite database on a
persistent disk, serve over HTTPS, and set `PILGRIM_API` in both Glance apps to
that public origin. Run the factory with `gunicorn 'app:create_app()'`. Do not
change the hash key after registrations exist.

The renderer can only make GET requests, so the ZIP travels in the query string.
Configure the public proxy not to retain query strings in access logs. The
application database itself never stores the raw ZIP.
