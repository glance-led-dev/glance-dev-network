"""The GDN app model.

A GDN app is a folder containing:
  - manifest.yaml : metadata, canvas width, declared inputs, pages, refresh
  - app.py        : defines `app = App(...)` and one render fn per page

Render functions receive a ready-made Canvas and the resolved inputs:

    app = App(name="Weather", width=192)

    @app.page("current", title="Current")
    def render(c, inputs):
        c.fill("black")
        c.text(inputs["zip"], 4, 12, font="5x7", color="white")

Pages are static images (32px tall). Multiple pages = multiple images the panel
rotates through (page 1 current, page 2 weekly, ...).
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional


@dataclass
class Input:
    key: str
    type: str = "string"          # data type: string | number | choice
    label: str = ""
    default: object = None
    choices: Optional[List[str]] = None
    help: str = ""
    # UI widget the client shows for this input. Optional; when unset the form
    # falls back to `type` (choice->dropdown, number->number, else free-text).
    # One of: free-text | dropdown | selection | checkbox | date | date-past | color
    app_input_type: Optional[str] = None

    def coerce(self, raw):
        if raw is None or raw == "":
            return self.default
        if self.type == "number":
            try:
                f = float(raw)
                return int(f) if f.is_integer() else f
            except (TypeError, ValueError):
                return self.default
        return raw


@dataclass
class Page:
    name: str
    fn: Callable
    title: str = ""


class App:
    def __init__(
        self,
        name: str = "Untitled",
        width: int = 192,
        height: int = 32,
        refresh: int = 300,
        author: str = "",
        description: str = "",
    ):
        self.name = name
        self.width = int(width)
        self.height = int(height)
        self.refresh = int(refresh)
        self.author = author
        self.description = description
        self.pages: List[Page] = []
        self.inputs: List[Input] = []

    def page(self, name: str, title: str = ""):
        """Decorator registering a render function as a page."""
        def deco(fn: Callable) -> Callable:
            self.pages.append(Page(name=name, fn=fn, title=title or name))
            return fn
        return deco

    def input(self, key: str, type: str = "string", label: str = "",
              default=None, choices=None, help: str = "",
              app_input_type: Optional[str] = None) -> "App":
        self.inputs.append(Input(key, type, label or key, default, choices, help,
                                 app_input_type))
        return self

    # --- inputs ------------------------------------------------------------
    def input_defaults(self) -> Dict[str, object]:
        return {i.key: i.default for i in self.inputs}

    def resolve_inputs(self, raw: Optional[Dict[str, object]]) -> Dict[str, object]:
        raw = raw or {}
        resolved = {}
        for i in self.inputs:
            resolved[i.key] = i.coerce(raw.get(i.key))
        # pass through any extra keys the caller supplied
        for k, v in raw.items():
            resolved.setdefault(k, v)
        return resolved

    def get_page(self, name: Optional[str] = None) -> Page:
        if not self.pages:
            raise ValueError(f"app {self.name!r} defines no pages")
        if name is None:
            return self.pages[0]
        for p in self.pages:
            if p.name == name:
                return p
        raise KeyError(f"page {name!r} not found in {self.name!r}")
