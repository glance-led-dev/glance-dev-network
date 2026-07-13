#!/usr/bin/env bash
# ===========================================================================
#  Glance Dev Studio launcher (macOS and Linux)
#
#  Run it from a terminal:   ./studio.sh       (or:  bash studio.sh )
#  On macOS you can also double-click "studio.command", which does the same.
#
#  It always starts from this folder, so it finds your apps no matter what,
#  and you never have to remember a command or which directory you're in.
# ===========================================================================
cd "$(dirname "$0")" || exit 1

echo "Starting Glance Dev Studio..."
echo "Your browser will open at http://localhost:8766"
echo "Press Ctrl+C (or close this window) when you are done."
echo

# Prefer the installed `gdn` command; fall back to the Python module if it
# isn't on PATH yet (e.g. a fresh copy that hasn't been installed).
if command -v gdn >/dev/null 2>&1; then
  exec gdn studio "$@"
elif command -v python3 >/dev/null 2>&1; then
  exec python3 -m gdn.cli studio "$@"
else
  exec python -m gdn.cli studio "$@"
fi
