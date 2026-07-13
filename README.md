# Glance Developer Network

Build tiny apps for Glance's LED panels. Write a few simple lines, preview
instantly in your browser, and submit your app with a pull request.

**📖 Full guide, tutorials & API reference: https://glance-led.dev**

## Install

```bash
pip install -e .
gdn version        # should print: gdn 0.1.0
```

Requires Python 3.9+.

## Open the Studio

Glance Dev Studio is the easiest way to build: your code, a live LED preview, the
settings form, and validation in one browser window. From this folder, run:

```bash
gdn studio
```

Or skip the terminal and double-click the launcher for your system: `studio.bat`
(Windows), `studio.command` (macOS), or `studio.sh` (Linux).

## Make an app

```bash
gdn new apps/my-app
gdn preview apps/my-app        # live preview in your browser
```

Edit `apps/my-app/manifest.yaml` (name, size, inputs) and `apps/my-app/app.star`:

```python
def main(c, ctx):
    c.fill("black")
    c.text("HELLO", c.width // 2, 12, font="7x12", color="amber", align="center")
```

## Check it

```bash
gdn validate apps/my-app
```

## Submit it

Fork this repo, add your app under `apps/`, and open a pull request. CI validates
it automatically; once it's merged it goes live. See
**[CONTRIBUTING.md](CONTRIBUTING.md)**.

## Commands

`gdn new` · `preview` · `studio` · `build` · `render --page N` · `validate` ·
`translate` · `fonts` · `version`


