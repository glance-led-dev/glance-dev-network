"""GDN — the Glance Developer Network SDK.

Build LED-panel "visuals" in Python that render exactly like Glance's panels,
preview them locally, and package them for submission.

Quick start:

    from gdn import App

    app = App(name="Hello", width=192)

    @app.page("main")
    def render(c, inputs):
        c.fill("black")
        c.text("HELLO GLANCE", c.width // 2, 12, font="7x12",
               color="green", align="center")

Then `gdn preview` in the app folder to see it on a simulated panel.
"""
from __future__ import annotations

from .app import App, Input, Page
from .canvas import Canvas
from .colors import quantize565, to_rgb
from . import fonts, rgb565

__version__ = "0.1.0"

__all__ = [
    "App",
    "Input",
    "Page",
    "Canvas",
    "to_rgb",
    "quantize565",
    "fonts",
    "rgb565",
    "__version__",
]
