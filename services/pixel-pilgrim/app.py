"""Shared state service for Pixel Pilgrim.

Each unique US ZIP becomes one anonymous route stop. The service resolves the
ZIP once, stores only an HMAC token plus city/state, and advances one shared
pilgrim every six hours.
"""

from __future__ import annotations

import hashlib
import hmac
import json
import math
import os
import re
import sqlite3
import time
import urllib.error
import urllib.request
from contextlib import closing
from pathlib import Path
from typing import Callable

from flask import Flask, jsonify, request


DWELL_SECONDS = 6 * 60 * 60
ACTIVE_SECONDS = 30 * 24 * 60 * 60
ZIP_RE = re.compile(r"^[0-9]{5}$")
KEEPSAKES = (
    "BLUE KEY",
    "TIN STAR",
    "RED FEATHER",
    "GLASS COIN",
    "TINY BELL",
    "MOON SEED",
    "BRASS MAP",
    "GREEN STONE",
)


def geocode_zip(zip_code: str) -> tuple[str, str] | None:
    url = f"https://api.zippopotam.us/us/{zip_code}"
    req = urllib.request.Request(url, headers={"User-Agent": "PixelPilgrim/0.1"})
    try:
        with urllib.request.urlopen(req, timeout=8) as response:
            payload = json.load(response)
    except (OSError, ValueError, urllib.error.HTTPError):
        return None
    places = payload.get("places") or []
    if not places:
        return None
    place = places[0]
    city = str(place.get("place name", "")).strip().upper()
    state = str(place.get("state abbreviation", "")).strip().upper()
    return (city, state) if city and state else None


def create_app(
    database_path: str | Path | None = None,
    geocoder: Callable[[str], tuple[str, str] | None] | None = None,
    clock: Callable[[], float] | None = None,
) -> Flask:
    app = Flask(__name__)
    db_path = Path(database_path or os.environ.get("PILGRIM_DB", "pixel-pilgrim.db"))
    lookup = geocoder or geocode_zip
    now_fn = clock or time.time
    hash_key = os.environ.get("PILGRIM_HASH_KEY", "development-only-change-me").encode()

    def connect() -> sqlite3.Connection:
        db_path.parent.mkdir(parents=True, exist_ok=True)
        conn = sqlite3.connect(db_path, timeout=10)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA journal_mode=WAL")
        conn.execute("PRAGMA foreign_keys=ON")
        return conn

    def init_db() -> None:
        with closing(connect()) as conn:
            conn.executescript(
                """
                CREATE TABLE IF NOT EXISTS stops (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    token TEXT NOT NULL UNIQUE,
                    city TEXT NOT NULL,
                    state TEXT NOT NULL,
                    created_at INTEGER NOT NULL,
                    last_seen INTEGER NOT NULL
                );
                CREATE TABLE IF NOT EXISTS journey_state (
                    key TEXT PRIMARY KEY,
                    value TEXT NOT NULL
                );
                """
            )
            conn.commit()

    def zip_token(zip_code: str) -> str:
        return hmac.new(hash_key, zip_code.encode(), hashlib.sha256).hexdigest()

    def get_meta(conn: sqlite3.Connection, key: str) -> int | None:
        row = conn.execute("SELECT value FROM journey_state WHERE key = ?", (key,)).fetchone()
        return int(row["value"]) if row else None

    def set_meta(conn: sqlite3.Connection, key: str, value: int) -> None:
        conn.execute(
            "INSERT INTO journey_state(key, value) VALUES(?, ?) "
            "ON CONFLICT(key) DO UPDATE SET value = excluded.value",
            (key, str(value)),
        )

    def place(row: sqlite3.Row) -> dict[str, str]:
        return {"city": row["city"], "state": row["state"]}

    def active_rows(conn: sqlite3.Connection, now: int, keep_id: int | None) -> list[sqlite3.Row]:
        cutoff = now - ACTIVE_SECONDS
        if keep_id is None:
            return conn.execute(
                "SELECT * FROM stops WHERE last_seen >= ? ORDER BY id", (cutoff,)
            ).fetchall()
        return conn.execute(
            "SELECT * FROM stops WHERE last_seen >= ? OR id = ? ORDER BY id",
            (cutoff, keep_id),
        ).fetchall()

    def build_state(conn: sqlite3.Connection, local_id: int, now: int) -> dict:
        conn.execute("BEGIN IMMEDIATE")
        current_id = get_meta(conn, "current_id")
        rows = active_rows(conn, now, current_id)
        if not rows:
            raise RuntimeError("route has no active stops")
        ids = [row["id"] for row in rows]
        if current_id not in ids:
            current_id = ids[0]
            set_meta(conn, "current_id", current_id)

        next_move = get_meta(conn, "next_move_at")
        if next_move is None:
            next_move = now + DWELL_SECONDS
            set_meta(conn, "next_move_at", next_move)

        previous_id = get_meta(conn, "previous_id")
        while now >= next_move:
            rows = active_rows(conn, now, current_id)
            ids = [row["id"] for row in rows]
            current_index = ids.index(current_id) if current_id in ids else 0
            previous_id = current_id
            current_id = ids[(current_index + 1) % len(ids)]
            next_move += DWELL_SECONDS
            set_meta(conn, "previous_id", previous_id)
            set_meta(conn, "current_id", current_id)
            set_meta(conn, "next_move_at", next_move)

        rows = active_rows(conn, now, current_id)
        ids = [row["id"] for row in rows]
        current_index = ids.index(current_id)
        local_index = ids.index(local_id)
        away = (local_index - current_index) % len(ids)
        next_id = ids[(current_index + 1) % len(ids)]
        if previous_id not in ids:
            previous_id = ids[(current_index - 1) % len(ids)]

        by_id = {row["id"]: row for row in rows}
        hours_left = max(1, math.ceil((next_move - now) / 3600))
        eta_hours = 0 if away == 0 else hours_left + (away - 1) * 6
        keepsake = KEEPSAKES[(previous_id - 1) % len(KEEPSAKES)]
        conn.commit()
        return {
            "ok": True,
            "current": place(by_id[current_id]),
            "previous": place(by_id[previous_id]),
            "next": place(by_id[next_id]),
            "local": place(by_id[local_id]),
            "is_here": away == 0,
            "eta_hours": eta_hours,
            "hours_left": hours_left,
            "keepsake": keepsake,
        }

    init_db()

    @app.get("/health")
    def health():
        return jsonify(ok=True)

    @app.get("/v1/journey")
    def journey():
        zip_code = request.args.get("zip", "").strip()
        if not ZIP_RE.fullmatch(zip_code):
            return jsonify(ok=False, error="valid five-digit ZIP required"), 400

        token = zip_token(zip_code)
        now = int(now_fn())
        with closing(connect()) as conn:
            row = conn.execute("SELECT * FROM stops WHERE token = ?", (token,)).fetchone()

        if row is None:
            resolved = lookup(zip_code)
            if not resolved:
                return jsonify(ok=False, error="ZIP could not be resolved"), 422
            city, state = resolved
            with closing(connect()) as conn:
                conn.execute(
                    "INSERT OR IGNORE INTO stops(token, city, state, created_at, last_seen) "
                    "VALUES(?, ?, ?, ?, ?)",
                    (token, city.upper(), state.upper(), now, now),
                )
                conn.execute("UPDATE stops SET last_seen = ? WHERE token = ?", (now, token))
                row = conn.execute("SELECT * FROM stops WHERE token = ?", (token,)).fetchone()
                conn.commit()
        else:
            with closing(connect()) as conn:
                conn.execute("UPDATE stops SET last_seen = ? WHERE id = ?", (now, row["id"]))
                conn.commit()

        try:
            with closing(connect()) as conn:
                payload = build_state(conn, row["id"], now)
        except (sqlite3.Error, RuntimeError):
            app.logger.exception("could not build pilgrim state")
            return jsonify(ok=False, error="journey unavailable"), 503
        return jsonify(payload)

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(host="127.0.0.1", port=int(os.environ.get("PORT", "8781")))
