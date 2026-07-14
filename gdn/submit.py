"""Browser-assisted app submission.

Commit an app, push it to the developer's own fork, and hand back the URL of
GitHub's "open a pull request" page. There's no GitHub CLI or access token to set
up: the push uses the developer's normal git credentials (their OS credential
manager), the same sign-in they'd use for any `git push`.

The flow matches CONTRIBUTING.md: fork the repo, clone your fork, add your app under
`apps/`, then submit, which opens a pull request the Glance team reviews and merges.
"""
from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path

# The public repo apps are submitted to. Pull requests open against its `main`.
UPSTREAM = "glance-led-dev/glance-dev-network"


class SubmitError(Exception):
    """A problem the developer can fix before the app can be submitted.

    The message is written to be shown to them directly (in Studio or the CLI)."""


def _git(root: Path, *args: str, timeout: int = 30) -> subprocess.CompletedProcess:
    env = dict(os.environ)
    env["GIT_TERMINAL_PROMPT"] = "0"   # fail fast instead of hanging on a missing password
    return subprocess.run(["git", "-C", str(root), *args],
                          capture_output=True, text=True, timeout=timeout, env=env)


def _repo_root(start: Path) -> Path:
    try:
        r = subprocess.run(["git", "-C", str(start), "rev-parse", "--show-toplevel"],
                           capture_output=True, text=True, timeout=10)
    except (OSError, subprocess.SubprocessError):
        raise SubmitError("git isn't installed, or it isn't on your PATH. Install git, then try again.")
    if r.returncode != 0:
        raise SubmitError(
            "This app isn't inside a git repository. To submit, fork the Glance app repo "
            "on GitHub, clone your fork, and put your app in its apps/ folder.")
    return Path(r.stdout.strip())


def _origin(root: Path):
    # Read the raw configured URL (not `git remote get-url`, which expands insteadOf
    # rewrites), so we recover the real github.com owner even behind a mirror.
    r = _git(root, "config", "--get", "remote.origin.url")
    if r.returncode != 0 or not r.stdout.strip():
        return None
    m = re.search(r"github\.com[:/]+([^/]+)/([^/.\s]+)", r.stdout.strip())
    return (m.group(1), m.group(2)) if m else None


def prepare_pr(app_dir) -> dict:
    """Commit `app_dir`, push it to the developer's fork, and return where to open
    the pull request. Raises SubmitError (with a fixable, user-facing message) on any
    problem. Returns {branch, fork, compare_url}."""
    app_dir = Path(app_dir).resolve()
    if not (app_dir / "app.star").exists():
        raise SubmitError("That folder isn't an app (there's no app.star in it).")

    root = _repo_root(app_dir)
    try:
        rel = app_dir.relative_to(root).as_posix()
    except ValueError:
        raise SubmitError("Your app folder is outside its git repository, move it under the repo's apps/ folder.")
    slug = app_dir.name

    up_owner = UPSTREAM.split("/")[0]
    origin = _origin(root)
    if origin is None:
        raise SubmitError(
            "No GitHub 'origin' remote found. Fork the repo on GitHub, clone your fork, "
            "and work in that clone, then submit.")
    owner, repo = origin
    if owner.lower() == up_owner.lower():
        raise SubmitError(
            "Your git 'origin' is the main Glance repo, not your fork. On GitHub click "
            "Fork, clone YOUR fork, move your app there, and submit from it.")

    branch = f"submit-{slug}"
    compare_url = f"https://github.com/{UPSTREAM}/compare/main...{owner}:{branch}?expand=1"

    co = _git(root, "checkout", "-B", branch)
    if co.returncode != 0:
        raise SubmitError("Couldn't start a submit branch:\n" + (co.stderr.strip() or co.stdout.strip()))

    add = _git(root, "add", "--", rel)
    if add.returncode != 0:
        raise SubmitError("Couldn't stage your app:\n" + add.stderr.strip())

    # Commit only this app's folder. Skip if there's nothing new (a re-submit whose
    # files are already committed) so we can still push the existing branch.
    if _git(root, "diff", "--cached", "--quiet", "--", rel).returncode != 0:
        cm = _git(root, "commit", "-m", f"Add {slug}", "--", rel)
        if cm.returncode != 0:
            raise SubmitError("Couldn't commit your app:\n" + (cm.stderr.strip() or cm.stdout.strip()))

    push = _git(root, "push", "-u", "origin", branch, timeout=180)
    if push.returncode != 0:
        raise SubmitError(
            f"Your app is committed on branch '{branch}', but pushing to your fork failed. "
            f"Sign in to git (your credential manager) and run:\n\n"
            f"    git push -u origin {branch}\n\n"
            f"then open:\n    {compare_url}\n\n"
            + (push.stderr.strip() or push.stdout.strip()))

    return {"branch": branch, "fork": f"{owner}/{repo}", "compare_url": compare_url}
