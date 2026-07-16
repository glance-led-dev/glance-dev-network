# Contributing an app

Anyone can add an app to the Glance Developer Network. Apps are sandboxed, so
submitting one is safe by design — it can only draw a picture, nothing else.

## Add your app in 4 steps

1. **Fork** this repo and clone your fork.
2. **Install the SDK** and scaffold an app:
   ```bash
   pip install -e .
   gdn new apps/my-cool-app
   ```
   (Put it under `apps/` — one folder per app.)
3. **Build it.** Edit `apps/my-cool-app/app.star` and `manifest.yaml`, previewing as you go:
   ```bash
   gdn preview apps/my-cool-app      # or: gdn studio apps/my-cool-app
   ```
   New to this? See the full guide and API reference at https://glance-led.dev
4. **Submit it** — validate and open the pull request in one step:
   ```bash
   gdn submit apps/my-cool-app
   ```
   (Or click **Validate & Submit** in `gdn studio`.) That validates your app, pushes it to
   your fork, and opens GitHub's "create pull request" page. Prefer to do it by hand? Run
   `gdn validate apps/my-cool-app`, commit your app folder, and open the PR yourself.

## What we look for

- **It renders.** `gdn validate` must pass (our CI runs the same check on your PR automatically).
- **One folder under `apps/`.** A PR should add *your app*, not change the SDK (`gdn/`), the
  server, or other people's apps. Core changes get a closer look.
- **No secrets.** Never commit API keys. A dev key goes in `secrets.dev.yaml` (git-ignored);
  in production Glance injects keys server-side.
- **Assets are small PNGs**, listed under `assets:` in your manifest.
- **Text is UPPERCASE** (the panel fonts have no lowercase).

## What happens next

Your PR runs the automated validator. Once it's green and reviewed, we merge it —
and it deploys to the live render service automatically. That's it. 🎉
