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

# Prefer a local virtualenv (.venv) if the package was installed into one. A
# double-click (or a non-activated shell) doesn't inherit an activated venv, so
# look for it here, otherwise the system python3 (which has none of the
# dependencies) gets used and Studio crashes with "No module named 'PIL'".
if [ -x ".venv/bin/gdn" ]; then
  exec .venv/bin/gdn studio "$@"
elif [ -x ".venv/bin/python3" ]; then
  exec .venv/bin/python3 -m gdn.cli studio "$@"
elif [ -x ".venv/bin/python" ]; then
  exec .venv/bin/python -m gdn.cli studio "$@"
# Otherwise use whatever is on PATH: an activated venv, or a system-wide install.
elif command -v gdn >/dev/null 2>&1; then
  exec gdn studio "$@"
elif command -v python3 >/dev/null 2>&1; then
  exec python3 -m gdn.cli studio "$@"
else
  exec python -m gdn.cli studio "$@"
fi
