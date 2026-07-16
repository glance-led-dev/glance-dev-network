# Glance Developer Network

Build apps for Glance's SCROLL and LED V2. Write a few simple lines, preview
instantly in your browser, and submit your app with a pull request.

**Full guide, tutorials & API reference: https://glance-led.dev**

![Glance Dev Studio](https://glance-led.dev/img/studio/glance-dev-studio.png)

*Glance Dev Studio: your code, a live LED preview, the settings form, and
validation, all in one browser window.*

## Ownership and use

**Copyright (c) Glance. All rights reserved.**

Glance Dev Studio, the `gdn` toolkit, and everything in this repository are the
property of Passive Income Consulting LLC (DBA GLANCE-LED). The repository is shared for one purpose: so developers can
**build apps for Glance LED panels and submit them** through a pull request, and
so the community can propose improvements to shared app code. That is what it is
here for, and those contributions are genuinely welcome.

> **That permission does not extend to the Studio or the platform itself.** You may
> **not** fork, copy, rebrand, redistribute, or publish Glance Dev Studio, or any
> modified or derivative version of it, and you may **not** make explicit changes to
> the Studio or the platform code, without the **prior written permission of Glance**.

Building your own app, or opening a pull request to improve this repository, is
encouraged. Standing up a modified, rebranded, or competing Studio is not. All
contributions submitted here are licensed to Glance for use within the Glance
Developer Network. For any use beyond building and submitting apps, contact Glance
at glance-led.com.

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

## Features in the GLANCE DEV STUDIO:

<table>
  <tr>
    <td width="33%" valign="top"><img src="https://glance-led.dev/img/studio/autocomplete.png" alt="Autocomplete for the drawing API"><br><sub>Autocomplete for the drawing API</sub></td>
    <td width="33%" valign="top"><img src="https://glance-led.dev/img/studio/sprite-editor.png" alt="Built-in pixel-art editor"><br><sub>Built-in pixel-art / sprite editor</sub></td>
    <td width="33%" valign="top"><img src="https://glance-led.dev/img/studio/create-new-app.png" alt="Create a new app"><br><sub>Create a new app in a click</sub></td>
  </tr>
</table>

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
