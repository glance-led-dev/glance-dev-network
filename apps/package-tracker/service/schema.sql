CREATE TABLE IF NOT EXISTS packages (
  id TEXT PRIMARY KEY,
  carrier TEXT NOT NULL,
  tracking_code TEXT NOT NULL,
  sender TEXT NOT NULL DEFAULT '',
  tracker_id TEXT,
  status TEXT NOT NULL DEFAULT 'unknown',
  normalized TEXT,
  first_seen INTEGER NOT NULL,
  checked_at INTEGER NOT NULL DEFAULT 0,
  archived INTEGER NOT NULL DEFAULT 0,
  error TEXT
);
CREATE INDEX IF NOT EXISTS package_refresh ON packages(archived, status, checked_at);
CREATE TABLE IF NOT EXISTS processed_messages (id TEXT PRIMARY KEY, processed_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
