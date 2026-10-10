"""Imported once by the render zygote (see zygote.py), so every forked render
starts with its imports done and its caches filled instead of paying for them
itself."""
from .. import fonts, scene
from . import executor  # noqa: F401  (pulls in starlark, requests, yaml, Pillow)

fonts._all()        # the 1.1MB fonts.json, parsed once
scene._validator()  # jsonschema import + validator build
