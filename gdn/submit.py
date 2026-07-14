"""One-button app submission for Glance Dev Studio.

Validate & Submit takes a finished app and turns it into a pull request: it makes
sure the developer has a fork of the catalog repo, pushes the app to it on its own
branch, and opens the PR, all through the developer's normal GitHub sign-in (their
OS credential manager, the same one `git push` uses). There's no separate access
token or GitHub CLI to set up.

The submission is built in an isolated git worktree, so it never disturbs the files
or branch the developer is working on. Each app is committed on a fresh branch off
the latest catalog `main`, which is why publishing a second app needs no re-pull or
extra setup.
"""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path

# The public repo apps are submitted to. Pull requests open against its `main`.
UPSTREAM = "glance-led-dev/glance-dev-network"
_API = "https://api.github.com"
_UA = "glance-dev-studio"


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
            "This app isn't inside a git repository. To publish, clone the Glance app repo "
            "with git and keep your app in its apps/ folder.")
    return Path(r.stdout.strip())


def _app_paths(app_dir):
    """Validate the app folder and return (app_dir, repo_root, rel_path, slug)."""
    app_dir = Path(app_dir).resolve()
    if not (app_dir / "app.star").exists():
        raise SubmitError("That folder isn't an app (there's no app.star in it).")
    root = _repo_root(app_dir)
    try:
        rel = app_dir.relative_to(root).as_posix()
    except ValueError:
        raise SubmitError("Your app folder is outside its git repository, move it under the repo's apps/ folder.")
    return app_dir, root, rel, app_dir.name


def _token(root: Path):
    """Return (username, token) from the developer's git credential helper for
    github.com, the same sign-in `git push` uses. Raises SubmitError if none."""
    try:
        r = subprocess.run(["git", "-C", str(root), "credential", "fill"],
                           input="protocol=https\nhost=github.com\n\n",
                           capture_output=True, text=True, timeout=180)
    except (OSError, subprocess.SubprocessError):
        raise SubmitError("Couldn't reach your git credential manager to sign in to GitHub.")
    if r.returncode != 0:
        raise SubmitError(
            "You're not signed in to GitHub for git yet. Do one normal `git push` (or sign in "
            "through your credential manager), then publish again.")
    user = tok = ""
    for line in r.stdout.splitlines():
        if line.startswith("username="):
            user = line[9:]
        elif line.startswith("password="):
            tok = line[9:]
    if not tok:
        raise SubmitError("Your GitHub sign-in didn't return an access token. Sign in again and retry.")
    return user, tok


def _api(method: str, path_or_url: str, token: str, body=None):
    """Call the GitHub REST API. Returns (status_code, parsed_json)."""
    url = path_or_url if path_or_url.startswith("http") else _API + path_or_url
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"token {token}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("User-Agent", _UA)
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            raw = resp.read().decode()
            return resp.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            parsed = json.loads(raw)
        except ValueError:
            parsed = {"message": raw}
        return e.code, parsed
    except urllib.error.URLError as e:
        raise SubmitError(f"Couldn't reach GitHub ({e.reason}). Check your internet connection and retry.")


def _ensure_fork(login: str, up_owner: str, up_repo: str, token: str, note) -> bool:
    """Make sure `login` has a fork of up_owner/up_repo. Returns True if it created one."""
    st, _ = _api("GET", f"/repos/{login}/{up_repo}", token)
    if st == 200:
        return False
    if st != 404:
        raise SubmitError("Couldn't check for your fork on GitHub. Try again in a moment.")
    note("Creating your fork…")
    st, _ = _api("POST", f"/repos/{up_owner}/{up_repo}/forks", token)
    if st not in (200, 201, 202):
        raise SubmitError(
            "Couldn't create your fork automatically (your GitHub sign-in may not allow it). "
            f"Create it once at https://github.com/{up_owner}/{up_repo}/fork, then publish again.")
    for _ in range(30):                      # forking is async; wait for it to appear
        time.sleep(2)
        st, _ = _api("GET", f"/repos/{login}/{up_repo}", token)
        if st == 200:
            return True
    raise SubmitError("Your fork is still being set up on GitHub. Give it a moment, then publish again.")


def submit_via_fork(app_dir, log=None) -> dict:
    """Publish an app end to end: ensure a fork, push the app to it on its own branch
    (built in an isolated worktree so the developer's files aren't touched), and open a
    pull request against the catalog. Uses the developer's GitHub sign-in. `log` is an
    optional callback(str) for progress. Returns
    {pr_url, fork, branch, created_fork, login, compare_url}. Raises SubmitError with a
    user-facing message on any problem."""
    note = (lambda m: log(m)) if log else (lambda m: None)
    app_dir, root, rel, slug = _app_paths(app_dir)
    up_owner, up_repo = UPSTREAM.split("/")
    branch = f"submit-{slug}"

    # Render the catalog preview images so preview/<page>.png ships with the app.
    note("Rendering preview images…")
    try:
        from .preview import write_previews
        write_previews(app_dir)
    except Exception:  # noqa: BLE001
        pass           # previews are a nice-to-have, never block a submit on them

    note("Signing in to GitHub…")
    _user, token = _token(root)
    st, me = _api("GET", "/user", token)
    if st != 200 or not me.get("login"):
        raise SubmitError("Couldn't confirm your GitHub account from your sign-in. Sign in again and retry.")
    login = me["login"]

    if login.lower() == up_owner.lower():
        # You can't fork your own repo; push the branch straight to it (maintainer path).
        fork_full = UPSTREAM
        created = False
    else:
        fork_full = f"{login}/{up_repo}"
        created = _ensure_fork(login, up_owner, up_repo, token, note)
    fork_url = f"https://github.com/{fork_full}.git"
    up_url = f"https://github.com/{UPSTREAM}.git"
    head = f"{login}:{branch}"
    compare_url = f"https://github.com/{UPSTREAM}/compare/main...{head}?expand=1"

    note("Fetching the latest catalog…")
    fetch = _git(root, "fetch", up_url, "main", timeout=120)
    if fetch.returncode != 0:
        raise SubmitError("Couldn't fetch the latest catalog from GitHub:\n"
                          + (fetch.stderr.strip() or fetch.stdout.strip()))

    wt = Path(tempfile.mkdtemp(prefix="gdn-submit-"))
    try:
        note("Preparing your app on a fresh branch…")
        aw = _git(root, "worktree", "add", "--detach", str(wt), "FETCH_HEAD", timeout=60)
        if aw.returncode != 0:
            raise SubmitError("Couldn't prepare a workspace for your submission:\n" + aw.stderr.strip())
        dest = wt / rel
        if dest.exists():
            shutil.rmtree(dest, ignore_errors=True)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(app_dir, dest,
                        ignore=shutil.ignore_patterns(".git", "__pycache__", "*.pyc", "build", ".gdn"))
        _git(wt, "checkout", "-B", branch)
        _git(wt, "add", "--", rel)
        if _git(wt, "diff", "--cached", "--quiet").returncode == 0:
            raise SubmitError("There's nothing new to publish, this app already matches the catalog.")
        cm = _git(wt, "-c", f"user.name={login}", "-c", f"user.email={login}@users.noreply.github.com",
                  "commit", "-m", f"Add {slug}")
        if cm.returncode != 0:
            raise SubmitError("Couldn't commit your app:\n" + (cm.stderr.strip() or cm.stdout.strip()))
        note("Pushing your app to your fork…")
        push = _git(wt, "push", "--force", fork_url, f"{branch}:{branch}", timeout=180)
        if push.returncode != 0:
            raise SubmitError("Couldn't push your app to your fork. Make sure you're signed in to git, "
                              "then publish again.\n" + (push.stderr.strip() or push.stdout.strip()))
    finally:
        _git(root, "worktree", "remove", "--force", str(wt))
        shutil.rmtree(wt, ignore_errors=True)

    note("Opening your pull request…")
    st, pr = _api("POST", f"/repos/{up_owner}/{up_repo}/pulls", token,
                  {"title": f"Add {slug}", "head": head, "base": "main",
                   "body": f"Adds the `{slug}` app.\n\nSubmitted from Glance Dev Studio.",
                   "maintainer_can_modify": True})
    if st == 201 and pr.get("html_url"):
        pr_url = pr["html_url"]
    else:
        st2, existing = _api("GET", f"/repos/{up_owner}/{up_repo}/pulls?head={head}&state=open", token)
        pr_url = (existing[0]["html_url"]
                  if st2 == 200 and isinstance(existing, list) and existing else compare_url)

    return {"pr_url": pr_url, "fork": fork_full, "branch": branch,
            "created_fork": created, "login": login, "compare_url": compare_url}
